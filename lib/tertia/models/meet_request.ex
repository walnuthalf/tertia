defmodule Tertia.MeetRequest do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema("meet_requests") do
    field(:name, :string)
    field(:point, Geo.PostGIS.Geometry)
    field(:reserved_count, :integer, null: false)
    field(:max_participants, :integer, null: false)
    field(:policy, :string, null: false)
    # belongs_to(:user, Tertia.User)
    # belongs_to(:channel, Tertia.Channel)
    # belongs_to(:activity, Tertia.Activity)
    # has_many(:participants, Tertia.User)
    timestamps(type: :utc_datetime)
  end
end
