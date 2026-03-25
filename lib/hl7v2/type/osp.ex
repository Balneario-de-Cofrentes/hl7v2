defmodule HL7v2.Type.OSP do
  @moduledoc """
  Occurrence Span Code and Date (OSP) -- HL7v2 composite data type.

  Links a UB occurrence span code to a date range for billing segments (UB2-8).

  3 components:
  1. Occurrence Span Code (CNE) -- sub-components, Table 0351
  2. Occurrence Span Start Date (DT) -- YYYY[MM[DD]]
  3. Occurrence Span Stop Date (DT) -- YYYY[MM[DD]]
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{CNE, DT}

  defstruct [
    :occurrence_span_code,
    :occurrence_span_start_date,
    :occurrence_span_stop_date
  ]

  @type t :: %__MODULE__{
          occurrence_span_code: CNE.t() | nil,
          occurrence_span_start_date: Date.t() | DT.t() | nil,
          occurrence_span_stop_date: Date.t() | DT.t() | nil
        }

  @doc """
  Parses an OSP from a list of components.

  ## Examples

      iex> HL7v2.Type.OSP.parse(["70&Qualifying stay&NUBC", "20260101", "20260115"])
      %HL7v2.Type.OSP{
        occurrence_span_code: %HL7v2.Type.CNE{identifier: "70", text: "Qualifying stay", name_of_coding_system: "NUBC"},
        occurrence_span_start_date: ~D[2026-01-01],
        occurrence_span_stop_date: ~D[2026-01-15]
      }

      iex> HL7v2.Type.OSP.parse([])
      %HL7v2.Type.OSP{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      occurrence_span_code: Type.parse_sub(CNE, Type.get_component(components, 0)),
      occurrence_span_start_date: components |> Type.get_component(1) |> DT.parse(),
      occurrence_span_stop_date: components |> Type.get_component(2) |> DT.parse()
    }
  end

  @doc """
  Encodes an OSP to a list of component strings.

  ## Examples

      iex> HL7v2.Type.OSP.encode(%HL7v2.Type.OSP{occurrence_span_code: %HL7v2.Type.CNE{identifier: "70"}, occurrence_span_start_date: ~D[2026-01-01], occurrence_span_stop_date: ~D[2026-01-15]})
      ["70", "20260101", "20260115"]

      iex> HL7v2.Type.OSP.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = osp) do
    [
      Type.encode_sub(CNE, osp.occurrence_span_code),
      DT.encode(osp.occurrence_span_start_date),
      DT.encode(osp.occurrence_span_stop_date)
    ]
    |> Type.trim_trailing()
  end
end
