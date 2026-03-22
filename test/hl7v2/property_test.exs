defmodule HL7v2.PropertyTest do
  @moduledoc """
  Property-based tests for HL7v2 parse/encode round-trips.

  Complements the existing property tests in individual modules by testing
  cross-cutting round-trip properties: raw message parse/encode, typed message
  parse/encode, primitive types, composite types, segments, and MLLP framing.
  """
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias HL7v2.{Encoder, Parser, MLLP}
  alias HL7v2.Type.{ST, NM, SI, DT, DTM, HD, CX, CE, CWE, MSG, NR}
  alias HL7v2.Segment.MSA

  # ---------------------------------------------------------------------------
  # Generators
  # ---------------------------------------------------------------------------

  # Safe string: no HL7v2 delimiter characters (|^~\&) and no CR/LF
  defp gen_safe_string(opts \\ []) do
    min = Keyword.get(opts, :min_length, 1)
    max = Keyword.get(opts, :max_length, 20)

    gen all(
          chars <-
            list_of(
              member_of(Enum.concat([?A..?Z, ?a..?z, ?0..?9, [?_, ?-, ?., ?\s]])),
              min_length: min,
              max_length: max
            )
        ) do
      to_string(chars)
    end
  end

  # Non-empty safe string (no leading/trailing spaces to avoid trim issues)
  defp gen_identifier do
    gen all(
          chars <-
            list_of(
              member_of(Enum.concat([?A..?Z, ?a..?z, ?0..?9, [?_, ?-]])),
              min_length: 1,
              max_length: 15
            )
        ) do
      to_string(chars)
    end
  end

  defp gen_control_id do
    gen all(id <- string(?0..?9, min_length: 1, max_length: 12)) do
      id
    end
  end

  defp gen_segment do
    gen all(
          seg_id <- member_of(["PID", "PV1", "OBR", "OBX", "NTE", "NK1", "EVN", "AL1", "DG1"]),
          fields <- list_of(gen_safe_string(), min_length: 1, max_length: 8)
        ) do
      seg_id <> "|" <> Enum.join(fields, "|")
    end
  end

  defp gen_hl7_message do
    gen all(
          sending_app <- gen_identifier(),
          sending_fac <- gen_identifier(),
          control_id <- gen_control_id(),
          msg_code <- member_of(["ADT", "ORM", "ORU", "SIU", "ACK"]),
          trigger <- member_of(["A01", "A02", "A03", "A04", "A08", "O01", "R01"]),
          extra_segments <- list_of(gen_segment(), min_length: 0, max_length: 5)
        ) do
      msh =
        "MSH|^~\\&|#{sending_app}|#{sending_fac}||RCV||20260322120000||" <>
          "#{msg_code}^#{trigger}|#{control_id}|P|2.5.1"

      Enum.join([msh | extra_segments], "\r") <> "\r"
    end
  end

  # ---------------------------------------------------------------------------
  # 1. Raw message round-trip
  # ---------------------------------------------------------------------------

  describe "raw message round-trip" do
    property "parse(text) |> encode() reproduces normalized text" do
      check all(text <- gen_hl7_message(), max_runs: 100) do
        assert {:ok, raw} = Parser.parse(text)
        encoded = Encoder.encode(raw)
        assert {:ok, reparsed} = Parser.parse(encoded)
        assert reparsed.type == raw.type
        assert length(reparsed.segments) == length(raw.segments)

        assert Enum.map(reparsed.segments, &elem(&1, 0)) ==
                 Enum.map(raw.segments, &elem(&1, 0))
      end
    end

    property "parse(encode(parse(text))) == parse(text) (idempotent canonical form)" do
      check all(text <- gen_hl7_message(), max_runs: 100) do
        {:ok, first_parse} = Parser.parse(text)
        second_wire = Encoder.encode(first_parse)
        {:ok, second_parse} = Parser.parse(second_wire)
        third_wire = Encoder.encode(second_parse)

        assert third_wire == second_wire
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 2. Typed message round-trip
  # ---------------------------------------------------------------------------

  describe "typed message round-trip" do
    property "typed parse then encode preserves message identity" do
      check all(text <- gen_hl7_message(), max_runs: 50) do
        {:ok, raw} = Parser.parse(text)
        {:ok, typed} = Parser.parse(text, mode: :typed)

        re_encoded = HL7v2.encode(typed)
        {:ok, raw_again} = Parser.parse(re_encoded)

        assert raw_again.type == raw.type
        assert length(raw_again.segments) == length(raw.segments)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 3. Primitive type round-trips
  # ---------------------------------------------------------------------------

  describe "ST round-trip" do
    property "parse(encode(parse(s))) == parse(s)" do
      check all(s <- gen_safe_string()) do
        parsed = ST.parse(s)
        re = ST.parse(ST.encode(parsed))
        assert re == parsed
      end
    end
  end

  describe "NM round-trip" do
    property "valid decimal strings round-trip through parse/encode" do
      check all(
              sign <- member_of(["", "-"]),
              int_part <- integer(0..99999),
              dec_digits <- integer(0..4)
            ) do
        base = Integer.to_string(int_part)

        s =
          if dec_digits > 0 do
            # Build a fractional part that won't be all zeros after normalize
            frac = int_part |> Integer.to_string() |> String.slice(0, dec_digits)
            sign <> base <> "." <> frac
          else
            sign <> base
          end

        parsed = NM.parse(s)

        if parsed != nil do
          assert NM.parse(NM.encode(parsed)) == parsed
        end
      end
    end
  end

  describe "SI round-trip" do
    property "parse(encode(n)) == n for valid sequence IDs" do
      check all(n <- integer(0..9999)) do
        s = Integer.to_string(n)
        assert s |> SI.parse() |> SI.encode() |> SI.parse() == n
      end
    end
  end

  describe "DT round-trip" do
    property "full date (YYYYMMDD) round-trips" do
      check all(
              year <- integer(1900..2099),
              month <- integer(1..12),
              day <- integer(1..28)
            ) do
        s = pad4(year) <> pad2(month) <> pad2(day)
        parsed = DT.parse(s)
        assert parsed != nil
        assert DT.parse(DT.encode(parsed)) == parsed
      end
    end

    property "partial date (YYYYMM) round-trips" do
      check all(
              year <- integer(1900..2099),
              month <- integer(1..12)
            ) do
        s = pad4(year) <> pad2(month)
        parsed = DT.parse(s)
        assert parsed != nil
        assert DT.parse(DT.encode(parsed)) == parsed
      end
    end

    property "year-only (YYYY) round-trips" do
      check all(year <- integer(1..2099)) do
        s = pad4(year)
        parsed = DT.parse(s)
        assert parsed != nil
        assert DT.parse(DT.encode(parsed)) == parsed
      end
    end
  end

  describe "DTM round-trip" do
    property "full DTM (YYYYMMDDHHMMSS) round-trips" do
      check all(
              year <- integer(1900..2099),
              month <- integer(1..12),
              day <- integer(1..28),
              hour <- integer(0..23),
              minute <- integer(0..59),
              second <- integer(0..59)
            ) do
        s =
          pad4(year) <>
            pad2(month) <> pad2(day) <> pad2(hour) <> pad2(minute) <> pad2(second)

        parsed = DTM.parse(s)
        assert parsed != nil
        assert DTM.parse(DTM.encode(parsed)) == parsed
      end
    end

    property "DTM with offset round-trips" do
      check all(
              year <- integer(1900..2099),
              month <- integer(1..12),
              day <- integer(1..28),
              hour <- integer(0..23),
              minute <- integer(0..59),
              off_sign <- member_of(["+", "-"]),
              off_hours <- integer(0..12),
              off_mins <- member_of([0, 30])
            ) do
        base = pad4(year) <> pad2(month) <> pad2(day) <> pad2(hour) <> pad2(minute)
        offset = off_sign <> pad2(off_hours) <> pad2(off_mins)
        s = base <> offset

        parsed = DTM.parse(s)
        assert parsed != nil
        assert DTM.parse(DTM.encode(parsed)) == parsed
      end
    end

    property "partial DTM (YYYYMMDD) round-trips" do
      check all(
              year <- integer(1900..2099),
              month <- integer(1..12),
              day <- integer(1..28)
            ) do
        s = pad4(year) <> pad2(month) <> pad2(day)
        parsed = DTM.parse(s)
        assert parsed != nil
        assert DTM.parse(DTM.encode(parsed)) == parsed
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 4. Composite type round-trips
  # ---------------------------------------------------------------------------

  describe "HD round-trip" do
    property "parse(encode(hd)) produces same struct" do
      check all(
              ns <- gen_identifier(),
              uid <- gen_identifier()
            ) do
        hd_struct = HD.parse([ns, uid, "ISO"])
        re = HD.parse(HD.encode(hd_struct))
        assert re == hd_struct
      end
    end

    property "HD with only namespace round-trips" do
      check all(ns <- gen_identifier()) do
        hd_struct = HD.parse([ns])
        re = HD.parse(HD.encode(hd_struct))
        assert re == hd_struct
      end
    end
  end

  describe "CX round-trip" do
    property "parse(encode(cx)) preserves key fields" do
      check all(
              id <- gen_identifier(),
              type_code <- member_of(["MR", "PI", "SS", "AN", "VN"])
            ) do
        cx = CX.parse([id, "", "", "", type_code])
        encoded = CX.encode(cx)
        reparsed = CX.parse(encoded)
        assert reparsed.id == cx.id
        assert reparsed.identifier_type_code == cx.identifier_type_code
      end
    end

    property "CX with assigning authority round-trips" do
      check all(
              id <- gen_identifier(),
              authority_ns <- gen_identifier()
            ) do
        cx = CX.parse([id, "", "", authority_ns, "MR"])
        encoded = CX.encode(cx)
        reparsed = CX.parse(encoded)
        assert reparsed.id == cx.id
        assert reparsed.assigning_authority == cx.assigning_authority
      end
    end
  end

  describe "CE round-trip" do
    property "parse(encode(ce)) produces same struct" do
      check all(
              code <- gen_identifier(),
              text <- gen_safe_string(),
              system <- member_of(["I9C", "I10", "SCT", "LN", "L"])
            ) do
        ce = CE.parse([code, text, system])
        re = CE.parse(CE.encode(ce))
        assert re == ce
      end
    end
  end

  describe "CWE round-trip" do
    property "parse(encode(cwe)) produces same struct" do
      check all(
              code <- gen_identifier(),
              text <- gen_safe_string(),
              system <- member_of(["I10", "SCT", "LN", "99LOCAL"])
            ) do
        cwe = CWE.parse([code, text, system])
        re = CWE.parse(CWE.encode(cwe))
        assert re == cwe
      end
    end
  end

  describe "MSG round-trip" do
    property "parse(encode(msg)) produces same struct" do
      check all(
              code <- member_of(["ADT", "ORM", "ORU", "ACK", "SIU", "MDM"]),
              event <- member_of(["A01", "A02", "A04", "A08", "O01", "R01"]),
              structure <- member_of(["ADT_A01", "ORM_O01", "ORU_R01", "ACK"])
            ) do
        msg = MSG.parse([code, event, structure])
        re = MSG.parse(MSG.encode(msg))
        assert re == msg
      end
    end
  end

  describe "NR round-trip" do
    property "parse(encode(nr)) produces same struct" do
      check all(
              low <- integer(0..999),
              high <- integer(1000..9999)
            ) do
        nr = NR.parse([Integer.to_string(low), Integer.to_string(high)])
        re = NR.parse(NR.encode(nr))
        assert re == nr
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 5. Segment round-trip
  # ---------------------------------------------------------------------------

  describe "MSA segment round-trip" do
    property "parse(encode(msa)) preserves key fields" do
      check all(
              code <- member_of(["AA", "AE", "AR"]),
              ctrl_id <- gen_identifier()
            ) do
        msa = MSA.parse([code, ctrl_id])
        encoded = MSA.encode(msa)
        reparsed = MSA.parse(encoded)
        assert reparsed.acknowledgment_code == code
        assert reparsed.message_control_id == ctrl_id
      end
    end

    property "MSA with text message round-trips" do
      check all(
              code <- member_of(["AA", "AE", "AR"]),
              ctrl_id <- gen_identifier(),
              text <- gen_safe_string()
            ) do
        msa = MSA.parse([code, ctrl_id, text])
        encoded = MSA.encode(msa)
        reparsed = MSA.parse(encoded)
        assert reparsed.acknowledgment_code == code
        assert reparsed.message_control_id == ctrl_id
        assert reparsed.text_message == msa.text_message
      end
    end
  end

  # ---------------------------------------------------------------------------
  # 6. MLLP framing round-trip
  # ---------------------------------------------------------------------------

  describe "MLLP framing round-trip" do
    property "frame/unframe round-trips for safe payloads" do
      check all(msg <- gen_safe_string(min_length: 1, max_length: 500)) do
        framed = MLLP.frame(msg)
        assert {:ok, ^msg} = MLLP.unframe(framed)
      end
    end

    property "frame/unframe round-trips for arbitrary binaries without MLLP control chars" do
      check all(msg <- binary(min_length: 1, max_length: 500)) do
        # Skip binaries containing MLLP control characters
        unless String.contains?(msg, [<<0x0B>>, <<0x1C>>]) do
          framed = MLLP.frame(msg)
          assert {:ok, ^msg} = MLLP.unframe(framed)
        end
      end
    end

    property "extract_messages recovers all framed messages" do
      check all(
              messages <-
                list_of(gen_safe_string(min_length: 1, max_length: 100),
                  min_length: 1,
                  max_length: 5
                )
            ) do
        buffer =
          messages
          |> Enum.map(&MLLP.frame/1)
          |> Enum.join()

        {extracted, remaining} = MLLP.extract_messages(buffer)
        assert extracted == messages
        assert remaining == <<>>
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp pad4(n), do: n |> Integer.to_string() |> String.pad_leading(4, "0")
  defp pad2(n), do: n |> Integer.to_string() |> String.pad_leading(2, "0")
end
