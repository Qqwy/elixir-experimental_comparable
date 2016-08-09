defmodule Comparable do

  @doc """
  Compares one thing to another.

  Works for all type-combinations that have a `defcomparable_for` implementation.
  (See `defcomparable_for/3` for more details)

  Returns:
  - -1 if `a` is smaller than `b`
  -  0 if `a` and `b` are the same
  -  1 if `a` is larger than `b`.
  """
  @spec compare(any, any) :: -1 | 0 | 1
  def compare(a, b)

  # Everything is always equal to itself.
  def compare(a, a), do: 0

  # Comparing two custom structs 
  def compare(a = %type_a{}, b = %type_b{}) when type_a <= type_b do
    impl_module(type_a, type_b).compare(a, b)
  end

  # Comparing two custom structs in non-alphabetical order  
  def compare(a = %type_a{}, b = %type_b{}) do
    impl_module(type_b, type_a).compare(b, a) * -1
  end

  # Integers and Floats can be compared directly with eachother.
  def compare(a, b) when is_number(a) and is_number(b) and a < b, do: -1
  def compare(a, b) when is_number(a) and is_number(b) and a > b, do:  1
  def compare(a, b) when is_number(a) and is_number(b)          , do:  0

  # Other built-in types, when compared to something of the same type.
  builtin_types = 
    [
      is_tuple: Tuple,
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

    def compare(a, b) when unquote(guard)(a) and unquote(guard)(b) and a < b, do: -1
    def compare(a, b) when unquote(guard)(a) and unquote(guard)(b) and a > b, do:  1
    def compare(a, b) when unquote(guard)(a) and unquote(guard)(b)          , do:  0

    def compare(a, b = %type_b{}) when unquote(guard)(a) and unquote(builtin_type) <= type_b do
      impl_module(unquote(builtin_type), type_b).compare(a, b)
    end

    def compare(a, b = %type_b{}) when unquote(guard)(a) do
      impl_module(type_b, unquote(builtin_type)).compare(b, a) * -1
    end

    def compare(a = %type_a{}, b) when unquote(guard)(b) and unquote(builtin_type) <= type_a do
      impl_module(unquote(builtin_type), type_a).compare(b, a) 
    end

    def compare(a = %type_a{}, b) when unquote(guard)(b) do
      impl_module(type_a, unquote(builtin_type)).compare(a, b) * -1
    end
  end

  @spec lt?(any, any) :: boolean
  def lt?(a, b), do: compare(a, b) < 0

  @spec lte?(any, any) :: boolean
  def lte?(a, b), do: compare(a, b) <= 0

  @spec gt?(any, any) :: boolean
  def gt?(a, b), do: compare(a, b) > 0

  @spec gte?(any, any) :: boolean
  def gte?(a, b), do: compare(a, b) >= 0

  @spec eq?(any, any) :: boolean
  def eq?(a, b), do: compare(a, b) == 0

  def sort(collection_of_comparable_items) do
    Enum.sort(collection_of_comparable_items, &(gt?(&1, &2)))
  end


  defprotocol Protocol do
    @doc false
    def compare(fake_types_struct, a, b)
  end

  defmacro defcomparable_for(module_a, module_b, keywords) do

    # The generic protocol implementation, which dispatches to the actual implementation
    # protocol_impl = 
    #   quote do
    #     defimpl Comparable.Protocol, for: Module.concat(unquote(module_a), unquote(module_b)) do
    #       def compare(_types, a, b) do
    #         Module.concat(Comparable.ProtocolImpl, Module.concat(unquote(module_a), unquote(module_b))).compare(a, b)
    #       end
    #     end
    #   end

    quote generated: true do
      case {unquote(module_a), unquote(module_b)} do
        {type_a, type_b} when is_atom(type_a) and is_atom(type_b) and type_a <= type_b ->
  
          # The actual custom implementation is specified here.          
          implname = Module.concat(Comparable.ProtocolImpl, Module.concat(type_a, type_b))
          defmodule implname do
            unquote(keywords[:do])
          end

          #unquote(protocol_impl)

        {type_a, type_b} when is_atom(type_a) and is_atom(type_b) ->
          raise "defcomparable_for called with types in non-alphabetical order `#{inspect type_a}, #{inspect type_b}`! Use `defcomparable_for #{inspect type_b}, #{inspect type_a} do ... end ` instead."
      end
    end
  end

  defp impl_module(type_a, type_b) do
     Module.concat(Comparable.ProtocolImpl, Module.concat(type_a, type_b))
  end


end
