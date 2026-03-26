defmodule HL7v2.Type.CCP do
  @moduledoc """
  Channel Calibration Parameters (CCP) -- HL7v2 composite data type.

  Specifies calibration corrections for a waveform channel. Used in CD
  (Channel Definition) component 4.

  3 components:
  1. Channel Calibration Sensitivity Correction Factor (NM)
  2. Channel Calibration Baseline (NM)
  3. Channel Calibration Time Skew (NM)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :channel_calibration_sensitivity_correction_factor,
    :channel_calibration_baseline,
    :channel_calibration_time_skew
  ]

  @type t :: %__MODULE__{
          channel_calibration_sensitivity_correction_factor: binary() | nil,
          channel_calibration_baseline: binary() | nil,
          channel_calibration_time_skew: binary() | nil
        }

  @doc """
  Parses a CCP from a list of components.

  ## Examples

      iex> HL7v2.Type.CCP.parse(["1.5", "0.0", "0.003"])
      %HL7v2.Type.CCP{channel_calibration_sensitivity_correction_factor: "1.5", channel_calibration_baseline: "0.0", channel_calibration_time_skew: "0.003"}

      iex> HL7v2.Type.CCP.parse(["1.2"])
      %HL7v2.Type.CCP{channel_calibration_sensitivity_correction_factor: "1.2"}

      iex> HL7v2.Type.CCP.parse([])
      %HL7v2.Type.CCP{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      channel_calibration_sensitivity_correction_factor: Type.get_component(components, 0),
      channel_calibration_baseline: Type.get_component(components, 1),
      channel_calibration_time_skew: Type.get_component(components, 2)
    }
  end

  @doc """
  Encodes a CCP to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CCP.encode(%HL7v2.Type.CCP{channel_calibration_sensitivity_correction_factor: "1.5", channel_calibration_baseline: "0.0", channel_calibration_time_skew: "0.003"})
      ["1.5", "0.0", "0.003"]

      iex> HL7v2.Type.CCP.encode(%HL7v2.Type.CCP{channel_calibration_sensitivity_correction_factor: "1.2"})
      ["1.2"]

      iex> HL7v2.Type.CCP.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ccp) do
    [
      ccp.channel_calibration_sensitivity_correction_factor || "",
      ccp.channel_calibration_baseline || "",
      ccp.channel_calibration_time_skew || ""
    ]
    |> Type.trim_trailing()
  end
end
