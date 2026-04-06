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
    5 => %{
      name: "Race",
      codes: %{
        "1002-5" => "American Indian or Alaska Native",
        "2028-9" => "Asian",
        "2054-5" => "Black or African American",
        "2076-8" => "Native Hawaiian or Other Pacific Islander",
        "2106-3" => "White",
        "2131-1" => "Other Race",
        "A" => "Asian or Pacific Islander",
        "B" => "Black",
        "H" => "Hispanic",
        "I" => "American Indian or Alaska Native",
        "N" => "Native Hawaiian or Other Pacific Islander",
        "O" => "Other",
        "U" => "Unknown",
        "W" => "White"
      }
    },
    6 => %{
      name: "Religion",
      codes: %{
        "AGN" => "Agnostic",
        "ATH" => "Atheist",
        "BAH" => "Baha'i",
        "BMA" => "Buddhist: Mahayana",
        "BOT" => "Buddhist: Other",
        "BTA" => "Buddhist: Tantrayana",
        "BTH" => "Buddhist: Theravada",
        "BUD" => "Buddhist",
        "CAT" => "Christian: Roman Catholic",
        "CHR" => "Christian",
        "CHS" => "Christian: Christian Science",
        "CMA" => "Christian: Christian Missionary Alliance",
        "CNF" => "Confucian",
        "COC" => "Christian: Church of Christ",
        "COG" => "Christian: Church of God",
        "COI" => "Christian: Church of God in Christ",
        "COL" => "Christian: Congregational",
        "COM" => "Christian: Community",
        "COP" => "Christian: Other Pentecostal",
        "COT" => "Christian: Other",
        "EPI" => "Christian: Episcopalian",
        "ERL" => "Ethnic Religionist",
        "EVC" => "Christian: Evangelical Church",
        "FRQ" => "Christian: Friends",
        "FUL" => "Christian: Full Gospel",
        "GRE" => "Christian: Greek Orthodox",
        "HIN" => "Hindu",
        "HOT" => "Hindu: Other",
        "HSH" => "Hindu: Shaivites",
        "HVA" => "Hindu: Vaishnavites",
        "JAI" => "Jain",
        "JCO" => "Jewish: Conservative",
        "JEW" => "Jewish",
        "JOR" => "Jewish: Orthodox",
        "JOT" => "Jewish: Other",
        "JRC" => "Jewish: Reconstructionist",
        "JRF" => "Jewish: Reform",
        "JRN" => "Jewish: Renewal",
        "LMS" => "Christian: Lutheran Missouri Synod",
        "LUT" => "Christian: Lutheran",
        "MEN" => "Christian: Mennonite",
        "MET" => "Christian: Methodist",
        "MOM" => "Christian: Latter-day Saints",
        "MOS" => "Muslim",
        "MOT" => "Muslim: Other",
        "MSH" => "Muslim: Shiite",
        "MSU" => "Muslim: Sunni",
        "NAM" => "Native American",
        "NAZ" => "Christian: Church of the Nazarene",
        "NOE" => "Nonreligious",
        "NRL" => "New Religionist",
        "ORT" => "Christian: Orthodox",
        "OTH" => "Other",
        "PEN" => "Christian: Pentecostal",
        "PRC" => "Christian: Other Protestant",
        "PRE" => "Christian: Presbyterian",
        "PRO" => "Christian: Protestant",
        "QUA" => "Christian: Friends",
        "REC" => "Christian: Reformed Church",
        "REO" => "Christian: Reorganized Church of Jesus Christ-LDS",
        "SAA" => "Christian: Salvation Army",
        "SEV" => "Christian: Seventh Day Adventist",
        "SHN" => "Shintoist",
        "SIK" => "Sikh",
        "SOU" => "Christian: Southern Baptist",
        "SPI" => "Spiritist",
        "UNI" => "Christian: Unitarian",
        "UNU" => "Christian: Unitarian Universalist",
        "VAR" => "Unknown",
        "WES" => "Christian: Wesleyan",
        "WMC" => "Christian: Wesleyan Methodist"
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
    9 => %{
      name: "Ambulatory Status",
      codes: %{
        "A0" => "No functional limitations",
        "A1" => "Ambulates with assistive device",
        "A2" => "Wheelchair/stretcher bound",
        "A3" => "Comatose; non-responsive",
        "A4" => "Disoriented",
        "A5" => "Vision impaired",
        "A6" => "Hearing impaired",
        "A7" => "Speech impaired",
        "A8" => "Non-English speaking",
        "A9" => "Functional level unknown",
        "B1" => "Oxygen therapy",
        "B2" => "Special equipment (tubes, IVs, catheters)",
        "B3" => "Amputee",
        "B4" => "Mastectomy",
        "B5" => "Paraplegic",
        "B6" => "Pregnant"
      }
    },
    10 => %{
      name: "Physician ID",
      codes: %{
        "AD" => "Admitting",
        "AT" => "Attending",
        "CP" => "Consulting Provider",
        "FHCP" => "Family Health Care Professional",
        "PP" => "Primary Care Provider",
        "RP" => "Referring Provider",
        "RT" => "Referred to Provider"
      }
    },
    15 => %{
      name: "Point of Origin",
      codes: %{
        "1" => "Physician referral",
        "2" => "Clinic referral",
        "3" => "HMO referral",
        "4" => "Transfer from a hospital",
        "5" => "Transfer from a skilled nursing facility",
        "6" => "Transfer from another health care facility",
        "7" => "Emergency room",
        "8" => "Court/law enforcement",
        "9" => "Information not available"
      }
    },
    17 => %{
      name: "Transaction Type",
      codes: %{
        "CG" => "Charge",
        "CD" => "Credit",
        "PY" => "Payment",
        "AJ" => "Adjustment"
      }
    },
    18 => %{
      name: "Patient Type",
      codes: %{
        "I" => "Inpatient",
        "O" => "Outpatient",
        "P" => "Preadmit",
        "E" => "Emergency",
        "B" => "Obstetrics",
        "R" => "Recurring"
      }
    },
    23 => %{
      name: "Admit Source",
      codes: %{
        "1" => "Physician referral",
        "2" => "Clinic referral",
        "3" => "HMO referral",
        "4" => "Transfer from a hospital",
        "5" => "Transfer from a skilled nursing facility",
        "6" => "Transfer from another health care facility",
        "7" => "Emergency room",
        "8" => "Court/law enforcement",
        "9" => "Information not available"
      }
    },
    38 => %{
      name: "Order Status",
      codes: %{
        "A" => "Some, but not all, results available",
        "CA" => "Order was canceled",
        "CM" => "Order is completed",
        "DC" => "Order was discontinued",
        "ER" => "Error, order not found",
        "HD" => "Order is on hold",
        "IP" => "In process, unspecified",
        "RP" => "Order has been replaced",
        "SC" => "In process, scheduled"
      }
    },
    48 => %{
      name: "What Subject Filter",
      codes: %{
        "ADV" => "Advice/diagnosis",
        "ANU" => "Nursing unit lookup (returns patients)",
        "APN" => "Patient name lookup",
        "APP" => "Physician lookup",
        "ARN" => "Nursing unit lookup (returns location)",
        "APM" => "Medical record number query, returns visits",
        "APA" => "Account number query, return matching visit",
        "CAN" => "Cancel. Used to cancel a query",
        "DEM" => "Demographics",
        "FIN" => "Financial",
        "GID" => "Generate new identifier",
        "GOL" => "Goals",
        "MRI" => "Most recent inpatient",
        "MRO" => "Most recent outpatient",
        "NCK" => "Network clock",
        "NSC" => "Network status change",
        "NST" => "Network statistic",
        "ORD" => "Order",
        "OTH" => "Other",
        "PRB" => "Problems",
        "PRO" => "Procedure",
        "RES" => "Result",
        "RAR" => "Pharmacy administration information",
        "RER" => "Pharmacy encoded order information",
        "RDR" => "Pharmacy dispense information",
        "RGR" => "Pharmacy give information",
        "ROR" => "Pharmacy prescription information",
        "SAL" => "All schedule related information",
        "SBK" => "Booked slots on the identified schedule",
        "SBL" => "Blocked slots on the identified schedule",
        "SOF" => "First open slot on the identified schedule",
        "SOP" => "Open slots on the identified schedule",
        "SSA" => "Time slots available for a single appointment",
        "SSR" => "Time slots available for a recurring appointment",
        "STA" => "Status",
        "VXI" => "Vaccine information"
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
    62 => %{
      name: "Event Reason",
      codes: %{
        "01" => "Patient request",
        "02" => "Physician/health practitioner order",
        "03" => "Census management",
        "O" => "Other",
        "U" => "Unknown"
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
    65 => %{
      name: "Specimen Action Code",
      codes: %{
        "A" => "Add ordered tests to the existing specimen",
        "C" => "Cancel order for battery or tests named",
        "G" => "Generated order; reflex order",
        "L" => "Lab to obtain specimen from patient",
        "O" => "Specimen obtained by service other than Lab",
        "P" => "Pending collection",
        "R" => "Revised order",
        "S" => "Schedule the tests specified below"
      }
    },
    69 => %{
      name: "Hospital Service",
      codes: %{
        "CAR" => "Cardiac Service",
        "MED" => "Medical Service",
        "PUL" => "Pulmonary Service",
        "SUR" => "Surgical Service",
        "URO" => "Urology Service"
      }
    },
    70 => %{
      name: "Specimen Source Codes",
      codes: %{
        "ABS" => "Abscess",
        "AMN" => "Amniotic Fluid",
        "ASP" => "Aspirate",
        "BLD" => "Whole Blood",
        "BON" => "Bone",
        "BPH" => "Basophils",
        "BRN" => "Burn",
        "BRO" => "Bronchial",
        "BRTH" => "Breath (use EXHLD)",
        "CALC" => "Calculus (ite Stone)",
        "CSF" => "Cerebral Spinal Fluid",
        "CVX" => "Cervix",
        "EAR" => "Ear",
        "EOS" => "Eosinophils",
        "EYE" => "Eye",
        "FIB" => "Fibroblasts",
        "GAST" => "Gastric Fluid/Contents",
        "HAR" => "Hair",
        "LYM" => "Lymphocytes",
        "MAC" => "Macrophages",
        "MAR" => "Marrow",
        "NOS" => "Nose (Nasal Passage)",
        "PER" => "Peritoneal Fluid/Ascites",
        "PLA" => "Plasma",
        "PLB" => "Plasma Bag",
        "PLR" => "Pleural Fluid (Thoracentesis Fld)",
        "SAL" => "Saliva",
        "SEM" => "Seminal Fluid",
        "SER" => "Serum",
        "SKN" => "Skin",
        "SNV" => "Synovial Fluid (Joint Fluid)",
        "SPT" => "Sputum",
        "STL" => "Stool = Fecal",
        "SWT" => "Sweat",
        "THR" => "Throat",
        "TIS" => "Tissue",
        "UMB" => "Umbilical Blood",
        "UR" => "Urine",
        "VOM" => "Vomitus",
        "WND" => "Wound"
      }
    },
    72 => %{
      name: "Insurance Plan ID",
      codes: %{
        "BC" => "Blue Cross",
        "BS" => "Blue Shield",
        "HM" => "HMO",
        "MC" => "Medicaid",
        "MA" => "Medicare Part A",
        "MB" => "Medicare Part B",
        "OF" => "Other Federal Program",
        "TV" => "Title V",
        "VA" => "Veterans Affairs Plan",
        "WC" => "Workers Compensation"
      }
    },
    80 => %{
      name: "Nature of Abnormal Testing",
      codes: %{
        "A" => "An age-based population",
        "B" => "Breed",
        "N" => "None - generic normal range",
        "R" => "A race-based population",
        "S" => "A sex-based population",
        "SP" => "Species"
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
    91 => %{
      name: "Query Priority",
      codes: %{
        "D" => "Deferred",
        "I" => "Immediate"
      }
    },
    100 => %{
      name: "Invocation Event",
      codes: %{
        "D" => "On disconnect",
        "O" => "On receipt of order",
        "Q" => "At specified date/time",
        "R" => "On result",
        "S" => "At time service is started",
        "T" => "At a designated date/time"
      }
    },
    102 => %{
      name: "Delayed Acknowledgment Type",
      codes: %{
        "D" => "Message Received, stored for later processing",
        "F" => "Acknowledgment after processing"
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
    105 => %{
      name: "Source of Comment",
      codes: %{
        "L" => "Ancillary (filler) department is source of comment",
        "O" => "Other system is source of comment",
        "P" => "Orderer (placer) is source of comment"
      }
    },
    112 => %{
      name: "Discharge Disposition",
      codes: %{
        "01" => "Discharged to home or self care (routine discharge)",
        "02" => "Discharged/transferred to a short term general hospital",
        "03" => "Discharged/transferred to skilled nursing facility (SNF)",
        "04" => "Discharged/transferred to an intermediate care facility (ICF)",
        "05" => "Discharged/transferred to a designated cancer center or children's hospital",
        "06" =>
          "Discharged/transferred to home under care of organized home health service organization",
        "07" => "Left against medical advice or discontinued care",
        "08" => "Discharged/transferred to home under care of Home IV provider",
        "09" => "Admitted as an inpatient to this hospital",
        "10" => "Discharge to be defined at state level",
        "20" => "Expired",
        "21" => "Discharged/transferred to court/law enforcement",
        "30" => "Still patient or expected to return for outpatient services",
        "40" => "Expired at home",
        "41" => "Expired in a medical facility",
        "42" => "Expired - place unknown",
        "43" => "Discharged/transferred to a federal health care facility"
      }
    },
    113 => %{
      name: "Discharged to Location",
      codes: %{
        "01" => "Home",
        "02" => "Short term general hospital",
        "03" => "Skilled nursing facility (SNF)",
        "04" => "Intermediate care facility (ICF)",
        "05" => "Designated cancer center or children's hospital",
        "06" => "Home under care of organized home health service organization",
        "07" => "Left against medical advice",
        "08" => "Home under care of Home IV provider",
        "09" => "Admitted as an inpatient to this hospital",
        "10" => "State-defined",
        "20" => "Expired",
        "21" => "Court/law enforcement",
        "30" => "Still patient"
      }
    },
    116 => %{
      name: "Bed Status",
      codes: %{
        "C" => "Closed",
        "H" => "Housekeeping",
        "I" => "Isolated",
        "K" => "Contaminated",
        "O" => "Occupied",
        "U" => "Unoccupied"
      }
    },
    117 => %{
      name: "Account Status",
      codes: %{
        "1" => "Active",
        "2" => "Active and billed",
        "3" => "Closed",
        "4" => "Inactive",
        "5" => "Inactive and billed"
      }
    },
    119 => %{
      name: "Order Control Codes",
      codes: %{
        "AF" => "Order/service refill request approval",
        "CA" => "Cancel order/service request",
        "CH" => "Child order/service",
        "CN" => "Combined result",
        "CR" => "Canceled as requested",
        "DC" => "Discontinue order/service request",
        "DE" => "Data errors",
        "DF" => "Order/service refill request denied",
        "DR" => "Discontinued as requested",
        "FU" => "Order/service refilled, unsolicited",
        "HD" => "Hold order request",
        "HR" => "On hold as requested",
        "LI" => "Link order/service to patient care problem or goal",
        "NA" => "Number assigned",
        "NW" => "New order/service",
        "OC" => "Order/service canceled",
        "OD" => "Order/service discontinued",
        "OE" => "Order/service released",
        "OF" => "Order/service refilled as requested",
        "OH" => "Order/service held",
        "OK" => "Order/service accepted & OK",
        "OP" => "Notification of order for outside dispense",
        "OR" => "Released as requested",
        "PA" => "Parent order/service",
        "RE" => "Observations/Performed Service to follow",
        "RF" => "Refill order/service request",
        "RL" => "Release previous hold",
        "RO" => "Replacement order",
        "RP" => "Order/service replace request",
        "RQ" => "Replaced as requested",
        "RR" => "Request received",
        "RU" => "Replaced unsolicited",
        "SC" => "Status changed",
        "SN" => "Send order/service number",
        "SR" => "Response to send order/service status request",
        "SS" => "Send order/service status request",
        "UA" => "Unable to accept order/service",
        "UC" => "Unable to cancel",
        "UD" => "Unable to discontinue",
        "UF" => "Unable to refill",
        "UH" => "Unable to put on hold",
        "UM" => "Unable to replace",
        "UN" => "Unlink order/service from patient care problem or goal",
        "UR" => "Unable to release",
        "UX" => "Unable to change",
        "XO" => "Change order/service request",
        "XR" => "Changed as requested",
        "XX" => "Order/service changed, unsol."
      }
    },
    121 => %{
      name: "Response Flag",
      codes: %{
        "D" => "Same as R, plus report/reference intervals, normals, and units",
        "E" => "Report exceptions only",
        "F" => "Same as D, plus patient demographics from PID segment",
        "N" => "Only the MSA segment is returned",
        "R" => "Same as E, plus Observations and OBX segments"
      }
    },
    123 => %{
      name: "Result Status",
      codes: %{
        "A" => "Some, but not all, results available",
        "C" => "Correction to results",
        "F" => "Final results",
        "I" => "No results available; specimen received, procedure incomplete",
        "O" => "Order received; specimen not yet received",
        "P" => "Preliminary",
        "R" => "Results stored; not yet verified",
        "S" => "No results available; procedure scheduled, but not done",
        "X" => "No results available; order canceled",
        "Y" => "No order on record for this test",
        "Z" => "No record of this patient"
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
    127 => %{
      name: "Allergen Type",
      codes: %{
        "AA" => "Animal Allergy",
        "DA" => "Drug Allergy",
        "EA" => "Environmental Allergy",
        "FA" => "Food Allergy",
        "LA" => "Pollen Allergy",
        "MA" => "Miscellaneous Allergy",
        "MC" => "Miscellaneous Contraindication",
        "NKA" => "No Known Allergies",
        "PA" => "Plant Allergy",
        "PL" => "Pollen"
      }
    },
    128 => %{
      name: "Allergy Severity",
      codes: %{
        "MI" => "Mild",
        "MO" => "Moderate",
        "SV" => "Severe",
        "U" => "Unknown"
      }
    },
    130 => %{
      name: "Visit User Code",
      codes: %{
        "HO" => "Home",
        "MO" => "Mobile Unit",
        "PH" => "Phone",
        "TE" => "Teaching"
      }
    },
    131 => %{
      name: "Contact Role",
      codes: %{
        "C" => "Emergency Contact",
        "E" => "Employer",
        "F" => "Federal Agency",
        "I" => "Insurance Company",
        "N" => "Next-of-Kin",
        "O" => "Other",
        "P" => "Person preparing referral",
        "S" => "State Agency",
        "U" => "Unknown"
      }
    },
    136 => %{
      name: "Yes/No Indicator",
      codes: %{
        "N" => "No",
        "Y" => "Yes"
      }
    },
    137 => %{
      name: "Mail Claim Party",
      codes: %{
        "E" => "Employer",
        "G" => "Guarantor",
        "I" => "Insurance Company",
        "O" => "Other",
        "P" => "Patient"
      }
    },
    141 => %{
      name: "Military Rank/Grade",
      codes: %{
        "E1" => "Enlisted 1",
        "E2" => "Enlisted 2",
        "E3" => "Enlisted 3",
        "E4" => "Enlisted 4",
        "E5" => "Enlisted 5",
        "E6" => "Enlisted 6",
        "E7" => "Enlisted 7",
        "E8" => "Enlisted 8",
        "E9" => "Enlisted 9",
        "O1" => "Officers 1",
        "O2" => "Officers 2",
        "O3" => "Officers 3",
        "O4" => "Officers 4",
        "O5" => "Officers 5",
        "O6" => "Officers 6",
        "O7" => "Officers 7",
        "O8" => "Officers 8",
        "O9" => "Officers 9",
        "O10" => "Officers 10",
        "W1" => "Warrant Officers 1",
        "W2" => "Warrant Officers 2",
        "W3" => "Warrant Officers 3",
        "W4" => "Warrant Officers 4"
      }
    },
    148 => %{
      name: "Money or Percentage Indicator",
      codes: %{
        "AT" => "Currency amount",
        "PC" => "Percentage"
      }
    },
    150 => %{
      name: "Certification Patient Type",
      codes: %{
        "ER" => "Emergency",
        "IPE" => "Inpatient Elective",
        "OPE" => "Outpatient Elective",
        "UR" => "Urgent"
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
    162 => %{
      name: "Route of Administration",
      codes: %{
        "AP" => "Apply Externally",
        "B" => "Buccal",
        "DT" => "Dental",
        "EP" => "Epidural",
        "ET" => "Endotracheal Tube",
        "GTT" => "Gastrostomy Tube",
        "GU" => "GU Irrigant",
        "IA" => "Intra-arterial",
        "IB" => "Intrabursal",
        "IC" => "Intracardiac",
        "ICV" => "Intracervical (uterus)",
        "ID" => "Intradermal",
        "IH" => "Inhalation",
        "IHA" => "Intrahepatic Artery",
        "IM" => "Intramuscular",
        "IN" => "Intranasal",
        "IO" => "Intraocular",
        "IP" => "Intraperitoneal",
        "IS" => "Intrasynovial",
        "IT" => "Intrathecal",
        "IU" => "Intrauterine",
        "IV" => "Intravenous",
        "MM" => "Mucous Membrane",
        "MTH" => "Mouth/Throat",
        "NG" => "Nasogastric",
        "NP" => "Nasal Prongs",
        "NS" => "Nasal",
        "NT" => "Nasotracheal Tube",
        "OP" => "Ophthalmic",
        "OT" => "Otic",
        "OTH" => "Other/Miscellaneous",
        "PF" => "Perfusion",
        "PO" => "Oral",
        "PR" => "Rectal",
        "RM" => "Rebreather Mask",
        "SC" => "Subcutaneous",
        "SD" => "Soaked Dressing",
        "SL" => "Sublingual",
        "TD" => "Transdermal",
        "TL" => "Translingual",
        "TP" => "Topical",
        "TRA" => "Tracheostomy",
        "UR" => "Urethral",
        "VG" => "Vaginal",
        "VM" => "Ventimask",
        "WND" => "Wound"
      }
    },
    163 => %{
      name: "Body Site",
      codes: %{
        "BE" => "Bilateral Ears",
        "BN" => "Bilateral Nares",
        "BU" => "Buttock",
        "CT" => "Chest Tube",
        "LA" => "Left Arm",
        "LAC" => "Left Anterior Chest",
        "LACF" => "Left Antecubital Fossa",
        "LD" => "Left Deltoid",
        "LE" => "Left Ear",
        "LEJ" => "Left External Jugular",
        "LF" => "Left Foot",
        "LG" => "Left Gluteus Medius",
        "LH" => "Left Hand",
        "LIJ" => "Left Internal Jugular",
        "LLAQ" => "Left Lower Abd Quadrant",
        "LLFA" => "Left Lower Forearm",
        "LMFA" => "Left Mid Forearm",
        "LN" => "Left Naris",
        "LPC" => "Left Posterior Chest",
        "LSC" => "Left Subclavian",
        "LT" => "Left Thigh",
        "LUA" => "Left Upper Arm",
        "LUAQ" => "Left Upper Abd Quadrant",
        "LUFA" => "Left Upper Forearm",
        "LVG" => "Left Ventrogluteal",
        "LVL" => "Left Vastus Lateralis",
        "NB" => "Nebulized",
        "OD" => "Right Eye",
        "OS" => "Left Eye",
        "OU" => "Bilateral Eyes",
        "PA" => "Perianal",
        "PERIN" => "Perineal",
        "RA" => "Right Arm",
        "RAC" => "Right Anterior Chest",
        "RACF" => "Right Antecubital Fossa",
        "RD" => "Right Deltoid",
        "RE" => "Right Ear",
        "REJ" => "Right External Jugular",
        "RF" => "Right Foot",
        "RG" => "Right Gluteus Medius",
        "RH" => "Right Hand",
        "RIJ" => "Right Internal Jugular",
        "RLAQ" => "Right Lower Abd Quadrant",
        "RLFA" => "Right Lower Forearm",
        "RMFA" => "Right Mid Forearm",
        "RN" => "Right Naris",
        "RPC" => "Right Posterior Chest",
        "RSC" => "Right Subclavian",
        "RT" => "Right Thigh",
        "RUA" => "Right Upper Arm",
        "RUAQ" => "Right Upper Abd Quadrant",
        "RUFA" => "Right Upper Forearm",
        "RVG" => "Right Ventrogluteal",
        "RVL" => "Right Vastus Lateralis"
      }
    },
    171 => %{
      name: "Citizenship",
      codes: %{
        "AFG" => "Afghanistan",
        "ALB" => "Albania",
        "ARG" => "Argentina",
        "AUS" => "Australia",
        "AUT" => "Austria",
        "BEL" => "Belgium",
        "BRA" => "Brazil",
        "CAN" => "Canada",
        "CHE" => "Switzerland",
        "CHN" => "China",
        "COL" => "Colombia",
        "CUB" => "Cuba",
        "DEU" => "Germany",
        "DNK" => "Denmark",
        "DOM" => "Dominican Republic",
        "ECU" => "Ecuador",
        "EGY" => "Egypt",
        "ESP" => "Spain",
        "FIN" => "Finland",
        "FRA" => "France",
        "GBR" => "United Kingdom",
        "GRC" => "Greece",
        "GTM" => "Guatemala",
        "HND" => "Honduras",
        "HTI" => "Haiti",
        "IND" => "India",
        "IRL" => "Ireland",
        "IRN" => "Iran",
        "IRQ" => "Iraq",
        "ISR" => "Israel",
        "ITA" => "Italy",
        "JAM" => "Jamaica",
        "JPN" => "Japan",
        "KOR" => "Korea",
        "MEX" => "Mexico",
        "NGA" => "Nigeria",
        "NLD" => "Netherlands",
        "NOR" => "Norway",
        "PAK" => "Pakistan",
        "PER" => "Peru",
        "PHL" => "Philippines",
        "POL" => "Poland",
        "PRI" => "Puerto Rico",
        "PRT" => "Portugal",
        "RUS" => "Russia",
        "SAU" => "Saudi Arabia",
        "SWE" => "Sweden",
        "THA" => "Thailand",
        "TUR" => "Turkey",
        "TWN" => "Taiwan",
        "UKR" => "Ukraine",
        "USA" => "United States",
        "VEN" => "Venezuela",
        "VNM" => "Vietnam"
      }
    },
    172 => %{
      name: "Veterans Military Status",
      codes: %{
        "ACT" => "Active duty",
        "DEC" => "Deceased",
        "RET" => "Retired",
        "SEP" => "Separated"
      }
    },
    174 => %{
      name: "Nature of Service/Test/Observation",
      codes: %{
        "A" => "Atomic service/test/observation",
        "C" => "Single observation calculated via a rule or formula",
        "F" => "Functional procedure that may consist of one or more interrelated measures",
        "P" => "Profile or battery consisting of many independent atomic observations",
        "S" => "Superset — a set of batteries or procedures ordered under a single code"
      }
    },
    175 => %{
      name: "Master File Identifier Code",
      codes: %{
        "CDM" => "Charge Description Master File",
        "CLN" => "Clinic Master File",
        "CMA" => "Clinical Study with Phases and Schedules Master File",
        "CMB" => "Clinical Study without Phases but with Schedules Master File",
        "LOC" => "Location Master File",
        "OMx" => "Observation Batteries/Definitions Master File",
        "PRA" => "Practitioner Master File",
        "STF" => "Staff Master File"
      }
    },
    180 => %{
      name: "Record-Level Event Code",
      codes: %{
        "MAC" => "Reactivate deactivated record",
        "MAD" => "Add record to master file",
        "MDC" => "Deactivate: discontinue using record in master file, but do not delete",
        "MDL" => "Delete record from master file",
        "MUP" => "Update record for master file"
      }
    },
    185 => %{
      name: "Preferred Method of Contact",
      codes: %{
        "B" => "Beeper Number",
        "C" => "Cellular Phone Number",
        "E" => "E-Mail Address",
        "F" => "FAX Number",
        "H" => "Home Phone Number",
        "O" => "Office Phone Number"
      }
    },
    189 => %{
      name: "Ethnic Group",
      codes: %{
        "H" => "Hispanic or Latino",
        "N" => "Not Hispanic or Latino",
        "U" => "Unknown",
        "2135-2" => "Hispanic or Latino",
        "2186-5" => "Not Hispanic or Latino"
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
    206 => %{
      name: "Segment Action Code",
      codes: %{
        "A" => "Add/Insert",
        "D" => "Delete",
        "U" => "Update",
        "X" => "No Change"
      }
    },
    207 => %{
      name: "Processing Mode",
      codes: %{
        "A" => "Archive",
        "I" => "Initial load",
        "Not present" => "Not present (the default, meaning current processing)",
        "R" => "Restore from archive",
        "T" => "Current processing, transmitted at intervals"
      }
    },
    208 => %{
      name: "Query Response Status",
      codes: %{
        "AE" => "Application error",
        "AR" => "Application reject",
        "NF" => "No data found, no errors",
        "OK" => "Data found, no errors (this is the default)"
      }
    },
    209 => %{
      name: "Relational Operator",
      codes: %{
        "CT" => "Contains",
        "EQ" => "Equal",
        "GE" => "Greater than or equal",
        "GN" => "Generic",
        "GT" => "Greater than",
        "LE" => "Less than or equal",
        "LT" => "Less than",
        "NE" => "Not equal"
      }
    },
    211 => %{
      name: "Alternate Character Sets",
      codes: %{
        "8859/1" => "ISO 8859/1 Character Set",
        "8859/2" => "ISO 8859/2 Character Set",
        "8859/3" => "ISO 8859/3 Character Set",
        "8859/4" => "ISO 8859/4 Character Set",
        "8859/5" => "ISO 8859/5 Character Set",
        "8859/6" => "ISO 8859/6 Character Set",
        "8859/7" => "ISO 8859/7 Character Set",
        "8859/8" => "ISO 8859/8 Character Set",
        "8859/9" => "ISO 8859/9 Character Set",
        "8859/15" => "ISO 8859/15 Latin-15",
        "ASCII" => "The printable 7-bit ASCII character set",
        "BIG-5" => "Code for Taiwanese Character Set (BIG-5)",
        "CNS 11643-1992" => "Code for Taiwanese Character Set (CNS 11643-1992)",
        "GB 18030-2000" => "Code for Chinese Character Set (GB 18030-2000)",
        "ISO IR14" => "Code for Information Exchange (one byte)(JIS X 0201-1976)",
        "ISO IR159" =>
          "Code of the supplementary Japanese Graphic Character set (JIS X 0212-1990)",
        "ISO IR6" => "ASCII graphic character set consisting of 94 characters",
        "ISO IR87" => "Code for the Japanese Graphic Character set (JIS X 0208-1990)",
        "KS X 1001" => "Code for Korean Character Set (KS X 1001)",
        "UNICODE" => "The world wide character standard from ISO/IEC 10646-1-1993",
        "UNICODE UTF-16" => "UCS Transformation Format, 16-bit form",
        "UNICODE UTF-32" => "UCS Transformation Format, 32-bit form",
        "UNICODE UTF-8" => "UCS Transformation Format, 8-bit form"
      }
    },
    215 => %{
      name: "Publicity Code",
      codes: %{
        "F" => "Family only",
        "N" => "No publicity",
        "O" => "Other",
        "U" => "Unknown"
      }
    },
    217 => %{
      name: "Visit Priority Code",
      codes: %{
        "1" => "Emergency",
        "2" => "Urgent",
        "3" => "Elective"
      }
    },
    228 => %{
      name: "Diagnosis Classification",
      codes: %{
        "C" => "Consultation",
        "D" => "Diagnosis",
        "I" => "Invasive procedure not classified elsewhere",
        "M" => "Medication (antibiotic)",
        "O" => "Other",
        "R" => "Radiological scheduling (not using ICDA codes)",
        "S" => "Sign and symptom",
        "T" => "Tissue diagnosis"
      }
    },
    229 => %{
      name: "DRG Payor",
      codes: %{
        "C" => "Champus",
        "G" => "Managed Care Organization",
        "M" => "Medicare"
      }
    },
    231 => %{
      name: "Student Status",
      codes: %{
        "F" => "Full-time student",
        "N" => "Not a student",
        "P" => "Part-time student"
      }
    },
    234 => %{
      name: "Report Timing",
      codes: %{
        "10D" => "10 day report",
        "15D" => "15 day report",
        "30D" => "30 day report",
        "3D" => "3 day report",
        "7D" => "7 day report",
        "AD" => "Additional information",
        "CO" => "Correction",
        "DE" => "Device evaluation",
        "PD" => "Periodic",
        "RQ" => "Requested information"
      }
    },
    254 => %{
      name: "Kind of Quantity",
      codes: %{
        "ABS" => "Absorbance",
        "ACNC" => "Concentration, Arbitrary Substance",
        "CACT" => "Catalytic Activity",
        "CNC" => "Catalytic Concentration",
        "CNCR" => "Catalytic Concentration Ratio",
        "CNFR" => "Catalytic Fraction",
        "CRAT" => "Catalytic Rate",
        "CRTO" => "Catalytic Ratio",
        "ENT" => "Entitic",
        "ENTC" => "Entitic Catalytic Activity",
        "ENTN" => "Entitic Number",
        "ENTS" => "Entitic Substance of Amount",
        "MASS" => "Mass",
        "MCNC" => "Mass Concentration",
        "MRAT" => "Mass Rate",
        "NUM" => "Number",
        "SCNC" => "Substance Concentration",
        "SUB" => "Substance Amount",
        "TITR" => "Titer",
        "VOL" => "Volume"
      }
    },
    255 => %{
      name: "Duration Categories",
      codes: %{
        "*" => "Life of the \"unit\"",
        "12H" => "12 hours",
        "1H" => "1 hour",
        "1L" => "1 month (30 days)",
        "1W" => "1 week",
        "24H" => "24 hours",
        "2D" => "2 days",
        "2H" => "2 hours",
        "2L" => "2 months",
        "2W" => "2 weeks",
        "30M" => "30 minutes",
        "3D" => "3 days",
        "3H" => "3 hours",
        "3L" => "3 months",
        "3W" => "3 weeks",
        "4D" => "4 days",
        "4H" => "4 hours",
        "4W" => "4 weeks",
        "5D" => "5 days",
        "5H" => "5 hours",
        "6D" => "6 days",
        "6H" => "6 hours",
        "7H" => "7 hours",
        "8H" => "8 hours",
        "PT" => "To identify measures at a point in time",
        "ST" => "To identify measures taken over the course of a study"
      }
    },
    267 => %{
      name: "Days of the Week",
      codes: %{
        "FRI" => "Friday",
        "MON" => "Monday",
        "SAT" => "Saturday",
        "SUN" => "Sunday",
        "THU" => "Thursday",
        "TUE" => "Tuesday",
        "WED" => "Wednesday"
      }
    },
    271 => %{
      name: "Document Completion Status",
      codes: %{
        "AU" => "Authenticated",
        "DI" => "Dictated",
        "DO" => "Documented",
        "IN" => "Incomplete",
        "IP" => "In Progress",
        "LA" => "Legally Authenticated",
        "PA" => "Pre-Authenticated"
      }
    },
    272 => %{
      name: "Document Confidentiality Status",
      codes: %{
        "R" => "Restricted",
        "U" => "Usual Control",
        "V" => "Very Restricted"
      }
    },
    273 => %{
      name: "Document Availability Status",
      codes: %{
        "AV" => "Available for patient care",
        "CA" => "Deleted",
        "OB" => "Obsolete",
        "UN" => "Unavailable for patient care"
      }
    },
    275 => %{
      name: "Document Storage Status",
      codes: %{
        "AA" => "Active and archived",
        "AC" => "Active",
        "AR" => "Archived (not active)",
        "PU" => "Purged"
      }
    },
    276 => %{
      name: "Appointment Reason Codes",
      codes: %{
        "CHECKUP" => "A routine check-up",
        "EMERGENCY" => "Emergency appointment",
        "FOLLOWUP" => "A follow up visit from a previous appointment",
        "ROUTINE" => "Routine appointment - default if not valued",
        "WALKIN" => "A previously unscheduled walk-in visit"
      }
    },
    277 => %{
      name: "Appointment Type Codes",
      codes: %{
        "Complete" => "A request to add a completed appointment",
        "Normal" => "Routine schedule request type - default if not valued",
        "Tentative" => "A request for a tentative (e.g., \"penciled in\") appointment"
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
    279 => %{
      name: "Allow Substitution Codes",
      codes: %{
        "Confirm" => "Contact the Placer Contact Person prior to making any substitutions",
        "No" => "Substitution is not allowed",
        "Yes" => "Substitution is allowed"
      }
    },
    283 => %{
      name: "Referral Status",
      codes: %{
        "A" => "Accepted",
        "E" => "Expired",
        "P" => "Pending",
        "R" => "Rejected",
        "W" => "Withdrawn"
      }
    },
    286 => %{
      name: "Provider Role",
      codes: %{
        "CP" => "Consulting Provider",
        "PP" => "Primary Care Provider",
        "RP" => "Referring Provider",
        "RT" => "Referred to Provider"
      }
    },
    287 => %{
      name: "Problem/Goal Action Code",
      codes: %{
        "AD" => "ADD",
        "CO" => "CORRECT",
        "DE" => "DELETE",
        "LI" => "LINK",
        "UC" => "UNCHANGED",
        "UN" => "UNLINK",
        "UP" => "UPDATE"
      }
    },
    291 => %{
      name: "Subtype of Referenced Data",
      codes: %{
        "BASIC" => "ISDN PCM audio data",
        "DICOM" => "Digital Imaging and Communications in Medicine",
        "FAX" => "Facsimile data",
        "GIF" => "GIF image data",
        "HTML" => "Hypertext Markup Language",
        "JOT" => "Electronic ink data (Jot 1.0 standard)",
        "JPEG" => "Joint Photographic Experts Group",
        "Octet-stream" => "Uninterpreted binary data",
        "PICT" => "PICT format image data",
        "PostScript" => "PostScript program",
        "RTF" => "Rich Text Format",
        "SGML" => "SGML data",
        "TIFF" => "TIFF image data",
        "XML" => "Extensible Markup Language",
        "x-hl7-cda-level-one" => "HL7 Clinical Document Architecture Level One document"
      }
    },
    294 => %{
      name: "Time Selection Criteria Parameter Class Codes",
      codes: %{
        "FRI" => "An indicator that Friday is or is not preferred for the day",
        "MON" => "An indicator that Monday is or is not preferred for the day",
        "PREFEND" => "The preferred end time for the appointment request",
        "PREFSTART" => "The preferred start time for the appointment request",
        "SAT" => "An indicator that Saturday is or is not preferred for the day",
        "SUN" => "An indicator that Sunday is or is not preferred for the day",
        "THU" => "An indicator that Thursday is or is not preferred for the day",
        "TUE" => "An indicator that Tuesday is or is not preferred for the day",
        "WED" => "An indicator that Wednesday is or is not preferred for the day"
      }
    },
    295 => %{
      name: "Handicap",
      codes: %{
        "1" => "Disabled",
        "2" => "Hearing impaired",
        "3" => "Speech impaired",
        "4" => "Vision impaired",
        "5" => "Mentally impaired",
        "6" => "Mobility impaired",
        "0" => "Not handicapped",
        "U" => "Unknown"
      }
    },
    299 => %{
      name: "Encoding",
      codes: %{
        "A" => "No encoding - data are displayable ASCII characters",
        "Base64" =>
          "Encoding as defined by MIME (Multipurpose Internet Mail Extensions) standard RFC 1521",
        "Hex" => "Hexadecimal encoding"
      }
    },
    301 => %{
      name: "Universal ID Type",
      codes: %{
        "CLIA" => "Clinical Laboratory Improvement Amendments",
        "CLIP" => "Clinical Laboratory Improvement Program",
        "DNS" => "An Internet dotted name (RFC 1034)",
        "EUI64" => "IEEE 64-bit Extended Unique Identifier",
        "GUID" => "Globally Unique Identifier (same as UUID)",
        "HCD" => "CEN Healthcare Coding Identifier",
        "HL7" => "HL7 registration schemes",
        "ISO" => "An International Standards Organization Object Identifier",
        "L" => "Local",
        "L,M,N" => "Local, Machine, Network",
        "M" => "Machine",
        "N" => "Network",
        "Random" => "Random (usually a GU type)",
        "URI" => "Uniform Resource Identifier",
        "UUID" => "Universally Unique Identifier (DCE)",
        "x400" => "An X.400 MHS format identifier",
        "x500" => "An X.500 directory name"
      }
    },
    322 => %{
      name: "Completion Status",
      codes: %{
        "CP" => "Complete",
        "NA" => "Not Administered",
        "PA" => "Partially Administered",
        "RE" => "Refused"
      }
    },
    323 => %{
      name: "Action Code",
      codes: %{
        "A" => "Add/Insert",
        "D" => "Delete",
        "U" => "Update"
      }
    },
    324 => %{
      name: "Location Characteristic ID",
      codes: %{
        "GEN" => "Gender of patient(s)",
        "IMP" => "Implant: can be used for radiation implant patients",
        "INF" => "Infectious disease: this location can be used for isolation",
        "LCR" => "Level of care",
        "LIC" => "Licensed",
        "OVR" => "Overflow",
        "PRL" => "Privacy level: indicating the level of private versus non-private room",
        "SET" => "Bed is set up",
        "SHA" => "Shadow: a temporary holding location that does not physically exist",
        "SMK" => "Smoking",
        "STF" => "Bed is staffed",
        "TEA" => "Teaching location"
      }
    },
    326 => %{
      name: "Visit Indicator",
      codes: %{
        "A" => "Account level (default)",
        "V" => "Visit level"
      }
    },
    356 => %{
      name: "Alternate Character Set Handling Scheme",
      codes: %{
        "2.3" => "The character set switching mode specified in HL7 2.5, section 2.7.2",
        "ISO 2022-1994" =>
          "This standard is titled \"Information Technology - Character Code Structure and Extension Technique\"",
        "UNICODE UTF-8" => "UTF-8 Unicode Encoding"
      }
    },
    357 => %{
      name: "Message Error Condition Codes",
      codes: %{
        "0" => "Message accepted",
        "100" => "Segment sequence error",
        "101" => "Required field missing",
        "102" => "Data type error",
        "103" => "Table value not found",
        "200" => "Unsupported message type",
        "201" => "Unsupported event code",
        "202" => "Unsupported processing ID",
        "203" => "Unsupported version ID",
        "204" => "Unknown key identifier",
        "205" => "Duplicate key identifier",
        "206" => "Application record locked",
        "207" => "Application internal error"
      }
    },
    364 => %{
      name: "Comment Type",
      codes: %{
        "1D" => "1-dimensional bar code",
        "2D" => "2-dimensional bar code",
        "GI" => "General Instructions",
        "PI" => "Patient Instructions",
        "RE" => "Remark"
      }
    },
    365 => %{
      name: "Equipment State",
      codes: %{
        "CL" => "Clearing",
        "CO" => "Configuring",
        "DI" => "Diagnosed",
        "ES" => "E-stopped",
        "ID" => "Idle",
        "IN" => "Initializing",
        "MA" => "Maintenance",
        "OP" => "Normal Operation",
        "PA" => "Pausing",
        "PD" => "Paused",
        "PU" => "Powered Up",
        "RS" => "Ready to start",
        "SS" => "Sampling stopped",
        "TS" => "Transport stopped"
      }
    },
    395 => %{
      name: "Modify Indicator",
      codes: %{
        "M" => "Modified Subscription",
        "N" => "New Subscription"
      }
    },
    399 => %{
      name: "Country Code",
      codes: %{
        "ABW" => "Aruba",
        "AFG" => "Afghanistan",
        "AGO" => "Angola",
        "AIA" => "Anguilla",
        "ALB" => "Albania",
        "AND" => "Andorra",
        "ARE" => "United Arab Emirates",
        "ARG" => "Argentina",
        "ARM" => "Armenia",
        "AUS" => "Australia",
        "AUT" => "Austria",
        "AZE" => "Azerbaijan",
        "BEL" => "Belgium",
        "BGD" => "Bangladesh",
        "BGR" => "Bulgaria",
        "BHR" => "Bahrain",
        "BIH" => "Bosnia and Herzegovina",
        "BLR" => "Belarus",
        "BOL" => "Bolivia",
        "BRA" => "Brazil",
        "CAN" => "Canada",
        "CHE" => "Switzerland",
        "CHL" => "Chile",
        "CHN" => "China",
        "COL" => "Colombia",
        "CRI" => "Costa Rica",
        "CUB" => "Cuba",
        "CYP" => "Cyprus",
        "CZE" => "Czech Republic",
        "DEU" => "Germany",
        "DNK" => "Denmark",
        "DOM" => "Dominican Republic",
        "DZA" => "Algeria",
        "ECU" => "Ecuador",
        "EGY" => "Egypt",
        "ESP" => "Spain",
        "EST" => "Estonia",
        "ETH" => "Ethiopia",
        "FIN" => "Finland",
        "FRA" => "France",
        "GBR" => "United Kingdom",
        "GEO" => "Georgia",
        "GHA" => "Ghana",
        "GRC" => "Greece",
        "GTM" => "Guatemala",
        "HKG" => "Hong Kong",
        "HND" => "Honduras",
        "HRV" => "Croatia",
        "HTI" => "Haiti",
        "HUN" => "Hungary",
        "IDN" => "Indonesia",
        "IND" => "India",
        "IRL" => "Ireland",
        "IRN" => "Iran",
        "IRQ" => "Iraq",
        "ISL" => "Iceland",
        "ISR" => "Israel",
        "ITA" => "Italy",
        "JAM" => "Jamaica",
        "JOR" => "Jordan",
        "JPN" => "Japan",
        "KAZ" => "Kazakhstan",
        "KEN" => "Kenya",
        "KOR" => "Korea (Republic of)",
        "KWT" => "Kuwait",
        "LBN" => "Lebanon",
        "LBY" => "Libya",
        "LKA" => "Sri Lanka",
        "LTU" => "Lithuania",
        "LUX" => "Luxembourg",
        "LVA" => "Latvia",
        "MAR" => "Morocco",
        "MDA" => "Moldova",
        "MEX" => "Mexico",
        "MKD" => "North Macedonia",
        "MLT" => "Malta",
        "MMR" => "Myanmar",
        "MNE" => "Montenegro",
        "MNG" => "Mongolia",
        "MOZ" => "Mozambique",
        "MYS" => "Malaysia",
        "NGA" => "Nigeria",
        "NLD" => "Netherlands",
        "NOR" => "Norway",
        "NPL" => "Nepal",
        "NZL" => "New Zealand",
        "OMN" => "Oman",
        "PAK" => "Pakistan",
        "PAN" => "Panama",
        "PER" => "Peru",
        "PHL" => "Philippines",
        "POL" => "Poland",
        "PRI" => "Puerto Rico",
        "PRT" => "Portugal",
        "PRY" => "Paraguay",
        "QAT" => "Qatar",
        "ROU" => "Romania",
        "RUS" => "Russia",
        "SAU" => "Saudi Arabia",
        "SGP" => "Singapore",
        "SRB" => "Serbia",
        "SVK" => "Slovakia",
        "SVN" => "Slovenia",
        "SWE" => "Sweden",
        "THA" => "Thailand",
        "TUN" => "Tunisia",
        "TUR" => "Turkey",
        "TWN" => "Taiwan",
        "UKR" => "Ukraine",
        "URY" => "Uruguay",
        "USA" => "United States",
        "UZB" => "Uzbekistan",
        "VEN" => "Venezuela",
        "VNM" => "Vietnam",
        "ZAF" => "South Africa"
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
    },
    429 => %{
      name: "Production Class Code",
      codes: %{
        "BR" => "Breeding/genetic stock",
        "DA" => "Dairy",
        "DR" => "Draft",
        "DU" => "Dual Purpose",
        "LY" => "Layer, Includes Multiplier flocks",
        "MT" => "Meat",
        "NA" => "Not Applicable",
        "OT" => "Other",
        "PL" => "Pleasure",
        "RA" => "Racing",
        "SH" => "Show"
      }
    },
    516 => %{
      name: "Error Severity",
      codes: %{
        "E" => "Error",
        "F" => "Fatal Error",
        "I" => "Information",
        "W" => "Warning"
      }
    },
    517 => %{
      name: "Inform Person Code",
      codes: %{
        "HD" => "Help Desk",
        "NPP" => "Nursing Practice Partner",
        "PAT" => "Patient",
        "USR" => "User"
      }
    },
    520 => %{
      name: "Message Population",
      codes: %{
        "D" => "Dissemination",
        "E" => "Education",
        "H" => "Historical",
        "I" => "Initial population",
        "P" => "Persistent",
        "R" => "Representative"
      }
    },

    # --- Tables added for full ID field coverage ---

    27 => %{
      name: "Priority",
      codes: %{
        "A" => "As soon as possible",
        "P" => "Preoperative",
        "R" => "Routine",
        "S" => "Stat",
        "T" => "Timing critical"
      }
    },
    122 => %{
      name: "Charge Type",
      codes: %{
        "CH" => "Charge",
        "CO" => "Contract",
        "CR" => "Credit",
        "DP" => "Department",
        "GR" => "Grant",
        "NC" => "No Charge",
        "PC" => "Professional",
        "RS" => "Research"
      }
    },
    161 => %{
      name: "Allow Substitution",
      codes: %{
        "G" => "Allow generic substitutions",
        "N" => "Substitutions are NOT authorized",
        "T" => "Allow therapeutic substitutions"
      }
    },
    167 => %{
      name: "Substitution Status",
      codes: %{
        "0" => "No substitute was dispensed",
        "1" => "A pharmaceutical substance was dispensed as a therapeutic substitute",
        "2" => "A pharmaceutical substance was dispensed as a generic substitute",
        "3" => "A pharmaceutical substance was dispensed as a prescribed product",
        "4" => "A teletherapy was dispensed in place of mail order pharmacy",
        "5" => "A brand name was dispensed when the order called for generic",
        "7" => "A generic was dispensed when the order specified a different formulation",
        "8" => "A prescribed product was dispensed as a generic pharmaceutical substance"
      }
    },
    168 => %{
      name: "Processing Priority",
      codes: %{
        "A" => "As soon as possible (a]waiting)",
        "B" => "Do at bedside or portable (may also be used for outpatient)",
        "C" => "Measure continuously (e.g., arterial line blood pressure)",
        "P" => "Preoperative (to be done prior to surgery)",
        "R" => "Routine",
        "S" => "Stat (do immediately)",
        "T" => "Timing critical (do as near as possible to requested time)"
      }
    },
    169 => %{
      name: "Reporting Priority",
      codes: %{
        "C" => "Call back results",
        "R" => "Rush reporting"
      }
    },
    170 => %{
      name: "Derived Specimen",
      codes: %{
        "C" => "Child observation",
        "N" => "Not applicable",
        "P" => "Parent observation"
      }
    },
    187 => %{
      name: "Provider Billing",
      codes: %{
        "I" => "Institution bills for provider",
        "P" => "Provider does own billing"
      }
    },
    230 => %{
      name: "Procedure Functional Type",
      codes: %{
        "A" => "Anesthesia",
        "D" => "Diagnostic procedure",
        "I" => "Invasive procedure not classified elsewhere",
        "P" => "Procedure for treatment"
      }
    },
    235 => %{
      name: "Report Source",
      codes: %{
        "C" => "Clinical trial",
        "D" => "Database/registry/poison control center",
        "E" => "Distributor",
        "H" => "Health professional",
        "L" => "Literature",
        "M" => "Manufacturer/marketing authority holder",
        "N" => "Non-healthcare professional",
        "O" => "Other",
        "P" => "Patient",
        "R" => "Regulatory agency"
      }
    },
    236 => %{
      name: "Event Reported To",
      codes: %{
        "D" => "Distributor",
        "L" => "Local facility/user facility",
        "M" => "Manufacturer",
        "R" => "Regulatory agency"
      }
    },
    237 => %{
      name: "Event Qualification",
      codes: %{
        "A" => "Abuse",
        "B" => "Unexpected beneficial effect",
        "D" => "Dependency",
        "I" => "Interaction",
        "L" => "Lack of expect therapeutic effect",
        "M" => "Misuse",
        "O" => "Overdose",
        "W" => "Drug withdrawal"
      }
    },
    238 => %{
      name: "Event Seriousness",
      codes: %{
        "N" => "No",
        "S" => "Significant",
        "Y" => "Yes"
      }
    },
    239 => %{
      name: "Event Expected",
      codes: %{
        "N" => "No",
        "U" => "Unknown",
        "Y" => "Yes"
      }
    },
    240 => %{
      name: "Event Consequence",
      codes: %{
        "C" => "Congenital anomaly/birth defect",
        "D" => "Death",
        "H" => "Caused hospitalized",
        "I" => "Incapacity which is significant, persistent or permanent",
        "J" => "Disability which is significant, persistent or permanent",
        "L" => "Life threatening",
        "O" => "Other",
        "P" => "Prolonged hospitalization",
        "R" => "Required intervention to prevent permanent impairment/damage"
      }
    },
    241 => %{
      name: "Patient Outcome",
      codes: %{
        "D" => "Died",
        "F" => "Fully recovered",
        "N" => "Not recovering/unchanged",
        "R" => "Recovering",
        "S" => "Sequelae",
        "U" => "Unknown",
        "W" => "Worsening"
      }
    },
    242 => %{
      name: "Primary Observer's Qualification",
      codes: %{
        "C" => "Health care consumer/patient",
        "H" => "Other health professional",
        "L" => "Lawyer/attorney",
        "M" => "Mid-level professional (PA, NP, CNS, CNM)",
        "O" => "Other non-health professional",
        "P" => "Physician (osteopath, homeopath)",
        "R" => "Pharmacist"
      }
    },
    243 => %{
      name: "Identity May Be Divulged",
      codes: %{
        "N" => "No",
        "NA" => "Not applicable",
        "Y" => "Yes"
      }
    },
    246 => %{
      name: "Product Available for Inspection",
      codes: %{
        "N" => "No",
        "U" => "Unknown",
        "Y" => "Yes"
      }
    },
    247 => %{
      name: "Status of Evaluation",
      codes: %{
        "A" => "Evaluation anticipated, but not yet begun",
        "C" => "Product received in condition which made analysis impossible",
        "D" => "Product discarded -- Loss of product",
        "I" => "Product is involved but results are not yet available",
        "K" => "Problem already known, no evaluation necessary",
        "O" => "Other",
        "P" => "Evaluation in progress",
        "Q" => "Product not available for follow up investigation",
        "R" => "Product evaluated -- results given below",
        "U" => "Product not evaluated -- reason not specified",
        "X" => "Product not available for follow up investigation -- Loss of product",
        "Y" => "Product not evaluated (unable to evaluate)"
      }
    },
    248 => %{
      name: "Product Source",
      codes: %{
        "A" => "Actual product involved in incident was evaluated",
        "L" => "A product from the same lot as the actual product involved was evaluated",
        "N" => "A product from a controlled/non-related inventory was evaluated",
        "R" => "A product from a reserve sample was evaluated"
      }
    },
    250 => %{
      name: "Relatedness Assessment",
      codes: %{
        "H" => "Highly probable",
        "I" => "Improbable",
        "M" => "Moderately probable",
        "N" => "Not Related",
        "S" => "Somewhat probable"
      }
    },
    251 => %{
      name: "Action Taken in Response to the Event",
      codes: %{
        "DI" => "Product dose or frequency of use increased",
        "DR" => "Product dose or frequency of use reduced",
        "N" => "None",
        "OT" => "Other",
        "WP" => "Product withdrawn permanently",
        "WT" => "Product withdrawn temporarily"
      }
    },
    252 => %{
      name: "Causality Observations",
      codes: %{
        "AW" => "Abatement of event after product withdrawn",
        "BE" => "Event recurred after product reintroduced",
        "DR" => "Dose response observed",
        "EX" => "Alternative explanations for the event available",
        "IN" => "Event occurred after product introduced",
        "LI" => "Literature reports association of product with event",
        "OE" => "Occurrence of event was confirmed by objective evidence",
        "OT" => "Other",
        "PL" => "Effect observed when patient receives placebo",
        "SE" => "Similar events in past for this patient",
        "TC" => "Toxic levels of product documented in blood or body fluids"
      }
    },
    253 => %{
      name: "Indirect Exposure Mechanism",
      codes: %{
        "B" => "Breast milk",
        "F" => "Father",
        "O" => "Other",
        "P" => "Transplacental",
        "X" => "Blood product"
      }
    },
    257 => %{
      name: "Nature of Challenge",
      codes: %{
        "CFOOD" => "Fasting (no calorie intake) for the period specified",
        "FFOOD" => "No fluid intake for the period specified in the time component",
        "NFOOD" => "No food intake for the period specified",
        "OVRN" => "Overnight fast"
      }
    },
    331 => %{
      name: "Facility Type",
      codes: %{
        "A" => "Agent for a foreign manufacturer",
        "D" => "Distributor",
        "M" => "Manufacturer",
        "U" => "User"
      }
    },
    368 => %{
      name: "Remote Control Command",
      codes: %{
        "AB" => "Abort",
        "CL" => "Clear",
        "CN" => "Clear Notification",
        "DI" => "Disable Sending Events",
        "EN" => "Enable Sending Events",
        "ES" => "Emergency -Loss of Power/Stop",
        "EX" => "Execute (command specified in field)",
        "IN" => "Initialize/Initiate",
        "LC" => "Local Control Request",
        "LK" => "Lock",
        "LO" => "Load",
        "PA" => "Pause",
        "RC" => "Remote Control Request",
        "RE" => "Resume",
        "SA" => "Sampling",
        "SU" => "Setup",
        "TS" => "Transport",
        "UC" => "Unlock",
        "UN" => "Unload"
      }
    },
    472 => %{
      name: "TQ Conjunction ID",
      codes: %{
        "A" => "Separator: independent timing specs are separated by Asynchronous",
        "C" => "Actuation Time: the time the service should be started",
        "S" => "Synchronous: do not start until the previous one is completed"
      }
    },
    480 => %{
      name: "Pharmacy Order Types",
      codes: %{
        "M" => "Medication (default)",
        "O" => "Other solution as medication orders",
        "S" => "Supply"
      }
    },
    503 => %{
      name: "Sequence/Results Flag",
      codes: %{
        "C" => "Cyclical",
        "R" => "Reserved for possible future use",
        "S" => "Sequential"
      }
    },
    504 => %{
      name: "Sequence Condition Code",
      codes: %{
        "EE" => "End related start or end",
        "ES" => "End related start or start",
        "SE" => "Start related start or end",
        "SS" => "Start related start or start"
      }
    },
    505 => %{
      name: "Cyclic Entry/Exit Indicator",
      codes: %{
        "#" => "The last service request in a cyclic group",
        "*" => "The first service request in a cyclic group"
      }
    },
    506 => %{
      name: "Service Request Relationship",
      codes: %{
        "C" => "Compound",
        "E" => "Exclusive",
        "N" => "Nurse prerogative",
        "S" => "Simultaneous",
        "T" => "Tapering"
      }
    },
    249 => %{
      name: "Generic Product",
      codes: %{
        "N" => "No",
        "Y" => "Yes"
      }
    },
    270 => %{
      name: "Document Type",
      codes: %{
        "AR" => "Autopsy Report",
        "CD" => "Cardiodiagnostics",
        "CN" => "Consultation",
        "DI" => "Diagnostic Imaging",
        "DS" => "Discharge Summary",
        "ED" => "Emergency Department Report",
        "HP" => "History and Physical Examination",
        "OP" => "Operative Report",
        "PC" => "Psychiatric Consultation",
        "PH" => "Psychiatric History and Physical Examination",
        "PN" => "Procedure Note",
        "PR" => "Progress Note",
        "SP" => "Surgical Pathology",
        "TS" => "Transfer Summary"
      }
    },
    166 => %{
      name: "RX Component Type",
      codes: %{
        "A" => "Additive",
        "B" => "Base"
      }
    },
    159 => %{
      name: "Diet Code Specification Type",
      codes: %{
        "D" => "Diet",
        "P" => "Preference",
        "S" => "Supplement"
      }
    },
    183 => %{
      name: "Active/Inactive",
      codes: %{
        "A" => "Active Staff",
        "I" => "Inactive Staff"
      }
    },
    269 => %{
      name: "Charge On Indicator",
      codes: %{
        "O" => "Charge on Order",
        "R" => "Charge on Result"
      }
    },
    268 => %{
      name: "Override",
      codes: %{
        "A" => "Override allowed",
        "R" => "Override required",
        "X" => "Override not allowed"
      }
    },
    336 => %{
      name: "Referral Reason",
      codes: %{
        "O" => "Provider Ordered",
        "P" => "Patient Preference",
        "S" => "Second Opinion"
      }
    },
    335 => %{
      name: "Repeat Pattern",
      codes: %{
        "A" => "Ante (before)",
        "BID" => "twice a day at institution-specified times",
        "C" => "service is provided continuously between start time and stop time",
        "D" => "Cibus Diurnus (lunch)",
        "M" => "Cibus Matutinus (breakfast)",
        "P" => "Post (after)",
        "PRN" => "given as needed",
        "Q1H" => "every hour",
        "Q2H" => "every 2 hours",
        "Q3H" => "every 3 hours",
        "Q4H" => "every 4 hours",
        "Q6H" => "every 6 hours",
        "Q8H" => "every 8 hours",
        "QAM" => "in the morning at institution-specified time",
        "QD" => "every day",
        "QHS" => "every day before the hour of sleep",
        "QID" => "four times a day at institution-specified times",
        "QOD" => "every other day",
        "QPM" => "in the evening at institution-specified time",
        "TID" => "three times a day at institution-specified times",
        "V" => "Cibus Vespertinus (dinner)"
      }
    },
    330 => %{
      name: "Marketing Basis",
      codes: %{
        "510K" => "510 (K)",
        "510KE" => "510 (K) Exempt",
        "PMA" => "Premarket Authorization",
        "PRE" => "Preamendment",
        "TXN" => "Transitional"
      }
    },
    261 => %{
      name: "Location Equipment",
      codes: %{
        "INF" => "Infusion pump",
        "IVP" => "IV pump",
        "OXY" => "Oxygen",
        "SUC" => "Suction",
        "VEN" => "Ventilator"
      }
    },
    532 => %{
      name: "Expanded Yes/No Indicator",
      codes: %{
        "ASKU" => "Asked but Unknown",
        "N" => "No",
        "NA" => "Not applicable",
        "NASK" => "Not Asked",
        "NI" => "No Information",
        "QS" => "Quantity Sufficient",
        "TRC" => "Trace",
        "UNK" => "Unknown",
        "Y" => "Yes"
      }
    },
    259 => %{
      name: "Modality",
      codes: %{
        "AS" => "Angioscopy",
        "BS" => "Biomagnetic imaging",
        "CD" => "Color flow Doppler",
        "CP" => "Colposcopy",
        "CR" => "Computed Radiography",
        "CS" => "Cystoscopy",
        "CT" => "Computed Tomography",
        "DD" => "Duplex Doppler",
        "DG" => "Diapanography",
        "DM" => "Digital Microscopy",
        "EC" => "Echocardiography",
        "ES" => "Endoscopy",
        "FA" => "Fluorescein Angiography",
        "FS" => "Fundoscopy",
        "LP" => "Laparoscopy",
        "LS" => "Laser surface scan",
        "MA" => "Magnetic Resonance Angiography",
        "MR" => "Magnetic Resonance",
        "MS" => "Magnetic Resonance Spectroscopy",
        "NM" => "Nuclear Medicine (Radioisotope study)",
        "OT" => "Other",
        "PT" => "Positron Emission Tomography (PET)",
        "RF" => "Radio Fluoroscopy",
        "ST" => "Single Photon Emission Computed Tomography (SPECT)",
        "TG" => "Thermography",
        "US" => "Ultrasound",
        "XA" => "X-Ray Angiography"
      }
    },
    508 => %{
      name: "Blood Product Processing Requirements",
      codes: %{
        "AU" => "Autologous Unit",
        "CM" => "CMV Negative",
        "CS" => "CMV Safe",
        "DI" => "Directed Unit",
        "FR" => "Fresh unit",
        "HB" => "Hemoglobin S Negative",
        "HL" => "HLA Matched",
        "IG" => "IgA Deficient",
        "IR" => "Irradiated",
        "LR" => "Leukoreduced",
        "WA" => "Washed"
      }
    },
    511 => %{
      name: "BP Observation Status Codes Interpretation",
      codes: %{
        "C" => "Record coming over is a correction and replaces a final status",
        "D" => "Deletes the BPX record",
        "F" => "Final status; can only be changed with a corrected status",
        "O" => "Order detail description only (no status)",
        "P" => "Preliminary status",
        "W" => "Post original as wrong, e.g., transmitted for wrong patient"
      }
    },
    513 => %{
      name: "Blood Product Transfusion/Disposition Status",
      codes: %{
        "RA" => "Returned unused/no longer needed",
        "RL" => "Returned unused/linked to patient",
        "TR" => "Transfused with adverse reaction",
        "TX" => "Transfused",
        "WA" => "Wasted (product no longer viable)"
      }
    },
    509 => %{
      name: "Consent Identifier",
      codes: %{
        "ALT" => "Alternate (second) opinion",
        "CON" => "Consent given",
        "DEN" => "Denial of consent",
        "LIM" => "Consent with limitation(s)",
        "OPT" => "Opt out",
        "RCV" => "Consent received",
        "WDR" => "Withdrawn/revocation of prior consent"
      }
    },
    498 => %{
      name: "Consent Status",
      codes: %{
        "A" => "Active — Consent has been granted",
        "B" => "Bypassed (Consent not sought)",
        "L" => "Limited — Consent has been granted with limitations",
        "P" => "Pending — Consent has not yet been sought",
        "R" => "Refused — Consent has been refused",
        "X" => "Rescinded — Consent was initially granted, but was subsequently revoked or ended"
      }
    },
    499 => %{
      name: "Consent Bypass Reason",
      codes: %{
        "E" => "Emergency",
        "PJ" => "Professional Judgment"
      }
    },
    497 => %{
      name: "Consent Type",
      codes: %{
        "001" =>
          "Release of Information/MR / Authorization to Disclosure Protected Health Information",
        "002" => "Medical Procedure (Invasive)",
        "003" => "Acknowledge Receipt of Privacy Notice",
        "004" => "Abortion",
        "005" => "Organ Donation",
        "006" => "Brain Death Determination Procedure",
        "007" => "Immunization",
        "008" => "Medical Treatment (Incl. Surgery/Anesthesia)"
      }
    },
    500 => %{
      name: "Consent Disclosure Level",
      codes: %{
        "F" => "Full Disclosure",
        "N" => "No Disclosure",
        "P" => "Partial Disclosure"
      }
    },
    501 => %{
      name: "Consent Non-Disclosure Reason",
      codes: %{
        "E" => "Emergency",
        "PI" => "Patient Request - information only",
        "RX" => "Patient Request - no further discussion"
      }
    },
    502 => %{
      name: "Non-Subject Consenter Reason",
      codes: %{
        "LM" => "Legally mandated",
        "MIN" => "Subject is a minor",
        "NC" => "Subject is not competent to consent"
      }
    },
    495 => %{
      name: "Body Site Modifier",
      codes: %{
        "ANT" => "Anterior",
        "BIL" => "Bilateral",
        "DIS" => "Distal",
        "EXT" => "External",
        "L" => "Left",
        "LAT" => "Lateral",
        "LLQ" => "Quadrant, Left Lower",
        "LOW" => "Lower",
        "LUQ" => "Quadrant, Left Upper",
        "MED" => "Medial",
        "POS" => "Posterior",
        "PRO" => "Proximal",
        "R" => "Right",
        "RLQ" => "Quadrant, Right Lower",
        "RUQ" => "Quadrant, Right Upper",
        "SUP" => "Superior",
        "UPP" => "Upper"
      }
    },
    507 => %{
      name: "Observation Result Handling",
      codes: %{
        "F" => "Film-with-patient",
        "N" => "Notify provider when ready"
      }
    },
    106 => %{
      name: "Query/Response Format Code",
      codes: %{
        "D" => "Response is in display format",
        "R" => "Response is in record-oriented format",
        "T" => "Response is in tabular format"
      }
    },
    107 => %{
      name: "Deferred Response Type",
      codes: %{
        "B" => "Before the Date/Time specified",
        "L" => "Later than the Date/Time specified"
      }
    },
    108 => %{
      name: "Query Results Level",
      codes: %{
        "O" => "Order plus order status",
        "R" => "Results without bulk text",
        "S" => "Status only",
        "T" => "Full results"
      }
    },
    109 => %{
      name: "Report Priority",
      codes: %{
        "R" => "Routine",
        "S" => "Stat"
      }
    },
    124 => %{
      name: "Transportation Mode",
      codes: %{
        "CART" => "Cart - Loss of Ambulatory",
        "PORT" => "The ambulatory patient requires a wheelchair to enter building",
        "WALK" => "Patient will walk to/from Lab",
        "WHLC" => "Wheelchair"
      }
    },
    156 => %{
      name: "Which Date/Time Qualifier",
      codes: %{
        "ANY" => "Any date/time within a range",
        "COL" => "Collection date/time, equivalent to film or study date",
        "ORD" => "Order date/time",
        "RCT" => "Specimen receipt date/time, receipt of specimen in filling lab",
        "REP" => "Report date/time",
        "SCHED" => "Schedule date/time"
      }
    },
    157 => %{
      name: "Which Date/Time Status Qualifier",
      codes: %{
        "ANY" => "Any status",
        "CFN" => "Current final value, whether or not final has been set",
        "COR" => "Corrected only (no strays)",
        "FIN" => "Final only (no corrections)",
        "PRE" => "Preliminary",
        "REP" => "Report completion date/time"
      }
    },
    158 => %{
      name: "Date/Time Selection Qualifier",
      codes: %{
        "1ST" => "First value within range",
        "ALL" => "All values within the range",
        "LST" => "Last value within the range",
        "REV" => "All values within the range returned in reverse chronological order"
      }
    },
    178 => %{
      name: "File Level Event Code",
      codes: %{
        "REP" =>
          "Replace current version of this master file with the version contained in this message",
        "UPD" => "Change file records as defined in the record-level event codes for each record"
      }
    },
    179 => %{
      name: "Response Level Code",
      codes: %{
        "AL" => "Always. All MFA segments (Acknowledgment Record Errors in MFN/MFK)",
        "ER" => "Error/Reject conditions only. Only MFA segments denoting errors",
        "NE" => "Never. No MFA segments",
        "SU" => "Success. Only MFA segments denoting success"
      }
    },
    191 => %{
      name: "Type of Referenced Data",
      codes: %{
        "AP" => "Other application data (typically uninterpreted binary data)",
        "AU" => "Audio data",
        "FT" => "Formatted text",
        "IM" => "Image data",
        "multipart" => "MIME multipart package",
        "NS" => "Non-scanned image (continuous tone)",
        "SD" => "Scanned document (group 4 fax)",
        "SI" => "Scanned image (2-color lineart)",
        "TEXT" => "Machine readable text document"
      }
    },
    224 => %{
      name: "Transport Arranged",
      codes: %{
        "A" => "Arranged",
        "N" => "Not Arranged",
        "U" => "Unknown"
      }
    },
    225 => %{
      name: "Escort Required",
      codes: %{
        "N" => "Not Required",
        "R" => "Required",
        "U" => "Unknown"
      }
    },
    321 => %{
      name: "Dispense Method",
      codes: %{
        "AD" => "Automatic Dispensing",
        "F" => "Floor Stock",
        "TR" => "Traditional",
        "UD" => "Unit Dose"
      }
    },
    329 => %{
      name: "Quantity Method",
      codes: %{
        "AD" => "Actual count",
        "EX" => "Extrapolated from history"
      }
    },
    332 => %{
      name: "Source Type",
      codes: %{
        "A" => "Accept",
        "I" => "Initiate"
      }
    },
    355 => %{
      name: "Primary Key Value Type",
      codes: %{
        "CE" => "Coded element",
        "PL" => "Person location"
      }
    },
    359 => %{
      name: "Diagnosis Priority",
      codes: %{
        "0" => "Not included in diagnosis ranking",
        "1" => "The primary diagnosis",
        "2" => "For ranked secondary diagnoses"
      }
    },
    398 => %{
      name: "Continuation Style Code",
      codes: %{
        "F" => "Fragmentation",
        "I" => "Interactive Continuation"
      }
    },
    418 => %{
      name: "Procedure Priority",
      codes: %{
        "0" => "The admitting procedure",
        "1" => "The primary procedure",
        "2" => "For ranked secondary procedures"
      }
    },
    53 => %{
      name: "Diagnosis Coding Method",
      codes: %{
        "I9" => "ICD-9",
        "I9C" => "ICD-9-CM",
        "I10" => "ICD-10"
      }
    },
    348 => %{
      name: "Special Program Code",
      codes: %{
        "01" => "EPSDT-CHAP",
        "02" => "Physically Handicapped Children's Program",
        "03" => "Special Federal Funding",
        "04" => "Family Planning",
        "05" => "Disability",
        "06" => "PPV/Medicare 100% Payment",
        "07" => "Induced Abortion-Danger to Life",
        "08" => "Induced Abortion Victim Rape/Incest",
        "09" => "Second Opinion or Surgery"
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
