defmodule Tertia.Repo.Migrations.CreateMessagesIndexes do
  use Ecto.Migration

  def change do
    create index(:messages, [:channel_id])
    create index(:messages, [:user_id])
  end
end
