defmodule ExCypher.Statements.Generic.Expression do
  @moduledoc """
    A module to abstract the AST format into something mode human-readable
  """

  defstruct [:type, :env, :args]

  def new(ast, env) do
    cond do
      fragment?(ast) ->
        {_command, _, args} = ast
        %__MODULE__{type: :fragment, args: args, env: env}

      property?(ast) ->
        {{_, _, [first, last | []]}, _, _} = ast
        %__MODULE__{type: :property, args: [first, last], env: env}

      node?(ast) ->
        {_command, _, args} = ast
        %__MODULE__{type: :node, args: args, env: env}

      relationship?(ast) ->
        {_command, _, args} = ast
        %__MODULE__{type: :relationship, args: args, env: env}

      association?(ast) ->
        {association, _ctx, [from, to]} = ast

        %__MODULE__{
          type: :association,
          args: [association, {from, to}],
          env: env
        }

      is_nil(ast) ->
        %__MODULE__{type: :null, args: nil, env: env}

      is_atom(ast) ->
        %__MODULE__{type: :alias, args: ast, env: env}

      is_list(ast) ->
        %__MODULE__{type: :list, args: ast, env: env}

      variable?(ast) ->
        %__MODULE__{type: :var, args: ast, env: env}

      true ->
        %__MODULE__{type: :other, args: ast, env: env}
    end
  end

  def fragment?({:fragment, _ctx, args}) do
    {:ok, {:fragment, args}}
  end

  def fragment?(_), do: false

  def property?({{:., _, [_first, _last | []]}, _, _}), do: true
  def property?(_), do: false

  def node?({:node, _ctx, args}), do: true
  def node?(_), do: false

  def relationship?({:rel, _ctx, args}), do: true
  def relationship?(_), do: false

  @associations [:--, :->, :<-]
  def association?({assoc, _ctx, args}) when assoc in @associations,
    do: true

  def association?(_), do: false

  def variable?({var_name, _ctx, nil}), do: is_atom(var_name)
  def variable?(_), do: false
end