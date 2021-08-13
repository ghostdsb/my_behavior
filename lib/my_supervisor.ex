defmodule MyBehavior.MySupervisor do

  # use MyGenServer
  alias MyBehavior.MyGenServer

  #######################
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(child_spec) do
    MyGenServer.start_link(__MODULE__, child_spec, name: __MODULE__)
  end

  def which_children() do
    MyGenServer.call(__MODULE__, "which_children")
  end

  #######################
  @spec init(any) :: {:ok, %{}}
  def init(child_spec) do
    Process.flag(:trap_exit, true)
    children =
      child_spec
      |> start_children()
      |> Map.new()
      |> IO.inspect()
    {:ok, children}
  end

  def handle_call("which_children", _from, state) do
    {:reply, state, state}
  end

  def handle_info({:EXIT, pid, :normal}, state) do
    state = Map.delete(state, pid)
    {:noreply, state}
  end
  def handle_info({:EXIT, pid, :killed}, state) do
    state = Map.delete(state, pid)
    {:noreply, state}
  end
  def handle_info({:EXIT, pid, reason}, state) do
    IO.puts("terminating #{inspect pid} due to #{inspect reason}")
    child_spec = Map.get(state, pid)
    state = Map.delete(state, pid)
    state =
      case start_child(child_spec) do
        {pid, child_spec} -> Map.put(state, pid, child_spec)
        :error -> state
      end
    {:noreply, state}
  end

  ######################
  defp start_children(child_spec) do
    child_spec
    |> Enum.map(fn child -> child |> start_child() end)
  end

  defp start_child({m,f,a}) do
    case apply(m,f,a) do
      {:ok, pid} when is_pid(pid) ->
        Process.link(pid)
        {pid, {m,f,a}}
      _ -> :error
    end
  end

end
