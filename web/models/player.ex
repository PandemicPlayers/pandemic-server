defmodule Pandemic.Player do
  def start_link(nickname, starting_city) do
    Agent.start_link(fn -> %{
      nickname: nickname,
      cards: [],
      role: "",
      current_city: starting_city,
    } end, name: String.to_atom(nickname))
  end

  def move(nickname, city) do
    check_moveable_city(
      city,
      Pandemic.City.connections(state(nickname)[:current_city])
    )
    #state[:cards]
    Agent.update(player_process(nickname), &(Map.put(&1, :current_city, city)))
  end

  def state(nickname) do
    Agent.get(player_process(nickname), &(&1))
  end

  def player_process(nickname) do
    Process.whereis(String.to_atom(nickname))
  end

  def check_moveable_city(city_to_move_to, connections) do
    if !Enum.member?(connections, city_to_move_to) do
      raise "Can not move to city " <> city_to_move_to
    end
  end
end
