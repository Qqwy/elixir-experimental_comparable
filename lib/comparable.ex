defmodule Comparable do
  @moduledoc """
  Allows two values of possibly different kinds to be compared
  with each other.

  This specification has already been implemented for all built-in Elixir types, to:
  - allow comparisons between two builtin values of the same kind.
  - allow comparisons between integers and floats.

  To make your own structs comparable to one of the builtin types, or to each other,
  you can define `defcomparison/3` for the type-combination that is to be comparable.

  Because when you compare two elements `a` and `b`, the result is exactly the opposite 
  of the result of comparing them the other way around,
  only a single implementation of `defcomparison` is necessary.

  The choice has been made to always define these comparable implementations in alphabetic
  order; the type with the lowest alphabetic order is mentioned first.


  ## Example

  In this example, a module is made to represent roman numerals.
  We want to allow comparisons between normal integers and these roman numerals,
  so we define how this should happen using `defcomparison`.
  
      defmodule RomanNumeral do
        defstruct [:num]

        import Comparable
        
        defcomparison(Integer, RomanNumeral) do
          def compare(int, %RomanNumeral{num: num}) when num < int, do: -1
          def compare(int, %RomanNumeral{num: num}) when num > int, do:  1
          def compare(int, %RomanNumeral{})                       , do:  0
        end
      end

  Observe:

  - Integer is used as first type in the `defcomparison` statement, 
    as `Integer` is earlier than `RomanNumeral`, alphabetically speaking.
  - Inside the `defcomparison` implementation, we can define any (helper) functions we want; 
    the `compare/2` function is the one that needs to be defined in order for the comparison to work.

  We can now do:

      iex> num = %RomanNumeral{num: 3}
      iex> Comparable.compare(num, 1)
      1
      iex> Comparable.compare(num, 4)
      -1
      iex> Comparable.compare(num, 3)
      0

  For type-combinations for which there does not exist a `defcomparison` implementation, an Comparable.UncomparableError is raised:

      iex> Comparable.compare(num, "foo")
      ** (Comparable.UncomparableError) Could not compare `BitString` with `RomanNumeral`,
      because no proper `defcomparison BitString, RomanNumeral do ... end` could be found.
      
  """

  defmodule UncomparableError do
    defexception [:message]
    
    def exception([type_a, type_b]) do
      [first_type, second_type] = :lists.sort([type_a, type_b])
      msg = """
      Could not compare `#{inspect type_a}` with `#{inspect type_b}`,
      because no proper `defcomparison #{inspect first_type}, #{inspect second_type} do ... end` could be found.
      """
      %UncomparableError{message: msg}
    end
  end
  alias UncomparableError

  @doc """
  Compares one thing to another.

  Works for all type-combinations that have a `defcomparison` implementation.
  (See `defcomparison/3` for more details)

  Returns:
  - -1 if `a` is smaller than `b`
  -  0 if `a` and `b` are the same
  -  1 if `a` is larger than `b`.
  """
  @spec compare(any, any) :: :< | := | :>
  def compare(a, b)

  # Comparing two custom structs 
  def compare(a = %type_a{}, b = %type_b{}) when type_a <= type_b do
    impl_module!(type_a, type_b).compare(a, b)
  end

  # Comparing two custom structs in non-alphabetical order  
  def compare(a = %type_a{}, b = %type_b{}) do
    invert_comparison impl_module!(type_b, type_a).compare(b, a)
  end

  # Integers and Floats can be compared directly with eachother.
  def compare(a, b) when is_number(a) and is_number(b) and a < b, do: :<
  def compare(a, b) when is_number(a) and is_number(b) and a > b, do: :>
  def compare(a, b) when is_number(a) and is_number(b)          , do: :=

  # Other built-in types, when compared to something of the same type.
  builtin_types = 
    [
      is_tuple: Tuple,
      is_integer: Integer,
      is_float: Float,
      is_atom: Atom,
      is_list: List,
      is_map: Map,
      is_bitstring: BitString,
      is_function: Function,
      is_pid: PID,
      is_port: Port,
      is_reference: Reference
    ]

  for {guard, builtin_type} <- builtin_types do 

    def compare(a, b) when unquote(guard)(a) and unquote(guard)(b) and a < b, do: :<
    def compare(a, b) when unquote(guard)(a) and unquote(guard)(b) and a > b, do: :>
    def compare(a, b) when unquote(guard)(a) and unquote(guard)(b)          , do: :=

    def compare(a, b = %type_b{}) when unquote(guard)(a) and unquote(builtin_type) <= type_b do
      impl_module!(unquote(builtin_type), type_b).compare(a, b)
    end

    def compare(a, b = %type_b{}) when unquote(guard)(a) do
      invert_comparison impl_module!(type_b, unquote(builtin_type)).compare(b, a)
    end

    def compare(a = %type_a{}, b) when unquote(guard)(b) and unquote(builtin_type) <= type_a do
      impl_module!(unquote(builtin_type), type_a).compare(b, a) 
    end

    def compare(a = %type_a{}, b) when unquote(guard)(b) do
      invert_comparison impl_module!(type_a, unquote(builtin_type)).compare(a, b)
    end
  end

  # Inverts a comparison, so less-than becomes greater-than and vice-versa.
  defp invert_comparison(:<), do: :>
  defp invert_comparison(:=), do: :=
  defp invert_comparison(:>), do: :<

  @doc """
  True if `a` is strictly smaller than `b`, 

  when compared using the Comparable.compare implementation for (a, b).
  """
  @spec lt?(any, any) :: boolean
  def lt?(a, b), do: compare(a, b) == :<

  @doc """
  True if `a` is smaller than or equal to `b`, 

  when `a` and `b` are Comparable to each other.
  """
  @spec lte?(any, any) :: boolean
  def lte?(a, b), do: compare(a, b) in [:<, :=]

  @doc """
  True if `a` is strictly larger than `b`, 

  when `a` and `b` are Comparable to each other.
  """
  @spec gt?(any, any) :: boolean
  def gt?(a, b), do: compare(a, b) == :>

  @doc """
  True if `a` is larger than or equal to `b`, 

  when `a` and `b` are Comparable to each other.
  """
  @spec gte?(any, any) :: boolean
  def gte?(a, b), do: compare(a, b) in [:=, :>]

  @doc """
  True if `a` is equal to `b`, 

  when `a` and `b` are Comparable to each other.
  """
  @spec eq?(any, any) :: boolean
  def eq?(a, b), do: compare(a, b) == :=

  @doc """
  Sorts an Enumerable that only contains items that are comparable to each other.

  This function uses the Merge Sort algorithm.

  `Comparable.compare/2` is used to check the order of the items.
  """
  def sort(enumerable_of_comparable_items) do
    Enum.sort(enumerable_of_comparable_items, &(gt?(&1, &2)))
  end

  @doc """
  Defines an implementation for the given Comparables, `module_a` and `module_b`.

  The two types passed to `defcomparison/3` should be in alphabetical order; if this is not
  the case, an error will be raised at compile-time.

  The `type_a` and `type_b` can each be any atom representing a built-in Elixir type:
  
  - Tuple
  - Integer
  - Float
  - Atom
  - List
  - Map
  - BitString
  - Function
  - PID
  - Port
  - Range
  - Reference

  or the atom of any module in which a struct is defined.

  Note that, unlike Protocol implementations, it is not possible to derive implementations.

  `defcomparison/3` should be called with a block containing an implementation
  of the `compare(a, b)` function.

  This `compare(a, b)`-function will always be called with as first parameter a value of type `type_a`,
  and as second parameter a value of type `type_b`.

  Inside the implementation, you can refer to the name of the first type with `@comparable_type_a`
  and to the name of the second type with `@comparable_type_b`.
  """
  @spec defcomparison(atom, atom, [do: any]) :: any
  defmacro defcomparison(type_a, type_b, do_block)

  defmacro defcomparison(type_a, type_b, do: block) do

    quote generated: true do
      case {unquote(type_a), unquote(type_b)} do
        {type_a, type_b} when is_atom(type_a) and is_atom(type_b) and type_a <= type_b ->
  
          # The custom implementation is specified here.
          impl_name = Module.concat(type_a, type_b)
          impl_module = Module.concat(Comparable.ProtocolImpl, impl_name)
          defmodule impl_module do
            @moduledoc false
            unquote(block)
            @impl_name impl_name
            @comparable_type_a type_a
            @comparable_type_b type_b

            def __comparable__, do: @impl_name
          end

        {type_a, type_b} when is_atom(type_a) and is_atom(type_b) ->
          raise "defcomparison called with types in non-alphabetical order `#{inspect type_a}, #{inspect type_b}`! Use `defcomparison #{inspect type_b}, #{inspect type_a} do ... end ` instead."
        _ -> raise ArgumentError
      end
    end
  end

  defp impl_module!(type_a, type_b) do
    impl = impl_module(type_a, type_b)
    name = impl_name(type_a, type_b)

    case Code.ensure_compiled(impl) do
      {:module, ^impl} -> :ok
      _ -> raise UncomparableError, [type_a, type_b]
    end

    try do
      impl.__comparable__
    rescue
      UndefinedFunctionError ->
        raise UncomparableError, [type_a, type_b]
    else
      ^name ->
        :ok
      other ->
        raise ArgumentError,
          "expected #{inspect impl} to be a Comparable implementation of #{type_a}, #{type_b}, got: #{inspect other}"
    end
    impl
  end

  # Concatenated module name of special protocol implementation.
  defp impl_module(type_a, type_b) do
     Module.concat(Comparable.ProtocolImpl, impl_name(type_a, type_b))
  end

  # Concatenated module name of special protocol implementation.
  defp impl_name(type_a, type_b) do
    Module.concat(type_a, type_b)
  end


end
