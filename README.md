```
    ╦ ╦╦  ╔╦╗┬  ┬┌─┐
    ╠═╣║   ║ └┐┌┘┌─┘
    ╩ ╩╩═╝ ╩  └┘ └─┘
    ─────────────────
    Pure Elixir HL7 v2.x
```

# HL7v2

[![Hex.pm](https://img.shields.io/hexpm/v/hl7v2.svg)](https://hex.pm/packages/hl7v2)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/hl7v2)
[![License](https://img.shields.io/hexpm/l/hl7v2.svg)](https://github.com/Balneario-de-Cofrentes/hl7v2/blob/main/LICENSE)

Schema-driven HL7 v2.x toolkit for Elixir. Typed segment structs, programmatic message building, validation, and integrated MLLP transport.

## Why another HL7 library?

Existing Elixir HL7 libraries treat messages as **delimited text** — sparse maps with integer keys, no type awareness, no builder. HL7v2 treats messages as **typed clinical data** — segments are Elixir structs with named fields, messages are built programmatically, and validation is first-class.

| | elixir_hl7 | hl7v2 |
|---|---|---|
| Parsing | Sparse maps | Typed structs |
| Building | Not supported | First-class API |
| Validation | Intentionally none | Opt-in, standards-aware |
| Transport | Separate package (mllp) | Integrated MLLP |
| Ranch | 1.8 | 2.x |
| Dependencies (core) | Zero | Zero |

## Installation

```elixir
def deps do
  [
    {:hl7v2, "~> 0.1"}
  ]
end
```

## Quick Start

### Parse a message

```elixir
text = "MSH|^~\\&|HIS|HOSP|PACS|IMG|20260322||ADT^A01|MSG001|P|2.5\rPID|1||12345^^^MRN||Smith^John||19800315|M"

# Raw mode — lossless, fast
{:ok, raw} = HL7v2.parse(text)
raw.type  # => {"ADT", "A01"}

# Typed mode — segments become structs
{:ok, msg} = HL7v2.parse(text, mode: :typed)

pid = HL7v2.Message.segment(msg, HL7v2.Segment.PID)
pid.patient_name     # => [%HL7v2.Type.XPN{family_name: "Smith", given_name: "John"}]
pid.date_of_birth    # => ~D[1980-03-15]
pid.sex              # => "M"
```

### Build a message

```elixir
alias HL7v2.{Message, Segment, Type}

msg =
  Message.new("ADT", "A01",
    sending_application: "PHAOS",
    receiving_application: "HIS"
  )
  |> Message.add_segment(%Segment.PID{
    set_id: 1,
    patient_id_list: [
      %Type.CX{id: "12345", assigning_authority: %Type.HD{namespace_id: "MRN"}}
    ],
    patient_name: [
      %Type.XPN{family_name: "Smith", given_name: "John"}
    ],
    date_of_birth: ~D[1980-03-15],
    sex: "M"
  })

HL7v2.encode(msg)
# => "MSH|^~\\&|PHAOS||HIS||...|ADT^A01|...|2.5\rPID|1||12345^^^MRN||Smith^John||19800315|M\r"
```

### Validate

```elixir
case HL7v2.validate(msg) do
  :ok -> :good
  {:error, errors} -> IO.inspect(errors)
end
```

### MLLP Transport

```elixir
# Start a listener
{:ok, _} = HL7v2.MLLP.Listener.start_link(
  port: 2575,
  handler: MyApp.HL7Handler
)

# Implement the handler
defmodule MyApp.HL7Handler do
  @behaviour HL7v2.MLLP.Handler

  @impl true
  def handle_message(%HL7v2.Message{} = msg) do
    # Process the message...
    {:ok, :application_accept}
  end
end

# Send as a client
{:ok, client} = HL7v2.MLLP.Client.start_link(host: "hl7.hospital.local", port: 2575)
{:ok, ack} = HL7v2.MLLP.Client.send(client, msg)
```

### TLS

```elixir
# Listener with TLS
HL7v2.MLLP.Listener.start_link(
  port: 2576,
  handler: MyApp.HL7Handler,
  tls: [
    certfile: "priv/cert.pem",
    keyfile: "priv/key.pem",
    cacertfile: "priv/ca.pem",
    verify: :verify_peer
  ]
)
```

## Typed Segments (v0.1)

MSH, EVN, PID, PV1, PV2, NK1, OBR, OBX, ORC, MSA, ERR, NTE, AL1, DG1, IN1, SCH, AIS, GT1, FT1 + generic Z-segment handler.

## Data Types (v0.1)

ST, NM, DT, DTM, TS, ID, IS, SI, TX, FT, CX, XPN, XAD, XTN, CE, CWE, HD, PL, EI, MSG, PT, VID, CNE, DR, FC, XON.

## Message Types (v0.1)

ADT (A01, A02, A03, A04, A08, A11, A13, A28, A31, A40), ORM^O01, ORU^R01, ACK, SIU (S12, S14, S15).

## Architecture

```
hl7v2
├── Core (zero runtime deps)
│   ├── Parser         — raw + typed parsing
│   ├── Encoder        — serialize to wire format
│   ├── Message        — builder API
│   ├── Segment.*      — typed segment structs
│   ├── Type.*         — HL7v2 data types
│   ├── Validation     — structure + field rules
│   └── ACK            — acknowledgment builder
│
└── Transport (Ranch 2.x + Telemetry)
    ├── MLLP           — framing encode/decode
    ├── MLLP.Listener  — TCP server
    ├── MLLP.Client    — TCP client
    └── MLLP.TLS       — TLS configuration
```

## Part of the Balneario Healthcare Toolkit

| Library | Protocol | Purpose |
|---------|----------|---------|
| [dicom](https://hex.pm/packages/dicom) | DICOM | Parse, write, de-identify medical imaging data |
| [dimse](https://hex.pm/packages/dimse) | DIMSE | DICOM networking (C-STORE, C-FIND, C-MOVE) |
| **hl7v2** | **HL7 v2.x** | **Parse, build, validate clinical messages + MLLP** |

## License

MIT - see [LICENSE](LICENSE).
