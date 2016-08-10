defmodule Bar do
  @moduledoc """
  Another simple struct to compare with.
  """

  defstruct num: 1

  import Comparable

  defcomparison(Bar, Integer) do
    def compare(%Bar{num: num}, int) when num < int, do: -1
    def compare(%Bar{num: num}, int) when num > int, do:  1
    def compare(%Bar{}, _int)                      , do:  0
  end
end