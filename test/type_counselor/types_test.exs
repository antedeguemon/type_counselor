defmodule TypeCounselor.TypesTest do
  use ExUnit.Case, async: true
  doctest TypeCounselor.Types
  alias TypeCounselor.Types

  test "function" do
    assert Types.suggest(fn -> IO.puts("hey!") end) == :function
    assert Types.suggest(fn _, _ -> IO.puts("hey!") end) == :function
    assert Types.suggest(&IO.puts/1) == :function
  end

  test "map" do
    assert Types.suggest(%{name: "John Titor", age: 26}) ==
             {:map, [{:age, [:non_neg_integer]}, {:name, [:string]}]}

    assert Types.suggest(%{name: "Titor", computer: %{maker: "IBM"}}) ==
             {:map, [computer: [{:map, [maker: [:string]]}], name: [:string]]}
  end

  test "list" do
    assert Types.suggest(["string", "string"]) == {:list, [:string]}
    assert Types.suggest([1, 2, 3, "string"]) == {:list, [:non_neg_integer, :string]}
  end

  test "string" do
    assert Types.suggest("Simple string") == :string
    assert Types.suggest("") == :string
  end

  test "integer" do
    assert Types.suggest(0) == :non_neg_integer
    assert Types.suggest(1) == :non_neg_integer
    assert Types.suggest(-1) == :integer
  end

  test "atom" do
    assert Types.suggest(:hey) == :hey
    assert Types.suggest(:"Quoted atom") == :"Quoted atom"
  end

  test "tuple" do
    assert Types.suggest({1, "hey"}) == {:tuple, {:non_neg_integer, :string}}
  end
end
