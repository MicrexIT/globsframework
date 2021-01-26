defmodule GlobsFramework.Metamodel.FieldsBuilder do
  @moduledoc """
  Used to create fields
  """
  alias GlobsFramework.Metamodel.{Field, GlobType}
  alias GlobsFramework.Model.Glob
  alias GlobsFramework.Metamodel.Annotations.KeyFieldAnnotation

  @spec complete_build(Field.t(), String.t()) :: Field.t()
  def complete_build(%Field{} = field, name), do: %{field | name: name}

  def complete_build(_, _), do: raise("invalid field to be built")

  @spec build_string(String.t()) :: Field.t()
  def build_string(name), do: build_string(name, [])

  @spec build_string(String.t(), list(Glob.t())) :: Field.t()
  def build_string(name, annotations), do: build_field(:string, name, annotations)

  @spec build_string_array(String.t()) :: Field.t()
  def build_string_array(name), do: build_string_array(name, [])

  @spec build_string_array(String.t(), list(Glob.t())) :: Field.t()
  def build_string_array(name, annotations), do: build_field(:string_array, name, annotations)

  @spec build_boolean(String.t()) :: Field.t()
  def build_boolean(name), do: build_boolean(name, [])

  @spec build_boolean(String.t(), list(Glob.t())) :: Field.t()
  def build_boolean(name, annotations), do: build_field(:boolean, name, annotations)

  @spec build_boolean_array(String.t()) :: Field.t()
  def build_boolean_array(name), do: build_boolean_array(name, [])

  @spec build_boolean_array(String.t(), list(Glob.t())) :: Field.t()
  def build_boolean_array(name, annotations), do: build_field(:boolean_array, name, annotations)

  @spec build_integer(String.t()) :: Field.t()
  def build_integer(name), do: build_integer(name, [])

  @spec build_integer(String.t(), list(Glob.t())) :: Field.t()
  def build_integer(name, annotations), do: build_field(:int, name, annotations)

  @spec build_integer_array(String.t()) :: Field.t()
  def build_integer_array(name), do: build_integer_array(name, [])

  @spec build_integer_array(String.t(), list(Glob.t())) :: Field.t()
  def build_integer_array(name, annotations), do: build_field(:int_array, name, annotations)

  @spec build_double(String.t()) :: Field.t()
  def build_double(name), do: build_double(name, [])

  @spec build_double(String.t(), list(Glob.t())) :: Field.t()
  def build_double(name, annotations), do: build_field(:double, name, annotations)

  @spec build_double_array(String.t()) :: Field.t()
  def build_double_array(name), do: build_double_array(name, [])

  @spec build_double_array(String.t(), list(Glob.t())) :: Field.t()
  def build_double_array(name, annotations), do: build_field(:double_array, name, annotations)

  @spec build_binary(String.t()) :: Field.t()
  def build_binary(name), do: build_binary(name, [])

  @spec build_binary(String.t(), list(Glob.t())) :: Field.t()
  def build_binary(name, annotations), do: build_field(:binary, name, annotations)

  @spec build_binary_array(String.t()) :: Field.t()
  def build_binary_array(name), do: build_binary_array(name, [])

  @spec build_binary_array(String.t(), list(Glob.t())) :: Field.t()
  def build_binary_array(name, annotations), do: build_field(:binary_array, name, annotations)

  @spec build_glob(String.t(), GlobType.t()) :: Field.t()
  def build_glob(name, glob_type), do: build_glob(name, glob_type, [])

  @spec build_glob(String.t(), GlobType.t(), list(Glob.t())) :: Field.t()
  def build_glob(name, glob_type, annotations),
    do: build_field(:glob, name, annotations, glob_type)

  @spec build_glob_array(String.t(), GlobType.t()) :: Field.t()
  def build_glob_array(name, glob_type) do
    build_glob_array(name, glob_type, [])
  end

  @spec build_glob_array(String.t(), GlobType.t(), list(Glob.t())) :: Field.t()
  def build_glob_array(name, glob_type, annotations),
    do: build_field(:glob_array, name, annotations, glob_type)

  @spec build_field(atom, String.t(), list(Glob.t())) :: Field.t()
  defp build_field(type, name, annotations), do: build_field(type, name, annotations, nil)

  @spec build_field(atom, String.t(), list(Glob.t()), GlobType.t() | nil) :: Field.t()
  defp build_field(type, name, annotations, glob_type) do
    annotations = set_annotations(annotations)

    %Field{
      name: name,
      type: type,
      key_field?: has_key_annotation?(annotations),
      annotations: annotations,
      glob_type: glob_type
    }
  end

  @spec has_key_annotation?(%{String.t() => Glob.t()}) :: boolean
  def has_key_annotation?(annotations) do
    Map.has_key?(annotations, KeyFieldAnnotation.unique_key())
  end

  defp set_annotations(annotations) do
    annotations
    |> Enum.reduce(%{}, fn item, acc -> set_in_map(item, acc) end)
  end

  defp set_in_map(annotation, annotationMap) do
    Map.put(annotationMap, Glob.get_key(annotation), annotation)
  end
end
