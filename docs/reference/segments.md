# HL7 v2.5.1 Segment Definitions Reference

Field-by-field definitions for all 152 typed segments
in the HL7 v2.5.1 standard as implemented by this library.

**Generated from code metadata** -- do not edit by hand.
Run `mix hl7v2.gen_docs` to regenerate.

**Optionality codes:** R = Required, O = Optional, C = Conditional, B = Backward compatible

**Repetition:** 1 = single, * = unbounded repeating

---

## ABS -- Abstract

13 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ABS.1 | Discharge Care Provider | XCN | O | 1 |
| ABS.2 | Transfer Medical Service Code | CE | O | 1 |
| ABS.3 | Severity Of Illness Code | CE | O | 1 |
| ABS.4 | Date Time Of Attestation | TS | O | 1 |
| ABS.5 | Attested By | XCN | O | 1 |
| ABS.6 | Triage Code | CE | O | 1 |
| ABS.7 | Abstract Completion Date Time | TS | O | 1 |
| ABS.8 | Abstracted By | XCN | O | 1 |
| ABS.9 | Case Category Code | CE | O | 1 |
| ABS.10 | Caesarian Section Indicator | ID | O | 1 |
| ABS.11 | Gestation Category Code | CE | O | 1 |
| ABS.12 | Gestation Period Weeks | NM | O | 1 |
| ABS.13 | Newborn Code | CE | O | 1 |

---

## ACC -- Accident

11 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ACC.1 | Accident Date Time | TS | O | 1 |
| ACC.2 | Accident Code | CE | O | 1 |
| ACC.3 | Accident Location | ST | O | 1 |
| ACC.4 | Auto Accident State | CE | O | 1 |
| ACC.5 | Accident Job Related Indicator | ID | O | 1 |
| ACC.6 | Accident Death Indicator | ID | O | 1 |
| ACC.7 | Entered By | XCN | O | 1 |
| ACC.8 | Accident Description | ST | O | 1 |
| ACC.9 | Brought In By | ST | O | 1 |
| ACC.10 | Police Notified Indicator | ID | O | 1 |
| ACC.11 | Accident Address | XAD | O | 1 |

---

## ADD -- Addendum

1 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ADD.1 | Addendum Continuation Pointer | ST | O | 1 |

---

## AFF -- Professional Affiliation

5 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| AFF.1 | Set Id | SI | R | 1 |
| AFF.2 | Professional Organization | XON | R | 1 |
| AFF.3 | Professional Organization Address | XAD | O | 1 |
| AFF.4 | Professional Organization Affiliation Date Range | DR | O | * |
| AFF.5 | Professional Affiliation Additional Information | ST | O | 1 |

---

## AIG -- Appointment Information — General Resource

14 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| AIG.1 | Set Id | SI | R | 1 |
| AIG.2 | Segment Action Code | ID | C | 1 |
| AIG.3 | Resource Id | CE | O | 1 |
| AIG.4 | Resource Type | CE | R | 1 |
| AIG.5 | Resource Group | CE | O | * |
| AIG.6 | Resource Quantity | NM | O | 1 |
| AIG.7 | Resource Quantity Units | CE | O | 1 |
| AIG.8 | Start Date Time | TS | O | 1 |
| AIG.9 | Start Date Time Offset | NM | O | 1 |
| AIG.10 | Start Date Time Offset Units | CE | O | 1 |
| AIG.11 | Duration | NM | O | 1 |
| AIG.12 | Duration Units | CE | O | 1 |
| AIG.13 | Allow Substitution Code | IS | O | 1 |
| AIG.14 | Filler Status Code | CE | O | 1 |

---

## AIL -- Appointment Information — Location Resource

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| AIL.1 | Set Id | SI | R | 1 |
| AIL.2 | Segment Action Code | ID | C | 1 |
| AIL.3 | Location Resource Id | PL | O | * |
| AIL.4 | Location Type | CE | O | 1 |
| AIL.5 | Location Group | CE | O | 1 |
| AIL.6 | Start Date Time | TS | O | 1 |
| AIL.7 | Start Date Time Offset | NM | O | 1 |
| AIL.8 | Start Date Time Offset Units | CE | O | 1 |
| AIL.9 | Duration | NM | O | 1 |
| AIL.10 | Duration Units | CE | O | 1 |
| AIL.11 | Allow Substitution Code | IS | O | 1 |
| AIL.12 | Filler Status Code | CE | O | 1 |

---

## AIP -- Appointment Information — Personnel Resource

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| AIP.1 | Set Id | SI | R | 1 |
| AIP.2 | Segment Action Code | ID | C | 1 |
| AIP.3 | Personnel Resource Id | XCN | O | * |
| AIP.4 | Resource Type | CE | O | 1 |
| AIP.5 | Resource Group | CE | O | 1 |
| AIP.6 | Start Date Time | TS | O | 1 |
| AIP.7 | Start Date Time Offset | NM | O | 1 |
| AIP.8 | Start Date Time Offset Units | CE | O | 1 |
| AIP.9 | Duration | NM | O | 1 |
| AIP.10 | Duration Units | CE | O | 1 |
| AIP.11 | Allow Substitution Code | IS | O | 1 |
| AIP.12 | Filler Status Code | CE | O | 1 |

---

## AIS -- Appointment Information — Service

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| AIS.1 | Set Id | SI | R | 1 |
| AIS.2 | Segment Action Code | ID | C | 1 |
| AIS.3 | Universal Service Identifier | CE | R | 1 |
| AIS.4 | Start Date Time | TS | O | 1 |
| AIS.5 | Start Date Time Offset | NM | O | 1 |
| AIS.6 | Start Date Time Offset Units | CE | O | 1 |
| AIS.7 | Duration | NM | O | 1 |
| AIS.8 | Duration Units | CE | O | 1 |
| AIS.9 | Allow Substitution Code | IS | O | 1 |
| AIS.10 | Filler Status Code | CE | O | 1 |
| AIS.11 | Placer Supplemental Service Information | CE | O | * |
| AIS.12 | Filler Supplemental Service Information | CE | O | * |

---

## AL1 -- Patient Allergy Information

6 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| AL1.1 | Set Id | SI | R | 1 |
| AL1.2 | Allergen Type Code | CE | O | 1 |
| AL1.3 | Allergen Code | CE | R | 1 |
| AL1.4 | Allergy Severity Code | CE | O | 1 |
| AL1.5 | Allergy Reaction Code | ST | O | * |
| AL1.6 | Identification Date | DT | B | 1 |

---

## APR -- Appointment Preferences

5 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| APR.1 | Time Selection Criteria | SCV | O | * |
| APR.2 | Resource Selection Criteria | SCV | O | * |
| APR.3 | Location Selection Criteria | SCV | O | * |
| APR.4 | Slot Spacing Criteria | NM | O | 1 |
| APR.5 | Filler Override Criteria | SCV | O | * |

---

## ARQ -- Appointment Request

25 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ARQ.1 | Placer Appointment Id | EI | R | 1 |
| ARQ.2 | Filler Appointment Id | EI | C | 1 |
| ARQ.3 | Occurrence Number | NM | O | 1 |
| ARQ.4 | Placer Group Number | EI | O | 1 |
| ARQ.5 | Schedule Id | CE | O | 1 |
| ARQ.6 | Request Event Reason | CE | O | 1 |
| ARQ.7 | Appointment Reason | CE | O | 1 |
| ARQ.8 | Appointment Type | CE | O | 1 |
| ARQ.9 | Appointment Duration | NM | O | 1 |
| ARQ.10 | Appointment Duration Units | CE | O | 1 |
| ARQ.11 | Requested Start Date Time Range | DR | O | * |
| ARQ.12 | Priority Arq | ST | O | 1 |
| ARQ.13 | Repeating Interval | RI | O | 1 |
| ARQ.14 | Repeating Interval Duration | ST | O | 1 |
| ARQ.15 | Placer Contact Person | XCN | R | * |
| ARQ.16 | Placer Contact Phone Number | XTN | O | * |
| ARQ.17 | Placer Contact Address | XAD | O | * |
| ARQ.18 | Placer Contact Location | PL | O | 1 |
| ARQ.19 | Entered By Person | XCN | R | * |
| ARQ.20 | Entered By Phone Number | XTN | O | * |
| ARQ.21 | Entered By Location | PL | O | 1 |
| ARQ.22 | Parent Placer Appointment Id | EI | O | 1 |
| ARQ.23 | Parent Filler Appointment Id | EI | O | 1 |
| ARQ.24 | Placer Order Number | EI | O | * |
| ARQ.25 | Filler Order Number | EI | O | * |

---

## AUT -- Authorization Information

10 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| AUT.1 | Authorizing Payor Plan Id | CE | O | 1 |
| AUT.2 | Authorizing Payor Company Id | CE | R | 1 |
| AUT.3 | Authorizing Payor Company Name | ST | O | 1 |
| AUT.4 | Authorization Effective Date | TS | O | 1 |
| AUT.5 | Authorization Expiration Date | TS | O | 1 |
| AUT.6 | Authorization Identifier | EI | O | 1 |
| AUT.7 | Reimbursement Limit | CP | O | 1 |
| AUT.8 | Requested Number Of Treatments | NM | O | 1 |
| AUT.9 | Authorized Number Of Treatments | NM | O | 1 |
| AUT.10 | Process Date | TS | O | 1 |

---

## BHS -- Batch Header

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| BHS.1 | Batch Field Separator | ST | R | 1 |
| BHS.2 | Batch Encoding Characters | ST | R | 1 |
| BHS.3 | Batch Sending Application | HD | O | 1 |
| BHS.4 | Batch Sending Facility | HD | O | 1 |
| BHS.5 | Batch Receiving Application | HD | O | 1 |
| BHS.6 | Batch Receiving Facility | HD | O | 1 |
| BHS.7 | Batch Creation Date Time | TS | O | 1 |
| BHS.8 | Batch Security | ST | O | 1 |
| BHS.9 | Batch Name Type Id | ST | O | 1 |
| BHS.10 | Batch Comment | ST | O | 1 |
| BHS.11 | Batch Control Id | ST | O | 1 |
| BHS.12 | Reference Batch Control Id | ST | O | 1 |

---

## BLC -- Blood Code

2 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| BLC.1 | Blood Product Code | CE | O | 1 |
| BLC.2 | Blood Amount | CQ | O | 1 |

---

## BLG -- Billing

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| BLG.1 | When To Charge | CCD | O | 1 |
| BLG.2 | Charge Type | ID | O | 1 |
| BLG.3 | Account Id | CX | O | 1 |

---

## BPO -- Blood Product Order

14 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| BPO.1 | Set Id | SI | R | 1 |
| BPO.2 | Bp Universal Service Id | CWE | R | 1 |
| BPO.3 | Bp Processing Requirements | CWE | O | * |
| BPO.4 | Bp Quantity | NM | R | 1 |
| BPO.5 | Bp Amount | NM | O | 1 |
| BPO.6 | Bp Units | CE | O | 1 |
| BPO.7 | Bp Intended Use Date Time | TS | O | 1 |
| BPO.8 | Bp Intended Dispense From Location | PL | O | 1 |
| BPO.9 | Bp Intended Dispense From Address | XAD | O | 1 |
| BPO.10 | Bp Requested Dispense Date Time | TS | O | 1 |
| BPO.11 | Bp Requested Dispense To Location | PL | O | 1 |
| BPO.12 | Bp Requested Dispense To Address | XAD | O | 1 |
| BPO.13 | Bp Indication For Use | CWE | O | * |
| BPO.14 | Bp Informed Consent Indicator | ID | O | 1 |

---

## BPX -- Blood Product Dispense Status

21 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| BPX.1 | Set Id | SI | R | 1 |
| BPX.2 | Bp Dispense Status | CWE | R | 1 |
| BPX.3 | Bp Status | ID | R | 1 |
| BPX.4 | Bp Date Time Of Status | TS | R | 1 |
| BPX.5 | Bc Donation Id | EI | C | 1 |
| BPX.6 | Bc Component | CNE | C | 1 |
| BPX.7 | Bc Donation Type Intended | CNE | O | 1 |
| BPX.8 | Cp Commercial Product | CWE | C | 1 |
| BPX.9 | Cp Manufacturer | XON | C | 1 |
| BPX.10 | Cp Lot Number | EI | C | 1 |
| BPX.11 | Bp Blood Group | CNE | O | 1 |
| BPX.12 | Bc Special Testing | CNE | O | * |
| BPX.13 | Bp Expiration Date Time | TS | O | 1 |
| BPX.14 | Bp Quantity | NM | R | 1 |
| BPX.15 | Bp Amount | NM | O | 1 |
| BPX.16 | Bp Units | CE | O | 1 |
| BPX.17 | Bp Unique Id | EI | O | 1 |
| BPX.18 | Bp Actual Dispensed To Location | PL | O | 1 |
| BPX.19 | Bp Actual Dispensed To Address | XAD | O | 1 |
| BPX.20 | Bp Dispensed To Receiver | XCN | O | 1 |
| BPX.21 | Bp Dispensing Individual | XCN | O | 1 |

---

## BTS -- Batch Trailer

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| BTS.1 | Batch Message Count | ST | O | 1 |
| BTS.2 | Batch Comment | ST | O | 1 |
| BTS.3 | Batch Totals | NM | O | * |

---

## BTX -- Blood Product Transfusion/Disposition

20 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| BTX.1 | Set Id | SI | R | 1 |
| BTX.2 | Bc Donation Id | EI | C | 1 |
| BTX.3 | Bc Component | CNE | C | 1 |
| BTX.4 | Bc Blood Group | CNE | O | 1 |
| BTX.5 | Cp Commercial Product | CWE | C | 1 |
| BTX.6 | Cp Manufacturer | XON | C | 1 |
| BTX.7 | Cp Lot Number | EI | C | 1 |
| BTX.8 | Bp Quantity | NM | R | 1 |
| BTX.9 | Bp Amount | NM | O | 1 |
| BTX.10 | Bp Units | CE | O | 1 |
| BTX.11 | Bp Transfusion Disposition Status | CWE | R | 1 |
| BTX.12 | Bp Message Status | ID | R | 1 |
| BTX.13 | Bp Date Time Of Status | TS | R | 1 |
| BTX.14 | Bp Administrator | XCN | O | 1 |
| BTX.15 | Bp Verifier | XCN | O | 1 |
| BTX.16 | Bp Transfusion Start Date Time Of Status | TS | O | 1 |
| BTX.17 | Bp Transfusion End Date Time Of Status | TS | O | 1 |
| BTX.18 | Bp Adverse Reaction Type | CWE | O | * |
| BTX.19 | Bp Transfusion Interrupted Reason | CWE | O | 1 |
| BTX.20 | Bp Unique Id | EI | C | 1 |

---

## CDM -- Charge Description Master

13 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CDM.1 | Primary Key Value | CE | R | 1 |
| CDM.2 | Charge Code Alias | CE | O | * |
| CDM.3 | Charge Description Short | ST | R | 1 |
| CDM.4 | Charge Description Long | ST | O | 1 |
| CDM.5 | Description Override Indicator | IS | O | 1 |
| CDM.6 | Exploding Charges | CE | O | * |
| CDM.7 | Procedure Code | CE | O | * |
| CDM.8 | Active Inactive Flag | ID | O | 1 |
| CDM.9 | Inventory Number | CE | O | * |
| CDM.10 | Resource Load | NM | O | 1 |
| CDM.11 | Contract Number | CX | O | * |
| CDM.12 | Contract Organization | ST | O | * |
| CDM.13 | Room Fee Indicator | ID | O | 1 |

---

## CER -- Certificate Detail

31 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CER.1 | Set Id | SI | R | 1 |
| CER.2 | Serial Number | ST | O | 1 |
| CER.3 | Version | ST | O | 1 |
| CER.4 | Granting Authority | XON | O | 1 |
| CER.5 | Issuing Authority | XCN | O | 1 |
| CER.6 | Signature Of Issuing Authority | ED | O | 1 |
| CER.7 | Granting Country | ID | O | 1 |
| CER.8 | Granting State Province | CWE | O | 1 |
| CER.9 | Granting County Parish | CWE | O | 1 |
| CER.10 | Certificate Type | CWE | O | 1 |
| CER.11 | Certificate Domain | CWE | O | 1 |
| CER.12 | Subject Id | EI | O | 1 |
| CER.13 | Subject Name | ST | R | 1 |
| CER.14 | Subject Directory Attribute Extension | CWE | O | * |
| CER.15 | Subject Public Key Info | CWE | O | 1 |
| CER.16 | Authority Key Identifier | CWE | O | 1 |
| CER.17 | Basic Constraint | ID | O | 1 |
| CER.18 | Crl Distribution Point | CWE | O | * |
| CER.19 | Jurisdiction Country | ID | O | 1 |
| CER.20 | Jurisdiction State Province | CWE | O | 1 |
| CER.21 | Jurisdiction County Parish | CWE | O | 1 |
| CER.22 | Jurisdiction Breadth | CWE | O | * |
| CER.23 | Granting Date | TS | O | 1 |
| CER.24 | Issuing Date | TS | O | 1 |
| CER.25 | Activation Date | TS | O | 1 |
| CER.26 | Inactivation Date | TS | O | 1 |
| CER.27 | Expiration Date | TS | O | 1 |
| CER.28 | Renewal Date | TS | O | 1 |
| CER.29 | Revocation Date | TS | O | 1 |
| CER.30 | Revocation Reason Code | CE | O | 1 |
| CER.31 | Certificate Status | CWE | O | 1 |

---

## CM0 -- Clinical Study Master

11 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CM0.1 | Set Id | SI | O | 1 |
| CM0.2 | Sponsor Study Id | EI | R | 1 |
| CM0.3 | Alternate Study Id | EI | O | * |
| CM0.4 | Title Of Study | ST | R | 1 |
| CM0.5 | Chairman Of Study | XCN | O | * |
| CM0.6 | Last Iru Date | DT | O | 1 |
| CM0.7 | Total Accrual To Date | NM | O | 1 |
| CM0.8 | Last Accrual Date | DT | O | 1 |
| CM0.9 | Contact For Study | XCN | O | * |
| CM0.10 | Contacts Telephone Number | XTN | O | 1 |
| CM0.11 | Contacts Address | XAD | O | * |

---

## CM1 -- Clinical Study Phase Master

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CM1.1 | Set Id | SI | R | 1 |
| CM1.2 | Study Phase Identifier | CE | R | 1 |
| CM1.3 | Description Of Study Phase | ST | R | 1 |

