defmodule Tertia.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :username, :string
      add :email, :string
      add :public_key, :binary, null: false
      add :encrypted_private_key, :binary, null: false
      add :token, :string
      add :token_assigned_at, :utc_datetime_usec
      timestamps(type: :utc_datetime_usec)
    end
  end
end
