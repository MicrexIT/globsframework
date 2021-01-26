defmodule GlobsFramework.Metamodel.FieldsBuilderTest do
  @moduledoc false
  use ExUnit.Case
  alias GlobsFramework.Metamodel.FieldsBuilder
  alias GlobsFramework.Metamodel.Annotations.KeyFieldAnnotation
  alias GlobsFramework.Metamodel.Field

  test "should build a key field" do
    field = FieldsBuilder.build_integer("id", [KeyFieldAnnotation.instance()])
    assert Field.get_name(field) == "id"
    assert Field.key?(field) == true
    assert Field.get_data_type(field) == :int
  end
end
