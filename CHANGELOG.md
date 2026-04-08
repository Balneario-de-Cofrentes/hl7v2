# Changelog

All notable changes to this project will be documented in this file.

## v3.0.2 — 2026-04-08

### Fixes

- **PV2 transfer rule respects strict mode** — `prior_pending_location` check
  now escalates to `:error` in strict mode for transfer triggers. Previously
  hardcoded to `:warning` regardless of mode.
- **All 32 fixtures pass strict-clean validation** — fixtures fixed: NTE ordering
  in ADT_A01, PV2-1 populated in ADT_A02, BPX donation/commercial path in
  BPS_O29. Zero warnings under `mode: :strict`.
- **Fixture coverage percentage corrected** — 32 files map to 28 unique canonical
  structures (15.1% of 186 official), not 30% as previously claimed.

### Added

- **Strict-clean conformance suite** — new test describe block runs every fixture
  under `mode: :strict` and fails on any warning. Lenient round-trip suite is
  preserved separately.

### Stats

3,938 tests (472 doctests + 32 properties + 3,434 tests), 0 failures

## v3.0.1 — 2026-04-08

### Fixes

- **Structural validation skipped for non-canonical MSH-9.3 aliases** — messages
  with alias structures in MSH-9.3 (e.g., `SIU_S14`, `ADT_A28`, `REF_I13`) now
  canonicalize to the correct registered structure (SIU_S12, ADT_A05, REF_I12)
  before structural validation. Previously these returned "structure not checked"
  warnings despite having known canonical mappings.
- **MLLP client docs** — `send_message/3` docs now correctly state that protocol
  desync is terminal (closes connection, stops client process). Previously still
  described the old drain-and-continue behavior.
- **README install snippet** — updated from `~> 2.9` to `~> 3.0` with upgrade
  note about the breaking desync change.
- **Conformance roadmap** — current state updated to reflect 32 fixtures, 25
  trigger-aware conditional rules, and accurate raw gap counts.

### Stats

3,906 tests (472 doctests + 32 properties + 3,402 tests), 0 failures

## v3.0.0 — 2026-04-08

### Breaking

- **MLLP protocol desync is now a fatal error** — `send_message/3` returns
  `{:error, :protocol_desync}` and closes the connection if any stale bytes
  (complete or partial frames) are found in the buffer at a send boundary.
  Previously, complete stale frames were silently discarded and partial bytes
  were carried forward, potentially corrupting the next response.

### Added

- **Trigger-aware conditional validation** — scheduling segments (AIS, AIG,
  AIL, AIP, RGS) now check the message trigger event from MSH-9.2. Modification
  triggers (S03-S11) produce definitive checks; non-modification triggers skip
  the heuristic. PV2 `prior_pending_location` is validated against transfer
  triggers (A02, A06, A07, etc.). Without trigger context, the original
  heuristic fallback is preserved for backwards compatibility.
- **14 new conformance fixtures** — ADT_A02/A04/A08/A17, ORU_R01 multi-OBR,
  ORU_R30, OML_O21, OMI_O23, OMS_O05, RDS_O13, RAS_O17, BPS_O29, MFN_M01,
  SIU_S14. 32 fixture files covering 28 unique canonical structures (15% of
  186 official). All pass strict-clean validation.
- **OBX-5 runtime-dispatched** in coverage reporting — `mix hl7v2.coverage`
  now distinguishes between true raw gaps (QPD-3, RDT-1) and intentionally
  runtime-typed fields (OBX-5 VARIES via OBXValue dispatch).

### Stats

3,904 tests (472 doctests + 32 properties + 3,400 tests), 0 failures

## v2.12.0 — 2026-04-08

### Fixes

- **MLLP protocol desync** — any non-empty buffer at a send boundary now returns
  `{:error, :protocol_desync}` and closes the connection. Previously, stale
  complete frames were silently discarded (hiding protocol violations) and
  partial stale bytes could corrupt the next response by concatenating with it.
  MLLP is strictly 1:1 request/response; leftover bytes of any kind are now
  treated as a fatal protocol violation.
- **Stale secondary docs** — `docs/expansion-plan.md` marked as historical
  (was showing v1.3.0 state); `docs/conformance-roadmap.md` corrected to
  reflect the 3 remaining raw holes and current conditional rule count.

### Stats

3,876 tests (472 doctests + 32 properties + 3,372 tests), 0 failures

## v2.11.0 — 2026-04-08

### Fixes

