defmodule GlobsFramework.Json.GlobSerializer do
  @moduledoc """
  Used to serialize globs and glob types to json data
  """
  alias GlobsFramework.Metamodel.{GlobType, Field}
  alias GlobsFramework.Model.Glob
  alias GlobsFramework.Json.Builder

  @spec serialize(Glob.t()) :: binary
  @spec serialize(list(Glob.t())) :: binary
  def serialize(%Glob{} = glob) do
    glob |> write() |> Jason.encode!()
  end

  def serialize(globs) when is_list(globs) do
    globs |> write() |> Jason.encode!()
  end

  @spec write(glob :: Glob.t()) :: any
  def write(%Glob{} = glob) do
    glob_type = Glob.get_glob_type(glob)
    glob_type_name = GlobType.get_name(glob_type)
    json_glob = Builder.Glob.create(glob_type_name)
    build_glob_json(json_glob, glob)
  end

  @spec write(globs :: list(Glob.t())) :: any
  def write(globs) when is_list(globs) do
    Enum.map(globs, fn glob -> write(glob) end)
  end

  @spec build_glob_json(json_glob :: any(), glob :: Glob.t()) :: any
  def build_glob_json(json_glob, %Glob{} = glob) do
    fields = glob |> build_glob_json_fields()
    Map.merge(json_glob, fields)
  end

  # Used for inner globs
  @spec build_glob_array_json(globs :: nonempty_list(Glob.t())) :: any
  def build_glob_array_json(globs) do
    Enum.map(globs, fn glob -> build_glob_json(%{}, glob) end)
  end

  @spec build_glob_json_fields(glob :: Glob.t()) :: any
  def build_glob_json_fields(%Glob{} = glob) do
    glob
    |> Glob.get_glob_type()
    |> GlobType.get_fields()
    |> reduce_glob_json_fields(glob)
  end

  @spec reduce_glob_json_fields(fields :: list(Field.t()), glob :: Glob.t()) :: any
  def reduce_glob_json_fields(fields, %Glob{} = glob) do
    Enum.reduce(fields, %{}, fn field, acc ->
      Map.put(acc, Field.get_name(field), build_glob_json_field(field, glob))
    end)
  end

  @spec build_glob_json_field(field :: Field.t(), glob :: Glob.t()) :: any
  def build_glob_json_field(%Field{} = field, %Glob{} = glob) do
    case Field.get_data_type(field) do
      :glob -> build_glob(field, glob)
      :glob_array -> build_glob_array(field, glob)
      _ -> build_simple(field, glob)
    end
  end

  @spec build_simple(field :: Field.t(), glob :: Glob.t()) :: any
  def build_simple(field, glob) do
    Glob.get_value(glob, field)
  end

  @spec build_glob(field :: Field.t(), glob :: Glob.t()) :: any
  def build_glob(field, %Glob{} = glob) do
    glob_field = Glob.get_value(glob, field)
    build_glob_json(%{}, glob_field)
  end

  @spec build_glob_array(field :: Field.t(), glob :: Glob.t()) :: any
  def build_glob_array(field, %Glob{} = glob) do
    globs_field = Glob.get_value(glob, field)
    build_glob_array_json(globs_field)
  end
end
