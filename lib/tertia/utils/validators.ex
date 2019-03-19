defmodule Tertia.Utils.Validators do
  def validate_id(id) do
    case Ecto.UUID.cast(id) do
      :error -> {:error, "invalid id #{id}"}
      res -> res
    end
  end

  def validate_true(expr, error_message) do
    expr || {:error, error_message}
  end

  def validate_user(context) do
    case context do
      %{context: %{current_user: user}} ->
        {:ok, user}

      _ ->
        {:error, "not logged in"}
    end
  end
end
