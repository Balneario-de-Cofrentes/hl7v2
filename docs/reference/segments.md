# HL7 v2.5.1 Segment Definitions Reference

Field-by-field definitions for 13 of the 21 standard HL7 v2.5.1 segments implemented in
HL7v2 integration. Source: HL7 v2.5.1 standard via Caristix HL7-Definition.

**Usage codes:** R = Required, O = Optional, C = Conditional, B = Backward compatible (retained for backward compatibility), W = Withdrawn, X = Not used

**Repetition:** 1 = single, \* = unbounded repeating, N = max N repetitions, - = not repeatable

---

## 1. MSH -- Message Header

Defines the intent, source, destination, and syntax specifics of a message.
Every HL7v2 message begins with MSH. Chapter: Control (CH\_02).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| MSH.1 | Field Separator | 1 | ST | R | 1 | | Always `\|` |
| MSH.2 | Encoding Characters | 4 | ST | R | 1 | | Default `^~\&` |
| MSH.3 | Sending Application | 227 | HD | O | 1 | 0361 | |
| MSH.4 | Sending Facility | 227 | HD | O | 1 | 0362 | |
| MSH.5 | Receiving Application | 227 | HD | O | 1 | 0361 | |
| MSH.6 | Receiving Facility | 227 | HD | O | 1 | 0362 | |
| MSH.7 | Date/Time Of Message | 26 | TS | R | 1 | | YYYYMMDDHHMMSS[.SSSS][+/-ZZZZ] |
| MSH.8 | Security | 40 | ST | O | 1 | | |
| MSH.9 | Message Type | 15 | MSG | R | 1 | | Components: Message Code^Trigger Event^Message Structure |
| MSH.10 | Message Control ID | 20 | ST | R | 1 | | Unique per message |
| MSH.11 | Processing ID | 3 | PT | R | 1 | | P=Production, D=Debug, T=Training |
| MSH.12 | Version ID | 60 | VID | R | 1 | | "2.5.1" |
| MSH.13 | Sequence Number | 15 | NM | O | 1 | | |
| MSH.14 | Continuation Pointer | 180 | ST | O | 1 | | |
| MSH.15 | Accept Acknowledgment Type | 2 | ID | O | 1 | 0155 | AL/NE/ER/SU |
| MSH.16 | Application Acknowledgment Type | 2 | ID | O | 1 | 0155 | AL/NE/ER/SU |
| MSH.17 | Country Code | 3 | ID | O | 1 | 0399 | ISO 3166 |
| MSH.18 | Character Set | 16 | ID | O | * | 0211 | e.g. ASCII, 8859/1, UNICODE UTF-8 |
| MSH.19 | Principal Language Of Message | 250 | CE | O | 1 | | |
| MSH.20 | Alternate Character Set Handling Scheme | 20 | ID | O | 1 | 0356 | |
| MSH.21 | Message Profile Identifier | 427 | EI | O | * | | |

---

## 2. PID -- Patient Identification

Primary means of communicating patient identification and demographics.
Contains permanent patient identifying information. Chapter: Patient Administration (CH\_03).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| PID.1 | Set ID - PID | 4 | SI | O | 1 | | |
| PID.2 | Patient ID | 20 | CX | B | 1 | | Retained for backward compatibility |
| PID.3 | Patient Identifier List | 250 | CX | R | * | | Primary patient identifiers (MRN, etc.) |
| PID.4 | Alternate Patient ID - PID | 20 | CX | B | * | | Retained for backward compatibility |
| PID.5 | Patient Name | 250 | XPN | R | * | | Legal name first |
| PID.6 | Mother's Maiden Name | 250 | XPN | O | * | | |
| PID.7 | Date/Time of Birth | 26 | TS | O | 1 | | |
| PID.8 | Administrative Sex | 1 | IS | O | 1 | 0001 | F/M/O/U/A/N |
| PID.9 | Patient Alias | 250 | XPN | B | * | | Retained for backward compatibility |
| PID.10 | Race | 250 | CE | O | * | 0005 | |
| PID.11 | Patient Address | 250 | XAD | O | * | | |
| PID.12 | County Code | 4 | IS | B | 1 | 0289 | Use PID.11 instead |
| PID.13 | Phone Number - Home | 250 | XTN | O | * | | |
| PID.14 | Phone Number - Business | 250 | XTN | O | * | | |
| PID.15 | Primary Language | 250 | CE | O | 1 | 0296 | |
| PID.16 | Marital Status | 250 | CE | O | 1 | 0002 | |
| PID.17 | Religion | 250 | CE | O | 1 | 0006 | |
| PID.18 | Patient Account Number | 250 | CX | O | 1 | | |
| PID.19 | SSN Number - Patient | 16 | ST | B | 1 | | Use PID.3 instead |
| PID.20 | Driver's License Number - Patient | 25 | DLN | B | 1 | | Use PID.3 instead |
| PID.21 | Mother's Identifier | 250 | CX | O | * | | |
| PID.22 | Ethnic Group | 250 | CE | O | * | 0189 | |
| PID.23 | Birth Place | 250 | ST | O | 1 | | |
| PID.24 | Multiple Birth Indicator | 1 | ID | O | 1 | 0136 | Y/N |
| PID.25 | Birth Order | 2 | NM | O | 1 | | |
| PID.26 | Citizenship | 250 | CE | O | * | 0171 | |
| PID.27 | Veterans Military Status | 250 | CE | O | 1 | 0172 | |
| PID.28 | Nationality | 250 | CE | B | 1 | 0212 | |
| PID.29 | Patient Death Date and Time | 26 | TS | O | 1 | | |
| PID.30 | Patient Death Indicator | 1 | ID | O | 1 | 0136 | Y/N |
| PID.31 | Identity Unknown Indicator | 1 | ID | O | 1 | 0136 | Y/N |
| PID.32 | Identity Reliability Code | 20 | IS | O | * | 0445 | |
| PID.33 | Last Update Date/Time | 26 | TS | O | 1 | | |
| PID.34 | Last Update Facility | 241 | HD | O | 1 | | |
| PID.35 | Species Code | 250 | CE | C | 1 | 0446 | Veterinary use |
| PID.36 | Breed Code | 250 | CE | C | 1 | 0447 | Veterinary use |
| PID.37 | Strain | 80 | ST | O | 1 | | Veterinary use |
| PID.38 | Production Class Code | 250 | CE | O | 2 | 0429 | Veterinary use |
| PID.39 | Tribal Citizenship | 250 | CWE | O | * | 0171 | |

