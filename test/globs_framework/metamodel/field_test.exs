defmodule GlobsFramework.Metamodel.FieldTest do
  @moduledoc false
  use ExUnit.Case
  alias GlobsFramework.Metamodel.{Field, GlobType, GlobTypeBuilder}

  test "should correctly infer a default field's data type" do
    assert Field.get_data_type(%Field{name: "int", type: :int}) !=
             "string"

    assert Field.get_data_type(%Field{name: "field", type: :int}) == :int
  end

  test "should correctly check values on a default field's data type" do
    assert Field.check_value(%Field{name: "int", type: :int}, 11)
    assert !Field.check_value(%Field{name: "int", type: :int}, "string")
    assert Field.check_value(%Field{name: "str", type: :string}, "string")
    assert Field.check_value(%Field{name: "bool", type: :boolean}, true)
    assert Field.check_value(%Field{name: "boolArr", type: :boolean_array}, [true])

    assert Field.check_value(%Field{name: "stringArr", type: :string_array}, [
             "string",
             "string"
           ])

    assert Field.check_value(%Field{name: "integerArr", type: :int_array}, [
             11,
             123
           ])
  end

  test "should correctly initialize a glob field" do
    glob_type = GlobTypeBuilder.create("glob_type_field")
    random_glob = GlobType.instantiate(glob_type)
    field = %Field{name: "glob_field", type: :glob, glob_type: glob_type}

    assert Field.check_value(field, random_glob)
    assert !Field.check_value(field, "string")
    assert !Field.check_value(field, %{})

    assert Field.check_value(%Field{name: "stringArr", type: :string_array}, [
             "string",
             "string"
           ])
  end

  test "should correctly initialize a glob array field" do
    glob_type = GlobTypeBuilder.create("glob_type_array_field")
    random_glob = GlobType.instantiate(glob_type)
    random_glob2 = GlobType.instantiate(glob_type)
    field = %Field{name: "glob_array_field", type: :glob_array, glob_type: glob_type}

    assert Field.check_value(field, [random_glob, random_glob2])
    assert Field.check_value(field, [random_glob])
    assert Field.check_value(field, [])
    assert !Field.check_value(field, random_glob)
    assert !Field.check_value(field, [random_glob, "string"])
    assert !Field.check_value(field, "string")
    assert !Field.check_value(field, %{})
    assert !Field.check_value(field, [%{}])
  end
end
