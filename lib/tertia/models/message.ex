defmodule Tertia.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]
  @required ~w(type channel_id user_id)a
  @optional ~w(text)a

  schema("messages") do
    field :type, :string, null: false
    field :text, :string
    belongs_to(:channel, Tertia.Channel, type: :binary_id)
    belongs_to(:user, Tertia.User, type: :binary_id)
    # attachments will become associations
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(params, struct \\ %__MODULE__{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_inclusion(:type, ~w(text))
  end
end
