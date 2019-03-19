defmodule Tertia.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]
  @required [:name, :type]

  schema("channels") do
    field :name, :string, null: false
    field :type, :string, null: false
    field :last_message, :any, virtual: true
    field :last_sender, :any, virtual: true
    field :last_read_message_id, :binary_id, virtual: true
    field :other_user, :any, virtual: true
    field :receiver, :any, virtual: true
    field :has_unread, :boolean, virtual: true
    many_to_many :users, Tertia.User, join_through: "user_channel_assocs"
    has_many(:messages, Tertia.Message)
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(params, struct \\ %__MODULE__{}) do
    struct
    |> cast(params, @required)
    |> validate_required(@required)
    |> validate_inclusion(:type, ~w(personal group))
  end
end
