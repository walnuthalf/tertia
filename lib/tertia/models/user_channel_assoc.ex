defmodule Tertia.UserChannelAssoc do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @required [:type, :user_id, :channel_id]
  @optional [:last_read_message_id]

  schema("user_channel_assocs") do
    field(:type, :string, null: false)
    belongs_to(:last_read_message, Tertia.Message, type: :binary_id)
    belongs_to(:channel, Tertia.Channel, type: :binary_id)
    belongs_to(:user, Tertia.User, type: :binary_id)
  end

  def changeset(params, struct \\ %__MODULE__{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
  end

  # def validate_last_read_inserted_at(changeset, struct) do
  #   validate_change(changeset, :last_read_inserted_at, fn _, inserted_at ->
  #     old_inserted_at = Map.get(struct, :last_read_inserted_at)
  #     if is_nil(old_inserted_at) || old_inserted_at < inserted_at do
  #       []
  #     else
  #       [{:last_read_inserted_at, "invalid last_read_inserted_at"}]
  #     end
  #   end)
  # end
end
