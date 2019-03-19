defmodule Tertia.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :string, null: false)
      add(:text, :text)

      add(:channel_id, references("channels", type: :binary_id, on_delete: :delete_all),
        null: false
      )

      add(:user_id, references("users", type: :binary_id, on_delete: :delete_all), null: false)
      timestamps(type: :utc_datetime_usec)
    end
  end
end
