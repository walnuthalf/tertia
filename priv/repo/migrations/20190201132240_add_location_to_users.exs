defmodule Tertia.Repo.Migrations.AddLocationToUsers do
  use Ecto.Migration

  @disable_ddl_transaction true

  def up do
    # Add a field `point` with type `geometry(Point,4326)`.
    # This can store a "standard GPS" (epsg4326) coordinate pair {longitude,latitude}.
    # 4326 is srid
    # 2 is dimension
    execute("SELECT AddGeometryColumn ('users','location',4326,'POINT',2)")
    execute("CREATE INDEX CONCURRENTLY users_location_index on users USING gist (location)")
  end

  def down do
    execute("DROP INDEX users_location_index")
    execute("SELECT DropGeometryColumn ('users','location')")
  end
end
