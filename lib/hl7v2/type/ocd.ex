defmodule HL7v2.Type.OCD do
  @moduledoc """
  Occurrence Code and Date (OCD) -- HL7v2 composite data type.

  Links a UB occurrence code to its date for billing segments (UB2-7).

  2 components:
  1. Occurrence Code (CNE) -- sub-components, Table 0350
  2. Occurrence Date (DT) -- YYYY[MM[DD]]
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{CNE, DT}

  defstruct [
    :occurrence_code,
    :occurrence_date
  ]

  @type t :: %__MODULE__{
          occurrence_code: CNE.t() | nil,
          occurrence_date: Date.t() | DT.t() | nil
        }

  @doc """
  Parses an OCD from a list of components.

  ## Examples

      iex> HL7v2.Type.OCD.parse(["01&Accident&NUBC", "20260115"])
      %HL7v2.Type.OCD{
        occurrence_code: %HL7v2.Type.CNE{identifier: "01", text: "Accident", name_of_coding_system: "NUBC"},
        occurrence_date: ~D[2026-01-15]
      }

      iex> HL7v2.Type.OCD.parse([])
      %HL7v2.Type.OCD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      occurrence_code: Type.parse_sub(CNE, Type.get_component(components, 0)),
      occurrence_date: components |> Type.get_component(1) |> DT.parse()
    }
  end

  @doc """
  Encodes an OCD to a list of component strings.

  ## Examples

      iex> HL7v2.Type.OCD.encode(%HL7v2.Type.OCD{occurrence_code: %HL7v2.Type.CNE{identifier: "01"}, occurrence_date: ~D[2026-01-15]})
      ["01", "20260115"]

      iex> HL7v2.Type.OCD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ocd) do
    [
      Type.encode_sub(CNE, ocd.occurrence_code),
      DT.encode(ocd.occurrence_date)
    ]
    |> Type.trim_trailing()
  end
end
