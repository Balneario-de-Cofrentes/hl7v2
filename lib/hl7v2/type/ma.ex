defmodule HL7v2.Type.MA do
  @moduledoc """
  Multiplexed Array (MA) -- HL7v2 composite data type.

  Contains a variable number of numeric (NM) sample values from multiple
  waveform channels. Used in OBX for waveform data transmission.

  Variable components (4+ per HL7 spec):
  1. Sample Y From Channel 1 (NM)
  2. Sample Y From Channel 2 (NM)
  3. Sample Y From Channel 3 (NM)
  4. Sample Y From Channel 4 (NM)
  ... additional channels as needed
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct values: []

  @type t :: %__MODULE__{
          values: [binary()]
        }

  @doc """
  Parses an MA from a list of components.

  All components are stored as a list of string values.

  ## Examples

      iex> HL7v2.Type.MA.parse(["1.2", "3.4", "5.6"])
      %HL7v2.Type.MA{values: ["1.2", "3.4", "5.6"]}

      iex> HL7v2.Type.MA.parse(["100"])
      %HL7v2.Type.MA{values: ["100"]}

      iex> HL7v2.Type.MA.parse([])
      %HL7v2.Type.MA{}

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
  Encodes an MA to a list of component strings.

  ## Examples

      iex> HL7v2.Type.MA.encode(%HL7v2.Type.MA{values: ["1.2", "3.4", "5.6"]})
      ["1.2", "3.4", "5.6"]

      iex> HL7v2.Type.MA.encode(%HL7v2.Type.MA{})
      []

      iex> HL7v2.Type.MA.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []
  def encode(%__MODULE__{values: []}), do: []
  def encode(%__MODULE__{values: vals}), do: vals
end
