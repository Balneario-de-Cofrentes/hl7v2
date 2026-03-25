defmodule HL7v2.Type.CD do
  @moduledoc """
  Channel Definition (CD) -- HL7v2 composite data type.

  Defines a waveform channel's identifier, source, sensitivity, calibration,
  and sampling parameters. Used in OBX for waveform observations.

  10 components:
  1. Channel Identifier (WVI) -- sub-components
  2. Waveform Source (WVS) -- sub-components
  3. Channel Sensitivity and Units (CSU) -- sub-components
  4. Channel Calibration Parameters (ST) -- raw
  5. Channel Sampling Frequency (NM)
  6. Minimum Data Value (NR) -- sub-components
  7. Maximum Data Value (NR) -- sub-components
  8-10: reserved/raw
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{WVI, WVS, CSU, NR}

  defstruct [
    :channel_identifier,
    :waveform_source,
    :channel_sensitivity_and_units,
    :channel_calibration_parameters,
    :channel_sampling_frequency,
    :minimum_data_value,
    :maximum_data_value
  ]

  @type t :: %__MODULE__{
          channel_identifier: WVI.t() | nil,
          waveform_source: WVS.t() | nil,
          channel_sensitivity_and_units: CSU.t() | nil,
          channel_calibration_parameters: binary() | nil,
          channel_sampling_frequency: binary() | nil,
          minimum_data_value: NR.t() | nil,
          maximum_data_value: NR.t() | nil
        }

  @doc """
  Parses a CD from a list of components.

  ## Examples

      iex> HL7v2.Type.CD.parse(["1&Lead I", "RA&LA"])
      %HL7v2.Type.CD{
        channel_identifier: %HL7v2.Type.WVI{channel_number: "1", channel_name: "Lead I"},
        waveform_source: %HL7v2.Type.WVS{source_one_name: "RA", source_two_name: "LA"}
      }

      iex> HL7v2.Type.CD.parse([])
      %HL7v2.Type.CD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      channel_identifier: Type.parse_sub(WVI, Type.get_component(components, 0)),
      waveform_source: Type.parse_sub(WVS, Type.get_component(components, 1)),
      channel_sensitivity_and_units: Type.parse_sub(CSU, Type.get_component(components, 2)),
      channel_calibration_parameters: Type.get_component(components, 3),
      channel_sampling_frequency: Type.get_component(components, 4),
      minimum_data_value: Type.parse_sub(NR, Type.get_component(components, 5)),
      maximum_data_value: Type.parse_sub(NR, Type.get_component(components, 6))
    }
  end

  @doc """
  Encodes a CD to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CD.encode(%HL7v2.Type.CD{channel_identifier: %HL7v2.Type.WVI{channel_number: "1", channel_name: "Lead I"}})
      ["1&Lead I"]

      iex> HL7v2.Type.CD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = cd) do
    [
      Type.encode_sub(WVI, cd.channel_identifier),
      Type.encode_sub(WVS, cd.waveform_source),
      Type.encode_sub(CSU, cd.channel_sensitivity_and_units),
      cd.channel_calibration_parameters || "",
      cd.channel_sampling_frequency || "",
      Type.encode_sub(NR, cd.minimum_data_value),
      Type.encode_sub(NR, cd.maximum_data_value)
    ]
    |> Type.trim_trailing()
  end
end
