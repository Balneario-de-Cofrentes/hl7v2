defmodule HL7v2.Type.TM do
  @moduledoc """
  Time (TM) -- HL7v2 primitive data type.

  Format: `HH[MM[SS[.S[S[S[S]]]]]][+/-ZZZZ]`

  Parses to a `%TM{}` struct preserving all fields for lossless round-trip
  encoding. Similar to DTM but without the date portion.
  """

  @behaviour HL7v2.Type

  defstruct [
    :hour,
    :minute,
    :second,
    :fraction,
    :offset
  ]

  @type t :: %__MODULE__{
          hour: non_neg_integer(),
          minute: non_neg_integer() | nil,
          second: non_neg_integer() | nil,
          fraction: binary() | nil,
          offset: binary() | nil
        }

  @doc """
  Parses a TM string into a `%TM{}` struct.

  ## Examples

      iex> HL7v2.Type.TM.parse("143022.1234+0100")
      %HL7v2.Type.TM{hour: 14, minute: 30, second: 22, fraction: "1234", offset: "+0100"}

      iex> HL7v2.Type.TM.parse("1430")
      %HL7v2.Type.TM{hour: 14, minute: 30}

      iex> HL7v2.Type.TM.parse("14")
      %HL7v2.Type.TM{hour: 14}

      iex> HL7v2.Type.TM.parse("")
      nil

      iex> HL7v2.Type.TM.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: t() | nil
  def parse(nil), do: nil
  def parse(""), do: nil

  def parse(value) when is_binary(value) do
    {time_part, offset} = split_offset(value)
    parse_time(time_part, offset)
  end

  @doc """
  Encodes a TM value back to HL7v2 format.

  ## Examples

      iex> HL7v2.Type.TM.encode(%HL7v2.Type.TM{hour: 14, minute: 30})
      "1430"

      iex> HL7v2.Type.TM.encode(%HL7v2.Type.TM{hour: 14, minute: 30, second: 22, fraction: "1234", offset: "+0100"})
      "143022.1234+0100"

      iex> HL7v2.Type.TM.encode(nil)
      ""

  """
  @spec encode(t() | nil) :: binary()
  def encode(nil), do: ""

  def encode(%__MODULE__{} = tm) do
    result = pad2(tm.hour)
    result = if tm.minute, do: result <> pad2(tm.minute), else: result
    result = if tm.second, do: result <> pad2(tm.second), else: result

    result =
      if tm.fraction do
        result <> "." <> tm.fraction
      else
        result
      end

    if tm.offset do
      result <> tm.offset
    else
      result
    end
  end

  # -- Private --

  defp split_offset(value) do
    len = byte_size(value)

    if len >= 5 do
      potential_sign = :binary.at(value, len - 5)

      if potential_sign in [?+, ?-] do
        offset_str = binary_part(value, len - 5, 5)
        time_str = binary_part(value, 0, len - 5)
        {time_str, offset_str}
      else
        {value, nil}
      end
    else
      {value, nil}
    end
  end

  defp parse_time(str, offset) do
    case byte_size(str) do
      n when n < 2 -> nil
      2 -> parse_hour(str, offset)
      4 -> parse_hour_minute(str, offset)
      n when n >= 6 -> parse_hour_minute_second(str, offset)
      _ -> nil
    end
  end

  defp parse_hour(<<h::binary-size(2)>>, offset) do
    case Integer.parse(h) do
      {hour, ""} when hour in 0..23 -> %__MODULE__{hour: hour, offset: offset}
      _ -> nil
    end
  end

  defp parse_hour_minute(<<h::binary-size(2), m::binary-size(2)>>, offset) do
    with {hour, ""} <- Integer.parse(h),
         true <- hour in 0..23,
         {minute, ""} <- Integer.parse(m),
         true <- minute in 0..59 do
      %__MODULE__{hour: hour, minute: minute, offset: offset}
    else
      _ -> nil
    end
  end

  defp parse_hour_minute_second(
         <<h::binary-size(2), m::binary-size(2), s::binary-size(2), rest::binary>>,
         offset
       ) do
    with {hour, ""} <- Integer.parse(h),
         true <- hour in 0..23,
         {minute, ""} <- Integer.parse(m),
         true <- minute in 0..59,
         {second, ""} <- Integer.parse(s),
         true <- second in 0..59 do
      tm = %__MODULE__{hour: hour, minute: minute, second: second, offset: offset}
      parse_fraction(rest, tm)
    else
      _ -> nil
    end
  end

  defp parse_fraction("", tm), do: tm

  defp parse_fraction(<<".", fraction::binary>>, tm) do
    if fraction != "" and Regex.match?(~r/\A\d{1,4}\z/, fraction) do
      %{tm | fraction: fraction}
    else
      nil
    end
  end

  defp parse_fraction(_, _), do: nil

  defp pad2(n), do: n |> Integer.to_string() |> String.pad_leading(2, "0")
end