---

## CM2 -- Clinical Study Schedule Master

4 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CM2.1 | Set Id | SI | O | 1 |
| CM2.2 | Scheduled Time Point | CE | R | 1 |
| CM2.3 | Description Of Time Point | ST | O | 1 |
| CM2.4 | Number Of Sample Containers | NM | R | 1 |

---

## CNS -- Clear Notification

6 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CNS.1 | Starting Notification Reference Number | NM | O | 1 |
| CNS.2 | Ending Notification Reference Number | NM | O | 1 |
| CNS.3 | Starting Notification Date Time | TS | O | 1 |
| CNS.4 | Ending Notification Date Time | TS | O | 1 |
| CNS.5 | Starting Notification Code | CE | O | 1 |
| CNS.6 | Ending Notification Code | CE | O | 1 |

---

## CON -- Consent Segment

25 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CON.1 | Set Id | SI | R | 1 |
| CON.2 | Consent Type | CWE | O | 1 |
| CON.3 | Consent Form Id | ST | O | 1 |
| CON.4 | Consent Form Number | EI | O | 1 |
| CON.5 | Consent Text | FT | O | * |
| CON.6 | Subject Specific Consent Text | FT | O | * |
| CON.7 | Consent Background | FT | O | * |
| CON.8 | Subject Specific Consent Background | FT | O | * |
| CON.9 | Consenter Imposed Limitations | FT | O | * |
| CON.10 | Consent Mode | CNE | O | 1 |
| CON.11 | Consent Status | CNE | R | 1 |
| CON.12 | Consent Discussion Date Time | TS | O | 1 |
| CON.13 | Consent Decision Date Time | TS | O | 1 |
| CON.14 | Consent Effective Date Time | TS | O | 1 |
| CON.15 | Consent End Date Time | TS | O | 1 |
| CON.16 | Subject Competence Indicator | ID | O | 1 |
| CON.17 | Translator Assistance Indicator | ID | O | 1 |
| CON.18 | Language Translated To | ID | O | 1 |
| CON.19 | Informational Material Supplied Indicator | ID | O | 1 |
| CON.20 | Consent Bypass Reason | CWE | O | 1 |
| CON.21 | Consent Disclosure Level | ID | O | 1 |
| CON.22 | Consent Non Disclosure Reason | CWE | O | 1 |
| CON.23 | Non Subject Consenter Reason | CWE | O | 1 |
| CON.24 | Consenter Id | XPN | R | * |
| CON.25 | Relationship To Subject Table | IS | R | * |

---

## CSP -- Clinical Study Phase

4 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CSP.1 | Study Phase Identifier | CE | R | 1 |
| CSP.2 | Date Time Study Phase Began | TS | R | 1 |
| CSP.3 | Date Time Study Phase Ended | TS | O | 1 |
| CSP.4 | Study Phase Evaluability | CE | C | 1 |

---

## CSR -- Clinical Study Registration

16 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CSR.1 | Sponsor Study Id | EI | R | 1 |
| CSR.2 | Alternate Study Id | EI | O | 1 |
| CSR.3 | Institution Registering The Patient | CE | O | 1 |
| CSR.4 | Sponsor Patient Id | CX | R | 1 |
| CSR.5 | Alternate Patient Id | CX | O | 1 |
| CSR.6 | Date Time Of Patient Study Registration | TS | O | 1 |
| CSR.7 | Person Performing Study Registration | XCN | O | * |
| CSR.8 | Study Authorizing Provider | XCN | R | * |
| CSR.9 | Date Time Patient Study Consent Signed | TS | O | 1 |
| CSR.10 | Patient Study Eligibility Status | CE | C | 1 |
| CSR.11 | Study Randomization Date Time | TS | O | * |
| CSR.12 | Randomized Study Arm | CE | O | * |
| CSR.13 | Stratum For Study Randomization | CE | O | * |
| CSR.14 | Patient Evaluability Status | CE | C | 1 |
| CSR.15 | Date Time Ended Study | TS | O | 1 |
| CSR.16 | Reason Ended Study | CE | O | 1 |

---

## CSS -- Clinical Study Data Schedule Segment

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CSS.1 | Study Scheduled Time Point | CE | R | 1 |
| CSS.2 | Study Scheduled Patient Time Point | TS | O | 1 |
| CSS.3 | Study Quality Control Codes | CE | O | * |

---

## CTD -- Contact Data

7 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CTD.1 | Contact Role | CE | R | * |
| CTD.2 | Contact Name | XPN | O | * |
| CTD.3 | Contact Address | XAD | O | * |
| CTD.4 | Contact Location | PL | O | 1 |
| CTD.5 | Contact Communication Information | XTN | O | * |
| CTD.6 | Preferred Method Of Contact | CE | O | 1 |
| CTD.7 | Contact Identifiers | PLN | O | * |

---

## CTI -- Clinical Trial Identification

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| CTI.1 | Sponsor Study Id | EI | R | 1 |
| CTI.2 | Study Phase Identifier | CE | O | 1 |
| CTI.3 | Study Scheduled Time Point | CE | O | 1 |

---

## DB1 -- Disability

8 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| DB1.1 | Set Id | SI | R | 1 |
| DB1.2 | Disabled Person Code | IS | O | 1 |
| DB1.3 | Disabled Person Identifier | CX | O | * |
| DB1.4 | Disabled Indicator | ID | O | 1 |
| DB1.5 | Disability Start Date | DT | O | 1 |
| DB1.6 | Disability End Date | DT | O | 1 |
| DB1.7 | Disability Return To Work Date | DT | O | 1 |
| DB1.8 | Disability Unable To Work Date | DT | O | 1 |

---

## DG1 -- Diagnosis

21 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| DG1.1 | Set Id | SI | R | 1 |
| DG1.2 | Diagnosis Coding Method | ID | B | 1 |
| DG1.3 | Diagnosis Code | CE | O | 1 |
| DG1.4 | Diagnosis Description | ST | B | 1 |
| DG1.5 | Diagnosis Date Time | TS | O | 1 |
| DG1.6 | Diagnosis Type | IS | R | 1 |
| DG1.7 | Major Diagnostic Category | CE | B | 1 |
| DG1.8 | Diagnostic Related Group | CE | B | 1 |
| DG1.9 | Drg Approval Indicator | ID | B | 1 |
| DG1.10 | Drg Grouper Review Code | IS | B | 1 |
| DG1.11 | Outlier Type | CE | B | 1 |
| DG1.12 | Outlier Days | NM | B | 1 |
| DG1.13 | Outlier Cost | CP | B | 1 |
| DG1.14 | Grouper Version And Type | ST | B | 1 |
| DG1.15 | Diagnosis Priority | ID | O | 1 |
| DG1.16 | Diagnosing Clinician | XCN | O | * |
| DG1.17 | Diagnosis Classification | IS | O | 1 |
| DG1.18 | Confidential Indicator | ID | O | 1 |
| DG1.19 | Attestation Date Time | TS | O | 1 |
| DG1.20 | Diagnosis Identifier | EI | C | 1 |
| DG1.21 | Diagnosis Action Code | ID | C | 1 |

---

## DRG -- Diagnosis Related Group

11 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| DRG.1 | Diagnostic Related Group | CE | O | 1 |
| DRG.2 | Drg Assigned Date Time | TS | O | 1 |
| DRG.3 | Drg Approval Indicator | ID | O | 1 |
| DRG.4 | Drg Grouper Review Code | IS | O | 1 |
| DRG.5 | Outlier Type | CE | O | 1 |
| DRG.6 | Outlier Days | NM | O | 1 |
| DRG.7 | Outlier Cost | CP | O | 1 |
| DRG.8 | Drg Payor | IS | O | 1 |
| DRG.9 | Outlier Reimbursement | CP | O | 1 |
| DRG.10 | Confidential Indicator | ID | O | 1 |
| DRG.11 | Drg Transfer Type | IS | O | 1 |

---

## DSC -- Continuation Pointer

2 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| DSC.1 | Continuation Pointer | ST | O | 1 |
| DSC.2 | Continuation Style | ID | O | 1 |

---

## DSP -- Display Data

5 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| DSP.1 | Set Id | SI | O | 1 |
| DSP.2 | Display Level | SI | O | 1 |
| DSP.3 | Data Line | TX | R | 1 |
| DSP.4 | Logical Break Point | ST | O | 1 |
| DSP.5 | Result Id | TX | O | 1 |

---

## ECD -- Equipment Command

5 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ECD.1 | Reference Command Number | NM | R | 1 |
| ECD.2 | Remote Control Command | CE | R | 1 |
| ECD.3 | Response Required | ID | O | 1 |
| ECD.4 | Requested Completion Time | TQ | O | 1 |
| ECD.5 | Parameters | CE | O | * |

---

## ECR -- Equipment Command Response

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ECR.1 | Command Response | CE | R | 1 |
| ECR.2 | Date Time Completed | TS | R | 1 |
| ECR.3 | Command Response Parameters | ST | O | * |

---

## EDU -- Educational Detail

9 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| EDU.1 | Set Id | SI | R | 1 |
| EDU.2 | Academic Degree | IS | O | 1 |
| EDU.3 | Academic Degree Program Date Range | DR | O | 1 |
| EDU.4 | Academic Degree Program Participation Date Range | DR | O | 1 |
| EDU.5 | Academic Degree Granted Date | DT | O | 1 |
| EDU.6 | School | XON | O | 1 |
| EDU.7 | School Type Code | CE | O | 1 |
| EDU.8 | School Address | XAD | O | 1 |
| EDU.9 | Major Field Of Study | CWE | O | * |

---

## EQL -- Embedded Query Language

4 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| EQL.1 | Query Tag | ST | O | 1 |
| EQL.2 | Query Response Format Code | ID | R | 1 |
| EQL.3 | Eql Query Name | CE | R | 1 |
| EQL.4 | Eql Query Statement | ST | R | 1 |

---

## EQP -- Equipment/log Service

5 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| EQP.1 | Event Type | CE | R | 1 |
| EQP.2 | File Name | ST | O | 1 |
| EQP.3 | Start Date Time | TS | R | 1 |
| EQP.4 | End Date Time | TS | O | 1 |
| EQP.5 | Transaction Data | FT | R | 1 |

---

## EQU -- Equipment Detail

5 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| EQU.1 | Equipment Instance Identifier | EI | R | 1 |
| EQU.2 | Event Date Time | TS | R | 1 |
| EQU.3 | Equipment State | CE | O | 1 |
| EQU.4 | Local Remote Control State | CE | O | 1 |
| EQU.5 | Alert Level | CE | O | 1 |

---

## ERQ -- Event Replay Query

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ERQ.1 | Query Tag | ST | O | 1 |
| ERQ.2 | Event Identifier | CE | R | 1 |
| ERQ.3 | Input Parameter List | QIP | O | * |

---

## ERR -- Error

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ERR.1 | Error Code And Location | ELD | B | * |
| ERR.2 | Error Location | ERL | O | * |
| ERR.3 | Hl7 Error Code | CWE | R | 1 |
| ERR.4 | Severity | ID | R | 1 |
| ERR.5 | Application Error Code | CWE | O | 1 |
| ERR.6 | Application Error Parameter | ST | O | * |
| ERR.7 | Diagnostic Information | TX | O | 1 |
| ERR.8 | User Message | TX | O | 1 |
| ERR.9 | Inform Person Indicator | IS | O | * |
| ERR.10 | Override Type | CWE | O | 1 |
| ERR.11 | Override Reason Code | CWE | O | * |
| ERR.12 | Help Desk Contact Point | XTN | O | * |

---

## EVN -- Event Type

7 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| EVN.1 | Event Type Code | ID | B | 1 |
| EVN.2 | Recorded Date Time | TS | R | 1 |
| EVN.3 | Date Time Planned Event | TS | O | 1 |
| EVN.4 | Event Reason Code | IS | O | 1 |
| EVN.5 | Operator Id | XCN | O | * |
| EVN.6 | Event Occurred | TS | O | 1 |
| EVN.7 | Event Facility | HD | O | 1 |

---

## FAC -- Facility

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| FAC.1 | Facility Id | EI | R | 1 |
| FAC.2 | Facility Type | ID | O | 1 |
| FAC.3 | Facility Address | XAD | R | * |
| FAC.4 | Facility Telecommunication | XTN | R | 1 |
| FAC.5 | Contact Person | XCN | O | * |
| FAC.6 | Contact Title | ST | O | * |
| FAC.7 | Contact Address | XAD | O | * |
| FAC.8 | Contact Telecommunication | XTN | O | * |
| FAC.9 | Signature Authority | XCN | R | * |
| FAC.10 | Signature Authority Title | ST | O | 1 |
| FAC.11 | Signature Authority Address | XAD | O | * |
| FAC.12 | Signature Authority Telecommunication | XTN | R | 1 |

---

## FHS -- File Header

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| FHS.1 | File Field Separator | ST | R | 1 |
| FHS.2 | File Encoding Characters | ST | R | 1 |
| FHS.3 | File Sending Application | HD | O | 1 |
| FHS.4 | File Sending Facility | HD | O | 1 |
| FHS.5 | File Receiving Application | HD | O | 1 |
| FHS.6 | File Receiving Facility | HD | O | 1 |
| FHS.7 | File Creation Date Time | TS | O | 1 |
| FHS.8 | File Security | ST | O | 1 |
| FHS.9 | File Name Id | ST | O | 1 |
| FHS.10 | File Header Comment | ST | O | 1 |
| FHS.11 | File Control Id | ST | O | 1 |
| FHS.12 | Reference File Control Id | ST | O | 1 |

---

## FT1 -- Financial Transaction

31 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| FT1.1 | Set Id | SI | O | 1 |
| FT1.2 | Transaction Id | ST | O | 1 |
| FT1.3 | Transaction Batch Id | ST | O | 1 |
| FT1.4 | Transaction Date | DR | R | 1 |
| FT1.5 | Transaction Posting Date | TS | O | 1 |
| FT1.6 | Transaction Type | IS | R | 1 |
| FT1.7 | Transaction Code | CE | R | 1 |
| FT1.8 | Transaction Description | ST | B | 1 |
| FT1.9 | Transaction Description Alt | ST | B | 1 |
| FT1.10 | Transaction Quantity | NM | O | 1 |
| FT1.11 | Transaction Amount Extended | CP | O | 1 |
| FT1.12 | Transaction Amount Unit | CP | O | 1 |
| FT1.13 | Department Code | CE | O | 1 |
| FT1.14 | Insurance Plan Id | CE | O | 1 |
| FT1.15 | Insurance Amount | CP | O | 1 |
| FT1.16 | Assigned Patient Location | PL | O | 1 |
| FT1.17 | Fee Schedule | IS | O | 1 |
| FT1.18 | Patient Type | IS | O | 1 |
| FT1.19 | Diagnosis Code | CE | O | * |
| FT1.20 | Performed By Code | XCN | O | * |
| FT1.21 | Ordered By Code | XCN | O | * |
| FT1.22 | Unit Cost | CP | O | 1 |
| FT1.23 | Filler Order Number | EI | O | 1 |
| FT1.24 | Entered By Code | XCN | O | * |
| FT1.25 | Procedure Code | CE | O | 1 |
| FT1.26 | Procedure Code Modifier | CE | O | * |
| FT1.27 | Advanced Beneficiary Notice Code | CE | O | 1 |
| FT1.28 | Medically Necessary Duplicate Procedure Reason | CWE | O | 1 |
| FT1.29 | Ndc Code | CNE | O | 1 |
| FT1.30 | Payment Reference Id | CX | O | 1 |
| FT1.31 | Transaction Reference Key | SI | O | * |

---

## FTS -- File Trailer

2 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| FTS.1 | File Batch Count | NM | O | 1 |
| FTS.2 | File Trailer Comment | ST | O | 1 |

---

## GOL -- Goal Detail

21 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| GOL.1 | Action Code | ID | R | 1 |
| GOL.2 | Action Date Time | TS | R | 1 |
| GOL.3 | Goal Id | CE | R | 1 |
| GOL.4 | Goal Instance Id | EI | R | 1 |
| GOL.5 | Episode Of Care Id | EI | O | 1 |
| GOL.6 | Goal List Priority | NM | O | 1 |
| GOL.7 | Goal Established Date Time | TS | O | 1 |
| GOL.8 | Expected Goal Achieve Date Time | TS | O | 1 |
| GOL.9 | Goal Classification | CE | O | 1 |
| GOL.10 | Goal Management Discipline | CE | O | 1 |
| GOL.11 | Current Goal Review Status | CE | O | 1 |
| GOL.12 | Current Goal Review Date Time | TS | O | 1 |
| GOL.13 | Next Goal Review Date Time | TS | O | 1 |
| GOL.14 | Previous Goal Review Date Time | TS | O | 1 |
| GOL.15 | Goal Review Interval | TQ | O | 1 |
| GOL.16 | Goal Evaluation | CE | O | 1 |
| GOL.17 | Goal Evaluation Comment | ST | O | * |
| GOL.18 | Goal Life Cycle Status | CE | O | 1 |
| GOL.19 | Goal Life Cycle Status Date Time | TS | O | 1 |
| GOL.20 | Goal Target Type | CE | O | * |
| GOL.21 | Goal Target Name | XPN | O | * |

---

## GP1 -- Grouping/Reimbursement — Visit

5 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| GP1.1 | Type Of Bill Code | IS | R | 1 |
| GP1.2 | Revenue Code | IS | O | * |
| GP1.3 | Overall Claim Disposition Code | IS | O | 1 |
| GP1.4 | Oce Edits Per Visit Code | IS | O | * |
| GP1.5 | Outlier Cost | CP | O | 1 |

---

## GP2 -- Grouping/Reimbursement — Procedure Line Item

14 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| GP2.1 | Revenue Code | IS | O | 1 |
| GP2.2 | Number Of Service Units | NM | O | 1 |
| GP2.3 | Charge | CP | O | 1 |
| GP2.4 | Reimbursement Action Code | IS | O | 1 |
| GP2.5 | Denial Or Rejection Code | IS | O | 1 |
| GP2.6 | Oce Edit Code | IS | O | * |
| GP2.7 | Ambulatory Payment Classification Code | CE | O | 1 |
| GP2.8 | Modifier Edit Code | IS | O | * |
| GP2.9 | Payment Adjustment Code | IS | O | 1 |
| GP2.10 | Packaging Status Code | IS | O | 1 |
| GP2.11 | Expected Cms Payment Amount | CP | O | 1 |
| GP2.12 | Reimbursement Type Code | IS | O | 1 |
| GP2.13 | Co Pay Amount | CP | O | 1 |
| GP2.14 | Pay Rate Per Service Unit | NM | O | 1 |

