defmodule HL7v2.Segment.OBXValue do
  @moduledoc """
  Dispatches OBX-5 (observation_value) parsing based on OBX-2 (value_type).

  When OBX-2 declares a known data type, the observation value is parsed into
  the corresponding typed struct. Unknown types are preserved as raw values.

  Per the HL7 v2.5.1 specification (Section 7.4.2), the data type of OBX-5
  varies at runtime based on the value of OBX-2.
  """

  alias HL7v2.Segment

  @value_type_map %{
    "ST" => HL7v2.Type.ST,
    "NM" => HL7v2.Type.NM,
    "TX" => HL7v2.Type.TX,
    "FT" => HL7v2.Type.FT,
    "CE" => HL7v2.Type.CE,
    "CWE" => HL7v2.Type.CWE,
    "CNE" => HL7v2.Type.CNE,
    "DT" => HL7v2.Type.DT,
    "DTM" => HL7v2.Type.DTM,
    "TS" => HL7v2.Type.TS,
    "NR" => HL7v2.Type.NR,
    "XCN" => HL7v2.Type.XCN,
    "XAD" => HL7v2.Type.XAD,
    "XPN" => HL7v2.Type.XPN,
    "XTN" => HL7v2.Type.XTN,
    "ID" => HL7v2.Type.ID,
    "IS" => HL7v2.Type.IS,
    "HD" => HL7v2.Type.HD,
    "CX" => HL7v2.Type.CX,
    "EI" => HL7v2.Type.EI,
    "SI" => HL7v2.Type.SI,
    "CF" => HL7v2.Type.FT,
    "CQ" => HL7v2.Type.CQ,
    "MO" => HL7v2.Type.MO,
    "DR" => HL7v2.Type.DR,
    "XON" => HL7v2.Type.XON,
    "CP" => HL7v2.Type.CP,
    "FC" => HL7v2.Type.FC,
    "TM" => HL7v2.Type.TM,
    "TN" => HL7v2.Type.TN,
    "SN" => HL7v2.Type.SN,
    "ED" => HL7v2.Type.ED,
    "RP" => HL7v2.Type.RP
  }

  @doc """
  Parses OBX-5 value(s) based on the declared value type from OBX-2.

  Returns the parsed value for single values, or a list for repeating values.
  Unknown types are preserved as-is (raw).
  """
  @spec parse(term(), binary() | nil) :: term()
  def parse(raw_value, value_type)
  def parse(nil, _value_type), do: nil
  def parse("", _value_type), do: nil
  def parse(raw_value, nil), do: raw_value

  def parse(raw_value, value_type) when is_binary(value_type) do
    case Map.get(@value_type_map, value_type) do
      nil -> raw_value
      type_module -> parse_with_type(raw_value, type_module)
    end
  end

  @doc """
  Encodes a typed OBX-5 value back to its raw wire representation.

  Used before segment encoding so the `:raw` encode path receives
  a value the wire encoder can serialize (strings and lists of strings).
  """
  @spec encode(term(), binary() | nil) :: term()
  def encode(nil, _value_type), do: nil
  def encode(value, nil), do: value

  def encode(value, value_type) when is_binary(value_type) do
    case Map.get(@value_type_map, value_type) do
      nil -> value
      type_module -> encode_with_type(value, type_module)
    end
  end

  @doc "Returns the type module for a given OBX-2 value, or nil."
  @spec type_for(binary()) :: module() | nil
  def type_for(value_type), do: Map.get(@value_type_map, value_type)

  @doc "Returns all known value type codes."
  @spec known_types() :: [binary()]
  def known_types, do: Map.keys(@value_type_map)

  # --- Parse Helpers ---

  defp parse_with_type(raw_value, type_module) do
    composite? = Segment.composite_type?(type_module)
    do_parse(raw_value, type_module, composite?)
  end

  # Repeating values: list of lists = multiple composite repetitions
  defp do_parse(reps, type_module, true = _composite?)
       when is_list(reps) and is_list(hd(reps)) do
    Enum.map(reps, &type_module.parse/1)
  end

  # Single composite value: list of components
  defp do_parse(components, type_module, true = _composite?) when is_list(components) do
    type_module.parse(components)
  end

  # Repeating primitives: list of strings
  defp do_parse(reps, type_module, false = _composite?) when is_list(reps) do
    Enum.map(reps, fn
      v when is_binary(v) -> type_module.parse(v)
      other -> other
    end)
  end

  # Single primitive value
  defp do_parse(value, type_module, _composite?) when is_binary(value) do
    type_module.parse(value)
  end

  # Anything else, keep raw
  defp do_parse(other, _type_module, _composite?), do: other

  # --- Encode Helpers ---

  defp encode_with_type(values, type_module) when is_list(values) do
    Enum.map(values, &encode_single(&1, type_module))
  end

  defp encode_with_type(value, type_module) do
    encode_single(value, type_module)
  end

  defp encode_single(nil, _type_module), do: nil
  defp encode_single(value, type_module), do: type_module.encode(value)
end
