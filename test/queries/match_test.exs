defmodule Queries.MatchTest do
  use ExUnit.Case

  import ExCypher

  describe "MATCH single nodes" do
    test "with an empty node" do
      assert "MATCH ()" = cypher(do: match(node()))
    end

    test "with only a name" do
      assert "MATCH (node)" = cypher(do: match(node(:node)))
    end

    test "with a name and a single label" do
      query =
        cypher do
          match(node(:n, [:Node]))
        end

      assert "MATCH (n:Node)" = query
    end

    test "with only labels" do
      query =
        cypher do
          match(node([:Node]))
        end

      assert "MATCH (:Node)" = query
    end

    test "with only labels and props" do
      query =
        cypher do
          match(node([:Node], %{name: "foo"}))
        end

      assert ~S[MATCH (:Node {name:"foo"})] = query
    end

    test "with a name and a multiple labels" do
      query =
        cypher do
          match(node(:bob, [:Person, :Employee]))
        end

      assert "MATCH (bob:Person,Employee)" = query
    end

    test "with a name and one prop" do
      query =
        cypher do
          match(node(:bob, [], %{name: "Bob"}))
        end

      assert ~S[MATCH (bob {name:"Bob"})] == query
    end

    test "with a name and lots of props" do
      query =
        cypher do
          match(node(:rick, [], %{name: "Rick", role: "scientist"}))
        end

      assert ~S[MATCH (rick {name:"Rick",role:"scientist"})] == query
    end

    test "with only props" do
      query =
        cypher do
          match(node(%{name: "Rick", role: "scientist"}))
        end

      assert ~S[MATCH ({name:"Rick",role:"scientist"})] == query
    end
  end

  describe "MATCH nodes and relationships" do
    test "with an undirected relationship" do
      expected = ~S[MATCH (n:Node)--(b:Node)]

      query =
        cypher do
          match(node(:n, [:Node]) -- node(:b, [:Node]))
        end

      assert expected == query
    end

    test "accepts a directed relationship pointing forward" do
      expected = ~S[MATCH (n:Node)-->(b:Node)]

      query =
        cypher do
          match((node(:n, [:Node]) -> node(:b, [:Node])))
        end

      assert expected == query
    end

    test "accepts a directed relationship pointing backward" do
      expected = ~S[MATCH (n:Node)<--(b:Node)]

      query =
        cypher do
          match(node(:n, [:Node]) <- node(:b, [:Node]))
        end

      assert expected == query
    end

    test "accepts complex relationships" do
      expected = ~S[MATCH (n:Node)<--()-->(b:Node)]

      query =
        cypher do
          match((node(:n, [:Node]) <- node() -> node(:b, [:Node])))
        end

      assert expected == query
    end
  end

  describe "MATCH multiple elements" do
    test "correctly matches on multiple elements" do
      expected = ~S[MATCH (a:Node), (b:Node)]

      query =
        cypher do
          match(
            node(:a, [:Node]),
            node(:b, [:Node])
          )
        end

      assert expected == query
    end

    test "correctly associates multiple matches and relationships" do
      expected = ~S[MATCH (a:Node), (c:Node), (c)<--(a)-->(b:Node)]

      query =
        cypher do
          match(
            node(:a, [:Node]),
            node(:c, [:Node]),
            (node(:c) <- node(:a) -> node(:b, [:Node]))
          )
        end

      assert expected == query
    end
  end

  describe "MATCH relationships with props" do
    test "accepts named relationships" do
      expected = ~S[MATCH (a)-[r\]-(b)]

      query =
        cypher do
          match(node(:a) -- rel(:r) -- node(:b))
        end

      assert expected == query
    end

    test "accepts labeled relationships" do
      expected = ~S[MATCH (a)-[:Rel\]-(b)]

      query =
        cypher do
          match(node(:a) -- rel([:Rel]) -- node(:b))
        end

      assert expected == query
    end

    test "accepts backwards named relationships" do
      expected = ~S[MATCH (a)<-[:Rel\]-(b)]

      query =
        cypher do
          match(node(:a) <- rel([:Rel]) -- node(:b))
        end

      assert expected == query
    end

    test "accepts towards named relationships" do
      expected = ~S[MATCH (a)-[:Rel\]->(b)]

      query =
        cypher do
          match((node(:a) -- rel([:Rel]) -> node(:b)))
        end

      assert expected == query
    end

    test "accepts properties in relationships" do
      expected = ~S[MATCH (a)-[:Rel {name:"foo"}\]->(b)]

      query =
        cypher do
          match((node(:a) -- rel([:Rel], %{name: "foo"}) -> node(:b)))
        end

      assert expected == query
    end

    test "accepts properties in named and labeled relationships" do
      expected = ~S[MATCH (a)-[r:Rel {name:"foo"}\]->(b)]

      query =
        cypher do
          match((node(:a) -- rel(:r, [:Rel], %{name: "foo"}) -> node(:b)))
        end

      assert expected == query
    end
  end
end
