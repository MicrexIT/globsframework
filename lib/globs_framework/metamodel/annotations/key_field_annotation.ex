defmodule GlobsFramework.Metamodel.Annotations.KeyFieldAnnotation do
  @moduledoc """
  Annotation signaling a key field
  """
  alias __MODULE__
  alias GlobsFramework.Metamodel.{GlobTypeBuilder, GlobType, Key}
  alias GlobsFramework.Model.{Glob}

  @type t :: %KeyFieldAnnotation{
          name: String.t(),
          glob_type: GlobType.t(),
          key: String.t()
        }
  defstruct [:name, :glob_type, :key]

  @spec get() :: KeyFieldAnnotation.t()
  def get(), do: init()

  @spec instance() :: Glob.t()
  def instance() do
    %KeyFieldAnnotation{glob_type: glob_type} = init()
    GlobType.instantiate(glob_type)
  end

  @spec unique_key() :: String.t()
  def unique_key() do
    %KeyFieldAnnotation{key: key} = init()
    key
  end

  @spec get_glob_type() :: GlobType.t()
  def get_glob_type() do
    %KeyFieldAnnotation{glob_type: glob_type} = init()
    glob_type
  end

  defp init() do
    name = "key_field_annotation"
    glob_type = GlobTypeBuilder.create(name)
    key = Key.build(glob_type)

    %KeyFieldAnnotation{
      name: name,
      glob_type: glob_type,
      key: key
    }
  end
end
