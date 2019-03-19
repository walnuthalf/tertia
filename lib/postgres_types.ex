# needs to be here, else PostGIS doesn't work
Postgrex.Types.define(
  Tertia.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Poison
)
