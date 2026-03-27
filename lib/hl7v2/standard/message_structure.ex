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

  # ---------------------------------------------------------------------------
  # MDM Structures — Additional Variants
  # ---------------------------------------------------------------------------

  # MDM_T01: Original Document Notification (no OBX content)
  @mdm_t01 %{
    name: "MDM_T01",
    description: "Original Document Notification",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PV1, :required},
      {:segment, :TXA, :required}
    ]
  }

  # MDM_T03: Document Status Change Notification
  @mdm_t03 %{
    name: "MDM_T03",
    description: "Document Status Change Notification",
    nodes: @mdm_t01.nodes
  }

  # MDM_T04: Document Status Change Notification and Content
  @mdm_t04 %{
    name: "MDM_T04",
    description: "Document Status Change Notification and Content",
    nodes: @mdm_t02.nodes
  }

  # MDM_T05: Document Addendum Notification
  @mdm_t05 %{
    name: "MDM_T05",
    description: "Document Addendum Notification",
    nodes: @mdm_t01.nodes
  }

  # MDM_T06: Document Addendum Notification and Content
  @mdm_t06 %{
    name: "MDM_T06",
    description: "Document Addendum Notification and Content",
    nodes: @mdm_t02.nodes
  }

  # MDM_T07: Document Edit Notification
  @mdm_t07 %{
    name: "MDM_T07",
    description: "Document Edit Notification",
    nodes: @mdm_t01.nodes
  }

  # MDM_T08: Document Edit Notification and Content
  @mdm_t08 %{
    name: "MDM_T08",
    description: "Document Edit Notification and Content",
    nodes: @mdm_t02.nodes
  }

  # MDM_T09: Document Replacement Notification
  @mdm_t09 %{
    name: "MDM_T09",
    description: "Document Replacement Notification",
    nodes: @mdm_t01.nodes
  }

  # MDM_T10: Document Replacement Notification and Content
  @mdm_t10 %{
    name: "MDM_T10",
    description: "Document Replacement Notification and Content",
    nodes: @mdm_t02.nodes
  }

  # MDM_T11: Document Cancel Notification
  @mdm_t11 %{
    name: "MDM_T11",
    description: "Document Cancel Notification",
    nodes: @mdm_t01.nodes
  }

  # ---------------------------------------------------------------------------
  # Additional Order Structures
  # ---------------------------------------------------------------------------

  # OMI_O23: Imaging Order
  @omi_o23 %{
    name: "OMI_O23",
    description: "Imaging Order",
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
         {:segment, :IPC, :required, :repeating}
       ]}
    ]
  }

  # ORI_O24: Imaging Order Response
  @ori_o24 %{
    name: "ORI_O24",
    description: "Imaging Order Response",
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
            {:segment, :IPC, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # OMN_O07: Non-Stock Requisition Order
  @omn_o07 %{
    name: "OMN_O07",
    description: "Non-Stock Requisition Order",
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

  # ORN_O08: Non-Stock Requisition Acknowledgment
  @orn_o08 %{
    name: "ORN_O08",
    description: "Non-Stock Requisition Acknowledgment",
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
            {:segment, :RQD, :optional},
            {:segment, :RQ1, :optional},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # ORD_O04: Dietary Order Acknowledgment
  @ord_o04 %{
    name: "ORD_O04",
    description: "Dietary Order Acknowledgment",
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
         {:group, :ORDER_DIET, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :TIMING_DIET, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:segment, :ODS, :optional, :repeating},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER_TRAY, :optional, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :TIMING_TRAY, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:segment, :ODT, :optional, :repeating},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # ORS_O06: Stock Requisition Acknowledgment
  @ors_o06 %{
    name: "ORS_O06",
    description: "Stock Requisition Acknowledgment",
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
            {:segment, :RQD, :optional},
            {:segment, :RQ1, :optional},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # OML_O33: Laboratory Order for Multiple Orders Related to a Single Specimen
  @oml_o33 %{
    name: "OML_O33",
    description: "Laboratory Order — Multiple Orders Per Specimen",
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
      {:group, :SPECIMEN, :required, :repeating,
       [
         {:segment, :SPM, :required},
         {:segment, :OBX, :optional, :repeating},
         {:segment, :SAC, :optional, :repeating},
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
       ]}
    ]
  }

  # OML_O35: Laboratory Order for Multiple Orders Related to a Single Container
  @oml_o35 %{
    name: "OML_O35",
    description: "Laboratory Order — Multiple Orders Per Container",
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
      {:group, :SPECIMEN, :required, :repeating,
       [
         {:segment, :SPM, :required},
         {:segment, :OBX, :optional, :repeating},
         {:segment, :SAC, :optional, :repeating},
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
                ]}
             ]},
            {:segment, :FT1, :optional, :repeating},
            {:segment, :CTI, :optional, :repeating},
            {:segment, :BLG, :optional}
          ]}
       ]}
    ]
  }

  # ORL_O34: Laboratory Order Response — Specimen-oriented
  @orl_o34 %{
    name: "ORL_O34",
    description: "Laboratory Order Response — Specimen Oriented",
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
         {:group, :SPECIMEN, :required, :repeating,
          [
            {:segment, :SPM, :required},
            {:segment, :SAC, :optional, :repeating},
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
                  {:segment, :SPM, :optional}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # ORL_O36: Laboratory Order Response — Container Oriented
  @orl_o36 %{
    name: "ORL_O36",
    description: "Laboratory Order Response — Container Oriented",
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
         {:group, :SPECIMEN, :required, :repeating,
          [
            {:segment, :SPM, :required},
            {:segment, :SAC, :optional, :repeating},
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
                  {:segment, :OBR, :required}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # OMB_O27: Blood Product Order
  @omb_o27 %{
    name: "OMB_O27",
    description: "Blood Product Order",
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
         {:segment, :BPO, :required},
         {:segment, :SPM, :optional},
         {:segment, :NTE, :optional, :repeating},
         {:segment, :DG1, :optional, :repeating},
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

  # ORB_O28: Blood Product Order Acknowledgment
  @orb_o28 %{
    name: "ORB_O28",
    description: "Blood Product Order Acknowledgment",
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
            {:segment, :BPO, :optional}
          ]}
       ]}
    ]
  }

  # OML_O39: Specimen Shipment Order
  @oml_o39 %{
    name: "OML_O39",
    description: "Specimen Shipment Order",
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
      {:group, :SPECIMEN, :required, :repeating,
       [
         {:segment, :SPM, :required},
         {:segment, :OBX, :optional, :repeating},
         {:segment, :SAC, :optional, :repeating},
         {:group, :ORDER, :optional, :repeating,
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
                ]}
             ]},
            {:segment, :FT1, :optional, :repeating},
            {:segment, :CTI, :optional, :repeating},
            {:segment, :BLG, :optional}
          ]}
       ]}
    ]
  }

  # ORL_O40: Specimen Shipment Order Response
  @orl_o40 %{
    name: "ORL_O40",
    description: "Specimen Shipment Order Response",
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
         {:group, :SPECIMEN, :required, :repeating,
          [
            {:segment, :SPM, :required},
            {:segment, :SAC, :optional, :repeating},
            {:group, :ORDER, :optional, :repeating,
             [
               {:segment, :ORC, :required},
               {:group, :TIMING, :optional, :repeating,
                [
                  {:segment, :TQ1, :required},
                  {:segment, :TQ2, :optional, :repeating}
                ]},
               {:group, :OBSERVATION_REQUEST, :optional,
                [
                  {:segment, :OBR, :required}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Additional Observation Structures
  # ---------------------------------------------------------------------------

  # OUL_R22: Unsolicited Specimen Oriented Observation
  @oul_r22 %{
    name: "OUL_R22",
    description: "Unsolicited Specimen Oriented Observation",
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
      {:group, :SPECIMEN, :required, :repeating,
       [
         {:segment, :SPM, :required},
         {:segment, :OBX, :optional, :repeating},
         {:group, :CONTAINER, :optional, :repeating,
          [
            {:segment, :SAC, :required},
            {:segment, :INV, :optional}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :OBR, :required},
            {:segment, :ORC, :optional},
            {:segment, :NTE, :optional, :repeating},
            {:group, :TIMING_QTY, :optional, :repeating,
             [
               {:segment, :TQ1, :required},
               {:segment, :TQ2, :optional, :repeating}
             ]},
            {:group, :RESULT, :optional, :repeating,
             [
               {:segment, :OBX, :required},
               {:segment, :TCD, :optional},
               {:segment, :SID, :optional},
               {:segment, :NTE, :optional, :repeating}
             ]},
            {:segment, :CTI, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # OUL_R23: Unsolicited Specimen Container Oriented Observation
  @oul_r23 %{
    name: "OUL_R23",
    description: "Unsolicited Specimen Container Oriented Observation",
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
      {:group, :SPECIMEN, :required, :repeating,
       [
         {:segment, :SPM, :required},
         {:segment, :OBX, :optional, :repeating},
         {:group, :CONTAINER, :required, :repeating,
          [
            {:segment, :SAC, :required},
            {:segment, :INV, :optional},
            {:group, :ORDER, :required, :repeating,
             [
               {:segment, :OBR, :required},
               {:segment, :ORC, :optional},
               {:segment, :NTE, :optional, :repeating},
               {:group, :TIMING_QTY, :optional, :repeating,
                [
                  {:segment, :TQ1, :required},
                  {:segment, :TQ2, :optional, :repeating}
                ]},
               {:group, :RESULT, :optional, :repeating,
                [
                  {:segment, :OBX, :required},
                  {:segment, :TCD, :optional},
                  {:segment, :SID, :optional},
                  {:segment, :NTE, :optional, :repeating}
                ]},
               {:segment, :CTI, :optional, :repeating}
             ]}
          ]}
       ]}
    ]
  }

  # OUL_R24: Unsolicited Order Oriented Observation
  @oul_r24 %{
    name: "OUL_R24",
    description: "Unsolicited Order Oriented Observation",
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
      {:group, :ORDER, :required, :repeating,
       [
         {:segment, :OBR, :required},
         {:segment, :ORC, :optional},
         {:segment, :NTE, :optional, :repeating},
         {:group, :TIMING_QTY, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:group, :SPECIMEN, :optional, :repeating,
          [
            {:segment, :SPM, :required},
            {:segment, :OBX, :optional, :repeating},
            {:group, :CONTAINER, :optional, :repeating,
             [
               {:segment, :SAC, :required},
               {:segment, :INV, :optional}
             ]}
          ]},
         {:group, :RESULT, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :TCD, :optional},
            {:segment, :SID, :optional},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:segment, :CTI, :optional, :repeating}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Patient Info Request/Response Structures
  # ---------------------------------------------------------------------------

  # QRY_A19: Patient Query
  @qry_a19 %{
    name: "QRY_A19",
    description: "Patient Query",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional}
    ]
  }

  # RQI_I01: Request for Insurance Information
  @rqi_i01 %{
    name: "RQI_I01",
    description: "Request for Insurance Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :PROVIDER, :required, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:segment, :PID, :required},
      {:segment, :NK1, :optional, :repeating},
      {:group, :GUARANTOR_INSURANCE, :optional,
       [
         {:segment, :GT1, :optional, :repeating},
         {:group, :INSURANCE, :required, :repeating,
          [
            {:segment, :IN1, :required},
            {:segment, :IN2, :optional},
            {:segment, :IN3, :optional}
          ]}
       ]},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # RPA_I08: Request for Treatment Authorization Info Response
  @rpa_i08 %{
    name: "RPA_I08",
    description: "Request for Treatment Authorization Information Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :RF1, :optional},
      {:group, :AUTHORIZATION, :optional,
       [
         {:segment, :AUT, :required},
         {:segment, :CTD, :optional}
       ]},
      {:group, :PROVIDER, :required, :repeating,
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
      {:group, :PROCEDURE, :required, :repeating,
       [
         {:segment, :PR1, :required},
         {:segment, :ROL, :optional, :repeating}
       ]},
      {:group, :OBSERVATION, :optional, :repeating,
       [
         {:segment, :OBR, :required},
         {:segment, :NTE, :optional, :repeating},
         {:group, :RESULTS, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]},
      {:group, :VISIT, :optional,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # RPI_I01: Return Patient Information
  @rpi_i01 %{
    name: "RPI_I01",
    description: "Return Patient Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:group, :PROVIDER, :required, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:segment, :PID, :required},
      {:segment, :NK1, :optional, :repeating},
      {:group, :GUARANTOR_INSURANCE, :optional,
       [
         {:segment, :GT1, :optional, :repeating},
         {:group, :INSURANCE, :required, :repeating,
          [
            {:segment, :IN1, :required},
            {:segment, :IN2, :optional},
            {:segment, :IN3, :optional}
          ]}
       ]},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # RPI_I04: Return Patient Information (insurance specific)
  @rpi_i04 %{
    name: "RPI_I04",
    description: "Return Patient Information — Insurance",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:group, :PROVIDER, :required, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:segment, :PID, :required},
      {:segment, :NK1, :optional, :repeating},
      {:group, :GUARANTOR_INSURANCE, :optional,
       [
         {:segment, :GT1, :optional, :repeating},
         {:group, :INSURANCE, :required, :repeating,
          [
            {:segment, :IN1, :required},
            {:segment, :IN2, :optional},
            {:segment, :IN3, :optional}
          ]}
       ]},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # RQA_I08: Request for Treatment Authorization
  @rqa_i08 %{
    name: "RQA_I08",
    description: "Request for Treatment Authorization Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :RF1, :optional},
      {:group, :AUTHORIZATION, :optional,
       [
         {:segment, :AUT, :required},
         {:segment, :CTD, :optional}
       ]},
      {:group, :PROVIDER, :required, :repeating,
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
      {:group, :PROCEDURE, :required, :repeating,
       [
         {:segment, :PR1, :required},
         {:segment, :ROL, :optional, :repeating}
       ]},
      {:group, :OBSERVATION, :optional, :repeating,
       [
         {:segment, :OBR, :required},
         {:segment, :NTE, :optional, :repeating},
         {:group, :RESULTS, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]},
      {:group, :VISIT, :optional,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # RQC_I05: Request for Patient Clinical Information
  @rqc_i05 %{
    name: "RQC_I05",
    description: "Request for Patient Clinical Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:group, :PROVIDER, :required, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:segment, :PID, :required},
      {:segment, :NK1, :optional, :repeating},
      {:segment, :GT1, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # RCI_I05: Return Patient Clinical Information
  @rci_i05 %{
    name: "RCI_I05",
    description: "Return Clinical Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:group, :PROVIDER, :required, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:segment, :PID, :required},
      {:segment, :DG1, :optional, :repeating},
      {:segment, :DRG, :optional, :repeating},
      {:segment, :AL1, :optional, :repeating},
      {:group, :OBSERVATION, :optional, :repeating,
       [
         {:segment, :OBR, :required},
         {:segment, :NTE, :optional, :repeating},
         {:group, :RESULTS, :optional, :repeating,
          [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]}
       ]},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # RQP_I04: Request for Patient Demographics
  @rqp_i04 %{
    name: "RQP_I04",
    description: "Request for Patient Demographics",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :PROVIDER, :required, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:segment, :PID, :required},
      {:segment, :NK1, :optional, :repeating},
      {:segment, :GT1, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # RPL_I02: Return Patient Display List
  @rpl_i02 %{
    name: "RPL_I02",
    description: "Return Patient Display List",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:group, :PROVIDER, :required, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:segment, :NTE, :optional, :repeating},
      {:segment, :DSP, :optional, :repeating},
      {:segment, :DSC, :optional}
    ]
  }

  # RPR_I03: Return Patient Subscription List
  @rpr_i03 %{
    name: "RPR_I03",
    description: "Return Patient Subscription List",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:group, :PROVIDER, :required, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:segment, :NTE, :optional, :repeating}
    ]
  }

  # ---------------------------------------------------------------------------
  # Additional Pharmacy Structures
  # ---------------------------------------------------------------------------

  # RER_RER: Pharmacy Encoded Order Query Response
  @rer_rer %{
    name: "RER_RER",
    description: "Pharmacy Encoded Order Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:group, :DEFINITION, :required, :repeating,
       [
         {:segment, :QRD, :required},
         {:segment, :QRF, :optional},
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:segment, :RXE, :required},
            {:segment, :RXR, :required, :repeating},
            {:segment, :RXC, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # RDR_RDR: Pharmacy Dispense Query Response
  @rdr_rdr %{
    name: "RDR_RDR",
    description: "Pharmacy Dispense Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:group, :DEFINITION, :required, :repeating,
       [
         {:segment, :QRD, :required},
         {:segment, :QRF, :optional},
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :DISPENSE, :optional, :repeating,
             [
               {:segment, :RXD, :required},
               {:segment, :RXR, :required, :repeating},
               {:segment, :RXC, :optional, :repeating}
             ]}
          ]}
       ]}
    ]
  }

  # RAR_RAR: Pharmacy Administration Query Response
  @rar_rar %{
    name: "RAR_RAR",
    description: "Pharmacy Administration Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:group, :DEFINITION, :required, :repeating,
       [
         {:segment, :QRD, :required},
         {:segment, :QRF, :optional},
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:group, :ADMINISTRATION, :optional, :repeating,
             [
               {:segment, :RXA, :required},
               {:segment, :RXR, :required}
             ]}
          ]}
       ]}
    ]
  }

  # ROR_ROR: Pharmacy Prescription Order Query Response
  @ror_ror %{
    name: "ROR_ROR",
    description: "Pharmacy Prescription Order Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:group, :DEFINITION, :required, :repeating,
       [
         {:segment, :QRD, :required},
         {:segment, :QRF, :optional},
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
          [
            {:segment, :ORC, :required},
            {:segment, :RXO, :required},
            {:segment, :RXR, :required, :repeating},
            {:segment, :RXC, :optional, :repeating}
          ]}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Additional Personnel Structures
  # ---------------------------------------------------------------------------

  # PMU_B04: Active Practicing Person
  @pmu_b04 %{
    name: "PMU_B04",
    description: "Active Practicing Person",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :STF, :required},
      {:segment, :PRA, :optional, :repeating},
      {:segment, :ORG, :optional, :repeating}
    ]
  }

  # PMU_B07: Grant Certificate/Permission
  @pmu_b07 %{
    name: "PMU_B07",
    description: "Grant Certificate/Permission",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :STF, :required},
      {:segment, :PRA, :optional, :repeating},
      {:segment, :CER, :optional, :repeating}
    ]
  }

  # PMU_B08: Revoke Certificate/Permission
  @pmu_b08 %{
    name: "PMU_B08",
    description: "Revoke Certificate/Permission",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :STF, :required},
      {:segment, :PRA, :optional, :repeating},
      {:segment, :CER, :optional, :repeating}
    ]
  }

  # ---------------------------------------------------------------------------
  # Additional ADT Structures
  # ---------------------------------------------------------------------------

  # ADT_A54: Change Attending Doctor
  @adt_a54 %{
    name: "ADT_A54",
    description: "Change Attending Doctor",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :ROL, :required, :repeating},
      {:segment, :PV1, :required},
      {:segment, :PV2, :optional},
      {:segment, :ROL, :optional, :repeating}
    ]
  }

  # ADT_A60: Update Allergy Information
  @adt_a60 %{
    name: "ADT_A60",
    description: "Update Allergy Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PV1, :optional},
      {:segment, :PV2, :optional},
      {:segment, :IAM, :optional, :repeating}
    ]
  }

  # ADT_A61: Change Consulting Doctor
  @adt_a61 %{
    name: "ADT_A61",
    description: "Change Consulting Doctor",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EVN, :required},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :ROL, :optional, :repeating},
      {:segment, :PV1, :required},
      {:segment, :PV2, :optional},
      {:segment, :ROL, :optional, :repeating}
    ]
  }

  # ---------------------------------------------------------------------------
  # Additional Query Structures
  # ---------------------------------------------------------------------------

  # QBP_Q11: Query by Parameter (Segment Pattern Response)
  @qbp_q11 %{
    name: "QBP_Q11",
    description: "Query by Parameter — Segment Pattern Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QPD, :required},
      {:segment, :RCP, :required},
      {:segment, :DSC, :optional}
    ]
  }

  # QBP_Q13: Query by Parameter — Tabular Response
  @qbp_q13 %{
    name: "QBP_Q13",
    description: "Query by Parameter — Tabular Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QPD, :required},
      {:segment, :RDF, :optional},
      {:segment, :RCP, :required},
      {:segment, :DSC, :optional}
    ]
  }

  # QBP_Q15: Query by Parameter — Display Response
  @qbp_q15 %{
    name: "QBP_Q15",
    description: "Query by Parameter — Display Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QPD, :required},
      {:segment, :RCP, :required},
      {:segment, :DSC, :optional}
    ]
  }

  # QSB_Q16: Create Subscription
  @qsb_q16 %{
    name: "QSB_Q16",
    description: "Create Subscription",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QPD, :required},
      {:segment, :RCP, :required},
      {:segment, :DSC, :optional}
    ]
  }

  # QVR_Q17: Query for Previous Events
  @qvr_q17 %{
    name: "QVR_Q17",
    description: "Query for Previous Events",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QPD, :required},
      {:segment, :RCP, :required},
      {:segment, :DSC, :optional}
    ]
  }

  # RSP_K11: Segment Pattern Response (specific)
  @rsp_k11 %{
    name: "RSP_K11",
    description: "Segment Pattern Response in Response to QBP^Q11",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:group, :ROW_DEFINITION, :optional,
       [
         {:segment, :RDF, :required},
         {:segment, :RDT, :optional, :repeating}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # RSP_K13: Segment Pattern Response (tabular)
  @rsp_k13 %{
    name: "RSP_K13",
    description: "Segment Pattern Response in Response to QBP^Q13",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:group, :ROW_DEFINITION, :optional,
       [
         {:segment, :RDF, :required},
         {:segment, :RDT, :optional, :repeating}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # RSP_K15: Display Based Response (specific)
  @rsp_k15 %{
    name: "RSP_K15",
    description: "Display Based Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:segment, :DSP, :optional, :repeating},
      {:segment, :DSC, :optional}
    ]
  }

  # RSP_K31: Pharmacy Dispense Response
  @rsp_k31 %{
    name: "RSP_K31",
    description: "Pharmacy Information Comprehensive Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:segment, :RCP, :optional},
      {:group, :RESPONSE, :optional, :repeating,
       [
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
            {:segment, :RXD, :required},
            {:segment, :RXR, :required, :repeating},
            {:segment, :RXC, :optional, :repeating},
            {:group, :OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :optional},
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # ---------------------------------------------------------------------------
  # Additional Master File Structures (with named content)
  # ---------------------------------------------------------------------------

  # MFN_M03: Master File — Test/Observation Batteries
  @mfn_m03 %{
    name: "MFN_M03",
    description: "Master File — Test/Observation",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_TEST, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :OM1, :required},
         {:segment, :NTE, :optional, :repeating}
       ]}
    ]
  }

  # MFN_M04: Master File — Charge Description
  @mfn_m04 %{
    name: "MFN_M04",
    description: "Master File — Charge Description",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_CDM, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :CDM, :required},
         {:segment, :NTE, :optional, :repeating}
       ]}
    ]
  }

  # MFN_M06: Master File — Clinical Study with Phases and Schedules
  @mfn_m06 %{
    name: "MFN_M06",
    description: "Master File — Clinical Study",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_CLIN_STUDY, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :CM0, :required},
         {:segment, :CM1, :optional, :repeating},
         {:segment, :CM2, :optional, :repeating}
       ]}
    ]
  }

  # MFN_M07: Master File — Observation Numeric
  @mfn_m07 %{
    name: "MFN_M07",
    description: "Master File — Observation — Numeric",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_OBS_ATTRIBUTES, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :OM1, :required},
         {:segment, :OM2, :optional},
         {:segment, :OM3, :optional},
         {:segment, :OM4, :optional}
       ]}
    ]
  }

  # MFN_M08: Master File — Test/Observation Numeric
  @mfn_m08 %{
    name: "MFN_M08",
    description: "Master File — Test/Observation Numeric",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_TEST_NUMERIC, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :OM1, :required},
         {:segment, :OM2, :optional},
         {:segment, :OM3, :optional},
         {:segment, :OM4, :optional}
       ]}
    ]
  }

  # MFN_M09: Master File — Test/Observation Categorical
  @mfn_m09 %{
    name: "MFN_M09",
    description: "Master File — Test/Observation Categorical",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_TEST_CATEGORICAL, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :OM1, :required},
         {:segment, :OM3, :optional},
         {:segment, :OM4, :optional, :repeating}
       ]}
    ]
  }

  # MFN_M10: Master File — Test/Observation Batteries
  @mfn_m10 %{
    name: "MFN_M10",
    description: "Master File — Test/Observation Batteries",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_TEST_BATTERIES, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :OM1, :required},
         {:segment, :OM5, :optional},
         {:segment, :OM4, :optional, :repeating}
       ]}
    ]
  }

  # MFN_M11: Master File — Test/Calculated Observations
  @mfn_m11 %{
    name: "MFN_M11",
    description: "Master File — Test/Calculated Observations",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_TEST_CALCULATED, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :OM1, :required},
         {:segment, :OM6, :optional},
         {:segment, :OM2, :required}
       ]}
    ]
  }

  # MFN_M12: Master File — Additional Basic Observation/Service Attributes
  @mfn_m12 %{
    name: "MFN_M12",
    description: "Master File — Additional Observation Attributes",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_OBS_ATTRIBUTES, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :OM1, :required},
         {:segment, :OM7, :optional}
       ]}
    ]
  }

  # MFN_M13: Master File — Inventory Item Master File
  @mfn_m13 %{
    name: "MFN_M13",
    description: "Master File — Inventory Item",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_INV_ITEM, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :IIM, :required}
       ]}
    ]
  }

  # MFR_M01: Master File Response
  @mfr_m01 %{
    name: "MFR_M01",
    description: "Master File Query Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :QAK, :optional},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:segment, :MFI, :required},
      {:group, :MF_QUERY, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :NTE, :optional, :repeating}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # ---------------------------------------------------------------------------
  # Vaccination Additional Structures
  # ---------------------------------------------------------------------------

  # VXX_V02: Vaccination Query Response with Multiple PID Matches
  @vxx_v02 %{
    name: "VXX_V02",
    description: "Response to Vaccination Query with Multiple PID Matches",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:group, :PATIENT, :required, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :NK1, :optional, :repeating}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Additional DFT Structures
  # ---------------------------------------------------------------------------

  # DFT_P03 exists already. Add P11 alias relationships.

  # ---------------------------------------------------------------------------
  # Collaborative Care Structures (Chapter 11)
  # ---------------------------------------------------------------------------

  # CCR_I16: Collaborative Care Referral
  @ccr_i16 %{
    name: "CCR_I16",
    description: "Collaborative Care Referral",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :RF1, :required},
      {:group, :PROVIDER_CONTACT, :optional, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:group, :CLINICAL_ORDER, :optional, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :CLINICAL_ORDER_TIMING, :optional, :repeating,
          [
            {:segment, :TQ1, :required},
            {:segment, :TQ2, :optional, :repeating}
          ]},
         {:group, :CLINICAL_ORDER_DETAIL, :optional, :repeating,
          [
            {:segment, :OBR, :required},
            {:segment, :OBX, :optional, :repeating}
          ]},
         {:segment, :CTI, :optional, :repeating}
       ]},
      {:group, :PATIENT, :required, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional}
       ]},
      {:segment, :NK1, :optional, :repeating},
      {:group, :INSURANCE, :optional, :repeating,
       [
         {:segment, :IN1, :required},
         {:segment, :IN2, :optional},
         {:segment, :IN3, :optional}
       ]},
      {:group, :APPOINTMENT_HISTORY, :optional, :repeating,
       [
         {:segment, :SCH, :required},
         {:group, :RESOURCES, :optional, :repeating,
          [
            {:segment, :RGS, :required},
            {:group, :RESOURCE_DETAIL, :optional, :repeating,
             [
               {:segment, :AIS, :required},
               {:segment, :AIG, :optional},
               {:segment, :AIL, :optional},
               {:segment, :AIP, :optional}
             ]}
          ]}
       ]},
      {:group, :CLINICAL_HISTORY, :optional, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :CLINICAL_HISTORY_DETAIL, :optional, :repeating,
          [
            {:segment, :OBR, :required},
            {:segment, :OBX, :optional, :repeating}
          ]},
         {:group, :ROLE_CLINICAL_HISTORY, :optional, :repeating,
          [
            {:segment, :ROL, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
         {:segment, :CTI, :optional, :repeating}
       ]},
      {:group, :PATIENT_VISITS, :required, :repeating,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:group, :MEDICATION_HISTORY, :optional, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :MEDICATION_ORDER_DETAIL, :optional,
          [
            {:segment, :RXO, :required},
            {:segment, :RXR, :required, :repeating},
            {:segment, :RXC, :optional, :repeating}
          ]},
         {:group, :MEDICATION_ENCODING_DETAIL, :optional,
          [
            {:segment, :RXE, :required},
            {:segment, :RXR, :required, :repeating}
          ]},
         {:group, :MEDICATION_ADMINISTRATION_DETAIL, :optional, :repeating,
          [
            {:segment, :RXA, :required},
            {:segment, :RXR, :required}
          ]},
         {:segment, :CTI, :optional, :repeating}
       ]},
      {:group, :PROBLEM, :optional, :repeating,
       [
         {:segment, :PRB, :required},
         {:segment, :VAR, :optional, :repeating},
         {:group, :ROLE_PROBLEM, :optional, :repeating,
          [
            {:segment, :ROL, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
         {:segment, :OBX, :optional, :repeating}
       ]},
      {:group, :GOAL, :optional, :repeating,
       [
         {:segment, :GOL, :required},
         {:segment, :VAR, :optional, :repeating},
         {:group, :ROLE_GOAL, :optional, :repeating,
          [
            {:segment, :ROL, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
         {:segment, :OBX, :optional, :repeating}
       ]},
      {:group, :PATHWAY, :optional, :repeating,
       [
         {:segment, :PTH, :required},
         {:segment, :VAR, :optional, :repeating},
         {:group, :ROLE_PATHWAY, :optional, :repeating,
          [
            {:segment, :ROL, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
         {:segment, :OBX, :optional, :repeating}
       ]},
      {:segment, :REL, :optional, :repeating}
    ]
  }

  # CCI_I22: Collaborative Care Information
  @cci_i22 %{
    name: "CCI_I22",
    description: "Collaborative Care Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :PID, :required},
      {:segment, :PD1, :optional},
      {:segment, :NK1, :optional, :repeating},
      {:group, :INSURANCE, :optional, :repeating,
       [
         {:segment, :IN1, :required},
         {:segment, :IN2, :optional},
         {:segment, :IN3, :optional}
       ]},
      {:group, :CLINICAL_HISTORY, :optional, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :CLINICAL_HISTORY_DETAIL, :optional, :repeating,
          [
            {:segment, :OBR, :required},
            {:segment, :OBX, :optional, :repeating}
          ]}
       ]},
      {:group, :PATIENT_VISITS, :required, :repeating,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:group, :MEDICATION_HISTORY, :optional, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :MEDICATION_ORDER_DETAIL, :optional,
          [
            {:segment, :RXO, :required},
            {:segment, :RXR, :required, :repeating}
          ]},
         {:group, :MEDICATION_ENCODING_DETAIL, :optional,
          [
            {:segment, :RXE, :required},
            {:segment, :RXR, :required, :repeating}
          ]},
         {:group, :MEDICATION_ADMINISTRATION_DETAIL, :optional, :repeating,
          [
            {:segment, :RXA, :required},
            {:segment, :RXR, :required}
          ]}
       ]},
      {:group, :PROBLEM, :optional, :repeating,
       [
         {:segment, :PRB, :required},
         {:segment, :VAR, :optional, :repeating},
         {:segment, :OBX, :optional, :repeating}
       ]},
      {:group, :GOAL, :optional, :repeating,
       [
         {:segment, :GOL, :required},
         {:segment, :VAR, :optional, :repeating},
         {:segment, :OBX, :optional, :repeating}
       ]},
      {:group, :PATHWAY, :optional, :repeating,
       [
         {:segment, :PTH, :required},
         {:segment, :VAR, :optional, :repeating},
         {:segment, :OBX, :optional, :repeating}
       ]},
      {:segment, :REL, :optional, :repeating}
    ]
  }

  # CCU_I20: Asynchronous Collaborative Care Update
  @ccu_i20 %{
    name: "CCU_I20",
    description: "Asynchronous Collaborative Care Update",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :RF1, :required},
      {:group, :PROVIDER_CONTACT, :optional, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:group, :PATIENT, :required, :repeating,
       [
         {:segment, :PID, :required},
         {:segment, :PD1, :optional}
       ]},
      {:segment, :NK1, :optional, :repeating},
      {:group, :INSURANCE, :optional, :repeating,
       [
         {:segment, :IN1, :required},
         {:segment, :IN2, :optional},
         {:segment, :IN3, :optional}
       ]},
      {:group, :CLINICAL_HISTORY, :optional, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :CLINICAL_HISTORY_DETAIL, :optional, :repeating,
          [
            {:segment, :OBR, :required},
            {:segment, :OBX, :optional, :repeating}
          ]}
       ]},
      {:group, :PATIENT_VISITS, :required, :repeating,
       [
         {:segment, :PV1, :required},
         {:segment, :PV2, :optional}
       ]},
      {:group, :MEDICATION_HISTORY, :optional, :repeating,
       [
         {:segment, :ORC, :required},
         {:group, :MEDICATION_ORDER_DETAIL, :optional,
          [
            {:segment, :RXO, :required},
            {:segment, :RXR, :required, :repeating}
          ]},
         {:group, :MEDICATION_ENCODING_DETAIL, :optional,
          [
            {:segment, :RXE, :required},
            {:segment, :RXR, :required, :repeating}
          ]},
         {:group, :MEDICATION_ADMINISTRATION_DETAIL, :optional, :repeating,
          [
            {:segment, :RXA, :required},
            {:segment, :RXR, :required}
          ]}
       ]},
      {:group, :PROBLEM, :optional, :repeating,
       [
         {:segment, :PRB, :required},
         {:segment, :VAR, :optional, :repeating},
         {:segment, :OBX, :optional, :repeating}
       ]},
      {:group, :GOAL, :optional, :repeating,
       [
         {:segment, :GOL, :required},
         {:segment, :VAR, :optional, :repeating},
         {:segment, :OBX, :optional, :repeating}
       ]},
      {:group, :PATHWAY, :optional, :repeating,
       [
         {:segment, :PTH, :required},
         {:segment, :VAR, :optional, :repeating},
         {:segment, :OBX, :optional, :repeating}
       ]},
      {:segment, :REL, :optional, :repeating}
    ]
  }

  # CCQ_I19: Collaborative Care Query
  @ccq_i19 %{
    name: "CCQ_I19",
    description: "Collaborative Care Query",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :RF1, :required},
      {:group, :PROVIDER_CONTACT, :optional, :repeating,
       [
         {:segment, :PRD, :required},
         {:segment, :CTD, :optional, :repeating}
       ]},
      {:segment, :REL, :optional, :repeating}
    ]
  }

  # CCF_I22: Collaborative Care Fetch
  @ccf_i22 %{
    name: "CCF_I22",
    description: "Collaborative Care Fetch",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :PID, :required},
      {:segment, :REL, :optional, :repeating}
    ]
  }

  # ---------------------------------------------------------------------------
  # Additional Misc Structures
  # ---------------------------------------------------------------------------

  # ORA_R41: Observation Report Alert Acknowledgment
  @ora_r41 %{
    name: "ORA_R41",
    description: "Observation Report Alert Acknowledgment",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating}
    ]
  }

  # ORU_R32: Unsolicited Pre-ordered Point-of-Care Observation
  @oru_r32 %{
    name: "ORU_R32",
    description: "Unsolicited Pre-ordered Point-of-Care Observation",
    nodes: @oru_r30.nodes
  }

  # ---------------------------------------------------------------------------
  # EHC Structures (Chapter 16 - E-Health)
  # ---------------------------------------------------------------------------

  # EHC_E01: Submit Health Care Services Invoice
  @ehc_e01 %{
    name: "EHC_E01",
    description: "Submit Health Care Services Invoice",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :INVOICE_INFORMATION_SUBMIT, :required, :repeating,
       [
         {:segment, :IVC, :required},
         {:segment, :CTD, :optional, :repeating},
         {:segment, :LOC, :optional, :repeating},
         {:segment, :ROL, :optional, :repeating},
         {:group, :PRODUCT_SERVICE_SECTION, :required, :repeating,
          [
            {:segment, :PSS, :required},
            {:group, :PRODUCT_SERVICE_GROUP, :required, :repeating,
             [
               {:segment, :PSG, :required},
               {:group, :PRODUCT_SERVICE_LINE_ITEM, :required, :repeating,
                [
                  {:segment, :PSL, :required},
                  {:segment, :NTE, :optional, :repeating},
                  {:segment, :ADJ, :optional, :repeating},
                  {:segment, :ABS, :optional},
                  {:segment, :LOC, :optional, :repeating},
                  {:segment, :ROL, :optional, :repeating}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # EHC_E02: Cancel Health Care Services Invoice
  @ehc_e02 %{
    name: "EHC_E02",
    description: "Cancel Health Care Services Invoice",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :INVOICE_INFORMATION_CANCEL, :required, :repeating,
       [
         {:segment, :IVC, :required},
         {:segment, :CTD, :optional, :repeating}
       ]}
    ]
  }

  # EHC_E04: Re-Assess Health Care Services Invoice Request
  @ehc_e04 %{
    name: "EHC_E04",
    description: "Re-Assess Health Care Services Invoice Request",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :REASSESSMENT_REQUEST_INFO, :required, :repeating,
       [
         {:segment, :IVC, :required},
         {:segment, :CTD, :optional, :repeating},
         {:segment, :NTE, :optional, :repeating},
         {:group, :PRODUCT_SERVICE_SECTION, :required, :repeating,
          [
            {:segment, :PSS, :required},
            {:group, :PRODUCT_SERVICE_GROUP, :required, :repeating,
             [
               {:segment, :PSG, :required},
               {:segment, :PSL, :required, :repeating}
             ]}
          ]}
       ]}
    ]
  }

  # EHC_E10: Edit/Adjudication Results
  @ehc_e10 %{
    name: "EHC_E10",
    description: "Edit/Adjudication Results",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:group, :INVOICE_PROCESSING_RESULTS_INFO, :required, :repeating,
       [
         {:segment, :IVC, :required},
         {:segment, :IPR, :required},
         {:group, :PRODUCT_SERVICE_SECTION, :required, :repeating,
          [
            {:segment, :PSS, :required},
            {:group, :PRODUCT_SERVICE_GROUP, :required, :repeating,
             [
               {:segment, :PSG, :required},
               {:group, :PRODUCT_SERVICE_LINE_ITEM, :required, :repeating,
                [
                  {:segment, :PSL, :required},
                  {:segment, :ADJ, :optional, :repeating}
                ]}
             ]}
          ]}
       ]}
    ]
  }

  # EHC_E12: Request Additional Information
  @ehc_e12 %{
    name: "EHC_E12",
    description: "Request Additional Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :RFI, :required},
      {:segment, :CTD, :optional, :repeating},
      {:segment, :IVC, :required},
      {:segment, :PSS, :required},
      {:segment, :PSG, :required},
      {:segment, :PID, :optional},
      {:segment, :PSL, :optional, :repeating},
      {:group, :REQUEST, :required, :repeating,
       [
         {:segment, :CTD, :optional},
         {:segment, :OBR, :required},
         {:segment, :NTE, :optional},
         {:segment, :OBX, :optional, :repeating}
       ]}
    ]
  }

  # EHC_E13: Additional Information Response
  @ehc_e13 %{
    name: "EHC_E13",
    description: "Additional Information Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :RFI, :required},
      {:segment, :CTD, :optional, :repeating},
      {:segment, :IVC, :required},
      {:segment, :PSS, :required},
      {:segment, :PSG, :required},
      {:segment, :PID, :optional},
      {:segment, :PSL, :optional, :repeating},
      {:group, :REQUEST, :required, :repeating,
       [
         {:segment, :CTD, :optional},
         {:segment, :OBR, :required},
         {:segment, :NTE, :optional},
         {:segment, :OBX, :optional, :repeating}
       ]}
    ]
  }

  # EHC_E15: Payment/Remittance Advice
  @ehc_e15 %{
    name: "EHC_E15",
    description: "Payment/Remittance Advice",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :PAYMENT_REMITTANCE_HEADER_INFO, :required,
       [
         {:segment, :PMT, :required},
         {:group, :PAYMENT_REMITTANCE_DETAIL_INFO, :optional, :repeating,
          [
            {:segment, :IPR, :required},
            {:segment, :IVC, :required},
            {:group, :PRODUCT_SERVICE_SECTION, :required, :repeating,
             [
               {:segment, :PSS, :required},
               {:group, :PRODUCT_SERVICE_GROUP, :required, :repeating,
                [
                  {:segment, :PSG, :required},
                  {:segment, :PSL, :optional, :repeating},
                  {:segment, :ADJ, :optional, :repeating}
                ]}
             ]}
          ]}
       ]},
      {:group, :ADJUSTMENT_PAYEE, :optional, :repeating,
       [
         {:segment, :ADJ, :required},
         {:segment, :ROL, :optional}
       ]}
    ]
  }

  # EHC_E20: Submit Authorization Request
  @ehc_e20 %{
    name: "EHC_E20",
    description: "Submit Authorization Request",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :AUTHORIZATION_REQUEST, :required, :repeating,
       [
         {:segment, :IVC, :required},
         {:segment, :CTD, :optional, :repeating},
         {:segment, :LOC, :optional, :repeating},
         {:segment, :ROL, :optional, :repeating},
         {:group, :PAT_INFO, :required, :repeating,
          [
            {:segment, :PID, :required},
            {:segment, :ACC, :optional},
            {:group, :INSURANCE, :required, :repeating,
             [
               {:segment, :IN1, :required},
               {:segment, :IN2, :optional}
             ]},
            {:group, :DIAGNOSIS, :optional, :repeating,
             [
               {:segment, :DG1, :required},
               {:segment, :NTE, :optional, :repeating}
             ]},
            {:group, :PROCEDURE, :optional, :repeating,
             [
               {:segment, :PR1, :required},
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]}
       ]}
    ]
  }

  # EHC_E21: Cancel Authorization Request
  @ehc_e21 %{
    name: "EHC_E21",
    description: "Cancel Authorization Request",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:group, :AUTHORIZATION_REQUEST, :required, :repeating,
       [
         {:segment, :IVC, :required},
         {:segment, :CTD, :optional, :repeating}
       ]}
    ]
  }

  # EHC_E24: Authorization Response
  @ehc_e24 %{
    name: "EHC_E24",
    description: "Authorization Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:group, :AUTHORIZATION_RESPONSE_INFO, :required, :repeating,
       [
         {:segment, :IVC, :required},
         {:segment, :CTD, :optional, :repeating}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # ADT Additional — Merge Patient Information (A18)
  # ---------------------------------------------------------------------------

  # ADT_A18: Merge Patient Information (variant of merge)
  @adt_a18 %{
    name: "ADT_A18",
    description: "Merge Patient Information",
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

  # ADT_A52: Cancel Leave of Absence (same structure as ADT_A21)
  @adt_a52 %{
    name: "ADT_A52",
    description: "Cancel Leave of Absence",
    nodes: @adt_a21.nodes
  }

  # ---------------------------------------------------------------------------
  # Master File Response Structures (MFR)
  # ---------------------------------------------------------------------------

  # MFR_M04: Master File Response — Charge Description
  @mfr_m04 %{
    name: "MFR_M04",
    description: "Master File Response — Charge Description",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :QAK, :optional},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:segment, :MFI, :required},
      {:group, :MF_QUERY, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :CDM, :required},
         {:segment, :LOC, :optional, :repeating},
         {:segment, :PRC, :optional, :repeating}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # MFR_M05: Master File Response — Patient Location
  @mfr_m05 %{
    name: "MFR_M05",
    description: "Master File Response — Patient Location",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :QAK, :optional},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:segment, :MFI, :required},
      {:group, :MF_QUERY, :required, :repeating,
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
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # MFR_M06: Master File Response — Clinical Study
  @mfr_m06 %{
    name: "MFR_M06",
    description: "Master File Response — Clinical Study",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :QAK, :optional},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:segment, :MFI, :required},
      {:group, :MF_QUERY, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :CM0, :required},
         {:segment, :CM1, :optional, :repeating},
         {:segment, :CM2, :optional, :repeating}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # MFR_M07: Master File Response — Calendar/Campaign
  @mfr_m07 %{
    name: "MFR_M07",
    description: "Master File Response — Calendar/Campaign",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :QAK, :optional},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:segment, :MFI, :required},
      {:group, :MF_QUERY, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :CM0, :required}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # MFN_M15: Master File Notification — Specimen
  @mfn_m15 %{
    name: "MFN_M15",
    description: "Master File Notification — Inventory Item Enhanced",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MFI, :required},
      {:group, :MF_INV_ITEM, :required, :repeating,
       [
         {:segment, :MFE, :required},
         {:segment, :IIM, :required}
       ]}
    ]
  }

  # ---------------------------------------------------------------------------
  # Observation Response Structures
  # ---------------------------------------------------------------------------

  # ORF_R04: Response to Query — Observation
  @orf_r04 %{
    name: "ORF_R04",
    description: "Response to Query — Transmission of Requested Observation",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :QRD, :optional},
      {:segment, :QRF, :optional},
      {:group, :QUERY_RESPONSE, :optional, :repeating,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
         {:group, :ORDER, :required, :repeating,
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
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]}
       ]},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :QAK, :optional},
      {:segment, :DSC, :optional}
    ]
  }

  # ---------------------------------------------------------------------------
  # Legacy Query Structures (QRY, OSQ, OSR)
  # ---------------------------------------------------------------------------

  # QRY_Q01: Query Sent for Immediate Response
  @qry_q01 %{
    name: "QRY_Q01",
    description: "Query Sent for Immediate Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:segment, :DSC, :optional}
    ]
  }

  # QRY_Q02: Query Sent for Deferred Response
  @qry_q02 %{
    name: "QRY_Q02",
    description: "Query Sent for Deferred Response",
    nodes: @qry_q01.nodes
  }

  # QRY_R02: Query for Results of Observation
  @qry_r02 %{
    name: "QRY_R02",
    description: "Query for Results of Observation",
    nodes: @qry_q01.nodes
  }

  # QRY_PC4: Problem Query
  @qry_pc4 %{
    name: "QRY_PC4",
    description: "Problem Query",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional}
    ]
  }

  # OSQ_Q06: Query for Order Status
  @osq_q06 %{
    name: "OSQ_Q06",
    description: "Query for Order Status",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:segment, :DSC, :optional}
    ]
  }

  # OSR_Q06: Query Response for Order Status
  @osr_q06 %{
    name: "OSR_Q06",
    description: "Query Response for Order Status",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:segment, :QAK, :required},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
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
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # ---------------------------------------------------------------------------
  # Additional RSP Query Response Structures
  # ---------------------------------------------------------------------------

  # RSP_Q11: Segment Pattern Response (variant for QBP^Q11)
  @rsp_q11 %{
    name: "RSP_Q11",
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

  # RSP_K23: Allocate Identifiers Response
  @rsp_k23 %{
    name: "RSP_K23",
    description: "Allocate Identifiers Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:segment, :PID, :optional},
      {:segment, :DSC, :optional}
    ]
  }

  # RSP_K25: Personnel Information Response
  @rsp_k25 %{
    name: "RSP_K25",
    description: "Personnel Information Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:group, :STAFF, :optional, :repeating,
       [
         {:segment, :STF, :required},
         {:segment, :PRA, :optional},
         {:segment, :ORG, :optional, :repeating},
         {:segment, :AFF, :optional, :repeating},
         {:segment, :LAN, :optional, :repeating},
         {:segment, :EDU, :optional, :repeating},
         {:segment, :CER, :optional, :repeating}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # RSP_Z82: Pharmacy Dispense Information Response
  @rsp_z82 %{
    name: "RSP_Z82",
    description: "Dispense History Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:segment, :RCP, :optional},
      {:group, :QUERY_RESPONSE, :optional, :repeating,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :PD1, :optional},
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
            {:segment, :RXD, :required},
            {:segment, :RXR, :required, :repeating},
            {:segment, :RXC, :optional, :repeating},
            {:group, :OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :optional},
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # RSP_Z86: Pharmacy Information Comprehensive Response
  @rsp_z86 %{
    name: "RSP_Z86",
    description: "Pharmacy Information Comprehensive Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:group, :QUERY_RESPONSE, :optional, :repeating,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :PD1, :optional},
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
            {:segment, :RXR, :required, :repeating},
            {:segment, :RXC, :optional, :repeating},
            {:group, :OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :optional},
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # RSP_Z88: Pharmacy Encoded Order Response
  @rsp_z88 %{
    name: "RSP_Z88",
    description: "Pharmacy Encoded Order Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:segment, :RCP, :required},
      {:group, :QUERY_RESPONSE, :optional, :repeating,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :PD1, :optional},
            {:segment, :NTE, :optional, :repeating},
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
            {:segment, :RXE, :required},
            {:segment, :RXR, :required, :repeating},
            {:segment, :RXC, :optional, :repeating},
            {:group, :OBSERVATION, :optional, :repeating,
             [
               {:segment, :OBX, :optional},
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # RSP_Z90: Lab Results Response
  @rsp_z90 %{
    name: "RSP_Z90",
    description: "Lab Results History Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional},
      {:segment, :QAK, :required},
      {:segment, :QPD, :required},
      {:segment, :RCP, :required},
      {:group, :QUERY_RESPONSE, :optional, :repeating,
       [
         {:group, :PATIENT, :optional,
          [
            {:segment, :PID, :required},
            {:segment, :PD1, :optional},
            {:segment, :NK1, :optional, :repeating},
            {:segment, :NTE, :optional, :repeating},
            {:group, :VISIT, :optional,
             [
               {:segment, :PV1, :required},
               {:segment, :PV2, :optional}
             ]}
          ]},
         {:group, :ORDER, :required, :repeating,
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
               {:segment, :OBX, :required},
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]}
       ]},
      {:segment, :DSC, :optional}
    ]
  }

  # ---------------------------------------------------------------------------
  # Scheduling Query Structures (SQM/SQR)
  # ---------------------------------------------------------------------------

  # SQM_S25: Schedule Query Message
  @sqm_s25 %{
    name: "SQM_S25",
    description: "Schedule Query Message",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:group, :REQUEST, :optional,
       [
         {:segment, :ARQ, :required},
         {:segment, :APR, :optional},
         {:group, :RESOURCES, :required, :repeating,
          [
            {:segment, :RGS, :required},
            {:group, :SERVICE, :optional, :repeating,
             [
               {:segment, :AIS, :required},
               {:segment, :APR, :optional}
             ]},
            {:group, :GENERAL_RESOURCE, :optional, :repeating,
             [
               {:segment, :AIG, :required},
               {:segment, :APR, :optional}
             ]},
            {:group, :PERSONNEL_RESOURCE, :optional, :repeating,
             [
               {:segment, :AIP, :required},
               {:segment, :APR, :optional}
             ]},
            {:group, :LOCATION_RESOURCE, :optional, :repeating,
             [
               {:segment, :AIL, :required},
               {:segment, :APR, :optional}
             ]}
          ]}
       ]}
    ]
  }

  # SQR_S25: Schedule Query Response
  @sqr_s25 %{
    name: "SQR_S25",
    description: "Schedule Query Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :QAK, :required},
      {:group, :SCHEDULE, :optional, :repeating,
       [
         {:segment, :SCH, :required},
         {:segment, :TQ1, :optional, :repeating},
         {:segment, :NTE, :optional, :repeating},
         {:group, :PATIENT, :optional,
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
            {:group, :PERSONNEL_RESOURCE, :optional, :repeating,
             [
               {:segment, :AIP, :required},
               {:segment, :NTE, :optional, :repeating}
             ]},
            {:group, :LOCATION_RESOURCE, :optional, :repeating,
             [
               {:segment, :AIL, :required},
               {:segment, :NTE, :optional, :repeating}
             ]}
          ]}
       ]}
    ]
  }

  # EAN_U09: Equipment Advisory Notification
  @ean_u09 %{
    name: "EAN_U09",
    description: "Automated Equipment Notification",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :EQU, :required},
      {:group, :NOTIFICATION, :required, :repeating, [
        {:segment, :NDS, :required},
        {:segment, :NTE, :optional}
      ]},
      {:segment, :ROL, :optional}
    ]
  }

  # PPV_PCA: Patient Pathway (Goal-Oriented) Response
  @ppv_pca %{
    name: "PPV_PCA",
    description: "Patient Goal Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :QAK, :optional},
      {:segment, :QRD, :required},
      {:group, :PATIENT, :required, :repeating, [
        {:segment, :PID, :required},
        {:group, :PATIENT_VISIT, :optional, [
          {:segment, :PV1, :required},
          {:segment, :PV2, :optional}
        ]},
        {:group, :GOAL, :required, :repeating, [
          {:segment, :GOL, :required},
          {:segment, :NTE, :optional, :repeating},
          {:segment, :VAR, :optional, :repeating},
          {:group, :GOAL_ROLE, :optional, :repeating, [
            {:segment, :ROL, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
          {:group, :GOAL_PATHWAY, :optional, :repeating, [
            {:segment, :PTH, :required},
            {:segment, :VAR, :optional, :repeating}
          ]},
          {:group, :GOAL_OBSERVATION, :optional, :repeating, [
            {:segment, :OBX, :required},
            {:segment, :NTE, :optional, :repeating}
          ]},
          {:group, :PROBLEM, :optional, :repeating, [
            {:segment, :PRB, :required},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :VAR, :optional, :repeating},
            {:group, :PROBLEM_ROLE, :optional, :repeating, [
              {:segment, :ROL, :required},
              {:segment, :VAR, :optional, :repeating}
            ]},
            {:group, :PROBLEM_OBSERVATION, :optional, :repeating, [
              {:segment, :OBX, :required},
              {:segment, :NTE, :optional, :repeating}
            ]}
          ]},
          {:group, :ORDER, :optional, :repeating, [
            {:segment, :ORC, :required},
            {:group, :ORDER_DETAIL, :optional, [
              {:segment, :OBR, :required},
              {:segment, :NTE, :optional, :repeating},
              {:segment, :VAR, :optional, :repeating},
              {:group, :ORDER_OBSERVATION, :optional, :repeating, [
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

  # PRR_PC5: Patient Problem Response
  @prr_pc5 %{
    name: "PRR_PC5",
    description: "Patient Problem Response",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:segment, :QAK, :optional},
      {:segment, :QRD, :required},
      {:group, :PATIENT, :required, :repeating, [
        {:segment, :PID, :required},
        {:group, :PATIENT_VISIT, :optional, [{:segment, :PV1, :required}, {:segment, :PV2, :optional}]},
        {:group, :PROBLEM, :required, :repeating, [
          {:segment, :PRB, :required},
          {:segment, :NTE, :optional, :repeating},
          {:segment, :VAR, :optional, :repeating},
          {:group, :PROBLEM_ROLE, :optional, :repeating, [{:segment, :ROL, :required}, {:segment, :VAR, :optional, :repeating}]},
          {:group, :PROBLEM_PATHWAY, :optional, :repeating, [{:segment, :PTH, :required}, {:segment, :VAR, :optional, :repeating}]},
          {:group, :PROBLEM_OBSERVATION, :optional, :repeating, [{:segment, :OBX, :required}, {:segment, :NTE, :optional, :repeating}]},
          {:group, :GOAL, :optional, :repeating, [
            {:segment, :GOL, :required},
            {:segment, :NTE, :optional, :repeating},
            {:segment, :VAR, :optional, :repeating},
            {:group, :GOAL_ROLE, :optional, :repeating, [{:segment, :ROL, :required}, {:segment, :VAR, :optional, :repeating}]},
            {:group, :GOAL_OBSERVATION, :optional, :repeating, [{:segment, :OBX, :required}, {:segment, :NTE, :optional, :repeating}]}
          ]},
          {:group, :ORDER, :optional, :repeating, [
            {:segment, :ORC, :required},
            {:group, :ORDER_DETAIL, :optional, [{:segment, :OBR, :required}, {:segment, :NTE, :optional, :repeating}, {:segment, :VAR, :optional, :repeating}, {:group, :ORDER_OBSERVATION, :optional, :repeating, [{:segment, :OBX, :required}, {:segment, :NTE, :optional, :repeating}, {:segment, :VAR, :optional, :repeating}]}]}
          ]}
        ]}
      ]}
    ]
  }

  # PTR_PCF: Pathway (Problem-Oriented) Response — same structure as PRR_PC5
  @ptr_pcf %{@prr_pc5 | name: "PTR_PCF", description: "Patient Pathway Response"}

  # QBP_Z73: Information about Pending Events Query
  @qbp_z73 %{
    name: "QBP_Z73",
    description: "Information about Pending Events",
    nodes: [{:segment, :MSH, :required}, {:segment, :SFT, :optional, :repeating}, {:segment, :QPD, :required}, {:segment, :RCP, :required}, {:segment, :DSC, :optional}]
  }

  # QRY: Original-Style Query (generic, no qualifier)
  @qry %{
    name: "QRY",
    description: "Original-Style Query",
    nodes: [{:segment, :MSH, :required}, {:segment, :SFT, :optional, :repeating}, {:segment, :QRD, :required}, {:segment, :QRF, :optional}, {:segment, :DSC, :optional}]
  }

  # RCL_I06: Request/Receipt of Clinical Data Listing
  @rcl_i06 %{
    name: "RCL_I06",
    description: "Request Clinical Data Listing",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :QRD, :required},
      {:segment, :QRF, :optional},
      {:group, :PROVIDER, :required, :repeating, [
        {:segment, :PRD, :required},
        {:segment, :CTD, :optional, :repeating}
      ]},
      {:segment, :PID, :required},
      {:segment, :DG1, :optional, :repeating},
      {:segment, :DRG, :optional, :repeating},
      {:segment, :AL1, :optional, :repeating},
      {:segment, :NTE, :optional, :repeating},
      {:segment, :DSP, :optional, :repeating},
      {:segment, :DSC, :optional}
    ]
  }

  # RGR_RGR: Pharmacy/Treatment Dose Information
  @rgr_rgr %{
    name: "RGR_RGR",
    description: "Pharmacy/Treatment Dose Information",
    nodes: [
      {:segment, :MSH, :required},
      {:segment, :SFT, :optional, :repeating},
      {:segment, :MSA, :required},
      {:segment, :ERR, :optional, :repeating},
      {:group, :DEFINITION, :required, :repeating, [
        {:segment, :QRD, :required},
        {:segment, :QRF, :optional},
        {:group, :PATIENT, :optional, [{:segment, :PID, :required}, {:segment, :NTE, :optional, :repeating}]},
        {:group, :ORDER, :required, :repeating, [
          {:segment, :ORC, :required},
          {:group, :ENCODING, :optional, [{:segment, :RXE, :required}, {:segment, :RXR, :required, :repeating}, {:segment, :RXC, :optional, :repeating}]},
          {:segment, :RXG, :required, :repeating},
          {:segment, :RXR, :required, :repeating},
          {:segment, :RXC, :optional, :repeating}
        ]}
      ]},
      {:segment, :DSC, :optional}
    ]
  }

  # RTB_Z74: Information about Pending Events Response
  @rtb_z74 %{
    name: "RTB_Z74",
    description: "Tabular Response — Pending Events",
    nodes: [{:segment, :MSH, :required}, {:segment, :SFT, :optional, :repeating}, {:segment, :MSA, :required}, {:segment, :ERR, :optional}, {:segment, :QAK, :required}, {:segment, :QPD, :required}, {:segment, :RDF, :optional}, {:segment, :RDT, :optional, :repeating}, {:segment, :DSC, :optional}]
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
    "ADT_A18" => @adt_a18,
    "ADT_A52" => @adt_a52,
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
    "PPV_PCA" => @ppv_pca,
    "PRR_PC5" => @prr_pc5,
    "PTR_PCF" => @ptr_pcf,
    "PPT_PCL" => @ppt_pcl,
    "QBP_Q21" => @qbp_q21,
    "QBP_Z73" => @qbp_z73,
    "QCK_Q02" => @qck_q02,
    "QCN_J01" => @qcn_j01,
    "RAS_O17" => @ras_o17,
    "RDE_O11" => @rde_o11,
    "RDS_O13" => @rds_o13,
    "RDY_K15" => @rdy_k15,
    "RCL_I06" => @rcl_i06,
    "REF_I12" => @ref_i12,
    "RGR_RGR" => @rgr_rgr,
    "RGV_O15" => @rgv_o15,
    "RRA_O18" => @rra_o18,
    "RRD_O14" => @rrd_o14,
    "RRE_O12" => @rre_o12,
    "RRI_I12" => @rri_i12,
    "RRG_O16" => @rrg_o16,
    "RSP_K21" => @rsp_k21,
    "RTB_K13" => @rtb_k13,
    "RTB_Z74" => @rtb_z74,
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
    "VXX_V02" => @vxx_v02,
    # MDM variants
    "MDM_T01" => @mdm_t01,
    "MDM_T03" => @mdm_t03,
    "MDM_T04" => @mdm_t04,
    "MDM_T05" => @mdm_t05,
    "MDM_T06" => @mdm_t06,
    "MDM_T07" => @mdm_t07,
    "MDM_T08" => @mdm_t08,
    "MDM_T09" => @mdm_t09,
    "MDM_T10" => @mdm_t10,
    "MDM_T11" => @mdm_t11,
    # Additional order structures
    "OMI_O23" => @omi_o23,
    "ORI_O24" => @ori_o24,
    "OMN_O07" => @omn_o07,
    "ORN_O08" => @orn_o08,
    "ORD_O04" => @ord_o04,
    "ORS_O06" => @ors_o06,
    "OML_O33" => @oml_o33,
    "OML_O35" => @oml_o35,
    "ORL_O34" => @orl_o34,
    "ORL_O36" => @orl_o36,
    "OMB_O27" => @omb_o27,
    "ORB_O28" => @orb_o28,
    "OML_O39" => @oml_o39,
    "ORL_O40" => @orl_o40,
    # Additional observation structures
    "OUL_R22" => @oul_r22,
    "OUL_R23" => @oul_r23,
    "OUL_R24" => @oul_r24,
    "ORA_R41" => @ora_r41,
    "ORU_R32" => @oru_r32,
    # Patient info request/response
    "QRY_A19" => @qry_a19,
    "RQI_I01" => @rqi_i01,
    "RPA_I08" => @rpa_i08,
    "RPI_I01" => @rpi_i01,
    "RPI_I04" => @rpi_i04,
    "RQA_I08" => @rqa_i08,
    "RQC_I05" => @rqc_i05,
    "RCI_I05" => @rci_i05,
    "RQP_I04" => @rqp_i04,
    "RPL_I02" => @rpl_i02,
    "RPR_I03" => @rpr_i03,
    # Pharmacy query responses
    "RER_RER" => @rer_rer,
    "RDR_RDR" => @rdr_rdr,
    "RAR_RAR" => @rar_rar,
    "ROR_ROR" => @ror_ror,
    # Additional personnel
    "PMU_B04" => @pmu_b04,
    "PMU_B07" => @pmu_b07,
    "PMU_B08" => @pmu_b08,
    # Additional ADT
    "ADT_A54" => @adt_a54,
    "ADT_A60" => @adt_a60,
    "ADT_A61" => @adt_a61,
    # Additional query
    "QBP_Q11" => @qbp_q11,
    "QBP_Q13" => @qbp_q13,
    "QBP_Q15" => @qbp_q15,
    "QSB_Q16" => @qsb_q16,
    "QVR_Q17" => @qvr_q17,
    "RSP_K11" => @rsp_k11,
    "RSP_K13" => @rsp_k13,
    "RSP_K15" => @rsp_k15,
    "RSP_K31" => @rsp_k31,
    # Additional master file
    "MFN_M03" => @mfn_m03,
    "MFN_M04" => @mfn_m04,
    "MFN_M06" => @mfn_m06,
    "MFN_M07" => @mfn_m07,
    "MFN_M08" => @mfn_m08,
    "MFN_M09" => @mfn_m09,
    "MFN_M10" => @mfn_m10,
    "MFN_M11" => @mfn_m11,
    "MFN_M12" => @mfn_m12,
    "MFN_M13" => @mfn_m13,
    "MFR_M01" => @mfr_m01,
    "MFR_M04" => @mfr_m04,
    "MFR_M05" => @mfr_m05,
    "MFR_M06" => @mfr_m06,
    "MFR_M07" => @mfr_m07,
    "MFN_M15" => @mfn_m15,
    # Observation response
    "ORF_R04" => @orf_r04,
    # Legacy query structures
    "QRY_Q01" => @qry_q01,
    "QRY_Q02" => @qry_q02,
    "QRY_R02" => @qry_r02,
    "QRY" => @qry,
    "QRY_PC4" => @qry_pc4,
    "OSQ_Q06" => @osq_q06,
    "OSR_Q06" => @osr_q06,
    # Additional RSP responses
    "RSP_Q11" => @rsp_q11,
    "RSP_K23" => @rsp_k23,
    "RSP_K25" => @rsp_k25,
    "RSP_Z82" => @rsp_z82,
    "RSP_Z86" => @rsp_z86,
    "RSP_Z88" => @rsp_z88,
    "RSP_Z90" => @rsp_z90,
    # Scheduling query
    "SQM_S25" => @sqm_s25,
    "SQR_S25" => @sqr_s25,
    # Collaborative care
    "CCR_I16" => @ccr_i16,
    "CCI_I22" => @cci_i22,
    "CCU_I20" => @ccu_i20,
    "CCQ_I19" => @ccq_i19,
    "CCF_I22" => @ccf_i22,
    # EHC (E-Health)
    "EHC_E01" => @ehc_e01,
    "EHC_E02" => @ehc_e02,
    "EHC_E04" => @ehc_e04,
    "EHC_E10" => @ehc_e10,
    "EHC_E12" => @ehc_e12,
    "EHC_E13" => @ehc_e13,
    "EHC_E15" => @ehc_e15,
    "EHC_E20" => @ehc_e20,
    "EHC_E21" => @ehc_e21,
    "EAN_U09" => @ean_u09,
    "EHC_E24" => @ehc_e24,
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
