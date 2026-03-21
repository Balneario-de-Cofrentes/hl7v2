defmodule HL7v2.RawMessageTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias HL7v2.{Encoder, Parser, RawMessage, Separator}

  @fixtures_dir Path.expand("../fixtures", __DIR__)

  # Generators for property tests

  # Generate a safe string that does not contain HL7v2 delimiter characters.
  # This ensures generated field values won't be confused with structural separators.
  defp safe_string do
    gen all(
          str <-
            string(Enum.concat([?A..?Z, ?a..?z, ?0..?9, [?\s, ?., ?-, ?_, ?/, ?:, ?#, ?@, ?!]]),
              min_length: 0,
              max_length: 20
            )
        ) do
      str
    end
  end

  # Generate a segment name (3 uppercase chars)
  defp segment_name do
    gen all(
          a <- member_of(?A..?Z),
          b <- member_of(?A..?Z),
          c <- member_of(Enum.concat([?A..?Z, ?0..?9]))
        ) do
      <<a, b, c>>
    end
  end

  # Generate a simple field value (no components, no repetitions)
  defp simple_field do
    safe_string()
  end

  # Generate a component list (2-5 simple values)
  defp component_field do
    gen all(components <- list_of(safe_string(), min_length: 2, max_length: 5)) do
      components
    end
  end

  # Generate a field that is either simple or has components
  defp field_value do
    one_of([simple_field(), component_field()])
  end

  # Generate a non-MSH segment
  defp non_msh_segment do
    gen all(
          name <- segment_name(),
          name != "MSH",
          fields <- list_of(field_value(), min_length: 1, max_length: 8)
        ) do
      {name, fields}
    end
  end

  # Generate a message type tuple
  defp message_type do
    gen all(
          code <- member_of(["ADT", "ORM", "ORU", "ACK", "SIU", "MDM"]),
          event <- member_of(["A01", "A02", "A04", "A08", "O01", "R01", "S12"])
        ) do
      {code, event}
    end
  end

  # Generate a complete RawMessage
  defp raw_message do
    sep = Separator.default()

    gen all(
          {msg_code, trigger} <- message_type(),
          control_id <- string(?0..?9, min_length: 1, max_length: 10),
          extra_segments <- list_of(non_msh_segment(), min_length: 0, max_length: 4)
        ) do
      msh_fields = [
        "|",
        "^~\\&",
        "SEND",
        "FAC",
        "",
        "RCV",
        "20240101120000",
        "",
        [msg_code, trigger],
        control_id,
        "P",
        "2.5"
      ]

      %RawMessage{
        separators: sep,
        type: {msg_code, trigger},
        segments: [{"MSH", msh_fields} | extra_segments]
      }
    end
  end

  describe "property: encode then parse round-trip" do
    property "parse(encode(msg)) preserves message structure" do
      check all(msg <- raw_message(), max_runs: 100) do
        encoded = Encoder.encode(msg)
        assert {:ok, parsed} = Parser.parse(encoded)

        # Message type preserved
        assert parsed.type == msg.type

        # Same number of segments
        assert length(parsed.segments) == length(msg.segments)

        # Segment names preserved
        assert Enum.map(parsed.segments, &elem(&1, 0)) ==
                 Enum.map(msg.segments, &elem(&1, 0))
      end
    end

    property "encode(parse(encode(msg))) == encode(msg) (canonical form)" do
      check all(msg <- raw_message(), max_runs: 100) do
        first_encode = Encoder.encode(msg)
        {:ok, parsed} = Parser.parse(first_encode)
        second_encode = Encoder.encode(parsed)

        assert second_encode == first_encode
      end
    end
  end

  describe "property: parse then encode round-trip on fixture files" do
    for fixture <- ~w(adt_a01.hl7 adt_a08.hl7 orm_o01.hl7 oru_r01.hl7 adt_a04_subcomponents.hl7) do
      @fixture fixture
      test "round-trip for #{fixture}" do
        text = File.read!(Path.join(@fixtures_dir, @fixture))
        # Normalize to CR endings for comparison (fixtures may use LF)
        normalized = text |> String.replace("\r\n", "\r") |> String.replace("\n", "\r")
        # Ensure trailing CR
        normalized =
          if String.ends_with?(normalized, "\r"), do: normalized, else: normalized <> "\r"

        assert {:ok, parsed} = Parser.parse(normalized)
        encoded = Encoder.encode(parsed)

        assert encoded == normalized
      end
    end
  end

  describe "struct" do
    test "has correct default fields" do
      raw = %RawMessage{}
      assert raw.separators == nil
      assert raw.type == nil
      assert raw.segments == nil
    end

    test "can be constructed with all fields" do
      raw = %RawMessage{
        separators: Separator.default(),
        type: {"ADT", "A01"},
        segments: [{"MSH", ["|", "^~\\&"]}]
      }

      assert raw.type == {"ADT", "A01"}
      assert length(raw.segments) == 1
    end
  end
end
