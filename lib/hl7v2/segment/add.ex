defmodule HL7v2.Segment.ADD do
  @moduledoc """
  Addendum (ADD) segment — HL7v2 v2.5.1.

  Defines the continuation of the prior segment when there is not enough
  room in that segment for the data. Used for very long text continuations.

  1 field per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "ADD",
    fields: [
      {1, :addendum_continuation_pointer, HL7v2.Type.ST, :o, 1}
    ]
end
