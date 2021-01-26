defmodule GlobsFramework.Json.GlobDeserializer do
  @moduledoc """
  Used to serialize globs and glob types to json data
  """
  alias GlobsFramework.Metamodel.{Field, GlobType, GlobTypeResolver}
  alias GlobsFramework.Model.{Glob, GlobBuilder}
  alias GlobsFramework.Json.{Reader}

  @spec deserialize(any(), GlobTypeResolver.t()) :: Glob.t()
  def deserialize(json, resolver) do
    json |> Jason.decode!() |> read(resolver)
  end

  @spec read(glob_json :: any(), resolver :: GlobTypeResolver.t()) :: Glob.t()
  def read(glob_json, %GlobTypeResolver{} = resolver) when is_list(glob_json) do
    Enum.map(glob_json, fn inner -> read(inner, resolver) end)
  end

  def read(glob_json, %GlobTypeResolver{} = resolver) do
    glob_type_name = Reader.Glob.type(glob_json)

    glob_type = GlobTypeResolver.get(resolver, glob_type_name)

    GlobBuilder.create(glob_type) |> read_fields(glob_json, resolver)
  end

  @spec read(glob_json :: any(), glob_type_name :: String.t(), resolver :: GlobTypeResolver.t()) ::
          Glob.t()
  def read(glob_json, glob_type_name, %GlobTypeResolver{} = resolver) when is_list(glob_json) do
    Enum.map(glob_json, fn inner -> read(inner, glob_type_name, resolver) end)
  end

  def read(glob_json, glob_type_name, %GlobTypeResolver{} = resolver) do
    glob_type = GlobTypeResolver.get(resolver, glob_type_name)
    GlobBuilder.create(glob_type) |> read_fields(glob_json, resolver)
  end

  @spec read_fields(glob :: Glob.t(), glob_json :: any(), resolver :: GlobTypeResolver.t()) ::
          Glob.t()
  def read_fields(%Glob{} = glob, glob_json, %GlobTypeResolver{} = resolver) do
    IO.inspect("reading fields")
    glob_type = Glob.get_glob_type(glob)
    field_names = Enum.map(GlobType.get_fields(glob_type), fn field -> Field.get_name(field) end)

    Enum.reduce(field_names, glob, fn field_name, acc ->
      write_field_value(field_name, acc, glob_json, resolver)
    end)
  end

  @spec write_field_value(
          field_name :: String.t(),
          glob :: Glob.t(),
          glob_json :: any(),
          resolver :: GlobTypeResolver.t()
        ) ::
          Glob.t()
  def write_field_value(field_name, %Glob{} = glob, glob_json, %GlobTypeResolver{} = resolver) do
    glob_type = Glob.get_glob_type(glob)
    field = GlobType.get_field(glob_type, field_name)
    value = get_field_value(field, glob_json, resolver)
    Glob.add(glob, glob_type, field, value)
  end

  @spec get_field_value(
          field :: Field.t(),
          glob_json :: any(),
          resolver :: GlobTypeResolver.t()
        ) :: any()
  def get_field_value(field, glob_json, resolver) do
    field_name = Field.get_name(field)
    value = Map.fetch!(glob_json, field_name)
    IO.inspect(value, label: "current value:")
    field_type = Field.get_data_type(field)
    is_glob_field = field_type == :glob || field_type == :glob_array
    IO.inspect(is_glob_field, label: "is glob field?:")

    if is_glob_field do
      type_name = field |> Field.get_glob_type() |> GlobType.get_name()
      read(value, type_name, resolver)
    else
      value
    end
  end
end