---

## 3. PV1 -- Patient Visit

Communicates visit-specific or account-specific information.
Chapter: Patient Administration (CH\_03).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| PV1.1 | Set ID - PV1 | 4 | SI | O | 1 | | |
| PV1.2 | Patient Class | 1 | IS | R | 1 | 0004 | E=Emergency, I=Inpatient, O=Outpatient, etc. |
| PV1.3 | Assigned Patient Location | 80 | PL | O | 1 | | Point of care^Room^Bed^Facility |
| PV1.4 | Admission Type | 2 | IS | O | 1 | 0007 | |
| PV1.5 | Preadmit Number | 250 | CX | O | 1 | | |
| PV1.6 | Prior Patient Location | 80 | PL | O | 1 | | |
| PV1.7 | Attending Doctor | 250 | XCN | O | * | 0010 | |
| PV1.8 | Referring Doctor | 250 | XCN | O | * | 0010 | |
| PV1.9 | Consulting Doctor | 250 | XCN | B | * | 0010 | Use ROL segment instead |
| PV1.10 | Hospital Service | 3 | IS | O | 1 | 0069 | |
| PV1.11 | Temporary Location | 80 | PL | O | 1 | | |
| PV1.12 | Preadmit Test Indicator | 2 | IS | O | 1 | 0087 | |
| PV1.13 | Re-admission Indicator | 2 | IS | O | 1 | 0092 | |
| PV1.14 | Admit Source | 6 | IS | O | 1 | 0023 | |
| PV1.15 | Ambulatory Status | 2 | IS | O | * | 0009 | |
| PV1.16 | VIP Indicator | 2 | IS | O | 1 | 0099 | |
| PV1.17 | Admitting Doctor | 250 | XCN | O | * | 0010 | |
| PV1.18 | Patient Type | 2 | IS | O | 1 | 0018 | |
| PV1.19 | Visit Number | 250 | CX | O | 1 | | |
| PV1.20 | Financial Class | 50 | FC | O | * | | |
| PV1.21 | Charge Price Indicator | 2 | IS | O | 1 | 0032 | |
| PV1.22 | Courtesy Code | 2 | IS | O | 1 | 0045 | |
| PV1.23 | Credit Rating | 2 | IS | O | 1 | 0046 | |
| PV1.24 | Contract Code | 2 | IS | O | * | 0044 | |
| PV1.25 | Contract Effective Date | 8 | DT | O | * | | |
| PV1.26 | Contract Amount | 12 | NM | O | * | | |
| PV1.27 | Contract Period | 3 | NM | O | * | | |
| PV1.28 | Interest Code | 2 | IS | O | 1 | 0073 | |
| PV1.29 | Transfer to Bad Debt Code | 4 | IS | O | 1 | 0110 | |
| PV1.30 | Transfer to Bad Debt Date | 8 | DT | O | 1 | | |
| PV1.31 | Bad Debt Agency Code | 10 | IS | O | 1 | 0021 | |
| PV1.32 | Bad Debt Transfer Amount | 12 | NM | O | 1 | | |
| PV1.33 | Bad Debt Recovery Amount | 12 | NM | O | 1 | | |
| PV1.34 | Delete Account Indicator | 1 | IS | O | 1 | 0111 | |
| PV1.35 | Delete Account Date | 8 | DT | O | 1 | | |
| PV1.36 | Discharge Disposition | 3 | IS | O | 1 | 0112 | |
| PV1.37 | Discharged to Location | 47 | DLD | O | 1 | | |
| PV1.38 | Diet Type | 250 | CE | O | 1 | 0114 | |
| PV1.39 | Servicing Facility | 2 | IS | O | 1 | 0115 | |
| PV1.40 | Bed Status | 1 | IS | B | 1 | 0116 | Retained for backward compatibility |
| PV1.41 | Account Status | 2 | IS | O | 1 | 0117 | |
| PV1.42 | Pending Location | 80 | PL | O | 1 | | |
| PV1.43 | Prior Temporary Location | 80 | PL | O | 1 | | |
| PV1.44 | Admit Date/Time | 26 | TS | O | 1 | | |
| PV1.45 | Discharge Date/Time | 26 | TS | O | * | | |
| PV1.46 | Current Patient Balance | 12 | NM | O | 1 | | |
| PV1.47 | Total Charges | 12 | NM | O | 1 | | |
| PV1.48 | Total Adjustments | 12 | NM | O | 1 | | |
| PV1.49 | Total Payments | 12 | NM | O | 1 | | |
| PV1.50 | Alternate Visit ID | 250 | CX | O | 1 | | |
| PV1.51 | Visit Indicator | 1 | IS | O | 1 | 0326 | |
| PV1.52 | Other Healthcare Provider | 250 | XCN | B | * | 0010 | Use ROL segment instead |

