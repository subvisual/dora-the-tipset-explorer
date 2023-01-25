defmodule DoraTest do
  use ExUnit.Case
  doctest Dora

  test "greets the world" do
    assert Dora.hello() == :world
  end
end
