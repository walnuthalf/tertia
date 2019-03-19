defmodule Tertia.Utils.MigrationUtils do
  def gen_timestamp(), do: DateTime.utc_now() |> Timex.format!("{YYYY}{0M}{0D}{h24}{0m}{0s}")

  def create_file(name, contents) do
    Mix.Generator.create_file(
      "priv/repo/migrations/#{gen_timestamp()}_#{name}.exs",
      contents
    )
  end
end
