defmodule TertiaWeb.Router do
  require Tertia.Utils.Env
  use TertiaWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug
    # authenticating users
    plug TertiaWeb.Context
  end

  scope "/" do
    pipe_through :api

    forward "/api", Absinthe.Plug, schema: TertiaWeb.Schema
  end

  get "/confirm_signup", TertiaWeb.SignupController, :signup
end
