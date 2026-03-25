defmodule HL7v2.Type.NA do
  @moduledoc """
  Numeric Array (NA) -- HL7v2 composite data type.

  Contains a variable number of numeric (NM) values. Used in OBX for
  waveform data (single-channel numeric arrays).

  Variable components (4+ per HL7 spec):
  1. Value 1 (NM)
  2. Value 2 (NM)
  3. Value 3 (NM)
  4. Value 4 (NM)
  ... additional values as needed
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct values: []

  @type t :: %__MODULE__{
          values: [binary()]
        }

  @doc """
  Parses an NA from a list of components.

  All components are stored as a list of string values.

  ## Examples

      iex> HL7v2.Type.NA.parse(["10", "20", "30", "40"])
      %HL7v2.Type.NA{values: ["10", "20", "30", "40"]}

      iex> HL7v2.Type.NA.parse(["100"])
      %HL7v2.Type.NA{values: ["100"]}

      iex> HL7v2.Type.NA.parse([])
      %HL7v2.Type.NA{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    vals =
      components
      |> Enum.map(&Type.get_component([&1], 0))
      |> Enum.reject(&is_nil/1)

    %__MODULE__{values: vals}
  end

  @doc """
  Encodes an NA to a list of component strings.

  ## Examples

      iex> HL7v2.Type.NA.encode(%HL7v2.Type.NA{values: ["10", "20", "30", "40"]})
      ["10", "20", "30", "40"]

      iex> HL7v2.Type.NA.encode(%HL7v2.Type.NA{})
      []

      iex> HL7v2.Type.NA.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []
  def encode(%__MODULE__{values: []}), do: []
  def encode(%__MODULE__{values: vals}), do: vals
end
