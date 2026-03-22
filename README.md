# HL7v2

[![Hex.pm](https://img.shields.io/hexpm/v/hl7v2.svg)](https://hex.pm/packages/hl7v2)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/hl7v2)
[![License](https://img.shields.io/hexpm/l/hl7v2.svg)](https://github.com/Balneario-de-Cofrentes/hl7v2/blob/main/LICENSE)

Pure Elixir HL7 v2.x toolkit -- schema-driven parsing, typed segments, message builder, validation, and MLLP transport.

## Why this library

- **Schema-driven** -- Segments are Elixir structs with named fields, not string maps with integer keys
- **Dual mode** -- Raw lossless parsing for forwarding/routing, typed structs for clinical logic
- **Builder-first** -- Programmatic message construction with auto-populated MSH, ACK/NAK helpers
- **All-in-one** -- Parse, build, validate, and transmit via MLLP in a single dependency

| | elixir_hl7 | hl7v2 |
|---|---|---|
| Parsing | Sparse maps | Typed structs |
| Building | Not supported | First-class API |
| Validation | None | Opt-in, standards-aware |
| Transport | Separate package | Integrated MLLP |
| Ranch | 1.8 | 2.x |

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

# Raw mode -- lossless, fast
{:ok, raw} = HL7v2.parse(text)
raw.type  # => {"ADT", "A01"}

# Typed mode -- segments become structs
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
  def handle_message(message, _meta) do
    case HL7v2.parse(message, mode: :typed) do
      {:ok, typed} ->
        msh = hd(typed.segments)
        {ack_msh, msa} = HL7v2.Ack.accept(msh)
        {:ok, HL7v2.Ack.encode({ack_msh, msa})}

      {:error, _reason} ->
        {:error, :parse_failed}
    end
  end
end

# Send as a client
{:ok, client} = HL7v2.MLLP.Client.start_link(host: "hl7.hospital.local", port: 2575)
{:ok, ack} = HL7v2.MLLP.Client.send_message(client, wire)
```

### TLS

```elixir
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

## Supported Segments

| Segment | Description |
|---------|-------------|
| MSH | Message Header |
| EVN | Event Type |
| PID | Patient Identification |
| PV1 | Patient Visit |
| PV2 | Patient Visit - Additional |
| NK1 | Next of Kin |
| OBR | Observation Request |
| OBX | Observation Result |
| ORC | Common Order |
| MSA | Message Acknowledgment |
| ERR | Error |
| NTE | Notes and Comments |
| AL1 | Allergy Information |
| DG1 | Diagnosis |
| IN1 | Insurance |
| SCH | Schedule Activity |
| AIS | Appointment Information |
| GT1 | Guarantor |
| FT1 | Financial Transaction |
| ZXX | Generic Z-Segment |

## Supported Data Types

| Type | Kind | Description |
|------|------|-------------|
| ST | Primitive | String |
| NM | Primitive | Numeric |
| DT | Primitive | Date |
| DTM | Primitive | Date/Time |
| SI | Primitive | Sequence ID |
| ID | Primitive | Coded Value (HL7 table) |
| IS | Primitive | Coded Value (user table) |
| TX | Primitive | Text |
| FT | Primitive | Formatted Text |
| NR | Primitive | Numeric Range |
| TN | Primitive | Telephone Number |
| CX | Composite | Extended Composite ID |
| XPN | Composite | Extended Person Name |
| XAD | Composite | Extended Address |
| XTN | Composite | Extended Telecom |
| XCN | Composite | Extended Composite Name |
| XON | Composite | Extended Composite Org |
| CE | Composite | Coded Element |
| CWE | Composite | Coded With Exceptions |
| CNE | Composite | Coded No Exceptions |
| HD | Composite | Hierarchic Designator |
| PL | Composite | Person Location |
| EI | Composite | Entity Identifier |
| EIP | Composite | Entity Identifier Pair |
| MSG | Composite | Message Type |
| PT | Composite | Processing Type |
| VID | Composite | Version Identifier |
| FN | Composite | Family Name |
| SAD | Composite | Street Address |
| DR | Composite | Date/Time Range |
| TS | Composite | Time Stamp |
| CP | Composite | Composite Price |
| MO | Composite | Money |
| FC | Composite | Financial Class |
| JCC | Composite | Job Code/Class |
| CQ | Composite | Composite Quantity |
| DLD | Composite | Discharge to Location |
| DLN | Composite | Driver's License Number |
| ERL | Composite | Error Location |

## Message Types

ADT (A01, A02, A03, A04, A08, A11, A13, A28, A31, A40), ORM^O01, ORU^R01, ACK, SIU (S12, S14, S15).

## Documentation

Full API documentation is available at [hexdocs.pm/hl7v2](https://hexdocs.pm/hl7v2).

## Part of the Balneario Healthcare Toolkit

| Library | Protocol | Purpose |
|---------|----------|---------|
| [dicom](https://hex.pm/packages/dicom) | DICOM | Parse, write, de-identify medical imaging data |
| [dimse](https://hex.pm/packages/dimse) | DIMSE | DICOM networking (C-STORE, C-FIND, C-MOVE) |
| **hl7v2** | **HL7 v2.x** | **Parse, build, validate clinical messages + MLLP** |

## License

MIT -- see [LICENSE](LICENSE).
