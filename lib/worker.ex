defmodule MyBehavior.Worker do

  alias MyBehavior.MyGenServer
  # @behaviour MyGenServer

  @spec start_link(any) :: {:ok, pid}
  def start_link(index) do
    MyGenServer.start_link(__MODULE__, :ok, name: :"w#{index}")
  end

  @spec increase(any, any) :: any
  def increase(index, val) do
    MyGenServer.cast(:"w#{index}", {"increase", val})
  end

  @spec decrease(any, any) :: any
  def decrease(index, val) do
    MyGenServer.cast(:"w#{index}", {"decrease", val})
  end

  @spec show(any):: any
  def show(index) do
    MyGenServer.call(:"w#{index}", "show")
  end

  @spec done(any, any) :: any
  def done(index, reason \\ :normal) do
    MyGenServer.stop(:"w#{index}", reason)
  end

  @spec init(:ok) :: {:ok, any}
  def init(:ok) do
    Process.send_after(self(), "hello self", 1000)
    {:ok, 0}
  end

  @spec handle_cast({any, any}, any) :: {:noreply, number}
  def handle_cast({"increase", val}, state) do
    state = state + val
    {:noreply, state}
  end

  def handle_cast({"decrease", val}, state) do
    state = state - val
    {:noreply, state}
  end

  @spec handle_call(any, any, any) :: {:reply, any, any}
  def handle_call("show", _from, state) do
    {:reply, state, state}
  end

  @spec handle_info(any, any) :: {:noreply, any}
  def handle_info("hello self", state) do
    IO.puts("a wild handle info")
    {:noreply, state}
  end

  @spec terminate(any, any) :: :ok
  def terminate(reason, _state) do
    IO.puts("terminating mygenserver due to  #{reason}")
  end
end