---

## 4. OBR -- Observation Request

Transmits information specific to an order for a diagnostic study, observation,
physical exam, or assessment. Chapter: Order Entry (CH\_04).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| OBR.1 | Set ID - OBR | 4 | SI | O | 1 | | |
| OBR.2 | Placer Order Number | 22 | EI | C | 1 | | Required if known to placer |
| OBR.3 | Filler Order Number | 22 | EI | C | 1 | | Required if known to filler |
| OBR.4 | Universal Service Identifier | 250 | CE | R | 1 | | Identifies the observation/test |
| OBR.5 | Priority - OBR | 2 | ID | B | 1 | | Use OBR.27 instead |
| OBR.6 | Requested Date/Time | 26 | TS | B | 1 | | Use OBR.27 instead |
| OBR.7 | Observation Date/Time | 26 | TS | C | 1 | | Clinically relevant date/time |
| OBR.8 | Observation End Date/Time | 26 | TS | O | 1 | | |
| OBR.9 | Collection Volume | 20 | CQ | O | 1 | | |
| OBR.10 | Collector Identifier | 250 | XCN | O | * | | |
| OBR.11 | Specimen Action Code | 1 | ID | O | 1 | 0065 | |
| OBR.12 | Danger Code | 250 | CE | O | 1 | | |
| OBR.13 | Relevant Clinical Information | 300 | ST | O | 1 | | |
| OBR.14 | Specimen Received Date/Time | 26 | TS | B | 1 | | |
| OBR.15 | Specimen Source | 300 | SPS | B | 1 | | Use SPM segment instead |
| OBR.16 | Ordering Provider | 250 | XCN | O | * | | |
| OBR.17 | Order Callback Phone Number | 250 | XTN | O | 2 | | |
| OBR.18 | Placer Field 1 | 60 | ST | O | 1 | | |
| OBR.19 | Placer Field 2 | 60 | ST | O | 1 | | |
| OBR.20 | Filler Field 1 | 60 | ST | O | 1 | | |
| OBR.21 | Filler Field 2 | 60 | ST | O | 1 | | |
| OBR.22 | Results Rpt/Status Chng - Date/Time | 26 | TS | C | 1 | | Required for results |
| OBR.23 | Charge to Practice | 40 | MOC | O | 1 | | |
| OBR.24 | Diagnostic Serv Sect ID | 10 | ID | O | 1 | 0074 | RAD, LAB, etc. |
| OBR.25 | Result Status | 1 | ID | C | 1 | 0123 | F=Final, P=Preliminary, C=Corrected |
| OBR.26 | Parent Result | 400 | PRL | O | 1 | | Links child to parent result |
| OBR.27 | Quantity/Timing | 200 | TQ | B | * | | Replaced by TQ1/TQ2 in v2.5 |
| OBR.28 | Result Copies To | 250 | XCN | O | * | | |
| OBR.29 | Parent | 200 | EIP | O | 1 | | Parent order reference |
| OBR.30 | Transportation Mode | 20 | ID | O | 1 | 0124 | |
| OBR.31 | Reason for Study | 250 | CE | O | * | | |
| OBR.32 | Principal Result Interpreter | 200 | NDL | O | 1 | | |
| OBR.33 | Assistant Result Interpreter | 200 | NDL | O | * | | |
| OBR.34 | Technician | 200 | NDL | O | * | | |
| OBR.35 | Transcriptionist | 200 | NDL | O | * | | |
| OBR.36 | Scheduled Date/Time | 26 | TS | O | 1 | | |
| OBR.37 | Number of Sample Containers | 4 | NM | O | 1 | | |
| OBR.38 | Transport Logistics of Collected Sample | 250 | CE | O | * | | |
| OBR.39 | Collector's Comment | 250 | CE | O | * | | |
| OBR.40 | Transport Arrangement Responsibility | 250 | CE | O | 1 | | |
| OBR.41 | Transport Arranged | 30 | ID | O | 1 | 0224 | |
| OBR.42 | Escort Required | 1 | ID | O | 1 | 0225 | |
| OBR.43 | Planned Patient Transport Comment | 250 | CE | O | * | | |
| OBR.44 | Procedure Code | 250 | CE | O | 1 | 0088 | |
| OBR.45 | Procedure Code Modifier | 250 | CE | O | * | 0340 | |
| OBR.46 | Placer Supplemental Service Information | 250 | CE | O | * | 0411 | |
| OBR.47 | Filler Supplemental Service Information | 250 | CE | O | * | 0411 | |
| OBR.48 | Medically Necessary Duplicate Procedure Reason | 250 | CWE | C | 1 | 0476 | |
| OBR.49 | Result Handling | 2 | IS | O | 1 | 0507 | |
| OBR.50 | Parent Universal Service Identifier | 250 | CWE | O | 1 | | |

