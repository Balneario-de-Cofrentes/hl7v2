# HL7 v2.5.1 Data Type Definitions

Component-by-component reference for all 90 data types
in the HL7 v2.5.1 standard as implemented by this library.

**Generated from code metadata** -- do not edit by hand.
Run `mix hl7v2.gen_docs` to regenerate.

---


## Primitive Data Types

| Code | Name |
|------|------|
| DT | Date |
| FT | Formatted Text Data |
| GTS | General Timing Specification |
| ID | Coded Value for HL7 Defined Tables |
| IS | Coded Value for User-Defined Tables |
| NM | Numeric |
| SI | Sequence ID |
| ST | String Data |
| TM | Time |
| TN | Telephone Number (deprecated) |
| TX | Text Data |

---


## Composite Data Types

### AD -- Address

8 components.

| # | Component |
|---|-----------|
| 1 | Street Address |
| 2 | Other Designation |
| 3 | City |
| 4 | State Or Province |
| 5 | Zip Or Postal Code |
| 6 | Country |
| 7 | Address Type |
| 8 | Other Geographic Designation |

---

### AUI -- Authorization Information

3 components.

| # | Component |
|---|-----------|
| 1 | Authorization Number |
| 2 | Date |
| 3 | Source |

---

### CCD -- Charge Code and Date

2 components.

| # | Component |
|---|-----------|
| 1 | Invocation Event |
| 2 | Date Time |

---

### CCP -- Channel Calibration Parameters

3 components.

| # | Component |
|---|-----------|
| 1 | Channel Calibration Sensitivity Correction Factor |
| 2 | Channel Calibration Baseline |
| 3 | Channel Calibration Time Skew |

---

### CD -- Channel Definition

7 components.

| # | Component |
|---|-----------|
| 1 | Channel Identifier |
| 2 | Waveform Source |
| 3 | Channel Sensitivity And Units |
| 4 | Channel Calibration Parameters |
| 5 | Channel Sampling Frequency |
| 6 | Minimum Data Value |
| 7 | Maximum Data Value |

---

### CE -- Coded Element

6 components.

| # | Component |
|---|-----------|
| 1 | Identifier |
| 2 | Text |
| 3 | Name Of Coding System |
| 4 | Alternate Identifier |
| 5 | Alternate Text |
| 6 | Name Of Alternate Coding System |

---

### CF -- Coded Element with Formatted Values

6 components.

| # | Component |
|---|-----------|
| 1 | Identifier |
| 2 | Formatted Text |
| 3 | Name Of Coding System |
| 4 | Alternate Identifier |
| 5 | Alternate Formatted Text |
| 6 | Name Of Alternate Coding System |

---

### CNE -- Coded with No Exceptions

9 components.

| # | Component |
|---|-----------|
| 1 | Identifier |
| 2 | Text |
| 3 | Name Of Coding System |
| 4 | Alternate Identifier |
| 5 | Alternate Text |
| 6 | Name Of Alternate Coding System |
| 7 | Coding System Version Id |
| 8 | Alternate Coding System Version Id |
| 9 | Original Text |

---

### CNN -- Composite Number and Name without Authority

11 components.

| # | Component |
|---|-----------|
| 1 | Id Number |
| 2 | Family Name |
| 3 | Given Name |
| 4 | Second Name |
| 5 | Suffix |
| 6 | Prefix |
| 7 | Degree |
| 8 | Source Table |
| 9 | Assigning Authority Namespace Id |
| 10 | Assigning Authority Universal Id |
| 11 | Assigning Authority Universal Id Type |

---

### CP -- Composite Price

6 components.

| # | Component |
|---|-----------|
| 1 | Price |
| 2 | Price Type |
| 3 | From Value |
| 4 | To Value |
| 5 | Range Units |
| 6 | Range Type |

---

### CQ -- Composite Quantity with Units

2 components.

| # | Component |
|---|-----------|
| 1 | Quantity |
| 2 | Units |

---

### CSU -- Channel Sensitivity and Units

7 components.

| # | Component |
|---|-----------|
| 1 | Channel Sensitivity |
| 2 | Unit Of Measure Identifier |
| 3 | Unit Of Measure Description |
| 4 | Unit Of Measure Coding System |
| 5 | Alternate Unit Of Measure Identifier |
| 6 | Alternate Unit Of Measure Text |
| 7 | Alternate Unit Of Measure Coding System |

