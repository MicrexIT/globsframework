defmodule GlobsFramework.Model.GlobBuilder do
  @moduledoc """
  Used to build a glob
  """
  alias GlobsFramework.Model.Glob

  @spec create(any) :: Glob.t()
  def create(glob_type) do
    %Glob{glob_type: glob_type, field_values: %{}}
  end
end
