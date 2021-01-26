defmodule GlobsFramework.Model.Glob do
  @moduledoc """
  Instance of a glob type holding data that can be read using the corresponding glob type fields
  and annotations
  """
  alias __MODULE__
  alias GlobsFramework.Metamodel.{GlobType, Field, Key}

  @type t :: %Glob{
          glob_type: GlobType.t(),
          field_values: %{
            String.t() => any
          }
        }

  defstruct [:glob_type, :field_values]

  @spec get_glob_type(Glob.t()) :: any
  def get_glob_type(%Glob{glob_type: glob_type}) do
    glob_type
  end

  @spec init(GlobType.t()) :: Glob.t()
  def init(%GlobType{} = glob_type) do
    %Glob{glob_type: glob_type, field_values: %{}}
  end

  @spec add(
          Glob.t(),
          GlobType.t(),
          Field.t(),
          any
        ) :: Glob.t()
  def add(%Glob{} = glob, %GlobType{} = glob_type, %Field{} = field, value) do
    field_values = get_field_values(glob)

    cond do
      Field.check_value(field, value) ->
        %Glob{
          glob_type: glob_type,
          field_values: Map.put(field_values, Field.get_name(field), value)
        }

      :else ->
        glob
    end
  end

  @spec get_value(Glob.t(), Field.t()) :: any
  def get_value(%Glob{field_values: field_values}, field) do
    name = Field.get_name(field)
    Map.get(field_values, name)
  end

  @spec get_values(Glob.t()) :: list(any)
  def get_values(%Glob{field_values: field_values}) do
    Map.values(field_values)
  end

  @spec get_field_values(Glob.t()) :: any
  def get_field_values(%Glob{field_values: field_values}) do
    field_values
  end

  @spec get_key(Glob.t()) :: String.t()
  def get_key(%Glob{} = glob), do: Key.build(glob)
end
