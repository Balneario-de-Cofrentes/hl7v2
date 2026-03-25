defmodule HL7v2.Type.WVS do
  @moduledoc """
  Waveform Source (WVS) -- HL7v2 composite data type.

  Identifies the source(s) of a waveform channel. Used in CD (Channel Definition).

  2 components:
  1. Source One Name (ST)
  2. Source Two Name (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:source_one_name, :source_two_name]

  @type t :: %__MODULE__{
          source_one_name: binary() | nil,
          source_two_name: binary() | nil
        }

  @doc """
  Parses a WVS from a list of components.

  ## Examples

      iex> HL7v2.Type.WVS.parse(["RA", "LA"])
      %HL7v2.Type.WVS{source_one_name: "RA", source_two_name: "LA"}

      iex> HL7v2.Type.WVS.parse(["V1"])
      %HL7v2.Type.WVS{source_one_name: "V1"}

      iex> HL7v2.Type.WVS.parse([])
      %HL7v2.Type.WVS{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      source_one_name: Type.get_component(components, 0),
      source_two_name: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes a WVS to a list of component strings.

  ## Examples

      iex> HL7v2.Type.WVS.encode(%HL7v2.Type.WVS{source_one_name: "RA", source_two_name: "LA"})
      ["RA", "LA"]

      iex> HL7v2.Type.WVS.encode(%HL7v2.Type.WVS{source_one_name: "V1"})
      ["V1"]

      iex> HL7v2.Type.WVS.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = wvs) do
    [
      wvs.source_one_name || "",
      wvs.source_two_name || ""
    ]
    |> Type.trim_trailing()
  end
end
