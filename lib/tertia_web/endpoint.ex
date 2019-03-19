defmodule TertiaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :tertia
  use Absinthe.Phoenix.Endpoint

  socket "/socket", TertiaWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.

  plug Plug.Static.IndexHtml, at: "/"

  plug Plug.Static,
    at: "/",
    from: "priv/client/build/",
    only: ~w(index.html favicon.ico static)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_tertia_key",
    signing_salt: "mzM1ol/3"

  plug TertiaWeb.Router
end
