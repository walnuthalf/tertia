defmodule Tertia.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime_usec]
  @required [:name, :username, :email, :public_key, :encrypted_private_key]
  @optional [:location, :token]

  schema("users") do
    field :name, :string, null: false
    # unique username
    field :username, :string, null: false
    # unique email
    field :email, :string, null: false
    field :public_key, :binary, null: false
    field :encrypted_private_key, :binary, null: false
    field :token, :string
    field :location, Geo.PostGIS.Geometry
    field :token_assigned_at, :utc_datetime_usec
    many_to_many :channels, Tertia.Channel, join_through: "user_channel_assocs"
    timestamps(type: :utc_datetime_usec)
  end

  def changeset(params, struct \\ %__MODULE__{}) do
    struct
    |> cast(params, @required ++ @optional)
    |> validate_required(@required)
    |> validate_format(:email, ~r/@/)
  end
end
