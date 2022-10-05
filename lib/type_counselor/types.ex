defmodule TypeCounselor.Types do
  def suggest_types(value) do
    case suggest(value) do
      nil -> [nil]
      suggestion -> List.wrap(suggestion)
    end
  end

  @doc """
  Suggests a type for a given value.
  """
  def suggest(struct) when is_struct(struct) do
    values =
      struct
      |> Map.from_struct()
      |> Enum.map(fn {key, value} ->
        {key, suggest_types(value)}
      end)

    {:map, values}
  end

  def suggest(function) when is_function(function) do
    :function
  end

  def suggest(map) when is_map(map) do
    values =
      map
      |> Enum.map(fn {key, value} ->
        {key, suggest_types(value)}
      end)

    {:map, values}
  end

  def suggest(values) when is_list(values) do
    {:list, values |> Enum.map(&suggest/1) |> Enum.uniq()}
  end

  def suggest(value) when is_binary(value) do
    if String.valid?(value) do
      :string
    else
      :binary
    end
  end

  def suggest(value) when is_integer(value) do
    if value >= 0 do
      :non_neg_integer
    else
      :integer
    end
  end

  def suggest(atom) when is_atom(atom) do
    atom
  end

  def suggest(tuple) when is_tuple(tuple) do
    values =
      tuple
      |> Tuple.to_list()
      |> Enum.map(&suggest/1)
      |> List.to_tuple()

    {:tuple, values}
  end
end