---

### CWE -- Coded with Exceptions

9 components.

| # | Component |
|---|-----------|
| 1 | Identifier |
| 2 | Text |
| 3 | Name Of Coding System |
| 4 | Alternate Identifier |
| 5 | Alternate Text |
| 6 | Name Of Alternate Coding System |
| 7 | Coding System Version Id |
| 8 | Alternate Coding System Version Id |
| 9 | Original Text |

---

### CX -- Extended Composite ID with Check Digit

10 components.

| # | Component |
|---|-----------|
| 1 | Id |
| 2 | Check Digit |
| 3 | Check Digit Scheme |
| 4 | Assigning Authority |
| 5 | Identifier Type Code |
| 6 | Assigning Facility |
| 7 | Effective Date |
| 8 | Expiration Date |
| 9 | Assigning Jurisdiction |
| 10 | Assigning Agency |

---

### DDI -- Daily Deductible Information

3 components.

| # | Component |
|---|-----------|
| 1 | Delay Days |
| 2 | Monetary Amount |
| 3 | Number Of Days |

---

### DIN -- Date and Institution Name

2 components.

| # | Component |
|---|-----------|
| 1 | Date |
| 2 | Institution Name |

---

### DLD -- Discharge to Location and Date

2 components.

| # | Component |
|---|-----------|
| 1 | Discharge To Location |
| 2 | Effective Date |

---

### DLN -- Driver's License Number

3 components.

| # | Component |
|---|-----------|
| 1 | License Number |
| 2 | Issuing State Province Country |
| 3 | Expiration Date |

---

### DLT -- Delta

4 components.

| # | Component |
|---|-----------|
| 1 | Normal Range |
| 2 | Numeric Threshold |
| 3 | Change Computation |
| 4 | Days Retained |

---

### DR -- Date/Time Range

2 components.

| # | Component |
|---|-----------|
| 1 | Range Start |
| 2 | Range End |

---

### DTM -- Date/Time

9 components.

| # | Component |
|---|-----------|
| 1 | Year |
| 2 | Month |
| 3 | Day |
| 4 | Hour |
| 5 | Minute |
| 6 | Second |
| 7 | Fraction |
| 8 | Offset |
| 9 | Original |

---

### DTN -- Day Type and Number

2 components.

| # | Component |
|---|-----------|
| 1 | Day Type |
| 2 | Number Of Days |

---

### ED -- Encapsulated Data

5 components.

| # | Component |
|---|-----------|
| 1 | Source Application |
| 2 | Type Of Data |
| 3 | Data Subtype |
| 4 | Encoding |
| 5 | Data |

---

### EI -- Entity Identifier

4 components.

| # | Component |
|---|-----------|
| 1 | Entity Identifier |
| 2 | Namespace Id |
| 3 | Universal Id |
| 4 | Universal Id Type |

---

### EIP -- Entity Identifier Pair

2 components.

| # | Component |
|---|-----------|
| 1 | Placer Assigned Identifier |
| 2 | Filler Assigned Identifier |

---

### ELD -- Error Location and Description

4 components.

| # | Component |
|---|-----------|
| 1 | Segment Id |
| 2 | Segment Sequence |
| 3 | Field Position |
| 4 | Code Identifying Error |

---

### ERL -- Error Location

6 components.

| # | Component |
|---|-----------|
| 1 | Segment Id |
| 2 | Segment Sequence |
| 3 | Field Position |
| 4 | Component Number |
| 5 | Sub Component Number |
| 6 | Source Table |

---

### FC -- Financial Class

2 components.

| # | Component |
|---|-----------|
| 1 | Financial Class Code |
| 2 | Effective Date |

---

### FN -- Family Name

5 components.

| # | Component |
|---|-----------|
| 1 | Surname |
| 2 | Own Surname Prefix |
| 3 | Own Surname |
| 4 | Surname Prefix From Partner |
| 5 | Surname From Partner |

---

### HD -- Hierarchic Designator

3 components.

| # | Component |
|---|-----------|
| 1 | Namespace Id |
| 2 | Universal Id |
| 3 | Universal Id Type |

---

### ICD -- Insurance Certification Definition

3 components.

| # | Component |
|---|-----------|
| 1 | Certification Patient Type |
| 2 | Certification Required |
| 3 | Date Time Certification Required |

---

### JCC -- Job Code/Class

2 components.

