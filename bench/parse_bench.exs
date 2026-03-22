defmodule HL7v2.Bench do
  @moduledoc false

  # Realistic ADT^A01 admission message with 10 segments, repeating fields,
  # sub-components, coded elements, and NTE notes — representative of
  # production traffic from an Epic-class HIS.
  @adt_a01 (
    "MSH|^~\\&|EPIC|HOSP|PACS|IMG|20260322143022||ADT^A01^ADT_A01|MSG00001|P|2.5.1|||AL|NE\r" <>
    "EVN|A01|20260322143022\r" <>
    "PID|1||MRN12345^^^HOSP^MR~SSN123^^^SSA^SS||Smith^John^Q^Jr^Dr||19800515|M||2106-3^White^CDCREC|123 Main St^^Springfield^IL^62704^USA^H||^PRN^PH^^1^217^5551234|^WPN^PH^^1^312^5555678|EN^English^HL70296|M^Married^HL70002|||ACC12345^^^HOSP^AN\r" <>
    "PV1|1|I|W^389^1^HOSP^^N|||12345^Jones^Robert^^^Dr^MD|||SUR||||A|||12345^Jones^Robert^^^Dr^MD|IP|VN001^^^HOSP^VN\r" <>
    "NK1|1|Smith^Jane||123 Main St^^Springfield^IL^62704^USA^H|^PRN^PH^^1^217^5559876\r" <>
    "AL1|1|DA|PCN^Penicillin^LN||Rash\r" <>
    "DG1|1||J06.9^Upper respiratory infection^I10|||A\r" <>
    "OBX|1|NM|8310-5^Body Temperature^LN||37.2|Cel^Celsius^UCUM|36.1-37.8||||F\r" <>
    "NTE|1||Patient reports mild fever for 2 days\r" <>
    "NTE|2||No known drug allergies except penicillin\r"
  )

  @target_us 1_000_000

  def run do
    IO.puts("HL7v2 Benchmark Results")
    IO.puts("=======================")
    IO.puts("")
    IO.puts("Message: ADT^A01 (10 segments, #{byte_size(@adt_a01)} bytes)")
    IO.puts("Duration: 1 second per benchmark")
    IO.puts("")

    # Warmup — ensure all code paths are JIT-compiled
    {:ok, raw} = HL7v2.parse(@adt_a01)
    {:ok, typed} = HL7v2.parse(@adt_a01, mode: :typed)
    _ = HL7v2.encode(raw)
    _ = HL7v2.encode(typed)
    _ = HL7v2.MLLP.frame(@adt_a01)

    bench("Raw Parse", fn -> HL7v2.parse(@adt_a01) end)
    bench("Typed Parse", fn -> HL7v2.parse(@adt_a01, mode: :typed) end)
    bench("Encode (raw)", fn -> HL7v2.encode(raw) end)
    bench("Encode (typed)", fn -> HL7v2.encode(typed) end)
    bench("Round-trip", fn ->
      {:ok, r} = HL7v2.parse(@adt_a01)
      HL7v2.encode(r)
    end)
    bench("MLLP Frame", fn ->
      framed = HL7v2.MLLP.frame(@adt_a01)
      HL7v2.MLLP.unframe(framed)
    end)
    bench("Builder", fn ->
      HL7v2.Message.new("ADT", "A01",
        sending_application: "BENCH",
        message_control_id: "B001"
      )
      |> HL7v2.Message.add_segment(%HL7v2.Segment.PID{
        set_id: 1,
        patient_identifier_list: [%HL7v2.Type.CX{id: "12345"}],
        patient_name: [
          %HL7v2.Type.XPN{
            family_name: %HL7v2.Type.FN{surname: "Smith"},
            given_name: "John"
          }
        ]
      })
      |> HL7v2.Message.encode()
    end)

    IO.puts("")
  end

  defp bench(name, fun) do
    {count, elapsed_us} = run_for(fun, @target_us)
    per_msg_us = elapsed_us / count
    msgs_per_sec = round(1_000_000 / per_msg_us)

    label = String.pad_trailing(name <> ":", 18)
    rate = msgs_per_sec |> format_number() |> String.pad_leading(9)
    IO.puts("#{label}#{rate} msgs/sec  (#{Float.round(per_msg_us, 2)} µs/msg)")
  end

  defp run_for(fun, target_us) do
    start = System.monotonic_time(:microsecond)
    do_run(fun, start, target_us, 0)
  end

  defp do_run(fun, start, target_us, count) do
    fun.()
    elapsed = System.monotonic_time(:microsecond) - start

    if elapsed >= target_us do
      {count + 1, elapsed}
    else
      do_run(fun, start, target_us, count + 1)
    end
  end

  defp format_number(n) when n >= 1_000_000 do
    m = div(n, 1_000_000)
    k = div(rem(n, 1_000_000), 1_000)
    r = rem(n, 1_000)
    "#{m},#{pad3(k)},#{pad3(r)}"
  end

  defp format_number(n) when n >= 1_000 do
    k = div(n, 1_000)
    r = rem(n, 1_000)
    "#{k},#{pad3(r)}"
  end

  defp format_number(n), do: Integer.to_string(n)

  defp pad3(n), do: n |> Integer.to_string() |> String.pad_leading(3, "0")
end

HL7v2.Bench.run()
