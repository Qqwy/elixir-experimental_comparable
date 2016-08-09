defmodule Comparable do

  defprotocol Protocol do
    @doc false
    def compare(fake_types_struct, a, b)
  end

  def compare(a = %type_a{}, b = %type_b{}) when type_a <= type_b do
    Comparable.Protocol.compare(%{__struct__: Module.concat(type_a, type_b)}, a, b)
  end

  def compare(a = %_type_a{}, b = %_type_b{}) do
    compare(b, a) * -1
  end

  defmacro defcomparable_for(module_a, module_b, keywords) do
    quote do
      case {unquote(module_a), unquote(module_b)} do
        {type_a, type_b} when is_atom(type_a) and is_atom(type_b) and type_a <= type_b ->
          fake_struct_name = Module.concat(type_a, type_b)
          implname = Module.concat(Comparable.ProtocolImpl, fake_struct_name)
          
          defmodule implname do
            unquote(keywords[:do])
          end

          # TODO: Find out if this is possible without nested eval_quoted
          quote do
            defimpl Comparable.Protocol, for: unquote(fake_struct_name) do
              def compare(_types, a, b) do
                unquote(implname).compare(a, b)
              end
            end
          end |> Code.eval_quoted
        {type_a, type_b} when is_atom(type_a) and is_atom(type_b) ->
          raise "defcomparable_for called with types in non-alphabetical order `#{type_a}, #{type_b}`! Use `defcomparable_for #{type_b}, #{type_a}, do: ` instead"
        _ -> 
          raise "Error: no correct `between: ` field found on defimpl_comparison."
      end
    end
  end


end


# defimpl_comparison Bar, Foo do

# end