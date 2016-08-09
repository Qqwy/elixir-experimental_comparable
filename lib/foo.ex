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
    def compare(bar, foo) do
      bar.number - foo.int
    end
  end

  defcomparable_for Foo, Foo do
    def compare(foo1, foo2) do
      foo1.int - foo2.int
    end
  end
end