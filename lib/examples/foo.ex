defmodule Foo do
  @moduledoc """
  A simple comparable implementation to test with.
  """

  defstruct int: 0

  import Comparable
  defcomparison(Bar, Foo) do
    def compare(%Bar{num: num}, %Foo{int: int}) when num < int do
      -1
    end

    def compare(%Bar{num: num}, %Foo{int: int}) when num == int do
      0
    end

    def compare(%Bar{}, %Foo{}) do
      1
    end
  end

  defcomparison(Foo, Foo) do
    def compare(%Foo{int: int1}, %Foo{int: int2}) when int1 < int2, do: -1
    def compare(%Foo{int: int1}, %Foo{int: int2}) when int1 > int2, do: 1
    def compare(%Foo{int: _int1}, %Foo{int: _int2}), do: 0
  end
end