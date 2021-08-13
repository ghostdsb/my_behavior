# MyBehavior

Implementation of GenServer from scratch to study how it is built.

Used that GenServer to build a Supervisor to study how a supervisor works.

## Worker implementing MyGenserver

init

```elixir
  def start_link(index) do
    MyGenServer.start_link(__MODULE__, :ok, name: :"w#{index}")
  end

  def init(:ok) do
    Process.send_after(self(), "hello self", 1000)
    {:ok, 0}
  end

```
handle_info
```elixir
  def handle_info("hello self", state) do
    IO.puts("a wild handle info")
    {:noreply, state}
  end
```

handle_call

```elixir
  def show(index) do
    MyGenServer.call(:"w#{index}", "show")
  end

  def handle_call("show", _from, state) do
    {:reply, state, state}
  end
```
handle_cast

```elixir
  def increase(index, val) do
    MyGenServer.cast(:"w#{index}", {"increase", val})
  end
  
  def handle_cast({"increase", val}, state) do
    state = state + val
    {:noreply, state}
  end
```

## MySupervisor

```elixir
defmodule SomeApplication do
  def start(_,_) do
    children = [
      {Worker, :start_link, [1]},
      {Worker, :start_link, [2]},
      {Worker, :start_link, [3]},
      {Worker, :start_link, [4]}
    ]

    MySupervisor.start_link(children)
  end
end
```

```bash
> SomeApplication.start(:a, :b)
{:ok, #PID<0.200.0>}
```

Supervisor.which_children/0
```bash
> MySupervisor.which_children
%{
  #PID<0.193.0> => {MyBehavior.Worker, :start_link, [1]},
  #PID<0.194.0> => {MyBehavior.Worker, :start_link, [2]},
  #PID<0.195.0> => {MyBehavior.Worker, :start_link, [3]},
  #PID<0.196.0> => {MyBehavior.Worker, :start_link, [4]}
}
```

Normal child termination
```bash
> pid = MyBehavior.MySupervisor.which_children |> Map.keys |> List.first
> Worker.done(1, :normal)
iex(6)> MyBehavior.MySupervisor.which_children                                
%{
  #PID<0.194.0> => {MyBehavior.Worker, :start_link, [2]},
  #PID<0.195.0> => {MyBehavior.Worker, :start_link, [3]},
  #PID<0.196.0> => {MyBehavior.Worker, :start_link, [4]}
}
```

Termination due to other reason
```bash
pid = MyBehavior.MySupervisor.which_children |> Map.keys |> List.first
#PID<0.143.0>
iex(2)> MyBehavior.Worker.done(1, :whoops)
{:stop, :whoops}
terminating mygenserver due to  whoops
iex(3)> terminating #PID<0.143.0> due to :whoops
iex(3)> MyBehavior.MySupervisor.which_children                                
%{
  #PID<0.144.0> => {MyBehavior.Worker, :start_link, [2]},
  #PID<0.145.0> => {MyBehavior.Worker, :start_link, [3]},
  #PID<0.146.0> => {MyBehavior.Worker, :start_link, [4]},
  #PID<0.150.0> => {MyBehavior.Worker, :start_link, [1]}
}

```

