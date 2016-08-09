defmodule ComparableTest do
  use ExUnit.Case
  doctest Comparable

  test "the truth" do
    assert 1 + 1 == 2
  end
end


f = %Foo{int: 1}
b = %Bar{number: 2}