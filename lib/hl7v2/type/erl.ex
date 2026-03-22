defmodule HL7v2.Type.ERL do
  @moduledoc """
  Error Location (ERL) -- HL7v2 composite data type.

  Identifies the exact location of an error in a received message.

  6 components:
  1. Segment ID (ST)
  2. Segment Sequence (NM)
  3. Field Position (NM)
  4. Component Number (NM)
  5. Sub-Component Number (NM)
  6. Source Table (ID)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.NM

  defstruct [
    :segment_id,
    :segment_sequence,
    :field_position,
    :component_number,
    :sub_component_number,
    :source_table
  ]

  @type t :: %__MODULE__{
          segment_id: binary() | nil,
          segment_sequence: binary() | nil,
          field_position: binary() | nil,
          component_number: binary() | nil,
          sub_component_number: binary() | nil,
          source_table: binary() | nil
        }

  @doc """
  Parses an ERL from a list of components.

  ## Examples

      iex> HL7v2.Type.ERL.parse(["PID", "1", "5", "2", "1", "HL70001"])
      %HL7v2.Type.ERL{segment_id: "PID", segment_sequence: "1", field_position: "5", component_number: "2", sub_component_number: "1", source_table: "HL70001"}

      iex> HL7v2.Type.ERL.parse(["PID", "1", "5"])
      %HL7v2.Type.ERL{segment_id: "PID", segment_sequence: "1", field_position: "5"}

      iex> HL7v2.Type.ERL.parse([])
      %HL7v2.Type.ERL{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      segment_id: Type.get_component(components, 0),
      segment_sequence: components |> Type.get_component(1) |> NM.parse(),
      field_position: components |> Type.get_component(2) |> NM.parse(),
      component_number: components |> Type.get_component(3) |> NM.parse(),
      sub_component_number: components |> Type.get_component(4) |> NM.parse(),
      source_table: Type.get_component(components, 5)
    }
  end

  @doc """
  Encodes an ERL to a list of component strings.

  ## Examples

      iex> HL7v2.Type.ERL.encode(%HL7v2.Type.ERL{segment_id: "PID", segment_sequence: "1", field_position: "5"})
      ["PID", "1", "5"]

      iex> HL7v2.Type.ERL.encode(%HL7v2.Type.ERL{segment_id: "PID", segment_sequence: "1", field_position: "5", component_number: "2"})
      ["PID", "1", "5", "2"]

      iex> HL7v2.Type.ERL.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = erl) do
    [
      erl.segment_id || "",
      NM.encode(erl.segment_sequence),
      NM.encode(erl.field_position),
      NM.encode(erl.component_number),
      NM.encode(erl.sub_component_number),
      erl.source_table || ""
    ]
    |> Type.trim_trailing()
  end
end
