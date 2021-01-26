defmodule GlobsFramework.DataTypes.DataType do
  @doc """
  Exposes functions to check that a value conforms to any type
  """
  alias GlobsFramework.DataTypes.Names

  @spec check_value_type(any, String.t()) :: boolean()
  def check_value_type(val, type) do
    cond do
      type == Names._string() -> string?(val)
      type == Names._string_array() -> string_array?(val)
      type == Names._integer() -> integer?(val)
      type == Names._integer_array() -> integer_array?(val)
      type == Names._float() -> float?(val)
      type == Names._float_array() -> float_array?(val)
      type == Names._boolean() -> boolean?(val)
      type == Names._boolean_array() -> boolean_array?(val)
      type == Names._binary() -> binary?(val)
      type == Names._binary_array() -> binary_array?(val)
      :else -> false
    end
  end

  @spec typeof(any) :: String.t()
  def typeof(val) do
    cond do
      is_bitstring(val) -> Names._string()
      is_integer(val) -> Names._integer()
      is_float(val) -> Names._float()
      is_number(val) -> Names._number()
      is_boolean(val) -> Names._boolean()
      is_binary(val) -> Names._binary()
      is_list(val) -> typeof_array(val)
      true -> "unknown"
    end
  end

  @spec typeof_array(list()) :: String.t()
  def typeof_array(val), do: typeof_array_recursion(val, nil)

  @spec number?(any) :: boolean()
  def number?(val), do: typeof(val) == Names._number()

  @spec number_array?(any) :: boolean()
  def number_array?(val), do: empty_or_verify_arr(val, Names._number())

  @spec string?(any) :: boolean
  def string?(val), do: typeof(val) == Names._string()

  @spec string_array?(any) :: boolean
  def string_array?(val), do: empty_or_verify_arr(val, Names._string())

  @spec integer?(any) :: boolean
  def integer?(val), do: typeof(val) == Names._integer()

  @spec integer_array?(any) :: boolean
  def integer_array?(val), do: empty_or_verify_arr(val, Names._integer())

  @spec float?(any) :: boolean
  def float?(val), do: typeof(val) == Names._float()

  @spec float_array?(any) :: boolean
  def float_array?(val), do: empty_or_verify_arr(val, Names._float())

  @spec boolean?(any) :: boolean
  def boolean?(val), do: typeof(val) == Names._boolean()

  @spec boolean_array?(any) :: boolean
  def boolean_array?(val), do: empty_or_verify_arr(val, Names._boolean())

  @spec binary?(any) :: boolean
  def binary?(val), do: typeof(val) == Names._binary()

  @spec binary_array?(any) :: boolean
  def binary_array?(val), do: empty_or_verify_arr(val, Names._binary())

  @spec empty_or_verify_arr(any, String.t()) :: boolean
  defp empty_or_verify_arr(val, primitive_type) do
    if empty_list?(val) do
      true
    else
      typeof(val) == Names.with_array(primitive_type)
    end
  end

  @spec empty_list?(any) :: boolean()
  defp empty_list?(val), do: val == []

  @spec typeof_array_recursion(list, String.t() | nil) :: String.t()
  defp typeof_array_recursion([head | tail], previous_type) do
    current_type = typeof(head)

    cond do
      previous_type == nil && current_type != nil -> typeof_array_recursion(tail, current_type)
      current_type != previous_type -> Names._mixte_array()
      :else -> typeof_array_recursion(tail, current_type)
    end
  end

  defp typeof_array_recursion([], previous_type), do: Names.with_array(previous_type)
end

defmodule GlobsFramework.DataTypes.Names do
  @doc """
  Holds the supported data types names for consistent access
  """
  @spec _string() :: String.t()
  def _string, do: "string"

  @spec _string_array :: String.t()
  def _string_array, do: with_array(_string())

  @spec _float :: String.t()
  def _float, do: "float"

  @spec _float_array :: String.t()
  def _float_array, do: with_array(_float())

  @spec _integer :: String.t()
  def _integer, do: "integer"

  @spec _integer_array :: String.t()
  def _integer_array, do: with_array(_integer())

  @spec _number :: String.t()
  def _number, do: "number"

  @spec _number_array :: String.t()
  def _number_array, do: with_array(_number())

  @spec _binary :: String.t()
  def _binary, do: "binary"

  @spec _binary_array :: String.t()
  def _binary_array, do: with_array(_binary())

  @spec _boolean :: String.t()
  def _boolean, do: "boolean"

  @spec _boolean_array :: String.t()
  def _boolean_array, do: with_array(_boolean())

  @spec _unknown :: String.t()
  def _unknown, do: "unknown"

  @spec _unknown_array :: String.t()
  def _unknown_array, do: with_array(_unknown())

  @spec _mixte :: String.t()
  def _mixte, do: "mixte"

  @spec _mixte_array :: String.t()
  def _mixte_array, do: with_array(_mixte())

  @spec with_array(any) :: String.t()
  def with_array(text) do
    "#{text}-array"
  end
end
