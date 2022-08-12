defmodule FormulaBuilder.Receiver do
  use GenServer

  defstruct func: nil, map: %{}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get_value do
    GenServer.call(__MODULE__, :get_value)
  end

  def update_value(key, value) do
    GenServer.call(__MODULE__, {:update_value, key, value})
  end

  def update_values(new_values) do
    GenServer.call(__MODULE__, {:update_values, new_values})
  end

  @impl true
  def init([formula_string, init_map]) do
    func = FormulaBuilder.build_formula(formula_string)
    {:ok, %__MODULE__{func: func, map: init_map}}
  end

  @impl true
  def handle_call(:get_value, _from, state) do
    {:reply, execute(state), state}
  end
  def handle_call({:update_value, key, value}, _from, state) do
    state = %__MODULE__{state | map: Map.put(state.map, key, value)}
    {:reply, execute(state), state}
  end
  def handle_call({:update_values, new_values}, _from, state) do
    state = %__MODULE__{state | map: Map.merge(state.map, new_values)}
    {:reply, execute(state), state}
  end

  defp execute(%__MODULE__{func: func, map: map}) do
    func.(map)
  end
end
