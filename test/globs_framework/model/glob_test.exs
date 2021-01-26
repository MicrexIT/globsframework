defmodule GlobsFramework.Model.GlobTest do
  @moduledoc false
  use ExUnit.Case

  alias GlobsFramework.Model.Glob
  alias GlobsFramework.Metamodel.GlobType
  alias GlobsFramework.Metamodel.GlobTypeBuilder
  alias GlobsFramework.Metamodel.FieldsBuilder

  @moduletag :capture_log

  doctest Glob

  test "module exists" do
    assert is_list(Glob.module_info())
  end

  test "should get a field in a glob" do
    glob_type = GlobTypeBuilder.create("user")
    field = FieldsBuilder.build_string("name")
    glob_type = GlobTypeBuilder.add_field(glob_type, field)
    glob = GlobType.instantiate(glob_type)
    glob = Glob.add(glob, glob_type, field, "bob")
    assert Glob.get_value(glob, field) == "bob"
  end

  test "should return nil when a glob is called with an not existing field" do
    glob_type = GlobTypeBuilder.create("user")
    glob = GlobType.instantiate(glob_type)
    field = FieldsBuilder.build_string("name")
    assert Glob.get_value(glob, field) == nil
  end

  test "should set a string field in a glob" do
    glob_type = GlobTypeBuilder.create("user")
    field = FieldsBuilder.build_string("name")
    glob_type = GlobTypeBuilder.add_field(glob_type, field)
    glob = GlobType.instantiate(glob_type)
    glob = Glob.add(glob, glob_type, field, "bob")
    assert Glob.get_value(glob, field) == "bob"
  end
end
