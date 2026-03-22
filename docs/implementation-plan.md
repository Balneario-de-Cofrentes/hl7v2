# HL7v2 Implementation Plan

## Status: COMPLETE (2026-03-22)

All 9 phases implemented. 1,382 tests (1,124 unit + 228 doctests + 30 properties), 0 failures.

## Phase Overview

| Phase | Name | Depends On | Parallel? |
|-------|------|------------|-----------|
| P1 | Core: Separator + Raw Parser + Encoder | Nothing | Start immediately |
| P2 | Type System: Primitive + Composite types | Nothing | Parallel with P1 |
| P3 | Segment Definitions: Typed segment structs | P2 (types) | After P2 |
| P4 | Typed Parser: Raw → Typed conversion | P1 + P3 | After P1 + P3 |
| P5 | Message Builder: Programmatic construction | P3 (segments) | Parallel with P4 |
| P6 | Validation Engine | P3 + P4 | After P3 + P4 |
| P7 | ACK Builder | P1 + P3 (MSH, MSA, ERR) | After P3 |
| P8 | MLLP Transport: Framing + Listener + Client | P1 (raw parser) | After P1 |
| P9 | Integration: Top-level API + Telemetry | P1-P8 | After all |

## Execution Plan

**Wave 1** (parallel): P1 + P2
**Wave 2** (after P1+P2): P3
**Wave 3** (parallel, after P3): P4 + P5 + P7
**Wave 4** (parallel, after P4): P6 + P8
**Wave 5** (after all): P9

---

## P1: Core — Separator + Raw Parser + Encoder

### Files
- `lib/hl7v2/separator.ex` — Delimiter detection from MSH-1/MSH-2
- `lib/hl7v2/parser.ex` — Raw parser (splits into segments/fields/components/sub-components)
- `lib/hl7v2/raw_message.ex` — Raw message struct (type, segments as lists of lists)
- `lib/hl7v2/encoder.ex` — Serialize raw message back to wire format
- `lib/hl7v2/escape.ex` — Escape sequence encoding/decoding

### Key behaviors
- Parse any HL7v2 message into a raw representation (nested lists)
- Lossless round-trip: parse → encode produces identical output
- Handle MSH-1/MSH-2 special parsing
- Handle custom delimiters (not just defaults)
- Escape sequence processing for ST/TX/FT fields
- Handle CR, LF, CRLF line endings
- Trailing field/component trimming on encode

### Tests
- Parse well-formed messages
- Round-trip property tests (parse ∘ encode = identity)
- Custom delimiter handling
- Escape sequence round-trip
- MSH-1/MSH-2 edge cases
- Empty fields, null fields (|""|), trailing omission

---

## P2: Type System — Primitive + Composite Types

### Files
- `lib/hl7v2/type.ex` — Base type behaviour
- `lib/hl7v2/type/st.ex` through `lib/hl7v2/type/vid.ex` — 26 type modules

### Primitive types (12)
ST, NM, DT, DTM, TS, ID, IS, SI, TX, FT, NR, TN

Each primitive type module:
- `parse/1` — string → typed value
- `encode/1` — typed value → string
- Type-specific validation

### Composite types (14)
CX, XPN, XAD, XTN, CE, CWE, HD, PL, EI, MSG, PT, VID, CNE, XON

Each composite type module:
- Elixir struct with named fields
- `parse/2` — list of components → struct
- `encode/1` — struct → list of components
- Component count and sub-type declarations

### Tests
- Parse/encode round-trip for each type
- Edge cases (empty, partial, extra components)
- Date/DateTime parsing/formatting
- Numeric parsing

---

## P3: Segment Definitions — Typed Segment Structs

### Files
- `lib/hl7v2/segment.ex` — Base segment behaviour
- `lib/hl7v2/segment/msh.ex` through `lib/hl7v2/segment/zxx.ex` — 19 segment modules

### Segments (19)
MSH, EVN, PID, PV1, PV2, NK1, OBR, OBX, ORC, MSA, ERR, NTE, AL1, DG1, IN1, SCH, AIS, GT1, FT1, ZXX

