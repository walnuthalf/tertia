defmodule Tertia.Activity do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema("activities") do
    field :name, :string, null: false
    field :description, :string, null: false
    field :equipment, :string, null: false
    timestamps(type: :utc_datetime)
  end
end
