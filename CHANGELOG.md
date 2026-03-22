# Changelog

All notable changes to this project will be documented in this file.

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