---

## 5. OBX -- Observation/Result

Carries a single clinical observation or result value.
One OBX per observation. Chapter: Observation Reporting (CH\_07).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| OBX.1 | Set ID - OBX | 4 | SI | O | 1 | | |
| OBX.2 | Value Type | 2 | ID | C | 1 | 0125 | NM, ST, CE, TX, FT, CWE, SN, ED, etc. |
| OBX.3 | Observation Identifier | 250 | CE | R | 1 | | LOINC code recommended |
| OBX.4 | Observation Sub-ID | 20 | ST | C | 1 | | Distinguishes repeating OBX groups |
| OBX.5 | Observation Value | 99999 | VARIES | C | * | | Type determined by OBX.2 |
| OBX.6 | Units | 250 | CE | O | 1 | | UCUM recommended |
| OBX.7 | References Range | 60 | ST | O | 1 | | e.g. "3.5-5.5" |
| OBX.8 | Abnormal Flags | 5 | IS | O | * | 0078 | L/H/LL/HH/A/AA/N |
| OBX.9 | Probability | 5 | NM | O | 1 | | 0-1 range |
| OBX.10 | Nature of Abnormal Test | 2 | ID | O | * | 0080 | |
| OBX.11 | Observation Result Status | 1 | ID | R | 1 | 0085 | F=Final, P=Preliminary, C=Corrected, X=Deleted |
| OBX.12 | Effective Date of Reference Range | 26 | TS | O | 1 | | |
| OBX.13 | User Defined Access Checks | 20 | ST | O | 1 | | |
| OBX.14 | Date/Time of the Observation | 26 | TS | O | 1 | | |
| OBX.15 | Producer's ID | 250 | CE | O | 1 | | Lab/device that produced result |
| OBX.16 | Responsible Observer | 250 | XCN | O | * | | |
| OBX.17 | Observation Method | 250 | CE | O | * | | |
| OBX.18 | Equipment Instance Identifier | 22 | EI | O | * | | |
| OBX.19 | Date/Time of the Analysis | 26 | TS | O | 1 | | |
| OBX.20 | Reserved for harmonization with V2.6 | 0 | ST | X | 1 | | Not used in v2.5.1 |
| OBX.21 | Reserved for harmonization with V2.6 | 0 | ST | X | 1 | | Not used in v2.5.1 |
| OBX.22 | Reserved for harmonization with V2.6 | 0 | ST | X | 1 | | Not used in v2.5.1 |
| OBX.23 | Performing Organization Name | 567 | XON | O | 1 | | |
| OBX.24 | Performing Organization Address | 631 | XAD | O | 1 | | |
| OBX.25 | Performing Organization Medical Director | 3002 | XCN | O | 1 | | |

---

## 6. ORC -- Common Order

Transmits fields common to all orders. Accompanies order-specific segments
like OBR. Chapter: Order Entry (CH\_04).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| ORC.1 | Order Control | 2 | ID | R | 1 | 0119 | NW=New, CA=Cancel, SC=Status Changed, etc. |
| ORC.2 | Placer Order Number | 22 | EI | C | 1 | | |
| ORC.3 | Filler Order Number | 22 | EI | C | 1 | | |
| ORC.4 | Placer Group Number | 22 | EI | O | 1 | | |
| ORC.5 | Order Status | 2 | ID | O | 1 | 0038 | |
| ORC.6 | Response Flag | 1 | ID | O | 1 | 0121 | |
| ORC.7 | Quantity/Timing | 200 | TQ | B | * | | Replaced by TQ1/TQ2 |
| ORC.8 | Parent Order | 200 | EIP | O | 1 | | |
| ORC.9 | Date/Time of Transaction | 26 | TS | O | 1 | | |
| ORC.10 | Entered By | 250 | XCN | O | * | | |
| ORC.11 | Verified By | 250 | XCN | O | * | | |
| ORC.12 | Ordering Provider | 250 | XCN | O | * | | |
| ORC.13 | Enterer's Location | 80 | PL | O | 1 | | |
| ORC.14 | Call Back Phone Number | 250 | XTN | O | 2 | | |
| ORC.15 | Order Effective Date/Time | 26 | TS | O | 1 | | |
| ORC.16 | Order Control Code Reason | 250 | CE | O | 1 | | |
| ORC.17 | Entering Organization | 250 | CE | O | 1 | | |
| ORC.18 | Entering Device | 250 | CE | O | 1 | | |
| ORC.19 | Action By | 250 | XCN | O | * | | |
| ORC.20 | Advanced Beneficiary Notice Code | 250 | CE | O | 1 | 0339 | |
| ORC.21 | Ordering Facility Name | 250 | XON | O | * | | |
| ORC.22 | Ordering Facility Address | 250 | XAD | O | * | | |
| ORC.23 | Ordering Facility Phone Number | 250 | XTN | O | * | | |
| ORC.24 | Ordering Provider Address | 250 | XAD | O | * | | |
| ORC.25 | Order Status Modifier | 250 | CWE | O | 1 | | |
| ORC.26 | Advanced Beneficiary Notice Override Reason | 60 | CWE | C | 1 | 0552 | |
| ORC.27 | Filler's Expected Availability Date/Time | 26 | TS | O | 1 | | |
| ORC.28 | Confidentiality Code | 250 | CWE | O | 1 | 0177 | |
| ORC.29 | Order Type | 250 | CWE | O | 1 | 0482 | |
| ORC.30 | Enterer Authorization Mode | 250 | CNE | O | 1 | 0483 | |
| ORC.31 | Parent Universal Service Identifier | 250 | CWE | O | 1 | | |