- **MLLP request/response desync** — stale frames from misbehaving peers are
  now drained before each send, maintaining strict 1:1 request/response pairing.
  Previously, buffered extra frames would be returned as the response to a
  subsequent request, mispairing ACKs with outbound messages.
- **~h sigil** — now validates repetition legality (non-repeating field +
  repetition selector = compile error) and component bounds against typed
  field metadata at compile time.
- **Typed round-trip contract** — tests and docs now correctly describe typed
  encode/parse as "canonicalization is idempotent" rather than
  "identity-preserving" (trailing empty components are trimmed per HL7 encoding
  rules).

### Added

- **Reference docs in HexDocs** — segments, data types, message structures, and
  encoding rules are now included in the published documentation.
- **Known Limitations** section in README — documents the 3 raw field holes
  (OBX-5 VARIES, QPD-3, RDT-1), segment-local conditional validation, and typed
  canonicalization behavior.

### Stats

3,875 tests (472 doctests + 32 properties + 3,371 tests), 0 failures

## v2.10.0 — 2026-04-07

### Fixes

- **MLLP client multi-frame safety** — extra complete frames in a single TCP
  read are now re-framed back into the buffer instead of silently dropped;
  previous fix only preserved partial-frame remainders
- **fetch/2 component out-of-range on composites** — `MSH-9.99` and
  `PID-3.99[*]` now return `{:error, :invalid_component}` instead of
  `{:ok, nil}` or `{:ok, [nil, nil]}`
- **Flaky MLLP client test** — server-close test uses 1ms timeout + 300ms
  margin (was 50ms/100ms race)
- **parse/2 docs** — `validate: true` now documented as typed-mode only

### Added

- **8 new OBX-5 value types** — AD, MA, NA, NDL, PL, PPN, SPS, VR added to
  the dispatch map (41 types total, up from 33)
- **PV2 conditional rule** — warns when `expected_discharge_date_time` is set
  without `expected_discharge_disposition`
- **QAK conditional rule** — warns when `query_tag` is present without
  `query_response_status`

### Stats

3,875 tests (472 doctests + 32 properties + 3,371 tests), 0 failures

## v2.9.1 — 2026-04-07

### Fixes

- **MLLP client frame buffering** — leftover frames from multi-frame responses
  are now buffered in GenServer state and consumed on the next `send_message`
  call (was silently discarding extra frames)
- **fetch/2 out-of-range repetitions** — `PID-3[3]` with only 2 reps now returns
  `{:error, :repetition_out_of_range}` instead of `{:ok, nil}`

## v2.9.0 — 2026-04-07

### Generated Reference Docs + Structure Proof

- **`mix hl7v2.gen_docs`** — generates all reference docs from code metadata
- **message-structures.md**: 6,726 lines — all 222 structures with group notation
- **segments.md**: 3,516 lines — all 152 segments with field tables
- **data-types.md**: 1,162 lines — all 90 types with components
- **444 generated structure validation tests** — positive + negative for every
  structure. No more "selectively tested."
- Conformance assertions tightened to exact counts
- Stale moduledocs and roadmap fixed

### Stats

3,863 tests (472 doctests + 32 properties + 3,359 tests), 0 failures

## v2.8.2 — 2026-04-06

### Fixes

- **Flaky MLLP test** — increased sleep and assert_receive timeouts for telemetry
  exception events (was timing-sensitive under CI load)
- **TQ moduledoc** — removed stale "RI/OSD preserved as raw strings" (now typed)
- **SCD/SDD moduledoc** — removed contradictory "per HL7 v2.5.1 specification"

## v2.8.1 — 2026-04-06

### Fixes

- **RPT data loss** — all 10 v2.5.1 components now parsed and encoded (was 6,
  silently dropping components 7-10)
- **TQ depth** — `interval` parsed as RI struct, `order_sequencing` as OSD struct
  (were raw strings despite typed modules existing)
- **Stale moduledocs** — IN2, SCD, SDD corrected

## v2.8.0 — 2026-04-06

### Full Conformance Expansion

- **189 HL7 tables** (was 108) — coded-value tables across all v2.5.1 domains
- **255 field bindings** (was 80) — 100% of ID-typed fields bound to tables
- **23/23 conditional rules** — all segments with `:c` fields have enforcement
- **18 conformance fixtures** — end-to-end round-trip + validation per family
- **222 message structures** (186/186 official v2.5.1 + aliases)

## v2.7.1 — 2026-03-27

### Fixes

