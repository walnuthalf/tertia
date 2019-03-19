defmodule Tertia.AuthResolverTest do
  use TertiaWeb.ConnCase, async: true
  alias Tertia.Repo
  alias Tertia.User

  @login_mutation """
    mutation LoginMutation($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        token
      }
    }
  """
  def run_login(context, email, password \\ Tertia.SampleValues.dummy_password()) do
    run_graphql(context, @login_mutation, :mutation,
      authenticated: false,
      variables: %{email: email, password: password}
    )
  end

  describe "AuthResolver" do
    test "login, right password", context do
      # remove the token
      User.changeset(%{token: nil}, context.user) |> Repo.update()
      res = run_login(context, context.user.email) |> response_data("login")
      %{token: token} = Repo.get(User, context.user.id)
      # assert that token was successfully created
      assert token != nil
      assert %{"token" => ^token} = res
      res2 = run_login(context, context.user.email) |> response_data("login")
      # same token on the second login
      assert %{"token" => ^token} = res2
    end

    test "login, wrong password", context do
      assert "Authentication failed" =
               run_login(context, context.user.email, "garbagepassword")
               |> response_error_message()

      assert "Authentication failed" =
               run_login(context, context.user.email, "verylongpasswordisverylongmorethan16chars")
               |> response_error_message()
    end
  end
end
