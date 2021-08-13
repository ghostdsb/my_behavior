defmodule MyBehavior.MyGenServer do

  # @callback init(arg :: any()) :: {:ok, state :: any()}
  # @callback handle_call(request :: any(), from :: pid(), state :: any()) :: {:reply, response :: any(), state :: any()}
  # @callback handle_cast(request :: any(), state :: any()) :: {:noreply, state :: any()}
  # @callback handle_info(request :: any(), state :: any()) :: {:noreply, state :: any()}
  # @callback terminate(reason :: any(), state :: any()) :: :ok

  # MyGenServer APIs
  def start_link(mod, a, opts) do
    name = Keyword.get(opts, :name)
    pid = spawn(__MODULE__, :server_init, [mod,a])
    Process.register(pid, name)
    {:ok, pid}
  end

  def call(name, request) do
    server_pid = Process.whereis(name)
    send(server_pid, {:call, self(), request})

    receive do
      {:response, response} -> response
    end

  end

  def cast(name, request) do
    server_pid = Process.whereis(name)
    send(server_pid, {:cast, request})
  end

  def stop(name, reason \\ :normal) do
    server_pid = Process.whereis(name)
    send(server_pid, {:stop, reason})
  end

  # Server APIs
  def server_init(mod,a) do
    {:ok, state} = mod.init(a)
    loop(mod, state)
  end

  # Process loop
  defp loop(mod, state) do
    receive do
      {:call, from, request} ->
        {:reply, response, state} = mod.handle_call(request, from, state)
        send(from, {:response, response})
        loop(mod, state)

      {:cast, request} ->
        {:noreply, state} = mod.handle_cast(request, state)
        loop(mod, state)

      {:stop, reason} ->
        mod.terminate(reason, state)
        exit(reason)

      request ->
        {:noreply, state} = mod.handle_info(request, state)
        loop(mod, state)
    end


  end

end
