defmodule HL7v2.Standard do
  @moduledoc """
  HL7 v2.5.1 standard metadata — single source of truth.

  Compile-time catalogs for segments, data types, message structures, and
  trigger-to-structure mappings from the HL7 v2.5.1 specification.

  Each entry includes a capability tier indicating the library's current
  level of support:

  - `:typed` — full parse/encode with Elixir struct
  - `:raw` — preserved as raw fields during typed parsing, no typed access
  - `:unsupported` — not in the library, unknown segments become raw tuples

  ## Usage

      HL7v2.Standard.segment("PID")
      #=> %{name: "Patient Identification", tier: :typed, module: HL7v2.Segment.PID}

      HL7v2.Standard.type("CX")
      #=> %{name: "Extended Composite ID with Check Digit", category: :composite, tier: :typed}

      HL7v2.Standard.segment_tier("PID")
      #=> :typed

  """

  # ---------------------------------------------------------------------------
  # Segment Catalog — HL7 v2.5.1
  # Source: https://www.hl7.eu/HL7v2x/v251/hl7v251segm.htm
  # ---------------------------------------------------------------------------

  @typed_segment_modules %{
    "ACC" => HL7v2.Segment.ACC,
    "AIG" => HL7v2.Segment.AIG,
    "AIL" => HL7v2.Segment.AIL,
    "AIP" => HL7v2.Segment.AIP,
    "AIS" => HL7v2.Segment.AIS,
    "AL1" => HL7v2.Segment.AL1,
    "BLG" => HL7v2.Segment.BLG,
    "CTD" => HL7v2.Segment.CTD,
    "CTI" => HL7v2.Segment.CTI,
    "DB1" => HL7v2.Segment.DB1,
    "DG1" => HL7v2.Segment.DG1,
    "DRG" => HL7v2.Segment.DRG,
    "DSC" => HL7v2.Segment.DSC,
    "ERR" => HL7v2.Segment.ERR,
    "EVN" => HL7v2.Segment.EVN,
    "FT1" => HL7v2.Segment.FT1,
    "GT1" => HL7v2.Segment.GT1,
    "IAM" => HL7v2.Segment.IAM,
    "IN1" => HL7v2.Segment.IN1,
    "IN2" => HL7v2.Segment.IN2,
    "IN3" => HL7v2.Segment.IN3,
    "MRG" => HL7v2.Segment.MRG,
    "MSA" => HL7v2.Segment.MSA,
    "MSH" => HL7v2.Segment.MSH,
    "NK1" => HL7v2.Segment.NK1,
    "NTE" => HL7v2.Segment.NTE,
    "OBR" => HL7v2.Segment.OBR,
    "OBX" => HL7v2.Segment.OBX,
    "ORC" => HL7v2.Segment.ORC,
    "PD1" => HL7v2.Segment.PD1,
    "PDA" => HL7v2.Segment.PDA,
    "PID" => HL7v2.Segment.PID,
    "PR1" => HL7v2.Segment.PR1,
    "PV1" => HL7v2.Segment.PV1,
    "PV2" => HL7v2.Segment.PV2,
    "RGS" => HL7v2.Segment.RGS,
    "ROL" => HL7v2.Segment.ROL,
    "RXA" => HL7v2.Segment.RXA,
    "RXC" => HL7v2.Segment.RXC,
    "RXD" => HL7v2.Segment.RXD,
    "RXE" => HL7v2.Segment.RXE,
    "RXG" => HL7v2.Segment.RXG,
    "RXO" => HL7v2.Segment.RXO,
    "RXR" => HL7v2.Segment.RXR,
    "SCH" => HL7v2.Segment.SCH,
    "SFT" => HL7v2.Segment.SFT,
    "SPM" => HL7v2.Segment.SPM,
    "TQ1" => HL7v2.Segment.TQ1,
    "TQ2" => HL7v2.Segment.TQ2,
    "TXA" => HL7v2.Segment.TXA,
    "UB1" => HL7v2.Segment.UB1,
    "UB2" => HL7v2.Segment.UB2
  }

  @segment_catalog %{
    # -- Typed segments (37) --
    "ACC" => %{name: "Accident", tier: :typed},
    "AIG" => %{name: "Appointment Information — General Resource", tier: :typed},
    "AIL" => %{name: "Appointment Information — Location Resource", tier: :typed},
    "AIP" => %{name: "Appointment Information — Personnel Resource", tier: :typed},
    "AIS" => %{name: "Appointment Information — Service", tier: :typed},
    "AL1" => %{name: "Patient Allergy Information", tier: :typed},
    "DB1" => %{name: "Disability", tier: :typed},
    "DG1" => %{name: "Diagnosis", tier: :typed},
    "ERR" => %{name: "Error", tier: :typed},
    "EVN" => %{name: "Event Type", tier: :typed},
    "FT1" => %{name: "Financial Transaction", tier: :typed},
    "GT1" => %{name: "Guarantor", tier: :typed},
    "IN1" => %{name: "Insurance", tier: :typed},
    "MRG" => %{name: "Merge Patient Information", tier: :typed},
    "MSA" => %{name: "Message Acknowledgment", tier: :typed},
    "MSH" => %{name: "Message Header", tier: :typed},
    "NK1" => %{name: "Next of Kin / Associated Parties", tier: :typed},
    "NTE" => %{name: "Notes and Comments", tier: :typed},
    "OBR" => %{name: "Observation Request", tier: :typed},
    "OBX" => %{name: "Observation/Result", tier: :typed},
    "ORC" => %{name: "Common Order", tier: :typed},
    "PD1" => %{name: "Patient Additional Demographic", tier: :typed},
    "PID" => %{name: "Patient Identification", tier: :typed},
    "PR1" => %{name: "Procedures", tier: :typed},
    "PV1" => %{name: "Patient Visit", tier: :typed},
    "PV2" => %{name: "Patient Visit — Additional Information", tier: :typed},
    "RGS" => %{name: "Resource Group", tier: :typed},
    "SCH" => %{name: "Scheduling Activity Information", tier: :typed},
    "SFT" => %{name: "Software Segment", tier: :typed},
    # -- Unsupported standard segments --
    "ADD" => %{name: "Addendum", tier: :unsupported},
    "APR" => %{name: "Appointment Preferences", tier: :unsupported},
    "ARQ" => %{name: "Appointment Request", tier: :unsupported},
    "AUT" => %{name: "Authorization Information", tier: :unsupported},
    "BHS" => %{name: "Batch Header", tier: :unsupported},
    "BLC" => %{name: "Blood Code", tier: :unsupported},
    "BLG" => %{name: "Billing", tier: :typed},
    "BPO" => %{name: "Blood Product Order", tier: :unsupported},
    "BPX" => %{name: "Blood Product Dispense Status", tier: :unsupported},
    "BTS" => %{name: "Batch Trailer", tier: :unsupported},
    "CDM" => %{name: "Charge Description Master", tier: :unsupported},
    "CER" => %{name: "Certificate Detail", tier: :unsupported},
    "CM0" => %{name: "Clinical Study Master", tier: :unsupported},
    "CM1" => %{name: "Clinical Study Phase Master", tier: :unsupported},
    "CM2" => %{name: "Clinical Study Schedule Master", tier: :unsupported},
    "CNS" => %{name: "Clear Notification", tier: :unsupported},
    "CON" => %{name: "Consent Segment", tier: :unsupported},
    "CSP" => %{name: "Clinical Study Phase", tier: :unsupported},
    "CSR" => %{name: "Clinical Study Registration", tier: :unsupported},
    "CSS" => %{name: "Clinical Study Data Schedule Segment", tier: :unsupported},
    "CTD" => %{name: "Contact Data", tier: :typed},
    "CTI" => %{name: "Clinical Trial Identification", tier: :typed},
    "DRG" => %{name: "Diagnosis Related Group", tier: :typed},
    "DSC" => %{name: "Continuation Pointer", tier: :typed},
    "DSP" => %{name: "Display Data", tier: :unsupported},
    "ECD" => %{name: "Equipment Command", tier: :unsupported},
    "ECR" => %{name: "Equipment Command Response", tier: :unsupported},
    "EDU" => %{name: "Educational Detail", tier: :unsupported},
    "EQP" => %{name: "Equipment/log Service", tier: :unsupported},
    "EQU" => %{name: "Equipment Detail", tier: :unsupported},
    "FAC" => %{name: "Facility", tier: :unsupported},
    "FHS" => %{name: "File Header", tier: :unsupported},
    "FTS" => %{name: "File Trailer", tier: :unsupported},
    "GOL" => %{name: "Goal Detail", tier: :unsupported},
    "GP1" => %{name: "Grouping/Reimbursement — Visit", tier: :unsupported},
    "GP2" => %{name: "Grouping/Reimbursement — Procedure Line Item", tier: :unsupported},
    "IAM" => %{name: "Patient Adverse Reaction Information", tier: :typed},
    "IIM" => %{name: "Inventory Item Master", tier: :unsupported},
    "IN2" => %{name: "Insurance Additional Information", tier: :typed},
    "IN3" => %{name: "Insurance Additional Information, Certification", tier: :typed},
    "INV" => %{name: "Inventory Detail", tier: :unsupported},
    "IPC" => %{name: "Imaging Procedure Control Segment", tier: :unsupported},
    "ISD" => %{name: "Interaction Status Detail", tier: :unsupported},
    "LAN" => %{name: "Language Detail", tier: :unsupported},
    "LCC" => %{name: "Location Charge Code", tier: :unsupported},
    "LCH" => %{name: "Location Characteristic", tier: :unsupported},
    "LDP" => %{name: "Location Department", tier: :unsupported},
    "LOC" => %{name: "Location Identification", tier: :unsupported},
    "LRL" => %{name: "Location Relationship", tier: :unsupported},
    "MFA" => %{name: "Master File Acknowledgment", tier: :unsupported},
    "MFE" => %{name: "Master File Entry", tier: :unsupported},
    "MFI" => %{name: "Master File Identification", tier: :unsupported},
    "NPU" => %{name: "Bed Status Update", tier: :unsupported},
    "OM1" => %{name: "General Segment", tier: :unsupported},
    "OM2" => %{name: "Numeric Observation", tier: :unsupported},
    "OM3" => %{name: "Categorical Service/Test/Observation", tier: :unsupported},
    "OM4" => %{name: "Observations that Require Specimens", tier: :unsupported},
    "OM5" => %{name: "Observation Batteries (Sets)", tier: :unsupported},
    "OM6" => %{name: "Observations Calculated from Other Observations", tier: :unsupported},
    "OM7" => %{name: "Additional Basic Attributes", tier: :unsupported},
    "ORG" => %{name: "Practitioner Organization Unit", tier: :unsupported},
    "OVR" => %{name: "Override Segment", tier: :unsupported},
    "PCR" => %{name: "Possible Causal Relationship", tier: :unsupported},
    "PDA" => %{name: "Patient Death and Autopsy", tier: :typed},
    "PDC" => %{name: "Product Detail Country", tier: :unsupported},
    "PEO" => %{name: "Product Experience Observation", tier: :unsupported},
    "PES" => %{name: "Product Experience Sender", tier: :unsupported},
    "PRA" => %{name: "Practitioner Detail", tier: :unsupported},
    "PRB" => %{name: "Problem Details", tier: :unsupported},
    "PRD" => %{name: "Provider Data", tier: :unsupported},
    "PSH" => %{name: "Product Summary Header", tier: :unsupported},
    "PTH" => %{name: "Pathway", tier: :unsupported},
    "QAK" => %{name: "Query Acknowledgment", tier: :unsupported},
    "QID" => %{name: "Query Identification", tier: :unsupported},
    "QPD" => %{name: "Query Parameter Definition", tier: :unsupported},
    "QRD" => %{name: "Original-Style Query Definition", tier: :unsupported},
    "QRF" => %{name: "Original Style Query Filter", tier: :unsupported},
    "RCP" => %{name: "Response Control Parameter", tier: :unsupported},
    "RDF" => %{name: "Table Row Definition", tier: :unsupported},
    "RDT" => %{name: "Table Row Data", tier: :unsupported},
    "RF1" => %{name: "Referral Information", tier: :unsupported},
    "ROL" => %{name: "Role", tier: :typed},
    "RQ1" => %{name: "Requisition Detail-1", tier: :unsupported},
    "RQD" => %{name: "Requisition Detail", tier: :unsupported},
    "RXA" => %{name: "Pharmacy/Treatment Administration", tier: :typed},
    "RXC" => %{name: "Pharmacy/Treatment Component Order", tier: :typed},
    "RXD" => %{name: "Pharmacy/Treatment Dispense", tier: :typed},
    "RXE" => %{name: "Pharmacy/Treatment Encoded Order", tier: :typed},
    "RXG" => %{name: "Pharmacy/Treatment Give", tier: :typed},
    "RXO" => %{name: "Pharmacy/Treatment Order", tier: :typed},
    "RXR" => %{name: "Pharmacy/Treatment Route", tier: :typed},
    "SAC" => %{name: "Specimen Container Detail", tier: :unsupported},
    "SCD" => %{name: "Anti-Microbial Cycle Data", tier: :unsupported},
    "SDD" => %{name: "Sterilization Device Data", tier: :unsupported},
    "SID" => %{name: "Substance Identifier", tier: :unsupported},
    "SPM" => %{name: "Specimen", tier: :typed},
    "STF" => %{name: "Staff Identification", tier: :unsupported},
    "TCC" => %{name: "Test Code Configuration", tier: :unsupported},
    "TCD" => %{name: "Test Code Detail", tier: :unsupported},
    "TQ1" => %{name: "Timing/Quantity", tier: :typed},
    "TQ2" => %{name: "Timing/Quantity Relationship", tier: :typed},
    "TXA" => %{name: "Transcription Document Header", tier: :typed},
    "UB1" => %{name: "UB82", tier: :typed},
    "UB2" => %{name: "UB92 Data", tier: :typed},
    "URD" => %{name: "Results/Update Definition", tier: :unsupported},
    "URS" => %{name: "Unsolicited Selection", tier: :unsupported},
    "VAR" => %{name: "Variance", tier: :unsupported}
  }

  # ---------------------------------------------------------------------------
  # Data Type Catalog — HL7 v2.5.1
  # Source: https://www.hl7.eu/HL7v2x/v251/hl7v251typ.htm
  # ---------------------------------------------------------------------------

  @type_catalog %{
    # -- Typed primitives (7 v2.5.1 + 1 legacy) --
    "DT" => %{name: "Date", category: :primitive, tier: :typed},
    "FT" => %{name: "Formatted Text Data", category: :primitive, tier: :typed},
    "ID" => %{name: "Coded Value for HL7 Defined Tables", category: :primitive, tier: :typed},
    "IS" => %{name: "Coded Value for User-Defined Tables", category: :primitive, tier: :typed},
    "NM" => %{name: "Numeric", category: :primitive, tier: :typed},
    "SI" => %{name: "Sequence ID", category: :primitive, tier: :typed},
    "ST" => %{name: "String Data", category: :primitive, tier: :typed},
    "TX" => %{name: "Text Data", category: :primitive, tier: :typed},
    "TN" => %{name: "Telephone Number (deprecated)", category: :primitive, tier: :typed},
    # -- Typed composites (36) --
    "AUI" => %{name: "Authorization Information", category: :composite, tier: :typed},
    "CE" => %{name: "Coded Element", category: :composite, tier: :typed},
    "CNE" => %{name: "Coded with No Exceptions", category: :composite, tier: :typed},
    "CNN" => %{
      name: "Composite Number and Name without Authority",
      category: :composite,
      tier: :typed
    },
    "CP" => %{name: "Composite Price", category: :composite, tier: :typed},
    "CQ" => %{name: "Composite Quantity with Units", category: :composite, tier: :typed},
    "CWE" => %{name: "Coded with Exceptions", category: :composite, tier: :typed},
    "CX" => %{name: "Extended Composite ID with Check Digit", category: :composite, tier: :typed},
    "DLD" => %{name: "Discharge to Location and Date", category: :composite, tier: :typed},
    "DLN" => %{name: "Driver's License Number", category: :composite, tier: :typed},
    "DR" => %{name: "Date/Time Range", category: :composite, tier: :typed},
    "DTM" => %{name: "Date/Time", category: :composite, tier: :typed},
    "EI" => %{name: "Entity Identifier", category: :composite, tier: :typed},
    "EIP" => %{name: "Entity Identifier Pair", category: :composite, tier: :typed},
    "ERL" => %{name: "Error Location", category: :composite, tier: :typed},
    "FC" => %{name: "Financial Class", category: :composite, tier: :typed},
    "FN" => %{name: "Family Name", category: :composite, tier: :typed},
    "HD" => %{name: "Hierarchic Designator", category: :composite, tier: :typed},
    "JCC" => %{name: "Job Code/Class", category: :composite, tier: :typed},
    "MO" => %{name: "Money", category: :composite, tier: :typed},
    "MOC" => %{name: "Money and Charge Code", category: :composite, tier: :typed},
    "MSG" => %{name: "Message Type", category: :composite, tier: :typed},
    "NDL" => %{name: "Name with Date and Location", category: :composite, tier: :typed},
    "NR" => %{name: "Numeric Range", category: :composite, tier: :typed},
    "PL" => %{name: "Person Location", category: :composite, tier: :typed},
    "PRL" => %{name: "Parent Result Link", category: :composite, tier: :typed},
    "PT" => %{name: "Processing Type", category: :composite, tier: :typed},
    "SAD" => %{name: "Street Address", category: :composite, tier: :typed},
    "TS" => %{name: "Time Stamp", category: :composite, tier: :typed},
    "VID" => %{name: "Version Identifier", category: :composite, tier: :typed},
    "XAD" => %{name: "Extended Address", category: :composite, tier: :typed},
    "XCN" => %{
      name: "Extended Composite ID Number and Name for Persons",
      category: :composite,
      tier: :typed
    },
    "XON" => %{
      name: "Extended Composite Name and ID Number for Organizations",
      category: :composite,
      tier: :typed
    },
    "XPN" => %{name: "Extended Person Name", category: :composite, tier: :typed},
    "XTN" => %{name: "Extended Telecommunication Number", category: :composite, tier: :typed},
    # -- Unsupported v2.5.1 types --
    "AD" => %{name: "Address", category: :composite, tier: :unsupported},
    "CF" => %{
      name: "Coded Element with Formatted Values",
      category: :composite,
      tier: :unsupported
    },
    "CCD" => %{name: "Charge Code and Date", category: :composite, tier: :unsupported},
    "CD" => %{name: "Channel Definition", category: :composite, tier: :unsupported},
    "CSU" => %{name: "Channel Sensitivity and Units", category: :composite, tier: :unsupported},
    "DDI" => %{name: "Daily Deductible Information", category: :composite, tier: :unsupported},
    "DIN" => %{name: "Date and Institution Name", category: :composite, tier: :unsupported},
    "DLT" => %{name: "Delta", category: :composite, tier: :unsupported},
    "DTN" => %{name: "Day Type and Number", category: :composite, tier: :unsupported},
    "ED" => %{name: "Encapsulated Data", category: :composite, tier: :typed},
    "ELD" => %{name: "Error Location and Description", category: :composite, tier: :typed},
    "GTS" => %{name: "General Timing Specification", category: :primitive, tier: :unsupported},
    "ICD" => %{
      name: "Insurance Certification Definition",
      category: :composite,
      tier: :unsupported
    },
    "LA1" => %{
      name: "Location with Address Variation 1",
      category: :composite,
      tier: :unsupported
    },
    "LA2" => %{
      name: "Location with Address Variation 2",
      category: :composite,
      tier: :unsupported
    },
    "MA" => %{name: "Multiplexed Array", category: :composite, tier: :unsupported},
    "MOP" => %{name: "Money or Percentage", category: :composite, tier: :unsupported},
    "NA" => %{name: "Numeric Array", category: :composite, tier: :unsupported},
    "OCD" => %{name: "Occurrence Code and Date", category: :composite, tier: :unsupported},
    "OSD" => %{name: "Order Sequence Definition", category: :composite, tier: :unsupported},
    "OSP" => %{name: "Occurrence Span Code and Date", category: :composite, tier: :unsupported},
    "PIP" => %{
      name: "Practitioner Institutional Privileges",
      category: :composite,
      tier: :unsupported
    },
    "PLN" => %{
      name: "Practitioner License or Other ID Number",
      category: :composite,
      tier: :typed
    },
    "PPN" => %{name: "Performing Person Time Stamp", category: :composite, tier: :unsupported},
    "PTA" => %{name: "Policy Type and Amount", category: :composite, tier: :unsupported},
    "QIP" => %{name: "Query Input Parameter List", category: :composite, tier: :unsupported},
    "QSC" => %{name: "Query Selection Criteria", category: :composite, tier: :unsupported},
    "RCD" => %{name: "Row Column Definition", category: :composite, tier: :unsupported},
    "RFR" => %{name: "Reference Range", category: :composite, tier: :unsupported},
    "RI" => %{name: "Repeat Interval", category: :composite, tier: :typed},
    "RMC" => %{name: "Room Coverage", category: :composite, tier: :unsupported},
    "RP" => %{name: "Reference Pointer", category: :composite, tier: :typed},
    "RPT" => %{name: "Repeat Pattern", category: :composite, tier: :typed},
    "SCV" => %{name: "Scheduling Class Value Pair", category: :composite, tier: :unsupported},
    "SN" => %{name: "Structured Numeric", category: :composite, tier: :typed},
    "SPD" => %{name: "Specialty Description", category: :composite, tier: :unsupported},
    "SPS" => %{name: "Specimen Source", category: :composite, tier: :typed},
    "SRT" => %{name: "Sort Order", category: :composite, tier: :unsupported},
    "TM" => %{name: "Time", category: :primitive, tier: :typed},
    "TQ" => %{name: "Timing/Quantity", category: :composite, tier: :typed},
    "UVC" => %{name: "UB Value Code and Amount", category: :composite, tier: :unsupported},
    "VH" => %{name: "Visiting Hours", category: :composite, tier: :unsupported},
    "VR" => %{name: "Value Range", category: :composite, tier: :unsupported},
    "WVI" => %{name: "Channel Identifier", category: :composite, tier: :unsupported},
    "WVS" => %{name: "Waveform Source", category: :composite, tier: :unsupported}
  }

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc "Returns segment metadata by ID, or nil."
  @spec segment(binary()) :: map() | nil
  def segment(id), do: Map.get(@segment_catalog, id)

  @doc "Returns the capability tier for a segment (`:typed`, `:raw`, or `:unsupported`)."
  @spec segment_tier(binary()) :: :typed | :raw | :unsupported
  def segment_tier(id) do
    case Map.get(@segment_catalog, id) do
      %{tier: tier} -> tier
      nil -> :unsupported
    end
  end

  @doc "Returns the segment module for a typed segment, or nil."
  @spec segment_module(binary()) :: module() | nil
  def segment_module(id), do: Map.get(@typed_segment_modules, id)

  @doc "Returns all segment IDs in the catalog."
  @spec segment_ids() :: [binary()]
  def segment_ids, do: Map.keys(@segment_catalog) |> Enum.sort()

  @doc "Returns all typed segment IDs."
  @spec typed_segment_ids() :: [binary()]
  def typed_segment_ids, do: Map.keys(@typed_segment_modules) |> Enum.sort()

  @doc "Returns type metadata by code, or nil."
  @spec type(binary()) :: map() | nil
  def type(code), do: Map.get(@type_catalog, code)

  @doc "Returns the capability tier for a data type."
  @spec type_tier(binary()) :: :typed | :unsupported
  def type_tier(code) do
    case Map.get(@type_catalog, code) do
      %{tier: tier} -> tier
      nil -> :unsupported
    end
  end

  @doc "Returns all type codes in the catalog."
  @spec type_codes() :: [binary()]
  def type_codes, do: Map.keys(@type_catalog) |> Enum.sort()

  @doc "Returns all typed type codes."
  @spec typed_type_codes() :: [binary()]
  def typed_type_codes do
    @type_catalog
    |> Enum.filter(fn {_, v} -> v.tier == :typed end)
    |> Enum.map(fn {k, _} -> k end)
    |> Enum.sort()
  end

  @doc "Returns the total count of standard segments in the catalog."
  @spec segment_count() :: non_neg_integer()
  def segment_count, do: map_size(@segment_catalog)

  @doc "Returns the total count of standard data types in the catalog."
  @spec type_count() :: non_neg_integer()
  def type_count, do: map_size(@type_catalog)
end
