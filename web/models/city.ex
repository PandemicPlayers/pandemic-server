defmodule Pandemic.City do
  def start_link(city_name, city_data) do
    Agent.start_link(fn -> %{
      city_name: city_name,
      infection_count: 0,
      connections: city_data["connections"],
      color: city_data["color"]
    } end, name: String.to_atom(city_name))
  end

  def state(city_name) do
    Agent.get(city_process(city_name), &(&1))
  end

  def treat(city_name) do
    check_cubes_on_city(state(city_name)[:infection_count])
    Agent.update(city_process(city_name), fn city_data ->
      Map.update(city_data, :infection_count, 0, &(&1 - 1))
    end)
  end

  def city_process(city_name) do
    Process.whereis(String.to_atom(city_name))
  end

  def check_cubes_on_city(cube_count) do
    if cube_count <= 0 do
      raise "Nothing to treat"
    end
  end

  def connections(city_name) do
    state[:connections]
  end

  def generate_cities do
    path = File.cwd! |> Path.join("config/pieces.yml")
    cities = YamlElixir.read_from_file(path)["cities"]
    for {k, v} <- cities, into: %{}, do: {k, start_link(k, v)}
  end
end
