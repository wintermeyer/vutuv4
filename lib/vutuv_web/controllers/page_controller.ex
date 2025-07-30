defmodule VutuvWeb.PageController do
  use VutuvWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
