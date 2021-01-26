defmodule GlobsFramework.Metamodel.Key do
  @moduledoc """
  Builds a GlobType or a Glob key
  """
  alias __MODULE__
  alias GlobsFramework.Metamodel.GlobType
  alias GlobsFramework.Metamodel.Field
  alias GlobsFramework.Model.Glob

  @spec build(GlobType.t()) :: String.t()
  def build(%GlobType{} = glob_type) do
    fields = GlobType.get_key_fields(glob_type)

    Enum.reduce(
      fields,
      "glob_type:#{GlobType.get_name(glob_type)}",
      fn field, acc -> "#{acc},#{Field.get_name(field)}" end
    )
  end

  @spec build(Glob.t()) :: String.t()
  def build(%Glob{} = glob) do
    glob_type = Glob.get_glob_type(glob)
    key = Key.build(glob_type)
    values = GlobType.get_key_fields(glob_type)

    Enum.reduce(
      values,
      key,
      fn field, acc -> "#{acc},#{Glob.get_value(glob, field)}" end
    )
  end
end
