defmodule Mix.Tasks.MigGen.Postgis do
  use Mix.Task

  @shortdoc "Generate migration file for enabling PostGIS"
  def run(_) do
    contents = """
    defmodule Tertia.Repo.Migrations.EnablePostgis do
      use Ecto.Migration

      def up do
        execute("CREATE EXTENSION IF NOT EXISTS postgis")
      end

      def down do
        execute("DROP EXTENSION IF EXISTS postgis")
      end
    end
    """

    Tertia.Utils.MigrationUtils.create_file("enable_postgis", contents)
  end
end
