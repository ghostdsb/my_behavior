defmodule MyGenServerTest do
  use ExUnit.Case
  doctest MyBehavior
  alias MyBehavior.MyGenServer
  alias MyBehavior.Worker

  test "init" do
    {:ok, pid} = Worker.start_link(0)
    assert is_pid(pid)
    assert Worker.show(0) === 0
    Process.unregister(:w0)
  end

  test "cast" do
    {:ok, _pid} = Worker.start_link(0)
    Worker.increase(0, 3)

    assert Worker.show(0) === 3
    Process.unregister(:w0)
  end

  test "call" do
    {:ok, _pid} = Worker.start_link(0)
    Worker.increase(0, 3)
    Worker.increase(0, 3)
    Worker.decrease(0, 1)
    val = Worker.show(0)

    assert val === 5
    Process.unregister(:w0)
  end

  test "stop" do
    {:ok, pid} = Worker.start_link(0)
    Process.monitor(pid)
    Worker.done(0)

    assert Process.alive?(pid) === true
    assert_receive({:DOWN, _, _, _, :normal})
    assert Process.alive?(pid) === false
  end
end
