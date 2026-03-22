defmodule HL7v2.MessageDefinition do
  @moduledoc """
  Defines expected segment presence for common HL7v2 message types.

  Each definition specifies which segments are required, optional, and
  repeating for a given message type (e.g., ADT_A01, ORM_O01, ORU_R01).
  Used by the validation engine for required-segment presence checking.

  **Limitations:** This is presence-only validation — it checks that required
  segments exist somewhere in the message. It does not enforce segment ordering,
  group structure, group anchors, or message-level cardinality rules from the
  HL7 abstract message definitions.
  """

  @type segment_rule :: {atom(), :required | :optional, :once | :repeating}
  @type definition :: %{
          name: binary(),
          description: binary(),
          segments: [segment_rule()]
        }

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
    {"ADT", "A12"} => "ADT_A09",
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

  @adt_admit_segments [
    {:MSH, :required, :once},
    {:EVN, :required, :once},
    {:PID, :required, :once},
    {:PV1, :required, :once},
    {:PV2, :optional, :once},
    {:NK1, :optional, :repeating},
    {:AL1, :optional, :repeating},
    {:DG1, :optional, :repeating},
    {:GT1, :optional, :repeating},
    {:IN1, :optional, :repeating},
    {:NTE, :optional, :repeating}
  ]

  # ADT_A05: Pre-admit a Patient (also A14 pending admit, A28 add person, A31 update person)
  @adt_preadmit_segments [
    {:MSH, :required, :once},
    {:EVN, :required, :once},
    {:PID, :required, :once},
    {:PV1, :required, :once},
    {:PV2, :optional, :once},
    {:NK1, :optional, :repeating},
    {:AL1, :optional, :repeating},
    {:DG1, :optional, :repeating},
    {:GT1, :optional, :repeating},
    {:IN1, :optional, :repeating},
    {:NTE, :optional, :repeating}
  ]

  # ADT_A09: Patient departing/tracking (also A10, A11)
  @adt_tracking_segments [
    {:MSH, :required, :once},
    {:EVN, :required, :once},
    {:PID, :required, :once},
    {:PV1, :required, :once},
    {:PV2, :optional, :once},
    {:NTE, :optional, :repeating}
  ]

  # ADT_A21: Patient goes on leave of absence (also A22-A27)
  @adt_leave_segments [
    {:MSH, :required, :once},
    {:EVN, :required, :once},
    {:PID, :required, :once},
    {:PV1, :required, :once},
    {:PV2, :optional, :once},
    {:NTE, :optional, :repeating}
  ]

  @definitions %{
    "ADT_A01" => %{
      name: "ADT_A01",
      description: "Admit/Visit Notification",
      segments: @adt_admit_segments
    },
    "ADT_A02" => %{
      name: "ADT_A02",
      description: "Transfer a Patient",
      segments: [
        {:MSH, :required, :once},
        {:EVN, :required, :once},
        {:PID, :required, :once},
        {:PV1, :required, :once},
        {:PV2, :optional, :once},
        {:NTE, :optional, :repeating}
      ]
    },
    "ADT_A03" => %{
      name: "ADT_A03",
      description: "Discharge/End Visit",
      segments: [
        {:MSH, :required, :once},
        {:EVN, :required, :once},
        {:PID, :required, :once},
        {:PV1, :required, :once},
        {:PV2, :optional, :once},
        {:DG1, :optional, :repeating},
        {:NTE, :optional, :repeating}
      ]
    },
    "ADT_A04" => %{
      name: "ADT_A04",
      description: "Register a Patient",
      segments: @adt_admit_segments
    },
    "ADT_A05" => %{
      name: "ADT_A05",
      description: "Pre-admit a Patient",
      segments: @adt_preadmit_segments
    },
    "ADT_A06" => %{
      name: "ADT_A06",
      description: "Change an Outpatient to an Inpatient",
      segments: [
        {:MSH, :required, :once},
        {:EVN, :required, :once},
        {:PID, :required, :once},
        {:PV1, :required, :once},
        {:PV2, :optional, :once},
        {:MRG, :optional, :once},
        {:NK1, :optional, :repeating},
        {:AL1, :optional, :repeating},
        {:DG1, :optional, :repeating},
        {:GT1, :optional, :repeating},
        {:IN1, :optional, :repeating},
        {:NTE, :optional, :repeating}
      ]
    },
    "ADT_A08" => %{
      name: "ADT_A08",
      description: "Update Patient Information",
      segments: @adt_admit_segments
    },
    "ADT_A09" => %{
      name: "ADT_A09",
      description: "Patient Departing — Tracking",
      segments: @adt_tracking_segments
    },
    "ADT_A15" => %{
      name: "ADT_A15",
      description: "Pending Transfer",
      segments: [
        {:MSH, :required, :once},
        {:EVN, :required, :once},
        {:PID, :required, :once},
        {:PV1, :required, :once},
        {:PV2, :optional, :once},
        {:NTE, :optional, :repeating}
      ]
    },
    "ADT_A16" => %{
      name: "ADT_A16",
      description: "Pending Discharge",
      segments: [
        {:MSH, :required, :once},
        {:EVN, :required, :once},
        {:PID, :required, :once},
        {:PV1, :required, :once},
        {:PV2, :optional, :once},
        {:DG1, :optional, :repeating},
        {:NTE, :optional, :repeating}
      ]
    },
    "ADT_A21" => %{
      name: "ADT_A21",
      description: "Patient Goes on a Leave of Absence",
      segments: @adt_leave_segments
    },
    "ADT_A24" => %{
      name: "ADT_A24",
      description: "Link Patient Information",
      segments: [
        {:MSH, :required, :once},
        {:EVN, :required, :once},
        {:PID, :required, :repeating},
        {:PV1, :optional, :repeating},
        {:NTE, :optional, :repeating}
      ]
    },
    "ADT_A37" => %{
      name: "ADT_A37",
      description: "Unlink Patient Information",
      segments: [
        {:MSH, :required, :once},
        {:EVN, :required, :once},
        {:PID, :required, :repeating},
        {:PV1, :optional, :repeating},
        {:NTE, :optional, :repeating}
      ]
    },
    "ADT_A38" => %{
      name: "ADT_A38",
      description: "Cancel Pre-admit",
      segments: [
        {:MSH, :required, :once},
        {:EVN, :required, :once},
        {:PID, :required, :once},
        {:PV1, :required, :once},
        {:PV2, :optional, :once},
        {:DG1, :optional, :repeating},
        {:NTE, :optional, :repeating}
      ]
    },
    "ADT_A39" => %{
      name: "ADT_A39",
      description: "Merge Patient — Patient ID",
      segments: [
        {:MSH, :required, :once},
        {:EVN, :required, :once},
        {:PID, :required, :repeating},
        {:MRG, :required, :repeating},
        {:PV1, :optional, :repeating},
        {:NTE, :optional, :repeating}
      ]
    },
    "ORM_O01" => %{
      name: "ORM_O01",
      description: "General Order Message",
      segments: [
        {:MSH, :required, :once},
        {:NTE, :optional, :repeating},
        {:PID, :optional, :once},
        {:PV1, :optional, :once},
        {:IN1, :optional, :repeating},
        {:ORC, :required, :repeating},
        {:OBR, :optional, :repeating},
        {:NTE, :optional, :repeating},
        {:OBX, :optional, :repeating}
      ]
    },
    "ORU_R01" => %{
      name: "ORU_R01",
      description: "Unsolicited Observation Result",
      segments: [
        {:MSH, :required, :once},
        {:PID, :optional, :once},
        {:PV1, :optional, :once},
        {:ORC, :optional, :repeating},
        {:OBR, :required, :repeating},
        {:OBX, :optional, :repeating},
        {:NTE, :optional, :repeating}
      ]
    },
    "SIU_S12" => %{
      name: "SIU_S12",
      description: "Notification of New Appointment Booking",
      segments: [
        {:MSH, :required, :once},
        {:SCH, :required, :once},
        {:NTE, :optional, :repeating},
        {:PID, :optional, :once},
        {:PV1, :optional, :once},
        {:RGS, :required, :repeating},
        {:AIS, :optional, :repeating},
        {:NTE, :optional, :repeating}
      ]
    },
    "ACK" => %{
      name: "ACK",
      description: "General Acknowledgment",
      segments: [
        {:MSH, :required, :once},
        {:MSA, :required, :once},
        {:ERR, :optional, :repeating}
      ]
    }
  }

  @doc "Returns the definition for a message structure, or nil."
  @spec get(binary()) :: definition() | nil
  def get(structure), do: Map.get(@definitions, structure)

  @doc "Returns all defined message structures."
  @spec all() :: %{binary() => definition()}
  def all, do: @definitions

  @doc "Returns the list of defined message structure names."
  @spec names() :: [binary()]
  def names, do: Map.keys(@definitions)

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
  Validates segment presence against the message definition.

  Returns `:ok` when all required segments are present, or
  `{:error, errors}` with a list of error maps for each missing
  required segment. Unknown structures (no definition) pass silently.
  """
  @spec validate_structure(binary(), [binary()]) :: :ok | {:error, [map()]}
  def validate_structure(nil, _segment_ids), do: :ok
  def validate_structure("", _segment_ids), do: :ok

  def validate_structure(structure, segment_ids) do
    case get(structure) do
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

      definition ->
        case check_required_segments(definition.segments, segment_ids) do
          [] -> :ok
          errors -> {:error, errors}
        end
    end
  end

  defp check_required_segments(rules, segment_ids) do
    rules
    |> Enum.filter(fn {_seg, optionality, _rep} -> optionality == :required end)
    |> Enum.map(fn {seg, _, _} -> seg end)
    |> Enum.uniq()
    |> Enum.reject(fn seg -> Atom.to_string(seg) in segment_ids end)
    |> Enum.map(fn seg ->
      %{
        level: :error,
        location: "message",
        field: nil,
        message: "Required segment #{seg} is missing"
      }
    end)
  end
end
