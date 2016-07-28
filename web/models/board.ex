defmodule Pandemic.Board do

  def start_link do
    Agent.start_link(fn -> %{
      board: %{
        state: "not_started",
        cities: Pandemic.City.generate_cities,
        players: %{},
        current_turn: %{
          player_index: 0,
          player_id: "",
          actions_left: 1
        },
        player_cards_left: 10,
        infection_cards_left: 10,
        infection_rate: 2,
        outbreak_count: 0,
        discarded_player_cards: [],
        discarded_infection_cards: []
      }
    } end, name: __MODULE__)
  end

  def state do
    current_state = Agent.get(my_pid, &(&1))
    cities = for {k, v} <- current_state[:board][:cities], into: %{}, do: {k, Pandemic.City.state(k)}
    players = for {k, v} <- current_state[:board][:players], into: %{}, do: {k, Pandemic.Player.state(k)}
    current_state = put_in(current_state, [:board, :cities], cities)
    Map.update(current_state, :board, %{}, &(%{&1 |
       cities: cities,
       players: players
    }))
  end

  def add_player(nickname) do
    check_game_not_started
    Agent.update(my_pid, &(put_in(&1, [:board, :players, nickname],
       Pandemic.Player.start_link(nickname, "atlanta")
    )))
  end

  def start_game do
    check_player_count
    check_game_not_started
    player_list = Map.keys(state[:board][:players])
    Agent.update(my_pid, &(put_in(&1, [:board, :player_list], player_list)))
    decrement_actions
    Agent.update(my_pid, &(put_in(&1, [:board, :state], "playing")))
  end

  def move_player(nickname, city) do
    check_game_started
    check_current_player(nickname)
    Pandemic.Player.move(nickname, city)
    decrement_actions
  end

  def treat(nickname) do
    check_game_started
    check_current_player(nickname)
    Pandemic.City.treat(state[:board][:players][nickname][:current_city])
    decrement_actions
  end

  def decrement_actions do
    current_actions = state[:board][:current_turn][:actions_left]
    Agent.update(my_pid, &(put_in(&1, [:board, :current_turn, :actions_left], current_actions-1)))
    if state[:board][:current_turn][:actions_left] <= 0 do
      player_index = state[:board][:current_turn][:player_index] + 1
      player_index = rem(player_index, Enum.count(state[:board][:player_list]))
      next_player = Enum.at(state[:board][:player_list], player_index)
      Agent.update(my_pid, &(put_in(&1, [:board, :current_turn, :actions_left], 4)))
      Agent.update(my_pid, &(put_in(&1, [:board, :current_turn, :player_id], next_player)))
      Agent.update(my_pid, &(put_in(&1, [:board, :current_turn, :player_index], player_index)))
    end
  end

  def check_current_player(nickname) do
    if state[:board][:current_turn][:player_id] != nickname do
      raise "Not current player"
    end
  end

  def check_player_count do
    if (Enum.count(Map.keys(state[:board][:players])) < 2) do
      raise "Not enough players"
    end
    if (Enum.count(Map.keys(state[:board][:players])) < 4) do
      raise "Too many players"
    end
  end

  def check_game_not_started do
    if (state[:board][:state] != "not_started") do
      raise "Game Started"
    end
  end

  def check_game_started do
    if (state[:board][:state] == "not_started") do
      raise "Not Started"
    end
  end

  def has_player?(nickname) do
    Map.has_key?(state[:board][:players], nickname)
  end

  def my_pid do
    Process.whereis(__MODULE__)
  end

  def update_cities do
    Agent.update(my_pid, &(put_in(&1, [:board, :cities], Pandemic.City.generate_cities)))
  end
end
