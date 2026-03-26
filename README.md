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

Pure Elixir HL7 v2.x toolkit — typed segment structs, programmatic message building,
structural validation, and integrated MLLP transport.

## What You Get

- **Typed segments** — every v2.5.1 segment is an Elixir struct with named fields,
  not string maps with integer keys
- **Programmatic message building** — `Message.new/3` + `add_segment/2` with
  auto-populated MSH
- **Structural validation** — positional order/group/cardinality checks for
  supported message structures, opt-in HL7 table validation
- **Lossless raw mode** — canonical round-trip parsing that preserves everything,
  including malformed input
- **Integrated MLLP** — Ranch 2.x listener, GenServer client, TLS/mTLS, telemetry
- **ACK/NAK builder** — `HL7v2.ack/2` with sender/receiver swap
- **Path access** — `get/2`, `fetch/2`, `~h` sigil with compile-time validation

```elixir
# Typed structs with named fields
{:ok, msg} = HL7v2.parse(text, mode: :typed)
pid = Enum.find(msg.segments, &is_struct(&1, HL7v2.Segment.PID))
pid.patient_name  #=> [%XPN{family_name: %FN{surname: "Smith"}, given_name: "John"}]

# Build messages programmatically
msg = HL7v2.Message.new("ADT", "A01", sending_application: "PHAOS")
      |> HL7v2.Message.add_segment(%HL7v2.Segment.PID{
           patient_name: [%XPN{family_name: %FN{surname: "Smith"}, given_name: "John"}]
         })
```

## Installation

```elixir
def deps do
  [{:hl7v2, "~> 2.5"}]
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
  tls: HL7v2.MLLP.TLS.mutual_tls_options(certfile: "cert.pem", keyfile: "key.pem", cacertfile: "ca.pem")
)
```

## Coverage

```
 Segments    152 standard + generic ZXX
              152 of 152 v2.5.1 segments (100%) + generic Z-segment pass-through
              149 fully typed, 3 with intentional raw holes (RDT, QPD, OBX)
              Run `mix hl7v2.coverage` for the full list

 Types       90 of 90 v2.5.1 data types (100%)

 Structures  190 message structure definitions covering all major v2.5.1 families
              ADT, BAR, BPS/BRP/BRT/BTS, CRM, CSU, DFT, MDM, MFN/MFK/MFR,
              OML/OMG/OMD/OMP/OMS/OMI/OMN/OMB, ORU/OUL/ORA, ORM/ORR/ORG/ORL/ORP/ORD/ORS/ORN/ORI/ORB,
              RDE/RDS/RGV/RAS, RRE/RRD/RRG/RRA, REF/RRI, SIU/SRM/SRR,
              PGL/PPG/PPP/PPR/PPT, QBP/QSB/QVR/RSP/RTB/RDY, PMU, PEX/SUR,
              CCR/CCI/CCU/CCQ/CCF, EHC, RQI/RQA/RQC/RQP/RPA/RPI/RPL/RPR/RCI,
              RER/RDR/RAR/ROR, VXU/VXQ/VXR/VXX, DOC, UDM, ACK + more

 Transport   MLLP framing, Ranch 2.x listener, GenServer client,
              TLS/mTLS, telemetry instrumentation

 Validation  structural (order/groups/cardinality) + opt-in table checking
              20 HL7 tables, 11 coded fields validated

 Speed       <1s full suite
```

## Scope

**HL7 v2.5.1** with permissive parsing of adjacent versions (v2.3 through v2.8.x).

- Every v2.5.1 segment and data type has a typed Elixir module
- Raw mode is lossless for all valid HL7v2 messages, including malformed input
- Typed mode preserves values it cannot parse (invalid dates, malformed
  numbers) in `original` fields for round-trip fidelity
- Extra fields beyond declared definitions are preserved in `extra_fields`
- Escape sequences are preserved literally in typed fields — call
  `HL7v2.Escape.decode/2` when you need decoded text

Run `mix hl7v2.coverage` for detailed per-segment field completeness.

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

# Unknown segments from other versions → raw tuples, lossless
{"XYZ", ["1", "DATA001", ...]}
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
