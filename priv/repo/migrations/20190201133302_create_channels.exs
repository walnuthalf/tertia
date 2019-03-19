defmodule Tertia.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :string, null: false)
      add(:name, :string, null: false)
      add(:description, :text)
      timestamps(type: :utc_datetime_usec)
    end
  end
end
