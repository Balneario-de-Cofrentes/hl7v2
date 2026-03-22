defmodule HL7v2.Message do
  @moduledoc """
  Programmatic HL7v2 message construction.

  Builds well-formed HL7v2 messages from typed segment structs. The MSH segment
  is auto-populated with sensible defaults (field separator, encoding characters,
  processing ID, version, timestamp, control ID) and can be overridden via opts.

  ## Examples

      msg =
        HL7v2.Message.new("ADT", "A01",
          sending_application: "PHAOS",
          sending_facility: "HOSP"
        )
        |> HL7v2.Message.add_segment(%HL7v2.Segment.PID{
          patient_identifier_list: [%HL7v2.Type.CX{id_number: "12345"}],
          patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}, given_name: "John"}]
        })

      wire = HL7v2.Message.encode(msg)

  """

  alias HL7v2.Segment.MSH
  alias HL7v2.Segment.ZXX
  alias HL7v2.Type.{HD, MSG, PT, VID, TS, DTM}

  # HL7 v2.5.1 canonical message structure map.
  # Many trigger events share the same abstract message definition.
  # If a {code, event} pair is not listed, the structure defaults to "CODE_EVENT".
  @canonical_structures %{
    {"ADT", "A04"} => "ADT_A01",
    {"ADT", "A08"} => "ADT_A01",
    {"ADT", "A13"} => "ADT_A01",
    {"ADT", "A05"} => "ADT_A05",
    {"ADT", "A14"} => "ADT_A05",
    {"ADT", "A28"} => "ADT_A05",
    {"ADT", "A31"} => "ADT_A05",
    {"ADT", "A06"} => "ADT_A06",
    {"ADT", "A07"} => "ADT_A06",
    {"ADT", "A09"} => "ADT_A09",
    {"ADT", "A10"} => "ADT_A09",
    {"ADT", "A11"} => "ADT_A09",
    {"ADT", "A15"} => "ADT_A15",
    {"ADT", "A16"} => "ADT_A16",
    {"ADT", "A25"} => "ADT_A21",
    {"ADT", "A26"} => "ADT_A21",
    {"ADT", "A27"} => "ADT_A21",
    {"ADT", "A21"} => "ADT_A21",
    {"ADT", "A22"} => "ADT_A21",
    {"ADT", "A23"} => "ADT_A21",
    {"ADT", "A24"} => "ADT_A24",
    {"ADT", "A37"} => "ADT_A37",
    {"ADT", "A38"} => "ADT_A38",
    {"ADT", "A39"} => "ADT_A39",
    {"ADT", "A40"} => "ADT_A39",
    {"ADT", "A41"} => "ADT_A39",
    {"ADT", "A42"} => "ADT_A39",
    {"SIU", "S13"} => "SIU_S12",
    {"SIU", "S14"} => "SIU_S12",
    {"SIU", "S15"} => "SIU_S12",
    {"SIU", "S16"} => "SIU_S12",
    {"SIU", "S17"} => "SIU_S12",
    {"SIU", "S26"} => "SIU_S12"
  }

  defstruct [:msh, segments: []]

  @type t :: %__MODULE__{
          msh: MSH.t(),
          segments: [struct()]
        }

  @doc """
  Creates a new message with MSH auto-populated.

  ## Options

    * `:sending_application` -- string or `%HD{}` (default `nil`)
    * `:sending_facility` -- string or `%HD{}` (default `nil`)
    * `:receiving_application` -- string or `%HD{}` (default `nil`)
    * `:receiving_facility` -- string or `%HD{}` (default `nil`)
    * `:date_time` -- `%TS{}` or `%DTM{}` (default: current UTC time)
    * `:message_control_id` -- string (default: auto-generated)
    * `:processing_id` -- string (default: `"P"`)
    * `:version_id` -- string (default: `"2.5.1"`)

  """
  @spec new(binary(), binary(), keyword()) :: t()
  def new(message_code, trigger_event, opts \\ []) do
    msh = %MSH{
      field_separator: "|",
      encoding_characters: "^~\\&",
      sending_application: wrap_hd(opts[:sending_application]),
      sending_facility: wrap_hd(opts[:sending_facility]),
      receiving_application: wrap_hd(opts[:receiving_application]),
      receiving_facility: wrap_hd(opts[:receiving_facility]),
      date_time_of_message: build_timestamp(opts[:date_time]),
      message_type: %MSG{
        message_code: message_code,
        trigger_event: trigger_event,
        message_structure: canonical_structure(message_code, trigger_event)
      },
      message_control_id: opts[:message_control_id] || generate_control_id(),
      processing_id: %PT{processing_id: opts[:processing_id] || "P"},
      version_id: %VID{version_id: opts[:version_id] || "2.5.1"}
    }

    %__MODULE__{msh: msh, segments: []}
  end

  @doc """
  Adds a segment to the message.

  Segments are appended in order. MSH is managed separately and cannot be added
  via this function.
  """
  @spec add_segment(t(), struct()) :: t()
  def add_segment(%__MODULE__{} = msg, segment) do
    %{msg | segments: msg.segments ++ [segment]}
  end

  @doc """
  Returns all segments of a given type.

  ## Examples

      HL7v2.Message.segments(msg, HL7v2.Segment.OBX)
      #=> [%HL7v2.Segment.OBX{...}, %HL7v2.Segment.OBX{...}]

  """
  @spec segments(t(), module()) :: [struct()]
  def segments(%__MODULE__{} = msg, module) do
    Enum.filter(msg.segments, &is_struct(&1, module))
  end

  @doc """
  Returns the first segment of a given type, or `nil`.

  ## Examples

      HL7v2.Message.segment(msg, HL7v2.Segment.PID)
      #=> %HL7v2.Segment.PID{...}

  """
  @spec segment(t(), module()) :: struct() | nil
  def segment(%__MODULE__{} = msg, module) do
    Enum.find(msg.segments, &is_struct(&1, module))
  end

  @doc """
  Encodes the message to HL7v2 wire format binary.

  Converts to a `RawMessage` and delegates to `HL7v2.Encoder`.
  """
  @spec encode(t()) :: binary()
  def encode(%__MODULE__{} = msg) do
    msg
    |> to_raw()
    |> HL7v2.Encoder.encode()
  end

  @doc """
  Converts to a `RawMessage` for encoding.
  """
  @spec to_raw(t()) :: HL7v2.RawMessage.t()
  def to_raw(%__MODULE__{msh: msh, segments: segments}) do
    sep = HL7v2.Separator.default()

    raw_segments = [
      {"MSH", MSH.encode(msh)}
      | Enum.map(segments, fn seg ->
          {segment_id_for(seg), seg.__struct__.encode(seg)}
        end)
    ]

    type = extract_type(msh)

    %HL7v2.RawMessage{
      separators: sep,
      type: type,
      segments: raw_segments
    }
  end

  # --- Private ---

  defp wrap_hd(nil), do: nil
  defp wrap_hd(%HD{} = hd), do: hd
  defp wrap_hd(value) when is_binary(value), do: %HD{namespace_id: value}

  defp build_timestamp(nil) do
    now = DateTime.utc_now()

    %TS{
      time: %DTM{
        year: now.year,
        month: now.month,
        day: now.day,
        hour: now.hour,
        minute: now.minute,
        second: now.second
      }
    }
  end

  defp build_timestamp(%TS{} = ts), do: ts

  defp build_timestamp(%DTM{} = dtm), do: %TS{time: dtm}

  defp generate_control_id do
    timestamp = :os.system_time(:microsecond) |> Integer.to_string()
    random = :crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower)
    "#{timestamp}_#{random}"
  end

  defp canonical_structure(code, event) do
    Map.get(@canonical_structures, {code, event}, "#{code}_#{event}")
  end

  defp extract_type(%MSH{message_type: %MSG{} = msg}) do
    code = msg.message_code || ""
    event = msg.trigger_event || ""
    structure = msg.message_structure

    if structure do
      {code, event, structure}
    else
      {code, event}
    end
  end

  defp extract_type(_), do: {"", ""}

  defp segment_id_for(%ZXX{} = zxx), do: ZXX.segment_name(zxx)
  defp segment_id_for(seg), do: seg.__struct__.segment_id()
end

defimpl String.Chars, for: HL7v2.Message do
  def to_string(msg), do: HL7v2.Message.encode(msg)
end
