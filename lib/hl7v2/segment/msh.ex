defmodule HL7v2.Segment.MSH do
  @moduledoc """
  Message Header (MSH) segment — HL7v2 v2.5.1.

  The first segment of every HL7v2 message. MSH-1 and MSH-2 receive special
  treatment: MSH-1 is the field separator character itself, and MSH-2 is the
  encoding characters literal string.

  21 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "MSH",
    fields: [
      {1, :field_separator, HL7v2.Type.ST, :r, 1},
      {2, :encoding_characters, HL7v2.Type.ST, :r, 1},
      {3, :sending_application, HL7v2.Type.HD, :o, 1},
      {4, :sending_facility, HL7v2.Type.HD, :o, 1},
      {5, :receiving_application, HL7v2.Type.HD, :o, 1},
      {6, :receiving_facility, HL7v2.Type.HD, :o, 1},
      {7, :date_time_of_message, HL7v2.Type.TS, :r, 1},
      {8, :security, HL7v2.Type.ST, :o, 1},
      {9, :message_type, HL7v2.Type.MSG, :r, 1},
      {10, :message_control_id, HL7v2.Type.ST, :r, 1},
      {11, :processing_id, HL7v2.Type.PT, :r, 1},
      {12, :version_id, HL7v2.Type.VID, :r, 1},
      {13, :sequence_number, HL7v2.Type.NM, :o, 1},
      {14, :continuation_pointer, HL7v2.Type.ST, :o, 1},
      {15, :accept_acknowledgment_type, HL7v2.Type.ID, :o, 1},
      {16, :application_acknowledgment_type, HL7v2.Type.ID, :o, 1},
      {17, :country_code, HL7v2.Type.ID, :o, 1},
      {18, :character_set, HL7v2.Type.ID, :o, :unbounded},
      {19, :principal_language_of_message, HL7v2.Type.CE, :o, 1},
      {20, :alternate_character_set_handling_scheme, HL7v2.Type.ID, :o, 1},
      {21, :message_profile_identifier, HL7v2.Type.EI, :o, :unbounded}
    ]

  @doc """
  Parses MSH with special handling for MSH-1 (field separator) and MSH-2
  (encoding characters), which are stored as-is rather than type-parsed.
  """
  @impl HL7v2.Segment
  @spec parse(list(), HL7v2.Separator.t()) :: t()
  def parse(raw_fields, _separators \\ HL7v2.Separator.default()) do
    # MSH-1 and MSH-2 are special: store as literal strings
    base = %__MODULE__{
      field_separator: Enum.at(raw_fields, 0),
      encoding_characters: Enum.at(raw_fields, 1)
    }

    # Parse remaining fields (MSH-3 onwards) using standard logic
    remaining_fields = Enum.drop(@segment_fields, 2)

    attrs =
      Enum.map(remaining_fields, fn {seq, name, type, _opt, max_reps} ->
        raw = Enum.at(raw_fields, seq - 1)
        {name, HL7v2.Segment.parse_field_value(raw, type, max_reps)}
      end)

    struct(base, attrs)
  end

  @doc """
  Encodes MSH with special handling for MSH-1 and MSH-2.
  """
  @impl HL7v2.Segment
  @spec encode(t()) :: list()
  def encode(%__MODULE__{} = msh) do
    remaining_fields = Enum.drop(@segment_fields, 2)

    rest =
      Enum.map(remaining_fields, fn {_seq, name, type, _opt, max_reps} ->
        value = Map.get(msh, name)
        HL7v2.Segment.encode_field_value(value, type, max_reps)
      end)

    trimmed_rest =
      rest
      |> Enum.reverse()
      |> Enum.drop_while(&empty_field?/1)
      |> Enum.reverse()

    [msh.field_separator, msh.encoding_characters | trimmed_rest]
  end

  defp empty_field?(""), do: true
  defp empty_field?(nil), do: true
  defp empty_field?([]), do: true
  defp empty_field?(_), do: false
end
