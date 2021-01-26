defmodule GlobsFramework.Json.Reader do
  @moduledoc """
  Used to serialize globs and glob types to json data
  """
  alias GlobsFramework.Json.Mapping

  defmodule Glob do
    def type(json_glob) do
      Map.fetch!(json_glob, Mapping.kind_name())
    end

    def is_glob(json_glob) when is_map(json_glob) do
      Map.has_key?(json_glob, Mapping.kind_name())
    end

    def is_glob(_), do: false
  end

  defmodule GlobType do
    def type(json_glob_type) do
      Map.fetch!(json_glob_type, Mapping.glob_type_kind())
    end

    def fields(json_glob_type) do
      if Map.has_key?(json_glob_type, Mapping.fields()) do
        Map.fetch!(json_glob_type, Mapping.fields())
      else
        []
      end
    end
  end

  defmodule Field do
    def name(parsed) do
      Map.fetch!(parsed, Mapping.field_name())
    end

    def type(parsed) do
      Map.fetch!(parsed, Mapping.field_type())
    end

    def annotations(parsed) do
      Map.fetch(parsed, Mapping.annotations())
    end

    def create(name, type) do
      create(name, type, [])
    end

    def create(name, type, annotations) do
      Mapping.decode_field(name, type, annotations)
    end

    def create(name, type, glob_type, annotations) do
      Mapping.decode_advanced_field(name, type, glob_type, annotations)
    end
  end
end
