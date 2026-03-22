# HL7 v2.5.1 Message Structure Reference

Comprehensive segment structure definitions for the HL7 v2.5.1 message types
supported by this library. Sourced from the HL7 v2.5.1 standard (Chapters 2-3)
and verified against [Caristix HL7-Definition](https://hl7-definition.caristix.com/v2/HL7v2.5.1/TriggerEvents).

## Notation

| Symbol | Meaning |
|--------|---------|
| R | Required -- segment MUST be present |
| O | Optional -- segment MAY be present |
| C | Conditional -- segment presence depends on a condition |
| `-` | Not repeatable (exactly 0 or 1 occurrence) |
| `*` | Repeatable, unbounded |
| `[...]` | Optional wrapper (0..1) |
| `{...}` | Repeating wrapper (1..*) |
| `[{...}]` | Optional + repeating (0..*) |

Indented segments belong to the group listed above them. The group's anchor
segment (first segment in the group) marks the start of each repetition.

---

## 1. ADT^A01 -- Admit/Visit Notification

**Structure:** ADT_A01
**Chapter:** 3 (Patient Administration)
**Use case:** Patient undergoes the admission process and is assigned a bed. Signals the beginning of a patient's stay in a healthcare facility.

| # | Segment | Description | Opt | Repeat | Group |
|---|---------|-------------|-----|--------|-------|
| 1 | MSH | Message Header | R | - | -- |
| 2 | SFT | Software Segment | O | * | -- |
| 3 | EVN | Event Type | R | - | -- |
| 4 | PID | Patient Identification | R | - | -- |
| 5 | PD1 | Patient Additional Demographic | O | - | -- |
| 6 | ROL | Role | O | * | -- |
| 7 | NK1 | Next of Kin / Associated Parties | O | * | -- |
| 8 | PV1 | Patient Visit | R | - | -- |
| 9 | PV2 | Patient Visit - Additional Info | O | - | -- |
| 10 | ROL | Role | O | * | -- |
| 11 | DB1 | Disability | O | * | -- |
| 12 | OBX | Observation/Result | O | * | -- |
| 13 | AL1 | Patient Allergy Information | O | * | -- |
| 14 | DG1 | Diagnosis | O | * | -- |
| 15 | DRG | Diagnosis Related Group | O | - | -- |
| -- | --- PROCEDURE (group) | | O | * | -- |
| 16 | &nbsp; PR1 | Procedures | R | - | PROCEDURE |
| 17 | &nbsp; ROL | Role | O | * | PROCEDURE |
| 18 | GT1 | Guarantor | O | * | -- |
| -- | --- INSURANCE (group) | | O | * | -- |
| 19 | &nbsp; IN1 | Insurance | R | - | INSURANCE |
| 20 | &nbsp; IN2 | Insurance Additional Info | O | - | INSURANCE |
| 21 | &nbsp; IN3 | Insurance Additional Info - Cert. | O | * | INSURANCE |
| 22 | &nbsp; ROL | Role | O | * | INSURANCE |
| 23 | ACC | Accident | O | - | -- |
| 24 | UB1 | UB82 Data | O | - | -- |
| 25 | UB2 | UB92 Data | O | - | -- |
| 26 | PDA | Patient Death and Autopsy | O | - | -- |

**Notes:**
- ROL at position 6 is for patient-level roles (e.g., primary care provider).
- ROL at position 10 is for visit-level roles (e.g., attending physician).
- PROCEDURE group: PR1 is the anchor; each repetition starts with PR1.
- INSURANCE group: IN1 is the anchor; each repetition starts with IN1.

---

## 2. ADT^A02 -- Transfer a Patient

**Structure:** ADT_A02
**Chapter:** 3 (Patient Administration)
**Use case:** Patient changes assigned physical location (bed/ward transfer).

| # | Segment | Description | Opt | Repeat | Group |
|---|---------|-------------|-----|--------|-------|
| 1 | MSH | Message Header | R | - | -- |
| 2 | SFT | Software Segment | O | * | -- |
| 3 | EVN | Event Type | R | - | -- |
| 4 | PID | Patient Identification | R | - | -- |
| 5 | PD1 | Patient Additional Demographic | O | - | -- |
| 6 | ROL | Role | O | * | -- |
| 7 | PV1 | Patient Visit | R | - | -- |
| 8 | PV2 | Patient Visit - Additional Info | O | - | -- |
| 9 | ROL | Role | O | * | -- |
| 10 | DB1 | Disability | O | * | -- |
| 11 | OBX | Observation/Result | O | * | -- |
| 12 | PDA | Patient Death and Autopsy | O | - | -- |

**Notes:**
- Simpler than A01: no NK1, AL1, DG1, DRG, PROCEDURE, GT1, INSURANCE, ACC, UB1, UB2.
- PV1-3 (Assigned Patient Location) contains the NEW location.
- PV1-6 (Prior Patient Location) contains the location being transferred FROM.

---

## 3. ADT^A03 -- Discharge/End Visit

**Structure:** ADT_A03
**Chapter:** 3 (Patient Administration)
**Use case:** End of a patient's stay. Status changes to "discharged" and discharge date is recorded.

| # | Segment | Description | Opt | Repeat | Group |
|---|---------|-------------|-----|--------|-------|
| 1 | MSH | Message Header | R | - | -- |
| 2 | SFT | Software Segment | O | * | -- |
| 3 | EVN | Event Type | R | - | -- |
| 4 | PID | Patient Identification | R | - | -- |
| 5 | PD1 | Patient Additional Demographic | O | - | -- |
| 6 | ROL | Role | O | * | -- |
| 7 | NK1 | Next of Kin / Associated Parties | O | * | -- |
| 8 | PV1 | Patient Visit | R | - | -- |
| 9 | PV2 | Patient Visit - Additional Info | O | - | -- |
| 10 | ROL | Role | O | * | -- |
| 11 | DB1 | Disability | O | * | -- |
| 12 | AL1 | Patient Allergy Information | O | * | -- |
| 13 | DG1 | Diagnosis | O | * | -- |
| 14 | DRG | Diagnosis Related Group | O | - | -- |
| -- | --- PROCEDURE (group) | | O | * | -- |
| 15 | &nbsp; PR1 | Procedures | R | - | PROCEDURE |
| 16 | &nbsp; ROL | Role | O | * | PROCEDURE |
| 17 | OBX | Observation/Result | O | * | -- |
| 18 | GT1 | Guarantor | O | * | -- |
| -- | --- INSURANCE (group) | | O | * | -- |
| 19 | &nbsp; IN1 | Insurance | R | - | INSURANCE |
| 20 | &nbsp; IN2 | Insurance Additional Info | O | - | INSURANCE |
| 21 | &nbsp; IN3 | Insurance Additional Info - Cert. | O | * | INSURANCE |
| 22 | &nbsp; ROL | Role | O | * | INSURANCE |
| 23 | ACC | Accident | O | - | -- |
| 24 | PDA | Patient Death and Autopsy | O | - | -- |

**Notes:**
- Very similar to A01 but omits UB1 and UB2.
- PV1-3 (Assigned Patient Location) contains the patient's location prior to discharge.
- PV1-36 (Discharge Disposition) and PV1-37 (Discharged to Location) carry discharge details.

---

## 4. ADT^A04 -- Register a Patient

**Structure:** ADT_A01 (same abstract message structure as A01)
**Chapter:** 3 (Patient Administration)
**Use case:** Register an outpatient or pre-admit a patient. No bed assignment -- the patient does not need to be "admitted."

Segment structure is **identical to ADT^A01** (see section 1 above).

**Notes:**
- A04 uses the ADT_A01 message structure.
- Distinguished from A01 by MSH-9.2 (Trigger Event = A04).
- Typically used for outpatient registration or emergency department registration.

---

## 5. ADT^A08 -- Update Patient Information

**Structure:** ADT_A01 (same abstract message structure as A01)
**Chapter:** 3 (Patient Administration)
**Use case:** Update patient demographic or visit information without a status change.

Segment structure is **identical to ADT^A01** (see section 1 above).

**Notes:**
- A08 uses the ADT_A01 message structure.
- No status change implied -- purely informational update.
- Commonly used for address changes, insurance updates, next-of-kin changes, etc.

---

## 6. ADT^A11 -- Cancel Admit/Visit Notification

**Structure:** ADT_A09
**Chapter:** 3 (Patient Administration)
**Use case:** Cancel a previously-sent A01 admission. The patient's status reverts.

| # | Segment | Description | Opt | Repeat | Group |
|---|---------|-------------|-----|--------|-------|
| 1 | MSH | Message Header | R | - | -- |
| 2 | SFT | Software Segment | O | * | -- |
| 3 | EVN | Event Type | R | - | -- |
| 4 | PID | Patient Identification | R | - | -- |
| 5 | PD1 | Patient Additional Demographic | O | - | -- |
| 6 | PV1 | Patient Visit | R | - | -- |
| 7 | PV2 | Patient Visit - Additional Info | O | - | -- |
| 8 | DB1 | Disability | O | * | -- |
| 9 | OBX | Observation/Result | O | * | -- |
| 10 | DG1 | Diagnosis | O | * | -- |

**Notes:**
- Uses the ADT_A09 abstract message structure (shared with A09, A10, A11, A12).
- Significantly simpler than A01 -- no ROL, NK1, AL1, DRG, PROCEDURE, GT1, INSURANCE, ACC, UB1, UB2, PDA.
- EVN-2 (Recorded Date/Time) should reflect when the cancel was recorded.

---

## 7. ADT^A13 -- Cancel Discharge/End Visit

**Structure:** ADT_A01 (same abstract message structure as A01)
**Chapter:** 3 (Patient Administration)
**Use case:** Cancel a previously-sent A03 discharge. The patient's status reverts to admitted.

Segment structure is **identical to ADT^A01** (see section 1 above).

**Notes:**
- A13 uses the ADT_A01 message structure.
- Reverses the effects of A03: the patient is re-admitted.
- The patient's location should be restored to the pre-discharge location.

---

## 8. ADT^A28 -- Add Person Information

**Structure:** ADT_A05
**Chapter:** 3 (Patient Administration)
**Use case:** Add demographic information for a person who may or may not be a patient yet. Used for Master Patient Index (MPI) operations.

| # | Segment | Description | Opt | Repeat | Group |
|---|---------|-------------|-----|--------|-------|
| 1 | MSH | Message Header | R | - | -- |
| 2 | SFT | Software Segment | O | * | -- |
| 3 | EVN | Event Type | R | - | -- |
| 4 | PID | Patient Identification | R | - | -- |
| 5 | PD1 | Patient Additional Demographic | O | - | -- |
| 6 | ROL | Role | O | * | -- |
| 7 | NK1 | Next of Kin / Associated Parties | O | * | -- |
| 8 | PV1 | Patient Visit | R | - | -- |
| 9 | PV2 | Patient Visit - Additional Info | O | - | -- |
| 10 | ROL | Role | O | * | -- |
| 11 | DB1 | Disability | O | * | -- |
| 12 | OBX | Observation/Result | O | * | -- |
| 13 | AL1 | Patient Allergy Information | O | * | -- |
| 14 | DG1 | Diagnosis | O | * | -- |
| 15 | DRG | Diagnosis Related Group | O | - | -- |
| -- | --- PROCEDURE (group) | | O | * | -- |
| 16 | &nbsp; PR1 | Procedures | R | - | PROCEDURE |
| 17 | &nbsp; ROL | Role | O | * | PROCEDURE |
| 18 | GT1 | Guarantor | O | * | -- |
| -- | --- INSURANCE (group) | | O | * | -- |
| 19 | &nbsp; IN1 | Insurance | R | - | INSURANCE |
| 20 | &nbsp; IN2 | Insurance Additional Info | O | - | INSURANCE |
| 21 | &nbsp; IN3 | Insurance Additional Info - Cert. | O | * | INSURANCE |
| 22 | &nbsp; ROL | Role | O | * | INSURANCE |
| 23 | ACC | Accident | O | - | -- |
| 24 | UB1 | UB82 Data | O | - | -- |
| 25 | UB2 | UB92 Data | O | - | -- |

**Notes:**
- Uses the ADT_A05 abstract message structure (shared with A05, A14, A28, A31).
- A28 is a non-visit event -- it adds person-level data to the MPI.
- PV1 is required by the structure but PV1-2 (Patient Class) is typically set to "N" (not applicable).
- Differs from A01 only in the absence of PDA.

---

## 9. ADT^A31 -- Update Person Information

**Structure:** ADT_A05 (same abstract message structure as A28)
**Chapter:** 3 (Patient Administration)
**Use case:** Update demographic information for a person in the MPI without changing visit status.

Segment structure is **identical to ADT^A28 / ADT_A05** (see section 8 above).

**Notes:**
- A31 uses the ADT_A05 message structure, same as A28.
- Distinguished from A28 by MSH-9.2 (Trigger Event = A31).
- A28 = new person record; A31 = update existing person record.

---

## 10. ADT^A40 -- Merge Patient - Patient Identifier List

**Structure:** ADT_A39
**Chapter:** 3 (Patient Administration)
**Use case:** Merge two patient records at the identifier level. The "incorrect" identifier (in MRG) is merged into the "correct" identifier (in PID).

| # | Segment | Description | Opt | Repeat | Group |
|---|---------|-------------|-----|--------|-------|
| 1 | MSH | Message Header | R | - | -- |
| 2 | SFT | Software Segment | O | * | -- |
| 3 | EVN | Event Type | R | - | -- |
| -- | --- PATIENT_ID (group) | | R | * | -- |
| 4 | &nbsp; PID | Patient Identification | R | - | PATIENT_ID |
| 5 | &nbsp; PD1 | Patient Additional Demographic | O | - | PATIENT_ID |
| 6 | &nbsp; MRG | Merge Patient Information | R | - | PATIENT_ID |
| 7 | &nbsp; PV1 | Patient Visit | O | - | PATIENT_ID |

**Notes:**
- PID contains the "correct" (surviving) patient identifier.
- MRG-1 (Prior Patient Identifier List) contains the "incorrect" identifier being merged away.
- The PATIENT_ID group repeats to allow batch merges in a single message.
- PV1 is optional within the group -- used when the merge involves visit-level data.
- PID is the anchor segment for the PATIENT_ID group.
- After merge, the MRG identifier should never be referenced in future transactions.

---

## 11. ORM^O01 -- General Order Message

**Structure:** ORM_O01
**Chapter:** 4 (Order Entry)
**Use case:** Place, cancel, discontinue, hold, or otherwise manage orders. (Legacy -- OMG/OML/OMD/OMS/OMN/OMI/OMP are preferred for new implementations.)

| # | Segment | Description | Opt | Repeat | Group |
|---|---------|-------------|-----|--------|-------|
| 1 | MSH | Message Header | R | - | -- |
| 2 | NTE | Notes and Comments | O | * | -- |
| -- | --- PATIENT (group) | | O | - | -- |
| 3 | &nbsp; PID | Patient Identification | R | - | PATIENT |
| 4 | &nbsp; PD1 | Patient Additional Demographic | O | - | PATIENT |
| 5 | &nbsp; NTE | Notes and Comments | O | * | PATIENT |
| -- | &nbsp; --- PATIENT_VISIT (subgroup) | | O | - | PATIENT |
| 6 | &nbsp;&nbsp; PV1 | Patient Visit | R | - | PATIENT_VISIT |
| 7 | &nbsp;&nbsp; PV2 | Patient Visit - Additional Info | O | - | PATIENT_VISIT |
| -- | &nbsp; --- INSURANCE (subgroup) | | O | * | PATIENT |
| 8 | &nbsp;&nbsp; IN1 | Insurance | R | - | INSURANCE |
| 9 | &nbsp;&nbsp; IN2 | Insurance Additional Info | O | - | INSURANCE |
| 10 | &nbsp;&nbsp; IN3 | Insurance Additional Info - Cert. | O | - | INSURANCE |
| 11 | &nbsp; GT1 | Guarantor | O | - | PATIENT |
| 12 | &nbsp; AL1 | Patient Allergy Information | O | * | PATIENT |
| -- | --- ORDER (group) | | R | * | -- |
| 13 | &nbsp; ORC | Common Order | R | - | ORDER |
| -- | &nbsp; --- ORDER_DETAIL (subgroup) | | O | - | ORDER |
| 14 | &nbsp;&nbsp; OBR | Observation Request | R | - | ORDER_DETAIL |
| 15 | &nbsp;&nbsp; RQD | Requisition Detail | R | - | ORDER_DETAIL |
| 16 | &nbsp;&nbsp; RQ1 | Requisition Detail-1 | R | - | ORDER_DETAIL |
| 17 | &nbsp;&nbsp; RXO | Pharmacy/Treatment Order | R | - | ORDER_DETAIL |
| 18 | &nbsp;&nbsp; ODS | Dietary Orders, Supplements, Preferences | R | - | ORDER_DETAIL |
| 19 | &nbsp;&nbsp; ODT | Diet Tray Instructions | R | - | ORDER_DETAIL |
| 20 | &nbsp;&nbsp; NTE | Notes and Comments | O | * | ORDER_DETAIL |
| 21 | &nbsp;&nbsp; CTD | Contact Data | O | - | ORDER_DETAIL |
| 22 | &nbsp;&nbsp; DG1 | Diagnosis | O | * | ORDER_DETAIL |
| -- | &nbsp;&nbsp; --- OBSERVATION (subgroup) | | O | * | ORDER_DETAIL |
| 23 | &nbsp;&nbsp;&nbsp; OBX | Observation/Result | R | - | OBSERVATION |
| 24 | &nbsp;&nbsp;&nbsp; NTE | Notes and Comments | O | * | OBSERVATION |
| 25 | &nbsp; CTI | Clinical Trial Identification | O | * | ORDER |
| 26 | &nbsp; BLG | Billing | O | - | ORDER |

**Notes:**
- ORDER_DETAIL choice: only ONE of OBR/RQD/RQ1/RXO/ODS/ODT is used per order, determined by the order type. For radiology/lab orders, OBR is the relevant segment.
- ORC is the anchor for the ORDER group; each order repetition starts with ORC.
- The PATIENT group is optional (patient context may come from a prior ADT or be implied).
- PID is the anchor for the PATIENT group.
- IN1 is the anchor for the INSURANCE subgroup.
- This is a legacy message; prefer OML^O21, OMI^O23, etc. for new implementations.

---

## 12. ORU^R01 -- Unsolicited Observation Result

**Structure:** ORU_R01
**Chapter:** 7 (Observation Reporting)
**Use case:** Transmit laboratory or other observation results to downstream systems.

| # | Segment | Description | Opt | Repeat | Group |
|---|---------|-------------|-----|--------|-------|
| 1 | MSH | Message Header | R | - | -- |
| 2 | SFT | Software Segment | O | * | -- |
| -- | --- PATIENT_RESULT (group) | | R | * | -- |
| -- | &nbsp; --- PATIENT (subgroup) | | O | - | PATIENT_RESULT |
| 3 | &nbsp;&nbsp; PID | Patient Identification | R | - | PATIENT |
| 4 | &nbsp;&nbsp; PD1 | Patient Additional Demographic | O | - | PATIENT |
| 5 | &nbsp;&nbsp; NTE | Notes and Comments | O | * | PATIENT |
| 6 | &nbsp;&nbsp; NK1 | Next of Kin / Associated Parties | O | * | PATIENT |
| -- | &nbsp;&nbsp; --- VISIT (subgroup) | | O | - | PATIENT |
| 7 | &nbsp;&nbsp;&nbsp; PV1 | Patient Visit | R | - | VISIT |
| 8 | &nbsp;&nbsp;&nbsp; PV2 | Patient Visit - Additional Info | O | - | VISIT |
| -- | &nbsp; --- ORDER_OBSERVATION (subgroup) | | R | * | PATIENT_RESULT |
| 9 | &nbsp;&nbsp; ORC | Common Order | O | - | ORDER_OBSERVATION |
| 10 | &nbsp;&nbsp; OBR | Observation Request | R | - | ORDER_OBSERVATION |
| 11 | &nbsp;&nbsp; NTE | Notes and Comments | O | * | ORDER_OBSERVATION |
| -- | &nbsp;&nbsp; --- TIMING_QTY (subgroup) | | O | * | ORDER_OBSERVATION |
| 12 | &nbsp;&nbsp;&nbsp; TQ1 | Timing/Quantity | R | - | TIMING_QTY |
| 13 | &nbsp;&nbsp;&nbsp; TQ2 | Timing/Quantity Relationship | O | * | TIMING_QTY |
| 14 | &nbsp;&nbsp; CTD | Contact Data | O | - | ORDER_OBSERVATION |
| -- | &nbsp;&nbsp; --- OBSERVATION (subgroup) | | O | * | ORDER_OBSERVATION |
| 15 | &nbsp;&nbsp;&nbsp; OBX | Observation/Result | R | - | OBSERVATION |
| 16 | &nbsp;&nbsp;&nbsp; NTE | Notes and Comments | O | * | OBSERVATION |
| 17 | &nbsp;&nbsp; FT1 | Financial Transaction | O | * | ORDER_OBSERVATION |
| 18 | &nbsp;&nbsp; CTI | Clinical Trial Identification | O | * | ORDER_OBSERVATION |
| -- | &nbsp;&nbsp; --- SPECIMEN (subgroup) | | O | * | ORDER_OBSERVATION |
| 19 | &nbsp;&nbsp;&nbsp; SPM | Specimen | R | - | SPECIMEN |
| 20 | &nbsp;&nbsp;&nbsp; OBX | Observation/Result | O | * | SPECIMEN |
| 21 | DSC | Continuation Pointer | O | - | -- |

**Notes:**
- PATIENT_RESULT is the top-level repeating group. Each repetition contains an optional PATIENT subgroup and one or more ORDER_OBSERVATION subgroups.
- OBR is the anchor for each ORDER_OBSERVATION repetition.
- OBX is the anchor for each OBSERVATION repetition.
- ORC is optional at the ORU level (it is required at the ORM level).
- For radiology results, OBR-4 (Universal Service ID) identifies the procedure, and OBX segments carry the report text (OBX-2 = "TX" or "FT").
- SPM (Specimen) is new in v2.5; it replaces the use of OBR-15/16 for specimen info.
- DSC is for continuation of large result sets (rarely used).

---

## 13. ACK -- General Acknowledgment

**Structure:** ACK
**Chapter:** 2 (Control)
**Use case:** Acknowledge receipt and acceptance/rejection of any HL7 message. Used when no application-specific ACK is defined, or when an error prevents application processing.

| # | Segment | Description | Opt | Repeat | Group |
|---|---------|-------------|-----|--------|-------|
| 1 | MSH | Message Header | R | - | -- |
| 2 | SFT | Software Segment | O | * | -- |
| 3 | MSA | Message Acknowledgment | R | - | -- |
| 4 | ERR | Error | O | * | -- |

**Notes:**
- MSH-9.2 (Trigger Event) echoes the trigger event of the message being acknowledged.
- MSH-9.3 (Message Structure) is always "ACK".
- MSA-1 (Acknowledgment Code): AA = accept, AE = error, AR = reject.
- MSA-2 (Message Control ID) echoes MSH-10 of the original message.
- ERR segment provides error location (segment, field, component) and error codes.
- The simplest possible HL7 response message.

---

## 14. SIU^S12 -- Notification of New Appointment Booking

**Structure:** SIU_S12
**Chapter:** 10 (Scheduling)
**Use case:** Filler application notifies other systems that a new appointment has been booked.

| # | Segment | Description | Opt | Repeat | Group |
|---|---------|-------------|-----|--------|-------|
| 1 | MSH | Message Header | R | - | -- |
| 2 | SCH | Scheduling Activity Information | R | - | -- |
| 3 | TQ1 | Timing/Quantity | O | * | -- |
| 4 | NTE | Notes and Comments | O | * | -- |
| -- | --- PATIENT (group) | | O | * | -- |
| 5 | &nbsp; PID | Patient Identification | R | - | PATIENT |
| 6 | &nbsp; PD1 | Patient Additional Demographic | O | - | PATIENT |
| 7 | &nbsp; PV1 | Patient Visit | O | - | PATIENT |
| 8 | &nbsp; PV2 | Patient Visit - Additional Info | O | - | PATIENT |
| 9 | &nbsp; OBX | Observation/Result | O | * | PATIENT |
| 10 | &nbsp; DG1 | Diagnosis | O | * | PATIENT |
| -- | --- RESOURCES (group) | | R | * | -- |
| 11 | &nbsp; RGS | Resource Group | R | - | RESOURCES |
| -- | &nbsp; --- SERVICE (subgroup) | | O | * | RESOURCES |
| 12 | &nbsp;&nbsp; AIS | Appointment Information - Service | R | - | SERVICE |
| 13 | &nbsp;&nbsp; NTE | Notes and Comments | O | * | SERVICE |
| -- | &nbsp; --- GENERAL_RESOURCE (subgroup) | | O | * | RESOURCES |
| 14 | &nbsp;&nbsp; AIG | Appointment Information - General Resource | R | - | GENERAL_RESOURCE |
| 15 | &nbsp;&nbsp; NTE | Notes and Comments | O | * | GENERAL_RESOURCE |
| -- | &nbsp; --- LOCATION_RESOURCE (subgroup) | | O | * | RESOURCES |
| 16 | &nbsp;&nbsp; AIL | Appointment Information - Location Resource | R | - | LOCATION_RESOURCE |
| 17 | &nbsp;&nbsp; NTE | Notes and Comments | O | * | LOCATION_RESOURCE |
| -- | &nbsp; --- PERSONNEL_RESOURCE (subgroup) | | O | * | RESOURCES |
| 18 | &nbsp;&nbsp; AIP | Appointment Information - Personnel Resource | R | - | PERSONNEL_RESOURCE |
| 19 | &nbsp;&nbsp; NTE | Notes and Comments | O | * | PERSONNEL_RESOURCE |

**Notes:**
- SCH contains the appointment details (placer/filler IDs, timing, duration, reason).
- RGS is the anchor for the RESOURCES group; each resource group repetition starts with RGS.
- Within RESOURCES, the four subgroups describe different resource types:
  - SERVICE (AIS): the clinical service being performed
  - GENERAL_RESOURCE (AIG): equipment or other general resources
  - LOCATION_RESOURCE (AIL): rooms, exam lanes, etc.
  - PERSONNEL_RESOURCE (AIP): physicians, technologists, etc.
- PID is the anchor for the PATIENT group.
- TQ1 at the message level specifies the timing of the scheduled activity.

---

## 15. SIU^S14 -- Notification of Appointment Modification

**Structure:** SIU_S12 (same abstract message structure as S12)
**Chapter:** 10 (Scheduling)
**Use case:** Filler application notifies other systems that an existing appointment has been modified.

Segment structure is **identical to SIU^S12** (see section 14 above).

**Notes:**
- S14 uses the SIU_S12 message structure.
- Distinguished from S12 by MSH-9.2 (Trigger Event = S14).
- SCH segment contains the updated appointment details.
- Modifications may include time changes, resource changes, or status updates.

---

## 16. SIU^S15 -- Notification of Appointment Cancellation

**Structure:** SIU_S12 (same abstract message structure as S12)
**Chapter:** 10 (Scheduling)
**Use case:** Filler application notifies other systems that an existing appointment has been cancelled.

Segment structure is **identical to SIU^S12** (see section 14 above).

**Notes:**
- S15 uses the SIU_S12 message structure.
- Distinguished from S12 by MSH-9.2 (Trigger Event = S15).
- SCH-25 (Filler Status Code) typically reflects the cancelled status.
- The appointment's resources should be released/freed.

---

## Abstract Message Structure Sharing Summary

Multiple trigger events share the same abstract message structure. This is important for parser implementation -- the parser maps by structure, not by trigger event.

| Abstract Structure | Trigger Events Using It |
|-------------------|------------------------|
| ADT_A01 | A01, A04, A08, A13 |
| ADT_A02 | A02 |
| ADT_A03 | A03 |
| ADT_A05 | A05, A14, A28, A31 |
| ADT_A09 | A09, A10, A11, A12 |
| ADT_A39 | A39, A40, A41, A42 |
| ORM_O01 | O01 |
| ORU_R01 | R01 |
| ACK | (general) |
| SIU_S12 | S12, S13, S14, S15, S16, S17, S18, S19, S20, S21, S22, S23, S24, S26 |

## Segment Full Names Quick Reference

| Code | Full Name |
|------|-----------|
| ACC | Accident |
| AIG | Appointment Information - General Resource |
| AIL | Appointment Information - Location Resource |
| AIP | Appointment Information - Personnel Resource |
| AIS | Appointment Information - Service |
| AL1 | Patient Allergy Information |
| BLG | Billing |
| CTD | Contact Data |
| CTI | Clinical Trial Identification |
| DB1 | Disability |
| DG1 | Diagnosis |
| DRG | Diagnosis Related Group |
| DSC | Continuation Pointer |
| ERR | Error |
| EVN | Event Type |
| FT1 | Financial Transaction |
| GT1 | Guarantor |
| IN1 | Insurance |
| IN2 | Insurance Additional Information |
| IN3 | Insurance Additional Information - Certification |
| MRG | Merge Patient Information |
| MSA | Message Acknowledgment |
| MSH | Message Header |
| NK1 | Next of Kin / Associated Parties |
| NTE | Notes and Comments |
| OBR | Observation Request |
| OBX | Observation/Result |
| ODS | Dietary Orders, Supplements, and Preferences |
| ODT | Diet Tray Instructions |
| ORC | Common Order |
| PD1 | Patient Additional Demographic |
| PDA | Patient Death and Autopsy |
| PID | Patient Identification |
| PR1 | Procedures |
| PV1 | Patient Visit |
| PV2 | Patient Visit - Additional Information |
| RGS | Resource Group |
| ROL | Role |
| RQ1 | Requisition Detail-1 |
| RQD | Requisition Detail |
| RXO | Pharmacy/Treatment Order |
| SCH | Scheduling Activity Information |
| SFT | Software Segment |
| SPM | Specimen |
| TQ1 | Timing/Quantity |
| TQ2 | Timing/Quantity Relationship |
| UB1 | UB82 Data |
| UB2 | UB92 Data |

## Sources

- HL7 v2.5.1 Standard: PS3.2 (Control), PS3.3 (Patient Administration), PS3.4 (Order Entry), PS3.7 (Observation Reporting), PS3.10 (Scheduling)
- [Caristix HL7-Definition V2 - HL7 v2.5.1 Trigger Events](https://hl7-definition.caristix.com/v2/HL7v2.5.1/TriggerEvents)
- HL7 International: [https://www.hl7.org/implement/standards/product_brief.cfm?product_id=144](https://www.hl7.org/implement/standards/product_brief.cfm?product_id=144)