---

## GT1 -- Guarantor

55 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| GT1.1 | Set Id | SI | R | 1 |
| GT1.2 | Guarantor Number | CX | O | * |
| GT1.3 | Guarantor Name | XPN | R | * |
| GT1.4 | Guarantor Spouse Name | XPN | O | * |
| GT1.5 | Guarantor Address | XAD | O | * |
| GT1.6 | Guarantor Ph Num Home | XTN | O | * |
| GT1.7 | Guarantor Ph Num Business | XTN | O | * |
| GT1.8 | Guarantor Date Time Of Birth | TS | O | 1 |
| GT1.9 | Guarantor Administrative Sex | IS | O | 1 |
| GT1.10 | Guarantor Type | IS | O | 1 |
| GT1.11 | Guarantor Relationship | CE | O | 1 |
| GT1.12 | Guarantor Ssn | ST | O | 1 |
| GT1.13 | Guarantor Date Begin | DT | O | 1 |
| GT1.14 | Guarantor Date End | DT | O | 1 |
| GT1.15 | Guarantor Priority | NM | O | 1 |
| GT1.16 | Guarantor Employer Name | XPN | O | * |
| GT1.17 | Guarantor Employer Address | XAD | O | * |
| GT1.18 | Guarantor Employer Phone Number | XTN | O | * |
| GT1.19 | Guarantor Employee Id Number | CX | O | * |
| GT1.20 | Guarantor Employment Status | IS | O | 1 |
| GT1.21 | Guarantor Organization Name | XON | O | * |
| GT1.22 | Guarantor Billing Hold Flag | ID | O | 1 |
| GT1.23 | Guarantor Credit Rating Code | CE | O | 1 |
| GT1.24 | Guarantor Death Date And Time | TS | O | 1 |
| GT1.25 | Guarantor Death Flag | ID | O | 1 |
| GT1.26 | Guarantor Charge Adjustment Code | CE | O | 1 |
| GT1.27 | Guarantor Household Annual Income | MO | O | 1 |
| GT1.28 | Guarantor Household Size | NM | O | 1 |
| GT1.29 | Guarantor Employer Id Number | CX | O | * |
| GT1.30 | Guarantor Marital Status Code | CE | O | 1 |
| GT1.31 | Guarantor Hire Effective Date | DT | O | 1 |
| GT1.32 | Employment Stop Date | DT | O | 1 |
| GT1.33 | Living Dependency | IS | O | 1 |
| GT1.34 | Ambulatory Status | IS | O | * |
| GT1.35 | Citizenship | CE | O | * |
| GT1.36 | Primary Language | CE | O | 1 |
| GT1.37 | Living Arrangement | IS | O | 1 |
| GT1.38 | Publicity Code | CE | O | 1 |
| GT1.39 | Protection Indicator | ID | O | 1 |
| GT1.40 | Student Indicator | IS | O | 1 |
| GT1.41 | Religion | CE | O | 1 |
| GT1.42 | Mothers Maiden Name | XPN | O | * |
| GT1.43 | Nationality | CE | O | 1 |
| GT1.44 | Ethnic Group | CE | O | * |
| GT1.45 | Contact Persons Name | XPN | O | * |
| GT1.46 | Contact Persons Telephone Number | XTN | O | * |
| GT1.47 | Contact Reason | CE | O | 1 |
| GT1.48 | Contact Relationship | IS | O | 1 |
| GT1.49 | Job Title | ST | O | 1 |
| GT1.50 | Job Code Class | JCC | O | 1 |
| GT1.51 | Guarantor Employers Organization Name | XON | O | * |
| GT1.52 | Handicap | IS | O | 1 |
| GT1.53 | Job Status | IS | O | 1 |
| GT1.54 | Guarantor Financial Class | FC | O | 1 |
| GT1.55 | Guarantor Race | CE | O | * |

---

## IAM -- Patient Adverse Reaction Information

20 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| IAM.1 | Set Id | SI | R | 1 |
| IAM.2 | Allergen Type Code | CE | O | 1 |
| IAM.3 | Allergen Code Mnemonic Description | CE | R | 1 |
| IAM.4 | Allergy Severity Code | CE | O | 1 |
| IAM.5 | Allergy Reaction Code | ST | O | * |
| IAM.6 | Allergy Action Code | CNE | R | 1 |
| IAM.7 | Allergy Unique Identifier | EI | O | 1 |
| IAM.8 | Action Reason | ST | O | 1 |
| IAM.9 | Sensitivity To Causative Agent Code | CE | O | 1 |
| IAM.10 | Allergen Group Code Mnemonic Description | CE | O | 1 |
| IAM.11 | Onset Date | DT | O | 1 |
| IAM.12 | Onset Date Text | ST | O | 1 |
| IAM.13 | Reported Date Time | TS | O | 1 |
| IAM.14 | Reported By | XPN | O | 1 |
| IAM.15 | Relationship To Patient Code | CE | O | 1 |
| IAM.16 | Alert Device Code | CE | O | 1 |
| IAM.17 | Allergy Clinical Status Code | CE | O | 1 |
| IAM.18 | Statused By Person | XCN | O | 1 |
| IAM.19 | Statused By Organization | XON | O | 1 |
| IAM.20 | Statused At Date Time | TS | O | 1 |

---

## IIM -- Inventory Item Master

15 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| IIM.1 | Primary Key Value | CWE | R | 1 |
| IIM.2 | Service Item Code | CWE | R | 1 |
| IIM.3 | Inventory Lot Number | ST | O | 1 |
| IIM.4 | Inventory Expiration Date | TS | O | 1 |
| IIM.5 | Inventory Manufacturer Name | CWE | O | 1 |
| IIM.6 | Inventory Location | CWE | O | 1 |
| IIM.7 | Inventory Received Date | TS | O | 1 |
| IIM.8 | Inventory Received Quantity | NM | O | 1 |
| IIM.9 | Inventory Received Quantity Unit | CWE | O | 1 |
| IIM.10 | Inventory Received Item Cost | MO | O | 1 |
| IIM.11 | Inventory On Hand Date | TS | O | 1 |
| IIM.12 | Inventory On Hand Quantity | NM | O | 1 |
| IIM.13 | Inventory On Hand Quantity Unit | CWE | O | 1 |
| IIM.14 | Procedure Code | CE | O | 1 |
| IIM.15 | Procedure Code Modifier | CE | O | * |

---

## IN1 -- Insurance

53 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| IN1.1 | Set Id | SI | R | 1 |
| IN1.2 | Insurance Plan Id | CE | R | 1 |
| IN1.3 | Insurance Company Id | CX | R | * |
| IN1.4 | Insurance Company Name | XON | O | * |
| IN1.5 | Insurance Company Address | XAD | O | * |
| IN1.6 | Insurance Co Contact Person | XPN | O | * |
| IN1.7 | Insurance Co Phone Number | XTN | O | * |
| IN1.8 | Group Number | ST | O | 1 |
| IN1.9 | Group Name | XON | O | * |
| IN1.10 | Insureds Group Emp Id | CX | O | * |
| IN1.11 | Insureds Group Emp Name | XON | O | * |
| IN1.12 | Plan Effective Date | DT | O | 1 |
| IN1.13 | Plan Expiration Date | DT | O | 1 |
| IN1.14 | Authorization Information | AUI | O | 1 |
| IN1.15 | Plan Type | IS | O | 1 |
| IN1.16 | Name Of Insured | XPN | O | * |
| IN1.17 | Insureds Relationship To Patient | CE | O | 1 |
| IN1.18 | Insureds Date Of Birth | TS | O | 1 |
| IN1.19 | Insureds Address | XAD | O | * |
| IN1.20 | Assignment Of Benefits | IS | O | 1 |
| IN1.21 | Coordination Of Benefits | IS | O | 1 |
| IN1.22 | Coord Of Ben Priority | ST | O | 1 |
| IN1.23 | Notice Of Admission Flag | ID | O | 1 |
| IN1.24 | Notice Of Admission Date | DT | O | 1 |
| IN1.25 | Report Of Eligibility Flag | ID | O | 1 |
| IN1.26 | Report Of Eligibility Date | DT | O | 1 |
| IN1.27 | Release Information Code | IS | O | 1 |
| IN1.28 | Pre Admit Cert | ST | O | 1 |
| IN1.29 | Verification Date Time | TS | O | 1 |
| IN1.30 | Verification By | XCN | O | * |
| IN1.31 | Type Of Agreement Code | IS | O | 1 |
| IN1.32 | Billing Status | IS | O | 1 |
| IN1.33 | Lifetime Reserve Days | NM | O | 1 |
| IN1.34 | Delay Before Lr Day | NM | O | 1 |
| IN1.35 | Company Plan Code | IS | O | 1 |
| IN1.36 | Policy Number | ST | O | 1 |
| IN1.37 | Policy Deductible | MO | O | 1 |
| IN1.38 | Policy Limit Amount | MO | B | 1 |
| IN1.39 | Policy Limit Days | NM | O | 1 |
| IN1.40 | Room Rate Semi Private | MO | B | 1 |
| IN1.41 | Room Rate Private | MO | B | 1 |
| IN1.42 | Insureds Employment Status | CE | O | 1 |
| IN1.43 | Insureds Administrative Sex | IS | O | 1 |
| IN1.44 | Insureds Employers Address | XAD | O | * |
| IN1.45 | Verification Status | ST | O | 1 |
| IN1.46 | Prior Insurance Plan Id | IS | O | 1 |
| IN1.47 | Coverage Type | IS | O | 1 |
| IN1.48 | Handicap | IS | O | 1 |
| IN1.49 | Insureds Id Number | CX | O | * |
| IN1.50 | Signature Code | IS | O | 1 |
| IN1.51 | Signature Code Date | DT | O | 1 |
| IN1.52 | Insureds Birth Place | ST | O | 1 |
| IN1.53 | Vip Indicator | IS | O | 1 |

---

## IN2 -- Insurance Additional Information

72 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| IN2.1 | Insured Employee Id | CX | O | * |
| IN2.2 | Insured Social Security Number | ST | O | 1 |
| IN2.3 | Insured Employer Name And Id | XCN | O | * |
| IN2.4 | Employer Information Data | IS | O | 1 |
| IN2.5 | Mail Claim Party | IS | O | * |
| IN2.6 | Medicare Health Ins Card Number | ST | O | 1 |
| IN2.7 | Medicaid Case Name | XPN | O | * |
| IN2.8 | Medicaid Case Number | ST | O | 1 |
| IN2.9 | Military Sponsor Name | XPN | O | * |
| IN2.10 | Military Id Number | ST | O | 1 |
| IN2.11 | Dependent Of Military Recipient | CE | O | 1 |
| IN2.12 | Military Organization | ST | O | 1 |
| IN2.13 | Military Station | ST | O | 1 |
| IN2.14 | Military Service | IS | O | 1 |
| IN2.15 | Military Rank Grade | IS | O | 1 |
| IN2.16 | Military Status | IS | O | 1 |
| IN2.17 | Military Retire Date | DT | O | 1 |
| IN2.18 | Military Non Avail Cert On File | ID | O | 1 |
| IN2.19 | Baby Coverage | ID | O | 1 |
| IN2.20 | Combine Baby Bill | ID | O | 1 |
| IN2.21 | Blood Deductible | ST | O | 1 |
| IN2.22 | Special Coverage Approval Name | XPN | O | * |
| IN2.23 | Special Coverage Approval Title | ST | O | 1 |
| IN2.24 | Non Covered Insurance Code | IS | O | * |
| IN2.25 | Payor Id | CX | O | * |
| IN2.26 | Payor Subscriber Id | CX | O | * |
| IN2.27 | Eligibility Source | IS | O | 1 |
| IN2.28 | Room Coverage Type Amount | RMC | O | * |
| IN2.29 | Policy Type Amount | PTA | O | * |
| IN2.30 | Daily Deductible | DDI | O | 1 |
| IN2.31 | Living Dependency | IS | O | 1 |
| IN2.32 | Ambulatory Status | IS | O | * |
| IN2.33 | Citizenship | CE | O | * |
| IN2.34 | Primary Language | CE | O | 1 |
| IN2.35 | Living Arrangement | IS | O | 1 |
| IN2.36 | Publicity Code | CE | O | 1 |
| IN2.37 | Protection Indicator | ID | O | 1 |
| IN2.38 | Student Indicator | IS | O | 1 |
| IN2.39 | Religion | CE | O | 1 |
| IN2.40 | Mothers Maiden Name | XPN | O | * |
| IN2.41 | Nationality | CE | O | 1 |
| IN2.42 | Ethnic Group | CE | O | * |
| IN2.43 | Marital Status | CE | O | * |
| IN2.44 | Insureds Employment Start Date | DT | O | 1 |
| IN2.45 | Employment Stop Date | DT | O | 1 |
| IN2.46 | Job Title | ST | O | 1 |
| IN2.47 | Job Code Class | JCC | O | 1 |
| IN2.48 | Job Status | IS | O | 1 |
| IN2.49 | Employer Contact Person Name | XPN | O | * |
| IN2.50 | Employer Contact Person Phone Number | XTN | O | * |
| IN2.51 | Employer Contact Reason | IS | O | 1 |
| IN2.52 | Insureds Contact Persons Name | XPN | O | * |
| IN2.53 | Insureds Contact Person Phone Number | XTN | O | * |
| IN2.54 | Insureds Contact Person Reason | IS | O | * |
| IN2.55 | Relationship To The Patient Start Date | DT | O | 1 |
| IN2.56 | Relationship To The Patient Stop Date | DT | O | * |
| IN2.57 | Insurance Co Contact Reason | IS | O | 1 |
| IN2.58 | Insurance Co Contact Phone Number | XTN | O | * |
| IN2.59 | Policy Scope | IS | O | 1 |
| IN2.60 | Policy Source | IS | O | 1 |
| IN2.61 | Patient Member Number | CX | O | 1 |
| IN2.62 | Guarantors Relationship To Insured | CE | O | 1 |
| IN2.63 | Insureds Phone Number Home | XTN | O | * |
| IN2.64 | Insureds Employer Phone Number | XTN | O | * |
| IN2.65 | Military Handicapped Program | CE | O | 1 |
| IN2.66 | Suspend Flag | ID | O | 1 |
| IN2.67 | Copay Limit Flag | ID | O | 1 |
| IN2.68 | Stoploss Limit Flag | ID | O | 1 |
| IN2.69 | Insured Organization Name And Id | XON | O | * |
| IN2.70 | Insured Employer Organization Name And Id | XON | O | * |
| IN2.71 | Race | CE | O | * |
| IN2.72 | Cms Patients Relationship To Insured | CE | O | 1 |

---

## IN3 -- Insurance Additional Information, Certification

28 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| IN3.1 | Set Id | SI | R | 1 |
| IN3.2 | Certification Number | CX | O | 1 |
| IN3.3 | Certified By | XCN | O | * |
| IN3.4 | Certification Required | ID | O | 1 |
| IN3.5 | Penalty | MO | O | 1 |
| IN3.6 | Certification Date Time | TS | O | 1 |
| IN3.7 | Certification Modify Date Time | TS | O | 1 |
| IN3.8 | Operator | XCN | O | * |
| IN3.9 | Certification Begin Date | DT | O | 1 |
| IN3.10 | Certification End Date | DT | O | 1 |
| IN3.11 | Days | DTN | O | 1 |
| IN3.12 | Non Concur Code Description | CE | O | 1 |
| IN3.13 | Non Concur Effective Date Time | TS | O | 1 |
| IN3.14 | Physician Reviewer | XCN | O | * |
| IN3.15 | Certification Contact | ST | O | 1 |
| IN3.16 | Certification Contact Phone Number | XTN | O | * |
| IN3.17 | Appeal Reason | CE | O | 1 |
| IN3.18 | Certification Agency | CE | O | 1 |
| IN3.19 | Certification Agency Phone Number | XTN | O | * |
| IN3.20 | Pre Certification Requirement | ICD | O | * |
| IN3.21 | Case Manager | ST | O | 1 |
| IN3.22 | Second Opinion Date | DT | O | 1 |
| IN3.23 | Second Opinion Status | IS | O | 1 |
| IN3.24 | Second Opinion Documentation Received | IS | O | * |
| IN3.25 | Second Opinion Physician | XCN | O | * |
| IN3.26 | Certification Type | IS | O | 1 |
| IN3.27 | Certification Category | IS | O | 1 |
| IN3.28 | Field 28 | CE | O | 1 |

---

## INV -- Inventory Detail

20 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| INV.1 | Substance Identifier | CE | R | 1 |
| INV.2 | Substance Status | CE | R | * |
| INV.3 | Substance Type | CE | O | 1 |
| INV.4 | Inventory Container Identifier | CE | O | 1 |
| INV.5 | Container Carrier Identifier | CE | O | 1 |
| INV.6 | Position On Carrier | CE | O | 1 |
| INV.7 | Initial Quantity | NM | O | 1 |
| INV.8 | Current Quantity | NM | O | 1 |
| INV.9 | Available Quantity | NM | O | 1 |
| INV.10 | Consumption Quantity | NM | O | 1 |
| INV.11 | Quantity Units | CE | O | 1 |
| INV.12 | Expiration Date Time | TS | O | 1 |
| INV.13 | First Used Date Time | TS | O | 1 |
| INV.14 | On Board Stability Duration | TQ | O | 1 |
| INV.15 | On Board Stability Time | TS | O | 1 |
| INV.16 | Test Fluid Identifier | CE | O | * |
| INV.17 | Manufacturer Lot Number | ST | O | 1 |
| INV.18 | Manufacturer Identifier | CE | O | 1 |
| INV.19 | Supplier Identifier | CE | O | 1 |
| INV.20 | On Board Stability Time 2 | CQ | O | 1 |

---

## IPC -- Imaging Procedure Control Segment

9 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| IPC.1 | Accession Identifier | EI | R | 1 |
| IPC.2 | Requested Procedure Id | EI | R | 1 |
| IPC.3 | Study Instance Uid | EI | R | 1 |
| IPC.4 | Scheduled Procedure Step Id | EI | R | 1 |
| IPC.5 | Modality | CE | O | 1 |
| IPC.6 | Protocol Code | CE | O | * |
| IPC.7 | Scheduled Station Name | EI | O | 1 |
| IPC.8 | Scheduled Procedure Step Location List | CE | O | * |
| IPC.9 | Scheduled Ae Title | ST | O | 1 |