Each segment module:
- Elixir struct with named fields matching HL7 field names
- `@fields` attribute: list of {seq, name, type, optionality, max_reps}
- `parse/2` — list of field strings → struct (using type parsers from P2)
- `encode/1` — struct → list of field strings
- Field count matches HL7 v2.5.1 spec exactly

### ZXX (Generic Z-segment)
- Dynamic struct that preserves all fields as raw strings
- Handles any Z-segment (ZPD, ZPI, etc.)

### Tests
- Parse/encode round-trip per segment
- Required field validation
- Field count accuracy vs spec
- Z-segment pass-through

---

## P4: Typed Parser — Raw → Typed Conversion

### Files
- `lib/hl7v2/typed_message.ex` — Typed message struct
- `lib/hl7v2/typed_parser.ex` — Converts raw message to typed segments

### Key behaviors
- Takes raw parsed message (from P1) and converts to typed
- Each segment gets parsed into its struct (from P3)
- Unknown segments preserved as raw
- Z-segments parsed as ZXX
- Message type detected from MSH-9
- Segment ordering preserved

### Tests
- Full message parse (raw → typed)
- Mixed known/unknown segments
- Z-segment handling
- Error cases (malformed segments)

---

## P5: Message Builder — Programmatic Construction

### Files
- `lib/hl7v2/message.ex` — Message struct + builder API

### API
- `Message.new(type, trigger, opts)` — create message with MSH
- `Message.add_segment(msg, segment)` — append segment
- `Message.segments(msg, type)` — query segments by type
- `Message.segment(msg, type)` — first segment of type
- Auto-generates MSH-7 (datetime), MSH-10 (control ID)

### Tests
- Build ADT^A01, ORM^O01, ORU^R01 messages
- Segment ordering
- MSH auto-population
- Encode built messages

---

## P6: Validation Engine

### Files
- `lib/hl7v2/validation.ex` — Validation orchestrator
- `lib/hl7v2/validation/message_rules.ex` — Message structure validation
- `lib/hl7v2/validation/field_rules.ex` — Field-level validation

### Key behaviors
- Validate required segments per message type
- Validate required fields per segment
- Validate data type conformance
- Validate field repetition limits
- Return list of errors with location + description
- Opt-in (never blocks parsing)

### Tests
- Valid messages pass
- Missing required segments detected
- Missing required fields detected
- Type violations detected
- Multiple errors accumulated

---

## P7: ACK Builder

### Files
- `lib/hl7v2/ack.ex` — ACK/NAK message construction

### API
- `ACK.accept(original_msg)` — AA response
- `ACK.error(original_msg, text)` — AE response
- `ACK.reject(original_msg, text)` — AR response
- Copies MSH fields from original, swaps sender/receiver
- Generates MSA with matching control ID
- Optional ERR segment

### Tests
- ACK for each code (AA, AE, AR)
- MSH field swapping
- Control ID matching
- ERR segment inclusion

---

## P8: MLLP Transport

### Files
- `lib/hl7v2/mllp.ex` — MLLP framing (encode/decode)
- `lib/hl7v2/mllp/listener.ex` — Ranch 2.x TCP server
- `lib/hl7v2/mllp/client.ex` — TCP client with GenServer
- `lib/hl7v2/mllp/handler.ex` — Handler behaviour
- `lib/hl7v2/mllp/tls.ex` — TLS configuration helpers

### Key behaviors
- MLLP frame encoding/decoding (SB/EB/CR)
- Listener with configurable handler behaviour
- Client with send/receive, connection management
- TLS + mTLS support
- Concurrent connections via Ranch
- Telemetry events

### Tests
- Frame encode/decode round-trip
- Listener accepts connections
- Client send/receive
- Multiple messages per connection
- TLS handshake
- Concurrent connections
- Timeout handling

---

## P9: Integration — Top-level API + Telemetry

### Files
- `lib/hl7v2.ex` — Update top-level module with real implementations
- `lib/hl7v2/telemetry.ex` — Telemetry event helpers

### Key behaviors
- `HL7v2.parse/2` dispatches to raw or typed parser
- `HL7v2.encode/1` handles both raw and typed messages
- `HL7v2.validate/1` runs validation engine
- Telemetry events for parse, encode, validate, send, receive

### Tests
- Top-level API integration tests
- Full round-trip: build → encode → parse → validate
- Telemetry event emission
