defmodule TockTest do
  use ExUnit.Case, async: true

  describe "expect/5" do
    test "allows a call to be invoked n times" do
      times = 2

      TaskSupervisor
      |> Tock.start()
      |> Tock.expect(RemoteMod, :add, times, fn(x, y) -> x + y end)

      for _n <- 1..times do
        assert { TaskSupervisor, node() }
                |> Task.Supervisor.async(RemoteMod, :add, [2, 3])
                |> Task.await() == 5
      end
    end

    test "allows the definition of multiple different calls" do
      TaskSupervisor
      |> Tock.start()
      |> Tock.expect(RemoteMod, :add, fn(x, y) -> x + y end)
      |> Tock.expect(RemoteMod, :add, fn(x, y) -> x * y end)

      assert { TaskSupervisor, node() }
              |> Task.Supervisor.async(RemoteMod, :add, [2, 3])
              |> Task.await() == 5

      assert { TaskSupervisor, node() }
              |> Task.Supervisor.async(RemoteMod, :add, [2, 3])
              |> Task.await() == 6
    end
  end

  describe "stub/4" do
    test "allows a call to be invoked an arbitrary number of times" do
      TaskSupervisor
      |> Tock.start()
      |> Tock.stub(RemoteMod, :add, fn(x, y) -> x + y end)

      times = :rand.uniform(10)

      for _n <- 1..times do
        assert { TaskSupervisor, node() }
               |> Task.Supervisor.async(RemoteMod, :add, [2, 3])
               |> Task.await() == 5
      end
    end

    test "replaces previously defined stubs when stubbed multiple times" do
      TaskSupervisor
      |> Tock.start()
      |> Tock.stub(RemoteMod, :add, fn(x, y) -> x + y end)
      |> Tock.stub(RemoteMod, :add, fn(x, y) -> x * y end)

      assert { TaskSupervisor, node() }
             |> Task.Supervisor.async(RemoteMod, :add, [2, 3])
             |> Task.await() == 6
    end

    test "is called after all expectations are fulfilled" do
      TaskSupervisor
      |> Tock.start()
      |> Tock.expect(RemoteMod, :add, fn(x, y) -> x + y end)
      |> Tock.expect(RemoteMod, :add, fn(x, y) -> x * y end)
      |> Tock.stub(RemoteMod, :add, fn(x, y) -> x - y end)

      assert { TaskSupervisor, node() }
              |> Task.Supervisor.async(RemoteMod, :add, [2, 3])
              |> Task.await() == 5

      assert { TaskSupervisor, node() }
              |> Task.Supervisor.async(RemoteMod, :add, [2, 3])
              |> Task.await() == 6

      assert { TaskSupervisor, node() }
              |> Task.Supervisor.async(RemoteMod, :add, [2, 3])
              |> Task.await() == -1

      assert { TaskSupervisor, node() }
              |> Task.Supervisor.async(RemoteMod, :add, [2, 3])
              |> Task.await() == -1
    end
  end
end
