# IHE Profile Pack — Field-Level Specification

Internal working reference distilled from the IHE ITI, PaLM, and RAD
Technical Frameworks. This drives `HL7v2.Profiles.IHE.*`. Not user-
facing documentation — see `guides/ihe-profiles.md` for that.

Each row that says "R" is a constraint the profile MUST encode. Rows
labeled "X" are IHE-forbidden (HL7 base may allow them).

**Shared IHE conventions across all transactions:**

- PID-3 Assigning Authority (CX-4) MUST be populated per repetition.
- MSH-8 Security is forbidden in IHE PAM/PIX/PDQ (not LAB/RAD).
- MSH-14 Continuation Pointer forbidden in PAM.
- EVN-1 Event Type Code is forbidden (deprecated; use MSH-9).
- HL7 version: v2.5 for PAM/PIX-Query/PDQ/RAD-OMI, **v2.3.1 for ITI-8
  and RAD-1 base**, v2.5.1 for LAB.

**Source citations**: each profile's `@doc` points at the specific
IHE TF section. Sources used:
`profiles.ihe.net/ITI/TF/Volume2/ITI-{8,9,10,21,22,30,31}.html`,
`IHE_PaLM_TF_Vol2a/2x Rev 11.0` (2024-04-08),
`IHE_RAD_TF_Rev13.0_Vol2` (2014-07-30).

---

## PAM — Patient Administration Management (IHE ITI)

### ITI-31 Patient Encounter Management — ADT^A01 (Admit)

- `message_type: {"ADT", "A01"}`
- `version: "2.5"`
- Required segments: `MSH`, `EVN`, `PID`, `PV1`
- Required fields:
  - `MSH-9`, `MSH-10`, `MSH-11`, `MSH-12`
  - `EVN-2` (Recorded Date/Time)
  - `PID-3` (Patient Identifier List, with Assigning Authority)
  - `PID-5` (Patient Name)
  - `PV1-2` (Patient Class)
  - `PV1-3` (Assigned Patient Location)
- Forbidden fields: `MSH-8`, `MSH-14`, `EVN-1`
- Value constraints:
  - `PV1-2` ∈ {I, O, E, P, R, B, C, N, U}
  - `PID-3` each repetition has CX-4 assigning authority populated

### ITI-31 ADT^A04 (Register Outpatient)

Same as A01. PV1-3 still R.

### ITI-31 ADT^A08 (Update Patient Information)

Same as A01. PV1-3 R.

### ITI-31 ADT^A03 (Discharge)

Like A01 but:
- `PV1-45` (Discharge Date/Time) RE (recommended, not hard R)
- `PV1-3` not required for A03

### ITI-31 ADT^A40 (Merge Patient — Patient ID List)

- `message_type: {"ADT", "A40"}`
- Required segments: `MSH`, `EVN`, `PID`, `MRG`
- Required fields: MSH-9/10/11/12, EVN-2, PID-3 (with AA), PID-5,
  `MRG-1` (Prior Patient Identifier List, with AA)
- Forbidden segments: `PV1` (not in A40 per ITI-31)
- MRG-1 assigning authority must match PID-3 assigning authority.

### ITI-30 ADT^A28 (Create Patient Record — no visit)

- `message_type: {"ADT", "A28"}`
- `version: "2.5"`
- Required segments: `MSH`, `EVN`, `PID`, `PV1`
- Required fields: MSH-9/10/12, EVN-2, PID-3 (with AA), PID-5
- Value constraint: `PV1-2` SHALL be `"N"` (Not Applicable — ITI-30 is
  outside encounter context)
- Forbidden fields: MSH-8, EVN-1

### ITI-30 ADT^A31 (Update Patient Information — no visit)

Same shape as A28. Used for ITI-10 (PIX Update Notification) as well
with slightly different rules (see PIX section).

### ITI-30 ADT^A40 (Merge — shared with ITI-31 A40)

---

## PIX — Patient Identifier Cross-Reference (IHE ITI)

### ITI-8 Patient Identity Feed — HL7 v2.3.1 (legacy)

Four variants on ADT triggers: A01, A04, A05, A08, A40.

**ITI-8 ADT^A01**

- `message_type: {"ADT", "A01"}`
- `version: "2.3.1"`
- Required segments: `MSH`, `EVN`, `PID`, `PV1`
- Required fields:
  - `PID-3` (with CX-4 Assigning Authority — namespace ID OR
    universal ID + universal ID type)
  - `PID-5` (Patient Name)
- Description must note "ITI-8 is on HL7 v2.3.1" — distinct from
  PAM (v2.5).

**ITI-8 ADT^A04/A05/A08** — same shape.

**ITI-8 ADT^A40** (merge)

