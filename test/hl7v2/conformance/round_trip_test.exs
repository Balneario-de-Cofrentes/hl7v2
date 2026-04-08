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

    # Typed canonicalization is idempotent (trailing empties are trimmed)
    typed_encoded = HL7v2.encode(typed)
    {:ok, typed2} = HL7v2.parse(typed_encoded, mode: :typed)
    assert HL7v2.encode(typed2) == typed_encoded

    # Lenient validation passes (warnings allowed)
    case HL7v2.validate(typed) do
      :ok -> :ok
      {:ok, _warnings} -> :ok
      {:error, errors} -> flunk("Validation failed: #{inspect(errors)}")
    end
  end

  defp assert_fixture_strict_clean(file) do
    wire = read_fixture(file)
    assert {:ok, typed} = HL7v2.parse(wire, mode: :typed)

    case HL7v2.validate(typed, mode: :strict) do
      :ok ->
        :ok

      {:ok, warnings} ->
        flunk("Strict validation produced warnings: #{inspect(Enum.map(warnings, & &1.message))}")

      {:error, errors} ->
        flunk("Strict validation failed: #{inspect(Enum.map(errors, & &1.message))}")
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

    test "BAR_P01 (billing)" do
      assert_fixture_round_trip("bar_p01.hl7")
    end

    test "DFT_P03 (financial transaction)" do
      assert_fixture_round_trip("dft_p03.hl7")
    end

    test "RDE_O11 (pharmacy encoded order)" do
      assert_fixture_round_trip("rde_o11.hl7")
    end

    test "MDM_T02 (medical document)" do
      assert_fixture_round_trip("mdm_t02.hl7")
    end

    test "MFN_M02 (master file - staff)" do
      assert_fixture_round_trip("mfn_m02.hl7")
    end

    test "VXU_V04 (vaccination)" do
      assert_fixture_round_trip("vxu_v04.hl7")
    end

    test "REF_I12 (referral)" do
      assert_fixture_round_trip("ref_i12.hl7")
    end

    test "QBP_Q21 (query by parameter)" do
      assert_fixture_round_trip("qbp_q21.hl7")
    end

    test "RSP_K21 (query response)" do
      assert_fixture_round_trip("rsp_k21.hl7")
    end

    test "RGV_O15 (pharmacy give)" do
      assert_fixture_round_trip("rgv_o15.hl7")
    end

    test "PPR_PC1 (patient problem)" do
      assert_fixture_round_trip("ppr_pc1.hl7")
    end

    test "SRM_S01 (scheduling request)" do
      assert_fixture_round_trip("srm_s01.hl7")
    end

    test "PMU_B01 (personnel management)" do
      assert_fixture_round_trip("pmu_b01.hl7")
    end

    test "ADT_A08 (update patient)" do
      assert_fixture_round_trip("adt_a08.hl7")
    end

    test "ADT_A04 (register patient)" do
      assert_fixture_round_trip("adt_a04.hl7")
    end

    test "ADT_A02 (transfer patient)" do
      assert_fixture_round_trip("adt_a02.hl7")
    end

    test "ORU_R30 (unsolicited point-of-care observation)" do
      assert_fixture_round_trip("oru_r30.hl7")
    end

    test "OML_O21 (laboratory order)" do
      assert_fixture_round_trip("oml_o21.hl7")
    end

    test "OMI_O23 (imaging order)" do
      assert_fixture_round_trip("omi_o23.hl7")
    end

    test "OMS_O05 (stock requisition order)" do
      assert_fixture_round_trip("oms_o05.hl7")
    end

    test "RDS_O13 (pharmacy dispense)" do
      assert_fixture_round_trip("rds_o13.hl7")
    end

    test "RAS_O17 (pharmacy administration)" do
      assert_fixture_round_trip("ras_o17.hl7")
    end

    test "ORU_R01 multi-OBR (multiple order groups)" do
      assert_fixture_round_trip("oru_r01_multi.hl7")
    end

    test "ADT_A17 (swap patients)" do
      assert_fixture_round_trip("adt_a17.hl7")
    end

    test "BPS_O29 (blood product order)" do
      assert_fixture_round_trip("bps_o29.hl7")
    end

    test "MFN_M01 (master file notification)" do
      assert_fixture_round_trip("mfn_m01.hl7")
    end

    test "SIU_S14 (modify appointment)" do
      assert_fixture_round_trip("siu_s14.hl7")
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

  # Strict-clean suite: every fixture must pass strict validation with zero
  # warnings. This is the real conformance proof — not just round-trip fidelity.
  describe "strict-clean conformance" do
    for file <- Path.wildcard(Path.join(@fixture_dir, "*.hl7")) do
      name = Path.basename(file, ".hl7")

      test "#{name} passes strict validation" do
        assert_fixture_strict_clean(unquote(name) <> ".hl7")
      end
    end
  end
end
