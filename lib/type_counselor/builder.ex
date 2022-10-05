defmodule TypeCounselor.Builder do
  @doc """
  Unifies type suggestions.
  """
  def unify(items) when is_list(items) do
    Enum.map(items, &unify/1)
  end

  def unify({:map, items}) do
    unified_items = Enum.map(items, fn {field, value} -> {field, unify(value)} end)
    {:map, unified_items}
  end

  def unify({:list, [{:map, _} | _] = items}) do
    unified_items =
      Enum.reduce(items, [], fn {:map, map}, acc ->
        Keyword.merge(acc, map, &resolve/3)
      end)

    {:list, [{:map, unified_items}]}
  end

  def unify({:list, items}) do
    {:list, Enum.uniq(items)}
  end

  def unify(value) do
    value
  end

  defp resolve(_field, a, b) when is_list(a) and is_list(b) do
    unify(Enum.uniq(a ++ b))
  end
end
