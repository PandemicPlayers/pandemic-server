defmodule Pandemic.Board do

  def start_link do
    Agent.start_link(fn -> %{
      board: %{
        state: "not_started",
        cities: cities,
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
    Agent.get(my_pid, &(&1))
  end

  def add_player(nickname) do
    check_game_not_started
    Agent.update(my_pid, &(put_in(&1, [:board, :players, nickname], %{current_city: "new_york"})))
  end

  def start_game do
    check_player_count
    check_game_not_started
    Agent.update(my_pid, &(put_in(&1, [:board, :state], "playing")))
    player_list = Map.keys(state[:board][:players])
    Agent.update(my_pid, &(put_in(&1, [:board, :player_list], player_list)))
    decrement_actions
  end

  def move_player(nickname, city) do
    check_game_started
    check_current_player(nickname)
    cur_state = state
    if !Enum.member?(cur_state[:board][:cities][cur_state[:board][:players][nickname][:current_city]][:connections], city) do
      raise "Movement Error"
    end
    Agent.update(my_pid, &(put_in(&1, [:board, :players, nickname, :current_city], city)))
    decrement_actions
  end

  def treat(nickname) do
    check_game_started
    check_current_player(nickname)
    current_city = state[:board][:players][nickname][:current_city]
    check_cubes_on_city(current_city)
    infection_count = state[:board][:cities][current_city][:infection_count]
    Agent.update(my_pid, &(put_in(&1, [:board, :cities, current_city, :infection_count], infection_count - 1)))
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

  def check_game_started do
    if (state[:board][:state] == "not_started") do
      raise "Not Started"
    end
  end

  def check_player_count do
    if (Enum.count(Map.keys(state[:board][:players])) < 2) do
      raise "Not enough players"
    end
  end

  def check_game_not_started do
    if (state[:board][:state] != "not_started") do
      raise "Game Started"
    end
  end

  def check_cubes_on_city(city) do
    if state[:board][:cities][city][:infection_count] < 1 do
      raise "No infections in city"
    end
  end

  def has_player?(nickname) do
    Map.has_key?(state[:board][:players], nickname)
  end

  def my_pid do
    Process.whereis(__MODULE__)
  end

  def update_cities do
    Agent.update(my_pid, &(put_in(&1, [:board, :cities], cities)))
  end

  def cities do
    %{
      "new_york" => %{
        color: "blue",
        infection_count: 3,
        connections: ["montreal", "washington", "london", "madrid"]
      },
      "london" => %{
        color: "blue",
        infection_count: 3,
        connections: ["new_york", "essen", "paris", "madrid"]
      },
      "montreal" => %{
        color: "blue",
        infection_count: 3,
        connections: ["new_york", "washington", "chicago"]
      },
      "washington" => %{
        color: "blue",
        infection_count: 3,
        connections: ["atlanta", "montreal", "new_york", "miami"]
      },
      "paris" => %{
        color: "blue",
        infection_count: 3,
        connections: ["london", "essen", "milan", "algiers", "madrid"]
      },
      "milan" => %{
        color: "blue",
        infection_count: 3,
        connections: ["paris", "essen", "istanbul"]
      },
      "atlanta" => %{
        color: "blue",
        infection_count: 3,
        connections: ["chicago", "montreal", "washington", "miami"]
      },
      "chicago" => %{
        color: "blue",
        infection_count: 3,
        connections: ["san_francisco", "los_angles", "mexico_city", "atlanta", "montreal"]
      },
      "san_francisco" => %{
        color: "blue",
        infection_count: 3,
        connections: ["tokyo", "manila", "chicago", "los_angles"]
      },
      "essen" => %{
        color: "blue",
        infection_count: 3,
        connections: ["london", "paris", "milan", "st_petersburg"]
      },
      "st_petersburg" => %{
        color: "blue",
        infection_count: 3,
        connections: ["essen", "istanbul", "moscow"]
      },
      "madrid" => %{
        color: "blue",
        infection_count: 3,
        connections: ["new_york", "london", "paris", "sao_paulo"]
      },
      "miami" => %{
        color: "yellow",
        infection_count: 3,
        connections: ["atlanta", "washington", "mexico_city", "bogota"]
      }
    }
  end
end
