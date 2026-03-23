# HL7v2

```
    _   _ _   ___        ____
   | | | | | |__ \__   _|___ \
   | |_| | |    ) \ \ / / __) |
   |  _  | |__ / / \ V / / __/
   |_| |_|____|_/   \_/ |_____|

   Pure Elixir HL7 v2.x Toolkit
   Schema-driven parsing, building, and MLLP transport.
```

[![Hex.pm](https://img.shields.io/hexpm/v/hl7v2.svg)](https://hex.pm/packages/hl7v2)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/hl7v2)
[![License](https://img.shields.io/hexpm/l/hl7v2.svg)](https://github.com/Balneario-de-Cofrentes/hl7v2/blob/main/LICENSE)

The HL7v2 library that treats clinical messages as first-class data structures,
not bags of strings.

## The Difference

Other Elixir HL7v2 libraries give you string maps. We give you structs:

```elixir
# elixir_hl7 — strings all the way down
HL7.get(msg, ~p"PID-5")  # => "Smith^John"

# hl7v2 — typed structs with named fields
pid = Enum.find(typed.segments, &is_struct(&1, HL7v2.Segment.PID))
pid.patient_name  # => [%XPN{family_name: %FN{surname: "Smith"}, given_name: "John"}]

# Build messages programmatically — no other Elixir library does this:
msg = HL7v2.Message.new("ADT", "A01", sending_application: "PHAOS")
      |> HL7v2.Message.add_segment(%HL7v2.Segment.PID{
           patient_name: [%XPN{family_name: %FN{surname: "Smith"}, given_name: "John"}]
         })
```

## Why HL7v2

| | elixir_hl7 | **hl7v2** |
|---|---|---|
| Data model | Sparse maps, integer keys | **Typed structs, named fields** |
| Building messages | Not supported | **`Message.new` + `add_segment`** |
| Validation | None (by design) | **Opt-in required-field + segment-presence checks** |
| Transport | Separate package (mllp) | **Integrated MLLP** |
| Ranch | 1.8 | **2.x** |
| Parse + type | Two steps | **`mode: :typed` in one call** |
| ACK/NAK | Manual | **`Ack.accept/error/reject`** |
| TLS | Separate config | **Built-in mTLS helpers** |
| Path access | `~p"PID-5"` sigil | **`get/2` + `fetch/2` with error tuples** |
| Telemetry | No | **`:telemetry` spans on all ops** |

## Installation

```elixir
def deps do
  [{:hl7v2, "~> 1.0"}]
end
```

## Quick Start

### Parse

```elixir
# Raw mode — canonical round-trip, zero allocation overhead
{:ok, raw} = HL7v2.parse(text)
raw.type  #=> {"ADT", "A01"}

# Typed mode — segments become structs
{:ok, msg} = HL7v2.parse(text, mode: :typed)

# Access fields naturally
HL7v2.get(msg, "PID-5")   #=> %XPN{family_name: %FN{surname: "Smith"}, ...}
HL7v2.get(msg, "PID-3")   #=> %CX{id: "12345", identifier_type_code: "MR"}
HL7v2.get(msg, "PID-8")   #=> "M"
HL7v2.get(msg, "PID-3[2]") #=> second identifier (repetition)
```

### Build

```elixir
msg =
  HL7v2.Message.new("ADT", "A01",
    sending_application: "PHAOS",
    sending_facility: "HOSP"
  )
  |> HL7v2.Message.add_segment(%HL7v2.Segment.PID{
    set_id: 1,
    patient_identifier_list: [
      %HL7v2.Type.CX{id: "MRN001", identifier_type_code: "MR"}
    ],
    patient_name: [
      %HL7v2.Type.XPN{
        family_name: %HL7v2.Type.FN{surname: "Smith"},
        given_name: "John"
      }
    ],
    administrative_sex: "M"
  })

wire = HL7v2.encode(msg)
# => "MSH|^~\\&|PHAOS|HOSP|...\rPID|1||MRN001^^^^MR||Smith^John|||M\r"
```

### Validate

```elixir
{:ok, typed} = HL7v2.parse(text, mode: :typed)

case HL7v2.validate(typed) do
  :ok ->
    :good

  {:error, errors} ->
    # [%{level: :error, location: "PID", field: :patient_name,
    #    message: "Required field is missing"}]
    Enum.each(errors, &IO.inspect/1)
end
```

### ACK/NAK

```elixir
# Accept
{ack_msh, msa} = HL7v2.Ack.accept(original_msh)
wire = HL7v2.Ack.encode({ack_msh, msa})

# Reject with error details
{ack_msh, msa, err} = HL7v2.Ack.reject(original_msh,
  text: "Unknown patient",
  error_code: "204"
)
```

### MLLP Transport

```elixir
# Server
defmodule MyHandler do
  @behaviour HL7v2.MLLP.Handler

  @impl true
  def handle_message(message, _meta) do
    {:ok, typed} = HL7v2.parse(message, mode: :typed)
    msh = hd(typed.segments)
    {ack_msh, msa} = HL7v2.Ack.accept(msh)
    {:ok, HL7v2.Ack.encode({ack_msh, msa})}
  end
end

{:ok, _} = HL7v2.MLLP.Listener.start_link(port: 2575, handler: MyHandler)

# Client
{:ok, client} = HL7v2.MLLP.Client.start_link(host: "hl7.hospital.local", port: 2575)
{:ok, ack} = HL7v2.MLLP.Client.send_message(client, wire)

# TLS / mTLS
{:ok, _} = HL7v2.MLLP.Listener.start_link(
  port: 2576,
  handler: MyHandler,
  tls: [certfile: "cert.pem", keyfile: "key.pem", cacertfile: "ca.pem", verify: :verify_peer]
)
```

## Coverage

```
 Segments    29 standard + generic ZXX (MSH EVN PID PD1 PV1 PV2 NK1
              OBR OBX ORC MSA ERR NTE AL1 DG1 IN1 SCH AIS AIG AIL AIP
              RGS MRG SFT PR1 DB1 ACC GT1 FT1)
              29 of ~136 standard segments + generic Z-segment pass-through

 Types       38 composite + 10 primitive (48 v2.5.1 types including legacy TN)

 Messages    ADT (A01-A04, A08, A12) ORM^O01 ORU^R01 SIU^S12 ACK
              structural validation (order + groups + cardinality)

 Transport   MLLP framing, Ranch 2.x listener, GenServer client,
              TLS/mTLS, telemetry instrumentation

 Validation  structural (order/groups/cardinality) + opt-in table checking
              20 HL7 tables, 11 coded fields validated

 Speed       <1s full suite
```

## Scope and Limitations

This library targets **HL7 v2.5.1** with permissive parsing of adjacent versions.

**What it does well:** delimiter parsing, typed segment/composite structs, canonical
round-trip encoding, programmatic message building, MLLP transport with TLS, and
validation (required fields, repetition limits, structural order/group/cardinality
checks for supported message types). Lenient mode (default) reports ordering issues
as warnings; strict mode treats them as errors.
Raw mode is lossless for all valid HL7v2 messages. Typed mode covers a focused
ADT/ORM/ORU/SIU/ACK subset with extra_fields preservation for unlisted fields.

**What it does not do:**

- Full abstract-message-definition validation (group nesting depth, alternatives)
- Conditional field logic (fields marked `:c` are not evaluated)
- Full message profile conformance (MSH-22+ not supported)
- Text type semantics (ST, TX, FT are lossless pass-through — no delimiter rejection,
  no whitespace normalization)

**Coverage:** 29 of ~136 standard segments (plus generic ZXX) typed. 48 of 89 v2.5.1
data types. 20 group-aware message structure definitions with positional structural
validation (ordering, cardinality, group awareness). Opt-in table validation for 20 HL7 tables. Extra
fields beyond declared definitions are preserved in `extra_fields` for lossless round-trip.
OBX exposes 19 of 25 fields; OBR exposes 49 of 50 — unlisted fields survive as extra_fields.
Some typed segment fields fall back to `:raw` where their HL7 data types (TQ, SPS, ELD) are
not yet implemented — these fields are preserved but not parsed into typed structs.

## Handling Unknown Segments

Real-world HL7 is messy. Messages arrive with vendor-specific Z-segments, obsolete
segments from older versions, and segments your system doesn't care about. The library
handles all of them without crashing or losing data:

```elixir
{:ok, msg} = HL7v2.parse(text, mode: :typed)

# Known segments → typed structs with named fields
%HL7v2.Segment.PID{patient_name: [%XPN{...}], ...}

# Z-segments → ZXX struct preserving segment ID and all raw fields
%HL7v2.Segment.ZXX{segment_id: "ZPD", raw_fields: ["custom", "data"]}

# Unknown standard segments → raw tuples, lossless
{"ROL", ["1", "AD", "CP", ...]}
```

All three forms encode back to valid HL7 wire format. The typed API (`get/2`, `fetch/2`,
`~h` sigil) works across all forms — typed segments return struct fields with component
and repetition selection, raw tuples return whole fields by position (component/repetition
selectors are not applied to raw tuples).

This means you can parse any HL7 message from any source, work with the segments you
understand, and forward the rest unchanged. No schema registration required.

## Documentation

Full API docs: [hexdocs.pm/hl7v2](https://hexdocs.pm/hl7v2)

Getting started guide included.

## Part of the Balneario Healthcare Toolkit

Three pure-Elixir libraries covering the core protocol surface of healthcare IT. Zero NIFs. Built for production.

| Library | Domain | Standards | |
|---------|--------|-----------|---|
| **dicom** | Medical imaging data | PS3.5 / 6 / 10 / 15 / 16 / 18 | [Hex](https://hex.pm/packages/dicom) · [Docs](https://hexdocs.pm/dicom) · [GitHub](https://github.com/Balneario-de-Cofrentes/dicom) |
| **dimse** | DICOM networking | PS3.7 / 8 / 15 | [Hex](https://hex.pm/packages/dimse) · [Docs](https://hexdocs.pm/dimse) · [GitHub](https://github.com/Balneario-de-Cofrentes/dimse) |
| **hl7v2** | Clinical messaging | HL7 v2.5.1 | [Hex](https://hex.pm/packages/hl7v2) · [Docs](https://hexdocs.pm/hl7v2) · [GitHub](https://github.com/Balneario-de-Cofrentes/hl7v2) |

[`dicom`](https://github.com/Balneario-de-Cofrentes/dicom) parses and writes DICOM files. [`dimse`](https://github.com/Balneario-de-Cofrentes/dimse) moves them over the network via DIMSE-C/N services. `hl7v2` handles the clinical messages (ADT, ORM, ORU) that trigger and contextualize imaging workflows.

Together they give Elixir the same healthcare protocol coverage that Java has with dcm4che + HAPI, or C++ with DCMTK — on the BEAM.

## License

MIT — see [LICENSE](LICENSE).
