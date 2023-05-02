defmodule ExCypher.Graph.Relationship do
  @moduledoc """
  Builds relationships using cypher syntax
  """
  alias ExCypher.Graph.Component

  @type assoc_direction :: :-- | :-> | :<-
  @type node_or_relationship :: {:node | :relationship, String.t()}

  @doc """
  Returns the Cypher's syntax for a relationship:

  ### Usage:

      iex> rel()
      "[]"

      iex> rel(%{year: 1980})
      "[{\"year\": 1980}]"

      iex> rel([:WORKS_IN])
      "[:WORKS_IN]"

      iex> rel(:r, %{year: 1980})
      "[r {\"year\": 1980}]"

      iex> rel([:Rel], %{year: 1980})
      "[:Rel {\"year\": 1980}]"

      iex> rel(:r, [:Rel], %{year: 1980})
      "[r:Rel {\"year\": 1980}]"
  """

  @spec rel() :: Component.ast()
  def rel, do: rel("")

  @spec rel(Component.name() | Component.properties()) :: Component.ast()
  def rel(%{} = props), do: rel(nil, nil, props)

  @spec rel(Component.name() | Component.labels(), Component.properties()) :: Component.ast()
  def rel(labels, props = %{})
      when is_list(labels),
      do: rel("", labels, props)

  def rel(rel_name, props = %{})
      when is_binary(rel_name) or is_atom(rel_name),
      do: rel(rel_name, [], props)

  @spec rel(Component.name(), Component.labels(), Component.properties()) :: Component.ast()
  def rel(name, labels \\ [], props \\ %{}) do
    Component.escape_relation(name, labels, props) |> to_rel()
  end

  @spec to_rel(list()) :: Component.ast()
  def to_rel(relation) do
    quote do
      unquote(relation)
      |> List.flatten()
      |> Enum.join()
      |> String.trim()
      |> Component.wrap(:relation)
    end
  end

  @doc """
    Builds associations between nodes and relationships
  """
  @spec assoc(assoc_direction, {node_or_relationship, node_or_relationship}) :: Component.ast()
  def assoc(assoc_type, {{from_type, from}, {to_type, to}}) do
    assoc_symbol = assoc_string(assoc_type, from_type, to_type)

    quote do
      [unquote(from), unquote(assoc_symbol), unquote(to)]
      |> List.flatten()
      |> Enum.join()
    end
  end

  defp any_rel?(from_type, to_type) do
    from_type == :relationship || to_type == :relationship
  end

  defp assoc_string(assoc_type, from_type, to_type) do
    case {assoc_type, any_rel?(from_type, to_type)} do
      {:--, false} -> "--"
      {:--, true} -> "-"
      {:<-, false} -> "<--"
      {:<-, true} -> "<-"
      {:->, false} -> "-->"
      {:->, true} -> "->"
    end
  end
end
