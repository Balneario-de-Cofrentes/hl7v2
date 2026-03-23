defmodule HL7v2.Type.RPT do
  @moduledoc """
  Repeat Pattern (RPT) -- HL7v2 composite data type.

  Defines a repeating schedule pattern for timing-related segments (TQ1-3).
  More expressive than RI, supporting calendar-aligned and phase-based
  patterns.

  6 components (of 10 defined in v2.5.1; remaining 4 are rarely used):
  1. Repeat Pattern Code (CWE) -- sub-components delimited by `&`, Table 0335
  2. Calendar Alignment (ID) -- Table 0527: e.g., "DY" (day), "WK" (week), "MY" (month)
  3. Phase Range Begin Value (NM) -- start of phase range
  4. Phase Range End Value (NM) -- end of phase range
  5. Period Quantity (NM) -- number of period units
  6. Period Units (IS) -- Table 0xxx: e.g., "s" (seconds), "min", "h", "d", "wk", "mo"
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{CWE, NM}

  defstruct [
    :repeat_pattern_code,
    :calendar_alignment,
    :phase_range_begin_value,
    :phase_range_end_value,
    :period_quantity,
    :period_units
  ]

  @type t :: %__MODULE__{
          repeat_pattern_code: CWE.t() | nil,
          calendar_alignment: binary() | nil,
          phase_range_begin_value: NM.t() | nil,
          phase_range_end_value: NM.t() | nil,
          period_quantity: NM.t() | nil,
          period_units: binary() | nil
        }

  @doc """
  Parses an RPT from a list of components.

  ## Examples

      iex> HL7v2.Type.RPT.parse(["QAM&Every morning&HL70335"])
      %HL7v2.Type.RPT{
        repeat_pattern_code: %HL7v2.Type.CWE{identifier: "QAM", text: "Every morning", name_of_coding_system: "HL70335"}
      }

      iex> HL7v2.Type.RPT.parse(["Q6H&Every 6 hours&HL70335", "DY", "", "", "6", "h"])
      %HL7v2.Type.RPT{
        repeat_pattern_code: %HL7v2.Type.CWE{identifier: "Q6H", text: "Every 6 hours", name_of_coding_system: "HL70335"},
        calendar_alignment: "DY",
        period_quantity: %HL7v2.Type.NM{value: "6", original: "6"},
        period_units: "h"
      }

      iex> HL7v2.Type.RPT.parse([])
      %HL7v2.Type.RPT{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      repeat_pattern_code: Type.parse_sub(CWE, Type.get_component(components, 0)),
      calendar_alignment: Type.get_component(components, 1),
      phase_range_begin_value: components |> Type.get_component(2) |> NM.parse(),
      phase_range_end_value: components |> Type.get_component(3) |> NM.parse(),
      period_quantity: components |> Type.get_component(4) |> NM.parse(),
      period_units: Type.get_component(components, 5)
    }
  end

  @doc """
  Encodes an RPT to a list of component strings.

  ## Examples

      iex> HL7v2.Type.RPT.encode(%HL7v2.Type.RPT{
      ...>   repeat_pattern_code: %HL7v2.Type.CWE{identifier: "QAM", text: "Every morning", name_of_coding_system: "HL70335"}
      ...> })
      ["QAM&Every morning&HL70335"]

      iex> HL7v2.Type.RPT.encode(%HL7v2.Type.RPT{
      ...>   repeat_pattern_code: %HL7v2.Type.CWE{identifier: "Q6H"},
      ...>   period_quantity: %HL7v2.Type.NM{value: "6", original: "6"},
      ...>   period_units: "h"
      ...> })
      ["Q6H", "", "", "", "6", "h"]

      iex> HL7v2.Type.RPT.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = rpt) do
    [
      Type.encode_sub(CWE, rpt.repeat_pattern_code),
      rpt.calendar_alignment || "",
      NM.encode(rpt.phase_range_begin_value),
      NM.encode(rpt.phase_range_end_value),
      NM.encode(rpt.period_quantity),
      rpt.period_units || ""
    ]
    |> Type.trim_trailing()
  end
end