---

## ISD -- Interaction Status Detail

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ISD.1 | Reference Interaction Number | NM | R | 1 |
| ISD.2 | Interaction Type Identifier | CE | O | 1 |
| ISD.3 | Interaction Active State | CE | R | 1 |

---

## LAN -- Language Detail

4 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| LAN.1 | Set Id | SI | R | 1 |
| LAN.2 | Language Code | CE | R | 1 |
| LAN.3 | Language Ability Code | CE | O | * |
| LAN.4 | Language Proficiency Code | CE | O | 1 |

---

## LCC -- Location Charge Code

4 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| LCC.1 | Primary Key Value | PL | R | 1 |
| LCC.2 | Location Department | CE | R | 1 |
| LCC.3 | Accommodation Type | CE | O | * |
| LCC.4 | Charge Code | CE | R | * |

---

## LCH -- Location Characteristic

4 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| LCH.1 | Primary Key Value | PL | R | 1 |
| LCH.2 | Segment Unique Key | EI | O | 1 |
| LCH.3 | Location Characteristic Id | CE | R | 1 |
| LCH.4 | Location Characteristic Value | CE | R | 1 |

---

## LDP -- Location Department

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| LDP.1 | Primary Key Value | PL | R | 1 |
| LDP.2 | Location Department | CE | R | 1 |
| LDP.3 | Location Service | IS | O | * |
| LDP.4 | Specialty Type | CE | O | * |
| LDP.5 | Valid Patient Classes | IS | O | * |
| LDP.6 | Active Inactive Flag | ID | O | 1 |
| LDP.7 | Activation Date Ldp | TS | O | 1 |
| LDP.8 | Inactivation Date Ldp | TS | O | 1 |
| LDP.9 | Inactivated Reason | ST | O | 1 |
| LDP.10 | Visiting Hours | VH | O | * |
| LDP.11 | Contact Phone | XTN | O | 1 |
| LDP.12 | Location Cost Center | CE | O | 1 |

---

## LOC -- Location Identification

9 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| LOC.1 | Primary Key Value | PL | R | 1 |
| LOC.2 | Location Description | ST | O | 1 |
| LOC.3 | Location Type | IS | O | * |
| LOC.4 | Organization Name Loc | XON | O | * |
| LOC.5 | Location Address | XAD | O | * |
| LOC.6 | Location Phone | XTN | O | * |
| LOC.7 | License Number | CE | O | * |
| LOC.8 | Location Equipment | IS | O | * |
| LOC.9 | Location Service Code | IS | O | 1 |

---

## LRL -- Location Relationship

6 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| LRL.1 | Primary Key Value | PL | R | 1 |
| LRL.2 | Segment Unique Key | EI | O | 1 |
| LRL.3 | Location Relationship Id | CE | R | 1 |
| LRL.4 | Location Relationship Value | XON | O | * |
| LRL.5 | Organizational Location Relationship Value | XAD | O | * |
| LRL.6 | Patient Location Relationship Value | PL | O | 1 |

---

## MFA -- Master File Acknowledgment

6 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| MFA.1 | Record Level Event Code | ID | R | 1 |
| MFA.2 | Mfn Control Id | ST | C | 1 |
| MFA.3 | Event Completion Date Time | TS | O | 1 |
| MFA.4 | Mfn Record Level Error Return | CE | R | 1 |
| MFA.5 | Primary Key Value Mfe | CE | R | * |
| MFA.6 | Primary Key Value Type Mfe | ID | R | * |

---

## MFE -- Master File Entry

5 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| MFE.1 | Record Level Event Code | ID | R | 1 |
| MFE.2 | Mfn Control Id | ST | C | 1 |
| MFE.3 | Effective Date Time | TS | O | 1 |
| MFE.4 | Primary Key Value | CE | R | * |
| MFE.5 | Primary Key Value Type | ID | R | * |

---

## MFI -- Master File Identification

6 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| MFI.1 | Master File Identifier | CE | R | 1 |
| MFI.2 | Master File Application Identifier | HD | O | * |
| MFI.3 | File Level Event Code | ID | R | 1 |
| MFI.4 | Entered Date Time | TS | O | 1 |
| MFI.5 | Effective Date Time | TS | O | 1 |
| MFI.6 | Response Level Code | ID | R | 1 |

---

## MRG -- Merge Patient Information

7 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| MRG.1 | Prior Patient Identifier List | CX | R | * |
| MRG.2 | Prior Alternate Patient Id | CX | O | * |
| MRG.3 | Prior Patient Account Number | CX | O | 1 |
| MRG.4 | Prior Patient Id | CX | O | 1 |
| MRG.5 | Prior Visit Number | CX | O | 1 |
| MRG.6 | Prior Alternate Visit Id | CX | O | 1 |
| MRG.7 | Prior Patient Name | XPN | O | * |

---

## MSA -- Message Acknowledgment

6 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| MSA.1 | Acknowledgment Code | ID | R | 1 |
| MSA.2 | Message Control Id | ST | R | 1 |
| MSA.3 | Text Message | ST | O | 1 |
| MSA.4 | Expected Sequence Number | NM | O | 1 |
| MSA.5 | Delayed Acknowledgment Type | ID | B | 1 |
| MSA.6 | Error Condition | CE | B | 1 |

---

## MSH -- Message Header

21 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| MSH.1 | Field Separator | ST | R | 1 |
| MSH.2 | Encoding Characters | ST | R | 1 |
| MSH.3 | Sending Application | HD | O | 1 |
| MSH.4 | Sending Facility | HD | O | 1 |
| MSH.5 | Receiving Application | HD | O | 1 |
| MSH.6 | Receiving Facility | HD | O | 1 |
| MSH.7 | Date Time Of Message | TS | R | 1 |
| MSH.8 | Security | ST | O | 1 |
| MSH.9 | Message Type | MSG | R | 1 |
| MSH.10 | Message Control Id | ST | R | 1 |
| MSH.11 | Processing Id | PT | R | 1 |
| MSH.12 | Version Id | VID | R | 1 |
| MSH.13 | Sequence Number | NM | O | 1 |
| MSH.14 | Continuation Pointer | ST | O | 1 |
| MSH.15 | Accept Acknowledgment Type | ID | O | 1 |
| MSH.16 | Application Acknowledgment Type | ID | O | 1 |
| MSH.17 | Country Code | ID | O | 1 |
| MSH.18 | Character Set | ID | O | * |
| MSH.19 | Principal Language Of Message | CE | O | 1 |
| MSH.20 | Alternate Character Set Handling Scheme | ID | O | 1 |
| MSH.21 | Message Profile Identifier | EI | O | * |

---

## NCK -- System Clock

1 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| NCK.1 | System Date Time | TS | R | 1 |

---

## NDS -- Notification Detail

4 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| NDS.1 | Notification Reference Number | NM | R | 1 |
| NDS.2 | Notification Date Time | TS | R | 1 |
| NDS.3 | Notification Alert Severity | NM | R | 1 |
| NDS.4 | Notification Code | CE | R | 1 |

---

## NK1 -- Next of Kin / Associated Parties

39 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| NK1.1 | Set Id | SI | R | 1 |
| NK1.2 | Nk Name | XPN | O | * |
| NK1.3 | Relationship | CE | O | 1 |
| NK1.4 | Address | XAD | O | * |
| NK1.5 | Phone Number | XTN | O | * |
| NK1.6 | Business Phone Number | XTN | O | * |
| NK1.7 | Contact Role | CE | O | 1 |
| NK1.8 | Start Date | DT | O | 1 |
| NK1.9 | End Date | DT | O | 1 |
| NK1.10 | Next Of Kin Job Title | ST | O | 1 |
| NK1.11 | Next Of Kin Job Code Class | JCC | O | 1 |
| NK1.12 | Next Of Kin Employee Number | CX | O | 1 |
| NK1.13 | Organization Name | XON | O | * |
| NK1.14 | Marital Status | CE | O | 1 |
| NK1.15 | Administrative Sex | IS | O | 1 |
| NK1.16 | Date Time Of Birth | TS | O | 1 |
| NK1.17 | Living Dependency | IS | O | * |
| NK1.18 | Ambulatory Status | IS | O | * |
| NK1.19 | Citizenship | CE | O | * |
| NK1.20 | Primary Language | CE | O | 1 |
| NK1.21 | Living Arrangement | IS | O | 1 |
| NK1.22 | Publicity Code | CE | O | 1 |
| NK1.23 | Protection Indicator | ID | O | 1 |
| NK1.24 | Student Indicator | IS | O | 1 |
| NK1.25 | Religion | CE | O | 1 |
| NK1.26 | Mothers Maiden Name | XPN | O | * |
| NK1.27 | Nationality | CE | O | 1 |
| NK1.28 | Ethnic Group | CE | O | * |
| NK1.29 | Contact Reason | CE | O | * |
| NK1.30 | Contact Persons Name | XPN | O | * |
| NK1.31 | Contact Persons Telephone Number | XTN | O | * |
| NK1.32 | Contact Persons Address | XAD | O | * |
| NK1.33 | Next Of Kin Identifiers | CX | O | * |
| NK1.34 | Job Status | IS | O | 1 |
| NK1.35 | Race | CE | O | * |
| NK1.36 | Handicap | IS | O | 1 |
| NK1.37 | Contact Person Social Security Number | ST | O | 1 |
| NK1.38 | Next Of Kin Birth Place | ST | O | 1 |
| NK1.39 | Vip Indicator | IS | O | 1 |

---

## NPU -- Bed Status Update

2 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| NPU.1 | Bed Location | PL | R | 1 |
| NPU.2 | Bed Status | IS | O | 1 |

---

## NSC -- Application Status Change

9 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| NSC.1 | Application Change Type | IS | R | 1 |
| NSC.2 | Current Cpu | ST | O | 1 |
| NSC.3 | Current Fileserver | ST | O | 1 |
| NSC.4 | Current Application | HD | O | 1 |
| NSC.5 | Current Facility | HD | O | 1 |
| NSC.6 | New Cpu | ST | O | 1 |
| NSC.7 | New Fileserver | ST | O | 1 |
| NSC.8 | New Application | HD | O | 1 |
| NSC.9 | New Facility | HD | O | 1 |

---

## NST -- Application Control Level Statistics

15 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| NST.1 | Statistics Available | ID | R | 1 |
| NST.2 | Source Identifier | ST | O | 1 |
| NST.3 | Source Type | ID | O | 1 |
| NST.4 | Statistics Start | TS | O | 1 |
| NST.5 | Statistics End | TS | O | 1 |
| NST.6 | Receive Character Count | NM | O | 1 |
| NST.7 | Send Character Count | NM | O | 1 |
| NST.8 | Messages Received | NM | O | 1 |
| NST.9 | Messages Sent | NM | O | 1 |
| NST.10 | Checksum Errors Received | NM | O | 1 |
| NST.11 | Length Errors Received | NM | O | 1 |
| NST.12 | Other Errors Received | NM | O | 1 |
| NST.13 | Connect Timeouts | NM | O | 1 |
| NST.14 | Receive Timeouts | NM | O | 1 |
| NST.15 | Application Control Level Errors | NM | O | 1 |

---

## NTE -- Notes and Comments

4 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| NTE.1 | Set Id | SI | O | 1 |
| NTE.2 | Source Of Comment | ID | O | 1 |
| NTE.3 | Comment | FT | O | * |
| NTE.4 | Comment Type | CE | O | 1 |

---

## OBR -- Observation Request

49 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| OBR.1 | Set Id | SI | O | 1 |
| OBR.2 | Placer Order Number | EI | C | 1 |
| OBR.3 | Filler Order Number | EI | C | 1 |
| OBR.4 | Universal Service Identifier | CE | R | 1 |
| OBR.5 | Priority | ID | B | 1 |
| OBR.6 | Requested Date Time | TS | B | 1 |
| OBR.7 | Observation Date Time | TS | C | 1 |
| OBR.8 | Observation End Date Time | TS | O | 1 |
| OBR.9 | Collection Volume | CQ | O | 1 |
| OBR.10 | Collector Identifier | XCN | O | * |
| OBR.11 | Specimen Action Code | ID | O | 1 |
| OBR.12 | Danger Code | CE | O | 1 |
| OBR.13 | Relevant Clinical Information | ST | O | 1 |
| OBR.14 | Specimen Received Date Time | TS | B | 1 |
| OBR.15 | Specimen Source | SPS | B | 1 |
| OBR.16 | Ordering Provider | XCN | O | * |
| OBR.17 | Order Callback Phone Number | XTN | O | * |
| OBR.18 | Placer Field 1 | ST | O | 1 |
| OBR.19 | Placer Field 2 | ST | O | 1 |
| OBR.20 | Filler Field 1 | ST | O | 1 |
| OBR.21 | Filler Field 2 | ST | O | 1 |
| OBR.22 | Results Rpt Status Chng Date Time | TS | C | 1 |
| OBR.23 | Charge To Practice | MOC | O | 1 |
| OBR.24 | Diagnostic Serv Sect Id | ID | O | 1 |
| OBR.25 | Result Status | ID | C | 1 |
| OBR.26 | Parent Result | PRL | O | 1 |
| OBR.27 | Quantity Timing | TQ | B | * |
| OBR.28 | Result Copies To | XCN | O | * |
| OBR.29 | Parent | EIP | O | 1 |
| OBR.30 | Transportation Mode | ID | O | 1 |
| OBR.31 | Reason For Study | CE | O | * |
| OBR.32 | Principal Result Interpreter | NDL | O | 1 |
| OBR.33 | Assistant Result Interpreter | NDL | O | * |
| OBR.34 | Technician | NDL | O | * |
| OBR.35 | Transcriptionist | NDL | O | * |
| OBR.36 | Scheduled Date Time | TS | O | 1 |
| OBR.37 | Number Of Sample Containers | NM | O | 1 |
| OBR.38 | Transport Logistics Of Collected Sample | CE | O | * |
| OBR.39 | Collectors Comment | CE | O | * |
| OBR.40 | Transport Arrangement Responsibility | CE | O | 1 |
| OBR.41 | Transport Arranged | ID | O | 1 |
| OBR.42 | Escort Required | ID | O | 1 |
| OBR.43 | Planned Patient Transport Comment | CE | O | * |
| OBR.44 | Procedure Code | CE | O | 1 |
| OBR.45 | Procedure Code Modifier | CE | O | * |
| OBR.46 | Placer Supplemental Service Information | CE | O | * |
| OBR.47 | Filler Supplemental Service Information | CE | O | * |
| OBR.48 | Medically Necessary Duplicate Procedure Reason | CWE | O | 1 |
| OBR.49 | Result Handling | IS | O | 1 |

---

## OBX -- Observation/Result

19 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| OBX.1 | Set Id | SI | O | 1 |
| OBX.2 | Value Type | ID | C | 1 |
| OBX.3 | Observation Identifier | CE | R | 1 |
| OBX.4 | Observation Sub Id | ST | C | 1 |
| OBX.5 | Observation Value | varies | C | * |
| OBX.6 | Units | CE | O | 1 |
| OBX.7 | References Range | ST | O | 1 |
| OBX.8 | Abnormal Flags | IS | O | * |
| OBX.9 | Probability | NM | O | 1 |
| OBX.10 | Nature Of Abnormal Test | ID | O | * |
| OBX.11 | Observation Result Status | ID | R | 1 |
| OBX.12 | Effective Date Of Reference Range | TS | O | 1 |
| OBX.13 | User Defined Access Checks | ST | O | 1 |
| OBX.14 | Date Time Of The Observation | TS | O | 1 |
| OBX.15 | Producers Id | CE | O | 1 |
| OBX.16 | Responsible Observer | XCN | O | * |
| OBX.17 | Observation Method | CE | O | * |
| OBX.18 | Equipment Instance Identifier | EI | O | * |
| OBX.19 | Date Time Of The Analysis | TS | O | 1 |

---

## ODS -- Dietary Orders, Supplements, and Preferences

4 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ODS.1 | Type | ID | R | 1 |
| ODS.2 | Service Period | CE | O | * |
| ODS.3 | Diet Supplement Or Preference Code | CE | R | * |
| ODS.4 | Text Instruction | ST | O | * |

---

## ODT -- Diet Tray Instructions

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ODT.1 | Tray Type | CE | R | 1 |
| ODT.2 | Service Period | CE | O | * |
| ODT.3 | Text Instruction | ST | O | 1 |

---

## OM1 -- General Segment

47 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| OM1.1 | Sequence Number | NM | R | 1 |
| OM1.2 | Producers Service Test Observation Id | CE | R | 1 |
| OM1.3 | Permitted Data Types | ID | O | * |
| OM1.4 | Specimen Required | ID | R | 1 |
| OM1.5 | Producer Id | CE | R | 1 |
| OM1.6 | Observation Description | TX | O | 1 |
| OM1.7 | Other Service Test Observation Ids For The Observation | CE | O | 1 |
| OM1.8 | Other Names | ST | R | * |
| OM1.9 | Preferred Report Name | ST | O | 1 |
| OM1.10 | Preferred Short Name | ST | O | 1 |
| OM1.11 | Preferred Long Name | ST | O | 1 |
| OM1.12 | Orderability | ID | O | 1 |
| OM1.13 | Identity Of Instrument Used To Perform This Study | CE | O | * |
| OM1.14 | Coded Representation Of Method | CE | O | * |
| OM1.15 | Portable Device Indicator | ID | O | 1 |
| OM1.16 | Observation Producing Department Section | CE | O | * |
| OM1.17 | Telephone Number Of Section | XTN | O | 1 |
| OM1.18 | Nature Of Service Test Observation | IS | R | 1 |
| OM1.19 | Report Subheader | CE | O | 1 |
| OM1.20 | Report Display Order | ST | O | 1 |
| OM1.21 | Date Time Stamp For Any Change In Definition For The Observation | TS | O | 1 |
| OM1.22 | Effective Date Time Of Change | TS | O | 1 |
| OM1.23 | Typical Turn Around Time | NM | O | 1 |
| OM1.24 | Processing Time | NM | O | 1 |
| OM1.25 | Processing Priority | ID | O | * |
| OM1.26 | Reporting Priority | ID | O | 1 |
| OM1.27 | Outside Site | CE | O | * |
| OM1.28 | Address Of Outside Site | XAD | O | * |
| OM1.29 | Phone Number Of Outside Site | XTN | O | 1 |
| OM1.30 | Confidentiality Code | CWE | O | 1 |
| OM1.31 | Observations Required To Interpret The Observation | CE | O | 1 |
| OM1.32 | Interpretation Of Observations | TX | O | 1 |
| OM1.33 | Contraindications To Observations | CE | O | 1 |
| OM1.34 | Reflex Tests Observations | CE | O | * |
| OM1.35 | Rules That Trigger Reflex Testing | TX | O | 1 |
| OM1.36 | Fixed Canned Message | CE | O | 1 |
| OM1.37 | Patient Preparation | TX | O | 1 |
| OM1.38 | Procedure Medication | CE | O | 1 |
| OM1.39 | Factors That May Affect The Observation | TX | O | 1 |
| OM1.40 | Service Test Observation Performance Schedule | ST | O | * |
| OM1.41 | Description Of Test Methods | TX | O | 1 |
| OM1.42 | Kind Of Quantity Observed | CE | O | 1 |
| OM1.43 | Point Versus Interval | CE | O | 1 |
| OM1.44 | Challenge Information | TX | O | 1 |
| OM1.45 | Relationship Modifier | CE | O | 1 |
| OM1.46 | Target Anatomic Site Of Test | CE | O | 1 |
| OM1.47 | Modality Of Imaging Measurement | CE | O | 1 |

