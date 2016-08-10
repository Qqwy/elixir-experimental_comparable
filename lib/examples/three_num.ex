defmodule ThreeNum do
  @moduledoc """
  Contains a defcomparison implementation which
  combines the results of three simpler comparisons,
  to show how this could be done.
  """

  defstruct x: 0, y: 0, z: 0

  import Comparable

  def new(x,y,z) do
    %ThreeNum{x: x, y: y, z: z}
  end
  
  defcomparison(ThreeNum, ThreeNum) do
    def compare(a = %ThreeNum{}, b = %ThreeNum{}) do
      with  0 <- Comparable.compare(a.x, b.x),
            0 <- Comparable.compare(a.y, b.y),
        do:      Comparable.compare(a.z, b.z)
    end
  end
end