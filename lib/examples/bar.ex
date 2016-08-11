defmodule Bar do
  @moduledoc """
  Another simple struct to compare with.
  """

  defstruct num: 1

  import Comparable

  defcomparison(Bar, Integer) do
    def compare(%Bar{num: num}, int) when num < int, do: :<
    def compare(%Bar{num: num}, int) when num > int, do: :>
    def compare(%Bar{}, _int)                      , do: :=
  end
end