---

## OM2 -- Numeric Observation

10 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| OM2.1 | Sequence Number | NM | O | 1 |
| OM2.2 | Units Of Measure | CE | O | 1 |
| OM2.3 | Range Of Decimal Precision | NM | O | * |
| OM2.4 | Corresponding Si Units Of Measure | CE | O | 1 |
| OM2.5 | Si Conversion Factor | TX | O | 1 |
| OM2.6 | Reference Normal Range Ordinal And Continuous Observations | RFR | O | * |
| OM2.7 | Critical Range For Ordinal And Continuous Observations | RFR | O | * |
| OM2.8 | Absolute Range For Ordinal And Continuous Observations | RFR | O | 1 |
| OM2.9 | Delta Check Criteria | DLT | O | * |
| OM2.10 | Minimum Meaningful Increments | NM | O | 1 |

---

## OM3 -- Categorical Service/Test/Observation

7 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| OM3.1 | Sequence Number | NM | O | 1 |
| OM3.2 | Preferred Coding System | CE | O | 1 |
| OM3.3 | Valid Coded Answers | CE | O | * |
| OM3.4 | Normal Text Codes For Categorical Results | CE | O | * |
| OM3.5 | Abnormal Text Codes For Categorical Results | CE | O | * |
| OM3.6 | Critical Text Codes For Categorical Results | CE | O | * |
| OM3.7 | Value Type | ID | O | 1 |

---

## OM4 -- Observations that Require Specimens

14 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| OM4.1 | Sequence Number | NM | O | 1 |
| OM4.2 | Derived Specimen | ID | O | 1 |
| OM4.3 | Container Description | TX | O | 1 |
| OM4.4 | Container Volume | NM | O | 1 |
| OM4.5 | Container Units | CE | O | 1 |
| OM4.6 | Specimen | CE | O | 1 |
| OM4.7 | Additive | CWE | O | 1 |
| OM4.8 | Preparation | TX | O | 1 |
| OM4.9 | Special Handling Requirements | TX | O | 1 |
| OM4.10 | Normal Collection Volume | CQ | O | 1 |
| OM4.11 | Minimum Collection Volume | CQ | O | 1 |
| OM4.12 | Specimen Requirements | TX | O | 1 |
| OM4.13 | Specimen Priorities | ID | O | * |
| OM4.14 | Specimen Retention Time | CQ | O | 1 |

---

## OM5 -- Observation Batteries (Sets)

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| OM5.1 | Sequence Number | NM | O | 1 |
| OM5.2 | Test Observations Included Within An Ordered Test Battery | CE | O | * |
| OM5.3 | Observation Id Suffixes | ST | O | 1 |

---

## OM6 -- Observations Calculated from Other Observations

1 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| OM6.1 | Derivation Rule | TX | O | 1 |

---

## OM7 -- Additional Basic Attributes

24 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| OM7.1 | Sequence Number | NM | R | 1 |
| OM7.2 | Universal Service Identifier | CE | R | 1 |
| OM7.3 | Category Identifier | CE | O | * |
| OM7.4 | Category Description | TX | O | 1 |
| OM7.5 | Category Synonym | ST | O | * |
| OM7.6 | Effective Test Service Start Date Time | TS | O | 1 |
| OM7.7 | Effective Test Service End Date Time | TS | O | 1 |
| OM7.8 | Test Service Default Duration Quantity | NM | O | 1 |
| OM7.9 | Test Service Default Duration Units | CE | O | 1 |
| OM7.10 | Test Service Default Frequency | IS | O | 1 |
| OM7.11 | Consent Indicator | ID | O | 1 |
| OM7.12 | Consent Identifier | CE | O | 1 |
| OM7.13 | Consent Effective Start Date Time | TS | O | 1 |
| OM7.14 | Consent Effective End Date Time | TS | O | 1 |
| OM7.15 | Consent Interval Quantity | NM | O | 1 |
| OM7.16 | Consent Interval Units | CE | O | 1 |
| OM7.17 | Consent Waiting Period Quantity | NM | O | 1 |
| OM7.18 | Consent Waiting Period Units | CE | O | 1 |
| OM7.19 | Effective Date Time Of Change | TS | O | 1 |
| OM7.20 | Entered By | XCN | O | 1 |
| OM7.21 | Orderable At Location | PL | O | * |
| OM7.22 | Formulary Status | IS | O | 1 |
| OM7.23 | Special Order Indicator | ID | O | 1 |
| OM7.24 | Primary Key Value Cdm | CE | O | * |

---

## ORC -- Common Order

31 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ORC.1 | Order Control | ID | R | 1 |
| ORC.2 | Placer Order Number | EI | C | 1 |
| ORC.3 | Filler Order Number | EI | C | 1 |
| ORC.4 | Placer Group Number | EI | O | 1 |
| ORC.5 | Order Status | ID | O | 1 |
| ORC.6 | Response Flag | ID | O | 1 |
| ORC.7 | Quantity Timing | TQ | B | * |
| ORC.8 | Parent | EIP | O | 1 |
| ORC.9 | Date Time Of Transaction | TS | O | 1 |
| ORC.10 | Entered By | XCN | O | * |
| ORC.11 | Verified By | XCN | O | * |
| ORC.12 | Ordering Provider | XCN | O | * |
| ORC.13 | Enterers Location | PL | O | 1 |
| ORC.14 | Call Back Phone Number | XTN | O | * |
| ORC.15 | Order Effective Date Time | TS | O | 1 |
| ORC.16 | Order Control Code Reason | CE | O | 1 |
| ORC.17 | Entering Organization | CE | O | 1 |
| ORC.18 | Entering Device | CE | O | 1 |
| ORC.19 | Action By | XCN | O | * |
| ORC.20 | Advanced Beneficiary Notice Code | CE | O | 1 |
| ORC.21 | Ordering Facility Name | XON | O | * |
| ORC.22 | Ordering Facility Address | XAD | O | * |
| ORC.23 | Ordering Facility Phone Number | XTN | O | * |
| ORC.24 | Ordering Provider Address | XAD | O | * |
| ORC.25 | Order Status Modifier | CWE | O | 1 |
| ORC.26 | Advanced Beneficiary Notice Override Reason | CWE | O | 1 |
| ORC.27 | Fillers Expected Availability Date Time | TS | O | 1 |
| ORC.28 | Confidentiality Code | CWE | O | 1 |
| ORC.29 | Order Type | CWE | O | 1 |
| ORC.30 | Enterer Authorization Mode | CNE | O | 1 |
| ORC.31 | Parent Universal Service Identifier | CWE | O | 1 |

---

## ORG -- Practitioner Organization Unit

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ORG.1 | Set Id | SI | R | 1 |
| ORG.2 | Organization Unit Code | CE | O | 1 |
| ORG.3 | Organization Unit Type Code | CE | O | 1 |
| ORG.4 | Primary Org Unit Indicator | ID | O | 1 |
| ORG.5 | Practitioner Org Unit Identifier | CX | O | 1 |
| ORG.6 | Health Care Provider Type Code | CE | O | 1 |
| ORG.7 | Health Care Provider Classification Code | CE | O | 1 |
| ORG.8 | Health Care Provider Area Of Specialization Code | CE | O | 1 |
| ORG.9 | Effective Date Range | DR | O | 1 |
| ORG.10 | Employment Status Code | CE | O | 1 |
| ORG.11 | Board Approval Indicator | ID | O | 1 |
| ORG.12 | Primary Care Physician Indicator | ID | O | 1 |

---

## OVR -- Override Segment

5 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| OVR.1 | Business Rule Override Type | CWE | O | 1 |
| OVR.2 | Business Rule Override Code | CWE | O | 1 |
| OVR.3 | Override Comments | TX | O | 1 |
| OVR.4 | Override Entered By | XCN | O | 1 |
| OVR.5 | Override Authorized By | XCN | O | 1 |

---

## PCR -- Possible Causal Relationship

23 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PCR.1 | Implicated Product | CE | R | 1 |
| PCR.2 | Generic Product | IS | O | 1 |
| PCR.3 | Product Class | CE | O | 1 |
| PCR.4 | Total Duration Of Therapy | CQ | O | 1 |
| PCR.5 | Product Manufacture Date | TS | O | 1 |
| PCR.6 | Product Expiration Date | TS | O | 1 |
| PCR.7 | Product Implantation Date | TS | O | 1 |
| PCR.8 | Product Explantation Date | TS | O | 1 |
| PCR.9 | Single Use Device | IS | O | 1 |
| PCR.10 | Indication For Product Use | CE | O | 1 |
| PCR.11 | Product Problem | IS | O | 1 |
| PCR.12 | Product Serial Lot Number | ST | O | * |
| PCR.13 | Product Available For Inspection | IS | O | 1 |
| PCR.14 | Product Evaluation Performed | CE | O | 1 |
| PCR.15 | Product Evaluation Status | CE | O | 1 |
| PCR.16 | Product Evaluation Results | CE | O | 1 |
| PCR.17 | Evaluated Product Source | ID | O | 1 |
| PCR.18 | Date Product Returned To Manufacturer | TS | O | 1 |
| PCR.19 | Device Operator Qualifications | ID | O | 1 |
| PCR.20 | Relatedness Assessment | ID | O | 1 |
| PCR.21 | Action Taken In Response To The Event | ID | O | * |
| PCR.22 | Event Causality Observations | ID | O | * |
| PCR.23 | Indirect Exposure Mechanism | ID | O | * |

---

## PD1 -- Patient Additional Demographic

21 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PD1.1 | Living Dependency | IS | O | * |
| PD1.2 | Living Arrangement | IS | O | 1 |
| PD1.3 | Patient Primary Facility | XON | O | * |
| PD1.4 | Patient Primary Care Provider Name And Id No | XCN | B | * |
| PD1.5 | Student Indicator | IS | O | 1 |
| PD1.6 | Handicap | IS | O | 1 |
| PD1.7 | Living Will Code | IS | O | 1 |
| PD1.8 | Organ Donor Code | IS | O | 1 |
| PD1.9 | Separate Bill | ID | O | 1 |
| PD1.10 | Duplicate Patient | CX | O | * |
| PD1.11 | Publicity Code | CE | O | 1 |
| PD1.12 | Protection Indicator | ID | O | 1 |
| PD1.13 | Protection Indicator Effective Date | DT | O | 1 |
| PD1.14 | Place Of Worship | XON | O | * |
| PD1.15 | Advance Directive Code | CE | O | * |
| PD1.16 | Immunization Registry Status | IS | O | 1 |
| PD1.17 | Immunization Registry Status Effective Date | DT | O | 1 |
| PD1.18 | Publicity Code Effective Date | DT | O | 1 |
| PD1.19 | Military Branch | IS | O | 1 |
| PD1.20 | Military Rank Grade | IS | O | 1 |
| PD1.21 | Military Status | IS | O | 1 |

---

## PDA -- Patient Death and Autopsy

9 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PDA.1 | Death Cause Code | CE | O | * |
| PDA.2 | Death Location | PL | O | 1 |
| PDA.3 | Death Certified Indicator | ID | O | 1 |
| PDA.4 | Death Certificate Signed Date Time | TS | O | 1 |
| PDA.5 | Death Certified By | XCN | O | 1 |
| PDA.6 | Autopsy Indicator | ID | O | 1 |
| PDA.7 | Autopsy Start And End Date Time | DR | O | 1 |
| PDA.8 | Autopsy Performed By | XCN | O | 1 |
| PDA.9 | Coroner Indicator | ID | O | 1 |

---

## PDC -- Product Detail Country

15 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PDC.1 | Manufacturer Distributor | XON | R | * |
| PDC.2 | Country | CE | R | 1 |
| PDC.3 | Brand Name | ST | R | 1 |
| PDC.4 | Device Family Name | ST | O | 1 |
| PDC.5 | Generic Name | CE | O | 1 |
| PDC.6 | Model Identifier | ST | O | * |
| PDC.7 | Catalogue Identifier | ST | O | 1 |
| PDC.8 | Other Identifier | ST | O | * |
| PDC.9 | Product Code | CE | O | 1 |
| PDC.10 | Marketing Basis | ID | O | 1 |
| PDC.11 | Marketing Approval Id | ST | O | 1 |
| PDC.12 | Labeled Shelf Life | CQ | O | 1 |
| PDC.13 | Expected Shelf Life | CQ | O | 1 |
| PDC.14 | Date First Marketed | TS | O | 1 |
| PDC.15 | Date Last Marketed | TS | O | 1 |

---

## PEO -- Product Experience Observation

25 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PEO.1 | Event Identifiers Used | CE | O | * |
| PEO.2 | Event Symptom Diagnosis Code | CE | O | * |
| PEO.3 | Event Onset Date Time | TS | R | 1 |
| PEO.4 | Event Exacerbation Date Time | TS | O | 1 |
| PEO.5 | Event Improved Date Time | TS | O | 1 |
| PEO.6 | Event Ended Data Time | TS | O | 1 |
| PEO.7 | Event Location Occurred Address | XAD | O | * |
| PEO.8 | Event Qualification | ID | O | * |
| PEO.9 | Event Serious | ID | O | 1 |
| PEO.10 | Event Expected | ID | O | 1 |
| PEO.11 | Event Outcome | ID | O | * |
| PEO.12 | Patient Outcome | ID | O | 1 |
| PEO.13 | Event Description From Others | FT | O | * |
| PEO.14 | Event From Original Reporter | FT | O | * |
| PEO.15 | Event Description From Patient | FT | O | * |
| PEO.16 | Event Description From Practitioner | FT | O | * |
| PEO.17 | Event Description From Autopsy | FT | O | * |
| PEO.18 | Cause Of Death | CE | O | * |
| PEO.19 | Primary Observer Name | XPN | O | * |
| PEO.20 | Primary Observer Address | XAD | O | * |
| PEO.21 | Primary Observer Telephone | XTN | O | * |
| PEO.22 | Primary Observers Qualification | ID | O | 1 |
| PEO.23 | Confirmation Provided By | ID | O | 1 |
| PEO.24 | Primary Observer Aware Date Time | TS | O | 1 |
| PEO.25 | Primary Observers Identity May Be Divulged | ID | O | 1 |

---

## PES -- Product Experience Sender

13 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PES.1 | Sender Organization Name | XON | O | * |
| PES.2 | Sender Individual Name | XCN | O | * |
| PES.3 | Sender Address | XAD | O | * |
| PES.4 | Sender Telephone | XTN | O | * |
| PES.5 | Sender Event Identifier | EI | O | 1 |
| PES.6 | Sender Sequence Number | NM | O | 1 |
| PES.7 | Sender Event Description | FT | O | * |
| PES.8 | Sender Comment | FT | O | 1 |
| PES.9 | Sender Aware Date Time | TS | O | 1 |
| PES.10 | Event Report Date | TS | R | 1 |
| PES.11 | Event Report Timing Type | ID | O | * |
| PES.12 | Event Report Source | ID | O | 1 |
| PES.13 | Event Reported To | ID | O | * |

---

## PID -- Patient Identification

39 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PID.1 | Set Id | SI | O | 1 |
| PID.2 | Patient Id | CX | B | 1 |
| PID.3 | Patient Identifier List | CX | R | * |
| PID.4 | Alternate Patient Id | CX | B | * |
| PID.5 | Patient Name | XPN | R | * |
| PID.6 | Mothers Maiden Name | XPN | O | * |
| PID.7 | Date Time Of Birth | TS | O | 1 |
| PID.8 | Administrative Sex | IS | O | 1 |
| PID.9 | Patient Alias | XPN | B | * |
| PID.10 | Race | CE | O | * |
| PID.11 | Patient Address | XAD | O | * |
| PID.12 | County Code | IS | B | 1 |
| PID.13 | Phone Number Home | XTN | O | * |
| PID.14 | Phone Number Business | XTN | O | * |
| PID.15 | Primary Language | CE | O | 1 |
| PID.16 | Marital Status | CE | O | 1 |
| PID.17 | Religion | CE | O | 1 |
| PID.18 | Patient Account Number | CX | O | 1 |
| PID.19 | Ssn Number | ST | B | 1 |
| PID.20 | Drivers License Number | DLN | B | 1 |
| PID.21 | Mothers Identifier | CX | O | * |
| PID.22 | Ethnic Group | CE | O | * |
| PID.23 | Birth Place | ST | O | 1 |
| PID.24 | Multiple Birth Indicator | ID | O | 1 |
| PID.25 | Birth Order | NM | O | 1 |
| PID.26 | Citizenship | CE | O | * |
| PID.27 | Veterans Military Status | CE | O | 1 |
| PID.28 | Nationality | CE | B | 1 |
| PID.29 | Patient Death Date And Time | TS | O | 1 |
| PID.30 | Patient Death Indicator | ID | O | 1 |
| PID.31 | Identity Unknown Indicator | ID | O | 1 |
| PID.32 | Identity Reliability Code | IS | O | * |
| PID.33 | Last Update Date Time | TS | O | 1 |
| PID.34 | Last Update Facility | HD | O | 1 |
| PID.35 | Species Code | CE | C | 1 |
| PID.36 | Breed Code | CE | C | 1 |
| PID.37 | Strain | ST | O | 1 |
| PID.38 | Production Class Code | CE | O | 1 |
| PID.39 | Tribal Citizenship | CWE | O | * |

