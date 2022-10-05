defmodule TypeCounselor do
  def suggest(structs) do
    structs
    |> TypeCounselor.Types.suggest_types()
    |> TypeCounselor.Builder.unify()
    |> TypeCounselor.Output.to_specs()
  end
end
