defmodule TertiaWeb.MainSender do
  @type_to_tag %{message: "channel_message", channel: "user_channel"}
  @publish_module Application.get_env(:tertia, :sandbox)[:absinthe_subscription]

  def publish(data, type, id) do
    @publish_module.publish(TertiaWeb.Endpoint, data, [
      {type, Map.get(@type_to_tag, type) <> "::" <> id}
    ])
  end
end
