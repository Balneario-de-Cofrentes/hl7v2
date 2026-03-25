defmodule HL7v2.Type.RCD do
  @moduledoc """
  Row Column Definition (RCD) -- HL7v2 composite data type.

  Defines columns in a tabular response. Used in RDF segment.

  3 components:
  1. Segment Field Name (ST) -- e.g., "PID.3"
  2. HL7 Data Type (ID) -- Table 0440: e.g., "ST", "NM", "CX"
  3. Maximum Column Width (NM)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:segment_field_name, :hl7_data_type, :maximum_column_width]

  @type t :: %__MODULE__{
          segment_field_name: binary() | nil,
          hl7_data_type: binary() | nil,
          maximum_column_width: binary() | nil
        }

  @doc """
  Parses an RCD from a list of components.

  ## Examples

      iex> HL7v2.Type.RCD.parse(["PID.3", "CX", "20"])
      %HL7v2.Type.RCD{segment_field_name: "PID.3", hl7_data_type: "CX", maximum_column_width: "20"}

      iex> HL7v2.Type.RCD.parse(["OBX.5", "ST"])
      %HL7v2.Type.RCD{segment_field_name: "OBX.5", hl7_data_type: "ST"}

      iex> HL7v2.Type.RCD.parse([])
      %HL7v2.Type.RCD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      segment_field_name: Type.get_component(components, 0),
      hl7_data_type: Type.get_component(components, 1),
      maximum_column_width: Type.get_component(components, 2)
    }
  end

  @doc """
  Encodes an RCD to a list of component strings.

  ## Examples

      iex> HL7v2.Type.RCD.encode(%HL7v2.Type.RCD{segment_field_name: "PID.3", hl7_data_type: "CX", maximum_column_width: "20"})
      ["PID.3", "CX", "20"]

      iex> HL7v2.Type.RCD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = rcd) do
    [
      rcd.segment_field_name || "",
      rcd.hl7_data_type || "",
      rcd.maximum_column_width || ""
    ]
    |> Type.trim_trailing()
  end
end