| # | Component |
|---|-----------|
| 1 | Job Code |
| 2 | Job Class |

---

### LA1 -- Location with Address Variation 1

9 components.

| # | Component |
|---|-----------|
| 1 | Point Of Care |
| 2 | Room |
| 3 | Bed |
| 4 | Facility |
| 5 | Location Status |
| 6 | Patient Location Type |
| 7 | Building |
| 8 | Floor |
| 9 | Address |

---

### LA2 -- Location with Address Variation 2

14 components.

| # | Component |
|---|-----------|
| 1 | Point Of Care |
| 2 | Room |
| 3 | Bed |
| 4 | Facility |
| 5 | Location Status |
| 6 | Patient Location Type |
| 7 | Building |
| 8 | Floor |
| 9 | Street Address |
| 10 | Other Designation |
| 11 | City |
| 12 | State Or Province |
| 13 | Zip Or Postal Code |
| 14 | Country |

---

### MA -- Multiplexed Array

1 components.

| # | Component |
|---|-----------|
| 1 | Values |

---

### MO -- Money

2 components.

| # | Component |
|---|-----------|
| 1 | Quantity |
| 2 | Denomination |

---

### MOC -- Money and Charge Code

2 components.

| # | Component |
|---|-----------|
| 1 | Monetary Amount |
| 2 | Charge Code |

---

### MOP -- Money or Percentage

2 components.

| # | Component |
|---|-----------|
| 1 | Money Or Percentage Indicator |
| 2 | Money Or Percentage Quantity |

---

### MSG -- Message Type

3 components.

| # | Component |
|---|-----------|
| 1 | Message Code |
| 2 | Trigger Event |
| 3 | Message Structure |

---

### NA -- Numeric Array

1 components.

| # | Component |
|---|-----------|
| 1 | Values |

---

### NDL -- Name with Date and Location

11 components.

| # | Component |
|---|-----------|
| 1 | Name |
| 2 | Start Date Time |
| 3 | End Date Time |
| 4 | Point Of Care |
| 5 | Room |
| 6 | Bed |
| 7 | Facility |
| 8 | Location Status |
| 9 | Patient Location Type |
| 10 | Building |
| 11 | Floor |

---

### NR -- Numeric Range

2 components.

| # | Component |
|---|-----------|
| 1 | Low |
| 2 | High |

---

### OCD -- Occurrence Code and Date

2 components.

| # | Component |
|---|-----------|
| 1 | Occurrence Code |
| 2 | Occurrence Date |

---

### OSD -- Order Sequence Definition

11 components.

| # | Component |
|---|-----------|
| 1 | Sequence Results Flag |
| 2 | Placer Order Number Entity Identifier |
| 3 | Placer Order Number Namespace Id |
| 4 | Filler Order Number Entity Identifier |
| 5 | Filler Order Number Namespace Id |
| 6 | Sequence Condition Value |
| 7 | Maximum Number Of Repeats |
| 8 | Placer Order Number Universal Id |
| 9 | Placer Order Number Universal Id Type |
| 10 | Filler Order Number Universal Id |
| 11 | Filler Order Number Universal Id Type |

---

### OSP -- Occurrence Span Code and Date

3 components.

| # | Component |
|---|-----------|
| 1 | Occurrence Span Code |
| 2 | Occurrence Span Start Date |
| 3 | Occurrence Span Stop Date |

---

### PIP -- Practitioner Institutional Privileges

5 components.

| # | Component |
|---|-----------|
| 1 | Privilege |
| 2 | Privilege Class |
| 3 | Expiration Date |
| 4 | Activation Date |
| 5 | Facility |

---

### PL -- Person Location

11 components.

| # | Component |
|---|-----------|
| 1 | Point Of Care |
| 2 | Room |
| 3 | Bed |
| 4 | Facility |
| 5 | Location Status |
| 6 | Person Location Type |
| 7 | Building |
| 8 | Floor |
| 9 | Location Description |
| 10 | Comprehensive Location Identifier |
| 11 | Assigning Authority For Location |

---

### PLN -- Practitioner License or Other ID Number

4 components.

| # | Component |
|---|-----------|
| 1 | Id Number |
| 2 | Type Of Id Number |
| 3 | State Other Qualifying Information |
| 4 | Expiration Date |

---

### PPN -- Performing Person Time Stamp

17 components.

