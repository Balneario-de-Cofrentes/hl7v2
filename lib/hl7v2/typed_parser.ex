defmodule HL7v2.TypedParser do
  @moduledoc """
  Converts a raw-parsed HL7v2 message into typed segment structs.

  Each segment in the `RawMessage` is dispatched to its corresponding segment
  module via a registry lookup:

  - **Known segments** (MSH, PID, PV1, ...) are parsed through
    `SegmentModule.parse(raw_fields, separators)`.
  - **Z-segments** (names starting with `"Z"`) become `HL7v2.Segment.ZXX` structs
    via `ZXX.new/2`, preserving the original segment name.
  - **Unknown segments** are kept as raw `{name, fields}` tuples so nothing is lost.
  """

  alias HL7v2.{RawMessage, TypedMessage}
  alias HL7v2.Segment.ZXX

  @segment_modules %{
    "MSH" => HL7v2.Segment.MSH,
    "EVN" => HL7v2.Segment.EVN,
    "PID" => HL7v2.Segment.PID,
    "PV1" => HL7v2.Segment.PV1,
    "PV2" => HL7v2.Segment.PV2,
    "NK1" => HL7v2.Segment.NK1,
    "OBR" => HL7v2.Segment.OBR,
    "OBX" => HL7v2.Segment.OBX,
    "ORC" => HL7v2.Segment.ORC,
    "MSA" => HL7v2.Segment.MSA,
    "ERR" => HL7v2.Segment.ERR,
    "NTE" => HL7v2.Segment.NTE,
    "AL1" => HL7v2.Segment.AL1,
    "DG1" => HL7v2.Segment.DG1,
    "IN1" => HL7v2.Segment.IN1,
    "SCH" => HL7v2.Segment.SCH,
    "AIS" => HL7v2.Segment.AIS,
    "GT1" => HL7v2.Segment.GT1,
    "FT1" => HL7v2.Segment.FT1,
    "RGS" => HL7v2.Segment.RGS,
    "MRG" => HL7v2.Segment.MRG
  }

  @doc """
  Returns the segment module for a given segment ID, or nil if unknown.
  """
  @spec segment_module(binary()) :: module() | nil
  def segment_module(seg_id), do: Map.get(@segment_modules, seg_id)

  @doc """
  Converts a `RawMessage` into a `TypedMessage` with parsed segment structs.

  Returns `{:ok, typed_message}` on success, or `{:error, reason}` if
  conversion fails.

  ## Examples

      iex> {:ok, raw} = HL7v2.Parser.parse("MSH|^~\\\\&|S|F||R|20240101||ADT^A01|1|P|2.5\\r")
      iex> {:ok, typed} = HL7v2.TypedParser.convert(raw)
      iex> %HL7v2.Segment.MSH{} = hd(typed.segments)

  """
  @spec convert(RawMessage.t()) :: {:ok, TypedMessage.t()} | {:error, term()}
  def convert(%RawMessage{separators: separators, type: type, segments: segments}) do
    typed_segments = Enum.map(segments, &convert_segment(&1, separators))

    {:ok,
     %TypedMessage{
       separators: separators,
       type: type,
       segments: typed_segments
     }}
  end

  @doc """
  Converts a `TypedMessage` back into a `RawMessage`.

  Each typed segment struct is encoded back to its raw field list via
  `SegmentModule.encode/1`. Z-segments use their stored `segment_id`, and
  unknown raw tuples pass through unchanged.

  ## Examples

      iex> {:ok, raw} = HL7v2.Parser.parse("MSH|^~\\\\&|S|F||R|20240101||ADT^A01|1|P|2.5\\r")
      iex> {:ok, typed} = HL7v2.TypedParser.convert(raw)
      iex> raw_again = HL7v2.TypedParser.to_raw(typed)
      iex> %HL7v2.RawMessage{} = raw_again

  """
  @spec to_raw(TypedMessage.t()) :: RawMessage.t()
  def to_raw(%TypedMessage{separators: separators, type: type, segments: segments}) do
    sep = <<separators.sub_component>>

    raw_segments =
      HL7v2.Type.with_sub_component_separator(sep, fn ->
        Enum.map(segments, &revert_segment/1)
      end)

    %RawMessage{
      separators: separators,
      type: type,
      segments: raw_segments
    }
  end

  # --- Private ---

  defp convert_segment({name, raw_fields}, separators) do
    case Map.get(@segment_modules, name) do
      nil ->
        if z_segment?(name) do
          ZXX.new(name, raw_fields)
        else
          {name, raw_fields}
        end

      module ->
        module.parse(raw_fields, separators)
    end
  end

  defp revert_segment(%ZXX{segment_id: name} = zxx) do
    {name, ZXX.encode(zxx)}
  end

  defp revert_segment({name, raw_fields}) when is_binary(name) and is_list(raw_fields) do
    {name, raw_fields}
  end

  defp revert_segment(%{__struct__: module} = segment) do
    name = module.segment_id()
    {name, module.encode(segment)}
  end

  defp z_segment?(<<"Z", _rest::binary>>), do: true
  defp z_segment?(_), do: false
end
