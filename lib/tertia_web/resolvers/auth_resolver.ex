defmodule TertiaWeb.AuthResolver do
  alias Tertia.Utils.Crypto
  alias Tertia.Repo

  def login(_, %{email: email, password: password}, _) do
    with %{public_key: public, encrypted_private_key: encrypted_private} = user <-
           Repo.get_by(Tertia.User, email: email),
         priv <- Crypto.decrypt(encrypted_private, password),
         true <- Crypto.match_keys(public, priv) do
      if user.token do
        {:ok, %{token: user.token}}
      else
        token = Ecto.UUID.generate()
        # write the token to the DB
        Tertia.User.changeset(%{token: token}, user) |> Tertia.Repo.update()
        {:ok, %{token: token}}
      end
    else
      _ ->
        {:error, "Authentication failed"}
    end
  end
end
