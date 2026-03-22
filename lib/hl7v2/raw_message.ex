defmodule HL7v2.RawMessage do
  @moduledoc """
  Represents a parsed HL7v2 message in raw (lossless) form.

  The raw message preserves the structure and content of the original message —
  no type coercion, no validation, no data loss. Round-tripping is canonical:
  line endings are normalized to CR and a trailing CR is always present, so
  `parse(text) |> encode()` produces the canonical wire form, which may differ
  from the input only in line-ending normalization.

  ## Structure

  Each segment is a tuple `{name, fields}` where:

  - `name` is a binary segment identifier (e.g., `"MSH"`, `"PID"`)
  - `fields` is an ordered list of field values, starting from the first field
    after the segment name

  ### Field Value Representation

  Field values use nested lists to represent the HL7v2 delimiter hierarchy:

  - **Simple field**: a binary string — `"Smith"`
  - **Components**: a list of binaries — `["Smith", "John", "", "Dr"]`
  - **Repetitions**: a list of component-lists — `[["12345", "", "", "MRN"], ["67890", "", "", "SSN"]]`
  - **Sub-components**: lists nested within components as needed

  For MSH, field 1 is always the field separator character as a single-byte binary
  (e.g., `"|"`), and field 2 is the encoding characters as a literal string
  (e.g., `"^~\\\\&"`).
  """

  @type field_value :: binary() | [binary()] | [[binary()]] | [[[binary()]]]

  @type t :: %__MODULE__{
          separators: HL7v2.Separator.t(),
          type: {binary(), binary()} | {binary(), binary(), binary()},
          segments: [{binary(), [field_value()]}]
        }

  defstruct [:separators, :type, :segments]
end
