defmodule Tertia.UserResolverTest do
  use TertiaWeb.ConnCase, async: true
  @longitude 12.1
  @latitude 42.42

  @profile_query """
  {
    myProfile {
      id
    }
  }
  """

  @location_mutation """
    mutation UpdateLocation {
      updateLocation(location: {longitude: "#{@longitude}", latitude: "#{@latitude}"})
    }
  """

  describe "UserResolver" do
    test "my profile, authenticated", context do
      res =
        run_graphql(context, @profile_query, :query, query_name: "myProfile")
        |> response_data("myProfile")

      assert res["id"] == context.user.id
    end

    test "my profile, not authenticated", context do
      error_message =
        run_graphql(context, @profile_query, :query, query_name: "myProfile", authenticated: false)
        |> response_error_message()

      assert error_message == "not logged in"
    end

    test "update location", context do
      assert run_graphql(context, @location_mutation, :mutation, authenticated: true)
             |> response_data("updateLocation")

      assert %{location: %{coordinates: {@longitude, @latitude}}} = Tertia.Repo.one(Tertia.User)
    end
  end
end
