defmodule HL7v2.Standard.Tables do
  @moduledoc """
  HL7 v2.5.1 coded-value tables.

  Provides lookup and validation for the most commonly used HL7-defined tables
  referenced by typed segments in this library. Each table is a map of
  `code => description` drawn from the HL7 v2.5.1 specification.

  Table validation is opt-in. Call `HL7v2.validate(msg, validate_tables: true)`
  to enable coded-value checking during message validation.

  ## Examples

      iex> HL7v2.Standard.Tables.valid?(1, "F")
      true

      iex> HL7v2.Standard.Tables.valid?(1, "ZZ")
      false

      iex> HL7v2.Standard.Tables.validate(8, "AA")
      :ok

      iex> HL7v2.Standard.Tables.validate(8, "XX")
      {:error, "invalid code \\"XX\\" for table 0008 (Acknowledgment Code)"}

  """

  # ---------------------------------------------------------------------------
  # Table definitions — HL7 v2.5.1
  # ---------------------------------------------------------------------------

  @tables %{
    1 => %{
      name: "Administrative Sex",
      codes: %{
        "A" => "Ambiguous",
        "F" => "Female",
        "M" => "Male",
        "N" => "Not Applicable",
        "O" => "Other",
        "U" => "Unknown"
      }
    },
    2 => %{
      name: "Marital Status",
      codes: %{
        "A" => "Separated",
        "B" => "Unmarried",
        "C" => "Common Law",
        "D" => "Divorced",
        "E" => "Legally Separated",
        "G" => "Living Together",
        "I" => "Interlocutory",
        "M" => "Married",
        "N" => "Annulled",
        "O" => "Other",
        "P" => "Domestic Partner",
        "R" => "Registered Domestic Partner",
        "S" => "Single",
        "T" => "Unreported",
        "U" => "Unknown",
        "W" => "Widowed"
      }
    },
    3 => %{
      name: "Event Type",
      codes:
        Map.new(
          [
            {"A01", "Admit/Visit Notification"},
            {"A02", "Transfer a Patient"},
            {"A03", "Discharge/End Visit"},
            {"A04", "Register a Patient"},
            {"A05", "Pre-Admit a Patient"},
            {"A06", "Change an Outpatient to an Inpatient"},
            {"A07", "Change an Inpatient to an Outpatient"},
            {"A08", "Update Patient Information"},
            {"A09", "Patient Departing - Tracking"},
            {"A10", "Patient Arriving - Tracking"},
            {"A11", "Cancel Admit/Visit Notification"},
            {"A12", "Cancel Transfer"},
            {"A13", "Cancel Discharge/End Visit"},
            {"A14", "Pending Admit"},
            {"A15", "Pending Transfer"},
            {"A16", "Pending Discharge"},
            {"A17", "Swap Patients"},
            {"A18", "Merge Patient Information"},
            {"A19", "Patient Query"},
            {"A20", "Bed Status Update"},
            {"A21", "Patient Goes on a Leave of Absence"},
            {"A22", "Patient Returns from a Leave of Absence"},
            {"A23", "Delete a Patient Record"},
            {"A24", "Link Patient Information"},
            {"A25", "Cancel Pending Discharge"},
            {"A26", "Cancel Pending Transfer"},
            {"A27", "Cancel Pending Admit"},
            {"A28", "Add Person Information"},
            {"A29", "Delete Person Information"},
            {"A30", "Merge Person Information"},
            {"A31", "Update Person Information"},
            {"A32", "Cancel Patient Arriving - Tracking"},
            {"A33", "Cancel Patient Departing - Tracking"},
            {"A34", "Merge Patient Information - Patient ID Only"},
            {"A35", "Merge Patient Information - Account Number Only"},
            {"A36", "Merge Patient Information - Patient ID & Account Number"},
            {"A37", "Unlink Patient Information"},
            {"A38", "Cancel Pre-Admit"},
            {"A39", "Merge Person - Patient ID"},
            {"A40", "Merge Patient - Patient Identifier List"},
            {"A41", "Merge Account - Patient Account Number"},
            {"A42", "Merge Visit - Visit Number"},
            {"A43", "Move Patient Information - Patient Identifier List"},
            {"A44", "Move Account Information - Patient Account Number"},
            {"A45", "Move Visit Information - Visit Number"},
            {"A46", "Change Patient ID"},
            {"A47", "Change Patient Identifier List"},
            {"A48", "Change Alternate Patient ID"},
            {"A49", "Change Patient Account Number"},
            {"A50", "Change Visit Number"},
            {"A51", "Change Alternate Visit ID"},
            {"A52", "Cancel Leave of Absence for a Patient"},
            {"A53", "Cancel Patient Returns from a Leave of Absence"},
            {"A54", "Change Attending Doctor"},
            {"A55", "Cancel Change Attending Doctor"},
            {"A60", "Update Allergy Information"},
            {"A61", "Change Consulting Doctor"},
            {"A62", "Cancel Change Consulting Doctor"},
            {"O01", "Order Message"},
            {"O02", "Order Response"},
            {"R01", "Unsolicited Observation Message"},
            {"S12", "Notification of New Appointment Booking"},
            {"S13", "Notification of Appointment Rescheduling"},
            {"S14", "Notification of Appointment Modification"},
            {"S15", "Notification of Appointment Cancellation"},
            {"S16", "Notification of Appointment Discontinuation"},
            {"S17", "Notification of Appointment Deletion"},
            {"S26", "Notification that Patient Did Not Show Up"}
          ],
          fn {k, v} -> {k, v} end
        )
    },
    4 => %{
      name: "Patient Class",
      codes: %{
        "B" => "Obstetrics",
        "C" => "Commercial Account",
        "E" => "Emergency",
        "I" => "Inpatient",
        "N" => "Not Applicable",
        "O" => "Outpatient",
        "P" => "Preadmit",
        "R" => "Recurring Patient",
        "U" => "Unknown"
      }
    },
    7 => %{
      name: "Admission Type",
      codes: %{
        "A" => "Accident",
        "C" => "Elective",
        "E" => "Emergency",
        "L" => "Labor and Delivery",
        "N" => "Newborn",
        "R" => "Routine",
        "U" => "Urgent"
      }
    },
    8 => %{
      name: "Acknowledgment Code",
      codes: %{
        "AA" => "Original mode: Application Accept",
        "AE" => "Original mode: Application Error",
        "AR" => "Original mode: Application Reject",
        "CA" => "Enhanced mode: Accept Acknowledgment Commit Accept",
        "CE" => "Enhanced mode: Accept Acknowledgment Commit Error",
        "CR" => "Enhanced mode: Accept Acknowledgment Commit Reject"
      }
    },
    52 => %{
      name: "Diagnosis Type",
      codes: %{
        "A" => "Admitting",
        "F" => "Final",
        "W" => "Working"
      }
    },
    63 => %{
      name: "Relationship",
      codes: %{
        "ASC" => "Associate",
        "BRO" => "Brother",
        "CGV" => "Care Giver",
        "CHD" => "Child",
        "DEP" => "Handicapped Dependent",
        "DOM" => "Life Partner",
        "EMC" => "Emergency Contact",
        "EME" => "Employee",
        "EMR" => "Employer",
        "EXF" => "Extended Family",
        "FCH" => "Foster Child",
        "FND" => "Friend",
        "FTH" => "Father",
        "GCH" => "Grandchild",
        "GRD" => "Guardian",
        "GRP" => "Grandparent",
        "MGR" => "Manager",
        "MTH" => "Mother",
        "NCH" => "Natural Child",
        "NON" => "None",
        "OAD" => "Other Adult",
        "OTH" => "Other",
        "OWN" => "Owner",
        "PAR" => "Parent",
        "SCH" => "Stepchild",
        "SEL" => "Self",
        "SIB" => "Sibling",
        "SIS" => "Sister",
        "SPO" => "Spouse",
        "TRA" => "Trainer",
        "UNK" => "Unknown",
        "WRD" => "Ward of Court"
      }
    },
    74 => %{
      name: "Diagnostic Service Section ID",
      codes: %{
        "AU" => "Audiology",
        "BG" => "Blood Gases",
        "BLB" => "Blood Bank",
        "CH" => "Chemistry",
        "CP" => "Cytopathology",
        "CT" => "CAT Scan",
        "CTH" => "Cardiac Catheterization",
        "CUS" => "Cardiac Ultrasound",
        "EC" => "Electrocardiac (e.g., EKG, EEC, Holter)",
        "EN" => "Electroneuro (EEG, EMG, EP, PSG)",
        "HM" => "Hematology",
        "ICU" => "Bedside ICU Monitoring",
        "IMM" => "Immunology",
        "LAB" => "Laboratory",
        "MB" => "Microbiology",
        "MCB" => "Mycobacteriology",
        "MYC" => "Mycology",
        "NMR" => "Nuclear Magnetic Resonance",
        "NMS" => "Nuclear Medicine Scan",
        "NRS" => "Nursing Service Measures",
        "OSL" => "Outside Lab",
        "OT" => "Occupational Therapy",
        "OTH" => "Other",
        "OUS" => "OB Ultrasound",
        "PAR" => "Parasitology",
        "PAT" => "Pathology (Gross & Histopath, not Surgical)",
        "PF" => "Pulmonary Function",
        "PHR" => "Pharmacy",
        "PHY" => "Physician (Hx. Dx, Assessment)",
        "PT" => "Physical Therapy",
        "RAD" => "Radiology",
        "RC" => "Respiratory Care (Therapy)",
        "RT" => "Radiation Therapy",
        "RUS" => "Radiology Ultrasound",
        "RX" => "Radiograph",
        "SP" => "Surgical Pathology",
        "SR" => "Serology",
        "TX" => "Toxicology",
        "URN" => "Urinalysis",
        "VR" => "Virology",
        "VUS" => "Vascular Ultrasound",
        "XRC" => "Cineradiograph"
      }
    },
    76 => %{
      name: "Message Type",
      codes: %{
        "ACK" => "General Acknowledgment",
        "ADR" => "ADT Response",
        "ADT" => "ADT Message",
        "BAR" => "Add/Change Billing Account",
        "BPS" => "Blood Product Dispense Status",
        "BRP" => "Blood Product Dispense Status Acknowledgment",
        "BRT" => "Blood Product Transfusion/Disposition Acknowledgment",
        "BTS" => "Blood Product Transfusion/Disposition",
        "CCF" => "Collaborative Care Fetch",
        "CCI" => "Collaborative Care Information",
        "CCM" => "Collaborative Care Message",
        "CCQ" => "Collaborative Care Referral Query",
        "CCU" => "Collaborative Care Referral Update",
        "CRM" => "Clinical Study Registration",
        "CSU" => "Unsolicited Study Data",
        "DFT" => "Detail Financial Transactions",
        "DOC" => "Document Response",
        "DSR" => "Display Response",
        "EAC" => "Automated Equipment Command",
        "EAN" => "Automated Equipment Notification",
        "EAR" => "Automated Equipment Response",
        "EDR" => "Enhanced Display Response",
        "EQQ" => "Embedded Query Language Query",
        "ERP" => "Event Replay Response",
        "ESR" => "Automated Equipment Status Request",
        "ESU" => "Automated Equipment Status Update",
        "INR" => "Automated Equipment Inventory Request",
        "INU" => "Automated Equipment Inventory Update",
        "LSR" => "Automated Equipment Log/Service Request",
        "LSU" => "Automated Equipment Log/Service Update",
        "MDM" => "Medical Document Management",
        "MFD" => "Master File Delayed Application Acknowledgment",
        "MFK" => "Master File Application Acknowledgment",
        "MFN" => "Master File Notification",
        "MFQ" => "Master File Query",
        "MFR" => "Master File Response",
        "NMD" => "Application Management Data",
        "NMQ" => "Application Management Query",
        "NMR" => "Application Management Response",
        "OMB" => "Blood Product Order",
        "OMD" => "Dietary Order",
        "OMG" => "General Clinical Order",
        "OMI" => "Imaging Order",
        "OML" => "Laboratory Order",
        "OMN" => "Non-Stock Requisition Order",
        "OMP" => "Pharmacy/Treatment Order",
        "OMS" => "Stock Requisition Order",
        "OPL" => "Population/Location-Based Laboratory Order",
        "OPR" => "Population/Location-Based Laboratory Order Acknowledgment",
        "OPU" => "Unsolicited Population/Location-Based Laboratory Observation",
        "ORA" => "Observation Report Acknowledgment",
        "ORB" => "Blood Product Order Acknowledgment",
        "ORD" => "Dietary Order Acknowledgment",
        "ORF" => "Query for Results of Observation",
        "ORG" => "General Clinical Order Acknowledgment",
        "ORI" => "Imaging Order Acknowledgment",
        "ORL" => "Laboratory Order Acknowledgment",
        "ORM" => "Pharmacy/Treatment Order",
        "ORN" => "Non-Stock Requisition Acknowledgment",
        "ORP" => "Pharmacy/Treatment Order Acknowledgment",
        "ORS" => "Stock Requisition Acknowledgment",
        "ORU" => "Unsolicited Transmission of an Observation",
        "OSQ" => "Query Response for Order Status",
        "OSR" => "Query Response for Order Status",
        "OUL" => "Unsolicited Laboratory Observation",
        "PEX" => "Product Experience",
        "PGL" => "Patient Goal",
        "PIN" => "Patient Insurance Information",
        "PMU" => "Add Personnel Record",
        "PPG" => "Patient Pathway (Goal-Oriented)",
        "PPP" => "Patient Pathway (Problem-Oriented)",
        "PPR" => "Patient Problem",
        "PPT" => "Patient Pathway Goal-Oriented Response",
        "PPV" => "Patient Goal Response",
        "PRR" => "Patient Problem Response",
        "PTR" => "Patient Pathway Problem-Oriented Response",
        "QBP" => "Query by Parameter",
        "QCK" => "Deferred Query",
        "QCN" => "Cancel Query",
        "QRY" => "Query, Original Mode",
        "QSB" => "Create Subscription",
        "QSX" => "Cancel Subscription/Acknowledge",
        "QVR" => "Query for Previous Events",
        "RAR" => "Pharmacy/Treatment Administration Information",
        "RAS" => "Pharmacy/Treatment Administration",
        "RCI" => "Return Clinical Information",
        "RCL" => "Return Clinical List",
        "RDE" => "Pharmacy/Treatment Encoded Order",
        "RDR" => "Pharmacy/Treatment Dispense Information",
        "RDS" => "Pharmacy/Treatment Dispense",
        "RDY" => "Display Based Response",
        "REF" => "Patient Referral",
        "RER" => "Pharmacy/Treatment Encoded Order Information",
        "RGR" => "Pharmacy/Treatment Dose Information",
        "RGV" => "Pharmacy/Treatment Give",
        "ROR" => "Pharmacy/Treatment Order Response",
        "RPA" => "Return Patient Authorization",
        "RPI" => "Return Patient Information",
        "RPL" => "Return Patient Display List",
        "RPR" => "Return Patient List",
        "RQA" => "Request Patient Authorization",
        "RQC" => "Request Clinical Information",
        "RQI" => "Request Patient Information",
        "RQP" => "Request Patient Demographics",
        "RRA" => "Pharmacy/Treatment Administration Acknowledgment",
        "RRD" => "Pharmacy/Treatment Dispense Acknowledgment",
        "RRE" => "Pharmacy/Treatment Encoded Order Acknowledgment",
        "RRG" => "Pharmacy/Treatment Give Acknowledgment",
        "RRI" => "Return Referral Information",
        "RSP" => "Segment Pattern Response",
        "RTB" => "Tabular Response",
        "SIU" => "Schedule Information Unsolicited",
        "SPQ" => "Stored Procedure Request",
        "SQM" => "Schedule Query",
        "SQR" => "Schedule Query Response",
        "SRM" => "Schedule Request",
        "SRR" => "Scheduled Request Response",
        "SSR" => "Specimen Status Request",
        "SSU" => "Specimen Status Update",
        "STC" => "Sterilization Item Notification",
        "SUR" => "Summary Product Experience Report",
        "TBR" => "Tabular Data Response",
        "TCR" => "Automated Equipment Test Code Settings Request",
        "TCU" => "Automated Equipment Test Code Settings Update",
        "UDM" => "Unsolicited Display Update",
        "VQQ" => "Virtual Table Query",
        "VXQ" => "Query for Vaccination Record",
        "VXR" => "Vaccination Record Response",
        "VXU" => "Unsolicited Vaccination Record Update",
        "VXX" => "Response for Vaccination Query with Multiple PID Matches"
      }
    },
    85 => %{
      name: "Observation Result Status",
      codes: %{
        "C" => "Record coming over is a correction and thus replaces a final result",
        "D" => "Deletes the OBX record",
        "F" => "Final results",
        "I" => "Specimen in lab; results pending",
        "N" => "Not asked; used to affirmatively document that the observation was not asked",
        "O" => "Order detail description only (no result)",
        "P" => "Preliminary results",
        "R" => "Results entered -- not verified",
        "S" => "Partial results",
        "U" => "Results status change to final without retransmitting results",
        "W" => "Post original as wrong, e.g., transmitted for wrong patient",
        "X" => "Results cannot be obtained for this observation"
      }
    },
    103 => %{
      name: "Processing ID",
      codes: %{
        "D" => "Debugging",
        "P" => "Production",
        "T" => "Training"
      }
    },
    104 => %{
      name: "Version ID",
      codes: %{
        "2.0" => "Release 2.0",
        "2.0D" => "Demo 2.0",
        "2.1" => "Release 2.1",
        "2.2" => "Release 2.2",
        "2.3" => "Release 2.3",
        "2.3.1" => "Release 2.3.1",
        "2.4" => "Release 2.4",
        "2.5" => "Release 2.5",
        "2.5.1" => "Release 2.5.1",
        "2.6" => "Release 2.6",
        "2.7" => "Release 2.7",
        "2.7.1" => "Release 2.7.1",
        "2.8" => "Release 2.8",
        "2.8.1" => "Release 2.8.1",
        "2.8.2" => "Release 2.8.2"
      }
    },
    125 => %{
      name: "Value Type",
      codes: %{
        "AD" => "Address",
        "CE" => "Coded Entry",
        "CF" => "Coded Element with Formatted Values",
        "CK" => "Composite ID with Check Digit",
        "CN" => "Composite ID and Name",
        "CP" => "Composite Price",
        "CWE" => "Coded with Exceptions",
        "CX" => "Extended Composite ID with Check Digit",
        "DT" => "Date",
        "DTM" => "Date/Time",
        "ED" => "Encapsulated Data",
        "FT" => "Formatted Text",
        "ID" => "Coded Value for HL7 Defined Tables",
        "IS" => "Coded Value for User-Defined Tables",
        "MO" => "Money",
        "NM" => "Numeric",
        "PN" => "Person Name",
        "RP" => "Reference Pointer",
        "SN" => "Structured Numeric",
        "ST" => "String Data",
        "TM" => "Time",
        "TN" => "Telephone Number",
        "TS" => "Time Stamp",
        "TX" => "Text Data",
        "XAD" => "Extended Address",
        "XCN" => "Extended Composite Name and Number for Persons",
        "XON" => "Extended Composite Name and Number for Organizations",
        "XPN" => "Extended Person Name",
        "XTN" => "Extended Telecommunication Number"
      }
    },
    155 => %{
      name: "Accept/Application Acknowledgment Conditions",
      codes: %{
        "AL" => "Always",
        "ER" => "Error/Reject Conditions Only",
        "NE" => "Never",
        "SU" => "Successful Completion Only"
      }
    },
    190 => %{
      name: "Address Type",
      codes: %{
        "B" => "Firm/Business",
        "BA" => "Bad Address",
        "BDL" => "Birth Delivery Location",
        "BR" => "Residence at Birth",
        "C" => "Current or Temporary",
        "F" => "Country of Origin",
        "H" => "Home",
        "L" => "Legal Address",
        "M" => "Mailing",
        "N" => "Birth (nee)",
        "O" => "Office",
        "P" => "Permanent",
        "RH" => "Registry Home",
        "S" => "Service Location"
      }
    },
    200 => %{
      name: "Name Type",
      codes: %{
        "A" => "Alias Name",
        "B" => "Name at Birth",
        "C" => "Adopted Name",
        "D" => "Display Name",
        "I" => "Licensing Name",
        "K" => "Artist Name",
        "L" => "Legal Name",
        "M" => "Maiden Name",
        "N" => "Nickname",
        "P" => "Name of Partner/Spouse",
        "R" => "Registered Name",
        "S" => "Coded Pseudo-Name",
        "T" => "Indigenous/Tribal",
        "U" => "Unspecified"
      }
    },
    203 => %{
      name: "Identifier Type",
      codes: %{
        "AM" => "American Express",
        "AN" => "Account Number",
        "ANC" => "Account Number Creditor",
        "AND" => "Account Number Debitor",
        "ANON" => "Anonymous Identifier",
        "ANT" => "Temporary Account Number",
        "APRN" => "Advanced Practice Registered Nurse Number",
        "BA" => "Bank Account Number",
        "BC" => "Bank Card Number",
        "BR" => "Birth Registry Number",
        "BRN" => "Breed Registry Number",
        "CC" => "Cost Center Number",
        "CY" => "County Number",
        "DDS" => "Dentist License Number",
        "DEA" => "Drug Enforcement Administration Registration Number",
        "DFN" => "Drug Furnishing or Prescriptive Authority Number",
        "DI" => "Diner's Club Card",
        "DL" => "Driver's License Number",
        "DN" => "Doctor Number",
        "DO" => "Osteopathic License Number",
        "DP" => "Diplomatic Passport",
        "DPM" => "Podiatrist License Number",
        "DR" => "Donor Registration Number",
        "DS" => "Discover Card",
        "EI" => "Employee Number",
        "EN" => "Employer Number",
        "FI" => "Facility ID",
        "GI" => "Guarantor Internal Identifier",
        "GL" => "General Ledger Number",
        "GN" => "Guarantor External Identifier",
        "HC" => "Health Card Number",
        "JHN" => "Jurisdictional Health Number (Canada)",
        "IND" => "Indigenous/Aboriginal",
        "LI" => "Labor and Industries Number",
        "LN" => "License Number",
        "LR" => "Local Registry ID",
        "MA" => "Patient Medicaid Number",
        "MB" => "Member Number",
        "MC" => "Patient's Medicare Number",
        "MCD" => "Practitioner Medicaid Number",
        "MCN" => "Microchip Number",
        "MCR" => "Practitioner Medicare Number",
        "MD" => "Medical License Number",
        "MI" => "Military ID Number",
        "MR" => "Medical Record Number",
        "MRT" => "Temporary Medical Record Number",
        "MS" => "MasterCard",
        "NE" => "National Employer Identifier",
        "NH" => "National Health Plan Identifier",
        "NI" => "National Unique Individual Identifier",
        "NII" => "National Insurance Organization Identifier",
        "NIIP" => "National Insurance Payor Identifier",
        "NNxxx" => "National Person Identifier (country code in xxx)",
        "NP" => "Nurse Practitioner Number",
        "NPI" => "National Provider Identifier",
        "OD" => "Optometrist License Number",
        "PA" => "Physician Assistant Number",
        "PCN" => "Penitentiary/Correctional Institution Number",
        "PE" => "Living Subject Enterprise Number",
        "PEN" => "Pension Number",
        "PI" => "Patient Internal Identifier",
        "PN" => "Person Number",
        "PNT" => "Temporary Living Subject Number",
        "PPIN" => "Medicare/CMS Performing Provider Identification Number",
        "PPN" => "Passport Number",
        "PRC" => "Permanent Resident Card Number",
        "PRN" => "Provider Number",
        "PT" => "Patient External Identifier",
        "QA" => "QA Number",
        "RI" => "Resource Identifier",
        "RN" => "Registered Nurse Number",
        "RPH" => "Pharmacist License Number",
        "RR" => "Railroad Retirement Number",
        "RRI" => "Regional Registry ID",
        "SL" => "State License",
        "SN" => "Subscriber Number",
        "SP" => "Study Permit",
        "SR" => "State Registry ID",
        "SS" => "Social Security Number",
        "TAX" => "Tax ID Number",
        "TN" => "Treaty Number/(Canda)",
        "U" => "Unspecified Identifier",
        "UPIN" => "Medicare/CMS Universal Physician Identification Numbers",
        "VN" => "Visit Number",
        "VS" => "VISA",
        "WC" => "WIC Identifier",
        "WCN" => "Workers' Comp Number",
        "XX" => "Organization Identifier"
      }
    },
    278 => %{
      name: "Filler Status Codes",
      codes: %{
        "Blocked" => "Blocked",
        "Booked" => "Booked",
        "Cancelled" => "Cancelled",
        "Complete" => "Complete",
        "Deleted" => "Deleted",
        "Discontinued" => "Discontinued",
        "Noshow" => "No Show",
        "Overbook" => "Overbook",
        "Pending" => "Pending",
        "Started" => "Started",
        "Waitlist" => "Waitlist"
      }
    },
    396 => %{
      name: "Coding System",
      codes: %{
        "99zzz" => "Local General Code (z is alphanumeric)",
        "ACR" => "American College of Radiology Finding Codes",
        "ANS+" => "HL7 Set of Units of Measure",
        "ART" => "WHO Adverse Reaction Terms",
        "AS4" => "ASTM E1238/E1467 Universal",
        "AS4E" => "AS4 Neurophysiology Codes",
        "ATC" => "American Type Culture Collection",
        "C4" => "CPT-4",
        "C5" => "CPT-5",
        "CAS" => "Chemical Abstract Codes",
        "CCC" => "Clinical Care Classification System",
        "CD2" => "CDT-2 Codes",
        "CDCA" => "CDC Analyte Codes",
        "CDCM" => "CDC Methods/Instruments Codes",
        "CDS" => "CDC Surveillance",
        "CE" => "CEN ECG Diagnostic Codes",
        "CLP" => "CLIP",
        "CPTM" => "CPT Modifier Code",
        "CST" => "COSTART",
        "CVX" => "CDC Vaccine Codes",
        "DCM" => "DICOM Controlled Terminology",
        "E" => "EUCLIDES",
        "E5" => "Euclides Quantity Codes",
        "E6" => "Euclides Lab Method Codes",
        "E7" => "Euclides Lab Equipment Codes",
        "ENZC" => "Enzyme Codes",
        "FDDC" => "First DataBank Drug Codes",
        "FDDX" => "First DataBank Diagnostic Codes",
        "FDK" => "FDA K10",
        "HB" => "HIBCC",
        "HCPCS" => "CMS (formerly HCFA) Common Procedure Coding System",
        "HCPT" => "Health Care Provider Taxonomy",
        "HHC" => "Home Health Care",
        "HI" => "Health Outcomes",
        "HL7nnnn" => "HL7 Defined Codes (nnnn = HL7 table number)",
        "HOT" => "Japanese Nationwide Medicine Code",
        "HPC" => "CMS (formerly HCFA) Procedure Codes (HCPCS)",
        "I10" => "ICD-10",
        "I10P" => "ICD-10 Procedure Codes",
        "I9" => "ICD9",
        "I9C" => "ICD-9CM",
        "IBT" => "ISBT",
        "IBTnnnn" => "ISBT 128 Standard Transfusion Medicine Codes",
        "IC2" => "ICHPPC-2",
        "ICD10AM" => "ICD-10 Australian Modification",
        "ICD10CA" => "ICD-10 Canada",
        "ICDO" => "International Classification of Diseases for Oncology",
        "ICS" => "ICCS",
        "ICSD" => "International Classification of Sleep Disorders",
        "ISO+" => "ISO 2955.83",
        "ISO3166_1" => "ISO 3166-1 Country Codes",
        "ISO3166_2" => "ISO 3166-2 Country Subdivision Codes",
        "ISO4217" => "ISO 4217 Currency Codes",
        "ISO639" => "ISO 639 Language",
        "IUPC" => "IUPAC/IFCC Component Codes",
        "IUPP" => "IUPAC/IFCC Property Codes",
        "JC8" => "Japanese Chemistry",
        "JJ1017" => "Japanese Image Examination Cache",
        "LB" => "Local Billing Code",
        "LN" => "Logical Observation Identifier Names and Codes (LOINC)",
        "MCD" => "Medicaid",
        "MCR" => "Medicare",
        "MDDX" => "Medispan Diagnostic Codes",
        "MEDC" => "Medical Economics Drug Codes",
        "MEDR" => "Medical Dictionary for Drug Regulatory Affairs (MedDRA)",
        "MEDX" => "Medical Economics Diagnostic Codes",
        "MGPI" => "Medispan GPI",
        "MVX" => "CDC Vaccine Manufacturer Codes",
        "NAICS" => "Industry (NAICS)",
        "NDA" => "NANDA",
        "NDC" => "National Drug Codes",
        "NIC" => "Nursing Interventions Classification",
        "NPI" => "National Provider Identifier",
        "NUBC" => "National Uniform Billing Committee Code",
        "OHA" => "Omaha System",
        "POS" => "POS Codes",
        "RC" => "Read Classification",
        "SCT" => "SNOMED Clinical Terms",
        "SDM" => "SNOMED DiagnosticAllergicReaction Module",
        "SIC" => "Industry (SIC)",
        "SNM" => "Systemized Nomenclature of Medicine (SNOMED)",
        "SNM3" => "SNOMED International",
        "SNT" => "SNOMED Topology Codes (Anatomic Sites)",
        "SOC" => "Occupation (SOC 2000)",
        "UB04FL14" => "Priority (Type) of Visit",
        "UB04FL15" => "Point of Origin",
        "UB04FL17" => "Patient Discharge Status",
        "UB04FL31" => "Occurrence Code",
        "UB04FL35" => "Occurrence Span",
        "UB04FL39" => "Value Code",
        "UCUM" => "UCUM Code Set for Units of Measure",
        "UML" => "Unified Medical Language",
        "UPC" => "Universal Product Code",
        "UPIN" => "UPIN",
        "W1" => "WHO Record # Drug Codes (6 digit)",
        "W2" => "WHO Record # Drug Codes (8 digit)",
        "W4" => "WHO Record # Code with ASTM Extension",
        "WC" => "WHO ATC"
      }
    }
  }

  @table_ids @tables |> Map.keys() |> Enum.sort()

  # ---------------------------------------------------------------------------
  # Public API
  # ---------------------------------------------------------------------------

  @doc """
  Returns the table map for the given table ID, or `nil` if undefined.

  The table ID is an integer (e.g., `1` for Table 0001).

  ## Examples

      iex> table = HL7v2.Standard.Tables.get(1)
      iex> table.name
      "Administrative Sex"

      iex> HL7v2.Standard.Tables.get(9999)
      nil

  """
  @spec get(non_neg_integer()) :: %{name: String.t(), codes: %{String.t() => String.t()}} | nil
  def get(table_id) when is_integer(table_id), do: Map.get(@tables, table_id)

  @doc """
  Returns `true` if `code` is a valid value in the given table.

  Returns `false` for unknown table IDs.

  ## Examples

      iex> HL7v2.Standard.Tables.valid?(1, "F")
      true

      iex> HL7v2.Standard.Tables.valid?(1, "ZZ")
      false

      iex> HL7v2.Standard.Tables.valid?(9999, "X")
      false

  """
  @spec valid?(non_neg_integer(), String.t()) :: boolean()
  def valid?(table_id, code) when is_integer(table_id) and is_binary(code) do
    case Map.get(@tables, table_id) do
      %{codes: codes} -> Map.has_key?(codes, code)
      nil -> false
    end
  end

  @doc """
  Validates `code` against the given table.

  Returns `:ok` if the code is valid, or `{:error, message}` with a
  human-readable description if invalid.

  Returns `:ok` for unknown table IDs (cannot validate what is not defined).

  ## Examples

      iex> HL7v2.Standard.Tables.validate(8, "AA")
      :ok

      iex> HL7v2.Standard.Tables.validate(8, "XX")
      {:error, "invalid code \\"XX\\" for table 0008 (Acknowledgment Code)"}

      iex> HL7v2.Standard.Tables.validate(9999, "X")
      :ok

  """
  @spec validate(non_neg_integer(), String.t()) :: :ok | {:error, String.t()}
  def validate(table_id, code) when is_integer(table_id) and is_binary(code) do
    case Map.get(@tables, table_id) do
      %{name: name, codes: codes} ->
        if Map.has_key?(codes, code) do
          :ok
        else
          padded = table_id |> Integer.to_string() |> String.pad_leading(4, "0")
          {:error, "invalid code #{inspect(code)} for table #{padded} (#{name})"}
        end

      nil ->
        :ok
    end
  end

  @doc """
  Returns a sorted list of all defined table IDs.

  ## Examples

      iex> ids = HL7v2.Standard.Tables.table_ids()
      iex> 1 in ids
      true

      iex> ids = HL7v2.Standard.Tables.table_ids()
      iex> ids == Enum.sort(ids)
      true

  """
  @spec table_ids() :: [non_neg_integer()]
  def table_ids, do: @table_ids
end
