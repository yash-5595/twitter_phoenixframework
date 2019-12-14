defmodule TwittersimulatorWeb.PageController do
  use TwittersimulatorWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
