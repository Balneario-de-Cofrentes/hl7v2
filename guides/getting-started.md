# Getting Started

## Installation

Add `hl7v2` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:hl7v2, "~> 1.4"}
  ]
end
```

Then run `mix deps.get`.

## Parsing

HL7v2 supports two parsing modes: **raw** (canonical round-trip, delimiter-based) and **typed** (structs with named fields).

### Raw mode

```elixir
text = "MSH|^~\\&|HIS|HOSP|PACS|IMG|20260322||ADT^A01|MSG001|P|2.5\rPID|1||12345^^^MRN||Smith^John||19800315|M"

{:ok, raw} = HL7v2.parse(text)

raw.type       # => {"ADT", "A01"}
raw.segments   # => [{"MSH", [...]}, {"PID", [...]}]
```

### Typed mode

```elixir
{:ok, typed} = HL7v2.parse(text, mode: :typed)

msh = hd(typed.segments)
msh.sending_application.namespace_id   # => "HIS"
msh.message_type.message_code          # => "ADT"

pid = Enum.find(typed.segments, &is_struct(&1, HL7v2.Segment.PID))
hd(pid.patient_name).given_name        # => "John"
```

### Parse + validate in one step

```elixir
{:ok, typed} = HL7v2.parse(text, mode: :typed, validate: true)
```

## Building Messages

Build HL7v2 messages programmatically with typed structs:

```elixir
alias HL7v2.Segment.{PID, EVN, PV1}
alias HL7v2.Type.{CX, XPN, FN, PL}

msg =
  HL7v2.new("ADT", "A01",
    sending_application: "MyApp",
    sending_facility: "Hospital",
    receiving_application: "PACS",
    receiving_facility: "IMG"
  )
  |> HL7v2.Message.add_segment(%EVN{
    event_type_code: "A01"
  })
  |> HL7v2.Message.add_segment(%PID{
    patient_identifier_list: [%CX{id: "12345"}],
    patient_name: [%XPN{family_name: %FN{surname: "Smith"}, given_name: "John"}]
  })
  |> HL7v2.Message.add_segment(%PV1{
    patient_class: "I",
    assigned_patient_location: %PL{point_of_care: "ICU", room: "101"}
  })

wire = HL7v2.encode(msg)
```

## Acknowledgments (ACK/NAK)

Build ACK responses from the original message's MSH segment:

```elixir
# Parse the incoming message
{:ok, typed} = HL7v2.parse(incoming_wire, mode: :typed)
original_msh = hd(typed.segments)

# Accept
{ack_msh, msa} = HL7v2.Ack.accept(original_msh)
accept_wire = HL7v2.Ack.encode({ack_msh, msa})

# Reject with error details
{ack_msh, msa, err} = HL7v2.Ack.reject(original_msh,
  error_code: "207",
  error_text: "Application internal error",
  text: "Could not process message"
)
reject_wire = HL7v2.Ack.encode({ack_msh, msa, err})
```

The shortcut `HL7v2.ack/2` is equivalent to `HL7v2.Ack.accept/2`:

```elixir
{ack_msh, msa} = HL7v2.ack(original_msh)
```

## Validation

```elixir
{:ok, typed} = HL7v2.parse(text, mode: :typed)

case HL7v2.validate(typed) do
  :ok ->
    # Message is valid
    :ok

  {:error, errors} ->
    # errors is a list of maps with :level, :location, :field, :message
    for err <- errors do
      IO.puts("#{err.level} in #{err.location}: #{err.message}")
    end
end
```

## MLLP Transport

HL7v2 includes an integrated MLLP transport layer built on Ranch 2.x.

### Server

Define a handler module implementing the `HL7v2.MLLP.Handler` behaviour:

```elixir
defmodule MyHandler do
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
```

Start the listener:

```elixir
{:ok, _pid} = HL7v2.MLLP.Listener.start_link(
  port: 2575,
  handler: MyHandler
)
```

### Client

```elixir
{:ok, client} = HL7v2.MLLP.Client.start_link(host: "localhost", port: 2575)

{:ok, ack} = HL7v2.MLLP.Client.send_message(client, wire)

:ok = HL7v2.MLLP.Client.close(client)
```

### TLS

Both listener and client support TLS:

```elixir
# Server with TLS
{:ok, _} = HL7v2.MLLP.Listener.start_link(
  port: 2576,
  handler: MyHandler,
  tls: [certfile: "server.pem", keyfile: "server-key.pem", cacertfile: "ca.pem"]
)

# Client with TLS
{:ok, client} = HL7v2.MLLP.Client.start_link(
  host: "remote.host",
  port: 2576,
  tls: [verify: :verify_peer, cacertfile: "ca.pem"]
)
```

## Working with Unknown Segments

Real-world HL7 messages contain segments the library doesn't have typed definitions for.
These are preserved losslessly — you never lose data:

```elixir
{:ok, msg} = HL7v2.parse(text, mode: :typed)

Enum.each(msg.segments, fn
  %HL7v2.Segment.PID{} = pid ->
    # Typed — access fields by name
    IO.inspect(pid.patient_name)

  %HL7v2.Segment.ZXX{segment_id: id, raw_fields: fields} ->
    # Z-segment — preserved with original segment ID
    IO.puts("Z-segment #{id}: #{inspect(fields)}")

  {name, raw_fields} ->
    # Unknown segment — preserved as raw tuple
    IO.puts("Unknown #{name}: #{length(raw_fields)} fields")
end)

# Path access works on all forms:
HL7v2.get(msg, "PID-5")   # typed struct field
HL7v2.get(msg, "ZPD-1")   # ZXX raw field by position
HL7v2.get(msg, "PR1-3")   # raw tuple field by position
```

All forms encode back to valid wire format with `HL7v2.encode/1`.

## Next Steps

- Browse the [API reference](https://hexdocs.pm/hl7v2) for full module documentation
- See `HL7v2.Segment` modules for available segment types and their fields
- See `HL7v2.Type` modules for composite data type structs
