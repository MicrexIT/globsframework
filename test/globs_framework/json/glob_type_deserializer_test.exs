defmodule GlobsFramework.Json.GlobTypeDeserializerTest do
  @moduledoc false
  use ExUnit.Case
  alias GlobsFramework.Json.{Mapping, GlobTypeDeserializer, GlobTypeSerializer}
  alias GlobsFramework.Metamodel.{GlobType, FieldsBuilder, GlobTypeBuilder}
  alias GlobsFramework.Metamodel.Annotations.KeyFieldAnnotation

  test "should deserialize a simple glob type" do
    glob_type = GlobTypeBuilder.create("user")
    field = FieldsBuilder.build_string("name")
    glob_type = GlobTypeBuilder.add_field(glob_type, field)

    serialized_glob_type =
      glob_type
      |> GlobTypeSerializer.serialize()

    deserialized = GlobTypeDeserializer.deserialize(serialized_glob_type, [])
    assert GlobType.get_name(deserialized) == "user"
    assert GlobType.get_field(deserialized, "name") == field
  end

  test "should deserialize a glob type with key annotation" do
    glob_type = GlobTypeBuilder.create("user")
    key_field = FieldsBuilder.build_integer("id", [KeyFieldAnnotation.instance()])
    glob_type = GlobTypeBuilder.add_field(glob_type, key_field)
    field = FieldsBuilder.build_string("name")
    glob_type = GlobTypeBuilder.add_field(glob_type, field)

    serialized_glob_type =
      glob_type
      |> GlobTypeSerializer.serialize()

    deserialized =
      GlobTypeDeserializer.deserialize(serialized_glob_type, [KeyFieldAnnotation.get_glob_type()])

    assert GlobType.get_name(deserialized) == "user"
    assert GlobType.get_field(deserialized, "name") == field
    assert GlobType.get_field(deserialized, "id") == key_field
  end
end
