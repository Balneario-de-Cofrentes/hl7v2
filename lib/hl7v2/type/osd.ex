defmodule HL7v2.Type.OSD do
  @moduledoc """
  Order Sequence Definition (OSD) -- HL7v2 composite data type.

  Defines the sequence of orders for results reporting.

  11 components:
  1. Sequence/Results Flag (ID) -- S (sequential), R (results-dependent)
  2. Placer Order Number: Entity Identifier (ST)
  3. Placer Order Number: Namespace ID (IS)
  4. Filler Order Number: Entity Identifier (ST)
  5. Filler Order Number: Namespace ID (IS)
  6. Sequence Condition Value (ST)
  7. Maximum Number of Repeats (NM)
  8. Placer Order Number: Universal ID (ST)
  9. Placer Order Number: Universal ID Type (ID)
  10. Filler Order Number: Universal ID (ST)
  11. Filler Order Number: Universal ID Type (ID)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :sequence_results_flag,
    :placer_order_number_entity_identifier,
    :placer_order_number_namespace_id,
    :filler_order_number_entity_identifier,
    :filler_order_number_namespace_id,
    :sequence_condition_value,
    :maximum_number_of_repeats,
    :placer_order_number_universal_id,
    :placer_order_number_universal_id_type,
    :filler_order_number_universal_id,
    :filler_order_number_universal_id_type
  ]

  @type t :: %__MODULE__{
          sequence_results_flag: binary() | nil,
          placer_order_number_entity_identifier: binary() | nil,
          placer_order_number_namespace_id: binary() | nil,
          filler_order_number_entity_identifier: binary() | nil,
          filler_order_number_namespace_id: binary() | nil,
          sequence_condition_value: binary() | nil,
          maximum_number_of_repeats: binary() | nil,
          placer_order_number_universal_id: binary() | nil,
          placer_order_number_universal_id_type: binary() | nil,
          filler_order_number_universal_id: binary() | nil,
          filler_order_number_universal_id_type: binary() | nil
        }

  @doc """
  Parses an OSD from a list of components.

  ## Examples

      iex> HL7v2.Type.OSD.parse(["S", "ORD001", "HOSP", "FILL001", "LAB"])
      %HL7v2.Type.OSD{sequence_results_flag: "S", placer_order_number_entity_identifier: "ORD001", placer_order_number_namespace_id: "HOSP", filler_order_number_entity_identifier: "FILL001", filler_order_number_namespace_id: "LAB"}

      iex> HL7v2.Type.OSD.parse([])
      %HL7v2.Type.OSD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      sequence_results_flag: Type.get_component(components, 0),
      placer_order_number_entity_identifier: Type.get_component(components, 1),
      placer_order_number_namespace_id: Type.get_component(components, 2),
      filler_order_number_entity_identifier: Type.get_component(components, 3),
      filler_order_number_namespace_id: Type.get_component(components, 4),
      sequence_condition_value: Type.get_component(components, 5),
      maximum_number_of_repeats: Type.get_component(components, 6),
      placer_order_number_universal_id: Type.get_component(components, 7),
      placer_order_number_universal_id_type: Type.get_component(components, 8),
      filler_order_number_universal_id: Type.get_component(components, 9),
      filler_order_number_universal_id_type: Type.get_component(components, 10)
    }
  end

  @doc """
  Encodes an OSD to a list of component strings.

  ## Examples

      iex> HL7v2.Type.OSD.encode(%HL7v2.Type.OSD{sequence_results_flag: "S", placer_order_number_entity_identifier: "ORD001"})
      ["S", "ORD001"]

      iex> HL7v2.Type.OSD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = osd) do
    [
      osd.sequence_results_flag || "",
      osd.placer_order_number_entity_identifier || "",
      osd.placer_order_number_namespace_id || "",
      osd.filler_order_number_entity_identifier || "",
      osd.filler_order_number_namespace_id || "",
      osd.sequence_condition_value || "",
      osd.maximum_number_of_repeats || "",
      osd.placer_order_number_universal_id || "",
      osd.placer_order_number_universal_id_type || "",
      osd.filler_order_number_universal_id || "",
      osd.filler_order_number_universal_id_type || ""
    ]
    |> Type.trim_trailing()
  end
end