- Required segments: `MSH`, `EVN`, `PID`, `MRG`, `PV1`
- Required fields: PID-3 (with AA), MRG-1 (Prior Patient ID List,
  with AA)

### ITI-9 PIX Query — QBP^Q23

- `message_type: {"QBP", "Q23"}`
- `version: "2.5"`
- Required segments: `MSH`, `QPD`, `RCP`
- Required fields:
  - `QPD-1` (Message Query Name), value pinned to `"IHE PIX Query"`
  - `QPD-2` (Query Tag)
  - `QPD-3` (Person Identifier — CX with CX-4 Assigning Authority)
  - `RCP-1` (Query Priority), value pinned to `"I"` (Immediate)

### ITI-9 PIX Query Response — RSP^K23

- `message_type: {"RSP", "K23"}`
- `version: "2.5"`
- Required segments: `MSH`, `MSA`, `QAK`, `QPD`
- Required fields:
  - `MSA-1` (Acknowledgment Code) — typically AA/AE
  - `QAK-1` (Query Tag)
  - `QAK-2` (Query Response Status) ∈ {OK, NF, AE}
- `PID` optional — present when MSA-1 = AA and IDs were found.

### ITI-10 PIX Update Notification — ADT^A31

- `message_type: {"ADT", "A31"}`
- `version: "2.5"`
- Required segments: `MSH`, `EVN`, `PID`, `PV1`
- Required fields: PID-3 (multi-rep with full AA), PID-5, EVN-2
- Value constraint: `PV1-2` SHALL be `"N"`
- Value constraint: `PID-5` first rep is a single space character
  (ITI-10 is outside-domain-specific)

---

## PDQ — Patient Demographics Query (IHE ITI)

### ITI-21 PDQ Query — QBP^Q22

- `message_type: {"QBP", "Q22"}`
- `version: "2.5"`
- Required segments: `MSH`, `QPD`, `RCP`
- Required fields:
  - `QPD-1` pinned to `"IHE PDQ Query"`
  - `QPD-2` (Query Tag)
  - `QPD-3` (Demographics Fields, at least one search criterion)
  - `RCP-1` pinned to `"I"`

### ITI-21 PDQ Query Response — RSP^K22

- `message_type: {"RSP", "K22"}`
- `version: "2.5"`
- Required segments: `MSH`, `MSA`, `QAK`, `QPD`
- `PID` group repeatable (one per matched patient), with PID-3, PID-5
  required on each returned PID.

### ITI-22 PDQ + Visit Query — QBP^ZV1

Same as ITI-21 but:
- `message_type: {"QBP", "ZV1"}`
- `QPD-3` may include PV1 search fields (PV1.2, PV1.3, PV1.7, PV1.8,
  PV1.9, PV1.10, PV1.17, PV1.19).

### ITI-22 PDQ + Visit Response — RSP^ZV2

- `message_type: {"RSP", "ZV2"}`
- Required segments: `MSH`, `MSA`, `QAK`, `QPD`
- Response per patient also includes `PV1` (R) per matched patient,
  with PV1-2 populated.

---

## LTW — Laboratory Testing Workflow (IHE PaLM)

### LAB-1 Placer Order Management — OML^O21

- `message_type: {"OML", "O21"}`
- `version: "2.5.1"`
- Required segments: `MSH`, `PID`, `ORC`, `OBR`
- Required fields:
  - `MSH-9`, `MSH-10`, `MSH-11`, `MSH-12`
  - `PID-3` (with AA), `PID-5`
  - `PV1-2` R (must be `"U"` if unknown)
  - `ORC-1` (Order Control), value ∈ {NW, OK, UA, SC, CA, CR, UC, OC,
    SN, NA, RP, RQ, UM, RU, XO, XR, UX, PR}
  - `ORC-9` (Date/Time of Transaction)
  - `OBR-2` (Placer Order Number)
  - `OBR-4` (Universal Service Identifier)
  - `OBR-16` (Ordering Provider)
- Forbidden fields: `ORC-7` (use TQ1), `OBR-5/6/8/12/13/14/15/22/27`

### LAB-2 Filler Order Management — OML^O21 (filler-initiated)

Like LAB-1 but:
- `OBR-3` (Filler Order Number) R instead of OBR-2
- ORC-1 expected values: {SN, NA, UA, OC, RU, XR, UX}

### LAB-3 Order Results Management — ORU^R01

- `message_type: {"ORU", "R01"}`
- `version: "2.5.1"`
- Required segments: `MSH`, `PID`, `ORC`, `OBR`, `OBX`
- Required fields:
  - PID-3 (with AA), PID-5
  - PV1-2 R (with "U" if unknown)
  - `OBR-3` (Filler Order Number) R — primary correlation key
  - `OBR-4` (Universal Service Identifier) R, components 1/2/3
    required (ID, Text, Coding System)
  - `OBR-25` (Order Result Status) R, value ∈ {S, I, R, P, F, C, X}
  - `OBX-1` (Set ID), `OBX-3` (Observation Identifier; in LAB-3 also
    OBX-3.2 Text required), `OBX-11` (Result Status) value ∈
    {O, I, D, R, P, F, C, X}
