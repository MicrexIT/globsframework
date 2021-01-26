defmodule GlobsFramework.Metamodel.GeneratorTest do
  @moduledoc false
  use ExUnit.Case
  alias GlobsFramework.Metamodel.{GlobType, Field}
  alias GlobsFramework.Metamodel.Annotations.KeyFieldAnnotation
  import GlobsFramework.Metamodel.Generator

  @moduletag :capture_log

  test "should return keys" do
    config = %{
      type: "aType",
      name: string_field()
      # email: string_field,
      # admin: boolean_field
    }

    keys = get_fields_keys(config)

    assert keys === [:name]
  end

  test "should initialize glob type with generator" do
    config = %{
      type: "aType",
      name: string_field()
      # email: string_field,
      # admin: boolean_field
    }

    gt = initialize_glob_type(config)

    assert GlobType.get_name(gt) == "aType"
  end

  test "should create a glob-type using a generator" do
    config = %{
      type: "aType",
      name: string_field(),
      email: string_field([KeyFieldAnnotation.instance()]),
      admin: boolean_field()
    }

    # todo: idea -> have these schema defined in a macro so that when we initialize a module using the schema
    # with key :user then we automatically generate a module with a struct "equal" to the map returned by the config
    # cf: ecto for phoenix or phoenix mvc web how it unquotes the imports
    %{
      type: type,
      name: name,
      email: email,
      admin: admin
    } = generate(config)

    assert GlobType.get_name(type) == "aType"
    assert Field.get_name(name) == "name"
    assert Field.key?(name) == false
    assert Field.get_name(email) == "email"
    assert Field.key?(email) == true
    assert Field.get_name(admin) == "admin"
  end

  test "should create a glob-type with glob fields using a generator" do
    config = %{
      type: "aType",
      name: string_field(),
      stuff: glob_field(%GlobType{name: "stuff_type"}),
      more_stuff: glob_array_field(%GlobType{name: "more_stuff_type"})
    }

    # todo: idea -> have these schema defined in a macro so that when we initialize a module using the schema
    # with key :user then we automatically generate a module with a struct "equal" to the map returned by the config
    # cf: ecto for phoenix or phoenix mvc web how it unquotes the imports
    %{
      type: type,
      name: name,
      stuff: stuff,
      more_stuff: more_stuff
    } = generate(config)

    assert GlobType.get_name(type) == "aType"
    assert Field.get_name(name) == "name"
    assert Field.get_name(stuff) == "stuff"
    assert Field.get_data_type(stuff) == :glob
    assert Field.get_name(more_stuff) == "more_stuff"
    assert Field.get_data_type(more_stuff) == :glob_array
  end
end
