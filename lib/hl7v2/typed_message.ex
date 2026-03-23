defmodule HL7v2.TypedMessage do
  @moduledoc """
  Typed HL7v2 message with parsed segment structs.

  A `TypedMessage` is the result of converting a `RawMessage` through the
  `HL7v2.TypedParser`. Known segments (MSH, PID, PV1, etc.) are represented as
  their typed struct, Z-segments as `HL7v2.Segment.ZXX` structs, and truly
  unknown segments are preserved as raw `{name, fields}` tuples.

  ## Escape sequences

  Typed field values preserve HL7 escape sequences literally (e.g. `\\F\\`,
  `\\S\\`, `\\R\\`, `\\E\\`, `\\T\\`, `\\Xhh\\`). The parser does **not**
  decode them automatically because doing so would lose the distinction between
  a literal delimiter and an escaped one, breaking round-trip fidelity.

  To decode escape sequences in a field value, call `HL7v2.Escape.decode/2`
  explicitly:

      sep = msg.separators
      decoded = HL7v2.Escape.decode(pid.patient_name |> hd() |> to_string(), sep)

  To encode delimiter characters before setting a field, use `HL7v2.Escape.encode/2`.
  """

  @type t :: %__MODULE__{
          separators: HL7v2.Separator.t(),
          type: {binary(), binary()} | {binary(), binary(), binary()},
          segments: [struct() | {binary(), list()}]
        }

  defstruct [:separators, :type, :segments]
end

defimpl String.Chars, for: HL7v2.TypedMessage do
  def to_string(msg) do
    msg
    |> HL7v2.TypedParser.to_raw()
    |> HL7v2.Encoder.encode()
  end
end
