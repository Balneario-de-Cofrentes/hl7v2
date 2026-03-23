defmodule HL7v2.Standard.MessageStructure do
  @moduledoc """
  HL7 v2.5.1 abstract message structure definitions.

  Each message structure is defined as a tree of segments and groups with
  cardinality constraints, following the HL7 v2.5.1 abstract message definitions.

  ## Structure AST

  Each node is one of:

  - `{:segment, id, optionality}` — a single segment occurrence
  - `{:segment, id, optionality, :repeating}` — a repeating segment
  - `{:group, name, optionality, children}` — a segment group (single)
  - `{:group, name, optionality, :repeating, children}` — a repeating group

  Where:
  - `id` is an atom like `:MSH`, `:PID`, `:PV1`
  - `name` is a group name atom like `:PATIENT`, `:VISIT`, `:ORDER`
  - `optionality` is `:required` or `:optional`
  - `children` is a list of nested nodes

  ## Limitations

  These definitions represent the **segments this library knows about** within
  each structure. Standard segments that are unsupported (PD1, ROL, SFT, etc.)
  are included as segment references but will be preserved as raw tuples during
  typed parsing. The structure definitions are complete enough for presence and
  ordering validation within the implemented subset.

  Source: HL7 v2.5.1 abstract message definitions via
  https://www.hl7.eu/HL7v2x/v251/hl7v251msgstruct.htm and
  https://hl7-definition.caristix.com/v2/HL7v2.5.1/TriggerEvents
  """

  @type structure_node ::
          {:segment, atom(), :required | :optional}
          | {:segment, atom(), :required | :optional, :repeating}
          | {:group, atom(), :required | :optional, [structure_node()]}
          | {:group, atom(), :required | :optional, :repeating, [structure_node()]}

  @type structure :: %{
          name: binary(),
          description: binary(),
          nodes: [structure_node()]
        }

  # ---------------------------------------------------------------------------
  # ADT Structures
  # ---------------------------------------------------------------------------

  @adt_a01 %{
    name: "ADT_A01",
    description: "Admit/Visit Notification",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:group, :PATIENT, :required,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :ROL, :optional, :repeating},
         {:segment, :NK1, :optional, :repeating},
         {:group, :VISIT, :required,
          [
            {:segment, :PV1, :required},
            {:segment, :PV2, :optional},
            {:segment, :ROL, :optional, :repeating}
          ]},
         {:segment, :DB1, :optional, :repeating},
         {:segment, :AL1, :optional, :repeating},
         {:segment, :DG1, :optional, :repeating},
         {:segment, :DRG, :optional},
         {:group, :PROCEDURE, :optional, :repeating,
          [
            {:segment, :PR1, :required},
            {:segment, :ROL, :optional, :repeating}
          ]},
         {:segment, :GT1, :optional, :repeating},
         {:group, :INSURANCE, :optional, :repeating,
          [
            {:segment, :IN1, :required},
            {:segment, :IN2, :optional},
            {:segment, :IN3, :optional, :repeating},
            {:segment, :ROL, :optional, :repeating}
          ]},
         {:group, :OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:segment, :ACC, :optional},
         {:segment, :UB1, :optional},
         {:segment, :UB2, :optional},
         {:segment, :PDA, :optional}
       ]}
    ]
  }

  @adt_a02 %{
    name: "ADT_A02",
    description: "Transfer a Patient",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:segment, :PV1, :required},
      {:segment, :PV2, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:segment, :DB1, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  @adt_a03 %{
    name: "ADT_A03",
    description: "Discharge/End Visit",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:segment, :PV1, :required},
      {:segment, :PV2, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:segment, :DB1, :optional, :repeating},
      {:segment, :DG1, :optional, :repeating},
      {:segment, :DRG, :optional},
      {:group, :PROCEDURE, :optional, :repeating,
       [
         {:segment, :PR1, :required},
         {:segment, :ROL, :optional, :repeating}
       ]},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ADT_A05: Pre-admit (shared with A14, A28, A31)
  @adt_a05 %{
    name: "ADT_A05",
    description: "Pre-admit a Patient",
    nodes: @adt_a01.nodes
  }

  # ADT_A06: Change outpatient to inpatient (shared with A07)
  @adt_a06 %{
    name: "ADT_A06",
    description: "Change an Outpatient to an Inpatient",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:segment, :MRG, :optional},
      {:segment, :NK1, :optional, :repeating},
      {:segment, :PV1, :required},
      {:segment, :PV2, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:segment, :DB1, :optional, :repeating},
      {:segment, :AL1, :optional, :repeating},
      {:segment, :DG1, :optional, :repeating},
      {:segment, :DRG, :optional},
      {:group, :PROCEDURE, :optional, :repeating,
       [
         {:segment, :PR1, :required},
         {:segment, :ROL, :optional, :repeating}
       ]},
      {:segment, :GT1, :optional, :repeating},
      {:group, :INSURANCE, :optional, :repeating,
       [
         {:segment, :IN1, :required},
         {:segment, :IN2, :optional},
         {:segment, :IN3, :optional, :repeating},
         {:segment, :ROL, :optional, :repeating}
       ]},
      {:segment, :ACC, :optional},
      {:segment, :UB1, :optional},
      {:segment, :UB2, :optional},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ADT_A09: Patient departing/tracking (shared with A10, A11)
  @adt_a09 %{
    name: "ADT_A09",
    description: "Patient Departing — Tracking",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :PV1, :required},
      {:segment, :PV2, :optional},
      {:segment, :DB1, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ADT_A12: Cancel transfer
  @adt_a12 %{
    name: "ADT_A12",
    description: "Cancel Transfer",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :PV1, :required},
      {:segment, :PV2, :optional},
      {:segment, :DB1, :optional, :repeating},
      {:segment, :DG1, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ADT_A15: Pending admit/transfer (shared with A15)
  @adt_a15 %{
    name: "ADT_A15",
    description: "Pending Transfer",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:segment, :PV1, :required},
      {:segment, :PV2, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:segment, :DB1, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ADT_A16: Pending discharge
  @adt_a16 %{
    name: "ADT_A16",
    description: "Pending Discharge",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:segment, :PV1, :required},
      {:segment, :PV2, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:segment, :DB1, :optional, :repeating},
      {:segment, :DG1, :optional, :repeating},
      {:segment, :DRG, :optional},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ADT_A21: Leave of absence (shared with A22-A27)
  @adt_a21 %{
    name: "ADT_A21",
    description: "Patient Goes on Leave of Absence",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :PV1, :required},
      {:segment, :PV2, :optional},
      {:segment, :DB1, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ADT_A24: Link patient information
  @adt_a24 %{
    name: "ADT_A24",
    description: "Link Patient Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :PV1, :optional},
      {:segment, :DB1, :optional, :repeating},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :PV1, :optional},
      {:segment, :DB1, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ADT_A37: Unlink patient information
  @adt_a37 %{
    name: "ADT_A37",
    description: "Unlink Patient Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :PV1, :optional},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :PV1, :optional},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ADT_A38: Cancel pre-admit
  @adt_a38 %{
    name: "ADT_A38",
    description: "Cancel Pre-admit",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :PV1, :required},
      {:segment, :PV2, :optional},
      {:segment, :DB1, :optional, :repeating},
      {:segment, :DG1, :optional, :repeating},
      {:segment, :DRG, :optional},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ADT_A39: Merge patient (shared with A40, A41, A42)
  @adt_a39 %{
    name: "ADT_A39",
    description: "Merge Patient — Patient ID",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:group, :PATIENT, :required, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :MRG, :required},
         {:segment, :PV1, :optional}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # ORM / ORU / SIU / ACK Structures
  # ---------------------------------------------------------------------------

  @orm_o01 %{
    name: "ORM_O01",
    description: "General Order Message",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :PATIENT, :optional,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :NTE, :optional, :repeating},
         {:group, :PATIENT_VISIT, :optional,
          [
            {:segment, :PV1, :required},
            {:segment, :PV2, :optional}
          ]},
         {:group, :INSURANCE, :optional, :repeating,
          [
            {:segment, :IN1, :required},
            {:segment, :IN2, :optional},
            {:segment, :IN3, :optional}
          ]},
         {:segment, :GT1, :optional}
       ]},
      {:group, :ORDER, :required, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :ORDER_DETAIL, :optional,
          [
            {:segment, :OBR, :required},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :CTD, :optional},
            {:segment, :DG1, :optional, :repeating},
            {:group, :OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :required},
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]},
         {:segment, :FT1, :optional, :repeating},
         {:segment, :CTI, :optional, :repeating},
         {:segment, :BLG, :optional}
       ]}
    ]
  }

  @oru_r01 %{
    name: "ORU_R01",
    description: "Unsolicited Observation Result",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :PATIENT_RESULT, :required, :repeating,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :PD1, :optional},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :NK1, :optional, :repeating},
            {:group, :VISIT, :optional,
             [
               {:segment, :PV1, :required},
               {:segment, :PV2, :optional}
             ]}
          ]},
         {:group, :ORDER_OBSERVATION, :required, :repeating,
          [
            {:segment, :ORC, :optional},
            {:segment, :OBR, :required},
            {:segment, :NTE, :optional, :repeating},
            {:group, :TIMING_QTY, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:segment, :CTD, :optional},
            {:group, :OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :required},
               {:segment, :NTE, :optional, :repeating}
             ]},
            {:group, :SPECIMEN, :optional, :repeating,
             [
               {:segment, :SPM, :required},
               {:group, :OBSERVATION, :optional, :repeating,
                [
                  {:segment, :OBX, :required},
                  {:segment, :NTE, :optional, :repeating}
                ]}
             ]},
            {:segment, :FT1, :optional, :repeating},
            {:segment, :CTI, :optional, :repeating}
          ]}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  @siu_s12 %{
    name: "SIU_S12",
    description: "Notification of New Appointment Booking",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SCH, :required},
      {:segment, :TQ1, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :PATIENT, :optional, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :PV1, :optional},
         {:segment, :PV2, :optional},
         {:segment, :DG1, :optional, :repeating}
       ]},
      {:group, :RESOURCES, :required, :repeating,
       [
         {:segment, :RGS, :required},
         {:group, :SERVICE, :optional, :repeating,
          [
            {:segment, :AIS, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :GENERAL_RESOURCE, :optional, :repeating,
          [
            {:segment, :AIG, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :LOCATION_RESOURCE, :optional, :repeating,
          [
            {:segment, :AIL, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :PERSONNEL_RESOURCE, :optional, :repeating,
          [
            {:segment, :AIP, :required},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  @ack %{
    name: "ACK",
    description: "General Acknowledgment",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating}
    ]
  }

  # ---------------------------------------------------------------------------
  # RDE / RDS Structures (Pharmacy)
  # ---------------------------------------------------------------------------

  @rde_o11 %{
    name: "RDE_O11",
    description: "Pharmacy/Treatment Encoded Order",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :PATIENT, :optional,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :NTE, :optional, :repeating},
         {:group, :PATIENT_VISIT, :optional,
          [
            {:segment, :PV1, :required},
            {:segment, :PV2, :optional}
          ]},
         {:group, :INSURANCE, :optional, :repeating,
          [
            {:segment, :IN1, :required},
            {:segment, :IN2, :optional},
            {:segment, :IN3, :optional}
          ]}
       ]},
      {:group, :ORDER, :required, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :TIMING_ENCODED, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:segment, :RXE, :required},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :RXR, :required, :repeating},
         {:segment, :RXC, :optional, :repeating},
         {:group, :OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:segment, :FT1, :optional, :repeating},
         {:segment, :CTI, :optional, :repeating}
       ]}
    ]
  }

  @rds_o13 %{
    name: "RDS_O13",
    description: "Pharmacy/Treatment Dispense",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :PATIENT, :optional,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :NTE, :optional, :repeating},
         {:group, :PATIENT_VISIT, :optional,
          [
            {:segment, :PV1, :required},
            {:segment, :PV2, :optional}
          ]},
         {:group, :INSURANCE, :optional, :repeating,
          [
            {:segment, :IN1, :required},
            {:segment, :IN2, :optional},
            {:segment, :IN3, :optional}
          ]}
       ]},
      {:group, :ORDER, :required, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :TIMING, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:segment, :RXD, :required},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :RXR, :required, :repeating},
         {:segment, :RXC, :optional, :repeating},
         {:group, :OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:segment, :FT1, :optional, :repeating}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # MDM Structures (Medical Document Management)
  # ---------------------------------------------------------------------------

  @mdm_t02 %{
    name: "MDM_T02",
    description: "Original Document Notification and Content",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PV1, :required},
      {:segment, :TXA, :required},
      {:group, :OBSERVATION, :required, :repeating,
       [
         {:segment, :OBX, :required},
         {:segment, :NTE, :optional, :repeating}
       ]}
    ]
  }

  @structures %{
    "ADT_A01" => @adt_a01,
    "ADT_A02" => @adt_a02,
    "ADT_A03" => @adt_a03,
    "ADT_A04" => %{@adt_a01 | name: "ADT_A04", description: "Register a Patient"},
    "ADT_A05" => @adt_a05,
    "ADT_A06" => @adt_a06,
    "ADT_A08" => %{@adt_a01 | name: "ADT_A08", description: "Update Patient Information"},
    "ADT_A09" => @adt_a09,
    "ADT_A12" => @adt_a12,
    "ADT_A15" => @adt_a15,
    "ADT_A16" => @adt_a16,
    "ADT_A21" => @adt_a21,
    "ADT_A24" => @adt_a24,
    "ADT_A37" => @adt_a37,
    "ADT_A38" => @adt_a38,
    "ADT_A39" => @adt_a39,
    "MDM_T02" => @mdm_t02,
    "ORM_O01" => @orm_o01,
    "ORU_R01" => @oru_r01,
    "RDE_O11" => @rde_o11,
    "RDS_O13" => @rds_o13,
    "SIU_S12" => @siu_s12,
    "ACK" => @ack
  }

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc "Returns the structure definition for a message structure name, or nil."
  @spec get(binary()) :: structure() | nil
  def get(name), do: Map.get(@structures, name)

  @doc "Returns all defined structure names."
  @spec names() :: [binary()]
  def names, do: Map.keys(@structures) |> Enum.sort()

  @doc "Returns the count of defined structures."
  @spec count() :: non_neg_integer()
  def count, do: map_size(@structures)

  @doc """
  Extracts the flat list of required segment IDs from a structure definition.

  This is the bridge to the current presence-only validation: it walks the
  structure tree and collects all required segment IDs, ignoring group nesting.
  """
  @spec required_segments(structure()) :: [atom()]
  def required_segments(%{nodes: nodes}) do
    extract_required(nodes)
    |> Enum.uniq()
  end

  defp extract_required([]), do: []

  defp extract_required([{:segment, id, :required} | rest]) do
    [id | extract_required(rest)]
  end

  defp extract_required([{:segment, id, :required, :repeating} | rest]) do
    [id | extract_required(rest)]
  end

  defp extract_required([{:segment, _, :optional} | rest]) do
    extract_required(rest)
  end

  defp extract_required([{:segment, _, :optional, :repeating} | rest]) do
    extract_required(rest)
  end

  defp extract_required([{:group, _, :required, children} | rest]) do
    extract_required(children) ++ extract_required(rest)
  end

  defp extract_required([{:group, _, :required, :repeating, children} | rest]) do
    extract_required(children) ++ extract_required(rest)
  end

  defp extract_required([{:group, _, :optional, _children} | rest]) do
    extract_required(rest)
  end

  defp extract_required([{:group, _, :optional, :repeating, _children} | rest]) do
    extract_required(rest)
  end
end
