defmodule Tertia.Utils.RecordCreator do
  alias Tertia.SampleValues
  alias Tertia.Repo
  @project_prefix "Elixir.Tertia."

  def create(list), do: create(%{}, list)

  def create(acc, []), do: acc

  def create(acc, list) do
    case hd(list) do
      opts when is_map(opts) -> insert_record(acc, opts)
      record_type when is_atom(record_type) -> insert_record(acc, %{record_type: record_type})
    end
    |> create(tl(list))
  end

  def insert_record(acc, %{record_type: record_type} = opts) do
    assoc_list = Map.get(opts, :assocs, [])
    values = Map.get(opts, :values, %{})
    acc_key = Map.get(opts, :as, record_type)

    sample =
      apply(SampleValues, record_type, [])
      |> add_assocs(acc, assoc_list)
      |> Map.merge(values)

    record = record_module(record_type) |> apply(:changeset, [sample]) |> Repo.insert!()
    Map.put(acc, acc_key, record)
  end

  def add_assocs(sample, _acc, []), do: sample

  def add_assocs(sample, acc, assoc_list) do
    case hd(assoc_list) do
      %{acc_key: acc_key, field_name: field_name} ->
        put_id(sample, field_name, acc, acc_key)

      record_type ->
        put_id(sample, record_type, acc, record_type)
    end
    |> add_assocs(acc, tl(assoc_list))
  end

  def put_id(sample, field_name, acc, acc_key) do
    Map.put(sample, add_id_to_atom(field_name), Map.get(acc, acc_key).id)
  end

  def record_module(record_type) do
    (@project_prefix <> (to_string(record_type) |> Macro.camelize()))
    |> String.to_existing_atom()
  end

  def add_id_to_atom(name), do: (to_string(name) <> "_id") |> String.to_atom()
end
