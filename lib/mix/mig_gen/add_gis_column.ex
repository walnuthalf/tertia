defmodule Mix.Tasks.MigGen.AddGisColumn do
  use Mix.Task

  @shortdoc "Generate migration file for a GIS column"
  def run([table_name, gis_column_name]) do
    contents = """
    defmodule Tertia.Repo.Migrations.Add#{Macro.camelize(gis_column_name)}To#{
      Macro.camelize(table_name)
    } do
      use Ecto.Migration

      @disable_ddl_transaction true

      def up do
        # Add a field `point` with type `geometry(Point,4326)`.
        # This can store a "standard GPS" (epsg4326) coordinate pair {longitude,latitude}.
        # 4326 is srid
        # 2 is dimension
        execute(
          "SELECT AddGeometryColumn ('#{table_name}','#{gis_column_name}',4326,'POINT',2)"
        )
        execute(
          "CREATE INDEX CONCURRENTLY #{table_name}_#{gis_column_name}_index on #{table_name} USING gist (#{
      gis_column_name
    })")
      end

      def down do
        execute("DROP INDEX #{table_name}_#{gis_column_name}_index")
        execute("SELECT DropGeometryColumn ('#{table_name}','#{gis_column_name}')")
      end
    end
    """

    Tertia.Utils.MigrationUtils.create_file("add_#{gis_column_name}_to_#{table_name}", contents)
  end
end
