defmodule Tertia.Repo do
  use Ecto.Repo,
    otp_app: :tertia,
    adapter: Ecto.Adapters.Postgres
end
