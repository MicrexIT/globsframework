defmodule GlobsFramework.Json.GlobTypeSerializerTest do
  @moduledoc false
  use ExUnit.Case
  alias GlobsFramework.Json.{Mapping, GlobTypeSerializer}
  alias GlobsFramework.Metamodel.{GlobType, FieldsBuilder, GlobTypeBuilder}

  test "should serializable a simple glob type" do
    glob_type = GlobTypeBuilder.create("user")
    field = FieldsBuilder.build_string("name")
    glob_type = GlobTypeBuilder.add_field(glob_type, field)

    serializable =
      glob_type
      |> GlobTypeSerializer.write()

    assert Map.get(serializable, Mapping.type_name()) == "user"
    fields = Map.get(serializable, Mapping.fields())

    IO.inspect(fields)

    assert GlobTypeSerializer.serialize(glob_type) ==
             "{\"fields\":[{\"name\":\"name\",\"type\":\"string\"}],\"kind\":\"user\"}"
  end

  test "should serializable a glob type array" do
    glob_type = GlobTypeBuilder.create("user")
    field = FieldsBuilder.build_string("name")
    glob_type = GlobTypeBuilder.add_field(glob_type, field)

    glob_type2 = GlobTypeBuilder.create("user")
    field2 = FieldsBuilder.build_string("name")
    glob_type2 = GlobTypeBuilder.add_field(glob_type2, field2)

    assert GlobTypeSerializer.serialize([glob_type, glob_type2]) ==
             "[{\"fields\":[{\"name\":\"name\",\"type\":\"string\"}],\"kind\":\"user\"},{\"fields\":[{\"name\":\"name\",\"type\":\"string\"}],\"kind\":\"user\"}]"
  end
end
