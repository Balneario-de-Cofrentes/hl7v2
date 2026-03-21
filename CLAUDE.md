# HL7v2 — AI Development Guide

## Project Overview

Pure Elixir HL7 v2.x library. Schema-driven parsing, typed segment structs, message builder, validation, and MLLP transport.

Standalone library — not part of an umbrella. Published on Hex.pm as `hl7v2`.

## Build Commands

```bash
mix deps.get          # Install dependencies
mix compile           # Compile
mix test              # Run all tests
mix format            # Format code
mix format --check-formatted  # Check formatting
```

## Module Naming

- Top-level namespace: `HL7v2`
- Segments: `HL7v2.Segment.PID`, `HL7v2.Segment.OBR`, etc.
- Data types: `HL7v2.Type.CX`, `HL7v2.Type.XPN`, etc.
- Transport: `HL7v2.MLLP.*`

## Coding Standards

- `@spec` on all public functions
- `@moduledoc` and `@doc` on all public modules and functions
- Use `{:ok, result}` / `{:error, reason}` tuples consistently
- Never raise in library code
- Prefer iodata over binary concatenation in encoding paths
- Zero runtime deps for core (parsing, building, validation)
- Ranch 2.x + Telemetry for transport only

## Testing

- Property-based testing with StreamData for encoding/decoding round-trips
- Use `ExUnit.Case, async: true` wherever possible
- 90%+ coverage target
- Run `mix test` before committing

## Reference

- HL7 v2.5.1 is the primary target version
- Segment definitions: `docs/reference/segments.md`
- Data type definitions: `docs/reference/data-types.md`
- Message structures: `docs/reference/message-structures.md`
- Encoding rules: `docs/reference/encoding-rules.md`

## License

MIT
