defmodule GlobsFramework.DataTypesTest do
  @moduledoc false
  use ExUnit.Case
  alias GlobsFramework.DataTypes

  test "should correctly identify a string with string?" do
    assert DataTypes.string?("string")
  end

  test "should correctly identify a string" do
    assert DataTypes.check_value_type("random value", :string)
  end

  test "should correctly identify an int" do
    assert DataTypes.check_value_type(123, :int)
  end

  test "should correctly identify a double" do
    assert DataTypes.check_value_type(123.1233, :double)
  end

  test "should correctly identify a boolean" do
    assert DataTypes.check_value_type(true, :boolean)
  end

  test "should correctly identify a string array" do
    assert DataTypes.check_value_type(
             ["string", "string2"],
             :string_array
           )
  end

  test "should correctly identify an int array" do
    assert DataTypes.check_value_type(
             [1, 2, 4, 10],
             :int_array
           )
  end

  test "should correctly identify a double array" do
    assert DataTypes.check_value_type(
             [1.231, 1.234],
             :double_array
           )
  end

  test "should correctly identify a mixed array" do
    assert DataTypes.typeof([123, "string", 1.234]) ==
             :mixed_array

    assert DataTypes.typeof([123, 1.234]) ==
             :mixed_array
  end
end
