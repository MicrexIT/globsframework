defmodule GlobsFramework.Json.GlobTypeSerializer do
  @moduledoc """
  Used to serialize globs and glob types to json data
  """
  alias GlobsFramework.Metamodel.{GlobType, Field}
  alias GlobsFramework.Json.{Builder}

  @spec serialize(GlobType.t()) :: binary
  def serialize(%GlobType{} = glob_type) do
    glob_type |> write() |> Jason.encode!()
  end

  def serialize(glob_types) when is_list(glob_types) do
    glob_types |> write() |> Jason.encode!()
  end

  @spec write(glob_type :: GlobType.t()) :: any
  def write(%GlobType{} = glob_type) do
    glob_type_name = GlobType.get_name(glob_type)
    json_glob_type = Builder.GlobType.create(glob_type_name)
    build_glob_type_json(json_glob_type, glob_type)
  end

  @spec write(glob_types :: nonempty_list(GlobType.t())) :: any
  def write(glob_types) when is_list(glob_types) do
    Enum.map(glob_types, fn glob_type -> write(glob_type) end)
  end

  @spec build_glob_type_json(json_glob_type :: any(), glob_type :: GlobType.t()) :: any
  def build_glob_type_json(json_glob_type, %GlobType{} = glob_type) do
    fields = glob_type |> build_glob_json_fields() |> Builder.GlobType.add_fields()
    Map.merge(json_glob_type, fields)
  end

  @spec build_glob_array_json(glob_types :: nonempty_list(GlobType.t())) :: any
  def build_glob_array_json(glob_types) do
    Enum.map(glob_types, fn glob_type -> build_glob_type_json(%{}, glob_type) end)
  end

  @spec build_glob_json_fields(glob_type :: GlobType.t()) :: any
  def build_glob_json_fields(%GlobType{} = glob_type) do
    glob_type
    |> GlobType.get_fields()
    |> reduce_glob_type_json_fields()
  end

  @spec reduce_glob_type_json_fields(fields :: list(Field.t())) :: any
  def reduce_glob_type_json_fields(fields) do
    Enum.map(fields, fn field ->
      build_glob_type_json_field(field)
    end)
  end

  @spec build_glob_type_json_field(field :: Field.t()) :: any
  def build_glob_type_json_field(%Field{} = field) do
    field_json =
      %{}
      |> Builder.Field.add_name(field)
      |> Builder.Field.add_type(field)
      |> Builder.Field.add_annotations(field)

    case Field.get_data_type(field) do
      :glob -> Builder.Field.add_glob_type(field_json, field)
      :glob_array -> Builder.Field.add_glob_type(field_json, field)
      _ -> field_json
    end
  end
end