---

## 7. EVN -- Event Type

Communicates trigger event information. Chapter: Patient Administration (CH\_03).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| EVN.1 | Event Type Code | 3 | ID | B | 1 | 0003 | Retained; use MSH.9 instead |
| EVN.2 | Recorded Date/Time | 26 | TS | R | 1 | | When event was recorded |
| EVN.3 | Date/Time Planned Event | 26 | TS | O | 1 | | |
| EVN.4 | Event Reason Code | 3 | IS | O | 1 | 0062 | |
| EVN.5 | Operator ID | 250 | XCN | O | * | 0188 | |
| EVN.6 | Event Occurred | 26 | TS | O | 1 | | When event actually occurred |
| EVN.7 | Event Facility | 241 | HD | O | 1 | | |

---

## 8. NK1 -- Next of Kin / Associated Parties

Information about related persons (next of kin, emergency contacts,
guarantors, employers). Chapter: Patient Administration (CH\_03).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| NK1.1 | Set ID - NK1 | 4 | SI | R | 1 | | |
| NK1.2 | NK Name | 250 | XPN | O | * | | |
| NK1.3 | Relationship | 250 | CE | O | 1 | 0063 | |
| NK1.4 | Address | 250 | XAD | O | * | | |
| NK1.5 | Phone Number | 250 | XTN | O | * | | |
| NK1.6 | Business Phone Number | 250 | XTN | O | * | | |
| NK1.7 | Contact Role | 250 | CE | O | 1 | 0131 | |
| NK1.8 | Start Date | 8 | DT | O | 1 | | |
| NK1.9 | End Date | 8 | DT | O | 1 | | |
| NK1.10 | Job Title | 60 | ST | O | 1 | | |
| NK1.11 | Job Code/Class | 20 | JCC | O | 1 | | |
| NK1.12 | Employee Number | 250 | CX | O | 1 | | |
| NK1.13 | Organization Name - NK1 | 250 | XON | O | * | | |
| NK1.14 | Marital Status | 250 | CE | O | 1 | 0002 | |
| NK1.15 | Administrative Sex | 1 | IS | O | 1 | 0001 | |
| NK1.16 | Date/Time of Birth | 26 | TS | O | 1 | | |
| NK1.17 | Living Dependency | 2 | IS | O | * | 0223 | |
| NK1.18 | Ambulatory Status | 2 | IS | O | * | 0009 | |
| NK1.19 | Citizenship | 250 | CE | O | * | 0171 | |
| NK1.20 | Primary Language | 250 | CE | O | 1 | 0296 | |
| NK1.21 | Living Arrangement | 2 | IS | O | 1 | 0220 | |
| NK1.22 | Publicity Code | 250 | CE | O | 1 | 0215 | |
| NK1.23 | Protection Indicator | 1 | ID | O | 1 | 0136 | Y/N |
| NK1.24 | Student Indicator | 2 | IS | O | 1 | 0231 | |
| NK1.25 | Religion | 250 | CE | O | 1 | 0006 | |
| NK1.26 | Mother's Maiden Name | 250 | XPN | O | * | | |
| NK1.27 | Nationality | 250 | CE | O | 1 | 0212 | |
| NK1.28 | Ethnic Group | 250 | CE | O | * | 0189 | |
| NK1.29 | Contact Reason | 250 | CE | O | * | 0222 | |
| NK1.30 | Contact Person's Name | 250 | XPN | O | * | | |
| NK1.31 | Contact Person's Telephone Number | 250 | XTN | O | * | | |
| NK1.32 | Contact Person's Address | 250 | XAD | O | * | | |
| NK1.33 | Next of Kin/Associated Party's Identifiers | 250 | CX | O | * | | |
| NK1.34 | Job Status | 2 | IS | O | 1 | 0311 | |
| NK1.35 | Race | 250 | CE | O | * | 0005 | |
| NK1.36 | Handicap | 2 | IS | O | 1 | 0295 | |
| NK1.37 | Contact Person Social Security Number | 16 | ST | O | 1 | | |
| NK1.38 | Next of Kin Birth Place | 250 | ST | O | 1 | | |
| NK1.39 | VIP Indicator | 2 | IS | O | 1 | 0099 | |

---

## 9. MSA -- Message Acknowledgment

