# Competitive Analysis — Elixir HL7v2 Ecosystem

## Landscape (March 2026)

| Package | Version | Downloads | Maintainer | Status |
|---------|---------|-----------|------------|--------|
| elixir_hl7 | 0.12.1 | 172k | HCA Healthcare | Active (Sep 2025) |
| mllp | 0.9.9 | 71k | HCA Healthcare | Active (Nov 2025) |
| ex_hl7 | 1.0.0 | 4k | jcomellas | Abandoned (Dec 2019) |
| hl7 | 1.0.2 | 390 | 5ht/erpuno | Name squatter (FHIR, not v2) |
| ex_l7 | 0.3.0 | 2k | making3 | Abandoned (Mar 2018) |

## Detailed Analysis

### elixir_hl7 (HCA Healthcare)

**What it is:** A delimiter-based HL7v2 parser that treats messages as text with pipes.

**Architecture:** Parses HL7v2 into sparse maps with integer keys. Fields accessed via `~p` sigil (compile-time validated path strings). No schema awareness — it doesn't know what PID-5 means, just that it's the 5th field in a PID segment.

**Strengths:**
- Mature (29 versions, 172k downloads)
- Pragmatic — handles real-world messy HL7 without complaining
- Lossless round-trip (parse → format produces identical output)
- `~p` sigil is ergonomic for ad-hoc querying
- Zero dependencies
- Apache-2.0 license
- HCA backing (largest US hospital operator)

**Weaknesses:**
- No typed segments — `PID` is just a map, not a struct with named fields
- No builder API — you can modify parsed messages but can't construct from scratch
- No validation — intentional design choice, but limits use in systems that need conformance
- No data type awareness — dates are strings, names are strings, IDs are strings
- Pattern matching is awkward (`msg |> HL7.get(~p"PID-5.1")` vs `pid.patient_name`)

**API example:**
```elixir
# Parse
{:ok, msg} = HL7.new(text)

# Query (returns strings)
patient_name = HL7.get(msg, ~p"PID-5")    # => "Smith^John"
mrn = HL7.get(msg, ~p"PID-3[1].1")        # => "12345"

# Modify (returns modified message)
msg = HL7.put(msg, ~p"PID-5.1", "Jones")
```

### mllp (HCA Healthcare)

**What it is:** MLLP transport as a separate package.

**Architecture:** Ranch 1.8-based TCP server/client with dispatcher behaviour. Depends on `elixir_hl7` for message parsing.

**Strengths:**
- TLS support including client certificate verification
- Dispatcher behaviour pattern (clean separation)
- Telemetry instrumented
- Connection lifecycle management with backoff

**Weaknesses:**
- Ranch 1.8 dependency (we use Ranch 2.x across dicom/dimse)
- Pre-1.0 — API declared unstable
- Separate package from parser (two deps, two version constraints, API boundary friction)
- Cannot be used independently of `elixir_hl7`

### ex_hl7 (jcomellas) — Abandoned

**What it was:** The closest to our approach — macro-based DSL for defining typed segments as Elixir structs.

**Why it died:**
- Only covered a "small subset" of segments
- Undefined fields are LOST during re-serialization (not lossless)
- One maintainer, no corporate backing
- Last release December 2019

**What it got right:**
- Segments as structs with typed fields
- Macro DSL for segment definition
- Component/sub-component awareness

**What it got wrong:**
- Lossy (fatal for production use)
- No builder API beyond struct creation
- No validation
- No MLLP transport
- Incomplete coverage made it unreliable

## Our Differentiation

### What makes hl7v2 fundamentally different

1. **Schema-driven, not delimiter-driven**
   - Segments are Elixir structs with named fields (`pid.patient_name` not `get(msg, ~p"PID-5")`)
   - Data types are structs (`%CX{id: "12345", assigning_authority: %HD{...}}`)
   - The compiler helps you — typos in field names are caught at compile time

2. **Dual representation solves the lossless problem**
   - Raw mode: lossless pass-through for routing, forwarding, logging (like elixir_hl7)
   - Typed mode: validated structs for domain logic (like ex_hl7 tried)
   - Convert between them — best of both worlds

3. **Builder-first**
   - Nobody in the Elixir ecosystem has a builder API for HL7v2
   - `Message.new("ADT", "A01") |> Message.add_segment(%PID{...})`
   - Enables: test fixture generation, message transformation, protocol bridges

4. **Integrated transport**
   - One package: parse + build + validate + MLLP in one namespace
   - Ranch 2.x (compatible with dimse stack)
   - No version constraint conflicts between parser and transport

5. **Standards-aware validation (opt-in)**
   - elixir_hl7 intentionally has none
   - We provide it as opt-in — the library knows the rules but doesn't enforce them unless asked
   - Structure validation (required segments per message type)
   - Field validation (data types, optionality, repetition)

## Not competing on

- Download count — elixir_hl7 has 172k downloads and HCA backing. We compete on architecture, not volume.
- Messy message tolerance — raw mode handles this the same way elixir_hl7 does.
- `~p` sigil — nice feature but unnecessary when you have typed structs.
