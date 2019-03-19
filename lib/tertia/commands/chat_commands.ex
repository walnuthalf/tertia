defmodule Tertia.ChatCommands do
  alias Tertia.{Repo, Channel, UserChannelAssoc, Message, ChatQueries}

  def insert_text_message!(params) do
    Map.merge(params, %{type: "text"})
    |> Message.changeset()
    |> Repo.insert!()
  end

  def personal_channel(user1_id, user2_id) do
    Repo.transaction(fn ->
      case ChatQueries.find_personal_channel(user1_id, user2_id) do
        nil -> create_personal_channel!(user1_id, user2_id)
        channel -> channel
      end
    end)
  end

  def create_personal_channel!(user1_id, user2_id) do
    # create channel
    channel = Channel.changeset(%{name: "personal", type: "personal"}) |> Repo.insert!()
    # create assocs
    create_assoc(channel.id, user1_id)
    create_assoc(channel.id, user2_id)
    channel
  end

  def create_assoc(channel_id, user_id, type \\ "personal") do
    Repo.insert(%UserChannelAssoc{channel_id: channel_id, user_id: user_id, type: type})
  end

  def update_last_read(message_id, user_id) do
    case Repo.get(Message, message_id) do
      nil ->
        {:error, "message not found"}

      %{channel_id: channel_id} ->
        if ChatQueries.user_in_channel?(user_id, channel_id) do
          assoc = Repo.get_by(UserChannelAssoc, user_id: user_id, channel_id: channel_id)

          UserChannelAssoc.changeset(%{last_read_message_id: message_id}, assoc)
          |> Repo.update()
        else
          {:error, "user not in channel"}
        end
    end
  end

  # def set_last_read_inserted_at(user_id, channel_id, inserted_at) do
  #   Repo.transaction(fn ->
  #     assoc = Repo.get_by(UserChannelAssoc, user_id: user_id, channel_id: channel_id)
  #
  #     UserChannelAssoc.changeset(%{last_read_inserted_at: inserted_at}, assoc)
  #     |> Repo.update()
  #   end)
  # end
end
