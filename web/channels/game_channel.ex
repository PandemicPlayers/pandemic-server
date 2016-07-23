defmodule Pandemic.GameChannel do
  use Phoenix.Channel
  require Logger

  def join("game", message, socket) do
    {:ok, socket}
  end

  def handle_in("ping", msg, socket) do
    {:reply, {:ok, %{msg: "pong"}}, socket}
  end

  def handle_in("game:action", %{"type" => "connect", "nickname" => nickname}, socket) do
    if !Pandemic.Board.has_player?(nickname) do
      Pandemic.Board.add_player(nickname)
    end
    broadcast! socket, "game:state_change", Pandemic.Board.state
    {:reply, {:ok, %{
       success: true
     }}, socket}
  end

  def handle_in("game:action", %{"type" => "start"}, socket) do
    Pandemic.Board.start_game
    broadcast! socket, "game:state_change", Pandemic.Board.state
    {:reply, {:ok, %{
       success: true
     }}, socket}
  end

  def handle_in("game:action", %{"nickname" => nickname, "type" => "move", "city" => city}, socket) do
    try do
      Pandemic.Board.move_player(nickname, city)
      broadcast! socket, "game:state_change", Pandemic.Board.state
      IO.puts "MOVED: " <> nickname <> " TO: " <> city
      {:reply, {:ok, %{ success: true }}, socket}
    rescue
      e in RuntimeError -> {:reply, {:error, %{ success: false, error: e.message }}, socket}
    end
  end

  def handle_in("game:action", %{"nickname" => nickname, "type" => "treat"}, socket) do
    try do
      Pandemic.Board.treat(nickname)
      broadcast! socket, "game:state_change", Pandemic.Board.state
      IO.puts "TREAT: " <> nickname
      {:reply, {:ok, %{ success: true }}, socket}
    rescue
      e in RuntimeError -> {:reply, {:error, %{ success: false, error: e.message }}, socket}
    end
  end

  def handle_in("game:state", msg, socket) do
    {:reply, {:ok, Pandemic.Board.state}, socket}
  end
end
