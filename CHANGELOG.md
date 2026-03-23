# Changelog

All notable changes to this project will be documented in this file.

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
  as raw tuple but is typed since v1.2.0), missing changelog entries, honest UB1/UB2
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
  throughout docs to honestly describe what it does (no ordering/group/cardinality)
- **Docs accuracy** — Fixed DICOM PS3.x citation in message-structures.md (was wrong
  standard), updated README coverage numbers to honest counts

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

- 4 rounds of analyst review fixes: honest scope claims, data correctness bugs, doc
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
