# Migration Guide

This guide walks through moving to `hl7v2` from another HL7 v2.x
library. Each section pairs the library you already know with the
equivalent `hl7v2` API so the diff is obvious.

Covered:

- [`elixir_hl7`](#from-elixir_hl7) — the main Elixir alternative
- [HAPI v2 (Java)](#from-hapi-v2-java) — mental-model mapping
- [HL7apy (Python)](#from-hl7apy-python) — mental-model mapping

At the end you'll find a
[feature comparison](#feature-comparison) and a short
[adoption checklist](#adoption-checklist).

## From `elixir_hl7`

`elixir_hl7` parses HL7 v2 messages as generic lists and exposes a
path-based query API. `hl7v2` parses into **typed segment structs**
with named fields backed by the HL7 v2.5.1 + v2.6/v2.7 catalogs, and
additionally preserves unknown segments losslessly.

### 1. Install

```elixir
# Old
def deps, do: [{:elixir_hl7, "~> 0.9"}]

# New
def deps, do: [{:hl7v2, "~> 3.8"}]
```

### 2. Parse

```elixir
# elixir_hl7
hl7 = HL7.Message.new(wire)
# => %HL7.Message{segments: [...], ...}

# hl7v2 — raw mode, same shape
{:ok, raw} = HL7v2.parse(wire)
# => %HL7v2.RawMessage{segments: [{"MSH", [...]}, {"PID", [...]}]}

# hl7v2 — typed mode, gives you structs
{:ok, msg} = HL7v2.parse(wire, mode: :typed)
# => %HL7v2.TypedMessage{segments: [%HL7v2.Segment.MSH{...}, %HL7v2.Segment.PID{...}]}
```

`hl7v2.parse/2` returns `{:ok, msg}` / `{:error, reason}` rather than
raising. Typed mode is strictly more powerful — you still get raw
access to any fields by path.

### 3. Field access by path

`elixir_hl7` uses a path string query API. `hl7v2` provides the same
string API plus typed struct access.

```elixir
# elixir_hl7
HL7.Message.get_value(hl7, "PID-5.2")
HL7.Message.get_values(hl7, "OBX-5")

# hl7v2 — path API (mirrors elixir_hl7)
HL7v2.get(msg, "PID-5.2")
HL7v2.get_all(msg, "OBX-5")

# hl7v2 — typed access (new, preferred)
pid = Enum.find(msg.segments, &is_struct(&1, HL7v2.Segment.PID))
first_name = hd(pid.patient_name).given_name
```

Typed access is autocompletion-friendly, catches typos at compile
time, and returns **nil** (not empty string) when a field is absent —
so `nil` guards work instead of truthy-string checks.

### 4. Build messages

```elixir
# elixir_hl7 — hand-assemble lists
segments = [
  ["MSH", "|", "^~\\&", "HIS", "HOSP", ...],
  ["PID", "1", "", "12345^^^MRN", "", "Smith^John"]
]
HL7.Message.new(segments)

# hl7v2 — struct builder
alias HL7v2.Segment.{PID, EVN, PV1}
alias HL7v2.Type.{CX, XPN, FN, PL}

msg =
  HL7v2.new("ADT", "A01",
    sending_application: "HIS",
    sending_facility: "HOSP",
    receiving_application: "PACS",
    receiving_facility: "IMG"
  )
  |> HL7v2.Message.add_segment(%EVN{event_type_code: "A01"})
  |> HL7v2.Message.add_segment(%PID{
    patient_identifier_list: [%CX{id: "12345", identifier_type_code: "MRN"}],
    patient_name: [%XPN{family_name: %FN{surname: "Smith"}, given_name: "John"}]
  })

wire = HL7v2.encode(msg)
```

You get compile-time safety, no manual separator management, and
type-aware composite encoding (`XPN`, `CX`, `PL`, ...).

### 5. Validate

`elixir_hl7` has no validation. `hl7v2` ships structural, positional,
conditional, field-level, version-aware, and table validation plus
user-defined conformance profiles:

```elixir
# Basic validation
case HL7v2.validate(msg) do
  :ok -> :ok
  {:error, errors} -> Enum.each(errors, &IO.inspect/1)
end

# Conformance profile
profile =
  HL7v2.Profile.new("Hospital_ADT", message_type: {"ADT", "A01"})
  |> HL7v2.Profile.require_segment("NK1")
  |> HL7v2.Profile.require_field("PID", 18)

HL7v2.validate(msg, profile: profile)
```

See [`guides/conformance-profiles.md`](conformance-profiles.md) for
the full profile DSL.

### 6. ACK / NAK

```elixir
# elixir_hl7 — no built-in helper, you hand-build the MSA

# hl7v2
{ack_msh, msa} = HL7v2.Ack.accept(hd(msg.segments))
accept_wire = HL7v2.Ack.encode({ack_msh, msa})

{ack_msh, msa, err} =
  HL7v2.Ack.reject(hd(msg.segments),
    error_code: "207",
    error_text: "Application internal error"
  )
reject_wire = HL7v2.Ack.encode({ack_msh, msa, err})
```

### 7. MLLP transport

`elixir_hl7` does not ship an MLLP transport. `hl7v2` includes an
integrated Ranch 2.x listener/client with TLS and mutual-TLS support.
This is typically the point where downstream users reach for a
separate `mllp` package — with `hl7v2`, it's already in the box.

```elixir
# Server
{:ok, _pid} = HL7v2.MLLP.Listener.start_link(port: 2575, handler: MyHandler)

# Client
{:ok, client} = HL7v2.MLLP.Client.start_link(host: "localhost", port: 2575)
{:ok, ack} = HL7v2.MLLP.Client.send_message(client, wire)
```

See [`getting-started.md`](getting-started.md#mllp-transport) for the
full transport API.

### 8. Unknown / Z-segments

Both libraries preserve unknown segments on parse. In `hl7v2`:

- Segments with an ID starting with `Z` become `%HL7v2.Segment.ZXX{}`
- Any other unknown segment stays as `{name, raw_fields}`
- Both forms encode back to wire format via `HL7v2.encode/1`
- `HL7v2.get/2` with a path string works uniformly across typed
  structs, ZXX, and raw tuples

### 9. Pitfalls worth knowing

If you're coming from a busy `elixir_hl7` codebase, watch for these:

- **Empty-string vs nil.** `elixir_hl7` returns `""` for absent
  fields; `hl7v2` returns `nil`. Replace `x != ""` checks with
  `is_nil/1` or pattern matching.
- **Repeating fields.** `elixir_hl7` returns a list always;
  `hl7v2` returns a typed list for `unbounded` fields and a single
  struct otherwise. Follow the segment module's declared cardinality.
- **Separator handling.** `elixir_hl7` exposes separators as strings;
  `hl7v2` threads them via a `%HL7v2.Separator{}` struct and handles
  subcomponent escaping automatically on encode.
- **Version.** `hl7v2` reads `MSH-12` on parse and applies
  version-aware field presence rules (v2.3 → v2.8+). If you parse
  v2.3 payloads, you'll now get v2.3-correct validation instead of
  v2.5.1-flavored warnings.

## From HAPI v2 (Java)

HAPI's model-based API maps almost 1:1 onto `hl7v2`:

| HAPI                             | `hl7v2`                                |
| -------------------------------- | -------------------------------------- |
| `PipeParser().parse(wire)`       | `HL7v2.parse(wire, mode: :typed)`      |
| `message.getMSH()`               | `hd(msg.segments)` (or `Enum.find/2`)  |
| `pid.getPatientName(0).getGivenName()` | `hd(pid.patient_name).given_name` |
| `new ADT_A01()`                  | `HL7v2.new("ADT", "A01", opts)`        |
| `message.encode()`               | `HL7v2.encode(msg)`                    |
| `Acknowledgment.generateACK(...)`| `HL7v2.Ack.accept(msh)`                |
| `HapiContext.getValidationContext()` | `HL7v2.Profile` + `HL7v2.validate/2` |
| `MinLowerLayerProtocol`          | `HL7v2.MLLP.Listener` / `.Client`       |

The mental model is the same — segment objects with named accessors —
but you replace generated Java classes with first-class Elixir structs
and idiomatic pipelines. Segment names, field names, and composite
types match the HL7 v2.5.1 spec and use `snake_case` instead of
camelCase.

## From HL7apy (Python)

HL7apy exposes HL7 as a hierarchy of attribute-addressable objects.
The Elixir equivalents:

| HL7apy                                  | `hl7v2`                                 |
| --------------------------------------- | --------------------------------------- |
| `parse_message(wire)`                   | `HL7v2.parse(wire, mode: :typed)`       |
| `msg.MSH.msh_9`                         | `hd(msg.segments).message_type`         |
| `msg.PID.pid_5.xpn_1.fn_1`              | `hd(pid.patient_name).family_name.surname` |
| `Message("ADT_A01")`                    | `HL7v2.new("ADT", "A01", opts)`         |
| `msg.to_er7()`                          | `HL7v2.encode(msg)`                     |
| `msg.validate()` (message profile)      | `HL7v2.validate(msg, profile: profile)` |

HL7apy's implicit-null attribute traversal becomes explicit `nil`
handling in Elixir — use `get_in/2`, pattern matching, or
`HL7v2.get/2` with a path string when you don't want to walk structs
manually.

## Feature comparison

| Feature                           | `hl7v2` | `elixir_hl7` | HAPI Java | HL7apy |
| --------------------------------- | :-----: | :----------: | :-------: | :----: |
| Typed segment structs             |   yes   |      no      |    yes    |  yes   |
| Positional structural validation  |   yes   |      no      |    yes    |  yes   |
| Conditional field validation      |   yes   |      no      |    yes    |   no   |
| Version-aware rules (v2.3-v2.8)   |   yes   |      no      |    yes    |  yes   |
| Table validation (opt-in)         |   yes   |      no      |    yes    |  yes   |
| Conformance profiles (DSL)        |   yes   |      no      |    yes    | partial |
| ACK / NAK helpers                 |   yes   |      no      |    yes    |  yes   |
| MLLP transport (TLS + mTLS)       |   yes   |      no      |    yes    |   no   |
| Unknown segment preservation      |   yes   |     yes      |    yes    |  yes   |
| Telemetry                         |   yes   |      no      |      no   |   no   |
| Pure-BEAM, no NIFs                |   yes   |     yes      |      no   |   no   |

## Adoption checklist

Port your codebase incrementally:

1. **Swap the dep** (`elixir_hl7` → `hl7v2`). Raw mode parses first.
2. **Adapt path lookups** — `HL7.Message.get_value/2` → `HL7v2.get/2`.
3. **Flip empty-string checks** to nil checks.
4. **Move one message flow at a time** to typed mode
   (`mode: :typed`), starting with the ones you know the segments for.
5. **Replace hand-assembled segment lists** with struct builders.
6. **Turn on validation** (`validate: true`) in a logging-only mode.
7. **Promote warnings to errors** per integration, optionally with
   `HL7v2.Profile`.
8. **Swap your MLLP transport** (`mllp`, handmade TCP handler) for
   `HL7v2.MLLP.Listener` + `.Client`.
9. **Subscribe to telemetry events** for observability
   (`[:hl7v2, :parse, :start | :stop | :exception]`, etc.).

If you hit a segment that isn't typed yet, it keeps parsing as a raw
tuple — nothing gets lost — and you can still address it via
`HL7v2.get/2` paths. File an issue and it'll usually show up in the
next release.
