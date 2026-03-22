defmodule HL7v2.Type.DTM do
  @moduledoc """
  Date/Time (DTM) -- HL7v2 primitive data type.

  Format: `YYYY[MM[DD[HH[MM[SS[.S[S[S[S]]]]]]]]][+/-ZZZZ]`

  Parses to the most appropriate Elixir type:
  - `DateTime` when timezone offset is present and precision >= minute
  - `NaiveDateTime` when full datetime without timezone
  - `%HL7v2.Type.DTM{}` struct for partial values

  Encodes back to the canonical HL7v2 format.
  """

  @behaviour HL7v2.Type

  defstruct [
    :year,
    :month,
    :day,
    :hour,
    :minute,
    :second,
    :fraction,
    :offset
  ]

  @type t :: %__MODULE__{
          year: pos_integer(),
          month: pos_integer() | nil,
          day: pos_integer() | nil,
          hour: non_neg_integer() | nil,
          minute: non_neg_integer() | nil,
          second: non_neg_integer() | nil,
          fraction: binary() | nil,
          offset: binary() | nil
        }

  @doc """
  Parses a DTM string into a DateTime, NaiveDateTime, or partial DTM struct.

  ## Examples

      iex> HL7v2.Type.DTM.parse("20260322143022.1234+0100")
      %HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 14, minute: 30, second: 22, fraction: "1234", offset: "+0100"}

      iex> HL7v2.Type.DTM.parse("20260322")
      %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}

      iex> HL7v2.Type.DTM.parse("2026")
      %HL7v2.Type.DTM{year: 2026}

      iex> HL7v2.Type.DTM.parse("")
      nil

      iex> HL7v2.Type.DTM.parse(nil)
      nil

  """
  @spec parse(binary() | nil) :: t() | nil
  def parse(nil), do: nil
  def parse(""), do: nil

  def parse(value) when is_binary(value) do
    {datetime_part, offset} = split_offset(value)
    parse_datetime(datetime_part, offset)
  end

  @doc """
  Encodes a DTM value back to HL7v2 format.

  ## Examples

      iex> HL7v2.Type.DTM.encode(%HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 14, minute: 30})
      "202603221430"

      iex> HL7v2.Type.DTM.encode(%HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 14, minute: 30, second: 22, fraction: "1234", offset: "+0100"})
      "20260322143022.1234+0100"

      iex> HL7v2.Type.DTM.encode(nil)
      ""

  """
  @spec encode(t() | DateTime.t() | NaiveDateTime.t() | nil) :: binary()
  def encode(nil), do: ""

  def encode(%DateTime{} = dt) do
    base =
      pad4(dt.year) <>
        pad2(dt.month) <>
        pad2(dt.day) <>
        pad2(dt.hour) <> pad2(dt.minute) <> pad2(dt.second)

    frac =
      case dt.microsecond do
        {0, _} ->
          ""

        {us, precision} ->
          "." <>
            (us
             |> Integer.to_string()
             |> String.pad_leading(6, "0")
             |> String.slice(0, precision))
      end

    offset = format_utc_offset(dt.utc_offset + dt.std_offset)

    base <> frac <> offset
  end

  def encode(%NaiveDateTime{} = ndt) do
    base =
      pad4(ndt.year) <>
        pad2(ndt.month) <>
        pad2(ndt.day) <>
        pad2(ndt.hour) <> pad2(ndt.minute) <> pad2(ndt.second)

    case ndt.microsecond do
      {0, _} ->
        base

      {us, precision} ->
        base <>
          "." <>
          (us |> Integer.to_string() |> String.pad_leading(6, "0") |> String.slice(0, precision))
    end
  end

  def encode(%__MODULE__{} = dtm) do
    result = pad4(dtm.year)
    result = if dtm.month, do: result <> pad2(dtm.month), else: result
    result = if dtm.day, do: result <> pad2(dtm.day), else: result
    result = if dtm.hour, do: result <> pad2(dtm.hour), else: result
    result = if dtm.minute, do: result <> pad2(dtm.minute), else: result
    result = if dtm.second, do: result <> pad2(dtm.second), else: result

    result =
      if dtm.fraction do
        result <> "." <> dtm.fraction
      else
        result
      end

    if dtm.offset do
      result <> dtm.offset
    else
      result
    end
  end

  # -- Private --

  defp split_offset(value) do
    # Offset is always the last 5 chars: +HHMM or -HHMM
    len = byte_size(value)

    if len >= 5 do
      potential_sign = :binary.at(value, len - 5)

      if potential_sign in [?+, ?-] do
        offset_str = binary_part(value, len - 5, 5)
        datetime_str = binary_part(value, 0, len - 5)

        if valid_offset?(offset_str) do
          {datetime_str, offset_str}
        else
          # Malformed offset — split it off but discard (don't poison the datetime)
          {datetime_str, nil}
        end
      else
        {value, nil}
      end
    else
      {value, nil}
    end
  end

  # Validates offset matches [+-]\d{4} with hours 00-23 and minutes 00-59
  defp valid_offset?(<<sign, h1, h2, m1, m2>>)
       when sign in [?+, ?-] and
              h1 in ?0..?9 and h2 in ?0..?9 and
              m1 in ?0..?9 and m2 in ?0..?9 do
    hours = (h1 - ?0) * 10 + (h2 - ?0)
    minutes = (m1 - ?0) * 10 + (m2 - ?0)
    hours <= 23 and minutes <= 59
  end

  defp valid_offset?(_), do: false

  defp parse_datetime(str, offset) do
    case byte_size(str) do
      n when n < 4 ->
        nil

      4 ->
        parse_year(str, offset)

      6 ->
        parse_year_month(str, offset)

      8 ->
        parse_year_month_day(str, offset)

      10 ->
        parse_with_time(str, 10, offset)

      12 ->
        parse_with_time(str, 12, offset)

      n when n >= 14 ->
        parse_with_time(str, n, offset)

      _ ->
        nil
    end
  end

  defp parse_year(<<y::binary-size(4)>>, offset) do
    case Integer.parse(y) do
      {year, ""} when year > 0 -> %__MODULE__{year: year, offset: offset}
      _ -> nil
    end
  end

  defp parse_year_month(<<y::binary-size(4), m::binary-size(2)>>, offset) do
    with {year, ""} <- Integer.parse(y),
         {month, ""} <- Integer.parse(m),
         true <- month in 1..12 do
      %__MODULE__{year: year, month: month, offset: offset}
    else
      _ -> nil
    end
  end

  defp parse_year_month_day(<<y::binary-size(4), m::binary-size(2), d::binary-size(2)>>, offset) do
    with {year, ""} <- Integer.parse(y),
         {month, ""} <- Integer.parse(m),
         {day, ""} <- Integer.parse(d),
         {:ok, _} <- Date.new(year, month, day) do
      %__MODULE__{year: year, month: month, day: day, offset: offset}
    else
      _ -> nil
    end
  end

  defp parse_with_time(str, len, offset) do
    <<y::binary-size(4), m::binary-size(2), d::binary-size(2), rest::binary>> = str

    with {year, ""} <- Integer.parse(y),
         {month, ""} <- Integer.parse(m),
         {day, ""} <- Integer.parse(d),
         {:ok, _} <- Date.new(year, month, day) do
      parse_time_portion(rest, len - 8, %__MODULE__{
        year: year,
        month: month,
        day: day,
        offset: offset
      })
    else
      _ -> nil
    end
  end

  defp parse_time_portion(<<h::binary-size(2), rest::binary>>, _remaining, dtm) do
    case Integer.parse(h) do
      {hour, ""} when hour in 0..23 ->
        dtm = %{dtm | hour: hour}
        parse_minute_portion(rest, dtm)

      _ ->
        nil
    end
  end

  defp parse_time_portion(_, _, _), do: nil

  defp parse_minute_portion("", dtm), do: dtm

  defp parse_minute_portion(<<m::binary-size(2), rest::binary>>, dtm) do
    case Integer.parse(m) do
      {minute, ""} when minute in 0..59 ->
        dtm = %{dtm | minute: minute}
        parse_second_portion(rest, dtm)

      _ ->
        nil
    end
  end

  defp parse_minute_portion(_, _), do: nil

  defp parse_second_portion("", dtm), do: dtm

  defp parse_second_portion(<<s::binary-size(2), rest::binary>>, dtm) do
    case Integer.parse(s) do
      {second, ""} when second in 0..59 ->
        dtm = %{dtm | second: second}
        parse_fraction_portion(rest, dtm)

      _ ->
        nil
    end
  end

  defp parse_second_portion(_, _), do: nil

  defp parse_fraction_portion("", dtm), do: dtm

  defp parse_fraction_portion(<<".", fraction::binary>>, dtm) do
    if fraction != "" and Regex.match?(~r/\A\d{1,4}\z/, fraction) do
      %{dtm | fraction: fraction}
    else
      nil
    end
  end

  defp parse_fraction_portion(_, _), do: nil

  defp format_utc_offset(total_seconds) do
    sign = if total_seconds >= 0, do: "+", else: "-"
    abs_seconds = abs(total_seconds)
    hours = div(abs_seconds, 3600)
    minutes = div(rem(abs_seconds, 3600), 60)
    sign <> pad2(hours) <> pad2(minutes)
  end

  defp pad4(n), do: n |> Integer.to_string() |> String.pad_leading(4, "0")
  defp pad2(n), do: n |> Integer.to_string() |> String.pad_leading(2, "0")
end
