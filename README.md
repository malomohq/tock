# Tock

Tock is a library for mocking remote function calls made by `Task.Supervisor`.

## Installation

Just add `tock` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    { :tock, "~> 1.0", only: :test }
  ]
end
```

## Usage

When working in a distributed system `Task.Supervisor` provides a mechanism
for calling functions on a remote node.

```elixir
{ MyRemoteTaskSupervisor, remote_node }
|> Task.Supervisor.async(MyRemoteModule, :add, [2, 3])
|> Task.await()
```

Tock allows you to easily mock a remote application. This eliminates the need to
mock your own code. Instead, mock the behavior of an application running on a
remote node.

```elixir
use ExUnit.Case, async: true

test "invokes add on a remote node" do
  MyRemoteTaskSupervisor
  |> Tock.start()
  |> Tock.expect(MyRemoteMod, :add, fn(x, y) -> x + y end)

  assert { MyRemoteTaskSupervisor, node() }
         |> Task.Supervisor.async(MyRemoteModule, :add, [2, 3])
         |> Task.await() == 5
end
```

All expectations are defined based on the current process. This allows
multiple tests to run concurrently when using the same named
`Task.Supervisor`.
