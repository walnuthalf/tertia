defmodule Mix.Tasks.MigGen.Table do
  use Mix.Task

  @shortdoc "Generate migration file for a new table"
  def run([table_name]) do
    contents = """
    defmodule Tertia.Repo.Migrations.Create#{Macro.camelize(table_name)} do
      use Ecto.Migration

      def change do
        create table(:#{table_name}, primary_key: false) do
          add(:id, :binary_id, primary_key: true)
          timestamps(type: :utc_datetime_usec)
        end
      end
    end
    """

    Tertia.Utils.MigrationUtils.create_file("create_#{table_name}", contents)
  end
end
