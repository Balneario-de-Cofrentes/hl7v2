defmodule HL7v2.Type.DIN do
  @moduledoc """
  Date and Institution Name (DIN) -- HL7v2 composite data type.

  Associates a date with an institution name. Used in PRA-5.

  2 components:
  1. Date (TS) -- sub-components delimited by `&`
  2. Institution Name (CE) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.CE

  defstruct [:date, :institution_name]

  @type t :: %__MODULE__{
          date: Type.TS.t() | nil,
          institution_name: CE.t() | nil
        }

  @doc """
  Parses a DIN from a list of components.

  ## Examples

      iex> HL7v2.Type.DIN.parse(["20260101", "HOSP1&City Hospital&LOCAL"])
      %HL7v2.Type.DIN{
        date: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 1, day: 1}},
        institution_name: %HL7v2.Type.CE{identifier: "HOSP1", text: "City Hospital", name_of_coding_system: "LOCAL"}
      }

      iex> HL7v2.Type.DIN.parse([])
      %HL7v2.Type.DIN{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      date: Type.parse_sub_ts(Type.get_component(components, 0)),
      institution_name: Type.parse_sub(CE, Type.get_component(components, 1))
    }
  end

  @doc """
  Encodes a DIN to a list of component strings.

  ## Examples

      iex> HL7v2.Type.DIN.encode(%HL7v2.Type.DIN{institution_name: %HL7v2.Type.CE{identifier: "HOSP1"}})
      ["", "HOSP1"]

      iex> HL7v2.Type.DIN.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = din) do
    [
      Type.encode_sub_ts(din.date),
      Type.encode_sub(CE, din.institution_name)
    ]
    |> Type.trim_trailing()
  end
end
