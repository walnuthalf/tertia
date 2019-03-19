defmodule Mix.Tasks.MigGen.ManyToMany do
  use Mix.Task

  @shortdoc "Generate migration file for a many to many association"
  def run([name1, name2]) do
    contents = """
    defmodule Tertia.Repo.Migrations.Create#{Macro.camelize(name1 <> "_" <> name2)}Assocs do
      use Ecto.Migration

      def change do
        create table(:#{name1}_#{name2}_assocs, primary_key: false) do
          add(:id, :binary_id, primary_key: true)
          add(:#{name1}_id, references("#{name1}s", type: :binary_id), null: false, on_delete: :delete_all)
          add(:#{name2}_id, references("#{name2}s", type: :binary_id), null: false, on_delete: :delete_all)
        end

        create unique_index("#{name1}_#{name2}_assocs", [:#{name1}_id, :#{name2}_id])
      end
    end
    """

    Tertia.Utils.MigrationUtils.create_file("create_#{name1}_#{name2}_assocs", contents)
  end
end
