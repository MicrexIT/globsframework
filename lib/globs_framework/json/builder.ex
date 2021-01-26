defmodule GlobsFramework.Json.Builder do
  alias GlobsFramework.Json.{Mapping, GlobSerializer}
  alias GlobsFramework.Metamodel

  defmodule Glob do
    def create(glob_type_name) do
      key = Mapping.kind_name()

      %{
        key => glob_type_name
      }
    end

    #  TODO: THIS HAPPENS WITH GLOBTYPE, GLOBS ONLY USES THE NAMES OF THE FIELDS
    def add_fields(fields) when is_nil(fields) do
      %{}
    end

    def add_fields(fields) do
      key = Mapping.fields()

      %{
        key => fields
      }
    end
  end

  defmodule GlobType do
    def create(glob_type_name) do
      key = Mapping.type_name()

      %{
        key => glob_type_name
      }
    end

    #  TODO: to be tested if it is the expected behaviour on original java implementation
    def add_fields(fields) when is_nil(fields) do
      %{}
    end

    def add_fields(fields) do
      key = Mapping.fields()

      %{
        key => fields
      }
    end
  end

  defmodule Field do
    @spec create(name :: String.t(), value :: any) :: any
    def create(name, value) do
      %{
        name => value
      }
    end

    @spec add_annotations(json :: any, field :: Metamodel.Field.t()) :: any
    def add_annotations(json, field) do
      key = Mapping.annotations()
      annotations = Metamodel.Field.get_annotations(field)
      IO.inspect(annotations, label: "annotations")

      if Enum.empty?(annotations) do
        json
      else
        serialized_annotations = GlobSerializer.write(annotations)
        IO.inspect(serialized_annotations, label: "builders serialized annotations")
        Map.merge(json, %{key => serialized_annotations})
      end
    end

    @spec add_type(json :: any, field :: Metamodel.Field.t()) :: any
    def add_type(json, field) do
      key = Mapping.field_type()
      Map.merge(json, %{key => Metamodel.Field.get_data_type(field)})
    end

    @spec add_name(json :: any, field :: Metamodel.Field.t()) :: any
    def add_name(json, field) do
      key = Mapping.field_name()
      Map.merge(json, %{key => Metamodel.Field.get_name(field)})
    end

    @spec add_glob_type(json :: any, field :: Metamodel.Field.t()) :: any
    def add_glob_type(json, field) do
      key = Mapping.type_name()
      Map.merge(json, %{key => Metamodel.Field.get_glob_type(field)})
    end
  end
end
