defmodule Tertia.Repo.Migrations.CreateUsersIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
    create unique_index(:users, [:token])
  end
end
