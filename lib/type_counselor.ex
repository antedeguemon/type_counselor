defmodule TypeCounselor do
  defdelegate add(name, struct), to: TypeCounselor.Server
  defdelegate fetch(name), to: TypeCounselor.Server

  def suggest(structs) do
    structs
    |> TypeCounselor.Types.suggest_types()
    |> TypeCounselor.Builder.unify()
    |> TypeCounselor.Output.to_specs()
  end
end
