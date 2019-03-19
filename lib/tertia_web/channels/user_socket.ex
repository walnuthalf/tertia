defmodule TertiaWeb.UserSocket do
  use Phoenix.Socket

  use Absinthe.Phoenix.Socket,
    schema: TertiaWeb.Schema

  import Ecto.Query, only: [where: 2]
  alias Tertia.{Repo, User}

  ## Channels
  # channel "room:*", TertiaWeb.RoomChannel

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(%{"token" => token}, socket, _connect_info) do
    User
    |> where(token: ^token)
    |> Repo.one()
    |> case do
      nil ->
        :error

      user ->
        socket = update_socket(socket, user)
        {:ok, socket}
    end
  end

  def connect(_, _socket, _connect_info), do: :error

  defp update_socket(socket, user) do
    Absinthe.Phoenix.Socket.put_options(
      socket,
      context: %{current_user: user}
    )
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     TertiaWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
