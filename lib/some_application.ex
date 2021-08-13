defmodule MyBehavior.SomeApplication do

  alias MyBehavior.MySupervisor
  alias MyBehavior.Worker

  @spec start(any, any) :: {:ok, pid}
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
