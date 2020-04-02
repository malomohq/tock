defmodule Tock do
  @moduledoc """
  Tock is a library for mocking remote function calls made by `Task.Supervisor`.

  When working in a distributed system `Task.Supervisor` provides a mechanism
  for calling functions on a remote node.

      { MyRemoteTaskSupervisor, remote_node }
      |> Task.Supervisor.async(MyRemoteModule, :remote_fun, [])
      |> Task.await()

  Tock allows you to easily mock a remote application. This eliminates the need
  to mock your own code. Instead, mock the behavior of an application running on
  a remote node.

      use ExUnit.Case, async: true

      test "invokes add on a remote node" do
        MyRemoteTaskSupervisor
        |> Tock.start()
        |> Tock.expect(MyRemoteMod, :add, fn(x, y) -> x + y end)

        assert { MyRemoteTaskSupervisor, node() }
               |> Task.Supervisor.async(MyRemoteModule, :add, [2, 3])
               |> Task.await() == 5
      end

  All expectations are defined based on the current process. This allows
  multiple tests to run concurrently when using the same named
  `Task.Supervisor`.
  """

  @doc """
  Expects `fun` on `module` with an arity defined by `code` to be invoked `n`
  times.

  When `expect/5` is invoked, any previously declared stub for the same module,
  function and arity will be removed. This will ensure that a remote function
  called more than `n` times will timeout. If a `stub/4` is invoked after
  `expect/5` for the same `module`, `fun` and arity, the stub will be used after
  all expectations are fulfilled.

  ## Examples

  Expect `MyRemoteMod.add/2` to be called once:

      expect(MyRemoteTaskSupervisor, MyRemoteMod, :add, fn(x, y) -> x + y end)

  Expect `MyRemoteMod.add/2` to be called 5 times:

      expect(MyRemoteTaskSupervisor, MyRemoteMod, :add, 5, fn(x, y) -> x + y end)

  `expect/5` can also be invoked multiple times for the same `module`, `fun` and
  arity allowing you to define different results on each call:

      MyRemoteTaskSupervisor
      |> expect(MyRemoteMod, :add, fn(x, y) -> x + y end)
      |> expect(MyRemoteMod, :add, fn(x, y) -> x * y end)
  """
  @spec expect(atom | pid, module, atom, non_neg_integer, fun) :: pid
  def expect(tock, module, fun, n \\ 1, code) do
    signature = { module, fun, :erlang.fun_info(code)[:arity] }

    expects = { signature, List.duplicate({ :expect, code }, n) }

    Tock.Server.put_expectation(tock, expects)
  end

  @doc """
  Start a mock `Task.Supervisor`.
  """
  @spec start(atom) :: pid
  def start(name) do
    case Tock.Supervisor.start_server([name: name]) do
      { :ok, pid } ->
        Tock.Server.join(pid)
      { :error, { :already_started, pid } } ->
        Tock.Server.join(pid)
    end
  end

  @doc """
  Allows `fun` on `module` with an arity defined by `code` to be invoked zero or
  more times.

  If expectations and stubs are defined for the same `module`, `fun` and arity
  the stub is invoked after all expectations are fulfilled.

  ## Examples

  Allow `MyRemoteMod` to be invoked zero or more times:

      stub(MyRemoteTaskSupervisor, MyRemoteMod, :add, fn(x, y) -> x + y end)

  `stub/4` will overwrite any previous calls to `stub/4`.
  """
  @spec stub(atom | pid, module, atom, function) :: pid
  def stub(tock, module, fun, code) do
    signature = { module, fun, :erlang.fun_info(code)[:arity] }

    expects = { signature, [{ :stub, code }] }

    Tock.Server.put_expectation(tock, expects)
  end
end
