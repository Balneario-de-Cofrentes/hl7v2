# HL7v2 — Product Requirements Document

## Vision

A pure Elixir HL7 v2.x library that treats HL7v2 as a typed clinical messaging protocol, not just delimited text. Schema-driven parsing, typed segment structs, programmatic message building, and integrated MLLP transport — the same architectural approach that `dicom` and `dimse` brought to DICOM.

## Problem Statement

The Elixir HL7v2 ecosystem has two viable libraries:

- **elixir_hl7** (HCA Healthcare, 172k downloads) — Pragmatic delimiter-based parser. Sparse maps with integer keys, `~p` sigil for path queries. Intentionally no validation, no typed segments, no builder API. Treats HL7 as "text with pipes."
- **mllp** (HCA Healthcare, 71k downloads) — MLLP transport as separate package. Depends on elixir_hl7 and Ranch 1.8 (our stack uses Ranch 2.x).

Neither provides:
- Typed segment structs (PID, OBR, OBX as Elixir structs with named fields)
- A builder API for constructing messages programmatically
- Structural validation (required segments, field cardinality)
- Field-level validation (data type conformance, length)
- Integrated transport (parsing + MLLP in one coherent package)
- Ranch 2.x compatibility

## Strategic Fit

| Library | Protocol | Role |
|---------|----------|------|
| `dicom` | DICOM P10/JSON | Parse, write, de-identify DICOM data |
| `dimse` | DIMSE networking | DICOM network services (C-STORE, C-FIND, etc.) |
| **`hl7v2`** | **HL7 v2.x + MLLP** | **Parse, build, validate HL7v2 messages + transport** |

Phaos wraps all three. The libraries are standalone, reusable by anyone.

## Design Principles

1. **Schema-driven, not delimiter-driven** — Segments are Elixir structs with named fields, not sparse maps with integer keys
2. **Dual representation** — Raw mode (lossless pass-through) and typed mode (validated structs). Parse into what you need.
3. **Builder-first** — Constructing messages is as important as parsing them. First-class API for building HL7v2 messages programmatically.
4. **Integrated transport** — MLLP is part of the library, not a separate package. One dep, one namespace, one API.
5. **Zero deps for core** — Parsing, building, and validation have zero runtime dependencies. MLLP transport depends on Ranch 2.x and Telemetry.
6. **Standards-aware, not standards-enforcing** — The library knows the standard but doesn't force conformance. Validation is opt-in. Real-world HL7 is messy.
7. **Pure Elixir** — No NIFs, no ports, no external processes.

## Architecture

```
hl7v2/
  lib/
    hl7v2.ex                    # Top-level API
    hl7v2/
      # -- Core (zero deps) --
      message.ex                # Message struct + builder API
      segment.ex                # Base segment behaviour + generic segment
      separator.ex              # Delimiter detection and handling
      parser.ex                 # Raw parser (delimiter-based, lossless)
      encoder.ex                # Serialize back to HL7v2 wire format
      ack.ex                    # ACK/NAK message builder

      # -- Type System --
      type.ex                   # Base type behaviour
      type/
        st.ex                   # String
        nm.ex                   # Numeric
        dt.ex                   # Date (YYYYMMDD)
        dtm.ex                  # DateTime (YYYYMMDD[HHmm[ss[.ffff]]][+/-ZZZZ])
        ts.ex                   # Timestamp (v2.4 and earlier)
        id.ex                   # Coded value
        is.ex                   # Coded value (user-defined)
        si.ex                   # Sequence ID
        tx.ex                   # Text
        ft.ex                   # Formatted text
        cx.ex                   # Extended composite ID (MRN, etc.)
        xpn.ex                  # Extended person name
        xad.ex                  # Extended address
        xtn.ex                  # Extended telecom number
        ce.ex                   # Coded element (v2.4-)
        cwe.ex                  # Coded with exceptions (v2.5+)
        hd.ex                   # Hierarchic designator
        pl.ex                   # Person location
        ei.ex                   # Entity identifier
        msg.ex                  # Message type (MSG data type)
        pt.ex                   # Processing type
        vid.ex                  # Version identifier

      # -- Segment Definitions (code-generated from standard) --
      segment/
        msh.ex                  # Message Header
        evn.ex                  # Event Type
        pid.ex                  # Patient Identification
        pv1.ex                  # Patient Visit
        pv2.ex                  # Patient Visit - Additional
        nk1.ex                  # Next of Kin
        obr.ex                  # Observation Request
        obx.ex                  # Observation/Result
        orc.ex                  # Common Order
        msa.ex                  # Message Acknowledgment
        err.ex                  # Error
        al1.ex                  # Allergy
        dg1.ex                  # Diagnosis
        in1.ex                  # Insurance
        nte.ex                  # Notes and Comments
        sch.ex                  # Scheduling Activity
        ais.ex                  # Appointment Information
        gt1.ex                  # Guarantor
        ft1.ex                  # Financial Transaction
        zxx.ex                  # Generic Z-segment handler

      # -- Validation --
      validation.ex             # Validation engine
      validation/
        message_rules.ex        # Message structure rules (required segments)
        field_rules.ex          # Field-level rules (data types, lengths)

      # -- MLLP Transport (depends on Ranch + Telemetry) --
      mllp.ex                   # MLLP framing (encode/decode)
      mllp/
        listener.ex             # MLLP TCP server (Ranch 2.x)
        client.ex               # MLLP TCP client
        handler.ex              # Handler behaviour for received messages
        tls.ex                  # TLS configuration helpers

      # -- Telemetry --
      telemetry.ex              # Telemetry event helpers
```

