defmodule HL7v2.MessageDefinition do
  @moduledoc """
  Defines expected segment structures for common HL7v2 message types.

  Each definition specifies which segments are required, optional, and
  repeating for a given message type (e.g., ADT_A01, ORM_O01, ORU_R01).
  Used by the validation engine for message-level structure validation.
  """

  @type segment_rule :: {atom(), :required | :optional, :once | :repeating}
  @type definition :: %{
          name: binary(),
          description: binary(),
          segments: [segment_rule()]
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
    "ADT_A08" => %{
      name: "ADT_A08",
      description: "Update Patient Information",
      segments: @adt_admit_segments
    },
    "ORM_O01" => %{
      name: "ORM_O01",
      description: "General Order Message",
      segments: [
        {:MSH, :required, :once},
        {:NTE, :optional, :repeating},
        {:PID, :required, :once},
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
        {:PID, :required, :once},
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
        {:PID, :required, :once},
        {:PV1, :optional, :once},
        {:AIS, :required, :repeating},
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
  Validates segment presence against the message definition.

  Returns `:ok` when all required segments are present, or
  `{:error, errors}` with a list of error maps for each missing
  required segment. Unknown structures (no definition) pass silently.
  """
  @spec validate_structure(binary(), [binary()]) :: :ok | {:error, [map()]}
  def validate_structure(structure, segment_ids) do
    case get(structure) do
      nil ->
        :ok

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