Returns acknowledgment status for a received message. Chapter: Control (CH\_02).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| MSA.1 | Acknowledgment Code | 2 | ID | R | 1 | 0008 | AA=Accept, AE=Error, AR=Reject, CA/CE/CR |
| MSA.2 | Message Control ID | 20 | ST | R | 1 | | Must echo MSH.10 of incoming msg |
| MSA.3 | Text Message | 80 | ST | B | 1 | | Use ERR segment instead |
| MSA.4 | Expected Sequence Number | 15 | NM | O | 1 | | |
| MSA.5 | Delayed Acknowledgment Type | 0 | ST | W | 1 | | Withdrawn |
| MSA.6 | Error Condition | 250 | CE | B | 1 | 0357 | Use ERR segment instead |

---

## 10. ERR -- Error

Provides detailed error information for acknowledgment messages.
Replaces MSA.3/MSA.6 in v2.5+. Chapter: Control (CH\_02).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| ERR.1 | Error Code and Location | 493 | ELD | B | * | | Retained for backward compat; use ERR.2+ |
| ERR.2 | Error Location | 18 | ERL | O | * | | Segment^Sequence^Field^Rep^Component^SubComponent |
| ERR.3 | HL7 Error Code | 705 | CWE | R | 1 | 0357 | |
| ERR.4 | Severity | 2 | ID | R | 1 | 0516 | E=Error, W=Warning, I=Information |
| ERR.5 | Application Error Code | 705 | CWE | O | 1 | 0533 | |
| ERR.6 | Application Error Parameter | 80 | ST | O | 10 | | |
| ERR.7 | Diagnostic Information | 2048 | TX | O | 1 | | |
| ERR.8 | User Message | 250 | TX | O | 1 | | Human-readable error description |
| ERR.9 | Inform Person Indicator | 20 | IS | O | * | 0517 | |
| ERR.10 | Override Type | 705 | CWE | O | 1 | 0518 | |
| ERR.11 | Override Reason Code | 705 | CWE | O | * | 0519 | |
| ERR.12 | Help Desk Contact Point | 652 | XTN | O | * | | |

---

## 11. NTE -- Notes and Comments

Free-text notes that can follow many segment types. Chapter: Patient
Administration (CH\_02).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| NTE.1 | Set ID - NTE | 4 | SI | O | 1 | | |
| NTE.2 | Source of Comment | 8 | ID | O | 1 | 0105 | L=Ancillary, P=Placer, O=Other |
| NTE.3 | Comment | 65536 | FT | O | * | | Free text, may repeat for multi-line |
| NTE.4 | Comment Type | 250 | CE | O | 1 | 0364 | PI=Patient Instructions, AI=Ancillary Instructions |

---

## 12. AL1 -- Patient Allergy Information

Patient allergy information. Chapter: Patient Administration (CH\_03).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| AL1.1 | Set ID - AL1 | 4 | SI | R | 1 | | |
| AL1.2 | Allergen Type Code | 250 | CE | O | 1 | 0127 | DA=Drug, FA=Food, EA=Environmental, etc. |
| AL1.3 | Allergen Code/Mnemonic/Description | 250 | CE | R | 1 | | |
| AL1.4 | Allergy Severity Code | 250 | CE | O | 1 | 0128 | SV=Severe, MO=Moderate, MI=Mild, U=Unknown |
| AL1.5 | Allergy Reaction Code | 15 | ST | O | * | | |
| AL1.6 | Identification Date | 8 | DT | B | 1 | | |

---

## 13. DG1 -- Diagnosis

Diagnosis information for the patient. Chapter: Patient Administration (CH\_06).

| Seq | Field Name | Len | DT | Opt | Rep | Table | Notes |
|-----|-----------|-----|-----|-----|-----|-------|-------|
| DG1.1 | Set ID - DG1 | 4 | SI | R | 1 | | |
| DG1.2 | Diagnosis Coding Method | 2 | ID | B | 1 | 0053 | Retained for backward compatibility |
| DG1.3 | Diagnosis Code - DG1 | 250 | CE | O | 1 | 0051 | ICD-10 or local code |
| DG1.4 | Diagnosis Description | 40 | ST | B | 1 | | Use DG1.3 text component instead |
| DG1.5 | Diagnosis Date/Time | 26 | TS | O | 1 | | |
| DG1.6 | Diagnosis Type | 2 | IS | R | 1 | 0052 | A=Admitting, W=Working, F=Final |
| DG1.7 | Major Diagnostic Category | 250 | CE | B | 1 | 0118 | |
| DG1.8 | Diagnostic Related Group | 250 | CE | B | 1 | 0055 | |
| DG1.9 | DRG Approval Indicator | 1 | ID | B | 1 | 0136 | |
| DG1.10 | DRG Grouper Review Code | 2 | IS | B | 1 | 0056 | |
| DG1.11 | Outlier Type | 250 | CE | B | 1 | 0083 | |
| DG1.12 | Outlier Days | 3 | NM | B | 1 | | |
| DG1.13 | Outlier Cost | 12 | CP | B | 1 | | |
| DG1.14 | Grouper Version And Type | 4 | ST | B | 1 | | |
| DG1.15 | Diagnosis Priority | 2 | ID | O | 1 | 0359 | 0=Not included in ranking, 1=Primary, 2+=Secondary |
| DG1.16 | Diagnosing Clinician | 250 | XCN | O | * | | |
| DG1.17 | Diagnosis Classification | 3 | IS | O | 1 | 0228 | |
| DG1.18 | Confidential Indicator | 1 | ID | O | 1 | 0136 | Y/N |
| DG1.19 | Attestation Date/Time | 26 | TS | O | 1 | | |
| DG1.20 | Diagnosis Identifier | 427 | EI | C | 1 | | |
| DG1.21 | Diagnosis Action Code | 1 | ID | C | 1 | 0206 | A=Add, D=Delete, U=Update |

