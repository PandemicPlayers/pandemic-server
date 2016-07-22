defmodule Pandemic.PageController do
  use Pandemic.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
