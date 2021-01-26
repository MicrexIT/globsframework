defmodule GlobsFramework.Metamodel.GlobTypeResolver do
  alias __MODULE__
  alias GlobsFramework.Metamodel.{GlobType}

  @moduledoc """
  Holds glob types
  """
  @type t :: %GlobTypeResolver{
          glob_types: %{
            String.t() => GlobType.t()
          }
        }
  defstruct [:glob_types]

  @spec get(GlobTypeResolver.t()) :: [GlobType]
  def get(%GlobTypeResolver{glob_types: glob_types}) do
    Enum.map(glob_types, fn {_, val} -> val end)
  end

  @spec get(GlobsFramework.Metamodel.GlobTypeResolver.t(), name :: String.t()) :: GlobType.t()
  def get(%GlobTypeResolver{glob_types: glob_types}, name) do
    Map.fetch!(glob_types, name)
  end

  @spec has(GlobsFramework.Metamodel.GlobTypeResolver.t(), name :: String.t()) :: boolean()
  def has(%GlobTypeResolver{glob_types: glob_types}, name) do
    Map.has_key?(glob_types, name)
  end

  def add(%GlobTypeResolver{} = resolver, %GlobType{} = glob_type) do
    name = GlobType.get_name(glob_type)
    glob_types = Map.put(resolver.glob_types, name, glob_type)
    Map.put(resolver, :glob_types, glob_types)
  end

  def remove(%GlobTypeResolver{glob_types: glob_types} = resolver, name) do
    Map.put(resolver, :glob_types, Map.drop(glob_types, [name]))
  end

  @spec from(list(GlobType.t())) :: GlobTypeResolver.t()
  def from(glob_types) when is_list(glob_types) do
    %GlobTypeResolver{
      glob_types:
        Enum.reduce(glob_types, %{}, fn glob_type, acc ->
          Map.put(acc, GlobType.get_name(glob_type), glob_type)
        end)
    }
  end

  @spec to_list(GlobTypeResolver.t()) :: list(GlobType.t())
  def to_list(%GlobTypeResolver{} = resolver) do
    Enum.map(resolver.glob_types, fn {_, value} -> value end)
  end

  @spec types(GlobTypeResolver.t()) :: list(GlobType.t())
  def types(%GlobTypeResolver{} = resolver) do
    Enum.map(resolver.glob_types, fn {name, _} -> name end)
  end
end
