defmodule GlobsFramework.Metamodel.KeyTest do
  @moduledoc false
  use ExUnit.Case
  alias GlobsFramework.Metamodel
  alias Metamodel.Key
  alias Metamodel.GlobTypeBuilder
  alias Metamodel.FieldsBuilder
  alias GlobsFramework.Model
  alias Model.GlobBuilder

  test "should create a key from a globtype without key fields" do
    gt = GlobTypeBuilder.create("aType")
    field = FieldsBuilder.build_string("name")
    gt = GlobTypeBuilder.add_field(gt, field)
    key = Key.build(gt)

    assert key == "glob_type:aType"
  end

  test "should create a key from a glob without key fields" do
    gt = GlobTypeBuilder.create("aType")
    field = FieldsBuilder.build_string("name")
    gt = GlobTypeBuilder.add_field(gt, field)
    glob = GlobBuilder.create(gt)
    key = Key.build(glob)
    assert key == "glob_type:aType"
  end
end
