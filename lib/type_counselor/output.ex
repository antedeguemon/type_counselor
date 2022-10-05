defmodule TypeCounselor.Output do
  # TODO: Fix `TypeCounselor.Types.unify/1` return so this strange match can be removed
  def to_specs([{:list, [struct]}]) do
    struct
    |> pprint()
    |> Code.string_to_quoted!()
    |> Macro.to_string()
  end

  defp pprint({:map, items}) do
    items_string =
      items
      |> Enum.map(fn
        {key, value} when is_atom(key) ->
          to_string(key) <> " => " <> pprint(value)

        {key, value} when is_binary(key) ->
          to_string(String.replace(key, "\"", "'")) <> " => " <> pprint(value)

        {key, value} ->
          escaped_key = String.replace(inspect(key, limit: :infinity), "\"", "\\\"")
          "\"" <> escaped_key <> "\" => " <> pprint(value)
      end)
      |> Enum.join(",\n")

    "%{" <> items_string <> "}"
  end

  defp pprint({:list, items}) when is_list(items) do
    "list(" <> (items |> Enum.map(&pprint/1) |> Enum.join(" | ")) <> ")"
  end

  defp pprint(items) when is_list(items) do
    items
    |> Enum.map(&pprint/1)
    |> Enum.join(" | ")
  end

  defp pprint(:string) do
    "String.t()"
  end

  defp pprint(item) do
    inspect(item, limit: :infinity)
  end
end