---

## Appendix A: Key Composite Data Types (Components)

Fields with composite data types contain components separated by `^` and
sub-components separated by `&`. This appendix lists the component
breakdowns for the most-used composites.

### HD -- Hierarchic Designator

Used in MSH.3-6, EVN.7, PID.34, etc.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | Namespace ID | IS | O | 20 |
| 2 | Universal ID | ST | C | 199 |
| 3 | Universal ID Type | ID | C | 6 |

HD.2 and HD.3 are conditional: both must be valued together, or both null.
Common Universal ID Types: DNS, UUID, ISO (OID), URI.

### MSG -- Message Type

Used in MSH.9.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | Message Code | ID | R | 3 |
| 2 | Trigger Event | ID | R | 3 |
| 3 | Message Structure | ID | R | 7 |

Example: `ADT^A01^ADT_A01`

### CE -- Coded Element

Used in PID.10, PID.15-17, OBR.4, OBX.3, OBX.6, AL1.2-4, DG1.3, etc.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | Identifier | ST | O | 20 |
| 2 | Text | ST | O | 199 |
| 3 | Name of Coding System | ID | O | 20 |
| 4 | Alternate Identifier | ST | O | 20 |
| 5 | Alternate Text | ST | O | 199 |
| 6 | Name of Alternate Coding System | ID | O | 20 |

Example: `784.0^Headache^I9CDX`

### CWE -- Coded with Exceptions

Used in ORC.25-26,28-31, OBR.48,50, ERR.3,5,10,11, PID.39, etc.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | Identifier | ST | O | 20 |
| 2 | Text | ST | O | 199 |
| 3 | Name of Coding System | ID | O | 20 |
| 4 | Alternate Identifier | ST | O | 20 |
| 5 | Alternate Text | ST | O | 199 |
| 6 | Name of Alternate Coding System | ID | O | 20 |
| 7 | Coding System Version ID | ST | C | 10 |
| 8 | Alternate Coding System Version ID | ST | O | 10 |
| 9 | Original Text | ST | O | 199 |

CWE extends CE with version info and original text.

### CX -- Extended Composite ID with Check Digit

Used in PID.2-5,18,21, PV1.5,19,50, NK1.12,33, etc.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | ID Number | ST | R | 15 |
| 2 | Check Digit | ST | O | 1 |
| 3 | Check Digit Scheme | ID | O | 3 |
| 4 | Assigning Authority | HD | O | 227 |
| 5 | Identifier Type Code | ID | O | 5 |
| 6 | Assigning Facility | HD | O | 227 |
| 7 | Effective Date | DT | O | 8 |
| 8 | Expiration Date | DT | O | 8 |
| 9 | Assigning Jurisdiction | CWE | O | 705 |
| 10 | Assigning Agency or Department | CWE | O | 705 |

CX.4 (Assigning Authority) is itself an HD, creating sub-components:
`ID^Check^Scheme^NS&UID&UIDType^TypeCode`

### XPN -- Extended Person Name

Used in PID.5-6,9, NK1.2,26,30, etc.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | Family Name | FN | O | 194 |
| 2 | Given Name | ST | O | 30 |
| 3 | Second and Further Given Names | ST | O | 30 |
| 4 | Suffix (e.g., Jr or III) | ST | O | 20 |
| 5 | Prefix (e.g., Dr) | ST | O | 20 |
| 6 | Degree (e.g., MD) | IS | B | 6 |
| 7 | Name Type Code | ID | O | 1 |
| 8 | Name Representation Code | ID | O | 1 |
| 9 | Name Context | CE | O | 483 |
| 10 | Name Validity Range | DR | B | 53 |
| 11 | Name Assembly Order | ID | O | 1 |
| 12 | Effective Date | TS | O | 26 |
| 13 | Expiration Date | TS | O | 26 |
| 14 | Professional Suffix | ST | O | 199 |

FN (Family Name) sub-components: Surname^Own Surname Prefix^Own Surname^
Surname Prefix From Partner^Surname From Partner.

### XCN -- Extended Composite ID Number and Name for Persons

