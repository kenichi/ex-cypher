defmodule ExCypher.Graph.Node do
  @moduledoc """
  Builds nodes using cypher syntax

  It can be used in order to build more complex queries involving your
  graph nodes.
  """

  alias ExCypher.Graph.Component

  @doc """
  Returns the CYPHER's syntax to a node element.

  ### Examples:

      iex> node()
      "()"

      iex> node(%{name: "bob"})
      "({\"name\": \"bob\"})"

      iex> node([:Person])
      "(:Person)"

      iex> node([:Person], %{name: "Amelia"})
      "(:Person {name: \"Amelia\"})"

      iex> node(:a, [:Node])
      "(a:Node)"

      iex> node(:a, [:Node], %{name: "mark", age: 27})
      "(a:Node {\"name\": \"mark\", \"age\": 27)"

  """
  @spec node() :: Component.ast()
  def node, do: node(nil, nil, nil)

  @spec node(Component.labels() | Component.properties()) :: Component.ast()
  def node(props = %{}), do: node(nil, nil, props)

  @spec node(Component.name() | Component.labels(), Component.properties()) :: Component.ast()
  def node(node_name, props = %{})
      when is_binary(node_name) or is_atom(node_name),
      do: node(node_name, [], props)

  def node(labels_list, props = %{})
      when is_list(labels_list),
      do: node("", labels_list, props)

  @spec node(Component.name(), Component.labels(), Component.properties()) :: Component.ast()
  def node(name, labels \\ [], props \\ %{}) do
    Component.escape_node(name, labels, props) |> to_node()
  end

  @spec to_node(list()) :: Component.ast()
  defp to_node(inner) do
    quote do
      unquote(inner)
      |> List.flatten()
      |> Enum.join()
      |> String.trim()
      |> Component.wrap(:node)
    end
  end
end
