defmodule Tertia.Repo.Migrations.AddStatusAndSignupHashToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :status, :string, null: false
      add :signup_hash, :string
    end
  end
end