---

## PR1 -- Procedures

20 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PR1.1 | Set Id | SI | R | 1 |
| PR1.2 | Procedure Coding Method | IS | B | 1 |
| PR1.3 | Procedure Code | CE | R | 1 |
| PR1.4 | Procedure Description | ST | B | 1 |
| PR1.5 | Procedure Date Time | TS | R | 1 |
| PR1.6 | Procedure Functional Type | IS | O | 1 |
| PR1.7 | Procedure Minutes | NM | O | 1 |
| PR1.8 | Anesthesiologist | XCN | B | * |
| PR1.9 | Anesthesia Code | IS | O | 1 |
| PR1.10 | Anesthesia Minutes | NM | O | 1 |
| PR1.11 | Surgeon | XCN | B | * |
| PR1.12 | Procedure Practitioner | XCN | B | * |
| PR1.13 | Consent Code | CE | O | 1 |
| PR1.14 | Procedure Priority | ID | O | 1 |
| PR1.15 | Associated Diagnosis Code | CE | O | 1 |
| PR1.16 | Procedure Code Modifier | CE | O | * |
| PR1.17 | Procedure Drg Type | IS | O | 1 |
| PR1.18 | Tissue Type Code | CE | O | * |
| PR1.19 | Procedure Identifier | EI | O | 1 |
| PR1.20 | Procedure Action Code | ID | O | 1 |

---

## PRA -- Practitioner Detail

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PRA.1 | Primary Key Value | CE | C | 1 |
| PRA.2 | Practitioner Group | CE | O | * |
| PRA.3 | Practitioner Category | IS | O | * |
| PRA.4 | Provider Billing | ID | O | 1 |
| PRA.5 | Specialty | SPD | O | * |
| PRA.6 | Practitioner Id Numbers | PLN | O | * |
| PRA.7 | Privileges | PIP | O | * |
| PRA.8 | Date Entered Practice | DT | O | 1 |
| PRA.9 | Institution | CE | O | 1 |
| PRA.10 | Date Left Practice | DT | O | 1 |
| PRA.11 | Government Reimbursement Billing Eligibility | CE | O | * |
| PRA.12 | Set Id | SI | C | 1 |

---

## PRB -- Problem Details

25 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PRB.1 | Action Code | ID | R | 1 |
| PRB.2 | Action Date Time | TS | R | 1 |
| PRB.3 | Problem Id | CE | R | 1 |
| PRB.4 | Problem Instance Id | EI | R | 1 |
| PRB.5 | Episode Of Care Id | EI | O | 1 |
| PRB.6 | Problem List Priority | NM | O | 1 |
| PRB.7 | Problem Established Date Time | TS | O | 1 |
| PRB.8 | Anticipated Problem Resolution Date Time | TS | O | 1 |
| PRB.9 | Actual Problem Resolution Date Time | TS | O | 1 |
| PRB.10 | Problem Classification | CE | O | 1 |
| PRB.11 | Problem Management Discipline | CE | O | * |
| PRB.12 | Problem Persistence | CE | O | 1 |
| PRB.13 | Problem Confirmation Status | CE | O | 1 |
| PRB.14 | Problem Life Cycle Status | CE | O | 1 |
| PRB.15 | Problem Life Cycle Status Date Time | TS | O | 1 |
| PRB.16 | Problem Date Of Onset | TS | O | 1 |
| PRB.17 | Problem Onset Text | ST | O | 1 |
| PRB.18 | Problem Ranking | CE | O | 1 |
| PRB.19 | Certainty Of Problem | CE | O | 1 |
| PRB.20 | Probability Of Problem | NM | O | 1 |
| PRB.21 | Individual Awareness Of Problem | CE | O | 1 |
| PRB.22 | Problem Prognosis | CE | O | 1 |
| PRB.23 | Individual Awareness Of Prognosis | CE | O | 1 |
| PRB.24 | Family Significant Other Awareness Of Problem Prognosis | ST | O | 1 |
| PRB.25 | Security Sensitivity | CE | O | 1 |

---

## PRC -- Pricing

18 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PRC.1 | Primary Key Value | CE | R | 1 |
| PRC.2 | Facility Id | CE | O | * |
| PRC.3 | Department | CE | O | * |
| PRC.4 | Valid Patient Classes | IS | O | * |
| PRC.5 | Price | CP | O | * |
| PRC.6 | Formula | ST | O | * |
| PRC.7 | Minimum Quantity | NM | O | 1 |
| PRC.8 | Maximum Quantity | NM | O | 1 |
| PRC.9 | Minimum Price | MO | O | 1 |
| PRC.10 | Maximum Price | MO | O | 1 |
| PRC.11 | Effective Start Date | TS | O | 1 |
| PRC.12 | Effective End Date | TS | O | 1 |
| PRC.13 | Price Override Flag | IS | O | 1 |
| PRC.14 | Billing Category | CE | O | * |
| PRC.15 | Chargeable Flag | ID | O | 1 |
| PRC.16 | Active Inactive Flag | ID | O | 1 |
| PRC.17 | Cost | MO | O | 1 |
| PRC.18 | Charge On Indicator | IS | O | 1 |

---

## PRD -- Provider Data

9 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PRD.1 | Provider Role | CE | R | * |
| PRD.2 | Provider Name | XPN | O | * |
| PRD.3 | Provider Address | XAD | O | 1 |
| PRD.4 | Provider Location | PL | O | 1 |
| PRD.5 | Provider Communication Information | XTN | O | * |
| PRD.6 | Preferred Method Of Contact | CE | O | 1 |
| PRD.7 | Provider Identifiers | PLN | O | * |
| PRD.8 | Effective Start Date Of Provider Role | TS | O | 1 |
| PRD.9 | Effective End Date Of Provider Role | TS | O | * |

---

## PSH -- Product Summary Header

14 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PSH.1 | Report Type | ST | R | 1 |
| PSH.2 | Report Form Identifier | ST | O | 1 |
| PSH.3 | Report Date | TS | R | 1 |
| PSH.4 | Report Interval Start Date | TS | O | 1 |
| PSH.5 | Report Interval End Date | TS | O | 1 |
| PSH.6 | Quantity Manufactured | CQ | O | 1 |
| PSH.7 | Quantity Distributed | CQ | O | 1 |
| PSH.8 | Quantity Distributed Method | ID | O | 1 |
| PSH.9 | Quantity Distributed Comment | FT | O | 1 |
| PSH.10 | Quantity In Use | CQ | O | 1 |
| PSH.11 | Quantity In Use Method | ID | O | 1 |
| PSH.12 | Quantity In Use Comment | FT | O | 1 |
| PSH.13 | Number Of Product Experience Reports Filed By Facility | NM | O | * |
| PSH.14 | Number Of Product Experience Reports Filed By Distributor | NM | O | * |

---

## PTH -- Pathway

6 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PTH.1 | Action Code | ID | R | 1 |
| PTH.2 | Pathway Id | CE | R | 1 |
| PTH.3 | Pathway Instance Id | EI | R | 1 |
| PTH.4 | Pathway Established Date Time | TS | R | 1 |
| PTH.5 | Pathway Life Cycle Status | CE | O | 1 |
| PTH.6 | Change Pathway Life Cycle Status Date Time | TS | O | 1 |

---

## PV1 -- Patient Visit

52 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PV1.1 | Set Id | SI | O | 1 |
| PV1.2 | Patient Class | IS | R | 1 |
| PV1.3 | Assigned Patient Location | PL | O | 1 |
| PV1.4 | Admission Type | IS | O | 1 |
| PV1.5 | Preadmit Number | CX | O | 1 |
| PV1.6 | Prior Patient Location | PL | O | 1 |
| PV1.7 | Attending Doctor | XCN | O | * |
| PV1.8 | Referring Doctor | XCN | O | * |
| PV1.9 | Consulting Doctor | XCN | O | * |
| PV1.10 | Hospital Service | IS | O | 1 |
| PV1.11 | Temporary Location | PL | O | 1 |
| PV1.12 | Preadmit Test Indicator | IS | O | 1 |
| PV1.13 | Re Admission Indicator | IS | O | 1 |
| PV1.14 | Admit Source | IS | O | 1 |
| PV1.15 | Ambulatory Status | IS | O | * |
| PV1.16 | Vip Indicator | IS | O | 1 |
| PV1.17 | Admitting Doctor | XCN | O | * |
| PV1.18 | Patient Type | IS | O | 1 |
| PV1.19 | Visit Number | CX | O | 1 |
| PV1.20 | Financial Class | FC | O | * |
| PV1.21 | Charge Price Indicator | IS | O | 1 |
| PV1.22 | Courtesy Code | IS | O | 1 |
| PV1.23 | Credit Rating | IS | O | 1 |
| PV1.24 | Contract Code | IS | O | * |
| PV1.25 | Contract Effective Date | DT | O | * |
| PV1.26 | Contract Amount | NM | O | * |
| PV1.27 | Contract Period | NM | O | * |
| PV1.28 | Interest Code | IS | O | 1 |
| PV1.29 | Transfer To Bad Debt Code | IS | O | 1 |
| PV1.30 | Transfer To Bad Debt Date | DT | O | 1 |
| PV1.31 | Bad Debt Agency Code | IS | O | 1 |
| PV1.32 | Bad Debt Transfer Amount | NM | O | 1 |
| PV1.33 | Bad Debt Recovery Amount | NM | O | 1 |
| PV1.34 | Delete Account Indicator | IS | O | 1 |
| PV1.35 | Delete Account Date | DT | O | 1 |
| PV1.36 | Discharge Disposition | IS | O | 1 |
| PV1.37 | Discharged To Location | DLD | O | 1 |
| PV1.38 | Diet Type | CE | O | 1 |
| PV1.39 | Servicing Facility | IS | O | 1 |
| PV1.40 | Bed Status | IS | B | 1 |
| PV1.41 | Account Status | IS | O | 1 |
| PV1.42 | Pending Location | PL | O | 1 |
| PV1.43 | Prior Temporary Location | PL | O | 1 |
| PV1.44 | Admit Date Time | TS | O | 1 |
| PV1.45 | Discharge Date Time | TS | O | * |
| PV1.46 | Current Patient Balance | NM | O | 1 |
| PV1.47 | Total Charges | NM | O | 1 |
| PV1.48 | Total Adjustments | NM | O | 1 |
| PV1.49 | Total Payments | NM | O | 1 |
| PV1.50 | Alternate Visit Id | CX | O | 1 |
| PV1.51 | Visit Indicator | IS | O | 1 |
| PV1.52 | Other Healthcare Provider | XCN | B | * |

---

## PV2 -- Patient Visit — Additional Information

49 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| PV2.1 | Prior Pending Location | PL | C | 1 |
| PV2.2 | Accommodation Code | CE | O | 1 |
| PV2.3 | Admit Reason | CE | O | 1 |
| PV2.4 | Transfer Reason | CE | O | 1 |
| PV2.5 | Patient Valuables | ST | O | * |
| PV2.6 | Patient Valuables Location | ST | O | 1 |
| PV2.7 | Visit User Code | IS | O | * |
| PV2.8 | Expected Admit Date Time | TS | O | 1 |
| PV2.9 | Expected Discharge Date Time | TS | O | 1 |
| PV2.10 | Estimated Length Of Inpatient Stay | NM | O | 1 |
| PV2.11 | Actual Length Of Inpatient Stay | NM | O | 1 |
| PV2.12 | Visit Description | ST | O | 1 |
| PV2.13 | Referral Source Code | XCN | O | * |
| PV2.14 | Previous Service Date | DT | O | 1 |
| PV2.15 | Employment Illness Related Indicator | ID | O | 1 |
| PV2.16 | Purge Status Code | IS | O | 1 |
| PV2.17 | Purge Status Date | DT | O | 1 |
| PV2.18 | Special Program Code | IS | O | 1 |
| PV2.19 | Retention Indicator | ID | O | 1 |
| PV2.20 | Expected Number Of Insurance Plans | NM | O | 1 |
| PV2.21 | Visit Publicity Code | IS | O | 1 |
| PV2.22 | Visit Protection Indicator | ID | O | 1 |
| PV2.23 | Clinic Organization Name | XON | O | * |
| PV2.24 | Patient Status Code | IS | O | 1 |
| PV2.25 | Visit Priority Code | IS | O | 1 |
| PV2.26 | Previous Treatment Date | DT | O | 1 |
| PV2.27 | Expected Discharge Disposition | IS | O | 1 |
| PV2.28 | Signature On File Date | DT | O | 1 |
| PV2.29 | First Similar Illness Date | DT | O | 1 |
| PV2.30 | Patient Charge Adjustment Code | CE | O | 1 |
| PV2.31 | Recurring Service Code | IS | O | 1 |
| PV2.32 | Billing Media Code | ID | O | 1 |
| PV2.33 | Expected Surgery Date And Time | TS | O | 1 |
| PV2.34 | Military Partnership Code | ID | O | 1 |
| PV2.35 | Military Non Availability Code | ID | O | 1 |
| PV2.36 | Newborn Baby Indicator | ID | O | 1 |
| PV2.37 | Baby Detained Indicator | ID | O | 1 |
| PV2.38 | Mode Of Arrival Code | CE | O | 1 |
| PV2.39 | Recreational Drug Use Code | CE | O | * |
| PV2.40 | Admission Level Of Care Code | CE | O | 1 |
| PV2.41 | Precaution Code | CE | O | * |
| PV2.42 | Patient Condition Code | CE | O | 1 |
| PV2.43 | Living Will Code | IS | O | 1 |
| PV2.44 | Organ Donor Code | IS | O | 1 |
| PV2.45 | Advance Directive Code | CE | O | * |
| PV2.46 | Patient Status Effective Date | DT | O | 1 |
| PV2.47 | Expected Loa Return Date Time | TS | O | 1 |
| PV2.48 | Expected Pre Admission Testing Date Time | TS | O | 1 |
| PV2.49 | Notify Clergy Code | IS | O | * |

---

## QAK -- Query Acknowledgment

6 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| QAK.1 | Query Tag | ST | C | 1 |
| QAK.2 | Query Response Status | ID | O | 1 |
| QAK.3 | Message Query Name | CE | O | 1 |
| QAK.4 | Hit Count Total | NM | O | 1 |
| QAK.5 | This Payload | NM | O | 1 |
| QAK.6 | Hits Remaining | NM | O | 1 |

---

## QID -- Query Identification

2 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| QID.1 | Query Tag | ST | R | 1 |
| QID.2 | Message Query Name | CE | R | 1 |

---

## QPD -- Query Parameter Definition

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| QPD.1 | Message Query Name | CE | R | 1 |
| QPD.2 | Query Tag | ST | R | 1 |
| QPD.3 | User Parameters In Successive Fields | varies | O | 1 |

---

## QRD -- Original-Style Query Definition

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| QRD.1 | Query Date Time | TS | R | 1 |
| QRD.2 | Query Format Code | ID | R | 1 |
| QRD.3 | Query Priority | ID | R | 1 |
| QRD.4 | Query Id | ST | R | 1 |
| QRD.5 | Deferred Response Type | ID | O | 1 |
| QRD.6 | Deferred Response Date Time | TS | O | 1 |
| QRD.7 | Quantity Limited Request | CQ | R | 1 |
| QRD.8 | Who Subject Filter | XCN | R | * |
| QRD.9 | What Subject Filter | CE | R | * |
| QRD.10 | What Department Data Code | CE | R | * |
| QRD.11 | What Data Code Value Qual | VR | O | * |
| QRD.12 | Query Results Level | ID | O | 1 |

---

## QRF -- Original Style Query Filter

10 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| QRF.1 | Where Subject Filter | ST | R | * |
| QRF.2 | When Data Start Date Time | TS | O | 1 |
| QRF.3 | When Data End Date Time | TS | O | 1 |
| QRF.4 | What User Qualifier | ST | O | * |
| QRF.5 | Other Qry Subject Filter | ST | O | * |
| QRF.6 | Which Date Time Qualifier | ID | O | * |
| QRF.7 | Which Date Time Status Qualifier | ID | O | * |
| QRF.8 | Date Time Selection Qualifier | ID | O | * |
| QRF.9 | When Quantity Timing Qualifier | TQ | O | 1 |
| QRF.10 | Search Confidence Threshold | NM | O | 1 |

---

## QRI -- Query Response Instance

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| QRI.1 | Candidate Confidence | NM | O | 1 |
| QRI.2 | Match Reason Code | IS | O | * |
| QRI.3 | Algorithm Descriptor | CE | O | 1 |

---

## RCP -- Response Control Parameter

7 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RCP.1 | Query Priority | ID | O | 1 |
| RCP.2 | Quantity Limited Request | CQ | O | 1 |
| RCP.3 | Response Modality | CE | O | 1 |
| RCP.4 | Execution And Delivery Time | TS | O | 1 |
| RCP.5 | Modify Indicator | ID | O | 1 |
| RCP.6 | Sort By Field | SRT | O | * |
| RCP.7 | Segment Group Inclusion | ST | O | * |

---

## RDF -- Table Row Definition

2 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RDF.1 | Number Of Columns Per Row | NM | R | 1 |
| RDF.2 | Column Description | RCD | R | * |

---

## RDT -- Table Row Data

1 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RDT.1 | Column Value | varies | R | 1 |

---

## RF1 -- Referral Information

11 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RF1.1 | Referral Status | CE | O | 1 |
| RF1.2 | Referral Priority | CE | O | 1 |
| RF1.3 | Referral Type | CE | O | 1 |
| RF1.4 | Referral Disposition | CE | O | * |
| RF1.5 | Referral Category | CE | O | 1 |
| RF1.6 | Originating Referral Identifier | EI | R | 1 |
| RF1.7 | Effective Date | TS | O | 1 |
| RF1.8 | Expiration Date | TS | O | 1 |
| RF1.9 | Process Date | TS | O | 1 |
| RF1.10 | Referral Reason | CE | O | * |
| RF1.11 | External Referral Identifier | EI | O | * |

---

## RGS -- Resource Group

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RGS.1 | Set Id | SI | R | 1 |
| RGS.2 | Segment Action Code | ID | C | 1 |
| RGS.3 | Resource Group Id | CE | O | 1 |

---

## RMI -- Risk Management Incident

