defmodule Cforum.Search.QueryTest do
  use Cforum.DataCase

  alias Cforum.Search.Query

  describe "all" do
    test "it parses an easy expression" do
      assert Query.parse("foo") == %Query{all: %{include: ["foo"], exclude: []}}
      assert Query.parse("+foo") == %Query{all: %{include: ["foo"], exclude: []}}
    end

    test "it parses a quoted expression" do
      assert Query.parse("\"foo bar\"") == %Query{all: %{include: [{:phrase, "foo bar"}], exclude: []}}
      assert Query.parse("+\"foo bar\"") == %Query{all: %{include: [{:phrase, "foo bar"}], exclude: []}}
    end

    test "it parses an exclude expression" do
      assert Query.parse("-foo") == %Query{all: %{include: [], exclude: ["foo"]}}
    end

    test "it parses a quoted exclude expression" do
      assert Query.parse("-\"foo bar\"") == %Query{all: %{include: [], exclude: [{:phrase, "foo bar"}]}}
    end
  end

  describe "author" do
    test "it parses an expression for an author" do
      assert Query.parse("author:foo") == %Query{author: %{include: ["foo"], exclude: []}}
      assert Query.parse("+author:foo") == %Query{author: %{include: ["foo"], exclude: []}}
      assert Query.parse("author:+foo") == %Query{author: %{include: ["foo"], exclude: []}}
    end

    test "it parses a quoted expression for an author" do
      assert Query.parse("author:\"foo bar\"") == %Query{author: %{include: [{:phrase, "foo bar"}], exclude: []}}
      assert Query.parse("+author:\"foo bar\"") == %Query{author: %{include: [{:phrase, "foo bar"}], exclude: []}}
      assert Query.parse("author:+\"foo bar\"") == %Query{author: %{include: [{:phrase, "foo bar"}], exclude: []}}
    end

    test "it parses an exclude expression for an author" do
      assert Query.parse("-author:foo") == %Query{author: %{include: [], exclude: ["foo"]}}
      assert Query.parse("author:-foo") == %Query{author: %{include: [], exclude: ["foo"]}}
    end

    test "it parses a quoted exclude expression for an author" do
      assert Query.parse("-author:\"foo bar\"") == %Query{author: %{include: [], exclude: [{:phrase, "foo bar"}]}}
      assert Query.parse("author:-\"foo bar\"") == %Query{author: %{include: [], exclude: [{:phrase, "foo bar"}]}}
    end
  end

  describe "title" do
    test "it parses an expression for a title" do
      assert Query.parse("title:foo") == %Query{title: %{include: ["foo"], exclude: []}}
      assert Query.parse("+title:foo") == %Query{title: %{include: ["foo"], exclude: []}}
      assert Query.parse("title:+foo") == %Query{title: %{include: ["foo"], exclude: []}}
    end

    test "it parses a quoted expression for a title" do
      assert Query.parse("title:\"foo bar\"") == %Query{title: %{include: [{:phrase, "foo bar"}], exclude: []}}
      assert Query.parse("+title:\"foo bar\"") == %Query{title: %{include: [{:phrase, "foo bar"}], exclude: []}}
      assert Query.parse("title:+\"foo bar\"") == %Query{title: %{include: [{:phrase, "foo bar"}], exclude: []}}
    end

    test "it parses an exclude expression for a title" do
      assert Query.parse("-title:foo") == %Query{title: %{include: [], exclude: ["foo"]}}
      assert Query.parse("title:-foo") == %Query{title: %{include: [], exclude: ["foo"]}}
    end

    test "it parses a quoted exclude expression for a title" do
      assert Query.parse("-title:\"foo bar\"") == %Query{title: %{include: [], exclude: [{:phrase, "foo bar"}]}}
      assert Query.parse("title:-\"foo bar\"") == %Query{title: %{include: [], exclude: [{:phrase, "foo bar"}]}}
    end
  end

  describe "body" do
    test "it parses an expression for a body" do
      assert Query.parse("body:foo") == %Query{content: %{include: ["foo"], exclude: []}}
      assert Query.parse("+body:foo") == %Query{content: %{include: ["foo"], exclude: []}}
      assert Query.parse("body:+foo") == %Query{content: %{include: ["foo"], exclude: []}}
    end

    test "it parses a quoted expression for a body" do
      assert Query.parse("body:\"foo bar\"") == %Query{content: %{include: [{:phrase, "foo bar"}], exclude: []}}
      assert Query.parse("+body:\"foo bar\"") == %Query{content: %{include: [{:phrase, "foo bar"}], exclude: []}}
      assert Query.parse("body:+\"foo bar\"") == %Query{content: %{include: [{:phrase, "foo bar"}], exclude: []}}
    end

    test "it parses an exclude expression for a body" do
      assert Query.parse("-body:foo") == %Query{content: %{include: [], exclude: ["foo"]}}
      assert Query.parse("body:-foo") == %Query{content: %{include: [], exclude: ["foo"]}}
    end

    test "it parses a quoted exclude expression for a body" do
      assert Query.parse("-body:\"foo bar\"") == %Query{content: %{include: [], exclude: [{:phrase, "foo bar"}]}}
      assert Query.parse("body:-\"foo bar\"") == %Query{content: %{include: [], exclude: [{:phrase, "foo bar"}]}}
    end
  end

  describe "tag" do
    test "it parses an expression for a tag" do
      assert Query.parse("tag:foo") == %Query{tags: %{include: ["foo"], exclude: []}}
      assert Query.parse("+tag:foo") == %Query{tags: %{include: ["foo"], exclude: []}}
      assert Query.parse("tag:+foo") == %Query{tags: %{include: ["foo"], exclude: []}}
    end

    test "it parses a quoted expression for a tag" do
      assert Query.parse("tag:\"foo bar\"") == %Query{tags: %{include: [{:phrase, "foo bar"}], exclude: []}}
      assert Query.parse("+tag:\"foo bar\"") == %Query{tags: %{include: [{:phrase, "foo bar"}], exclude: []}}
      assert Query.parse("tag:+\"foo bar\"") == %Query{tags: %{include: [{:phrase, "foo bar"}], exclude: []}}
    end

    test "it parses an exclude expression for a tag" do
      assert Query.parse("-tag:foo") == %Query{tags: %{include: [], exclude: ["foo"]}}
      assert Query.parse("tag:-foo") == %Query{tags: %{include: [], exclude: ["foo"]}}
    end

    test "it parses a quoted exclude expression for a tag" do
      assert Query.parse("-tag:\"foo bar\"") == %Query{tags: %{include: [], exclude: [{:phrase, "foo bar"}]}}
      assert Query.parse("tag:-\"foo bar\"") == %Query{tags: %{include: [], exclude: [{:phrase, "foo bar"}]}}
    end
  end

  test "it parses a more complex query" do
    assert Query.parse("foo author:bar author:-foo lulu title:baz") == %Query{
             all: %{include: ["foo", "lulu"], exclude: []},
             author: %{include: ["bar"], exclude: ["foo"]},
             title: %{include: ["baz"], exclude: []}
           }
  end

  test "it removes leading and trailing whitespaces" do
    assert Query.parse("  foo  ") == %Query{all: %{include: ["foo"], exclude: []}}
    assert Query.parse("author:\"  foo  \"") == %Query{author: %{include: [{:phrase, "foo"}], exclude: []}}
  end
end
