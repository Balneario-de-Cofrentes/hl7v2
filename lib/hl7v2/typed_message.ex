defmodule HL7v2.TypedMessage do
  @moduledoc """
  Typed HL7v2 message with parsed segment structs.

  A `TypedMessage` is the result of converting a `RawMessage` through the
  `HL7v2.TypedParser`. Known segments (MSH, PID, PV1, etc.) are represented as
  their typed struct, Z-segments as `HL7v2.Segment.ZXX` structs, and truly
  unknown segments are preserved as raw `{name, fields}` tuples.
  """

  @type t :: %__MODULE__{
          separators: HL7v2.Separator.t(),
          type: {binary(), binary()} | {binary(), binary(), binary()},
          segments: [struct() | {binary(), list()}]
        }

  defstruct [:separators, :type, :segments]
end
