defmodule Tertia.ChatQueries do
  require Ecto.Query
  import Ecto.Query
  alias Tertia.Repo
  @channel_page_size 25

  def enrich_message(message), do: Tertia.Repo.preload(message, :user)

  def enrich_empty_channel(%{id: channel_id}, user_id) do
    enrich_channel_query(channel_id, user_id, false)
    |> Repo.one()
    |> transform_channel()
  end

  def channel_updates(%{channel_id: channel_id, user: sender} = message) do
    channel =
      channel_base_query()
      |> channel_id_query(channel_id)
      |> preload([:users])
      |> Repo.one()

    Enum.map(channel.users, fn user ->
      channel_update =
        Map.merge(channel, %{
          receiver: user,
          last_message: message,
          has_unread: sender.id != user.id
        })

      if channel_update.type == "personal" do
        other_user = Enum.find(channel.users, fn u -> u.id != user.id end)
        Map.put(channel_update, :name, other_user.name)
      else
        channel_update
      end
    end)
  end

  # channels are sorted by inserted_at of the last message
  def user_channels(user_id) do
    channel_base_query()
    |> last_message_query()
    |> user_assoc_join_query(user_id)
    |> other_user_assoc_join_query(user_id)
    |> channel_select_query(true)
    |> order_by([last_message: m], desc: m.inserted_at)
    |> Repo.all()
    |> transform_channels()
  end

  def transform_channel(result) do
    channel =
      if result.last_message == nil do
        Map.put(result, :has_unread, false)
      else
        message = Map.put(result.last_message, :user, result.last_sender)

        Map.merge(result, %{
          last_message: message,
          has_unread: message.id != result.last_read_message_id
        })
      end

    (channel.type == "personal" && Map.put(channel, :name, channel.other_user.name)) || channel
  end

  def transform_channels(results), do: Enum.map(results, &transform_channel/1)

  def channel_page(channel_id, opts \\ []) do
    messages = channel_messages(channel_id, opts)

    if length(messages) == @channel_page_size do
      %{id: channel_id, messages: messages, next_cursor: List.first(messages).inserted_at}
    else
      %{id: channel_id, messages: messages}
    end
  end

  def channel_messages(channel_id, opts \\ []) do
    cursor = Keyword.get(opts, :cursor, nil)

    base_query =
      from(
        m in Tertia.Message,
        where: m.channel_id == ^channel_id,
        order_by: [desc: m.inserted_at],
        limit: @channel_page_size,
        preload: :user
      )

    ((cursor && where(base_query, [m], m.inserted_at < ^cursor)) || base_query)
    |> Repo.all()
    |> Enum.reverse()
  end

  def user_in_channel?(user_id, channel_id) do
    from(
      a in Tertia.UserChannelAssoc,
      where: a.user_id == ^user_id and a.channel_id == ^channel_id,
      select: a.channel_id
    )
    |> Repo.one()
    |> case do
      nil -> false
      _ -> true
    end
  end

  def channel_users_query(channel_id) do
    from(
      u in Tertia.User,
      join: a in Tertia.UserChannelAssoc,
      on: a.channel_id == ^channel_id and a.user_id == u.id
    )
  end

  def channel_user_ids(channel_id),
    do: channel_users_query(channel_id) |> select([u], u.id) |> Repo.all()

  def channel_users(channel_id), do: channel_users_query(channel_id) |> Repo.all()

  def find_personal_channel(user1_id, user2_id) do
    from(
      c in Tertia.Channel,
      join: a1 in Tertia.UserChannelAssoc,
      on: a1.channel_id == c.id and a1.user_id == ^user1_id and a1.type == "personal",
      join: a2 in Tertia.UserChannelAssoc,
      on: a2.channel_id == c.id and a2.user_id == ^user2_id and a2.type == "personal"
    )
    |> Repo.one()
  end

  def user_id_channel_id_query(user_id) do
    from(
      a in Tertia.UserChannelAssoc,
      select: a.channel_id,
      where: a.user_id == ^user_id and a.type == "personal"
    )
  end

  def channel_query(channel_id, user_id) do
    channel_base_query()
    |> channel_id_query(channel_id)
    |> user_assoc_join_query(user_id)
    |> other_user_assoc_join_query(user_id)
    |> channel_select_query()
  end

  def channel_base_query(), do: from(c in Tertia.Channel, as: :channel)

  def channel_id_query(query, channel_id),
    do: where(query, [channel: c], c.id == ^channel_id)

  def user_assoc_join_query(query, user_id) do
    join(
      query,
      :inner,
      [channel: c],
      a in Tertia.UserChannelAssoc,
      as: :user_channel_assoc,
      on: a.channel_id == c.id and a.user_id == ^user_id
    )
  end

  def all_users_assoc_join_query(query) do
    join(
      query,
      :inner,
      [channel: c],
      a in Tertia.UserChannelAssoc,
      as: :all_users_channel_assoc,
      on: a.channel_id == c.id
    )
  end

  def all_other_users_assoc_join_query(query) do
    join(
      query,
      :inner,
      [channel: c, all_other_users_channel_assoc: a],
      other_u in Tertia.User,
      as: :all_other_users,
      on:
        fragment(
          "? = (SELECT user_id FROM user_channel_assocs WHERE channel_id = ? and user_id <> ? LIMIT 1)",
          other_u.id,
          c.id,
          a.user_id
        )
    )
  end

  def other_user_assoc_join_query(query, user_id) do
    {:ok, user_uuid} = Ecto.UUID.dump(user_id)

    join(
      query,
      :left,
      [channel: c],
      other_u in Tertia.User,
      as: :other_user,
      on:
        fragment(
          "? = (SELECT user_id FROM user_channel_assocs WHERE channel_id = ? and user_id <> ? LIMIT 1)",
          other_u.id,
          c.id,
          ^user_uuid
        )
    )
  end

  def channel_select_query(query, load_last_message \\ false) do
    if load_last_message do
      select(
        query,
        [
          channel: c,
          last_message: m,
          last_message_user: u,
          other_user: other_u,
          user_channel_assoc: a
        ],
        %{
          c
          | other_user: %{name: other_u.name},
            last_message: m,
            last_sender: u,
            last_read_message_id: a.last_read_message_id
        }
      )
    else
      select(query, [channel: c, other_user: other_u, user_channel_assoc: a], %{
        c
        | other_user_name: other_u.name,
          last_read_message_id: a.last_read_message_id
      })
    end
  end

  def last_message_query(query) do
    join(
      query,
      :left,
      [channel: c],
      m in Tertia.Message,
      as: :last_message,
      on:
        fragment(
          "? = (SELECT id FROM messages WHERE channel_id = ? ORDER BY inserted_at DESC LIMIT 1)",
          m.id,
          c.id
        )
    )
    |> join(
      :left,
      [last_message: m],
      u in Tertia.User,
      as: :last_message_user,
      on: m.user_id == u.id
    )
  end

  def enrich_channel_query(channel_id, user_id, load_last_message) do
    if load_last_message do
      channel_query(channel_id, user_id) |> last_message_query()
    else
      channel_query(channel_id, user_id)
    end
    |> channel_id_query(channel_id)
    |> user_assoc_join_query(user_id)
    |> other_user_assoc_join_query(user_id)
    |> channel_select_query(load_last_message)
  end
end
