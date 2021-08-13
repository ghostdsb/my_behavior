defmodule MySupervisorTest do

  use ExUnit.Case
  alias MyBehavior.MySupervisor
  alias MyBehavior.Worker
  alias MyBehavior.SomeApplication

  test "test_supervisor" do

    chidren_count =
      MySupervisor.which_children()
      |> Enum.count()

    assert chidren_count === 4

    first_child_pid = MySupervisor.which_children() |> Map.keys() |> List.first()
    Process.monitor(first_child_pid)
    Worker.done(1)

    assert Process.alive?(first_child_pid) === true
    assert_receive({:DOWN, _, _, _, :normal})
    assert Process.alive?(first_child_pid) === false

    chidren_count =
      MySupervisor.which_children()
      |> Enum.count()

    assert chidren_count === 3

    new_first_child_pid = MySupervisor.which_children() |> Map.keys() |> List.first()
    Process.monitor(new_first_child_pid)
    reason = :whoops
    Worker.done(2, reason)

    assert Process.alive?(new_first_child_pid) === true
    assert_receive({:DOWN, _, _, _, ^reason}, 1000)
    assert Process.alive?(new_first_child_pid) === false

    chidren_count =
      MySupervisor.which_children()
      |> Enum.count()

    assert chidren_count === 3
  end
end