Used in PV1.7-9,17,52, OBR.10,16,28,32-35, ORC.10-12,19, EVN.5,
OBX.16,25, DG1.16, etc.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | ID Number | ST | O | 15 |
| 2 | Family Name | FN | O | 194 |
| 3 | Given Name | ST | O | 30 |
| 4 | Second and Further Given Names | ST | O | 30 |
| 5 | Suffix (e.g., Jr or III) | ST | O | 20 |
| 6 | Prefix (e.g., Dr) | ST | O | 20 |
| 7 | Degree (e.g., MD) | IS | B | 5 |
| 8 | Source Table | IS | C | 4 |
| 9 | Assigning Authority | HD | O | 227 |
| 10 | Name Type Code | ID | O | 1 |
| 11 | Identifier Check Digit | ST | O | 1 |
| 12 | Check Digit Scheme | ID | C | 3 |
| 13 | Identifier Type Code | ID | O | 5 |
| 14 | Assigning Facility | HD | O | 227 |
| 15 | Name Representation Code | ID | O | 1 |
| 16 | Name Context | CE | O | 483 |
| 17 | Name Validity Range | DR | B | 53 |
| 18 | Name Assembly Order | ID | O | 1 |
| 19 | Effective Date | TS | O | 26 |
| 20 | Expiration Date | TS | O | 26 |
| 21 | Professional Suffix | ST | O | 199 |
| 22 | Assigning Jurisdiction | CWE | O | 705 |
| 23 | Assigning Agency or Department | CWE | O | 705 |

### XAD -- Extended Address

Used in PID.11, NK1.4,32, ORC.22,24, OBX.24, etc.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | Street Address | SAD | O | 184 |
| 2 | Other Designation | ST | O | 120 |
| 3 | City | ST | O | 50 |
| 4 | State or Province | ST | O | 50 |
| 5 | Zip or Postal Code | ST | O | 12 |
| 6 | Country | ID | O | 3 |
| 7 | Address Type | ID | O | 3 |
| 8 | Other Geographic Designation | ST | O | 50 |
| 9 | County/Parish Code | IS | O | 20 |
| 10 | Census Tract | IS | O | 20 |
| 11 | Address Representation Code | ID | O | 1 |
| 12 | Address Validity Range | DR | B | 53 |
| 13 | Effective Date | TS | O | 26 |
| 14 | Expiration Date | TS | O | 26 |

SAD (Street Address) sub-components: Street or Mailing Address^Street Name^
Dwelling Number.

### XTN -- Extended Telecommunication Number

Used in PID.13-14, NK1.5-6,31, OBR.17, ORC.14,23, ERR.12.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | Telephone Number | ST | B | 199 |
| 2 | Telecommunication Use Code | ID | O | 3 |
| 3 | Telecommunication Equipment Type | ID | O | 8 |
| 4 | Email Address | ST | O | 199 |
| 5 | Country Code | NM | O | 3 |
| 6 | Area/City Code | NM | O | 5 |
| 7 | Local Number | NM | O | 9 |
| 8 | Extension | NM | O | 5 |
| 9 | Any Text | ST | O | 199 |
| 10 | Extension Prefix | ST | O | 4 |
| 11 | Speed Dial Code | ST | O | 6 |
| 12 | Unformatted Telephone Number | ST | C | 199 |

### EI -- Entity Identifier

Used in OBR.2-3, ORC.2-4, OBX.18, MSH.21, DG1.20, etc.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | Entity Identifier | ST | O | 199 |
| 2 | Namespace ID | IS | O | 20 |
| 3 | Universal ID | ST | C | 199 |
| 4 | Universal ID Type | ID | C | 6 |

### PL -- Person Location

Used in PV1.3,6,11,42-43, ORC.13.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | Point of Care | IS | O | 20 |
| 2 | Room | IS | O | 20 |
| 3 | Bed | IS | O | 20 |
| 4 | Facility | HD | O | 227 |
| 5 | Location Status | IS | O | 20 |
| 6 | Person Location Type | IS | C | 20 |
| 7 | Building | IS | O | 20 |
| 8 | Floor | IS | O | 20 |
| 9 | Location Description | ST | O | 199 |
| 10 | Comprehensive Location Identifier | EI | O | 427 |
| 11 | Assigning Authority for Location | HD | O | 227 |

### ERL -- Error Location

Used in ERR.2.

| # | Component | DT | Opt | Len |
|---|----------|-----|-----|-----|
| 1 | Segment ID | ST | R | 3 |
| 2 | Segment Sequence | NM | R | 2 |
| 3 | Field Position | NM | O | 2 |
| 4 | Field Repetition | NM | O | 2 |
| 5 | Component Number | NM | O | 2 |
| 6 | Sub-Component Number | NM | O | 2 |

---

## Appendix B: Primitive Data Types Quick Reference

| DT | Name | Description |
|----|------|-------------|
| ST | String Data | Printable ASCII, no formatting |
| TX | Text Data | String with optional formatting (may contain escape sequences) |
| FT | Formatted Text | Text with HL7 formatting commands (\\.br\\, \\.sp\\, etc.) |
| NM | Numeric | Decimal number (optional leading sign, optional decimal point) |
| SI | Sequence ID | Non-negative integer for Set ID fields |
| ID | Coded Value (HL7 table) | Value from an HL7-defined table |
| IS | Coded Value (User table) | Value from a user-defined table |
| DT | Date | YYYY[MM[DD]] |
| TS | Time Stamp | YYYY[MM[DD[HH[MM[SS[.S[S[S[S]]]]]]]]][+/-ZZZZ] |
| DR | Date/Time Range | Start TS ^ End TS |

---

*Source: HL7 v2.5.1 standard, verified against Caristix HL7-Definition
(https://hl7-definition.caristix.com/v2/HL7v2.5.1/Segments/). All field
sequence numbers, data types, lengths, optionalities, and repetition
flags extracted from the Caristix v2 API.*