| # | Component |
|---|-----------|
| 1 | Id Number |
| 2 | Family Name |
| 3 | Given Name |
| 4 | Second Name |
| 5 | Suffix |
| 6 | Prefix |
| 7 | Degree |
| 8 | Source Table |
| 9 | Assigning Authority |
| 10 | Name Type Code |
| 11 | Identifier Check Digit |
| 12 | Check Digit Scheme |
| 13 | Identifier Type Code |
| 14 | Assigning Facility |
| 15 | Date Time Action Performed |
| 16 | Name Representation Code |
| 17 | Raw 17 24 |

---

### PRL -- Parent Result Link

3 components.

| # | Component |
|---|-----------|
| 1 | Parent Observation Identifier |
| 2 | Parent Observation Sub Identifier |
| 3 | Parent Observation Value Descriptor |

---

### PT -- Processing Type

2 components.

| # | Component |
|---|-----------|
| 1 | Processing Id |
| 2 | Processing Mode |

---

### PTA -- Policy Type and Amount

3 components.

| # | Component |
|---|-----------|
| 1 | Policy Type |
| 2 | Amount Class |
| 3 | Money Or Percentage Quantity |

---

### QIP -- Query Input Parameter List

2 components.

| # | Component |
|---|-----------|
| 1 | Segment Field Name |
| 2 | Values |

---

### QSC -- Query Selection Criteria

4 components.

| # | Component |
|---|-----------|
| 1 | Segment Field Name |
| 2 | Relational Operator |
| 3 | Value |
| 4 | Relational Conjunction |

---

### RCD -- Row Column Definition

3 components.

| # | Component |
|---|-----------|
| 1 | Segment Field Name |
| 2 | Hl7 Data Type |
| 3 | Maximum Column Width |

---

### RFR -- Reference Range

7 components.

| # | Component |
|---|-----------|
| 1 | Numeric Range |
| 2 | Administrative Sex |
| 3 | Age Range |
| 4 | Gestational Age Range |
| 5 | Species |
| 6 | Race Subspecies |
| 7 | Conditions |

---

### RI -- Repeat Interval

2 components.

| # | Component |
|---|-----------|
| 1 | Repeat Pattern |
| 2 | Explicit Time Interval |

---

### RMC -- Room Coverage

4 components.

| # | Component |
|---|-----------|
| 1 | Room Type |
| 2 | Amount Type |
| 3 | Coverage Amount |
| 4 | Money Or Percentage |

---

### RP -- Reference Pointer

4 components.

| # | Component |
|---|-----------|
| 1 | Pointer |
| 2 | Application Id |
| 3 | Type Of Data |
| 4 | Subtype |

---

### RPT -- Repeat Pattern

10 components.

| # | Component |
|---|-----------|
| 1 | Repeat Pattern Code |
| 2 | Calendar Alignment |
| 3 | Phase Range Begin Value |
| 4 | Phase Range End Value |
| 5 | Period Quantity |
| 6 | Period Units |
| 7 | Institution Specified Time |
| 8 | Event |
| 9 | Event Offset Quantity |
| 10 | Event Offset Units |

---

### SAD -- Street Address

3 components.

| # | Component |
|---|-----------|
| 1 | Street Or Mailing Address |
| 2 | Street Name |
| 3 | Dwelling Number |

---

### SCV -- Scheduling Class Value Pair

2 components.

| # | Component |
|---|-----------|
| 1 | Parameter Class |
| 2 | Parameter Value |

---

### SN -- Structured Numeric

4 components.

| # | Component |
|---|-----------|
| 1 | Comparator |
| 2 | Num1 |
| 3 | Separator Suffix |
| 4 | Num2 |

---

### SPD -- Specialty Description

4 components.

| # | Component |
|---|-----------|
| 1 | Specialty Name |
| 2 | Governing Board |
| 3 | Eligible Or Certified |
| 4 | Date Of Certification |

---

### SPS -- Specimen Source

7 components.

| # | Component |
|---|-----------|
| 1 | Specimen Source Name Or Code |
| 2 | Additives |
| 3 | Specimen Collection Method |
| 4 | Body Site |
| 5 | Site Modifier |
| 6 | Collection Method Modifier Code |
| 7 | Specimen Role |

---

### SRT -- Sort Order

2 components.

| # | Component |
|---|-----------|
| 1 | Sort By Field |
| 2 | Sequencing |

---

### TQ -- Timing/Quantity

12 components.

