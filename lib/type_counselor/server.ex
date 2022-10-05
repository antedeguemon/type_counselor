defmodule TypeCounselor.Server do
  use GenServer

  # Client

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def derive(name) do
    GenServer.call(__MODULE__, {:derive, name})
  end

  def add(name, struct) do
    GenServer.cast(__MODULE__, {:add, name, struct})
    struct
  end

  # Callbacks

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call({:derive, name}, _from, state) do
    suggestion =
      state
      |> Enum.filter(fn {key, _value} -> key == name end)
      |> Enum.map(fn {_key, struct} -> struct end)
      |> TypeCounselor.suggest()

    {:reply, suggestion, state}
  end

  @impl true
  def handle_cast({:add, name, struct}, state) do
    {:noreply, [{name, struct} | state]}
  end
end
