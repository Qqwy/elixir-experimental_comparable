defmodule Bar do
  defstruct num: 1

  import Comparable

  defcomparable_for Bar, Integer do
    def compare(%Bar{num: num}, int) when num < int, do: -1
    def compare(%Bar{num: num}, int) when num > int, do:  1
    def compare(%Bar{}, int)                       , do:  0
  end
end