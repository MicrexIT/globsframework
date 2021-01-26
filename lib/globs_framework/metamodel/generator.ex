defmodule GlobsFramework.Metamodel.Generator do
  @moduledoc """
  Generate maps with objects and the respective fields
  """
  alias GlobsFramework.Metamodel
  alias Metamodel.GlobTypeBuilder
  alias Metamodel.GlobType
  alias Metamodel.FieldsBuilder
  # defstruct [:TYPE, :name, :email, :admin]

  def generate(schema) when is_map(schema) do
    keys = get_fields_keys(schema)
    glob_type = add_fields(keys, schema)
    generate_schema(keys, glob_type)
  end

  def get_fields_keys(schema) do
    schema |> Map.keys() |> Enum.filter(&(&1 != :type))
  end

  def initialize_glob_type(schema) do
    type_name = Map.get(schema, :type)
    if is_nil(type_name), do: raise("No type name provided")
    GlobTypeBuilder.create(type_name)
  end

  def add_fields(keys, schema) do
    Enum.reduce(keys, initialize_glob_type(schema), &add_field(&1, &2, schema))
  end

  defp add_field(key, glob_type, schema) do
    field = Map.get(schema, key)
    name = to_string(key)
    field = FieldsBuilder.complete_build(field, name)
    GlobTypeBuilder.add_field(glob_type, field)
  end

  defp generate_schema(keys, glob_type) do
    Enum.reduce(keys, Map.put(%{}, :type, glob_type), fn key, generated ->
      field = GlobType.get_field(glob_type, to_string(key))
      Map.put(generated, key, field)
    end)
  end

  def string_field(), do: string_field([])

  def string_field(annotations) do
    FieldsBuilder.build_string("empty", annotations)
  end

  def string_array_field(), do: string_array_field([])

  def string_array_field(annotations) do
    FieldsBuilder.build_string_array("empty", annotations)
  end

  def integer_field(), do: integer_field([])

  def integer_field(annotations) do
    FieldsBuilder.build_integer("empty", annotations)
  end

  def integer_array_field(), do: integer_array_field([])

  def integer_array_field(annotations) do
    FieldsBuilder.build_integer_array("empty", annotations)
  end

  def double_field(), do: double_field([])

  def double_field(annotations) do
    FieldsBuilder.build_double("empty", annotations)
  end

  def double_array_field(), do: double_array_field([])

  def double_array_field(annotations) do
    FieldsBuilder.build_double_array("empty", annotations)
  end

  def boolean_field(), do: boolean_field([])

  def boolean_field(annotations) do
    FieldsBuilder.build_boolean("empty", annotations)
  end

  def boolean_array_field(), do: boolean_array_field([])

  def boolean_array_field(annotations) do
    FieldsBuilder.build_boolean_array("empty", annotations)
  end

  def binary_field(), do: binary_field([])

  def binary_field(annotations) do
    FieldsBuilder.build_binary("empty", annotations)
  end

  def binary_array_field(), do: binary_array_field([])

  def binary_array_field(annotations) do
    FieldsBuilder.build_binary_array("empty", annotations)
  end

  def glob_field(%GlobType{} = glob_type), do: glob_field(glob_type, [])

  def glob_field(%GlobType{} = glob_type, annotations) do
    FieldsBuilder.build_glob("empty", glob_type, annotations)
  end

  def glob_array_field(%GlobType{} = glob_type), do: glob_array_field(glob_type, [])

  def glob_array_field(%GlobType{} = glob_type, annotations) do
    FieldsBuilder.build_glob_array("empty", glob_type, annotations)
  end
end
