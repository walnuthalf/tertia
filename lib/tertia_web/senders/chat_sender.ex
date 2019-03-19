defmodule TertiaWeb.ChatSender do
  alias Tertia.ChatQueries
  alias TertiaWeb.MainSender

  def channel_echo(channel_id, message) do
    message = ChatQueries.enrich_message(message)
    MainSender.publish(message, :message, channel_id)

    ChatQueries.channel_updates(message)
    |> Enum.map(fn channel ->
      MainSender.publish(channel, :channel, channel.receiver.id)
    end)
  end

  # TODO
  def channel_created_echo(channel) do
    channel
  end
end
