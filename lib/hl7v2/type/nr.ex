defmodule HL7v2.Type.NR do
  @moduledoc """
  Numeric Range (NR) -- HL7v2 composite data type.

  Two components: low value and high value, both NM type.
  Specifies an interval between lowest and highest values.
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.NM

  defstruct [:low, :high]

  @type t :: %__MODULE__{
          low: binary() | nil,
          high: binary() | nil
        }

  @doc """
  Parses a numeric range from a list of components.

  ## Examples

      iex> HL7v2.Type.NR.parse(["2.5", "10.0"])
      %HL7v2.Type.NR{low: "2.5", high: "10"}

      iex> HL7v2.Type.NR.parse(["", "100"])
      %HL7v2.Type.NR{low: nil, high: "100"}

      iex> HL7v2.Type.NR.parse([])
      %HL7v2.Type.NR{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      low: components |> Type.get_component(0) |> NM.parse(),
      high: components |> Type.get_component(1) |> NM.parse()
    }
  end

  @doc """
  Encodes a numeric range to a list of component strings.

  ## Examples

      iex> HL7v2.Type.NR.encode(%HL7v2.Type.NR{low: "2.5", high: "10"})
      ["2.5", "10"]

      iex> HL7v2.Type.NR.encode(%HL7v2.Type.NR{})
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = nr) do
    [NM.encode(nr.low), NM.encode(nr.high)]
    |> Type.trim_trailing()
  end
end
