defmodule TertiaWeb.Schema do
  use Absinthe.Schema
  import_types(Absinthe.Type.Custom)
  import_types(TertiaWeb.Schema.Scalars)

  alias TertiaWeb.{AuthResolver, UserResolver, ChatResolver}

  object :user do
    field :id, non_null(:uuid)
    field :username, non_null(:string)
    field :name, non_null(:string)
  end

  object :session do
    field :token, non_null(:string)
  end

  object :channel do
    field :id, non_null(:uuid)
    field :name, non_null(:string)
    field :type, non_null(:string)
    field :last_message, :message
    field :has_unread, non_null(:boolean)
  end

  object :message do
    field :id, non_null(:uuid)
    field :text, non_null(:string)
    field :inserted_at, non_null(:datetime)
    field :user, non_null(:user)
    field :channel_id, non_null(:uuid)
  end

  object :message_ack do
    field :id, non_null(:uuid)
    field :inserted_at, non_null(:datetime)
  end

  object :channel_page do
    field :id, non_null(:uuid)
    field :messages, list_of(:message)
    field :next_cursor, :datetime
  end

  input_object :location do
    field :longitude, non_null(:decimal)
    field :latitude, non_null(:decimal)
  end

  query do
    @desc "Get user profile"
    field :my_profile, :user do
      resolve(&UserResolver.my_profile/3)
    end

    @desc "Get channel messages"
    field :channel_page, :channel_page do
      arg(:channel_id, non_null(:uuid))
      arg(:cursor, :datetime)
      resolve(&ChatResolver.channel_page/3)
    end

    @desc "Get channels"
    field :channels, list_of(:channel) do
      resolve(&ChatResolver.channels/3)
    end
  end

  subscription do
    field :channel, :channel do
      config(fn _, %{context: %{current_user: user}} ->
        {:ok, topic: "user_channel::" <> user.id}
      end)

      # no trigger, messages will be sent by a helper sender
    end

    field :message, :message do
      arg(:channel_id, non_null(:uuid))

      config(fn %{channel_id: channel_id}, %{context: %{current_user: user}} ->
        if Tertia.ChatQueries.user_in_channel?(user.id, channel_id) do
          {:ok, topic: "channel_message::" <> channel_id}
        else
          {:error, "user not in channel"}
        end
      end)

      # no trigger, messages will be sent by a helper sender
    end
  end

  mutation do
    @desc "Login"
    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&AuthResolver.login/3)
    end

    @desc "Update user's location"
    field :update_location, :boolean do
      arg(:location, non_null(:location))
      resolve(&UserResolver.update_location/3)
    end

    field :init_personal_channel, :channel do
      arg(:user_id, non_null(:uuid))
      resolve(&ChatResolver.init_personal_channel/3)
    end

    field :send_text_message, :message_ack do
      arg(:channel_id, non_null(:uuid))
      arg(:text, non_null(:string))
      resolve(&ChatResolver.send_text/3)
    end

    field :update_last_read_message, :boolean do
      arg(:message_id, non_null(:uuid))
      resolve(&ChatResolver.update_last_read_message/3)
    end
  end
end
