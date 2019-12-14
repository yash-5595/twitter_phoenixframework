defmodule Twittersimulator.Repo do
  use Ecto.Repo,
    otp_app: :twittersimulator,
    adapter: Ecto.Adapters.Postgres
end
