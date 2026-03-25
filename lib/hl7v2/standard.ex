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
    "ABS" => HL7v2.Segment.ABS,
    "ACC" => HL7v2.Segment.ACC,
    "ADD" => HL7v2.Segment.ADD,
    "AFF" => HL7v2.Segment.AFF,
    "AIG" => HL7v2.Segment.AIG,
    "AIL" => HL7v2.Segment.AIL,
    "AIP" => HL7v2.Segment.AIP,
    "AIS" => HL7v2.Segment.AIS,
    "AL1" => HL7v2.Segment.AL1,
    "APR" => HL7v2.Segment.APR,
    "ARQ" => HL7v2.Segment.ARQ,
    "AUT" => HL7v2.Segment.AUT,
    "BHS" => HL7v2.Segment.BHS,
    "BLC" => HL7v2.Segment.BLC,
    "BLG" => HL7v2.Segment.BLG,
    "BPO" => HL7v2.Segment.BPO,
    "BPX" => HL7v2.Segment.BPX,
    "BTS" => HL7v2.Segment.BTS,
    "BTX" => HL7v2.Segment.BTX,
    "CDM" => HL7v2.Segment.CDM,
    "CER" => HL7v2.Segment.CER,
    "CM0" => HL7v2.Segment.CM0,
    "CM1" => HL7v2.Segment.CM1,
    "CM2" => HL7v2.Segment.CM2,
    "CNS" => HL7v2.Segment.CNS,
    "CON" => HL7v2.Segment.CON,
    "CSP" => HL7v2.Segment.CSP,
    "CSR" => HL7v2.Segment.CSR,
    "CSS" => HL7v2.Segment.CSS,
    "CTD" => HL7v2.Segment.CTD,
    "CTI" => HL7v2.Segment.CTI,
    "DB1" => HL7v2.Segment.DB1,
    "DG1" => HL7v2.Segment.DG1,
    "DRG" => HL7v2.Segment.DRG,
    "DSC" => HL7v2.Segment.DSC,
    "DSP" => HL7v2.Segment.DSP,
    "ECD" => HL7v2.Segment.ECD,
    "ECR" => HL7v2.Segment.ECR,
    "EDU" => HL7v2.Segment.EDU,
    "EQL" => HL7v2.Segment.EQL,
    "EQP" => HL7v2.Segment.EQP,
    "EQU" => HL7v2.Segment.EQU,
    "ERQ" => HL7v2.Segment.ERQ,
    "ERR" => HL7v2.Segment.ERR,
    "EVN" => HL7v2.Segment.EVN,
    "FAC" => HL7v2.Segment.FAC,
    "FHS" => HL7v2.Segment.FHS,
    "FT1" => HL7v2.Segment.FT1,
    "FTS" => HL7v2.Segment.FTS,
    "GOL" => HL7v2.Segment.GOL,
    "GP1" => HL7v2.Segment.GP1,
    "GP2" => HL7v2.Segment.GP2,
    "GT1" => HL7v2.Segment.GT1,
    "IAM" => HL7v2.Segment.IAM,
    "IIM" => HL7v2.Segment.IIM,
    "IN1" => HL7v2.Segment.IN1,
    "IN2" => HL7v2.Segment.IN2,
    "IN3" => HL7v2.Segment.IN3,
    "INV" => HL7v2.Segment.INV,
    "IPC" => HL7v2.Segment.IPC,
    "ISD" => HL7v2.Segment.ISD,
    "LAN" => HL7v2.Segment.LAN,
    "LCC" => HL7v2.Segment.LCC,
    "LCH" => HL7v2.Segment.LCH,
    "LDP" => HL7v2.Segment.LDP,
    "LOC" => HL7v2.Segment.LOC,
    "LRL" => HL7v2.Segment.LRL,
    "MFA" => HL7v2.Segment.MFA,
    "MFE" => HL7v2.Segment.MFE,
    "MFI" => HL7v2.Segment.MFI,
    "MRG" => HL7v2.Segment.MRG,
    "MSA" => HL7v2.Segment.MSA,
    # N-segments
    "NCK" => HL7v2.Segment.NCK,
    "NDS" => HL7v2.Segment.NDS,
    "NSC" => HL7v2.Segment.NSC,
    "NST" => HL7v2.Segment.NST,
    "MSH" => HL7v2.Segment.MSH,
    "NK1" => HL7v2.Segment.NK1,
    "NPU" => HL7v2.Segment.NPU,
    "NTE" => HL7v2.Segment.NTE,
    "OBR" => HL7v2.Segment.OBR,
    "OBX" => HL7v2.Segment.OBX,
    "ODS" => HL7v2.Segment.ODS,
    "ODT" => HL7v2.Segment.ODT,
    "ORC" => HL7v2.Segment.ORC,
    "OM1" => HL7v2.Segment.OM1,
    "OM2" => HL7v2.Segment.OM2,
    "OM3" => HL7v2.Segment.OM3,
    "OM4" => HL7v2.Segment.OM4,
    "OM5" => HL7v2.Segment.OM5,
    "OM6" => HL7v2.Segment.OM6,
    "OM7" => HL7v2.Segment.OM7,
    "ORG" => HL7v2.Segment.ORG,
    "OVR" => HL7v2.Segment.OVR,
    "PCR" => HL7v2.Segment.PCR,
    "PD1" => HL7v2.Segment.PD1,
    "PDA" => HL7v2.Segment.PDA,
    "PDC" => HL7v2.Segment.PDC,
    "PEO" => HL7v2.Segment.PEO,
    "PES" => HL7v2.Segment.PES,
    "PID" => HL7v2.Segment.PID,
    "PR1" => HL7v2.Segment.PR1,
    "PRA" => HL7v2.Segment.PRA,
    "PRB" => HL7v2.Segment.PRB,
    "PRC" => HL7v2.Segment.PRC,
    "PRD" => HL7v2.Segment.PRD,
    "PSH" => HL7v2.Segment.PSH,
    "PTH" => HL7v2.Segment.PTH,
    "PV1" => HL7v2.Segment.PV1,
    "PV2" => HL7v2.Segment.PV2,
    "QAK" => HL7v2.Segment.QAK,
    "QID" => HL7v2.Segment.QID,
    "QPD" => HL7v2.Segment.QPD,
    "QRI" => HL7v2.Segment.QRI,
    "QRD" => HL7v2.Segment.QRD,
    "QRF" => HL7v2.Segment.QRF,
    "RCP" => HL7v2.Segment.RCP,
    "RDF" => HL7v2.Segment.RDF,
    "RDT" => HL7v2.Segment.RDT,
    "RF1" => HL7v2.Segment.RF1,
    "RGS" => HL7v2.Segment.RGS,
    "RMI" => HL7v2.Segment.RMI,
    "ROL" => HL7v2.Segment.ROL,
    "RQ1" => HL7v2.Segment.RQ1,
    "RQD" => HL7v2.Segment.RQD,
    "RXA" => HL7v2.Segment.RXA,
    "RXC" => HL7v2.Segment.RXC,
    "RXD" => HL7v2.Segment.RXD,
    "RXE" => HL7v2.Segment.RXE,
    "RXG" => HL7v2.Segment.RXG,
    "RXO" => HL7v2.Segment.RXO,
    "RXR" => HL7v2.Segment.RXR,
    "SAC" => HL7v2.Segment.SAC,
    "SCD" => HL7v2.Segment.SCD,
    "SCH" => HL7v2.Segment.SCH,
    "SDD" => HL7v2.Segment.SDD,
    "SFT" => HL7v2.Segment.SFT,
    "SID" => HL7v2.Segment.SID,
    "SPM" => HL7v2.Segment.SPM,
    "SPR" => HL7v2.Segment.SPR,
    "STF" => HL7v2.Segment.STF,
    "TCC" => HL7v2.Segment.TCC,
    "TCD" => HL7v2.Segment.TCD,
    "TQ1" => HL7v2.Segment.TQ1,
    "TQ2" => HL7v2.Segment.TQ2,
    "TXA" => HL7v2.Segment.TXA,
    "UB1" => HL7v2.Segment.UB1,
    "UB2" => HL7v2.Segment.UB2,
    "URD" => HL7v2.Segment.URD,
    "URS" => HL7v2.Segment.URS,
    "VAR" => HL7v2.Segment.VAR,
    "VTQ" => HL7v2.Segment.VTQ
  }

  @segment_catalog %{
    # -- Typed segments (see @typed_segment_modules for authoritative count) --
    "ABS" => %{name: "Abstract", tier: :typed},
    "ACC" => %{name: "Accident", tier: :typed},
    "AFF" => %{name: "Professional Affiliation", tier: :typed},
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
    "ADD" => %{name: "Addendum", tier: :typed},
    "APR" => %{name: "Appointment Preferences", tier: :typed},
    "ARQ" => %{name: "Appointment Request", tier: :typed},
    "AUT" => %{name: "Authorization Information", tier: :typed},
    "BHS" => %{name: "Batch Header", tier: :typed},
    "BLC" => %{name: "Blood Code", tier: :typed},
    "BLG" => %{name: "Billing", tier: :typed},
    "BPO" => %{name: "Blood Product Order", tier: :typed},
    "BPX" => %{name: "Blood Product Dispense Status", tier: :typed},
    "BTS" => %{name: "Batch Trailer", tier: :typed},
    "BTX" => %{name: "Blood Product Transfusion/Disposition", tier: :typed},
    "CDM" => %{name: "Charge Description Master", tier: :typed},
    "CER" => %{name: "Certificate Detail", tier: :typed},
    "CM0" => %{name: "Clinical Study Master", tier: :typed},
    "CM1" => %{name: "Clinical Study Phase Master", tier: :typed},
    "CM2" => %{name: "Clinical Study Schedule Master", tier: :typed},
    "CNS" => %{name: "Clear Notification", tier: :typed},
    "CON" => %{name: "Consent Segment", tier: :typed},
    "CSP" => %{name: "Clinical Study Phase", tier: :typed},
    "CSR" => %{name: "Clinical Study Registration", tier: :typed},
    "CSS" => %{name: "Clinical Study Data Schedule Segment", tier: :typed},
    "CTD" => %{name: "Contact Data", tier: :typed},
    "CTI" => %{name: "Clinical Trial Identification", tier: :typed},
    "DRG" => %{name: "Diagnosis Related Group", tier: :typed},
    "DSC" => %{name: "Continuation Pointer", tier: :typed},
    "DSP" => %{name: "Display Data", tier: :typed},
    "ECD" => %{name: "Equipment Command", tier: :typed},
    "ECR" => %{name: "Equipment Command Response", tier: :typed},
    "EDU" => %{name: "Educational Detail", tier: :typed},
    "EQL" => %{name: "Embedded Query Language", tier: :typed},
    "EQP" => %{name: "Equipment/log Service", tier: :typed},
    "EQU" => %{name: "Equipment Detail", tier: :typed},
    "ERQ" => %{name: "Event Replay Query", tier: :typed},
    "FAC" => %{name: "Facility", tier: :typed},
    "FHS" => %{name: "File Header", tier: :typed},
    "FTS" => %{name: "File Trailer", tier: :typed},
    "GOL" => %{name: "Goal Detail", tier: :typed},
    "GP1" => %{name: "Grouping/Reimbursement — Visit", tier: :typed},
    "GP2" => %{name: "Grouping/Reimbursement — Procedure Line Item", tier: :typed},
    "IAM" => %{name: "Patient Adverse Reaction Information", tier: :typed},
    "IIM" => %{name: "Inventory Item Master", tier: :typed},
    "IN2" => %{name: "Insurance Additional Information", tier: :typed},
    "IN3" => %{name: "Insurance Additional Information, Certification", tier: :typed},
    "INV" => %{name: "Inventory Detail", tier: :typed},
    "IPC" => %{name: "Imaging Procedure Control Segment", tier: :typed},
    "ISD" => %{name: "Interaction Status Detail", tier: :typed},
    "LAN" => %{name: "Language Detail", tier: :typed},
    "LCC" => %{name: "Location Charge Code", tier: :typed},
    "LCH" => %{name: "Location Characteristic", tier: :typed},
    "LDP" => %{name: "Location Department", tier: :typed},
    "LOC" => %{name: "Location Identification", tier: :typed},
    "LRL" => %{name: "Location Relationship", tier: :typed},
    "MFA" => %{name: "Master File Acknowledgment", tier: :typed},
    "MFE" => %{name: "Master File Entry", tier: :typed},
    "MFI" => %{name: "Master File Identification", tier: :typed},
    "NCK" => %{name: "System Clock", tier: :typed},
    "NDS" => %{name: "Notification Detail", tier: :typed},
    "NPU" => %{name: "Bed Status Update", tier: :typed},
    "NSC" => %{name: "Application Status Change", tier: :typed},
    "NST" => %{name: "Application Control Level Statistics", tier: :typed},
    "OM1" => %{name: "General Segment", tier: :typed},
    "OM2" => %{name: "Numeric Observation", tier: :typed},
    "OM3" => %{name: "Categorical Service/Test/Observation", tier: :typed},
    "OM4" => %{name: "Observations that Require Specimens", tier: :typed},
    "OM5" => %{name: "Observation Batteries (Sets)", tier: :typed},
    "OM6" => %{name: "Observations Calculated from Other Observations", tier: :typed},
    "OM7" => %{name: "Additional Basic Attributes", tier: :typed},
    "ODS" => %{name: "Dietary Orders, Supplements, and Preferences", tier: :typed},
    "ODT" => %{name: "Diet Tray Instructions", tier: :typed},
    "ORG" => %{name: "Practitioner Organization Unit", tier: :typed},
    "OVR" => %{name: "Override Segment", tier: :typed},
    "PCR" => %{name: "Possible Causal Relationship", tier: :typed},
    "PDA" => %{name: "Patient Death and Autopsy", tier: :typed},
    "PDC" => %{name: "Product Detail Country", tier: :typed},
    "PEO" => %{name: "Product Experience Observation", tier: :typed},
    "PES" => %{name: "Product Experience Sender", tier: :typed},
    "PRA" => %{name: "Practitioner Detail", tier: :typed},
    "PRB" => %{name: "Problem Details", tier: :typed},
    "PRC" => %{name: "Pricing", tier: :typed},
    "PRD" => %{name: "Provider Data", tier: :typed},
    "PSH" => %{name: "Product Summary Header", tier: :typed},
    "PTH" => %{name: "Pathway", tier: :typed},
    "QAK" => %{name: "Query Acknowledgment", tier: :typed},
    "QID" => %{name: "Query Identification", tier: :typed},
    "QPD" => %{name: "Query Parameter Definition", tier: :typed},
    "QRI" => %{name: "Query Response Instance", tier: :typed},
    "QRD" => %{name: "Original-Style Query Definition", tier: :typed},
    "QRF" => %{name: "Original Style Query Filter", tier: :typed},
    "RCP" => %{name: "Response Control Parameter", tier: :typed},
    "RDF" => %{name: "Table Row Definition", tier: :typed},
    "RDT" => %{name: "Table Row Data", tier: :typed},
    "RF1" => %{name: "Referral Information", tier: :typed},
    "RMI" => %{name: "Risk Management Incident", tier: :typed},
    "ROL" => %{name: "Role", tier: :typed},
    "RQ1" => %{name: "Requisition Detail-1", tier: :typed},
    "RQD" => %{name: "Requisition Detail", tier: :typed},
    "RXA" => %{name: "Pharmacy/Treatment Administration", tier: :typed},
    "RXC" => %{name: "Pharmacy/Treatment Component Order", tier: :typed},
    "RXD" => %{name: "Pharmacy/Treatment Dispense", tier: :typed},
    "RXE" => %{name: "Pharmacy/Treatment Encoded Order", tier: :typed},
    "RXG" => %{name: "Pharmacy/Treatment Give", tier: :typed},
    "RXO" => %{name: "Pharmacy/Treatment Order", tier: :typed},
    "RXR" => %{name: "Pharmacy/Treatment Route", tier: :typed},
    "SAC" => %{name: "Specimen Container Detail", tier: :typed},
    "SCD" => %{name: "Anti-Microbial Cycle Data (v2.6)", tier: :typed},
    "SDD" => %{name: "Sterilization Device Data (v2.6)", tier: :typed},
    "SID" => %{name: "Substance Identifier", tier: :typed},
    "SPM" => %{name: "Specimen", tier: :typed},
    "SPR" => %{name: "Stored Procedure Request Definition", tier: :typed},
    "STF" => %{name: "Staff Identification", tier: :typed},
    "TCC" => %{name: "Test Code Configuration", tier: :typed},
    "TCD" => %{name: "Test Code Detail", tier: :typed},
    "TQ1" => %{name: "Timing/Quantity", tier: :typed},
    "TQ2" => %{name: "Timing/Quantity Relationship", tier: :typed},
    "TXA" => %{name: "Transcription Document Header", tier: :typed},
    "UB1" => %{name: "UB82", tier: :typed},
    "UB2" => %{name: "UB92 Data", tier: :typed},
    "URD" => %{name: "Results/Update Definition", tier: :typed},
    "URS" => %{name: "Unsolicited Selection", tier: :typed},
    "VAR" => %{name: "Variance", tier: :typed},
    "VTQ" => %{name: "Virtual Table Query Request", tier: :typed}
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
    # -- Remaining v2.5.1 types (all typed) --
    "AD" => %{name: "Address", category: :composite, tier: :typed},
    "CCD" => %{name: "Charge Code and Date", category: :composite, tier: :typed},
    "CD" => %{name: "Channel Definition", category: :composite, tier: :typed},
    "CF" => %{name: "Coded Element with Formatted Values", category: :composite, tier: :typed},
    "CSU" => %{name: "Channel Sensitivity and Units", category: :composite, tier: :typed},
    "DDI" => %{name: "Daily Deductible Information", category: :composite, tier: :typed},
    "DIN" => %{name: "Date and Institution Name", category: :composite, tier: :typed},
    "DLT" => %{name: "Delta", category: :composite, tier: :typed},
    "DTN" => %{name: "Day Type and Number", category: :composite, tier: :typed},
    "ED" => %{name: "Encapsulated Data", category: :composite, tier: :typed},
    "ELD" => %{name: "Error Location and Description", category: :composite, tier: :typed},
    "GTS" => %{name: "General Timing Specification", category: :primitive, tier: :typed},
    "ICD" => %{name: "Insurance Certification Definition", category: :composite, tier: :typed},
    "LA1" => %{name: "Location with Address Variation 1", category: :composite, tier: :typed},
    "LA2" => %{name: "Location with Address Variation 2", category: :composite, tier: :typed},
    "MA" => %{name: "Multiplexed Array", category: :composite, tier: :typed},
    "MOP" => %{name: "Money or Percentage", category: :composite, tier: :typed},
    "NA" => %{name: "Numeric Array", category: :composite, tier: :typed},
    "OCD" => %{name: "Occurrence Code and Date", category: :composite, tier: :typed},
    "OSD" => %{name: "Order Sequence Definition", category: :composite, tier: :typed},
    "OSP" => %{name: "Occurrence Span Code and Date", category: :composite, tier: :typed},
    "PIP" => %{name: "Practitioner Institutional Privileges", category: :composite, tier: :typed},
    "PLN" => %{
      name: "Practitioner License or Other ID Number",
      category: :composite,
      tier: :typed
    },
    "PPN" => %{name: "Performing Person Time Stamp", category: :composite, tier: :typed},
    "PTA" => %{name: "Policy Type and Amount", category: :composite, tier: :typed},
    "QIP" => %{name: "Query Input Parameter List", category: :composite, tier: :typed},
    "QSC" => %{name: "Query Selection Criteria", category: :composite, tier: :typed},
    "RCD" => %{name: "Row Column Definition", category: :composite, tier: :typed},
    "RFR" => %{name: "Reference Range", category: :composite, tier: :typed},
    "RI" => %{name: "Repeat Interval", category: :composite, tier: :typed},
    "RMC" => %{name: "Room Coverage", category: :composite, tier: :typed},
    "RP" => %{name: "Reference Pointer", category: :composite, tier: :typed},
    "RPT" => %{name: "Repeat Pattern", category: :composite, tier: :typed},
    "SCV" => %{name: "Scheduling Class Value Pair", category: :composite, tier: :typed},
    "SN" => %{name: "Structured Numeric", category: :composite, tier: :typed},
    "SPD" => %{name: "Specialty Description", category: :composite, tier: :typed},
    "SPS" => %{name: "Specimen Source", category: :composite, tier: :typed},
    "SRT" => %{name: "Sort Order", category: :composite, tier: :typed},
    "TM" => %{name: "Time", category: :primitive, tier: :typed},
    "TQ" => %{name: "Timing/Quantity", category: :composite, tier: :typed},
    "UVC" => %{name: "UB Value Code and Amount", category: :composite, tier: :typed},
    "VH" => %{name: "Visiting Hours", category: :composite, tier: :typed},
    "VR" => %{name: "Value Range", category: :composite, tier: :typed},
    "WVI" => %{name: "Channel Identifier", category: :composite, tier: :typed},
    "WVS" => %{name: "Waveform Source", category: :composite, tier: :typed}
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