- **parse/2 table validation** — `validate_tables: true` option now forwarded to
  validator (was silently ignored)
- **add_segment/2 guards** — rejects MSH (ArgumentError) and non-segment structs
- **ACK 5-char delimiter support** — ACK encoder handles truncation-character MSH-2
- **parse/2 typespec** — includes `{:ok, msg, warnings}` return shape

## v2.7.0 — 2026-03-27

### Full v2.5.1 Structure Coverage

- **9 final missing structures**: EAN_U09, PPV_PCA, PRR_PC5, PTR_PCF, QBP_Z73,
  QRY, RCL_I06, RGR_RGR, RTB_Z74
- **186/186 official v2.5.1 structures** covered (222 total with aliases)
- All official segments, types, and structures at 100%

## v2.6.0 — 2026-03-26

### Full v2.5.1 Structure Coverage

- **23 new structures** closing all identified gaps vs the official v2.5.1 index:
  ADT_A18, ADT_A52, MFR_M04-M07, MFN_M15, ORF_R04, QRY variants, OSQ/OSR_Q06,
  RSP_Q11/K23/K25/Z82/Z86/Z88/Z90, SQM/SQR_S25
- **213 message structure definitions** total (186 official + aliases/responses)
- README: tightened type count (89 + legacy TN), version scope, raw mode claims

## v2.5.0 — 2026-03-26

### Deep Semantic Validation

- **108 HL7 tables** (was 20) — demographics, clinical, scheduling, administrative,
  financial coded-value tables
- **80 coded field bindings** (was 11) — across MSH, PID, PV1, PV2, NK1, AL1, IAM,
  DG1, DRG, NTE, ORC, OBR, OBX, IN1, FT1, TXA, SCH, AIS, AIG, RXR, EVN, ERR, MSA
- **Conditional field rules** for 17 segments — OBX, MSH, NK1, ORC, OBR, SCH, AIS,
  AIG, AIL, AIP, RGS, ARQ, DG1, PID, PV2, QAK, MFE/MFA. Rules produce warnings
  in lenient mode, errors in strict mode.

## v2.4.0 — 2026-03-26

### CCP Type + 190 Message Structures

- **CCP type** (Channel Calibration Parameters) — last missing v2.5.1 type. 90/90.
- **86 new message structures** (104 → 190) covering all major v2.5.1 families
- README and docs updated to current coverage

## v2.3.0 — 2026-03-25

### 104 Message Structures

- 81 new message structures across all HL7 v2.5.1 families: ADT, BAR, DFT,
  pharmacy, lab, query, master files, scheduling, referrals, pathways, equipment,
  blood bank, clinical study, personnel, network management
- 226 canonical trigger-event mappings

## v2.2.0 — 2026-03-25

### Zero Raw Holes

- 218 raw field holes filled across 36 segments
- Only 3 intentional raw holes remaining (OBX-5 dispatch, RDT-1 variable, QPD-3 query)

## v2.1.3 — 2026-03-26

### Fixes

- **SI/TM/DT invalid value preservation** — completes the lossless round-trip
  work started in v2.1.2. Invalid SI values preserved as raw strings, invalid
  TM/DT values preserved in `original` field. No primitive type silently drops
  malformed values anymore.

## v2.1.2 — 2026-03-26

### Fixes

- **DT/DTM invalid value preservation** — invalid dates (e.g., `20240230`, `20250229`)
  and malformed DTM values are now preserved in an `original` field instead of silently
  dropping to nil. Prevents clinical data loss on dirty feeds during typed round-trip.

## v2.1.1 — 2026-03-26

### Fixes

- **Strict repetition validation** — non-repeatable fields with illegal repetitions
  (e.g., `M~F` on PID-8) are now caught in strict mode as errors and in lenient
  mode as warnings. Previously silently accepted.

## v2.1.0 — 2026-03-26

### Full v2.5.1 Segment Catalog

- **16 new segments**: ABS, AFF, BTX, EQL, ERQ, NCK, NDS, NSC, NST, ODS, ODT,
  PRC, QRI, RMI, SPR, VTQ — completing the official v2.5.1 segment index
- **152/152 v2.5.1 segments** in catalog, all typed (115 fully, 37 partial)
- **89/89 v2.5.1 data types** implemented
- SCD/SDD marked as v2.6 extensions
- Fixed unused alias warning in DLT type

## v2.0.0 — 2026-03-25

### Full Standard Coverage

