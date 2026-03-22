defmodule HL7v2.Conformance.RoundTripTest do
  @moduledoc """
  Round-trip conformance tests using fixture messages.
  """
  use ExUnit.Case, async: true

  @fixture_dir Path.join([__DIR__, "..", "..", "fixtures", "conformance"])

  defp read_fixture(file) do
    @fixture_dir
    |> Path.join(file)
    |> File.read!()
    |> String.replace("\n", "\r")
  end

  defp assert_fixture_round_trip(file) do
    wire = read_fixture(file)

    # Raw parse
    assert {:ok, raw} = HL7v2.parse(wire)
    assert %HL7v2.RawMessage{} = raw

    # Typed parse
    assert {:ok, typed} = HL7v2.parse(wire, mode: :typed)
    assert %HL7v2.TypedMessage{} = typed

    # Raw round-trip is canonical
    re_encoded = HL7v2.encode(raw)
    {:ok, raw2} = HL7v2.parse(re_encoded)
    assert HL7v2.encode(raw2) == re_encoded

    # Typed round-trip preserves identity
    typed_encoded = HL7v2.encode(typed)
    {:ok, typed2} = HL7v2.parse(typed_encoded, mode: :typed)
    assert HL7v2.encode(typed2) == typed_encoded

    # Validation passes
    case HL7v2.validate(typed) do
      :ok -> :ok
      {:ok, _warnings} -> :ok
      {:error, errors} -> flunk("Validation failed: #{inspect(errors)}")
    end
  end

  describe "fixture round-trips" do
    test "ADT_A01" do
      assert_fixture_round_trip("adt_a01.hl7")
    end

    test "ORU_R01" do
      assert_fixture_round_trip("oru_r01.hl7")
    end

    test "ORM_O01" do
      assert_fixture_round_trip("orm_o01.hl7")
    end

    test "SIU_S12" do
      assert_fixture_round_trip("siu_s12.hl7")
    end

    test "ACK" do
      assert_fixture_round_trip("ack.hl7")
    end
  end

  describe "non-default delimiters" do
    test "custom subcomponent separator round-trips" do
      wire =
        "MSH|^~\\$|S|F||R|20260322||ADT^A01^ADT_A01|1|P|2.5.1\r" <>
          "EVN|A01\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r"

      {:ok, typed} = HL7v2.parse(wire, mode: :typed)
      re_encoded = HL7v2.encode(typed)
      assert String.starts_with?(re_encoded, "MSH|^~\\$|")
    end

    test "message with extra fields survives typed round-trip" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ADT^A01^ADT_A01|1|P|2.5.1\r" <>
          "EVN|A01\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|I\r" <>
          "OBX|1|NM|WBC||7.5|10*3/uL||||||||||||||||extra20|extra21|extra22\r"

      {:ok, typed} = HL7v2.parse(wire, mode: :typed)
      re_encoded = HL7v2.encode(typed)
      assert re_encoded =~ "extra20"
      assert re_encoded =~ "extra22"
    end
  end
end
