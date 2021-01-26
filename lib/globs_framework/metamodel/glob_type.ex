defmodule GlobsFramework.Metamodel.GlobType do
  alias __MODULE__
  alias GlobsFramework.Metamodel.Field
  alias GlobsFramework.Model.Glob

  @moduledoc """
  Has a name and hold fields
  """
  @type t :: %GlobType{
          name: String.t(),
          fields: %{
            String.t() => Field.t()
          },
          annotations: %{String.t() => Glob.t()}
        }
  @enforce_keys [:name]
  defstruct [:name, :fields, :annotations]

  @spec get_name(GlobType.t()) :: String.t()
  def get_name(%GlobType{name: name}) do
    name
  end

  @spec get_fields(GlobType.t()) :: list(Field.t())
  def get_fields(%GlobType{fields: fields}) do
    Map.values(fields)
  end

  @spec get_key_fields(GlobType.t()) :: list(Field.t())
  def get_key_fields(%GlobType{fields: fields}) do
    fields
    |> Map.values()
    |> Enum.filter(fn field -> Field.key?(field) end)
  end

  @spec get_field(GlobType.t(), String.t()) :: Field.t()
  def get_field(%GlobType{fields: fields}, name) do
    Map.get(fields, name, nil)
  end

  @spec instantiate(GlobType.t()) :: GlobsFramework.Model.Glob.t()
  def instantiate(globType) do
    GlobsFramework.Model.Glob.init(globType)
  end
end
