defmodule TertiaWeb.AbsintheHelpers do
  def skeleton(query, type, opts) do
    query =
      case type do
        :query -> "query #{Keyword.get(opts, :query_name)} #{query}"
        :param_query -> query
        :mutation -> query
      end

    %{
      "operationName" => Keyword.get(opts, :query_name, ""),
      "query" => query,
      "variables" => Keyword.get(opts, :variables, %{}) |> Jason.encode!()
    }
  end
end
