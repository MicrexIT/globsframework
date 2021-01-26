defmodule GlobsFramework.DataTypes do
  @moduledoc """
  Exposes functions to check that a value conforms to any type
  """
  @spec check_value_type(any, atom) :: boolean()
  def check_value_type(val, :string), do: string?(val)
  def check_value_type(val, :string_array), do: string_array?(val)
  def check_value_type(val, :int), do: int?(val)
  def check_value_type(val, :int_array), do: integer_array?(val)
  def check_value_type(val, :double), do: double?(val)
  def check_value_type(val, :double_array), do: double_array?(val)
  def check_value_type(val, :binary), do: binary?(val)
  def check_value_type(val, :binary_array), do: binary_array?(val)
  def check_value_type(val, :boolean), do: boolean?(val)
  def check_value_type(val, :boolean_array), do: boolean_array?(val)
  def check_value_type(val, :glob), do: glob?(val)
  def check_value_type(val, :glob_array), do: glob_array?(val)
  def check_value_type(_, _), do: false

  @spec typeof(any) :: atom
  def typeof(val) when is_bitstring(val), do: :string
  def typeof(val) when is_integer(val), do: :int
  def typeof(val) when is_float(val), do: :double
  def typeof(val) when is_boolean(val), do: :boolean
  def typeof(val) when is_binary(val), do: :binary
  def typeof(val) when is_struct(val, GlobsFramework.Model.Glob), do: :glob
  def typeof(val) when is_list(val), do: typeof_array(val)
  def typeof(_), do: :unknown

  @spec typeof_array(list()) :: atom
  def typeof_array(val), do: typeof_array_recursion(val)

  @spec string?(any) :: boolean
  def string?(val), do: typeof(val) == :string

  @spec string_array?(any) :: boolean
  def string_array?(val), do: empty_or_verify_arr(val, :string_array)

  @spec int?(any) :: boolean
  def int?(val), do: typeof(val) == :int

  @spec integer_array?(any) :: boolean
  def integer_array?(val), do: empty_or_verify_arr(val, :int_array)

  @spec double?(any) :: boolean
  def double?(val), do: typeof(val) == :double

  @spec double_array?(any) :: boolean
  def double_array?(val), do: empty_or_verify_arr(val, :double_array)

  @spec boolean?(any) :: boolean
  def boolean?(val), do: typeof(val) == :boolean

  @spec boolean_array?(any) :: boolean
  def boolean_array?(val), do: empty_or_verify_arr(val, :boolean_array)

  @spec binary?(any) :: boolean
  def binary?(val), do: typeof(val) == :binary

  @spec binary_array?(any) :: boolean
  def binary_array?(val), do: empty_or_verify_arr(val, :binary_array)

  @spec glob?(any) :: boolean
  def glob?(val), do: typeof(val) == :glob

  @spec glob_array?(any) :: boolean
  def glob_array?(val), do: empty_or_verify_arr(val, :glob_array)

  @spec empty_or_verify_arr(any, atom) :: boolean
  defp empty_or_verify_arr(val, type) do
    if empty_list?(val) do
      true
    else
      typeof(val) == type
    end
  end

  @spec empty_list?(any) :: boolean()
  defp empty_list?(val), do: val == []

  @spec typeof_array_recursion(nonempty_list()) :: atom
  defp typeof_array_recursion([head | tail]) do
    typeof_array_recursion(tail, typeof(head))
  end

  @spec typeof_array_recursion(list, atom) :: atom
  defp typeof_array_recursion([head | tail], previous_type) do
    current_type = typeof(head)

    cond do
      current_type != previous_type -> :mixed_array
      :else -> typeof_array_recursion(tail, current_type)
    end
  end

  defp typeof_array_recursion([], previous_type), do: :"#{previous_type}_array"
end