## API Design

### Parsing

```elixir
# Raw mode — lossless, sparse maps (like elixir_hl7 but cleaner)
{:ok, raw} = HL7v2.parse(text)
raw.type        # => {"ADT", "A01"}
raw.segments    # => [%{0 => "MSH", ...}, %{0 => "PID", ...}]

# Typed mode — validated structs
{:ok, msg} = HL7v2.parse(text, mode: :typed)
msg.header.message_type           # => %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"}
msg.header.sending_application    # => %HL7v2.Type.HD{namespace_id: "HIS"}

pid = HL7v2.Message.segment(msg, HL7v2.Segment.PID)
pid.patient_name     # => [%HL7v2.Type.XPN{family_name: "Smith", given_name: "John"}]
pid.patient_id_list  # => [%HL7v2.Type.CX{id: "12345", assigning_authority: %HD{...}}]
pid.date_of_birth    # => ~D[1980-03-15]
pid.sex              # => "M"
```

### Building

```elixir
msg =
  HL7v2.Message.new("ADT", "A01",
    sending_application: "PHAOS",
    receiving_application: "HIS"
  )
  |> HL7v2.Message.add_segment(
    %HL7v2.Segment.PID{
      set_id: 1,
      patient_id_list: [
        %HL7v2.Type.CX{id: "12345", assigning_authority: %HL7v2.Type.HD{namespace_id: "MRN"}}
      ],
      patient_name: [
        %HL7v2.Type.XPN{family_name: "Smith", given_name: "John"}
      ],
      date_of_birth: ~D[1980-03-15],
      sex: "M"
    }
  )
  |> HL7v2.Message.add_segment(
    %HL7v2.Segment.PV1{
      set_id: 1,
      patient_class: "I",
      assigned_patient_location: %HL7v2.Type.PL{
        point_of_care: "ICU",
        facility: %HL7v2.Type.HD{namespace_id: "HOSP"}
      }
    }
  )

# Serialize
text = HL7v2.encode(msg)
# => "MSH|^~\\&|PHAOS||HIS||...|ADT^A01|...|2.5\rPID|1||12345^^^MRN||Smith^John||19800315|M\rPV1|1|I|ICU^^^HOSP\r"
```

### Validation

```elixir
# Validate a parsed or built message
case HL7v2.validate(msg) do
  :ok -> :proceed
  {:error, errors} ->
    # [%{segment: "PID", field: 3, error: :required_field_missing}, ...]
end

# Validate on parse
{:ok, msg} = HL7v2.parse(text, mode: :typed, validate: true)
```

### MLLP Transport

```elixir
# Server
{:ok, _pid} = HL7v2.MLLP.Listener.start_link(
  port: 2575,
  handler: MyApp.HL7Handler
)

# Handler behaviour
defmodule MyApp.HL7Handler do
  @behaviour HL7v2.MLLP.Handler

  @impl true
  def handle_message(%HL7v2.Message{} = msg) do
    # Process the message
    {:ok, :application_accept}
  end
end

# Client
{:ok, client} = HL7v2.MLLP.Client.start_link(host: "hl7.hospital.local", port: 2575)
{:ok, ack} = HL7v2.MLLP.Client.send(client, msg)
```

### ACK Building

```elixir
# Auto-generate ACK from received message
ack = HL7v2.ACK.accept(original_msg)
nak = HL7v2.ACK.reject(original_msg, "Missing required PID segment")
```

## v0.1 Scope

### In Scope

| Area | Details |
|------|---------|
| Raw parsing | Lossless delimiter-based parsing, MSH auto-detection |
| Typed parsing | Schema-driven parsing into segment structs |
| Segments | MSH, EVN, PID, PV1, NK1, OBR, OBX, ORC, MSA, ERR, NTE, AL1, DG1, ZXX (generic) |
| Data types | ST, NM, DT, DTM, TS, ID, IS, SI, TX, FT, CX, XPN, XAD, XTN, CE, CWE, HD, PL, EI, MSG, PT, VID |
| Builder | Full message construction API |
| Encoder | Serialize to HL7v2 wire format (lossless round-trip) |
| Validation | Structure validation (required segments) + field validation (types, required) |
| ACK builder | AA, AE, AR acknowledgments |
| MLLP framing | Encode/decode MLLP frames |
| MLLP listener | Ranch 2.x TCP server with handler behaviour |
| MLLP client | TCP client with connection management |
| TLS | TLS + mTLS for MLLP connections |
| Telemetry | Events for parse, encode, send, receive |
| HL7 version | v2.5 primary, v2.3.1+ compatible |

### Out of Scope (v0.1)

- Full segment coverage (200+ segments in the standard)
- Message profiles / conformance profiles
- HL7v2 XML encoding
- Batch/file mode
- Character set negotiation beyond UTF-8
- Code-generation mix tasks (manual segment definitions first)

## Testing Strategy

- Property-based testing with StreamData for encoding/decoding round-trips
- Fixture-based testing with real-world HL7v2 messages
- MLLP integration tests with dynamic port allocation
- 90%+ coverage target

## License

MIT — same as `dicom` and `dimse`.

## Success Criteria

1. Parse any well-formed HL7 v2.x message without data loss
2. Build valid ADT and ORM messages programmatically
3. Round-trip: parse → encode produces identical output
4. MLLP listener handles concurrent connections with TLS
5. Published on Hex.pm as `hl7v2`
6. Phaos migrates from inline HL7 code to this library
