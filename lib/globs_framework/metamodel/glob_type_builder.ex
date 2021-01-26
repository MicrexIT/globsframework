defmodule GlobsFramework.Metamodel.GlobTypeBuilder do
  @moduledoc """
  Used to create and add fields to a glob type
  """
  alias GlobsFramework.Metamodel.GlobType
  alias GlobsFramework.Metamodel.Field
  @spec add_field(GlobType.t(), Field.t()) :: GlobType.t()
  def add_field(%GlobType{fields: fields} = glob_type, field) do
    %GlobType{glob_type | fields: Map.put(fields, Field.get_name(field), field)}
  end

  @spec create(String.t()) :: GlobType.t()
  def create(name) do
    %GlobType{name: name, fields: %{}, annotations: %{}}
  end
end
