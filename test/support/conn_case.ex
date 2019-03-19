defmodule TertiaWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias TertiaWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint TertiaWeb.Endpoint

      # Absinthe stuff
      @api_path "api"
      alias TertiaWeb.AbsintheHelpers

      def run_graphql(context, query, type, opts) do
        conn =
          if Keyword.get(opts, :authenticated, true) do
            context.authed_conn
          else
            context.conn
          end

        post(conn, @api_path, AbsintheHelpers.skeleton(query, type, opts))
      end

      def response_data(res, query_name), do: json_response(res, 200)["data"][query_name]

      def response_error_message(res),
        do: json_response(res, 200)["errors"] |> List.first() |> Map.get("message")

      def get_mailbox(), do: get_mailbox([])

      def get_mailbox(list) do
        receive do
          {:sandbox, data} -> data
          _ -> :skip
        after
          0 -> :done
        end
        |> case do
          :done -> list
          :skip -> get_mailbox(list)
          msg -> get_mailbox(list ++ [msg])
        end
      end
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Tertia.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Tertia.Repo, {:shared, self()})
    end

    %{user: %{token: token} = user} = Tertia.Utils.RecordCreator.create([:user])

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/json")

    authed_conn = Plug.Conn.put_req_header(conn, "authorization", "Bearer #{token}")

    {:ok, %{conn: conn, authed_conn: authed_conn, user: user}}
  end
end
