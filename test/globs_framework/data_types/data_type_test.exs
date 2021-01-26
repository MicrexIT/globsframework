defmodule GlobsFramework.DataTypes.DataTypeTest do
  use ExUnit.Case
  alias GlobsFramework.DataTypes.DataType
  alias GlobsFramework.DataTypes.Names

  test "should correctly identify a string with string?" do
    assert DataType.string?("string")
  end

  test "should correctly identify a string" do
    assert DataType.check_value_type("random value", Names._string())
  end

  test "should correctly identify an integer" do
    assert DataType.check_value_type(123, Names._integer())
  end

  test "should correctly identify a float" do
    assert DataType.check_value_type(123.1233, Names._float())
  end

  test "should correctly identify a boolean" do
    assert DataType.check_value_type(true, Names._boolean())
  end

  test "should correctly identify a string array" do
    assert DataType.check_value_type(
             ["string", "string2"],
             Names._string_array()
           )
  end

  test "should correctly identify an integer array" do
    assert DataType.check_value_type(
             [1, 2, 4, 10],
             Names._integer_array()
           )
  end

  test "should correctly identify a float array" do
    assert DataType.check_value_type(
             [1.231, 1.234],
             Names._float_array()
           )
  end

  test "should correctly identify a mixte array" do
    assert DataType.typeof([123, "string", 1.234]) ==
             Names._mixte_array()

    assert DataType.typeof([123, 1.234]) ==
             Names._mixte_array()
  end
end
