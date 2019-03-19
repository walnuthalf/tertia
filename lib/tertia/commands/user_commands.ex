defmodule Tertia.UserCommands do
  alias Tertia.{Repo, User}
  alias Tertia.Utils.RepoUtils

  def add_user!(%{password: password} = params) do
    {public_key, encrypted_priv} = Tertia.Utils.Crypto.gen_auth_pair(password)

    Map.merge(params, %{
      public_key: public_key,
      encrypted_private_key: encrypted_priv
    })
    |> User.changeset()
    |> Repo.insert!()
  end

  def update_location(user, %{longitude: lng, latitude: lat}) do
    point = RepoUtils.build_point(lng, lat)

    case User.changeset(%{location: point}, user) |> Repo.update() do
      {:ok, user} -> {:ok, user}
      _ -> {:error, "location update failed"}
    end
  end
end
