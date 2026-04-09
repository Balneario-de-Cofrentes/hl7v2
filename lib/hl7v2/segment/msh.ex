defmodule HL7v2.Segment.MSH do
  @moduledoc """
  Message Header (MSH) segment — HL7v2 v2.5.1, with v2.7+ extensions.

  The first segment of every HL7v2 message. MSH-1 and MSH-2 receive special
  treatment: MSH-1 is the field separator character itself, and MSH-2 is the
  encoding characters literal string.

  21 fields per HL7 v2.5.1 specification, plus v2.7+ optional fields 22-25:
  sending/receiving responsible organization (XON) and sending/receiving
  network address (HD).
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
      {21, :message_profile_identifier, HL7v2.Type.EI, :o, :unbounded},
      # v2.7+ fields
      {22, :sending_responsible_organization, HL7v2.Type.XON, :o, 1},
      {23, :receiving_responsible_organization, HL7v2.Type.XON, :o, 1},
      {24, :sending_network_address, HL7v2.Type.HD, :o, 1},
      {25, :receiving_network_address, HL7v2.Type.HD, :o, 1}
    ]

  @doc """
  Parses MSH with special handling for MSH-1 (field separator) and MSH-2
  (encoding characters), which are stored as-is rather than type-parsed.
  """
  @impl HL7v2.Segment
  @spec parse(list(), HL7v2.Separator.t()) :: t()
  def parse(raw_fields, separators \\ HL7v2.Separator.default()) do
    sep = <<separators.sub_component>>

    ensure_sep = fn fun ->
      if Process.get(:hl7v2_sub_component_sep) do
        fun.()
      else
        HL7v2.Type.with_sub_component_separator(sep, fun)
      end
    end

    ensure_sep.(fn ->
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

      max_seq = HL7v2.Segment.max_declared_seq(@segment_fields)
      extra = Enum.drop(raw_fields, max_seq)

      struct(base, [{:extra_fields, extra} | attrs])
    end)
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

    extra = msh.extra_fields || []
    [msh.field_separator, msh.encoding_characters | HL7v2.Segment.trim_trailing(rest ++ extra)]
  end
end