3 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RMI.1 | Risk Management Incident Code | CE | O | 1 |
| RMI.2 | Date Time Incident | TS | O | 1 |
| RMI.3 | Incident Type Code | CE | O | 1 |

---

## ROL -- Role

12 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| ROL.1 | Role Instance Id | EI | O | 1 |
| ROL.2 | Action Code | ID | R | 1 |
| ROL.3 | Role | CE | R | 1 |
| ROL.4 | Role Person | XCN | R | * |
| ROL.5 | Role Begin Date Time | TS | O | 1 |
| ROL.6 | Role End Date Time | TS | O | 1 |
| ROL.7 | Role Duration | CE | O | 1 |
| ROL.8 | Role Action Reason | CE | O | 1 |
| ROL.9 | Provider Type | CE | O | * |
| ROL.10 | Organization Unit Type | CE | O | 1 |
| ROL.11 | Office Home Address Birthplace | XAD | O | * |
| ROL.12 | Phone | XTN | O | * |

---

## RQ1 -- Requisition Detail-1

7 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RQ1.1 | Anticipated Price | ST | O | 1 |
| RQ1.2 | Manufacturer Identifier | CE | O | 1 |
| RQ1.3 | Manufacturers Catalog | ST | O | 1 |
| RQ1.4 | Vendor Id | CE | O | 1 |
| RQ1.5 | Vendor Catalog | ST | O | 1 |
| RQ1.6 | Taxable | ID | O | 1 |
| RQ1.7 | Substitute Allowed | ID | O | 1 |

---

## RQD -- Requisition Detail

10 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RQD.1 | Requisition Line Number | SI | O | 1 |
| RQD.2 | Item Code Internal | CE | O | 1 |
| RQD.3 | Item Code External | CE | O | 1 |
| RQD.4 | Hospital Item Code | CE | O | 1 |
| RQD.5 | Requisition Quantity | NM | O | 1 |
| RQD.6 | Requisition Unit Of Measure | CE | O | 1 |
| RQD.7 | Dept Cost Center | IS | O | 1 |
| RQD.8 | Item Natural Account Code | IS | O | 1 |
| RQD.9 | Deliver To Id | CE | O | 1 |
| RQD.10 | Date Needed | DT | O | 1 |

---

## RXA -- Pharmacy/Treatment Administration

26 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RXA.1 | Give Sub Id Counter | NM | R | 1 |
| RXA.2 | Administration Sub Id Counter | NM | R | 1 |
| RXA.3 | Date Time Start Of Administration | TS | R | 1 |
| RXA.4 | Date Time End Of Administration | TS | O | 1 |
| RXA.5 | Administered Code | CE | R | 1 |
| RXA.6 | Administered Amount | NM | R | 1 |
| RXA.7 | Administered Units | CE | O | 1 |
| RXA.8 | Administered Dosage Form | CE | O | 1 |
| RXA.9 | Administration Notes | CE | O | * |
| RXA.10 | Administering Provider | XCN | O | * |
| RXA.11 | Administered At Location | LA2 | O | 1 |
| RXA.12 | Administered Per Time Unit | ST | O | 1 |
| RXA.13 | Administered Strength | NM | O | 1 |
| RXA.14 | Administered Strength Units | CE | O | 1 |
| RXA.15 | Substance Lot Number | ST | O | * |
| RXA.16 | Substance Expiration Date | TS | O | * |
| RXA.17 | Substance Manufacturer Name | CE | O | * |
| RXA.18 | Substance Treatment Refusal Reason | CE | O | * |
| RXA.19 | Indication | CE | O | * |
| RXA.20 | Completion Status | ID | O | 1 |
| RXA.21 | Action Code | ID | O | 1 |
| RXA.22 | System Entry Date Time | TS | O | 1 |
| RXA.23 | Administered Drug Strength Volume | NM | O | 1 |
| RXA.24 | Administered Drug Strength Volume Units | CWE | O | 1 |
| RXA.25 | Administered Barcode Identifier | CWE | O | 1 |
| RXA.26 | Pharmacy Order Type | ID | O | 1 |

---

## RXC -- Pharmacy/Treatment Component Order

9 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RXC.1 | Rx Component Type | ID | R | 1 |
| RXC.2 | Component Code | CE | R | 1 |
| RXC.3 | Component Amount | NM | R | 1 |
| RXC.4 | Component Units | CE | R | 1 |
| RXC.5 | Component Strength | NM | O | 1 |
| RXC.6 | Component Strength Units | CE | O | 1 |
| RXC.7 | Supplementary Code | CE | O | * |
| RXC.8 | Component Drug Strength Volume | NM | O | 1 |
| RXC.9 | Component Drug Strength Volume Units | CWE | O | 1 |

---

## RXD -- Pharmacy/Treatment Dispense

33 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RXD.1 | Dispense Sub Id Counter | NM | R | 1 |
| RXD.2 | Dispense Give Code | CE | R | 1 |
| RXD.3 | Date Time Dispensed | TS | R | 1 |
| RXD.4 | Actual Dispense Amount | NM | R | 1 |
| RXD.5 | Actual Dispense Units | CE | O | 1 |
| RXD.6 | Actual Dosage Form | CE | O | 1 |
| RXD.7 | Prescription Number | ST | R | 1 |
| RXD.8 | Number Of Refills Remaining | NM | O | 1 |
| RXD.9 | Dispense Notes | ST | O | * |
| RXD.10 | Dispensing Provider | XCN | O | * |
| RXD.11 | Substitution Status | ID | O | 1 |
| RXD.12 | Total Daily Dose | CQ | O | 1 |
| RXD.13 | Dispense To Location | LA1 | O | 1 |
| RXD.14 | Needs Human Review | ID | O | 1 |
| RXD.15 | Pharmacy Treatment Suppliers Special Dispensing Instructions | CE | O | * |
| RXD.16 | Actual Strength | NM | O | 1 |
| RXD.17 | Actual Strength Unit | CE | O | 1 |
| RXD.18 | Substance Lot Number | ST | O | * |
| RXD.19 | Substance Expiration Date | TS | O | * |
| RXD.20 | Substance Manufacturer Name | CE | O | * |
| RXD.21 | Indication | CE | O | * |
| RXD.22 | Dispense Package Size | NM | O | 1 |
| RXD.23 | Dispense Package Size Unit | CE | O | 1 |
| RXD.24 | Dispense Package Method | ID | O | 1 |
| RXD.25 | Supplementary Code | CE | O | * |
| RXD.26 | Initiating Location | CE | O | 1 |
| RXD.27 | Packaging Assembly Location | CE | O | 1 |
| RXD.28 | Actual Drug Strength Volume | NM | O | 1 |
| RXD.29 | Actual Drug Strength Volume Units | CWE | O | 1 |
| RXD.30 | Dispense To Pharmacy | CWE | O | 1 |
| RXD.31 | Dispense To Pharmacy Address | XAD | O | 1 |
| RXD.32 | Pharmacy Order Type | ID | O | 1 |
| RXD.33 | Dispense Type | CWE | O | 1 |

---

## RXE -- Pharmacy/Treatment Encoded Order

44 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RXE.1 | Quantity Timing | TQ | O | 1 |
| RXE.2 | Give Code | CE | R | 1 |
| RXE.3 | Give Amount Minimum | NM | R | 1 |
| RXE.4 | Give Amount Maximum | NM | O | 1 |
| RXE.5 | Give Units | CE | R | 1 |
| RXE.6 | Give Dosage Form | CE | O | 1 |
| RXE.7 | Providers Administration Instructions | CE | O | * |
| RXE.8 | Deliver To Location | LA1 | O | 1 |
| RXE.9 | Substitution Status | ID | O | 1 |
| RXE.10 | Dispense Amount | NM | O | 1 |
| RXE.11 | Dispense Units | CE | O | 1 |
| RXE.12 | Number Of Refills | NM | O | 1 |
| RXE.13 | Ordering Providers Dea Number | XCN | O | * |
| RXE.14 | Pharmacist Treatment Suppliers Verifier Id | XCN | O | * |
| RXE.15 | Prescription Number | ST | O | 1 |
| RXE.16 | Number Of Refills Remaining | NM | O | 1 |
| RXE.17 | Number Of Refills Doses Dispensed | NM | O | 1 |
| RXE.18 | Dt Of Most Recent Refill | TS | O | 1 |
| RXE.19 | Total Daily Dose | CQ | O | 1 |
| RXE.20 | Needs Human Review | ID | O | 1 |
| RXE.21 | Pharmacy Treatment Suppliers Special Dispensing Instructions | CE | O | * |
| RXE.22 | Give Per Time Unit | ST | O | 1 |
| RXE.23 | Give Rate Amount | ST | O | 1 |
| RXE.24 | Give Rate Units | CE | O | 1 |
| RXE.25 | Give Strength | NM | O | 1 |
| RXE.26 | Give Strength Units | CE | O | 1 |
| RXE.27 | Give Indication | CE | O | * |
| RXE.28 | Dispense Package Size | NM | O | 1 |
| RXE.29 | Dispense Package Size Unit | CE | O | 1 |
| RXE.30 | Dispense Package Method | ID | O | 1 |
| RXE.31 | Supplementary Code | CE | O | * |
| RXE.32 | Original Order Date Time | TS | O | 1 |
| RXE.33 | Give Drug Strength Volume | NM | O | 1 |
| RXE.34 | Give Drug Strength Volume Units | CWE | O | 1 |
| RXE.35 | Controlled Substance Schedule | CWE | O | 1 |
| RXE.36 | Formulary Status | ID | O | 1 |
| RXE.37 | Pharmaceutical Substance Alternative | CWE | O | * |
| RXE.38 | Pharmacy Of Most Recent Fill | CWE | O | 1 |
| RXE.39 | Initial Dispense Amount | NM | O | 1 |
| RXE.40 | Dispensing Pharmacy | CWE | O | 1 |
| RXE.41 | Dispensing Pharmacy Address | XAD | O | 1 |
| RXE.42 | Deliver To Patient Location | PL | O | 1 |
| RXE.43 | Deliver To Address | XAD | O | 1 |
| RXE.44 | Pharmacy Order Type | ID | O | 1 |

---

## RXG -- Pharmacy/Treatment Give

27 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RXG.1 | Give Sub Id Counter | NM | R | 1 |
| RXG.2 | Dispense Sub Id Counter | NM | O | 1 |
| RXG.3 | Quantity Timing | TQ | O | 1 |
| RXG.4 | Give Code | CE | R | 1 |
| RXG.5 | Give Amount Minimum | NM | R | 1 |
| RXG.6 | Give Amount Maximum | NM | O | 1 |
| RXG.7 | Give Units | CE | R | 1 |
| RXG.8 | Give Dosage Form | CE | O | 1 |
| RXG.9 | Administration Notes | CE | O | * |
| RXG.10 | Substitution Status | ID | O | 1 |
| RXG.11 | Dispense To Location | LA1 | O | 1 |
| RXG.12 | Needs Human Review | ID | O | 1 |
| RXG.13 | Pharmacy Treatment Suppliers Special Dispensing Instructions | CE | O | * |
| RXG.14 | Give Per Time Unit | ST | O | 1 |
| RXG.15 | Give Strength | NM | O | 1 |
| RXG.16 | Give Strength Units | CE | O | 1 |
| RXG.17 | Substance Lot Number | ST | O | * |
| RXG.18 | Substance Expiration Date | TS | O | * |
| RXG.19 | Substance Manufacturer Name | CE | O | * |
| RXG.20 | Indication | CE | O | * |
| RXG.21 | Give Drug Strength Volume | NM | O | 1 |
| RXG.22 | Give Drug Strength Volume Units | CWE | O | 1 |
| RXG.23 | Give Barcode Identifier | CWE | O | 1 |
| RXG.24 | Pharmacy Order Type | ID | O | 1 |
| RXG.25 | Dispense To Pharmacy | CWE | O | 1 |
| RXG.26 | Dispense To Pharmacy Address | XAD | O | 1 |
| RXG.27 | Deliver To Patient Location | PL | O | 1 |

---

## RXO -- Pharmacy/Treatment Order

25 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RXO.1 | Requested Give Code | CE | R | 1 |
| RXO.2 | Requested Give Amount Minimum | NM | O | 1 |
| RXO.3 | Requested Give Amount Maximum | NM | O | 1 |
| RXO.4 | Requested Give Units | CE | R | 1 |
| RXO.5 | Requested Dosage Form | CE | O | 1 |
| RXO.6 | Providers Pharmacy Treatment Instructions | CE | O | * |
| RXO.7 | Providers Administration Instructions | CE | O | * |
| RXO.8 | Deliver To Location | LA1 | O | 1 |
| RXO.9 | Allow Substitutions | ID | O | 1 |
| RXO.10 | Requested Dispense Code | CE | O | 1 |
| RXO.11 | Requested Dispense Amount | NM | O | 1 |
| RXO.12 | Requested Dispense Units | CE | O | 1 |
| RXO.13 | Number Of Refills | NM | O | 1 |
| RXO.14 | Ordering Providers Dea Number | XCN | O | * |
| RXO.15 | Pharmacist Treatment Suppliers Verifier Id | XCN | O | * |
| RXO.16 | Needs Human Review | ID | O | 1 |
| RXO.17 | Requested Give Per Time Unit | ST | O | 1 |
| RXO.18 | Requested Give Strength | NM | O | 1 |
| RXO.19 | Requested Give Strength Units | CE | O | 1 |
| RXO.20 | Indication | CE | O | * |
| RXO.21 | Requested Give Rate Amount | ST | O | 1 |
| RXO.22 | Requested Give Rate Units | CE | O | 1 |
| RXO.23 | Total Daily Dose | CQ | O | 1 |
| RXO.24 | Supplementary Code | CE | O | * |
| RXO.25 | Requested Drug Strength Volume | NM | O | 1 |

---

## RXR -- Pharmacy/Treatment Route

6 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| RXR.1 | Route | CE | R | 1 |
| RXR.2 | Administration Site | CWE | O | 1 |
| RXR.3 | Administration Device | CE | O | 1 |
| RXR.4 | Administration Method | CWE | O | 1 |
| RXR.5 | Routing Instruction | CE | O | 1 |
| RXR.6 | Administration Site Modifier | CWE | O | 1 |

---

## SAC -- Specimen Container Detail

44 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| SAC.1 | External Accession Identifier | EI | O | 1 |
| SAC.2 | Accession Identifier | EI | O | 1 |
| SAC.3 | Container Identifier | EI | O | 1 |
| SAC.4 | Primary Parent Container Identifier | EI | O | 1 |
| SAC.5 | Equipment Container Identifier | EI | O | 1 |
| SAC.6 | Specimen Source | SPS | O | 1 |
| SAC.7 | Registration Date Time | TS | O | 1 |
| SAC.8 | Container Status | CE | O | 1 |
| SAC.9 | Carrier Type | CE | O | 1 |
| SAC.10 | Carrier Identifier | EI | O | 1 |
| SAC.11 | Position In Carrier | CE | O | 1 |
| SAC.12 | Tray Type | CE | O | 1 |
| SAC.13 | Tray Identifier | EI | O | 1 |
| SAC.14 | Position In Tray | CE | O | 1 |
| SAC.15 | Location | CE | O | * |
| SAC.16 | Container Height | NM | O | 1 |
| SAC.17 | Container Diameter | NM | O | 1 |
| SAC.18 | Barrier Delta | NM | O | 1 |
| SAC.19 | Bottom Delta | NM | O | 1 |
| SAC.20 | Container Height Diameter Delta Units | CE | O | 1 |
| SAC.21 | Container Volume | NM | O | 1 |
| SAC.22 | Available Specimen Volume | NM | O | 1 |
| SAC.23 | Initial Specimen Volume | NM | O | 1 |
| SAC.24 | Volume Units | CE | O | 1 |
| SAC.25 | Separator Type | CE | O | 1 |
| SAC.26 | Cap Type | CE | O | 1 |
| SAC.27 | Additive | CWE | O | * |
| SAC.28 | Specimen Component | CE | O | 1 |
| SAC.29 | Dilution Factor | SN | O | 1 |
| SAC.30 | Treatment | CE | O | 1 |
| SAC.31 | Temperature | SN | O | 1 |
| SAC.32 | Hemolysis Index | NM | O | 1 |
| SAC.33 | Hemolysis Index Units | CE | O | 1 |
| SAC.34 | Lipemia Index | NM | O | 1 |
| SAC.35 | Lipemia Index Units | CE | O | 1 |
| SAC.36 | Icterus Index | NM | O | 1 |
| SAC.37 | Icterus Index Units | CE | O | 1 |
| SAC.38 | Fibrin Index | NM | O | 1 |
| SAC.39 | Fibrin Index Units | CE | O | 1 |
| SAC.40 | System Induced Contaminants | CE | O | * |
| SAC.41 | Drug Interference | CE | O | * |
| SAC.42 | Artificial Blood | CE | O | 1 |
| SAC.43 | Special Handling Code | CWE | O | * |
| SAC.44 | Other Environmental Factors | CE | O | * |

---

## SCD -- Anti-Microbial Cycle Data (v2.6)

36 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| SCD.1 | Cycle Start Time | TS | O | 1 |
| SCD.2 | Cycle Count | NM | O | 1 |
| SCD.3 | Temp Max | CQ | O | 1 |
| SCD.4 | Temp Min | CQ | O | 1 |
| SCD.5 | Load Number | NM | O | 1 |
| SCD.6 | Condition Time | CQ | O | 1 |
| SCD.7 | Sterilize Time | CQ | O | 1 |
| SCD.8 | Exhaust Time | CQ | O | 1 |
| SCD.9 | Total Cycle Time | CQ | O | 1 |
| SCD.10 | Device Status | CWE | O | 1 |
| SCD.11 | Cycle Start Date Time | TS | O | 1 |
| SCD.12 | Dry Time | CQ | O | 1 |
| SCD.13 | Leak Rate | CQ | O | 1 |
| SCD.14 | Control Temperature | CQ | O | 1 |
| SCD.15 | Sterilizer Temperature | CQ | O | 1 |
| SCD.16 | Cycle Complete Time | TS | O | 1 |
| SCD.17 | Under Temperature | CQ | O | 1 |
| SCD.18 | Over Temperature | CQ | O | 1 |
| SCD.19 | Abort Cycle | CNE | O | 1 |
| SCD.20 | Alarm | CNE | O | 1 |
| SCD.21 | Long In Charge Phase | CNE | O | 1 |
| SCD.22 | Long In Exhaust Phase | CNE | O | 1 |
| SCD.23 | Long In Fast Exhaust Phase | CNE | O | 1 |
| SCD.24 | Reset | CNE | O | 1 |
| SCD.25 | Operator Unload | XCN | O | 1 |
| SCD.26 | Door Open | CNE | O | 1 |
| SCD.27 | Reading Failure | CNE | O | 1 |
| SCD.28 | Cycle Type | CWE | O | 1 |
| SCD.29 | Thermal Rinse Time | CQ | O | 1 |
| SCD.30 | Wash Time | CQ | O | 1 |
| SCD.31 | Injection Rate | CQ | O | 1 |
| SCD.32 | Procedure Code | CNE | O | 1 |
| SCD.33 | Patient Identifier List | CX | O | * |
| SCD.34 | Attending Doctor | XCN | O | 1 |
| SCD.35 | Dilution Factor | SN | O | 1 |
| SCD.36 | Fill Time | CQ | O | 1 |

