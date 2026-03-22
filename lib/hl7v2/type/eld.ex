defmodule HL7v2.Type.ELD do
  @moduledoc """
  Error Location and Description (ELD) -- HL7v2 composite data type.

  Deprecated in v2.5.1 (replaced by ERL + CWE), but retained for backward
  compatibility with ERR-1 which uses this type.

  4 components:
  1. Segment ID (ST)
  2. Segment Sequence (NM)
  3. Field Position (NM)
  4. Code Identifying Error (CE) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.CE

  defstruct [
    :segment_id,
    :segment_sequence,
    :field_position,
    :code_identifying_error
  ]

  @type t :: %__MODULE__{
          segment_id: binary() | nil,
          segment_sequence: binary() | nil,
          field_position: binary() | nil,
          code_identifying_error: CE.t() | nil
        }

  @doc """
  Parses an ELD from a list of components.

  ## Examples

      iex> HL7v2.Type.ELD.parse(["PID", "1", "4", "101&Required field missing&HL70357"])
      %HL7v2.Type.ELD{
        segment_id: "PID",
        segment_sequence: "1",
        field_position: "4",
        code_identifying_error: %HL7v2.Type.CE{identifier: "101", text: "Required field missing", name_of_coding_system: "HL70357"}
      }

      iex> HL7v2.Type.ELD.parse(["PID", "1"])
      %HL7v2.Type.ELD{segment_id: "PID", segment_sequence: "1"}

      iex> HL7v2.Type.ELD.parse([])
      %HL7v2.Type.ELD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      segment_id: Type.get_component(components, 0),
      segment_sequence: Type.get_component(components, 1),
      field_position: Type.get_component(components, 2),
      code_identifying_error: Type.parse_sub(CE, Type.get_component(components, 3))
    }
  end

  @doc """
  Encodes an ELD to a list of component strings.

  ## Examples

      iex> HL7v2.Type.ELD.encode(%HL7v2.Type.ELD{segment_id: "PID", segment_sequence: "1", field_position: "4", code_identifying_error: %HL7v2.Type.CE{identifier: "101", text: "Required field missing", name_of_coding_system: "HL70357"}})
      ["PID", "1", "4", "101&Required field missing&HL70357"]

      iex> HL7v2.Type.ELD.encode(%HL7v2.Type.ELD{segment_id: "PID", segment_sequence: "1"})
      ["PID", "1"]

      iex> HL7v2.Type.ELD.encode(nil)
      []

      iex> HL7v2.Type.ELD.encode(%HL7v2.Type.ELD{})
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = eld) do
    [
      eld.segment_id || "",
      eld.segment_sequence || "",
      eld.field_position || "",
      Type.encode_sub(CE, eld.code_identifying_error)
    ]
    |> Type.trim_trailing()
  end

end
