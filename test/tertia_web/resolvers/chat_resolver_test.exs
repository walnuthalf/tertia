defmodule Tertia.ChatResolverTest do
  use TertiaWeb.ConnCase, async: true
  alias Tertia.Utils.RecordCreator

  @channel_page_size 25
  @channel_query """
    {
      channels {
        id
        name
        lastMessage {
          id
          text
          insertedAt
          user {
            name
          }
        }
      }
    }
  """

  @channel_page_query """
    query ChannelPage($channelId: String!){
      channelPage(channelId: $channelId){
        id
        messages {
          id
          text
          insertedAt
          channelId
          __typename
          user{
            name
          }
        }
        nextCursor
        __typename
      }
    }
  """

  @send_text_message_mutation """
      mutation SendTextMessage($text: String!, $channelId: String!) {
        sendTextMessage(text: $text, channelId: $channelId){
            id
            insertedAt
        }
      }
  """

  describe "channel and messages setup" do
    setup context do
      acc =
        RecordCreator.create(%{user: context.user}, [
          %{
            record_type: :user,
            as: :user2,
            values: %{username: "user2", email: "user2@email.com"}
          },
          :channel,
          %{record_type: :user_channel_assoc, assocs: [:user, :channel]},
          %{
            record_type: :user_channel_assoc,
            as: :user_channel_assoc2,
            assocs: [%{acc_key: :user2, field_name: :user}, :channel]
          },
          %{
            record_type: :message,
            as: :message1,
            assocs: [:user, :channel]
          },
          %{
            record_type: :message,
            as: :message2,
            assocs: [%{acc_key: :user2, field_name: :user}, :channel]
          }
        ])

      {:ok, Map.put(context, :acc, acc)}
    end

    test "user channels", %{acc: acc} = context do
      channel_id = acc.channel.id
      last_message_id = acc.message2.id

      assert [%{"id" => ^channel_id, "lastMessage" => %{"id" => ^last_message_id}}] =
               run_graphql(context, @channel_query, :query, query_name: "channels")
               |> response_data("channels")
    end

    test "channel page", %{acc: acc} = context do
      message1_id = acc.message1.id
      message2_id = acc.message2.id

      res =
        run_graphql(context, @channel_page_query, :param_query,
          query_name: "ChannelPage",
          variables: %{channelId: acc.channel.id}
        )
        |> response_data("channelPage")

      assert %{
               "messages" => [%{"id" => ^message1_id}, %{"id" => ^message2_id}]
             } = res

      # no more messages, cursor should be nil
      assert is_nil(Map.get(res, "nextCursor"))
    end

    test "channel page, lots of messages", %{acc: acc} = context do
      msg_descriptors =
        Enum.flat_map(1..25, fn i ->
          [
            %{
              record_type: :message,
              as: String.to_atom("extra_message#{i}"),
              assocs: [:user, :channel]
            },
            %{
              record_type: :message,
              as: String.to_atom("user2_extra_message#{i}"),
              assocs: [%{acc_key: :user2, field_name: :user}, :channel]
            }
          ]
        end)

      RecordCreator.create(acc, msg_descriptors)

      res =
        run_graphql(context, @channel_page_query, :param_query,
          query_name: "ChannelPage",
          variables: %{channelId: acc.channel.id}
        )
        |> response_data("channelPage")

      # lots of messages, cursor should not be nil
      assert not is_nil(Map.get(res, "nextCursor"))
      assert Enum.count(Map.get(res, "messages")) == @channel_page_size
    end

    test "send text message", %{acc: acc} = context do
      text = "test sendMessageMutation"

      %{"id" => id} =
        run_graphql(context, @send_text_message_mutation, :mutation,
          authenticated: true,
          variables: %{channelId: acc.channel.id, text: text}
        )
        |> response_data("sendTextMessage")

      assert %{text: ^text} = Tertia.Repo.get(Tertia.Message, id)

      run_graphql(context, @send_text_message_mutation, :mutation,
        authenticated: true,
        variables: %{channelId: acc.channel.id, text: text}
      )

      sandbox_msgs =
        get_mailbox()
        |> Enum.map(fn {Absinthe.Subscription, :publish, [TertiaWeb.Endpoint, data, topic_opts]} ->
          {data, topic_opts}
        end)

      # assert topics
      Enum.each(sandbox_msgs, fn
        {%Tertia.Channel{receiver: %{id: user_id}}, topic_opts} ->
          topic = "user_channel::#{user_id}"
          assert [channel: ^topic] = topic_opts

        {%Tertia.Message{channel_id: channel_id}, topic_opts} ->
          topic = "channel_message::#{channel_id}"
          assert [message: ^topic] = topic_opts
      end)

      sandbox_groups =
        Enum.group_by(sandbox_msgs, fn
          {%Tertia.Channel{}, [channel: "user_channel::" <> user_id]} -> {:channel, user_id}
          {%Tertia.Message{channel_id: channel_id}, _} -> {:message, channel_id}
        end)

      # all evens were published
      assert Enum.count(sandbox_groups[{:channel, acc.user.id}]) > 0
      assert Enum.count(sandbox_groups[{:channel, acc.user2.id}]) > 0
      assert Enum.count(sandbox_groups[{:message, acc.channel.id}]) > 0
    end
  end
end
