defmodule TertiaWeb.UserResolver do
  alias Tertia.Utils.Validators
  alias Tertia.UserCommands
  def my_profile(_, _, %{context: %{current_user: user}}), do: {:ok, user}
  def my_profile(_, _, _), do: {:error, "not logged in"}

  def update_location(_, %{location: location}, context) do
    with {:ok, user} <- Validators.validate_user(context),
         {:ok, _} <- UserCommands.update_location(user, location) do
      {:ok, true}
    end
  end
end
