defmodule GlobsFramework.Metamodel.Field do
  @moduledoc """
  Used to hold the type information of a field as well as its name
  """
  alias __MODULE__

  alias GlobsFramework.DataTypes
  alias GlobsFramework.Model.{Glob}
  alias GlobsFramework.Metamodel.{GlobType}

  @type t :: %Field{
          name: String.t(),
          type: atom,
          key_field?: boolean,
          annotations: %{
            String.t() => Glob.t()
          },
          glob_type: GlobType.t()
        }
  defstruct [:name, :type, :key_field?, :annotations, :glob_type]

  @spec check_value(Field.t(), any) :: boolean
  def check_value(%Field{type: type}, value) do
    DataTypes.check_value_type(value, type)
  end

  @spec get_data_type(Field.t()) :: atom()
  def get_data_type(%Field{type: type}) do
    type
  end

  @spec get_name(Field.t()) :: String.t()
  def get_name(%Field{name: name}) do
    name
  end

  @spec key?(Field.t()) :: boolean
  def key?(%Field{key_field?: key_field}) do
    key_field
  end

  @spec get_glob_type(Field.t()) :: GlobType.t() | nil
  def get_glob_type(%Field{glob_type: glob_type}) do
    glob_type
  end

  @spec get_annotations(Field.t()) :: [Glob]
  def get_annotations(%Field{annotations: annotations}) do
    Enum.map(annotations, fn {_, annotation} -> annotation end)
  end
end
