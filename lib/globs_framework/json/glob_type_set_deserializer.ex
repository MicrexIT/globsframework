defmodule GlobsFramework.Json.GlobTypeSetDeserializer do
  @moduledoc """
  Used to serialize globs and glob types to json data
  """
  alias GlobsFramework.Metamodel.{GlobType, GlobTypeResolver, GlobTypeBuilder}
  alias GlobsFramework.Model.{Glob}
  alias GlobsFramework.Json.{Reader, GlobDeserializer}

  @type parsed :: %{
          type_name: map()
        }
  @type state :: %{
          parsed: parsed,
          resolver: GlobTypeResolver.t(),
          targets: list(String.t()),
          partials: GlobTypeResolver.t(),
          deserialized: GlobTypeResolver.t()
        }

  @spec deserialize(list(map()), list(GlobType.t())) :: [GlobType.t()]
  def deserialize(json, glob_types) when is_list(glob_types) do
    resolver = GlobTypeResolver.from(glob_types)
    json |> Jason.decode!() |> compute_state(resolver) |> read()
  end

  @spec deserialize(list(map()), GlobTypeResolver.t()) :: [GlobType.t()]
  def deserialize(json, resolver) do
    json |> Jason.decode!() |> compute_state(resolver) |> read()
  end

  @spec compute_state(parsed :: list(map()), resolver :: GlobTypeResolver.t()) :: state()
  def compute_state(parsed, resolver) do
    parsed =
      Enum.reduce(parsed, %{}, fn element, acc ->
        Map.put(acc, Reader.GlobType.type(element), element)
      end)

    targets = Enum.map(parsed, fn {name, _} -> name end)

    %{
      parsed: parsed,
      resolver: resolver,
      targets: targets,
      partials: GlobTypeResolver.from([]),
      deserialized: GlobTypeResolver.from([])
    }
  end

  def read(%{
        targets: [],
        deserialized: deserialized
      }) do
    GlobTypeResolver.to_list(deserialized)
  end

  @spec read(state :: state()) :: [GlobType.t()]
  def read(%{
        parsed: parsed,
        resolver: resolver,
        targets: [type_name | other_types],
        partials: partials,
        deserialized: deserialized
      }) do
    # Enum.map(types_json, fn inner -> read(inner, resolver, partial_types) end)

    is_type_known = GlobTypeResolver.has(resolver, type_name)
    is_partial = GlobTypeResolver.has(partials, type_name)
    is_deserialized = GlobTypeResolver.has(deserialized, type_name)

    cond do
      is_deserialized ->
        GlobTypeResolver.get(deserialized, type_name)

        read(%{
          parsed: parsed,
          resolver: resolver,
          targets: other_types,
          partials: partials,
          deserialized: deserialized
        })

      is_type_known ->
        glob_type = GlobTypeResolver.get(resolver, type_name)

        read(%{
          parsed: parsed,
          resolver: resolver,
          targets: other_types,
          partials: partials,
          deserialized: GlobTypeResolver.add(deserialized, glob_type)
        })

      is_partial ->
        read(%{
          parsed: parsed,
          resolver: resolver,
          targets: other_types,
          partials: partials,
          deserialized: deserialized
        })

      true ->
        parsed_glob_type = Map.fetch!(parsed, type_name)

        glob_type = GlobTypeBuilder.create(type_name)
        partials = GlobTypeResolver.add(partials, glob_type)

        glob_type =
          read_fields(glob_type, parsed_glob_type, %{
            parsed: parsed,
            resolver: resolver,
            targets: other_types,
            partials: partials,
            deserialized: deserialized
          })

        partials = GlobTypeResolver.remove(partials, type_name)

        read(%{
          parsed: parsed,
          resolver: resolver,
          targets: other_types,
          partials: partials,
          deserialized: GlobTypeResolver.add(deserialized, glob_type)
        })
    end
  end

  @spec read_fields(
          glob_type :: GlobType.t(),
          glob_json :: any(),
          state :: state()
        ) ::
          GlobType.t()
  def read_fields(
        %GlobType{} = glob_type,
        parsed_glob_type,
        state
      ) do
    parsed_fields = Reader.GlobType.fields(parsed_glob_type)

    Enum.reduce(parsed_fields, glob_type, fn parsed_field, acc ->
      write_field_value(parsed_field, acc, state)
    end)
  end

  @spec write_field_value(
          parsed_field :: {String.t(), map},
          glob_type :: GlobType.t(),
          state :: state()
        ) ::
          GlobType.t()
  def write_field_value(
        parsed_field,
        %GlobType{} = glob_type,
        state
      ) do
    # TODO: annotations seems to be excluded from the resolver but inherent to the glob model...
    # json_annotations = Reader.Field.annotations(parsed_field)
    annotations = []

    # annotations =
    #   case json_annotations do
    #     # We are not using the deserialized types to retrieve the annotations
    #     {:ok, annotations} -> GlobDeserializer.read(annotations, state.resolver)
    #     _ -> []
    #   end

    name = Reader.Field.name(parsed_field)
    type = Reader.Field.type(parsed_field)

    case type do
      "glob" ->
        field_glob_type_name = Reader.GlobType.type(parsed_field)

        write_non_primitive_field_value(
          name,
          type,
          annotations,
          field_glob_type_name,
          glob_type,
          state
        )

      "globArray" ->
        field_glob_type_name = Reader.GlobType.type(parsed_field)

        write_non_primitive_field_value(
          name,
          type,
          annotations,
          field_glob_type_name,
          glob_type,
          state
        )

      _ ->
        write_primitive_field_value(name, type, annotations, glob_type)
    end
  end

  @spec write_primitive_field_value(
          field_name :: String.t(),
          field_type :: String.t(),
          annotations :: list(Glob.t()),
          glob_type :: GlobType.t()
        ) ::
          GlobType.t()
  def write_primitive_field_value(
        field_name,
        field_type,
        annotations,
        %GlobType{} = glob_type
      ) do
    field = Reader.Field.create(field_name, field_type, annotations)
    GlobTypeBuilder.add_field(glob_type, field)
  end

  @spec write_non_primitive_field_value(
          field_name :: String.t(),
          field_type :: String.t(),
          annotations :: list(Glob.t()),
          field_glob_type_name :: String.t(),
          glob_type :: GlobType.t(),
          state :: state()
        ) ::
          GlobType.t()
  def write_non_primitive_field_value(
        field_name,
        field_type,
        annotations,
        field_glob_type_name,
        %GlobType{} = glob_type,
        %{
          parsed: parsed,
          resolver: resolver,
          targets: targets,
          partials: partials,
          deserialized: deserialized
        }
      ) do
    is_type_known = GlobTypeResolver.has(resolver, field_glob_type_name)
    is_partial = GlobTypeResolver.has(partials, field_glob_type_name)
    is_deserialized = GlobTypeResolver.has(deserialized, field_glob_type_name)
    is_in_targets = Enum.find(targets, false, fn target -> target == field_glob_type_name end)

    # TODO check if order of conditions is good
    cond do
      is_deserialized ->
        field_glob_type = GlobTypeResolver.get(deserialized, field_glob_type_name)
        field = Reader.Field.create(field_name, field_type, field_glob_type, annotations)
        GlobTypeBuilder.add_field(glob_type, field)

      is_type_known ->
        field_glob_type = GlobTypeResolver.get(resolver, field_glob_type_name)
        field = Reader.Field.create(field_name, field_type, field_glob_type, annotations)
        GlobTypeBuilder.add_field(glob_type, field)

      is_in_targets ->
        # targets = Enum.filter(targets, fn element -> element != field_glob_type_name end)
        glob_types =
          read(%{
            parsed: parsed,
            resolver: resolver,
            targets: targets,
            partials: partials,
            deserialized: deserialized
          })

        resolver = GlobTypeResolver.from(glob_types)
        field_glob_type = GlobTypeResolver.get(resolver, field_glob_type_name)
        field = Reader.Field.create(field_name, field_type, field_glob_type, annotations)
        GlobTypeBuilder.add_field(glob_type, field)

      is_partial ->
        glob_types =
          read(%{
            parsed: parsed,
            resolver: resolver,
            targets: [field_glob_type_name | targets],
            partials: GlobTypeResolver.remove(partials, field_glob_type_name),
            deserialized: deserialized
          })

        resolver = GlobTypeResolver.from(glob_types)
        field_glob_type = GlobTypeResolver.get(resolver, field_glob_type_name)
        field = Reader.Field.create(field_name, field_type, field_glob_type, annotations)
        GlobTypeBuilder.add_field(glob_type, field)

      true ->
        throw(:bad_glob_field_type)
    end
  end
end
