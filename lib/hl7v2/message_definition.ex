defmodule HL7v2.MessageDefinition do
  @moduledoc """
  Canonical message structure mappings and validation dispatch.

  Maps HL7v2 trigger events to their canonical message structures (e.g.,
  ADT^A04 → ADT_A01) and dispatches structural validation to
  `HL7v2.Standard.MessageStructure` and `HL7v2.Validation.Structural`.
  """

  # HL7 v2.5.1 canonical message structure map.
  # Many trigger events share the same abstract message definition.
  # If a {code, event} pair is not listed, the structure defaults to "CODE_EVENT".
  @canonical_structures %{
    {"ADT", "A04"} => "ADT_A01",
    {"ADT", "A08"} => "ADT_A01",
    {"ADT", "A13"} => "ADT_A01",
    {"ADT", "A05"} => "ADT_A05",
    {"ADT", "A14"} => "ADT_A05",
    {"ADT", "A28"} => "ADT_A05",
    {"ADT", "A31"} => "ADT_A05",
    {"ADT", "A06"} => "ADT_A06",
    {"ADT", "A07"} => "ADT_A06",
    {"ADT", "A09"} => "ADT_A09",
    {"ADT", "A10"} => "ADT_A09",
    {"ADT", "A11"} => "ADT_A09",
    {"ADT", "A12"} => "ADT_A12",
    {"ADT", "A15"} => "ADT_A15",
    {"ADT", "A16"} => "ADT_A16",
    {"ADT", "A25"} => "ADT_A21",
    {"ADT", "A26"} => "ADT_A21",
    {"ADT", "A27"} => "ADT_A21",
    {"ADT", "A21"} => "ADT_A21",
    {"ADT", "A22"} => "ADT_A21",
    {"ADT", "A23"} => "ADT_A21",
    {"ADT", "A24"} => "ADT_A24",
    {"ADT", "A37"} => "ADT_A37",
    {"ADT", "A38"} => "ADT_A38",
    {"ADT", "A39"} => "ADT_A39",
    {"ADT", "A40"} => "ADT_A39",
    {"ADT", "A41"} => "ADT_A39",
    {"ADT", "A42"} => "ADT_A39",
    {"MDM", "T01"} => "MDM_T02",
    {"MDM", "T02"} => "MDM_T02",
    {"RDE", "O11"} => "RDE_O11",
    {"RDS", "O13"} => "RDS_O13",
    {"SIU", "S13"} => "SIU_S12",
    {"SIU", "S14"} => "SIU_S12",
    {"SIU", "S15"} => "SIU_S12",
    {"SIU", "S16"} => "SIU_S12",
    {"SIU", "S17"} => "SIU_S12",
    {"SIU", "S18"} => "SIU_S12",
    {"SIU", "S19"} => "SIU_S12",
    {"SIU", "S20"} => "SIU_S12",
    {"SIU", "S21"} => "SIU_S12",
    {"SIU", "S22"} => "SIU_S12",
    {"SIU", "S23"} => "SIU_S12",
    {"SIU", "S24"} => "SIU_S12",
    {"SIU", "S26"} => "SIU_S12"
  }

  @doc """
  Returns the canonical message structure for a message code and trigger event.

  Many HL7v2 trigger events share the same abstract message definition. For
  example, ADT^A04, ADT^A08, and ADT^A13 all use the ADT_A01 structure.

  Falls back to `"CODE_EVENT"` when no canonical mapping exists.

  ## Examples

      iex> HL7v2.MessageDefinition.canonical_structure("ADT", "A28")
      "ADT_A05"

      iex> HL7v2.MessageDefinition.canonical_structure("ADT", "A01")
      "ADT_A01"

      iex> HL7v2.MessageDefinition.canonical_structure("ZZZ", "Z01")
      "ZZZ_Z01"

  """
  @spec canonical_structure(binary(), binary()) :: binary()
  def canonical_structure(code, event) do
    Map.get(@canonical_structures, {code, event}, "#{code}_#{event}")
  end

  @doc """
  Validates segment presence/structure against the message definition.

  Delegates to `HL7v2.Validation.Structural` for structures with group-aware
  definitions. Returns a warning for unknown structures.
  """
  @spec validate_structure(binary() | nil, [binary()]) :: :ok | {:error, [map()]}
  def validate_structure(nil, _segment_ids), do: :ok
  def validate_structure("", _segment_ids), do: :ok

  def validate_structure(structure, segment_ids) do
    case HL7v2.Standard.MessageStructure.get(structure) do
      %{} = struct_def ->
        case HL7v2.Validation.Structural.validate(struct_def, segment_ids) do
          [] -> :ok
          errors -> {:error, errors}
        end

      nil ->
        {:error,
         [
           %{
             level: :warning,
             location: "message",
             message:
               "message structure #{structure} has no validation definition — structure not checked"
           }
         ]}
    end
  end
end
