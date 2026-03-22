# HL7v2 Conformance Roadmap

## Current State (v0.5.6)

Strong raw round-trip core. Typed support for a focused ADT/ORM/ORU/SIU/ACK subset.
Presence-only validation. 21 standard segments, 43 v2.5.1 types + legacy TN,
20 message structure definitions.

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

### M2: Standard Model

Build-time v2.5.1 metadata generation and conformance test infrastructure.

- [ ] v2.5.1 segment/field/type dataset (JSON or Elixir term, build-time generated)
- [ ] Trigger-to-structure mapping from spec (replace hand-curated map)
- [ ] Group/anchor/cardinality metadata for message structures
- [ ] Conformance test fixture pipeline (spec-derived + synthetic + real-world)
- [ ] Capability tier flags per segment/type/structure
- [ ] Generated coverage ledger (replaces hand-maintained README counts)

### M3: Narrow But Real Conformance

Structural validation for the core ADT/ACK/ORU/SIU subset.

- [ ] Message structure AST (segments, groups, anchors, cardinality, alternatives)
- [ ] Structural validator: order, group anchors, cardinality, nesting
- [ ] Detection: orphan segments, wrong order, repeated non-repeatables, missing anchors
- [ ] Strict vs lenient parse/validate modes
- [ ] Positive + negative validation tests per supported structure

### M4: Order/Observation Expansion

Fill type gaps and complete realistic ORM_O01 / ORU_R01.

- [ ] Missing types: TQ, TM, SPS, ELD, ED, SN, RP, CF, RPT, PLN, PPN
- [ ] Remove :raw holes in OBR-15, OBR-27, ORC-7, SCH-11, ERR-1
- [ ] OBX-5 dispatch for ED, SN, RP, TM
- [ ] Segments: SPM, TQ1, TQ2, CTD, CTI

### M5: Broad Clinical Coverage

Patient admin, scheduling, insurance, procedure segments.

- [ ] Core control: SFT, DSC, BHS, BTS
- [ ] Patient admin: PD1, ROL, DB1, DRG, ACC, PDA, PR1, IN2, IN3
- [ ] Scheduling: AIG, AIL, AIP
- [ ] Order/pharmacy: RQD, RQ1, RXO, ODS, ODT, BLG (if needed)

### M6: Versioned Conformance Platform

- [ ] HL7 table/coded-value validation (opt-in, versioned)
- [ ] Version-aware support (v2.3-v2.8.2 deltas)
- [ ] Generated reference docs (types, segments, structures, raw holes, validation depth)
- [ ] Release gates (metadata sync, conformance green, coverage ledger, no asymmetries)

## Scope Reality

| Stop at | You get |
|---------|---------|
| M1 | Honest, strong raw toolkit with typed subset (current) |
| M3 | Honest, strong library with real structural validation |
| M4 | Strong practical interoperability for common HL7 workflows |
| M6 | Serious HL7 v2 conformance platform |

## Execution Order

1. Contract honesty + correctness fixes (M1 — DONE)
2. Metadata generation + conformance test harness (M2)
3. Structural validator rewrite (M3)
4. Datatype expansion (M4)
5. Segment expansion for ADT/ORU/SIU core (M5)
6. Table validation + version compat + generated docs (M6)
