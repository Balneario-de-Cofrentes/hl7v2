defmodule HL7v2.Type.ICD do
  @moduledoc """
  Insurance Certification Definition (ICD) -- HL7v2 composite data type.

  Specifies pre-certification requirements for insurance claims.

  3 components:
  1. Certification Patient Type (IS) -- Table 0150: e.g., "ER" (emergency), "IPE" (inpatient elective)
  2. Certification Required (ID) -- Table 0136 (Y/N): "Y" or "N"
  3. Date/Time Certification Required (TS) -- when certification is needed by
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :certification_patient_type,
    :certification_required,
    :date_time_certification_required
  ]

  @type t :: %__MODULE__{
          certification_patient_type: binary() | nil,
          certification_required: binary() | nil,
          date_time_certification_required: Type.TS.t() | nil
        }

  @doc """
  Parses an ICD from a list of components.

  ## Examples

      iex> HL7v2.Type.ICD.parse(["ER", "Y", "20260101"])
      %HL7v2.Type.ICD{
        certification_patient_type: "ER",
        certification_required: "Y",
        date_time_certification_required: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 1, day: 1}}
      }

      iex> HL7v2.Type.ICD.parse([])
      %HL7v2.Type.ICD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      certification_patient_type: Type.get_component(components, 0),
      certification_required: Type.get_component(components, 1),
      date_time_certification_required: Type.parse_sub_ts(Type.get_component(components, 2))
    }
  end

  @doc """
  Encodes an ICD to a list of component strings.

  ## Examples

      iex> HL7v2.Type.ICD.encode(%HL7v2.Type.ICD{certification_patient_type: "ER", certification_required: "Y"})
      ["ER", "Y"]

      iex> HL7v2.Type.ICD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = icd) do
    [
      icd.certification_patient_type || "",
      icd.certification_required || "",
      Type.encode_sub_ts(icd.date_time_certification_required)
    ]
    |> Type.trim_trailing()
  end
end