---

## SCH -- Scheduling Activity Information

27 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| SCH.1 | Placer Appointment Id | EI | C | 1 |
| SCH.2 | Filler Appointment Id | EI | C | 1 |
| SCH.3 | Occurrence Number | NM | C | 1 |
| SCH.4 | Placer Group Number | EI | O | 1 |
| SCH.5 | Schedule Id | CE | O | 1 |
| SCH.6 | Event Reason | CE | R | 1 |
| SCH.7 | Appointment Reason | CE | O | 1 |
| SCH.8 | Appointment Type | CE | O | 1 |
| SCH.9 | Appointment Duration | NM | O | 1 |
| SCH.10 | Appointment Duration Units | CE | O | 1 |
| SCH.11 | Appointment Timing Quantity | TQ | B | * |
| SCH.12 | Placer Contact Person | XCN | O | * |
| SCH.13 | Placer Contact Phone Number | XTN | O | 1 |
| SCH.14 | Placer Contact Address | XAD | O | * |
| SCH.15 | Placer Contact Location | PL | O | 1 |
| SCH.16 | Filler Contact Person | XCN | R | * |
| SCH.17 | Filler Contact Phone Number | XTN | O | 1 |
| SCH.18 | Filler Contact Address | XAD | O | * |
| SCH.19 | Filler Contact Location | PL | O | 1 |
| SCH.20 | Entered By Person | XCN | R | * |
| SCH.21 | Entered By Phone Number | XTN | O | * |
| SCH.22 | Entered By Location | PL | O | 1 |
| SCH.23 | Parent Placer Appointment Id | EI | O | 1 |
| SCH.24 | Parent Filler Appointment Id | EI | O | 1 |
| SCH.25 | Filler Status Code | CE | C | 1 |
| SCH.26 | Placer Order Number | EI | O | * |
| SCH.27 | Filler Order Number | EI | O | * |

---

## SDD -- Sterilization Device Data (v2.6)

7 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| SDD.1 | Lot Number | EI | O | 1 |
| SDD.2 | Device Number | EI | O | 1 |
| SDD.3 | Device Name | ST | O | 1 |
| SDD.4 | Device Data State | IS | O | 1 |
| SDD.5 | Load Status | IS | O | 1 |
| SDD.6 | Control Code | NM | O | 1 |
| SDD.7 | Operator Name | ST | O | 1 |

---

## SFT -- Software Segment

6 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| SFT.1 | Software Vendor Organization | XON | R | 1 |
| SFT.2 | Software Certified Version Or Release Number | ST | R | 1 |
| SFT.3 | Software Product Name | ST | R | 1 |
| SFT.4 | Software Binary Id | ST | R | 1 |
| SFT.5 | Software Product Information | TX | O | 1 |
| SFT.6 | Software Install Date | TS | O | 1 |

---

## SID -- Substance Identifier

4 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| SID.1 | Application Method Identifier | CE | C | 1 |
| SID.2 | Substance Lot Number | ST | O | 1 |
| SID.3 | Substance Container Identifier | ST | O | 1 |
| SID.4 | Substance Manufacturer Identifier | CE | C | 1 |

---

## SPM -- Specimen

30 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| SPM.1 | Set Id | SI | O | 1 |
| SPM.2 | Specimen Id | EIP | O | 1 |
| SPM.3 | Specimen Parent Ids | EIP | O | * |
| SPM.4 | Specimen Type | CWE | R | 1 |
| SPM.5 | Specimen Type Modifier | CWE | O | * |
| SPM.6 | Specimen Additives | CWE | O | * |
| SPM.7 | Specimen Collection Method | CWE | O | 1 |
| SPM.8 | Specimen Source Site | CWE | O | 1 |
| SPM.9 | Specimen Source Site Modifier | CWE | O | * |
| SPM.10 | Specimen Collection Site | CWE | O | 1 |
| SPM.11 | Specimen Role | CWE | O | * |
| SPM.12 | Specimen Collection Amount | CQ | O | 1 |
| SPM.13 | Grouped Specimen Count | NM | O | 1 |
| SPM.14 | Specimen Description | ST | O | * |
| SPM.15 | Specimen Handling Code | CWE | O | * |
| SPM.16 | Specimen Risk Code | CWE | O | * |
| SPM.17 | Specimen Collection Date Time | DR | O | 1 |
| SPM.18 | Specimen Received Date Time | TS | O | 1 |
| SPM.19 | Specimen Expiration Date Time | TS | O | 1 |
| SPM.20 | Specimen Availability | ID | O | 1 |
| SPM.21 | Specimen Reject Reason | CWE | O | * |
| SPM.22 | Specimen Quality | CWE | O | 1 |
| SPM.23 | Specimen Appropriateness | CWE | O | 1 |
| SPM.24 | Specimen Condition | CWE | O | * |
| SPM.25 | Specimen Current Quantity | CQ | O | 1 |
| SPM.26 | Number Of Specimen Containers | NM | O | 1 |
| SPM.27 | Container Type | CWE | O | 1 |
| SPM.28 | Container Condition | CWE | O | 1 |
| SPM.29 | Specimen Child Role | CWE | O | 1 |
| SPM.30 | Field 30 | CWE | O | 1 |

---

## SPR -- Stored Procedure Request Definition

4 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| SPR.1 | Query Tag | ST | O | 1 |
| SPR.2 | Query Response Format Code | ID | R | 1 |
| SPR.3 | Stored Procedure Name | CE | R | 1 |
| SPR.4 | Input Parameter List | QIP | O | * |

---

## STF -- Staff Identification

38 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| STF.1 | Primary Key Value | CE | C | 1 |
| STF.2 | Staff Identifier List | CX | O | * |
| STF.3 | Staff Name | XPN | O | * |
| STF.4 | Staff Type | IS | O | * |
| STF.5 | Administrative Sex | IS | O | 1 |
| STF.6 | Date Time Of Birth | TS | O | 1 |
| STF.7 | Active Inactive Flag | ID | O | 1 |
| STF.8 | Department | CE | O | * |
| STF.9 | Hospital Service | CE | O | * |
| STF.10 | Phone | XTN | O | * |
| STF.11 | Office Home Address Birthplace | XAD | O | * |
| STF.12 | Institution Activation Date | DIN | O | * |
| STF.13 | Institution Inactivation Date | DIN | O | * |
| STF.14 | Backup Person Id | CE | O | * |
| STF.15 | E Mail Address | ST | O | * |
| STF.16 | Preferred Method Of Contact | CE | O | 1 |
| STF.17 | Marital Status | CE | O | 1 |
| STF.18 | Job Title | ST | O | 1 |
| STF.19 | Job Code Class | JCC | O | 1 |
| STF.20 | Employment Status Code | CE | O | 1 |
| STF.21 | Additional Insured On Auto | ID | O | 1 |
| STF.22 | Drivers License Number Staff | DLN | O | 1 |
| STF.23 | Copy Auto Ins | ID | O | 1 |
| STF.24 | Auto Ins Expires | DT | O | 1 |
| STF.25 | Date Last Dmv Review | DT | O | 1 |
| STF.26 | Date Next Dmv Review | DT | O | 1 |
| STF.27 | Race | CE | O | 1 |
| STF.28 | Ethnic Group | CE | O | 1 |
| STF.29 | Re Activation Approval Indicator | ID | O | 1 |
| STF.30 | Citizenship | CE | O | * |
| STF.31 | Death Date And Time | TS | O | 1 |
| STF.32 | Death Indicator | ID | O | 1 |
| STF.33 | Institution Relationship Type Code | CWE | O | 1 |
| STF.34 | Institution Relationship Period | DR | O | 1 |
| STF.35 | Expected Return Date | DT | O | 1 |
| STF.36 | Cost Center Code | CWE | O | * |
| STF.37 | Generic Classification Indicator | ID | O | 1 |
| STF.38 | Inactive Reason Code | CWE | O | 1 |

---

## TCC -- Test Code Configuration

14 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| TCC.1 | Universal Service Identifier | CE | R | 1 |
| TCC.2 | Test Application Identifier | EI | R | 1 |
| TCC.3 | Specimen Source | SPS | O | 1 |
| TCC.4 | Auto Dilution Factor Default | SN | O | 1 |
| TCC.5 | Rerun Dilution Factor Default | SN | O | 1 |
| TCC.6 | Pre Dilution Factor Default | SN | O | 1 |
| TCC.7 | Endogenous Content Of Pre Dilution Diluent | SN | O | 1 |
| TCC.8 | Inventory Limits Warning Level | NM | O | 1 |
| TCC.9 | Automatic Rerun Allowed | ID | O | 1 |
| TCC.10 | Automatic Repeat Allowed | ID | O | 1 |
| TCC.11 | Automatic Reflex Allowed | ID | O | 1 |
| TCC.12 | Equipment Dynamic Range | SN | O | 1 |
| TCC.13 | Units | CE | O | 1 |
| TCC.14 | Processing Type | CE | O | 1 |

---

## TCD -- Test Code Detail

8 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| TCD.1 | Universal Service Identifier | CE | R | 1 |
| TCD.2 | Auto Dilution Factor | SN | O | 1 |
| TCD.3 | Rerun Dilution Factor | SN | O | 1 |
| TCD.4 | Pre Dilution Factor | SN | O | 1 |
| TCD.5 | Endogenous Content Of Pre Dilution Diluent | SN | O | 1 |
| TCD.6 | Automatic Repeat Allowed | ID | O | 1 |
| TCD.7 | Reflex Allowed | ID | O | 1 |
| TCD.8 | Analyte Repeatability | CE | O | 1 |

---

## TQ1 -- Timing/Quantity

14 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| TQ1.1 | Set Id | SI | O | 1 |
| TQ1.2 | Quantity | CQ | O | 1 |
| TQ1.3 | Repeat Pattern | RPT | O | * |
| TQ1.4 | Explicit Time | TM | O | * |
| TQ1.5 | Relative Time And Units | CQ | O | * |
| TQ1.6 | Service Duration | CQ | O | 1 |
| TQ1.7 | Start Date Time | TS | O | 1 |
| TQ1.8 | End Date Time | TS | O | 1 |
| TQ1.9 | Priority | CWE | O | * |
| TQ1.10 | Condition Text | TX | O | 1 |
| TQ1.11 | Text Instruction | TX | O | 1 |
| TQ1.12 | Conjunction | ID | O | 1 |
| TQ1.13 | Occurrence Duration | CQ | O | 1 |
| TQ1.14 | Total Occurrences | NM | O | 1 |

---

## TQ2 -- Timing/Quantity Relationship

10 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| TQ2.1 | Set Id | SI | O | 1 |
| TQ2.2 | Sequence Results Flag | ID | O | 1 |
| TQ2.3 | Related Placer Number | EI | O | * |
| TQ2.4 | Related Filler Number | EI | O | * |
| TQ2.5 | Related Placer Group Number | EI | O | * |
| TQ2.6 | Sequence Condition Code | ID | O | 1 |
| TQ2.7 | Cyclic Entry Exit Indicator | ID | O | 1 |
| TQ2.8 | Sequence Condition Time Interval | CQ | O | 1 |
| TQ2.9 | Cyclic Group Maximum Number Of Repeats | NM | O | 1 |
| TQ2.10 | Special Service Request Relationship | ID | O | 1 |

---

## TXA -- Transcription Document Header

23 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| TXA.1 | Set Id | SI | R | 1 |
| TXA.2 | Document Type | IS | R | 1 |
| TXA.3 | Document Content Presentation | ID | O | 1 |
| TXA.4 | Activity Date Time | TS | O | 1 |
| TXA.5 | Primary Activity Provider Code | XCN | O | * |
| TXA.6 | Origination Date Time | TS | O | 1 |
| TXA.7 | Transcription Date Time | TS | O | 1 |
| TXA.8 | Edit Date Time | TS | O | * |
| TXA.9 | Originator Code Name | XCN | O | * |
| TXA.10 | Assigned Document Authenticator | XCN | O | * |
| TXA.11 | Transcriptionist Code Name | XCN | O | * |
| TXA.12 | Unique Document Number | EI | R | 1 |
| TXA.13 | Parent Document Number | EI | O | 1 |
| TXA.14 | Placer Order Number | EI | O | * |
| TXA.15 | Filler Order Number | EI | O | 1 |
| TXA.16 | Unique Document File Name | ST | O | 1 |
| TXA.17 | Document Completion Status | ID | O | 1 |
| TXA.18 | Document Confidentiality Status | ID | O | 1 |
| TXA.19 | Document Availability Status | ID | O | 1 |
| TXA.20 | Document Storage Status | ID | O | 1 |
| TXA.21 | Document Change Reason | ST | O | 1 |
| TXA.22 | Authentication Person Time Stamp | XCN | O | * |
| TXA.23 | Distributed Copies | XCN | O | * |

---

## UB1 -- UB82

23 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| UB1.1 | Set Id | SI | O | 1 |
| UB1.2 | Blood Deductible | NM | B | 1 |
| UB1.3 | Blood Furnished Pints Of | NM | B | 1 |
| UB1.4 | Blood Replaced Pints | NM | B | 1 |
| UB1.5 | Blood Not Replaced Pints | NM | B | 1 |
| UB1.6 | Co Insurance Days | NM | B | 1 |
| UB1.7 | Condition Code | IS | O | 7 |
| UB1.8 | Covered Days | NM | B | 1 |
| UB1.9 | Non Covered Days | NM | B | 1 |
| UB1.10 | Value Amount And Code | UVC | B | * |
| UB1.11 | Number Of Grace Days | NM | B | 1 |
| UB1.12 | Special Program Indicator | CE | B | 1 |
| UB1.13 | Psro Ur Approval Indicator | CE | B | 1 |
| UB1.14 | Priority | ID | O | 1 |
| UB1.15 | Psro Ur Approved Stay To | DT | B | 1 |
| UB1.16 | Number Of Grace Days 16 | NM | O | 1 |
| UB1.17 | Admit Date | DT | B | 1 |
| UB1.18 | Discharge Date | DT | B | 1 |
| UB1.19 | Discharge Diagnosis | CE | B | 1 |
| UB1.20 | Discharge Diagnosis Date | DT | B | 1 |
| UB1.21 | Facility Id | ST | B | 1 |
| UB1.22 | Health Plan Id | IS | B | 1 |
| UB1.23 | Special Program Code | ID | B | 1 |

---

## UB2 -- UB92 Data

17 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| UB2.1 | Set Id | SI | O | 1 |
| UB2.2 | Co Insurance Days | ST | O | 1 |
| UB2.3 | Condition Code | IS | O | 7 |
| UB2.4 | Covered Days | ST | O | 1 |
| UB2.5 | Non Covered Days | ST | O | 1 |
| UB2.6 | Value Amount And Code | UVC | O | * |
| UB2.7 | Occurrence Code And Date | OCD | O | * |
| UB2.8 | Occurrence Span Code Dates | OSP | O | * |
| UB2.9 | Ub92 Locator 2 State | ST | O | 1 |
| UB2.10 | Ub92 Locator 11 State | ST | O | * |
| UB2.11 | Ub92 Locator 31 National | ST | O | 1 |
| UB2.12 | Document Control Number | ST | O | * |
| UB2.13 | Ub92 Locator 49 National | ST | O | * |
| UB2.14 | Ub92 Locator 56 State | ST | O | * |
| UB2.15 | Ub92 Locator 57 National | ST | O | 1 |
| UB2.16 | Ub92 Locator 78 State | ST | O | * |
| UB2.17 | Special Visit Count | NM | O | 1 |

---

## URD -- Results/Update Definition

7 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| URD.1 | R U Date Time | TS | O | 1 |
| URD.2 | Report Priority | ID | O | 1 |
| URD.3 | R U Who Subject Definition | XCN | R | * |
| URD.4 | R U What Subject Definition | CE | O | * |
| URD.5 | R U What Department Code | CE | O | * |
| URD.6 | R U Display Print Locations | ST | O | * |
| URD.7 | R U Results Level | ID | O | 1 |

---

## URS -- Unsolicited Selection

8 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| URS.1 | R U Where Subject Definition | ST | R | * |
| URS.2 | R U When Data Start Date Time | TS | O | 1 |
| URS.3 | R U When Data End Date Time | TS | O | 1 |
| URS.4 | R U What User Qualifier | ST | O | * |
| URS.5 | R U Other Results Subject Definition | ST | O | * |
| URS.6 | R U Which Date Time Qualifier | ID | O | * |
| URS.7 | R U Which Date Time Status Qualifier | ID | O | * |
| URS.8 | R U Date Time Selection Qualifier | ID | O | * |

---

## VAR -- Variance

6 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| VAR.1 | Variance Instance Id | EI | R | 1 |
| VAR.2 | Documented Date Time | TS | R | 1 |
| VAR.3 | Stated Variance Date Time | TS | O | 1 |
| VAR.4 | Variance Originator | XCN | O | * |
| VAR.5 | Variance Classification | CE | O | 1 |
| VAR.6 | Variance Description | ST | O | * |

---

## VTQ -- Virtual Table Query Request

5 fields.

| Seq | Name | Type | Opt | Rep |
|-----|------|------|-----|-----|
| VTQ.1 | Query Tag | ST | O | 1 |
| VTQ.2 | Query Response Format Code | ID | R | 1 |
| VTQ.3 | Vtq Query Name | CE | R | 1 |
| VTQ.4 | Virtual Table Name | CE | R | 1 |
| VTQ.5 | Selection Criteria | QSC | O | * |

---
