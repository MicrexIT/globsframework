defmodule GlobsFramework.Json.Mapping do
  import GlobsFramework.Metamodel.FieldsBuilder

  @field_decoder %{
    "string" => &build_string/2,
    "stringArray" => &build_string_array/2,
    "boolean" => &build_boolean/2,
    "booleanArray" => &build_boolean_array/2,
    "int" => &build_integer/2,
    "intArray" => &build_integer_array/2,
    "double" => &build_double/2,
    "doubleArray" => &build_double_array/2,
    "binary" => &build_binary/2,
    "binaryArray" => &build_binary_array/2,
    "glob" => &build_glob/3,
    "globArray" => &build_glob_array/3
  }
  def decode_field(name, type), do: decode_field(name, type, [])

  def decode_field(name, type, annotations) do
    Map.fetch!(@field_decoder, type).(name, annotations)
  end

  def decode_advanced_field(name, type, glob_type),
    do: decode_advanced_field(name, type, glob_type, [])

  def decode_advanced_field(name, type, glob_type, annotations) do
    Map.fetch!(@field_decoder, type).(name, glob_type, annotations)
  end

  def kind_name(), do: "_kind"
  def type_name(), do: "kind"
  def fields(), do: "fields"
  def field_type(), do: "type"
  def field_name(), do: "name"
  def annotations(), do: "annotations"
  def glob_type_kind(), do: "kind"
end
