defmodule HL7v2.Type.EIP do
  @moduledoc """
  Entity Identifier Pair (EIP) -- HL7v2 composite data type.

  Used to convey a pair of placer and filler identifiers (e.g., parent order
  references in ORC-8 and OBR-29).

  2 components:
  1. Placer Assigned Identifier (EI) -- sub-components delimited by `&`
  2. Filler Assigned Identifier (EI) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.EI

  defstruct [:placer_assigned_identifier, :filler_assigned_identifier]

  @type t :: %__MODULE__{
          placer_assigned_identifier: EI.t() | nil,
          filler_assigned_identifier: EI.t() | nil
        }

  @doc """
  Parses an EIP from a list of components.

  ## Examples

      iex> HL7v2.Type.EIP.parse(["P123&HOSP&2.16.840&ISO", "F456&LAB&2.16.841&ISO"])
      %HL7v2.Type.EIP{
        placer_assigned_identifier: %HL7v2.Type.EI{entity_identifier: "P123", namespace_id: "HOSP", universal_id: "2.16.840", universal_id_type: "ISO"},
        filler_assigned_identifier: %HL7v2.Type.EI{entity_identifier: "F456", namespace_id: "LAB", universal_id: "2.16.841", universal_id_type: "ISO"}
      }

      iex> HL7v2.Type.EIP.parse(["P123"])
      %HL7v2.Type.EIP{placer_assigned_identifier: %HL7v2.Type.EI{entity_identifier: "P123"}}

      iex> HL7v2.Type.EIP.parse([])
      %HL7v2.Type.EIP{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      placer_assigned_identifier: Type.parse_sub(EI, Type.get_component(components, 0)),
      filler_assigned_identifier: Type.parse_sub(EI, Type.get_component(components, 1))
    }
  end

  @doc """
  Encodes an EIP to a list of component strings.

  ## Examples

      iex> HL7v2.Type.EIP.encode(%HL7v2.Type.EIP{placer_assigned_identifier: %HL7v2.Type.EI{entity_identifier: "P123", namespace_id: "HOSP"}})
      ["P123&HOSP"]

      iex> HL7v2.Type.EIP.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = eip) do
    [
      Type.encode_sub(EI, eip.placer_assigned_identifier),
      Type.encode_sub(EI, eip.filler_assigned_identifier)
    ]
    |> Type.trim_trailing()
  end

end
