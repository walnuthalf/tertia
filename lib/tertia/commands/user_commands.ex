defmodule Tertia.UserCommands do
  alias Tertia.{Repo, User}
  alias Tertia.Utils.RepoUtils

  def add_user(%{password: password} = params) do
    {public_key, encrypted_priv} = Tertia.Utils.Crypto.gen_auth_pair(password)

    Map.merge(params, %{
      public_key: public_key,
      encrypted_private_key: encrypted_priv
    })
    |> User.changeset()
    |> Repo.insert()
  end

  def add_user!(params) do
    {:ok, user} = add_user(params)
    user
  end

  def update_location(user, %{longitude: lng, latitude: lat}) do
    point = RepoUtils.build_point(lng, lat)

    case User.changeset(%{location: point}, user) |> Repo.update() do
      {:ok, user} -> {:ok, user}
      _ -> {:error, "location update failed"}
    end
  end

  def activate_user(hash) do
    case RepoUtils.get_fields_by(User, [signup_hash: hash], [:status, :signup_hash]) do
      nil ->
        {:error, "user not found"}

      user ->
        User.changeset(%{status: "active"}, user) |> Repo.update()
        :ok
    end
  end
end
