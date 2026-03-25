defmodule HL7v2.Type.WVI do
  @moduledoc """
  Channel Identifier (WVI) -- HL7v2 composite data type.

  Identifies a waveform channel. Used in CD (Channel Definition).

  2 components:
  1. Channel Number (NM)
  2. Channel Name (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:channel_number, :channel_name]

  @type t :: %__MODULE__{
          channel_number: binary() | nil,
          channel_name: binary() | nil
        }

  @doc """
  Parses a WVI from a list of components.

  ## Examples

      iex> HL7v2.Type.WVI.parse(["1", "Lead I"])
      %HL7v2.Type.WVI{channel_number: "1", channel_name: "Lead I"}

      iex> HL7v2.Type.WVI.parse(["3"])
      %HL7v2.Type.WVI{channel_number: "3"}

      iex> HL7v2.Type.WVI.parse([])
      %HL7v2.Type.WVI{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      channel_number: Type.get_component(components, 0),
      channel_name: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes a WVI to a list of component strings.

  ## Examples

      iex> HL7v2.Type.WVI.encode(%HL7v2.Type.WVI{channel_number: "1", channel_name: "Lead I"})
      ["1", "Lead I"]

      iex> HL7v2.Type.WVI.encode(%HL7v2.Type.WVI{channel_number: "3"})
      ["3"]

      iex> HL7v2.Type.WVI.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = wvi) do
    [
      wvi.channel_number || "",
      wvi.channel_name || ""
    ]
    |> Type.trim_trailing()
  end
end
