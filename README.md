# HL7v2

```
    _   _ _   ___        ____
   | | | | | |__ \__   _|___ \
   | |_| | |    ) \ \ / / __) |
   |  _  | |__ / / \ V / / __/
   |_| |_|____|_/   \_/ |_____|

   Pure Elixir HL7 v2.x Toolkit
   Schema-driven. Type-safe. Production-ready.
```

[![Hex.pm](https://img.shields.io/hexpm/v/hl7v2.svg)](https://hex.pm/packages/hl7v2)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/hl7v2)
[![License](https://img.shields.io/hexpm/l/hl7v2.svg)](https://github.com/Balneario-de-Cofrentes/hl7v2/blob/main/LICENSE)

The HL7v2 library that treats clinical messages as first-class data structures,
not bags of strings.

## The Problem

Every Elixir HL7v2 library today gives you this:

```elixir
# elixir_hl7 — string maps, integer keys, no types
patient_name = HL7.get(msg, ~p"PID-5")    # => "Smith^John"
mrn = HL7.get(msg, ~p"PID-3[1].1")        # => "12345"
# Typo in "PID-55"? Silent nil. Wrong field? Silent nil. No compiler help.
```

We give you this:

```elixir
# hl7v2 — typed structs, named fields, compiler-checked
pid = HL7v2.get(msg, "PID-5")
pid.family_name.surname  # => "Smith"
pid.given_name           # => "John"

# Or build from scratch — no other Elixir library can do this:
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
| Validation | None (by design) | **Opt-in, per HL7 v2.5.1** |
| Transport | Separate package (mllp) | **Integrated MLLP** |
| Ranch | 1.8 | **2.x** |
| Parse + type | Two steps | **`mode: :typed` in one call** |
| ACK/NAK | Manual | **`Ack.accept/error/reject`** |
| TLS | Separate config | **Built-in mTLS helpers** |
| Path access | `~p"PID-5"` sigil | **`get(msg, "PID-5.1[2]")`** |
| Telemetry | No | **`:telemetry` spans on all ops** |

## Installation

```elixir
def deps do
  [{:hl7v2, "~> 0.1"}]
end
```

## Quick Start

### Parse

```elixir
# Raw mode — lossless, zero allocation overhead
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
 Segments    20 typed structs (MSH EVN PID PV1 PV2 NK1 OBR OBX ORC
              MSA ERR NTE AL1 DG1 IN1 SCH AIS GT1 FT1 ZXX)

 Types       39 composites + 12 primitives — 97% of segment fields typed

 Messages    ADT (A01-A04, A08) ORM^O01 ORU^R01 SIU^S12 ACK
              with structure validation rules

 Transport   MLLP framing, Ranch 2.x listener, GenServer client,
              TLS/mTLS, telemetry instrumentation

 Tests       1,382 (228 doctests + 30 properties + 1,124 tests)
 Coverage    96.56%
 Speed       0.5s full suite
```

## Documentation

Full API docs: [hexdocs.pm/hl7v2](https://hexdocs.pm/hl7v2)

Getting started guide included.

## Part of the Balneario Healthcare Toolkit

```
  dicom     DICOM P10 parse/write/de-id    hex.pm/packages/dicom
  dimse     DICOM networking (C-STORE/FIND) hex.pm/packages/dimse
  hl7v2     HL7 v2.x parse/build/MLLP      hex.pm/packages/hl7v2
```

Three pure-Elixir libraries. Zero NIFs. One team. Built for production
medical imaging and clinical messaging systems.

## License

MIT — see [LICENSE](LICENSE).
