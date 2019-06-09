defmodule TertiaWeb.SignupController do
  use TertiaWeb, :controller

  def signup(conn, %{hash: hash}) do
    case Tertia.UserCommands.activate_user(hash) do
      :ok -> simple_render(conn, 200)
      _ -> simple_render(conn, 400)
    end
  end

  defp simple_render(conn, status_code) do
    conn |> put_resp_content_type("text/plain") |> send_resp(status_code, "")
  end
end