- Forbidden fields: `OBX-9`, `OBX-10`, `OBX-12`

---

## RAD-SWF — Radiology Scheduled Workflow (IHE RAD)

### RAD-1 Patient Registration — HL7 v2.3.1 ADT^A01

- `message_type: {"ADT", "A01"}`
- `version: "2.3.1"`
- Required segments: `MSH`, `EVN`, `PID`, `PV1`
- Required fields:
  - `EVN-2`, PID-3 (with AA, namespace ID required), PID-5, PID-8
    (Administrative Sex)
  - `PV1-2` (Patient Class)
  - `PV1-3` R when A01 (Assigned Patient Location)
  - `PV1-7` R when A01 (Attending Doctor)
  - `PV1-10` R when A01 (Hospital Service)
  - `PV1-17` R when A01 (Admitting Doctor)
  - At least one of `PID-18` or `PV1-19` populated (value
    constraint on the message as a whole — use `add_rule/3`).

### RAD-1 ADT^A04

Same as A01 but PV1-8 (Referring Doctor) R instead of PV1-7/10/17.
PV1-3 still R.

### RAD-1 ADT^A05

PV1-3 R, PV1-8 R.

### RAD-4 Procedure Scheduled — HL7 v2.5.1 Option OMI^O23

- `message_type: {"OMI", "O23"}`
- `version: "2.5.1"`
- Required segments: `MSH`, `PID`, `PV1`, `ORC`, `TQ1`, `OBR`, `IPC`
- Required fields:
  - PID-3 (with AA + Identifier Type Code), PID-5, PID-8
  - PV1-2
  - `ORC-1` value `"NW"`
  - `ORC-3` (Filler Order Number)
  - `ORC-5` value `"SC"`
  - `TQ1-7` (Start Date/Time)
  - `OBR-1` (Set ID)
  - `OBR-3` (Filler Order Number)
  - `OBR-4` (Universal Service Identifier)
  - `IPC-1` (Accession Identifier)
  - `IPC-2` (Requested Procedure ID)
  - `IPC-3` (Study Instance UID)
  - `IPC-4` (Scheduled Procedure Step ID)
  - `IPC-5` (Modality)
- Forbidden fields: `ORC-7`, `OBR-15`, `OBR-27` (replaced by TQ1 and
  OBR-46)

### RAD-13 Procedure Update — OMI^O23

Same segments as RAD-4. Differences are in ORC-1 and ORC-5 values:

- Cancel: `ORC-1 = "CA"`, `ORC-5 = "CA"`
- Change (in progress): `ORC-1 = "XO"`, `ORC-5 = "SC"`
- Change (completed): `ORC-1 = "XO"`, `ORC-5 = "CM"`
- Discontinue: `ORC-1 = "DC"`, `ORC-5 = "CA"`

Profile encodes `ORC-1` value constraint to the set {CA, DC, XO}.
Study Instance UID in `IPC-3` is the immutable correlation key.

---

## Cross-cutting DSL needs

The existing `HL7v2.Profile` DSL is missing one function that several
IHE transactions need:

- **`forbid_field/3`** — MSH-8 forbidden, EVN-1 forbidden, ORC-7
  forbidden in LAB, OBR-5/6/8 forbidden in LAB, etc.

Add this as part of the IHE work. Implementation: new `forbidden_fields`
field on the Profile struct (MapSet of `{segment_id, field_seq}`);
`ProfileRules.check/2` emits an `:forbid_field` error when the named
field has a non-nil value in the parsed message.

Value pinning is already expressible via `add_value_constraint/4` with
an equality predicate; a `pin_value/4` helper would be sugar but not
strictly required.

## Catalog structure

```
lib/hl7v2/profiles/
├── examples.ex               # existing toy examples, untouched
├── ihe.ex                    # new — top-level catalog module
└── ihe/
    ├── common.ex             # shared constraint helpers
    ├── pam.ex                # ITI-30, ITI-31 profiles
    ├── pix.ex                # ITI-8, ITI-9, ITI-10 profiles
    ├── pdq.ex                # ITI-21, ITI-22 profiles
    ├── ltw.ex                # LAB-1, LAB-2, LAB-3 profiles
    └── rad_swf.ex            # RAD-1, RAD-4, RAD-13 profiles
```

`HL7v2.Profiles.IHE.all/0` returns a map of
`{transaction_code => profile}` (e.g. `"ITI-31.A01" => Profile.t()`).
