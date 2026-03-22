defmodule HL7v2.Type.EI do
  @moduledoc """
  Entity Identifier (EI) -- HL7v2 composite data type.

  Used for order numbers, filler/placer numbers, and other entity identifiers.

  4 components:
  1. Entity Identifier (ST)
  2. Namespace ID (IS)
  3. Universal ID (ST)
  4. Universal ID Type (ID)

  Components 3 and 4 follow HD pairing rules: both must be valued or both null.
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:entity_identifier, :namespace_id, :universal_id, :universal_id_type]

  @type t :: %__MODULE__{
          entity_identifier: binary() | nil,
          namespace_id: binary() | nil,
          universal_id: binary() | nil,
          universal_id_type: binary() | nil
        }

  @doc """
  Parses an EI from a list of components.

  ## Examples

      iex> HL7v2.Type.EI.parse(["ORD12345", "HOSP", "2.16.840.1.113883.19.4.6", "ISO"])
      %HL7v2.Type.EI{entity_identifier: "ORD12345", namespace_id: "HOSP", universal_id: "2.16.840.1.113883.19.4.6", universal_id_type: "ISO"}

      iex> HL7v2.Type.EI.parse(["ORD12345"])
      %HL7v2.Type.EI{entity_identifier: "ORD12345"}

      iex> HL7v2.Type.EI.parse([])
      %HL7v2.Type.EI{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      entity_identifier: Type.get_component(components, 0),
      namespace_id: Type.get_component(components, 1),
      universal_id: Type.get_component(components, 2),
      universal_id_type: Type.get_component(components, 3)
    }
  end

  @doc """
  Encodes an EI to a list of component strings.

  ## Examples

      iex> HL7v2.Type.EI.encode(%HL7v2.Type.EI{entity_identifier: "ORD12345", namespace_id: "HOSP"})
      ["ORD12345", "HOSP"]

      iex> HL7v2.Type.EI.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ei) do
    [
      ei.entity_identifier || "",
      ei.namespace_id || "",
      ei.universal_id || "",
      ei.universal_id_type || ""
    ]
    |> Type.trim_trailing()
  end
end
