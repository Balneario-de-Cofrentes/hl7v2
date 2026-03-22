# HL7v2 Conformance Roadmap

## Current State (v1.0.0)

Strong raw round-trip core. Typed support for ADT/ORM/ORU/SIU/ACK with structural
validation (order, groups, cardinality) and opt-in HL7 table checking. 29 standard
segments, 48 v2.5.1 types, 20 group-aware message structure definitions, 20 coded-value
tables, 1 raw hole (OBX-5 dispatch). 1,921 tests, 0 failures.

## Milestones

### M1: Honest Core — COMPLETE (v0.5.0-v0.5.6)

- [x] Fix DTM encode/parse fraction asymmetry (v0.5.6)
- [x] Fix fetch/2 raw tuple bounds (v0.5.6)
- [x] Fix fetch/2 component bounds (v0.5.5)
- [x] Fix subcomponent separator threading (v0.5.2)
- [x] Fix MSH-2 validation (v0.5.0)
- [x] Fix extra_fields preservation (v0.5.0)
- [x] Fix NM/DTM lexical preservation (v0.5.0)
- [x] Fix OBR fields 32-35 NDL type (v0.5.0)
- [x] Fix primitive extra components preservation (v0.5.1)
- [x] Fix ORM/ORU PID optional, SIU RGS required (v0.5.1)
- [x] Fix validation warnings vs errors (v0.5.4)
- [x] Fix builder separator derivation from MSH (v0.5.3)
- [x] Honest README: coverage counts, capability framing, raw holes
- [x] Presence validation naming everywhere
- [x] Implementation plan marked historical
- [x] MRG + RGS segments with tests
- [x] OBX dispatch extended (CQ, MO, DR, XON, CP, FC, TN)

### M2: Standard Model — COMPLETE (v0.6.0)

- [x] HL7v2.Standard module with segment catalog (~136), type catalog (~84), capability tiers
- [x] MessageStructure: 20 group-aware abstract message definitions
- [x] Coverage ledger: HL7v2.Standard.Coverage + `mix hl7v2.coverage` task
- [x] Conformance tests: 27 metadata + fixture round-trip tests
- [x] MessageDefinition delegates to MessageStructure

### M3: Narrow But Real Conformance — COMPLETE (v0.7.0)

- [x] Structural validator: order, group anchors, cardinality checking
- [x] Detection: wrong order, repeated non-repeatables, missing required/anchors
- [x] Strict vs lenient validation modes
- [x] 28 positive + negative structural validation tests
- [x] Validation.validate/1 uses structural validation for all 20 defined structures

### M4: Order/Observation Expansion — COMPLETE (v0.8.0)

- [x] TQ (Timing/Quantity, 12 components): OBR-27, ORC-7, SCH-11 now typed
- [x] ELD (Error Location and Description, 4 components): ERR-1 now typed
- [x] SPS (Specimen Source, 7 components): OBR-15 now typed
- [x] TM (Time primitive): added to OBX-5 dispatch
- [x] Raw holes: 6 → 1 (OBX-5 only, by design)
- [x] Type coverage: 48/84 (57.1%)

### M5: Broad Clinical Coverage — COMPLETE (v0.9.0)

- [x] SFT (Software Segment)
- [x] PD1, DB1, ACC, PR1 (Patient admin / procedures)
- [x] AIG, AIL, AIP (Scheduling resources)
- [x] Segment coverage: 29/136 (21.3%)
- [x] 647 declared fields, 1 raw hole (OBX-5)
- [ ] Remaining: ROL, DRG, PDA, IN2, IN3, DSC, BHS, BTS (lower priority)

### M6: Conformance Platform — COMPLETE (v1.0.0)

- [x] HL7 table/coded-value validation (20 tables, opt-in via `validate_tables: true`)
- [x] 11 coded fields checked against HL7 tables (MSH, PID, PV1, MSA, OBX)
- [x] Tables API: `HL7v2.Standard.Tables.valid?/2`, `validate/2`, `get/1`
- [x] Final README/CHANGELOG accuracy pass
- [x] Conformance roadmap finalized
- [ ] Version-aware support deferred (v2.3-v2.8.2 deltas — future work)

## Scope Reality

| Stop at | You get | Status |
|---------|---------|--------|
| M1 | Honest, strong raw toolkit with typed subset | DONE (v0.5.x) |
| M3 | Real structural validation for supported structures | DONE (v0.7.0) |
| M4 | Strong practical interoperability (no raw holes) | DONE (v0.8.0) |
| M5 | Broad clinical segment coverage | DONE (v0.9.0) |
| M6 | Table validation + conformance platform | DONE (v1.0.0) |

## Execution Order

1. Contract honesty + correctness fixes (M1 — DONE)
2. Metadata generation + conformance test harness (M2 — DONE)
3. Structural validator rewrite (M3)
4. Datatype expansion (M4)
5. Segment expansion for ADT/ORU/SIU core (M5)
6. Table validation + version compat + generated docs (M6)
