defmodule Foo do
  defstruct int: 0

  # defimpl Comparable.Protocol, for: Bar.Foo do
  #   def compare(_, bar, foo) do
  #     IO.inspect([bar, foo])
  #     bar.number - foo.int
  #   end
  # end
  import Comparable
  defcomparable_for Bar, Foo do
    def compare(%Bar{number: number}, %Foo{int: int}) when number < int do
      -1
    end

    def compare(%Bar{number: number}, %Foo{int: int}) when number == int do
      0
    end

    def compare(%Bar{number: number}, %Foo{int: int}) do
      1
    end
  end

  defcomparable_for Foo, Foo do
    def compare(%Foo{int: int1}, %Foo{int: int2}) when int1 < int2, do: -1
    def compare(%Foo{int: int1}, %Foo{int: int2}) when int1 > int2, do: 1
    def compare(%Foo{int: _int1}, %Foo{int: _int2}), do: 0
  end
end