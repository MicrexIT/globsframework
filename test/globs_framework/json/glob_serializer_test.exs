defmodule GlobsFramework.Json.GlobSerializerTest do
  @moduledoc false
  use ExUnit.Case
  alias GlobsFramework.Json.{GlobSerializer, Mapping}
  alias GlobsFramework.Metamodel.{GlobType, FieldsBuilder, GlobTypeBuilder}
  alias GlobsFramework.Model.{Glob}

  @moduletag :capture_log

  test "should serializable a simple glob" do
    glob_type = GlobTypeBuilder.create("user")
    field = FieldsBuilder.build_string("name")
    glob_type = GlobTypeBuilder.add_field(glob_type, field)
    glob = GlobType.instantiate(glob_type) |> Glob.add(glob_type, field, "bob")

    serializable =
      glob
      |> GlobSerializer.write()

    assert Map.get(serializable, Mapping.kind_name()) == "user"
    assert Map.get(serializable, "name") == "bob"

    assert GlobSerializer.serialize(glob) == "{\"_kind\":\"user\",\"name\":\"bob\"}"
  end

  test "should return the serializable for a glob with an array field" do
    glob_type = GlobTypeBuilder.create("user")
    field = FieldsBuilder.build_string_array("name")
    glob_type = GlobTypeBuilder.add_field(glob_type, field)
    glob = GlobType.instantiate(glob_type) |> Glob.add(glob_type, field, ["bob", "alice"])

    serializable =
      glob
      |> GlobSerializer.write()

    assert Map.get(serializable, Mapping.kind_name()) == "user"
    assert Map.get(serializable, "name") == ["bob", "alice"]

    assert GlobSerializer.serialize(glob) == "{\"_kind\":\"user\",\"name\":[\"bob\",\"alice\"]}"
  end

  test "should return the serializable map for glob with glob fields" do
    inner_field = FieldsBuilder.build_string("inner_name")
    glob_type_inner = GlobTypeBuilder.create("inner") |> GlobTypeBuilder.add_field(inner_field)

    inner_glob =
      GlobType.instantiate(glob_type_inner)
      |> Glob.add(glob_type_inner, inner_field, "inner_name_field")

    field_outer_1 = FieldsBuilder.build_string("outer_name")
    field_glob = FieldsBuilder.build_glob("field_glob", glob_type_inner)

    glob_type_outer =
      GlobTypeBuilder.create("outer")
      |> GlobTypeBuilder.add_field(field_outer_1)
      |> GlobTypeBuilder.add_field(field_glob)

    glob =
      GlobType.instantiate(glob_type_outer)
      |> Glob.add(glob_type_outer, field_outer_1, "bob")
      |> Glob.add(glob_type_outer, field_glob, inner_glob)

    serializable =
      glob
      |> GlobSerializer.write()

    assert Map.get(serializable, Mapping.kind_name()) == "outer"
    assert Map.get(serializable, "name") != "bob"

    assert GlobSerializer.serialize(glob) ==
             "{\"_kind\":\"outer\",\"field_glob\":{\"inner_name\":\"inner_name_field\"},\"outer_name\":\"bob\"}"
  end

  test "should return the serializable array for glob with array glob fields" do
    inner_field = FieldsBuilder.build_string_array("inner_array_name")
    glob_type_inner = GlobTypeBuilder.create("inner") |> GlobTypeBuilder.add_field(inner_field)

    inner_glob1 =
      GlobType.instantiate(glob_type_inner)
      |> Glob.add(glob_type_inner, inner_field, ["inner_name_field"])

    inner_glob2 =
      GlobType.instantiate(glob_type_inner)
      |> Glob.add(glob_type_inner, inner_field, ["inner_name_field2"])

    field_glob = FieldsBuilder.build_glob_array("field_glob", glob_type_inner)
    field_outer_1 = FieldsBuilder.build_string("outer_name")

    glob_type_outer =
      GlobTypeBuilder.create("outer")
      |> GlobTypeBuilder.add_field(field_outer_1)
      |> GlobTypeBuilder.add_field(field_glob)

    glob =
      GlobType.instantiate(glob_type_outer)
      |> Glob.add(glob_type_outer, field_outer_1, "bob")
      |> Glob.add(glob_type_outer, field_glob, [inner_glob1, inner_glob2])

    serializable =
      glob
      |> GlobSerializer.write()

    assert Map.get(serializable, Mapping.kind_name()) == "outer"
    assert Map.get(serializable, "name") != "bob"

    assert GlobSerializer.serialize(glob) ==
             "{\"_kind\":\"outer\",\"field_glob\":[{\"inner_array_name\":[\"inner_name_field\"]},{\"inner_array_name\":[\"inner_name_field2\"]}],\"outer_name\":\"bob\"}"
  end

  test "should return an array of serializable globs" do
    field = FieldsBuilder.build_string("field_string")

    glob_type =
      GlobTypeBuilder.create("outer")
      |> GlobTypeBuilder.add_field(field)

    bob =
      GlobType.instantiate(glob_type)
      |> Glob.add(glob_type, field, "bob")

    alice =
      GlobType.instantiate(glob_type)
      |> Glob.add(glob_type, field, "alice")

    john =
      GlobType.instantiate(glob_type)
      |> Glob.add(glob_type, field, "john")

    serializable_array =
      [bob, alice, john]
      |> GlobSerializer.write()

    for serializable <- serializable_array do
      assert Map.get(serializable, Mapping.kind_name()) == "outer"
      assert is_bitstring(Map.get(serializable, "field_string"))
      assert !is_bitstring(Map.get(serializable, "not_existing_field"))
    end

    assert GlobSerializer.serialize([bob, alice, john]) ==
             "[{\"_kind\":\"outer\",\"field_string\":\"bob\"},{\"_kind\":\"outer\",\"field_string\":\"alice\"},{\"_kind\":\"outer\",\"field_string\":\"john\"}]"
  end
end
