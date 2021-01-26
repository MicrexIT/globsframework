defmodule GlobsFramework.Metamodel.Field do
  @doc """
  Holds the data-structure information for a globType's field
  """
  defstruct [:name, :type, :globType]
  alias GlobsFramework.DataTypes.DataType
  alias GlobsFramework.Metamodel.Field

  @spec checkValue(%Field{}, any) :: boolean
  def checkValue(%Field{type: type}, value) do
    DataType.check_value_type(value, type)
  end

  # use Agent

  # def start_link(%{name: name, type: type, ref: globTypePid}) do
  #   Agent.start_link(fn -> %{name: name, type: type, ref: globTypePid} end)
  # end

  # def get(pid, :name) do
  #   Agent.get(pid, fn %{name: name} -> name end)
  # end

  # def get(pid, :type) do
  #   Agent.get(pid, fn %{type: type} -> type end)
  # end

  # def get(pid) do
  #   Agent.get(pid, fn state -> state end)
  # end
end
