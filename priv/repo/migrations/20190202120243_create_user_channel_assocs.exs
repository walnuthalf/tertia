defmodule Tertia.Repo.Migrations.CreateUserChannelAssocs do
  use Ecto.Migration

  def change do
    create table(:user_channel_assocs, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :string, null: false)
      add(:last_read_message_id, references("messages", type: :binary_id))
      add(:user_id, references("users", type: :binary_id), null: false, on_delete: :delete_all)

      add(:channel_id, references("channels", type: :binary_id, on_delete: :delete_all),
        null: false
      )
    end

    create unique_index("user_channel_assocs", [:user_id, :channel_id])
  end
end
