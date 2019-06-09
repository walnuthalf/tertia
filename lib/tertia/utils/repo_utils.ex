defmodule Tertia.Utils.RepoUtils do
  alias Tertia.Repo
  import Ecto.Query

  def try_find(model, id, name) do
    with {:ok, id} <- Ecto.UUID.cast(id),
         result when not is_nil(result) <- Repo.get(model, id) do
      {:ok, result}
    else
      _ ->
        {:error, "#{name} ID #{id} not found"}
    end
  end

  def get_field_by(model, params, field) do
    case get_fields_by(model, params, [field]) do
      nil -> nil
      result -> Map.get(result, field)
    end
  end

  def get_fields_by(model, params, fields) do
    from(model, where: ^params, select: ^fields) |> Repo.one()
  end

  def within(query, point, radius_in_m) do
    {lng, lat} = point.coordinates

    from(
      model in query,
      where:
        fragment(
          "ST_DWithin(?::geography, ST_SetSRID(ST_MakePoint(?, ?), ?), ?)",
          model.point,
          ^lng,
          ^lat,
          ^point.srid,
          ^radius_in_m
        )
    )
  end

  def order_by_nearest(query, point) do
    {lng, lat} = point.coordinates

    from(
      model in query,
      order_by:
        fragment(
          "? <-> ST_SetSRID(ST_MakePoint(?,?), ?)",
          model.point,
          ^lng,
          ^lat,
          ^point.srid
        )
    )
  end

  def select_with_distance(query, point) do
    {lng, lat} = point.coordinates

    from(
      model in query,
      select: %{
        model
        | distance:
            fragment(
              "ST_Distance_Sphere(?, ST_SetSRID(ST_MakePoint(?,?), ?))",
              model.point,
              ^lng,
              ^lat,
              ^point.srid
            )
      }
    )
  end

  def build_point(lng, lat), do: %Geo.Point{coordinates: {lng, lat}, srid: 4326}
end
