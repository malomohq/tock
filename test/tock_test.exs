defmodule TockTest do
  use ExUnit.Case
  doctest Tock

  test "greets the world" do
    assert Tock.hello() == :world
  end
end
