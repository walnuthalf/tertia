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

  def signup(_, %{email: email} = params, _) do
    hash = Ecto.UUID.generate()
    params = Map.merge(params, %{status: "signup", signup_hash: hash})

    case Tertia.UserCommands.add_user(params) do
      {:ok, _} ->
        TertiaWeb.EmailSender.send_signup(email, hash)
        {:ok, true}

      _ ->
        {:error, "Signup failure"}
    end
  end
end