- **84 new segments** — all remaining v2.5.1 standard segments
- **35 new data types** — all remaining v2.5.1 data types
- **66 raw holes filled** across 13 segments
- Segment coverage: 136/136 → 152/152 (after v2.1.0 corrections)
- Type coverage: 89/89 (100%)

## v1.4.6 — 2026-03-25

### Fixes

- **Nested composite validation** — `semantic_blank?` now recurses into nested
  structs. `[%XPN{family_name: %FN{}}]` is correctly detected as blank for
  required-field checks.
- **Strict mode unsupported structures** — `validate(msg, mode: :strict)` now
  returns errors (not warnings) for unsupported message structures.

## v1.4.5 — 2026-03-24

### Fixes

- **Escape.decode/2 crash** — malformed hex escapes (`\XGG\`, `\X4Z\`) no longer
  raise `FunctionClauseError`; invalid hex bytes gracefully terminate decoding
- **parse(validate: true) warnings** — now returns `{:ok, msg, warnings}` when
  validation produces only warnings (was silently discarding them as `{:ok, msg}`)
- **Empty string required fields** — `""` on required fields now caught by validation
  (was passing as non-blank)
- **MLLP connection stop reason** — telemetry now carries actual reason (`:closed`,
  `:timeout`, `:message_too_large`, `{:error, reason}`) instead of always `:normal`
- **Getting-started guide** — install `~> 1.4`, fixed `CX` field name (`id` not `id_number`)
- **README TLS example** — uses `HL7v2.MLLP.TLS.mutual_tls_options/1`
- **OBX moduledoc** — removed stale claim that ED/SN/RP are raw (they're typed)
- **PRD** — marked as historical

## v1.4.4 — 2026-03-24

### Fixes

- **ADT structure definitions** — 8 structures corrected against v2.5.1 spec:
  A09, A12, A15, A16, A21, A24, A37, A38 had incorrect NTE (removed) and
  missing OBX/DG1 (added). Structural validation now matches the standard.
- **Coverage metrics** — `mix hl7v2.coverage` now shows fully typed vs partially
  typed segment split. `--detail` flag shows per-segment field completeness.
- **Builder moduledoc** — clarified as low-level constructor (does not validate)

## v1.4.3 — 2026-03-24

### Fixes

- **Structural validator strictness** — unknown non-Z segments are no longer silently
  consumed during matching. They now stop the matcher and are flagged as leftover
  warnings (e.g., ACC in an ACK message is now caught).
- **ADT_A02** — added OBX and PDA per v2.5.1 spec (were missing)
- **ADT_A03** — added NK1, VISIT group, AL1, GT1, INSURANCE group, ACC, PDA
  per v2.5.1 spec (was incomplete)
- **Canonical aliases** — added A29, A32, A33 → ADT_A21 (were falling through)
- **Conformance roadmap** — updated to current state

## v1.4.2 — 2026-03-23

### MLLP Hardening

- **`max_message_size` option** — configurable buffer limit for both MLLP
  server connections and client recv loops (default: 10 MB). Connections
  exceeding the limit are closed with telemetry and logging. Protects against
  memory exhaustion from misbehaving or malicious senders.
- **`handler_timeout` option** — configurable timeout for handler execution
  (default: 60 s). Handlers that exceed the deadline are killed via
  `spawn_monitor`/`Process.exit(:kill)`; the connection continues accepting
  new messages. Telemetry event emitted on timeout.

### Property Testing

- Added delimiter-aware generators (`gen_hl7_field/0` family) that produce
  fields with repetitions (`~`), components (`^`), and sub-components (`&`).
  Two new property tests verify round-trip idempotency for structured messages
  and individual structured fields.

### Documentation

- **Escape sequence behavior** documented in `TypedMessage` moduledoc and
  README Scope section: typed field values preserve HL7 escape sequences
  literally; users must call `HL7v2.Escape.decode/2` explicitly.

### Stats

2,383 tests (303 doctests + 32 properties + 2,048 tests), 0 failures

## v1.4.1 — 2026-03-23

### Fixes

- **Raw parser/encoder round-trip data corruption** — fields with mixed-structure
  repetitions (e.g., `a~b^c`) were silently corrupted: the encoder misidentified
  repetitions as components, encoding `a~b^c` as `a^b&c`. The parser now normalizes
  each repetition to a list, making the representation unambiguous. This also fixes
  the same ambiguity in the typed parser (mixed repetitions were collapsed into a
  single garbled composite value).
- **`HL7v2.type/1`** — now returns `{:ok, typed}` instead of raising `MatchError`
  on conversion failure. Aligns with the library's error-tuple convention.
- **README/CHANGELOG accuracy** — stale segment counts, stale ROL example (was shown
  as raw tuple but is typed since v1.2.0), missing changelog entries, UB1/UB2
  disclosure (mostly raw shells).

### Stats

2,376 tests (303 doctests + 30 properties + 2,043 tests), 0 failures

## v1.4.0 — 2026-03-23

### Pharmacy, Documents & Adverse Reactions

- **9 new segments**: RXO (Order, 25 fields), RXE (Encoded Order, 44 fields),
  RXD (Dispense, 33 fields), RXA (Administration, 26 fields), RXR (Route, 6 fields),
  RXG (Give, 27 fields), RXC (Component, 9 fields), TXA (Transcription Document Header,
  23 fields), IAM (Patient Adverse Reaction, 20 fields)
- **3 new message structures**: RDE_O11 (Pharmacy Encoded Order), RDS_O13 (Pharmacy
  Dispense), MDM_T02 (Document Notification and Content)
- **Segment coverage**: 52/136 (38.2%, up from 31.6%)

### Fixes

- **Atom leak in structural validator** — segment IDs from untrusted input were
  converted to atoms via `String.to_atom/1`. Now uses string-based MapSet comparison.
- **Strict mode field cardinality** — field cardinality overflow escalated to `:error`
  in strict mode (was always `:warning` regardless of mode).

### Stats

2,370 tests (303 doctests + 30 properties + 2,037 tests), 0 failures

## v1.3.0 — 2026-03-23

### Standards Expansion

- **6 new segments**: UB1 (UB82), UB2 (UB92 Data), CTD (Contact Data),
  CTI (Clinical Trial Identification), BLG (Billing), DSC (Continuation Pointer)
- **Segment coverage**: 43/136 (31.6%, up from 27.2%)

### Stats

2,126 tests (303 doctests + 30 properties + 1,793 tests), 0 failures

## v1.2.0 — 2026-03-23

### Standards Expansion

- **8 new segments**: ROL (Role), IN2 (Insurance Additional Info, 72 fields),
  IN3 (Insurance Certification, 28 fields), DRG (Diagnosis Related Group),
  SPM (Specimen, 30 fields), TQ1 (Timing/Quantity), TQ2 (Timing Relationship),
  PDA (Patient Death and Autopsy)
- **6 new types**: RI (Repeat Interval), SN (Structured Numeric),
  ED (Encapsulated Data), RP (Reference Pointer), RPT (Repeat Pattern),
  PLN (Practitioner License)
- **OBX dispatch**: Added SN, ED, RP to value_type_map
- **Segment coverage**: 37/136 (27.2%, up from 21.3%)
- **Type coverage**: 54/89 (60.7%, up from 53.9%)
- **833 declared fields** across typed segments
- All 14 previously-raw segments in supported structures now typed
  (ROL, IN2, IN3, DRG, SPM, TQ1, TQ2, PDA + previously done)
- Improved structural validator diagnostics: out-of-order segments no longer
  double-reported

### Stats

2,126 tests (303 doctests + 30 properties + 1,793 tests), 0 failures

## v1.1.0 — 2026-03-23

### Positional Structural Validation

- **Rewritten structural validator** — state-machine-style positional matcher that walks
  the segment stream against the structure AST. Replaces flat deduplicated checks.
  - Handles segments in multiple groups (ROL in PATIENT, VISIT, PROCEDURE, INSURANCE)
  - Validates repeating groups per-occurrence (A39 PATIENT requires PID+MRG each time)
  - Ordering enforced naturally by sequential walk
- **ADT_A01**: Added OBSERVATION group (OBX+NTE) per HL7 v2.5.1
- **ORU_R01**: Added SPECIMEN group (SPM+OBX+NTE) per HL7 v2.5.1
- **Type catalog**: Added 5 missing v2.5.1 types (CD, DLT, DTN, ICD, MOP) — 89 total
- **Type coverage**: 48/89 (53.9%, corrected from inflated 57.1%)
- 10 new structural validation tests

### Stats

1,933 tests (266 doctests + 30 properties + 1,637 tests), 0 failures

## v1.0.0 — 2026-03-23

### M6: Conformance Platform

- **HL7 table validation** — 20 coded-value tables from HL7 v2.5.1 (administrative sex,
  patient class, message type, processing ID, acknowledgment codes, observation status,
  value types, identifier types, and more). Opt-in via `validate(msg, validate_tables: true)`.
- **Table-aware field validation** — 11 coded fields checked against their HL7 tables:
  MSH-9.1, MSH-11.1, MSH-12.1, MSH-15, MSH-16, PID-8, PV1-2, PV1-4, MSA-1, OBX-2, OBX-11
- **Tables API** — `HL7v2.Standard.Tables.valid?(table_id, code)`, `validate/2`, `get/1`
- 26 new table validation tests

### Stats

1,921 tests (266 doctests + 30 properties + 1,625 tests), 0 failures

## v0.9.0 — 2026-03-23

### M5: Broad Clinical Coverage

- **8 new segments**: SFT (Software), PD1 (Patient Additional Demographic),
  PR1 (Procedures), AIG/AIL/AIP (Scheduling Resources), DB1 (Disability),
  ACC (Accident)
- **Segment coverage**: 29/136 standard segments (21.3%, up from 15.4%)
- **647 declared fields** across typed segments
- All segments referenced in ADT/ORU/SIU message structure definitions are now
  typed (except ROL, DRG, IN2, IN3 which are lower priority)
- 98 new tests across 8 test files

### Stats

1,893 tests (266 doctests + 30 properties + 1,597 tests), 0 failures

## v0.8.0 — 2026-03-23

### M4: Datatype Expansion

- **TQ type** — Timing/Quantity (12 components) — closes raw holes in OBR-27, ORC-7, SCH-11
- **ELD type** — Error Location and Description (4 components) — closes raw hole in ERR-1
- **SPS type** — Specimen Source (7 components) — closes raw hole in OBR-15
- **TM type** — Time primitive (HH[MM[SS[.SSSS]]][+/-ZZZZ]) — added to OBX-5 dispatch
- **Raw holes**: 6 → 1 (only OBX-5 remains, by design — uses dispatch)
- **Type coverage**: 48/84 standard types (57.1%, up from 52.4%)
- 56 new tests + 25 new doctests

### Stats

1,795 tests (266 doctests + 30 properties + 1,499 tests), 0 failures

## v0.7.0 — 2026-03-22

### M3: Structural Validation

- **Structural validator** — `HL7v2.Validation.Structural` checks segment ordering,
  group anchors, and cardinality against group-aware message structure definitions.
  Replaces presence-only validation for all 20 supported message structures.
- **Strict/lenient modes** — `HL7v2.validate(msg, mode: :strict)` treats ordering and
  cardinality violations as errors. Default `:lenient` mode reports them as warnings.
- **Order checking** — Detects when segments appear in wrong order relative to the
  abstract message definition (e.g., OBX before OBR in ORU_R01)
- **Cardinality checking** — Flags non-repeating segments that appear multiple times
- **28 structural tests** — Positive and negative cases for ADT_A01, ORU_R01, ORM_O01,
  SIU_S12, ACK, ADT_A39 including missing anchors, wrong order, duplicates, Z-segments

### Stats

1,700 tests (241 doctests + 30 properties + 1,429 tests), 0 failures

## v0.6.0 — 2026-03-22

### M2: Standard Model

- **HL7v2.Standard** — Single source of truth for HL7 v2.5.1 metadata: segment catalog
  (~136 entries), type catalog (~84 entries), capability tiers (`:typed` / `:unsupported`)
- **MessageStructure** — Group-aware abstract message definitions for 20 structures
  (ADT A01-A39, ORM_O01, ORU_R01, SIU_S12, ACK). Includes groups, anchors, cardinality
  and optionality per the HL7 v2.5.1 abstract message definitions.
- **Coverage ledger** — `HL7v2.Standard.Coverage` computes typed segments, raw holes,
  unsupported types, and coverage percentages
- **`mix hl7v2.coverage`** — Prints human-readable coverage report to stdout
- **Conformance tests** — `test/hl7v2/conformance/` with structure metadata validation
  (27 tests) and fixture round-trips for ADT_A01, ORU_R01, ORM_O01, SIU_S12, ACK
- **MessageDefinition** now delegates to MessageStructure for presence validation,
  extracting required segments from group-aware definitions

### Stats

1,672 tests (241 doctests + 30 properties + 1,401 tests), 0 failures

## v0.5.6 — 2026-03-22

### Fixes

- **DTM encode precision** — DateTime/NaiveDateTime encode now caps fractional seconds
  at 4 digits per HL7 v2.5.1 spec (was emitting up to 6, which the parser couldn't
  re-parse)
- **fetch/2 raw tuple bounds** — `fetch(msg, "PR1-99")` on raw tuple segments now
  returns `{:error, :field_not_found}` instead of `{:ok, nil}` for out-of-range fields
- **Type count** — README: "43 v2.5.1 types + legacy TN" (TN is deprecated, not in the
  v2.5.1 data-structure catalog)
- **Implementation plan** — Marked as historical reference, no longer claims "COMPLETE"

## v0.5.5 — 2026-03-22

### Fixes

- **fetch/2 component bounds** — `fetch(msg, "PID-5.99")` now returns
  `{:error, :component_not_found}` instead of `{:ok, nil}` for out-of-range
  component indices on typed fields
- **MRG/RGS tests** — Added parse/encode/round-trip tests for both segments
  (were at 0% coverage). Added SIU^S12 integration test with RGS.
- **Parser docs** — Changed "preserves the original wire format exactly" to
  "canonical round-trip fidelity" (line endings are normalized to CR)

## v0.5.4 — 2026-03-22

### Fixes

- **Validation return shape** — `validate/1` now returns `{:ok, warnings}` when only
  warnings are present, instead of treating warnings as errors. Warnings-only results
  no longer block `parse(..., validate: true)`.
- **Install snippet** — README updated from `~> 0.1` to `~> 0.5`
- **Segment count** — README now says "21 standard segments + generic ZXX" (was counting
  ZXX as a standard segment)
- **Raw tuple access** — README now documents that component/repetition selectors are not
  applied to raw tuples (only typed segments get full descent)
- **Segment reference** — docs/reference/segments.md now says "13 of 21" segments
  documented (was claiming all 22)

## v0.5.3 — 2026-03-22

### Additions

- **MRG segment** — Merge Patient Information (7 fields), registered in typed parser.
  ADT^A39-A42 merge workflows now fully typed end-to-end.
- **OBX dispatch** — Extended value_type_map with CQ, MO, DR, XON, CP, FC, TN. All
  implemented types now available for OBX-5 dispatch.

### Fixes

- **Builder separator** — `Message.to_raw/1` now derives separators from MSH instead
  of hardcoding defaults. Custom-delimiter builder messages encode correctly.
- **NM whitespace** — `original` field now preserves raw wire value including any
  whitespace for lossless round-trip. `value` field still uses trimmed+normalized form.
- **README accuracy** — 22 segments (was 21), ~95% coverage (was 95%+), explicit note
  about raw holes (TQ, SPS, ELD fields)

## v0.5.2 — 2026-03-22

### Fixes

- **Subcomponent separator** — Non-default sub-component separators (e.g., `$` in
  MSH-2 `^~\$`) now preserved through typed round-trip. Previously hardcoded as `&`
  in 15 composite type modules. Uses process-dictionary-scoped separator context
  threaded from the Separator struct through segment parse/encode.
- **RGS typed parsing** — RGS segment now registered in typed parser (was defined
  but not dispatched, so SIU messages returned raw tuples instead of structs)
- **ADT_A12** — ADT^A12 (Cancel Transfer) now correctly mapped to ADT_A12, not ADT_A09
- **Presence validation** — Renamed "structure validation" to "presence validation"
  throughout docs to clarify scope (no ordering/group/cardinality)
- **Docs accuracy** — Fixed DICOM PS3.x citation in message-structures.md (was wrong
  standard), updated README coverage numbers

## v0.5.1 — 2026-03-22

### Fixes

- **ORM_O01 / ORU_R01** — PID is now optional (patient group is optional per spec)
- **SIU_S12** — RGS required as resource group anchor; PID now optional; AIS optional
  within the resource group
- **Primitive extra components** — Non-conformant input like `M^EXTRA` on primitive
  fields now preserved through typed round-trip instead of being silently truncated
- **Canonical structure mappings** — Added ADT^A12 and SIU S18-S24 to match the
  documented reference

## v0.5.0 — 2026-03-22

### Conformance Hardening

- **Extra fields preservation** — Typed segments now capture fields beyond the declared
  count in `extra_fields`, preventing silent data loss on messages with trailing standard
  fields (e.g. OBX-20 through OBX-25)
- **MSH-2 validation** — Reject malformed encoding characters: overlong (6+), field
  separator collision, duplicate delimiters
- **CNN type** — Composite Number and Name without Authority (11 components, flat HD)
- **NDL type** — Name with Date and Location (11 components with CNN sub-components)
- **OBR fields 32-35** corrected from XCN to NDL per HL7 v2.5.1
- **NM lexical preservation** — `original` field preserves raw wire format (`+01.20`
  round-trips as `+01.20`, not `1.2`)
- **DTM offset preservation** — Malformed timezone offsets preserved instead of silently
  dropped
- **Message definition completeness** — Canonical structure mapping moved to single source
  of truth in `MessageDefinition`

### Stats

44 type modules (36 composite + 8 primitive), 20 segments + ZXX, 1,620 tests, 0 failures

## v0.4.0 — 2026-03-22

### Ergonomics & Polish

- **`~h` sigil** — Compile-time validated HL7v2 path access (`~h"PID-5.1"`)
- **`fetch/2`** — Error-returning path access (`{:ok, value}` or `{:error, reason}`)
- **String.Chars protocol** — `to_string/1` on RawMessage, TypedMessage, and Message
- **Truncation character** — v2.7+ 5th encoding character support
- **Wildcard paths** — `OBX[*]-5` returns all OBX observation values, `PID-3[*]` returns
  all repetitions
- **Copy mode** — `parse(text, copy: true)` prevents GC pressure on long-lived messages
- **Unknown segment handling** — ZXX pass-through for vendor Z-segments and unrecognized
  standard segments
- **Benchmarks** — Parse/encode throughput benchmarks

### Fixes

- 4 rounds of analyst review fixes: scope claims, data correctness bugs, doc
  accuracy, fetch/2 error semantics

### Stats

42 type modules, 20 segments + ZXX, 1,470 tests, 0 failures

## v0.3.0 — 2026-03-22

### Type Coverage Push

- **16 new composite types** — XCN, CP, MO, FC, JCC, CQ, EIP, DLD, DLN, ERL, MOC, PRL,
  AUI plus others; 97% of segment fields now typed (up from ~60%)
- **Path-based access API** — `HL7v2.Access.get(msg, "PID-5.1")` for field/component/
  repetition extraction
- **Message structure definitions** — 9 message types (ADT_A01-A04/A08, ORM_O01, ORU_R01,
  SIU_S12, ACK) with required/optional segment rules
- **Property-based tests** — 25 StreamData properties for parser/encoder round-trip
- **Coverage** — 81% to 96%+ with 244 additional tests
- **ExDoc** — Module groups, getting-started guide, hex.pm package metadata

### Stats

42 type modules (34 composite + 8 primitive), 20 segments + ZXX, 1,132 tests, 0 failures

## v0.2.0 — 2026-03-22

### Feature-Complete MVP

- **20 typed segment structs** — MSH, EVN, PID, PV1, PV2, NK1, OBR, OBX, ORC, MSA, ERR,
  NTE, AL1, DG1, IN1, SCH, AIS, GT1, FT1 via DRY behaviour macro; plus ZXX generic
  Z-segment
- **Typed parser** — Raw message to typed segment struct conversion with OBX-5 VARIES
  dispatch
- **Message builder** — `HL7v2.Message.new/3` with auto-populated MSH (timestamp, control
  ID, version, processing ID)
- **ACK/NAK builder** — `HL7v2.ack/2` with sender/receiver swap
- **Validation engine** — Opt-in required-field and segment-presence checks
- **MLLP transport** — Ranch 2.x TCP listener, GenServer client, TLS/mTLS support
- **Telemetry** — Instrumented parse, encode, and MLLP operations
- **26 base type modules** — 12 primitives (ST, NM, SI, ID, IS, TX, FT, TN, DT, DTM, TS,
  NR) + 14 composites (CX, XPN, XAD, XTN, CE, CWE, HD, PL, EI, MSG, PT, VID, CNE, XON,
  FN, SAD, DR)

### Stats

26 type modules, 20 segments + ZXX, 319 tests, 0 failures

## v0.1.0 — 2026-03-22

### Initial Release — Core Parser

- **Separator parsing** — Field, component, repetition, escape, sub-component delimiters
  from MSH
- **Escape/unescape** — Full HL7v2 escape sequence handling (`\F\`, `\S\`, `\R\`, `\E\`,
  `\T\`, hex `\Xhh\`, `\Cxxyy\`, `\Mxxyyzz\`)
- **Raw parser** — Lossless message parsing with CR/LF/CRLF line-ending normalization
- **Encoder** — Wire-format serialization with iodata performance and trailing-empty
  trimming

### Stats

Core foundation, 45 tests, 0 failures
