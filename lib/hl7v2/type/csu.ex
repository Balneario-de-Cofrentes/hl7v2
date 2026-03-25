defmodule HL7v2.Type.CSU do
  @moduledoc """
  Channel Sensitivity and Units (CSU) -- HL7v2 composite data type.

  Defines the sensitivity and units of measurement for a waveform channel.
  Used in CD (Channel Definition).

  7 components:
  1. Channel Sensitivity (NM)
  2. Unit of Measure Identifier (ST)
  3. Unit of Measure Description (ST)
  4. Unit of Measure Coding System (ID) -- Table 0396
  5. Alternate Unit of Measure Identifier (ST)
  6. Alternate Unit of Measure Text (ST)
  7. Alternate Unit of Measure Coding System (ID) -- Table 0396
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :channel_sensitivity,
    :unit_of_measure_identifier,
    :unit_of_measure_description,
    :unit_of_measure_coding_system,
    :alternate_unit_of_measure_identifier,
    :alternate_unit_of_measure_text,
    :alternate_unit_of_measure_coding_system
  ]

  @type t :: %__MODULE__{
          channel_sensitivity: binary() | nil,
          unit_of_measure_identifier: binary() | nil,
          unit_of_measure_description: binary() | nil,
          unit_of_measure_coding_system: binary() | nil,
          alternate_unit_of_measure_identifier: binary() | nil,
          alternate_unit_of_measure_text: binary() | nil,
          alternate_unit_of_measure_coding_system: binary() | nil
        }

  @doc """
  Parses a CSU from a list of components.

  ## Examples

      iex> HL7v2.Type.CSU.parse(["0.1", "mV", "millivolts", "UCUM"])
      %HL7v2.Type.CSU{channel_sensitivity: "0.1", unit_of_measure_identifier: "mV", unit_of_measure_description: "millivolts", unit_of_measure_coding_system: "UCUM"}

      iex> HL7v2.Type.CSU.parse([])
      %HL7v2.Type.CSU{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      channel_sensitivity: Type.get_component(components, 0),
      unit_of_measure_identifier: Type.get_component(components, 1),
      unit_of_measure_description: Type.get_component(components, 2),
      unit_of_measure_coding_system: Type.get_component(components, 3),
      alternate_unit_of_measure_identifier: Type.get_component(components, 4),
      alternate_unit_of_measure_text: Type.get_component(components, 5),
      alternate_unit_of_measure_coding_system: Type.get_component(components, 6)
    }
  end

  @doc """
  Encodes a CSU to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CSU.encode(%HL7v2.Type.CSU{channel_sensitivity: "0.1", unit_of_measure_identifier: "mV"})
      ["0.1", "mV"]

      iex> HL7v2.Type.CSU.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = csu) do
    [
      csu.channel_sensitivity || "",
      csu.unit_of_measure_identifier || "",
      csu.unit_of_measure_description || "",
      csu.unit_of_measure_coding_system || "",
      csu.alternate_unit_of_measure_identifier || "",
      csu.alternate_unit_of_measure_text || "",
      csu.alternate_unit_of_measure_coding_system || ""
    ]
    |> Type.trim_trailing()
  end
end
