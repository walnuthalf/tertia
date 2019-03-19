defmodule TertiaWeb.ChatResolver do
  alias Tertia.{ChatQueries, ChatCommands, Utils.Validators, ChatValidators}
  alias TertiaWeb.ChatSender

  def send_text(_, %{channel_id: channel_id, text: text}, context) do
    with :ok <- (text != "" && :ok) || {:error, "cannot send an empty string"},
         {:ok, user} <- Validators.validate_user(context),
         true <- ChatValidators.validate_user_channel(user.id, channel_id) do
      msg =
        ChatCommands.insert_text_message!(%{
          channel_id: channel_id,
          user_id: user.id,
          text: text
        })

      ChatSender.channel_echo(channel_id, msg)

      {:ok, msg}
    end
  end

  def channel_page(_, %{channel_id: channel_id} = params, context) do
    with {:ok, user} <- Validators.validate_user(context),
         true <- ChatValidators.validate_user_channel(user.id, channel_id) do
      {:ok, ChatQueries.channel_page(channel_id, cursor: Map.get(params, :cursor))}
    end
  end

  def init_personal_channel(_, %{user_id: user_id}, context) do
    with {:ok, user} <- Validators.validate_user(context) do
      ChatCommands.personal_channel(user.id, user_id)
    end
  end

  def channels(_, _, context) do
    with {:ok, user} <- Validators.validate_user(context) do
      {:ok, ChatQueries.user_channels(user.id)}
    end
  end

  def update_last_read_message(_, %{message_id: message_id}, context) do
    with {:ok, user} <- Validators.validate_user(context),
         {:ok, _} <- ChatCommands.update_last_read(message_id, user.id) do
      {:ok, true}
    end
  end
end
