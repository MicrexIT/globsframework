defmodule GlobsFramework.Json.GlobTypeDeserializer do
  @moduledoc """
  Used to serialize globs and glob types to json data
  """
  alias GlobsFramework.Metamodel.{GlobType, GlobTypeResolver, GlobTypeBuilder}
  alias GlobsFramework.Json.{Reader, GlobDeserializer}

  @spec deserialize(any(), list(GlobType.t())) :: GlobType.t()
  def deserialize(json, glob_types) when is_list(glob_types) do
    resolver = GlobTypeResolver.from(glob_types)
    json |> Jason.decode!() |> read(resolver)
  end

  @spec deserialize(any(), GlobTypeResolver.t()) :: GlobType.t()
  def deserialize(json, resolver) do
    json |> Jason.decode!() |> read(resolver)
  end

  @spec read(
          glob_json :: any(),
          resolver :: GlobTypeResolver.t()
        ) :: GlobType.t()
  def read(glob_json, %GlobTypeResolver{} = resolver)
      when is_list(glob_json) do
    Enum.map(glob_json, fn inner -> read(inner, resolver) end)
  end

  def read(glob_json, %GlobTypeResolver{} = resolver) do
    glob_type_name = Reader.GlobType.type(glob_json)

    has_glob_type = GlobTypeResolver.has(resolver, glob_type_name)

    if has_glob_type do
      GlobTypeResolver.get(resolver, glob_type_name)
    else
      glob_type_name
      |> GlobTypeBuilder.create()
      |> read_fields(glob_json, resolver)
    end
  end

  @spec read_fields(
          glob_type :: GlobType.t(),
          glob_json :: any(),
          resolver :: GlobTypeResolver.t()
        ) :: GlobType.t()
  def read_fields(
        %GlobType{} = glob_type,
        glob_json,
        %GlobTypeResolver{} = resolver
      ) do
    IO.inspect("read fields")
    json_fields = Reader.GlobType.fields(glob_json)

    # TODO here we have an array of {name => {...field stuff}} so we need to get array of names and only then do the rest

    Enum.reduce(json_fields, glob_type, fn json_field, acc ->
      write_field_value(json_field, acc, resolver)
    end)
  end

  @spec write_field_value(
          json_field :: map,
          glob_type :: GlobType.t(),
          resolver :: GlobTypeResolver.t()
        ) ::
          GlobType.t()
  def write_field_value(
        json_field,
        %GlobType{} = glob_type,
        %GlobTypeResolver{} = resolver
      ) do
    name = Reader.Field.name(json_field)
    type = Reader.Field.type(json_field)
    json_annotations = Reader.Field.annotations(json_field)

    annotations =
      case json_annotations do
        {:ok, annotations} -> GlobDeserializer.read(annotations, resolver)
        _ -> []
      end

    IO.inspect(annotations, label: "annotations deserialized")

    field = Reader.Field.create(name, type, annotations)
    GlobTypeBuilder.add_field(glob_type, field)
  end
end
