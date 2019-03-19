defmodule TertiaWeb.MainSenderSandbox do
  def publish(endpoint, data, opts),
    do: send(self(), {:sandbox, {Absinthe.Subscription, :publish, [endpoint, data, opts]}})
end
