defmodule GlobsFramework.Metamodel.GlobType do
  @doc """
  Shapes the structure of some data (glob) through holding fields that maps to
  data types as well as a meta information and the ability to instantiate a glob
  """
  @enforce_keys [:name]
  defstruct [:name, fields: %{}]
  alias GlobsFramework.Metamodel.GlobType

  def getName(%GlobType{name: name}) do
    name
  end

  def getFields(%GlobType{fields: fields}) do
    fields
  end

  def getField(%GlobType{fields: fields}, :name) do
    Map.get(fields, :name, nil)
  end

  def addField(%GlobType{fields: fields}, field) do
    # todo: test with duplicate
    {name} = field
    Map.put(fields, name, field)
  end
end
