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

  These definitions cover segments within 100+ supported message structures.
  Most referenced segments are typed; a few less-common ones (e.g., OSD, RMC,
  DDI) remain as `:raw` field types within their segments. Run
  `mix hl7v2.coverage --detail` for per-segment field completeness.

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
      {:segment, :OBX, :optional, :repeating},
      {:segment, :PDA, :optional}
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
      {:segment, :ACC, :optional},
      {:segment, :PDA, :optional}
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
      {:segment, :OBX, :optional, :repeating},
      {:segment, :DG1, :optional, :repeating}
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
      {:segment, :OBX, :optional, :repeating},
      {:segment, :DG1, :optional, :repeating}
    ]
  }

  # ADT_A15: Pending admit/transfer
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
      {:segment, :OBX, :optional, :repeating},
      {:segment, :DG1, :optional, :repeating}
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
      {:segment, :OBX, :optional, :repeating},
      {:segment, :DG1, :optional, :repeating},
      {:segment, :DRG, :optional}
    ]
  }

  # ADT_A17: Swap patients
  @adt_a17 %{
    name: "ADT_A17",
    description: "Swap Patients",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:group, :PATIENT_1, :required,
       [
         {:segment, :PID, :required},
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional},
         {:segment, :DB1, :optional, :repeating},
         {:segment, :OBX, :optional, :repeating}
       ]},
      {:group, :PATIENT_2, :required,
       [
         {:segment, :PID, :required},
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional},
         {:segment, :DB1, :optional, :repeating},
         {:segment, :OBX, :optional, :repeating}
       ]}
    ]
  }

  # ADT_A20: Bed status update
  @adt_a20 %{
    name: "ADT_A20",
    description: "Bed Status Update",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :NPU, :required}
    ]
  }

  # ADT_A21: Leave of absence (shared with A22-A27, A29, A32, A33)
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
      {:segment, :OBX, :optional, :repeating}
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
      {:segment, :DB1, :optional, :repeating}
    ]
  }

  # ADT_A30: Merge person info (shared with A34, A35, A36)
  @adt_a30 %{
    name: "ADT_A30",
    description: "Merge Person Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :MRG, :required}
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
      {:segment, :PV1, :optional}
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
      {:segment, :OBX, :optional, :repeating},
      {:segment, :DG1, :optional, :repeating},
      {:segment, :DRG, :optional}
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

  # ADT_A43: Move patient info — patient identifier list (shared with A44)
  @adt_a43 %{
    name: "ADT_A43",
    description: "Move Patient Information — Patient Identifier List",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:group, :PATIENT, :required, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :MRG, :required}
       ]}
    ]
  }

  # ADT_A45: Move visit info — merge
  @adt_a45 %{
    name: "ADT_A45",
    description: "Move Visit Information — Visit Number",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:group, :MERGE_INFO, :required, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :MRG, :required},
         {:segment, :PV1, :required}
       ]}
    ]
  }

  # ADT_A50: Change visit number (shared with A52, A53, A54, A55)
  @adt_a50 %{
    name: "ADT_A50",
    description: "Change Visit Number",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :MRG, :required},
      {:segment, :PV1, :required}
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

  # ---------------------------------------------------------------------------
  # BAR Structures (Billing)
  # ---------------------------------------------------------------------------

  # BAR_P01: Add/change billing account (shared with P05)
  @bar_p01 %{
    name: "BAR_P01",
    description: "Add Patient Account",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:group, :VISIT, :required, :repeating,
       [
         {:segment, :PV1, :optional},
         {:segment, :PV2, :optional},
         {:segment, :ROL, :optional, :repeating},
         {:segment, :DB1, :optional, :repeating},
         {:segment, :OBX, :optional, :repeating},
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
         {:segment, :UB2, :optional}
       ]}
    ]
  }

  # BAR_P02: Purge patient account (shared with P06)
  @bar_p02 %{
    name: "BAR_P02",
    description: "Purge Patient Account",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:group, :PATIENT, :required, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PV1, :required}
       ]}
    ]
  }

  # BAR_P10: Transmit ambulance billing
  @bar_p10 %{
    name: "BAR_P10",
    description: "Transmit Ambulance Billing",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:group, :PATIENT, :required, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PV1, :required},
         {:segment, :DG1, :optional, :repeating},
         {:segment, :GP1, :optional},
         {:group, :PROCEDURE, :optional, :repeating,
          [
            {:segment, :PR1, :required},
            {:segment, :GP2, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # BAR_P12: Update diagnosis/procedure
  @bar_p12 %{
    name: "BAR_P12",
    description: "Update Diagnosis/Procedure",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PV1, :required},
      {:segment, :DG1, :optional, :repeating},
      {:group, :PROCEDURE, :optional, :repeating,
       [
         {:segment, :PR1, :required},
         {:segment, :ROL, :optional, :repeating}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # DFT Structures (Financial Transaction)
  # ---------------------------------------------------------------------------

  # DFT_P03: Post detail financial transaction
  @dft_p03 %{
    name: "DFT_P03",
    description: "Post Detail Financial Transaction",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:group, :VISIT, :optional,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional},
         {:segment, :ROL, :optional, :repeating},
         {:segment, :DB1, :optional, :repeating}
       ]},
      {:group, :FINANCIAL, :required, :repeating,
       [
         {:segment, :FT1, :required},
         {:segment, :NTE, :optional, :repeating},
         {:group, :FINANCIAL_PROCEDURE, :optional, :repeating,
          [
            {:segment, :PR1, :required},
            {:segment, :ROL, :optional, :repeating}
          ]},
         {:group, :FINANCIAL_INSURANCE, :optional, :repeating,
          [
            {:segment, :IN1, :required},
            {:segment, :IN2, :optional},
            {:segment, :IN3, :optional, :repeating}
          ]},
         {:group, :FINANCIAL_GUARANTOR, :optional, :repeating,
          [
            {:segment, :GT1, :required},
            {:group, :GUARANTOR_INSURANCE, :optional, :repeating,
             [
               {:segment, :IN1, :required},
               {:segment, :IN2, :optional},
               {:segment, :IN3, :optional, :repeating}
             ]}
          ]}
       ]}
    ]
  }

  # DFT_P11: Post detail financial transaction — new
  @dft_p11 %{
    name: "DFT_P11",
    description: "Post Detail Financial Transaction — New",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:group, :VISIT, :optional,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional},
         {:segment, :ROL, :optional, :repeating},
         {:segment, :DB1, :optional, :repeating}
       ]},
      {:group, :FINANCIAL, :required, :repeating,
       [
         {:segment, :FT1, :required},
         {:group, :FINANCIAL_PROCEDURE, :optional, :repeating,
          [
            {:segment, :PR1, :required},
            {:segment, :ROL, :optional, :repeating}
          ]},
         {:group, :FINANCIAL_INSURANCE, :optional, :repeating,
          [
            {:segment, :IN1, :required},
            {:segment, :IN2, :optional},
            {:segment, :IN3, :optional, :repeating},
            {:segment, :ROL, :optional, :repeating}
          ]},
         {:group, :FINANCIAL_GUARANTOR, :optional, :repeating,
          [
            {:segment, :GT1, :required}
          ]}
       ]},
      {:group, :DIAGNOSIS, :optional, :repeating,
       [
         {:segment, :DG1, :required},
         {:segment, :DG1, :optional}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Additional Pharmacy Structures
  # ---------------------------------------------------------------------------

  # RGV_O15: Pharmacy/Treatment Give
  @rgv_o15 %{
    name: "RGV_O15",
    description: "Pharmacy/Treatment Give",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :PATIENT, :optional,
       [
         {:segment, :PID, :required},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :AL1, :optional, :repeating},
         {:group, :PATIENT_VISIT, :optional,
          [
            {:segment, :PV1, :required},
            {:segment, :PV2, :optional}
          ]}
       ]},
      {:group, :ORDER, :required, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :TIMING_GIVE, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:group, :GIVE, :required,
          [
            {:segment, :RXG, :required},
            {:group, :TIMING_GIVE, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:segment, :RXR, :required, :repeating},
            {:segment, :RXC, :optional, :repeating}
          ]},
         {:group, :OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :optional},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # RAS_O17: Pharmacy/Treatment Administration
  @ras_o17 %{
    name: "RAS_O17",
    description: "Pharmacy/Treatment Administration",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :PATIENT, :optional,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :AL1, :optional, :repeating},
         {:group, :PATIENT_VISIT, :optional,
          [
            {:segment, :PV1, :required},
            {:segment, :PV2, :optional}
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
         {:group, :ADMINISTRATION, :required, :repeating,
          [
            {:segment, :RXA, :required},
            {:segment, :RXR, :required},
            {:segment, :OBX, :optional, :repeating}
          ]},
         {:segment, :CTI, :optional, :repeating}
       ]}
    ]
  }

  # RRE_O12: Pharmacy/Treatment Encoded Order Acknowledgment
  @rre_o12 %{
    name: "RRE_O12",
    description: "Pharmacy/Treatment Encoded Order Acknowledgment",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :RESPONSE, :optional,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :TIMING, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:segment, :RXE, :required},
            {:segment, :RXR, :optional, :repeating},
            {:segment, :RXC, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # RRD_O14: Pharmacy/Treatment Dispense Acknowledgment
  @rrd_o14 %{
    name: "RRD_O14",
    description: "Pharmacy/Treatment Dispense Acknowledgment",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :RESPONSE, :optional,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :TIMING, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:group, :DISPENSE, :optional,
             [
               {:segment, :RXD, :required},
               {:segment, :RXR, :optional, :repeating},
               {:segment, :RXC, :optional, :repeating}
             ]}
          ]}
       ]}
    ]
  }

  # RRG_O16: Pharmacy/Treatment Give Acknowledgment
  @rrg_o16 %{
    name: "RRG_O16",
    description: "Pharmacy/Treatment Give Acknowledgment",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :RESPONSE, :optional,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :TIMING, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:group, :GIVE, :optional,
             [
               {:segment, :RXG, :required},
               {:group, :TIMING_GIVE, :optional, :repeating,
                [
                  {:segment, :TQ1, :required},
                  {:segment, :TQ2, :optional, :repeating}
                ]},
               {:segment, :RXR, :optional, :repeating},
               {:segment, :RXC, :optional, :repeating}
             ]}
          ]}
       ]}
    ]
  }

  # RRA_O18: Pharmacy/Treatment Administration Acknowledgment
  @rra_o18 %{
    name: "RRA_O18",
    description: "Pharmacy/Treatment Administration Acknowledgment",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :RESPONSE, :optional,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :TIMING, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:group, :ADMINISTRATION, :optional,
             [
               {:segment, :RXA, :optional, :repeating},
               {:segment, :RXR, :required}
             ]}
          ]}
       ]}
    ]
  }

  # OMP_O09: Pharmacy/Treatment Order
  @omp_o09 %{
    name: "OMP_O09",
    description: "Pharmacy/Treatment Order",
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
         {:group, :TIMING, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:segment, :RXO, :required},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :RXR, :required, :repeating},
         {:group, :OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:segment, :FT1, :optional, :repeating},
         {:segment, :BLG, :optional}
       ]}
    ]
  }

  # ORP_O10: Pharmacy/Treatment Order Acknowledgment
  @orp_o10 %{
    name: "ORP_O10",
    description: "Pharmacy/Treatment Order Acknowledgment",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :RESPONSE, :optional,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :TIMING, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:segment, :RXO, :optional},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :RXR, :optional, :repeating},
            {:segment, :RXC, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Lab Order Structures
  # ---------------------------------------------------------------------------

  # OML_O21: Laboratory Order
  @oml_o21 %{
    name: "OML_O21",
    description: "Laboratory Order",
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
         {:segment, :GT1, :optional},
         {:segment, :AL1, :optional, :repeating}
       ]},
      {:group, :ORDER, :required, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :TIMING, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:group, :OBSERVATION_REQUEST, :optional,
          [
            {:segment, :OBR, :required},
            {:segment, :TCD, :optional},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :DG1, :optional, :repeating},
            {:group, :OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :required},
               {:segment, :TCD, :optional},
               {:segment, :NTE, :optional, :repeating}
             ]},
            {:segment, :SPM, :optional},
            {:segment, :OBX, :optional, :repeating},
            {:group, :PRIOR_RESULT, :optional, :repeating,
             [
               {:segment, :AL1, :optional, :repeating},
               {:group, :ORDER_PRIOR, :required, :repeating,
                [
                  {:segment, :ORC, :required},
                  {:segment, :OBR, :required},
                  {:segment, :NTE, :optional, :repeating},
                  {:group, :OBSERVATION_PRIOR, :optional, :repeating,
                   [
                     {:segment, :OBX, :required},
                     {:segment, :NTE, :optional, :repeating}
                   ]}
                ]}
             ]}
          ]},
         {:segment, :FT1, :optional, :repeating},
         {:segment, :CTI, :optional, :repeating},
         {:segment, :BLG, :optional}
       ]}
    ]
  }

  # ORL_O22: General Laboratory Order Response
  @orl_o22 %{
    name: "ORL_O22",
    description: "General Laboratory Order Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :RESPONSE, :optional,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :TIMING, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:group, :OBSERVATION_REQUEST, :optional,
             [
               {:segment, :OBR, :required},
               {:segment, :SPM, :optional},
               {:segment, :SAC, :optional}
             ]}
          ]}
       ]}
    ]
  }

  # OUL_R21: Unsolicited Laboratory Observation
  @oul_r21 %{
    name: "OUL_R21",
    description: "Unsolicited Laboratory Observation",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional},
      {:group, :PATIENT, :optional,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :PV1, :optional},
         {:segment, :PV2, :optional}
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
         {:group, :OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :optional},
            {:segment, :TCD, :optional},
            {:segment, :SID, :optional},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:segment, :CTI, :optional, :repeating}
       ]}
    ]
  }

  # ORU_R30: Unsolicited Point-Of-Care Observation Without Existing Order
  @oru_r30 %{
    name: "ORU_R30",
    description: "Unsolicited Point-Of-Care Observation Without Existing Order",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :OBX, :optional, :repeating},
      {:group, :ORDER_OBSERVATION, :required, :repeating,
       [
         {:segment, :ORC, :required},
         {:segment, :OBR, :required},
         {:segment, :NTE, :optional, :repeating},
         {:group, :TIMING_QTY, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:group, :OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # General Clinical Order Structures
  # ---------------------------------------------------------------------------

  # OMG_O19: General Clinical Order
  @omg_o19 %{
    name: "OMG_O19",
    description: "General Clinical Order",
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
         {:segment, :GT1, :optional},
         {:segment, :AL1, :optional, :repeating}
       ]},
      {:group, :ORDER, :required, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :TIMING, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:segment, :OBR, :required},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :CTD, :optional},
         {:segment, :DG1, :optional, :repeating},
         {:group, :OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :PRIOR_RESULT, :optional, :repeating,
          [
            {:group, :ORDER_PRIOR, :required, :repeating,
             [
               {:segment, :ORC, :required},
               {:segment, :OBR, :required},
               {:segment, :NTE, :optional, :repeating},
               {:group, :OBSERVATION_PRIOR, :optional, :repeating,
                [
                  {:segment, :OBX, :required},
                  {:segment, :NTE, :optional, :repeating}
                ]}
             ]}
          ]},
         {:segment, :FT1, :optional, :repeating},
         {:segment, :CTI, :optional, :repeating},
         {:segment, :BLG, :optional}
       ]}
    ]
  }

  # ORA_R33: Observation Report Acknowledgment
  @ora_r33 %{
    name: "ORA_R33",
    description: "Observation Report Acknowledgment",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating}
    ]
  }

  # ORG_O20: General Clinical Order Response
  @org_o20 %{
    name: "ORG_O20",
    description: "General Clinical Order Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :RESPONSE, :optional,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :TIMING, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:segment, :OBR, :optional},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :CTI, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Dietary Order Structures
  # ---------------------------------------------------------------------------

  # OMD_O03: Dietary Order
  @omd_o03 %{
    name: "OMD_O03",
    description: "Dietary Order",
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
         {:segment, :GT1, :optional},
         {:segment, :AL1, :optional, :repeating}
       ]},
      {:group, :ORDER_DIET, :required, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :DIET, :optional,
          [
            {:segment, :ODS, :required, :repeating},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER_TRAY, :optional,
          [
            {:segment, :ODT, :required, :repeating},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Stock/Supply Order Structures
  # ---------------------------------------------------------------------------

  # OMS_O05: Stock Requisition Order
  @oms_o05 %{
    name: "OMS_O05",
    description: "Stock Requisition Order",
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
         {:segment, :GT1, :optional},
         {:segment, :AL1, :optional, :repeating}
       ]},
      {:group, :ORDER, :required, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :TIMING, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:segment, :RQD, :required},
         {:segment, :RQ1, :optional},
         {:segment, :NTE, :optional, :repeating},
         {:group, :OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:segment, :BLG, :optional}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Master File Structures
  # ---------------------------------------------------------------------------

  # MFN_M01: Master File Not Otherwise Specified
  @mfn_m01 %{
    name: "MFN_M01",
    description: "Master File Not Otherwise Specified",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :NTE, :optional, :repeating}
       ]}
    ]
  }

  # MFN_M02: Staff/Practitioner Master File
  @mfn_m02 %{
    name: "MFN_M02",
    description: "Staff/Practitioner Master File",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_STAFF, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :STF, :required},
         {:segment, :PRA, :optional},
         {:segment, :ORG, :optional}
       ]}
    ]
  }

  # MFN_M05: Patient Location Master File
  @mfn_m05 %{
    name: "MFN_M05",
    description: "Patient Location Master File",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_LOCATION, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :LOC, :required},
         {:segment, :LCH, :optional, :repeating},
         {:segment, :LRL, :optional, :repeating},
         {:group, :MF_LOC_DEPT, :optional, :repeating,
          [
            {:segment, :LDP, :required},
            {:segment, :LCH, :optional, :repeating},
            {:segment, :LCC, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # MFK_M01: Master File Ack
  @mfk_m01 %{
    name: "MFK_M01",
    description: "Master File Acknowledgment",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :MFI, :required},
      {:segment, :MFA, :optional, :repeating}
    ]
  }

  # MFQ_M01: Master File Query
  @mfq_m01 %{
    name: "MFQ_M01",
    description: "Master File Query",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional}
    ]
  }

  # ---------------------------------------------------------------------------
  # Query Structures
  # ---------------------------------------------------------------------------

  # QBP_Q21: Query by Parameter
  @qbp_q21 %{
    name: "QBP_Q21",
    description: "Query by Parameter",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QPD, :required},
      {:segment, :RCP, :required},
      {:segment, :DSC, :optional}
    ]
  }

  # RSP_K21: Segment Pattern Response
  @rsp_k21 %{
    name: "RSP_K21",
    description: "Segment Pattern Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:group, :QUERY_RESPONSE, :optional, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :NK1, :optional, :repeating},
         {:segment, :QRI, :optional}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # QCK_Q02: Cancel Query
  @qck_q02 %{
    name: "QCK_Q02",
    description: "Cancel Query",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :optional}
    ]
  }

  # QCN_J01: Cancel Subscription
  @qcn_j01 %{
    name: "QCN_J01",
    description: "Cancel Subscription",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QID, :required}
    ]
  }

  # RTB_K13: Tabular Response
  @rtb_k13 %{
    name: "RTB_K13",
    description: "Tabular Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:segment, :RDF, :optional},
      {:group, :ROW_DEFINITION, :optional, :repeating,
       [
         {:segment, :RDT, :required}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # RDY_K15: Display Based Response
  @rdy_k15 %{
    name: "RDY_K15",
    description: "Display Based Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:group, :DISPLAY, :optional, :repeating,
       [
         {:segment, :DSP, :required}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # ---------------------------------------------------------------------------
  # Vaccination Structures
  # ---------------------------------------------------------------------------

  # VXU_V04: Vaccination Update
  @vxu_v04 %{
    name: "VXU_V04",
    description: "Vaccination Update",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :NK1, :optional, :repeating},
      {:segment, :GT1, :optional, :repeating},
      {:group, :INSURANCE, :optional,
       [
         {:segment, :IN1, :required},
         {:segment, :IN2, :optional},
         {:segment, :IN3, :optional}
       ]},
      {:group, :ORDER, :optional, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :TIMING, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:segment, :RXA, :required},
         {:segment, :RXR, :optional},
         {:group, :OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # VXQ_V01: Query for Vaccination Record
  @vxq_v01 %{
    name: "VXQ_V01",
    description: "Query for Vaccination Record",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional}
    ]
  }

  # VXR_V03: Vaccination Record Response
  @vxr_v03 %{
    name: "VXR_V03",
    description: "Vaccination Record Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :ERR, :optional},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :NK1, :optional, :repeating},
      {:group, :ORDER, :optional, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :TIMING, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:segment, :RXA, :required},
         {:segment, :RXR, :optional},
         {:group, :OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Referral Structures
  # ---------------------------------------------------------------------------

  # REF_I12: Patient Referral
  @ref_i12 %{
    name: "REF_I12",
    description: "Patient Referral",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :RF1, :optional},
      {:group, :AUTHORIZATION_CONTACT, :optional,
       [
         {:segment, :AUT, :required},
         {:segment, :CTD, :optional}
       ]},
      {:group, :PROVIDER_CONTACT, :required, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:segment, :PID, :required},
      {:segment, :NK1, :optional, :repeating},
      {:segment, :GT1, :optional, :repeating},
      {:group, :INSURANCE, :optional, :repeating,
       [
         {:segment, :IN1, :required},
         {:segment, :IN2, :optional},
         {:segment, :IN3, :optional}
       ]},
      {:segment, :ACC, :optional},
      {:segment, :DG1, :optional, :repeating},
      {:segment, :DRG, :optional, :repeating},
      {:segment, :AL1, :optional, :repeating},
      {:group, :PROCEDURE, :optional, :repeating,
       [
         {:segment, :PR1, :required},
         {:segment, :ROL, :optional, :repeating}
       ]},
      {:group, :OBSERVATION, :optional, :repeating,
       [
         {:segment, :OBX, :required},
         {:segment, :NTE, :optional, :repeating}
       ]},
      {:group, :PATIENT_VISIT, :optional,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # RRI_I12: Return Referral Info
  @rri_i12 %{
    name: "RRI_I12",
    description: "Return Referral Info",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :RF1, :optional},
      {:group, :AUTHORIZATION_CONTACT, :optional,
       [
         {:segment, :AUT, :required},
         {:segment, :CTD, :optional}
       ]},
      {:group, :PROVIDER_CONTACT, :required, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:segment, :PID, :required},
      {:segment, :NK1, :optional, :repeating},
      {:segment, :GT1, :optional, :repeating},
      {:group, :INSURANCE, :optional, :repeating,
       [
         {:segment, :IN1, :required},
         {:segment, :IN2, :optional},
         {:segment, :IN3, :optional}
       ]},
      {:segment, :ACC, :optional},
      {:segment, :DG1, :optional, :repeating},
      {:segment, :DRG, :optional, :repeating},
      {:segment, :AL1, :optional, :repeating},
      {:group, :PROCEDURE, :optional, :repeating,
       [
         {:segment, :PR1, :required},
         {:segment, :ROL, :optional, :repeating}
       ]},
      {:group, :OBSERVATION, :optional, :repeating,
       [
         {:segment, :OBX, :required},
         {:segment, :NTE, :optional, :repeating}
       ]},
      {:group, :PATIENT_VISIT, :optional,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ---------------------------------------------------------------------------
  # Pathway/Problem/Goal Structures
  # ---------------------------------------------------------------------------

  # PPR_PC1: Problem Add/Update/Delete
  @ppr_pc1 %{
    name: "PPR_PC1",
    description: "Problem Add",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :PID, :required},
      {:group, :PATIENT_VISIT, :required,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:group, :PROBLEM, :required, :repeating,
       [
         {:segment, :PRB, :required},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :VAR, :optional, :repeating},
         {:group, :PROBLEM_ROLE, :optional, :repeating,
          [
            {:segment, :ROL, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
         {:group, :PATHWAY, :optional, :repeating,
          [
            {:segment, :PTH, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
         {:group, :PROBLEM_OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :GOAL, :optional, :repeating,
          [
            {:segment, :GOL, :required},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :VAR, :optional, :repeating},
            {:group, :GOAL_ROLE, :optional, :repeating,
             [
               {:segment, :ROL, :required},
               {:segment, :VAR, :optional, :repeating}
             ]},
            {:group, :GOAL_OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :required},
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]},
         {:group, :ORDER, :optional, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :ORDER_DETAIL, :optional,
             [
               {:segment, :OBR, :required},
               {:segment, :NTE, :optional, :repeating},
               {:segment, :VAR, :optional, :repeating},
               {:group, :ORDER_OBSERVATION, :optional, :repeating,
                [
                  {:segment, :OBX, :required},
                  {:segment, :NTE, :optional, :repeating},
                  {:segment, :VAR, :optional, :repeating}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # PGL_PC6: Goal Add/Update/Delete
  @pgl_pc6 %{
    name: "PGL_PC6",
    description: "Goal Add",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :PID, :required},
      {:group, :PATIENT_VISIT, :required,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:group, :GOAL, :required, :repeating,
       [
         {:segment, :GOL, :required},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :VAR, :optional, :repeating},
         {:group, :GOAL_ROLE, :optional, :repeating,
          [
            {:segment, :ROL, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
         {:group, :PATHWAY, :optional, :repeating,
          [
            {:segment, :PTH, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
         {:group, :GOAL_OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :PROBLEM, :optional, :repeating,
          [
            {:segment, :PRB, :required},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :VAR, :optional, :repeating},
            {:group, :PROBLEM_ROLE, :optional, :repeating,
             [
               {:segment, :ROL, :required},
               {:segment, :VAR, :optional, :repeating}
             ]},
            {:group, :PROBLEM_OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :required},
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]},
         {:group, :ORDER, :optional, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :ORDER_DETAIL, :optional,
             [
               {:segment, :OBR, :required},
               {:segment, :NTE, :optional, :repeating},
               {:segment, :VAR, :optional, :repeating},
               {:group, :ORDER_OBSERVATION, :optional, :repeating,
                [
                  {:segment, :OBX, :required},
                  {:segment, :NTE, :optional, :repeating},
                  {:segment, :VAR, :optional, :repeating}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # PPP_PCB: Pathway Add/Update/Delete
  @ppp_pcb %{
    name: "PPP_PCB",
    description: "Pathway Add",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :PID, :required},
      {:group, :PATIENT_VISIT, :required,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:group, :PATHWAY, :required, :repeating,
       [
         {:segment, :PTH, :required},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :VAR, :optional, :repeating},
         {:group, :PATHWAY_ROLE, :optional, :repeating,
          [
            {:segment, :ROL, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
         {:group, :PROBLEM, :optional, :repeating,
          [
            {:segment, :PRB, :required},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :VAR, :optional, :repeating},
            {:group, :PROBLEM_ROLE, :optional, :repeating,
             [
               {:segment, :ROL, :required},
               {:segment, :VAR, :optional, :repeating}
             ]},
            {:group, :PROBLEM_OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :required},
               {:segment, :NTE, :optional, :repeating}
             ]},
            {:group, :GOAL, :optional, :repeating,
             [
               {:segment, :GOL, :required},
               {:segment, :NTE, :optional, :repeating},
               {:segment, :VAR, :optional, :repeating},
               {:group, :GOAL_ROLE, :optional, :repeating,
                [
                  {:segment, :ROL, :required},
                  {:segment, :VAR, :optional, :repeating}
                ]},
               {:group, :GOAL_OBSERVATION, :optional, :repeating,
                [
                  {:segment, :OBX, :required},
                  {:segment, :NTE, :optional, :repeating}
                ]}
             ]},
            {:group, :ORDER, :optional, :repeating,
             [
               {:segment, :ORC, :required},
               {:group, :ORDER_DETAIL, :optional,
                [
                  {:segment, :OBR, :required},
                  {:segment, :NTE, :optional, :repeating},
                  {:segment, :VAR, :optional, :repeating},
                  {:group, :ORDER_OBSERVATION, :optional, :repeating,
                   [
                     {:segment, :OBX, :required},
                     {:segment, :NTE, :optional, :repeating},
                     {:segment, :VAR, :optional, :repeating}
                   ]}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # PPT_PCL: Pathway Query Response
  @ppt_pcl %{
    name: "PPT_PCL",
    description: "Pathway Query Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :optional},
      {:segment, :QRD, :required},
      {:segment, :PID, :required},
      {:group, :PATIENT_VISIT, :required,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:group, :PATHWAY, :required, :repeating,
       [
         {:segment, :PTH, :required},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :VAR, :optional, :repeating},
         {:group, :PROBLEM, :optional, :repeating,
          [
            {:segment, :PRB, :required},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :VAR, :optional, :repeating},
            {:group, :PROBLEM_OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :required},
               {:segment, :NTE, :optional, :repeating}
             ]},
            {:group, :ORDER, :optional, :repeating,
             [
               {:segment, :ORC, :required},
               {:group, :ORDER_DETAIL, :optional,
                [
                  {:segment, :OBR, :required},
                  {:segment, :NTE, :optional, :repeating},
                  {:segment, :VAR, :optional, :repeating},
                  {:group, :ORDER_OBSERVATION, :optional, :repeating,
                   [
                     {:segment, :OBX, :required},
                     {:segment, :NTE, :optional, :repeating},
                     {:segment, :VAR, :optional, :repeating}
                   ]}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # PPG_PCG: Goal Query Response
  @ppg_pcg %{
    name: "PPG_PCG",
    description: "Goal Query Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :optional},
      {:segment, :QRD, :required},
      {:segment, :PID, :required},
      {:group, :PATIENT_VISIT, :required,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:group, :GOAL, :required, :repeating,
       [
         {:segment, :GOL, :required},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :VAR, :optional, :repeating},
         {:group, :GOAL_ROLE, :optional, :repeating,
          [
            {:segment, :ROL, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
         {:group, :GOAL_OBSERVATION, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :PROBLEM, :optional, :repeating,
          [
            {:segment, :PRB, :required},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :VAR, :optional, :repeating},
            {:group, :PROBLEM_OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :required},
               {:segment, :NTE, :optional, :repeating}
             ]},
            {:group, :ORDER, :optional, :repeating,
             [
               {:segment, :ORC, :required},
               {:group, :ORDER_DETAIL, :optional,
                [
                  {:segment, :OBR, :required},
                  {:segment, :NTE, :optional, :repeating},
                  {:segment, :VAR, :optional, :repeating},
                  {:group, :ORDER_OBSERVATION, :optional, :repeating,
                   [
                     {:segment, :OBX, :required},
                     {:segment, :NTE, :optional, :repeating},
                     {:segment, :VAR, :optional, :repeating}
                   ]}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Scheduling Request/Response Structures
  # ---------------------------------------------------------------------------

  # SRM_S01: Schedule Request
  @srm_s01 %{
    name: "SRM_S01",
    description: "Schedule Request",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :ARQ, :required},
      {:segment, :APR, :optional},
      {:segment, :NTE, :optional, :repeating},
      {:group, :PATIENT, :optional, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PV1, :optional},
         {:segment, :PV2, :optional},
         {:segment, :DG1, :optional, :repeating},
         {:group, :RESOURCES, :required, :repeating,
          [
            {:segment, :RGS, :required},
            {:group, :SERVICE, :optional, :repeating,
             [
               {:segment, :AIS, :required},
               {:segment, :APR, :optional},
               {:segment, :NTE, :optional, :repeating}
             ]},
            {:group, :GENERAL_RESOURCE, :optional, :repeating,
             [
               {:segment, :AIG, :required},
               {:segment, :APR, :optional},
               {:segment, :NTE, :optional, :repeating}
             ]},
            {:group, :LOCATION_RESOURCE, :optional, :repeating,
             [
               {:segment, :AIL, :required},
               {:segment, :APR, :optional},
               {:segment, :NTE, :optional, :repeating}
             ]},
            {:group, :PERSONNEL_RESOURCE, :optional, :repeating,
             [
               {:segment, :AIP, :required},
               {:segment, :APR, :optional},
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]}
       ]}
    ]
  }

  # SRR_S01: Schedule Response
  @srr_s01 %{
    name: "SRR_S01",
    description: "Schedule Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:group, :SCHEDULE, :optional,
       [
         {:segment, :SCH, :required},
         {:segment, :TQ1, :optional, :repeating},
         {:segment, :NTE, :optional, :repeating},
         {:group, :PATIENT, :optional, :repeating,
          [
            {:segment, :PID, :required},
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
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Equipment/Automation Structures
  # ---------------------------------------------------------------------------

  # EAC_U07: Equipment Command
  @eac_u07 %{
    name: "EAC_U07",
    description: "Equipment Command",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EQU, :required},
      {:segment, :ECD, :required, :repeating},
      {:segment, :SAC, :optional},
      {:segment, :CNS, :optional},
      {:segment, :ROL, :optional}
    ]
  }

  # EAR_U08: Equipment Command Response
  @ear_u08 %{
    name: "EAR_U08",
    description: "Equipment Command Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EQU, :required},
      {:group, :COMMAND_RESPONSE, :required, :repeating,
       [
         {:segment, :ECD, :required},
         {:segment, :SAC, :optional},
         {:segment, :CNS, :optional},
         {:segment, :ECR, :required}
       ]},
      {:segment, :ROL, :optional}
    ]
  }

  # ESU_U01: Equipment Status Update
  @esu_u01 %{
    name: "ESU_U01",
    description: "Equipment Status Update",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EQU, :required},
      {:segment, :ISD, :optional, :repeating},
      {:segment, :ROL, :optional}
    ]
  }

  # ESR_U02: Equipment Status Request
  @esr_u02 %{
    name: "ESR_U02",
    description: "Equipment Status Request",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EQU, :required},
      {:segment, :ROL, :optional}
    ]
  }

  # SSU_U03: Specimen Status Update
  @ssu_u03 %{
    name: "SSU_U03",
    description: "Specimen Status Update",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EQU, :required},
      {:group, :SPECIMEN_CONTAINER, :required, :repeating,
       [
         {:segment, :SAC, :required},
         {:segment, :SPM, :optional},
         {:segment, :OBX, :optional, :repeating}
       ]}
    ]
  }

  # SSR_U04: Specimen Status Request
  @ssr_u04 %{
    name: "SSR_U04",
    description: "Specimen Status Request",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EQU, :required},
      {:segment, :ROL, :optional}
    ]
  }

  # INU_U05: Inventory Update
  @inu_u05 %{
    name: "INU_U05",
    description: "Inventory Update",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EQU, :required},
      {:segment, :INV, :required, :repeating},
      {:segment, :ROL, :optional}
    ]
  }

  # INR_U06: Inventory Request
  @inr_u06 %{
    name: "INR_U06",
    description: "Inventory Request",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EQU, :required},
      {:segment, :INV, :required, :repeating},
      {:segment, :ROL, :optional}
    ]
  }

  # LSU_U12: Equipment Log/Service Update
  @lsu_u12 %{
    name: "LSU_U12",
    description: "Equipment Log/Service Update",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EQU, :required},
      {:segment, :EQP, :required, :repeating},
      {:segment, :ROL, :optional}
    ]
  }

  # TCU_U10: Test Code Settings Update
  @tcu_u10 %{
    name: "TCU_U10",
    description: "Test Code Settings Update",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EQU, :required},
      {:segment, :TCC, :required, :repeating},
      {:segment, :ROL, :optional}
    ]
  }

  # ---------------------------------------------------------------------------
  # Network Management Structures
  # ---------------------------------------------------------------------------

  # NMD_N02: Application Management Data
  @nmd_n02 %{
    name: "NMD_N02",
    description: "Application Management Data",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :CLOCK_AND_STATS, :required, :repeating,
       [
         {:segment, :NCK, :required},
         {:segment, :NTE, :optional},
         {:segment, :NST, :optional},
         {:segment, :NTE, :optional},
         {:segment, :NSC, :optional},
         {:segment, :NTE, :optional}
       ]}
    ]
  }

  # NMR_N01: Application Management Response
  @nmr_n01 %{
    name: "NMR_N01",
    description: "Application Management Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:group, :CLOCK_AND_STATS, :required, :repeating,
       [
         {:segment, :NCK, :required},
         {:segment, :NTE, :optional},
         {:segment, :NST, :optional},
         {:segment, :NTE, :optional},
         {:segment, :NSC, :optional},
         {:segment, :NTE, :optional}
       ]}
    ]
  }

  # NMQ_N01: Application Management Query
  @nmq_n01 %{
    name: "NMQ_N01",
    description: "Application Management Query",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:group, :CLOCK_AND_STATS, :optional, :repeating,
       [
         {:segment, :NCK, :required},
         {:segment, :NTE, :optional},
         {:segment, :NST, :optional},
         {:segment, :NTE, :optional},
         {:segment, :NSC, :optional},
         {:segment, :NTE, :optional}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Personnel Structures
  # ---------------------------------------------------------------------------

  # PMU_B01: Add Personnel Record
  @pmu_b01 %{
    name: "PMU_B01",
    description: "Add Personnel Record",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :STF, :required},
      {:segment, :PRA, :optional, :repeating},
      {:segment, :ORG, :optional, :repeating},
      {:segment, :AFF, :optional, :repeating},
      {:segment, :LAN, :optional, :repeating},
      {:segment, :EDU, :optional, :repeating},
      {:segment, :CER, :optional, :repeating}
    ]
  }

  # PMU_B03: Delete Personnel Record
  @pmu_b03 %{
    name: "PMU_B03",
    description: "Delete Personnel Record",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :STF, :required}
    ]
  }

  # ---------------------------------------------------------------------------
  # Blood Bank Structures
  # ---------------------------------------------------------------------------

  # BPS_O29: Blood Product Dispense Status
  @bps_o29 %{
    name: "BPS_O29",
    description: "Blood Product Dispense Status",
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
            {:segment, :PV1, :required}
          ]}
       ]},
      {:group, :ORDER, :required, :repeating,
       [
         {:segment, :ORC, :required},
         {:segment, :BPO, :required},
         {:segment, :NTE, :optional, :repeating},
         {:group, :TIMING, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:group, :PRODUCT, :required, :repeating,
          [
            {:segment, :BPX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # BRP_O30: Blood Product Dispense Status Ack
  @brp_o30 %{
    name: "BRP_O30",
    description: "Blood Product Dispense Status Ack",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :RESPONSE, :optional,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:segment, :BPO, :optional},
            {:group, :TIMING, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:segment, :BPX, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # BTS_O31: Blood Product Transfusion/Disposition
  @bts_o31 %{
    name: "BTS_O31",
    description: "Blood Product Transfusion/Disposition",
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
            {:segment, :PV1, :required}
          ]}
       ]},
      {:group, :ORDER, :required, :repeating,
       [
         {:segment, :ORC, :required},
         {:segment, :BPO, :required},
         {:segment, :NTE, :optional, :repeating},
         {:group, :TIMING, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:group, :PRODUCT_STATUS, :required, :repeating,
          [
            {:segment, :BTX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # BRT_O32: Blood Product Transfusion/Disposition Ack
  @brt_o32 %{
    name: "BRT_O32",
    description: "Blood Product Transfusion/Disposition Ack",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating}
    ]
  }

  # ---------------------------------------------------------------------------
  # Clinical Study Structures
  # ---------------------------------------------------------------------------

  # CRM_C01: Clinical Study Registration
  @crm_c01 %{
    name: "CRM_C01",
    description: "Clinical Study Registration",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :PATIENT, :required, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PV1, :optional},
         {:segment, :CSR, :required},
         {:segment, :CSP, :optional, :repeating}
       ]}
    ]
  }

  # CSU_C09: Unsolicited Study Data
  @csu_c09 %{
    name: "CSU_C09",
    description: "Unsolicited Study Data",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :PATIENT, :required, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :NTE, :optional, :repeating},
         {:group, :PATIENT_VISIT, :optional,
          [
            {:segment, :PV1, :required},
            {:segment, :PV2, :optional}
          ]},
         {:segment, :CSR, :required},
         {:group, :STUDY_PHASE, :optional, :repeating,
          [
            {:segment, :CSP, :optional},
            {:group, :STUDY_SCHEDULE, :optional, :repeating,
             [
               {:segment, :CSS, :optional},
               {:group, :STUDY_OBSERVATION, :optional, :repeating,
                [
                  {:segment, :ORC, :optional},
                  {:segment, :OBR, :required},
                  {:group, :TIMING_QTY, :optional, :repeating,
                   [
                     {:segment, :TQ1, :required},
                     {:segment, :TQ2, :optional, :repeating}
                   ]},
                  {:segment, :OBX, :required, :repeating}
                ]},
               {:group, :STUDY_PHARM, :optional, :repeating,
                [
                  {:segment, :ORC, :optional},
                  {:group, :RX_ADMIN, :required, :repeating,
                   [
                     {:segment, :RXA, :required},
                     {:segment, :RXR, :required}
                   ]}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Product Experience Structures
  # ---------------------------------------------------------------------------

  # PEX_P07: Product Experience
  @pex_p07 %{
    name: "PEX_P07",
    description: "Product Experience",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :NTE, :optional, :repeating},
      {:group, :EXPERIENCE, :required, :repeating,
       [
         {:segment, :PES, :required},
         {:group, :PEX_OBSERVATION, :required, :repeating,
          [
            {:segment, :PEO, :required},
            {:group, :PEX_CAUSE, :required, :repeating,
             [
               {:segment, :PCR, :required},
               {:group, :RX_ORDER, :optional,
                [
                  {:segment, :RXE, :required},
                  {:group, :TIMING_QTY, :optional, :repeating,
                   [
                     {:segment, :TQ1, :required},
                     {:segment, :TQ2, :optional, :repeating}
                   ]},
                  {:segment, :RXR, :optional, :repeating}
                ]},
               {:group, :RX_ADMINISTRATION, :optional, :repeating,
                [
                  {:segment, :RXA, :required},
                  {:segment, :RXR, :optional}
                ]},
               {:segment, :PRB, :optional, :repeating},
               {:segment, :OBX, :optional, :repeating},
               {:segment, :NTE, :optional, :repeating},
               {:group, :NK1_TIMING_QTY, :optional, :repeating,
                [
                  {:segment, :NK1, :required},
                  {:group, :TIMING_QTY, :optional, :repeating,
                   [
                     {:segment, :TQ1, :required},
                     {:segment, :TQ2, :optional, :repeating}
                   ]}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # SUR_P09: Summary Product Experience
  @sur_p09 %{
    name: "SUR_P09",
    description: "Summary Product Experience",
    nodes: [
      {:segment, :MSH, :required},
      {:group, :FACILITY, :required, :repeating,
       [
         {:segment, :FAC, :required},
         {:group, :PRODUCT, :required, :repeating,
          [
            {:segment, :PSH, :required},
            {:segment, :PDC, :required}
          ]}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Misc/Other Structures
  # ---------------------------------------------------------------------------

  # DOC_T12: Document Response
  @doc_t12 %{
    name: "DOC_T12",
    description: "Document Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QRD, :optional},
      {:group, :RESULT, :required, :repeating,
       [
         {:segment, :EVN, :required},
         {:segment, :PID, :required},
         {:segment, :PV1, :required},
         {:segment, :TXA, :required},
         {:segment, :OBX, :optional, :repeating}
       ]}
    ]
  }

  # UDM_Q05: Unsolicited Display Update
  @udm_q05 %{
    name: "UDM_Q05",
    description: "Unsolicited Display Update",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :URD, :required},
      {:segment, :URS, :optional},
      {:segment, :DSP, :required, :repeating},
      {:segment, :DSC, :optional}
    ]
  }

  # ADR_A19: ADT Response
  @adr_a19 %{
    name: "ADR_A19",
    description: "ADT Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :optional},
      {:segment, :QRD, :optional},
      {:segment, :QRF, :optional},
      {:group, :QUERY_RESPONSE, :required, :repeating,
       [
         {:segment, :EVN, :optional},
         {:segment, :PID, :required},
         {:segment, :PD1, :optional},
         {:segment, :ROL, :optional, :repeating},
         {:segment, :NK1, :optional, :repeating},
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional},
         {:segment, :ROL, :optional, :repeating},
         {:segment, :DB1, :optional, :repeating},
         {:segment, :OBX, :optional, :repeating},
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
         {:segment, :UB2, :optional}
       ]}
    ]
  }

  # ORR_O02: General Order Response
  @orr_o02 %{
    name: "ORR_O02",
    description: "General Order Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:group, :RESPONSE, :optional,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:segment, :OBR, :optional},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  @structures %{
    "ADR_A19" => @adr_a19,
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
    "ADT_A17" => @adt_a17,
    "ADT_A20" => @adt_a20,
    "ADT_A21" => @adt_a21,
    "ADT_A24" => @adt_a24,
    "ADT_A30" => @adt_a30,
    "ADT_A37" => @adt_a37,
    "ADT_A38" => @adt_a38,
    "ADT_A39" => @adt_a39,
    "ADT_A43" => @adt_a43,
    "ADT_A45" => @adt_a45,
    "ADT_A50" => @adt_a50,
    "BAR_P01" => @bar_p01,
    "BAR_P02" => @bar_p02,
    "BAR_P05" => %{@bar_p01 | name: "BAR_P05", description: "Update Account"},
    "BAR_P06" => %{@bar_p02 | name: "BAR_P06", description: "End Account"},
    "BAR_P10" => @bar_p10,
    "BAR_P12" => @bar_p12,
    "BPS_O29" => @bps_o29,
    "BRP_O30" => @brp_o30,
    "BRT_O32" => @brt_o32,
    "BTS_O31" => @bts_o31,
    "CRM_C01" => @crm_c01,
    "CSU_C09" => @csu_c09,
    "DFT_P03" => @dft_p03,
    "DFT_P11" => @dft_p11,
    "DOC_T12" => @doc_t12,
    "EAC_U07" => @eac_u07,
    "EAR_U08" => @ear_u08,
    "ESR_U02" => @esr_u02,
    "ESU_U01" => @esu_u01,
    "INR_U06" => @inr_u06,
    "INU_U05" => @inu_u05,
    "LSU_U12" => @lsu_u12,
    "MDM_T02" => @mdm_t02,
    "MFK_M01" => @mfk_m01,
    "MFN_M01" => @mfn_m01,
    "MFN_M02" => @mfn_m02,
    "MFN_M05" => @mfn_m05,
    "MFQ_M01" => @mfq_m01,
    "NMD_N02" => @nmd_n02,
    "NMQ_N01" => @nmq_n01,
    "NMR_N01" => @nmr_n01,
    "OMD_O03" => @omd_o03,
    "OMG_O19" => @omg_o19,
    "OML_O21" => @oml_o21,
    "OMP_O09" => @omp_o09,
    "OMS_O05" => @oms_o05,
    "ORA_R33" => @ora_r33,
    "ORG_O20" => @org_o20,
    "ORL_O22" => @orl_o22,
    "ORM_O01" => @orm_o01,
    "ORP_O10" => @orp_o10,
    "ORR_O02" => @orr_o02,
    "ORU_R01" => @oru_r01,
    "ORU_R30" => @oru_r30,
    "OUL_R21" => @oul_r21,
    "PEX_P07" => @pex_p07,
    "PGL_PC6" => @pgl_pc6,
    "PMU_B01" => @pmu_b01,
    "PMU_B03" => @pmu_b03,
    "PPG_PCG" => @ppg_pcg,
    "PPP_PCB" => @ppp_pcb,
    "PPR_PC1" => @ppr_pc1,
    "PPT_PCL" => @ppt_pcl,
    "QBP_Q21" => @qbp_q21,
    "QCK_Q02" => @qck_q02,
    "QCN_J01" => @qcn_j01,
    "RAS_O17" => @ras_o17,
    "RDE_O11" => @rde_o11,
    "RDS_O13" => @rds_o13,
    "RDY_K15" => @rdy_k15,
    "REF_I12" => @ref_i12,
    "RGV_O15" => @rgv_o15,
    "RRA_O18" => @rra_o18,
    "RRD_O14" => @rrd_o14,
    "RRE_O12" => @rre_o12,
    "RRI_I12" => @rri_i12,
    "RRG_O16" => @rrg_o16,
    "RSP_K21" => @rsp_k21,
    "RTB_K13" => @rtb_k13,
    "SIU_S12" => @siu_s12,
    "SRM_S01" => @srm_s01,
    "SRR_S01" => @srr_s01,
    "SSR_U04" => @ssr_u04,
    "SSU_U03" => @ssu_u03,
    "SUR_P09" => @sur_p09,
    "TCU_U10" => @tcu_u10,
    "UDM_Q05" => @udm_q05,
    "VXQ_V01" => @vxq_v01,
    "VXR_V03" => @vxr_v03,
    "VXU_V04" => @vxu_v04,
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