| # | Component |
|---|-----------|
| 1 | Quantity |
| 2 | Interval |
| 3 | Duration |
| 4 | Start Date Time |
| 5 | End Date Time |
| 6 | Priority |
| 7 | Condition |
| 8 | Text |
| 9 | Conjunction |
| 10 | Order Sequencing |
| 11 | Occurrence Duration |
| 12 | Total Occurrences |

---

### TS -- Time Stamp

2 components.

| # | Component |
|---|-----------|
| 1 | Time |
| 2 | Degree Of Precision |

---

### UVC -- UB Value Code and Amount

2 components.

| # | Component |
|---|-----------|
| 1 | Value Code |
| 2 | Value Amount |

---

### VH -- Visiting Hours

4 components.

| # | Component |
|---|-----------|
| 1 | Start Day Range |
| 2 | End Day Range |
| 3 | Start Hour Range |
| 4 | End Hour Range |

---

### VID -- Version Identifier

3 components.

| # | Component |
|---|-----------|
| 1 | Version Id |
| 2 | Internationalization Code |
| 3 | International Version Id |

---

### VR -- Value Range

2 components.

| # | Component |
|---|-----------|
| 1 | First Data Code Value |
| 2 | Last Data Code Value |

---

### WVI -- Channel Identifier

2 components.

| # | Component |
|---|-----------|
| 1 | Channel Number |
| 2 | Channel Name |

---

### WVS -- Waveform Source

2 components.

| # | Component |
|---|-----------|
| 1 | Source One Name |
| 2 | Source Two Name |

---

### XAD -- Extended Address

14 components.

| # | Component |
|---|-----------|
| 1 | Street Address |
| 2 | Other Designation |
| 3 | City |
| 4 | State |
| 5 | Zip |
| 6 | Country |
| 7 | Address Type |
| 8 | Other Geographic |
| 9 | County Code |
| 10 | Census Tract |
| 11 | Address Representation Code |
| 12 | Address Validity Range |
| 13 | Effective Date |
| 14 | Expiration Date |

---

### XCN -- Extended Composite ID Number and Name for Persons

23 components.

| # | Component |
|---|-----------|
| 1 | Id Number |
| 2 | Family Name |
| 3 | Given Name |
| 4 | Second Name |
| 5 | Suffix |
| 6 | Prefix |
| 7 | Degree |
| 8 | Source Table |
| 9 | Assigning Authority |
| 10 | Name Type Code |
| 11 | Identifier Check Digit |
| 12 | Check Digit Scheme |
| 13 | Identifier Type Code |
| 14 | Assigning Facility |
| 15 | Name Representation Code |
| 16 | Name Context |
| 17 | Name Validity Range |
| 18 | Name Assembly Order |
| 19 | Effective Date |
| 20 | Expiration Date |
| 21 | Professional Suffix |
| 22 | Assigning Jurisdiction |
| 23 | Assigning Agency |

---

### XON -- Extended Composite Name and ID Number for Organizations

10 components.

| # | Component |
|---|-----------|
| 1 | Organization Name |
| 2 | Organization Name Type Code |
| 3 | Id Number |
| 4 | Check Digit |
| 5 | Check Digit Scheme |
| 6 | Assigning Authority |
| 7 | Identifier Type Code |
| 8 | Assigning Facility |
| 9 | Name Representation Code |
| 10 | Organization Identifier |

---

### XPN -- Extended Person Name

14 components.

| # | Component |
|---|-----------|
| 1 | Family Name |
| 2 | Given Name |
| 3 | Second Name |
| 4 | Suffix |
| 5 | Prefix |
| 6 | Degree |
| 7 | Name Type Code |
| 8 | Name Representation Code |
| 9 | Name Context |
| 10 | Name Validity Range |
| 11 | Name Assembly Order |
| 12 | Effective Date |
| 13 | Expiration Date |
| 14 | Professional Suffix |

---

### XTN -- Extended Telecommunication Number

12 components.

| # | Component |
|---|-----------|
| 1 | Telephone Number |
| 2 | Telecom Use Code |
| 3 | Telecom Equipment Type |
| 4 | Email Address |
| 5 | Country Code |
| 6 | Area Code |
| 7 | Local Number |
| 8 | Extension |
| 9 | Any Text |
| 10 | Extension Prefix |
| 11 | Speed Dial Code |
| 12 | Unformatted Telephone Number |

---
