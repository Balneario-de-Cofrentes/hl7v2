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

    test "ADT_A03 (discharge patient)" do
      assert_fixture_round_trip("adt_a03.hl7")
    end

    test "ADT_A06 (change outpatient to inpatient)" do
      assert_fixture_round_trip("adt_a06.hl7")
    end

    test "ADT_A09 (patient departing tracking)" do
      assert_fixture_round_trip("adt_a09.hl7")
    end

    test "ADT_A16 (pending discharge)" do
      assert_fixture_round_trip("adt_a16.hl7")
    end

    test "ADT_A18 (merge patient information)" do
      assert_fixture_round_trip("adt_a18.hl7")
    end

    test "ADT_A38 (cancel pre-admit)" do
      assert_fixture_round_trip("adt_a38.hl7")
    end

    test "ADT_A45 (move visit info — visit number)" do
      assert_fixture_round_trip("adt_a45.hl7")
    end

    test "ADT_A50 (change visit number)" do
      assert_fixture_round_trip("adt_a50.hl7")
    end

    test "ADT_A60 (update allergy information)" do
      assert_fixture_round_trip("adt_a60.hl7")
    end

    test "BAR_P02 (purge patient accounts)" do
      assert_fixture_round_trip("bar_p02.hl7")
    end

    test "DOC_T12 (document response)" do
      assert_fixture_round_trip("doc_t12.hl7")
    end

    test "MDM_T01 (original document notification)" do
      assert_fixture_round_trip("mdm_t01.hl7")
    end

    test "MFK_M01 (master file application ack)" do
      assert_fixture_round_trip("mfk_m01.hl7")
    end

    test "QRY_A19 (patient demographics query)" do
      assert_fixture_round_trip("qry_a19.hl7")
    end

    test "SSU_U03 (specimen status update)" do
      assert_fixture_round_trip("ssu_u03.hl7")
    end

    test "ADT_A12 (cancel transfer)" do
      assert_fixture_round_trip("adt_a12.hl7")
    end

    test "ADT_A15 (pending transfer)" do
      assert_fixture_round_trip("adt_a15.hl7")
    end

    test "ADT_A20 (bed status update)" do
      assert_fixture_round_trip("adt_a20.hl7")
    end

    test "ADT_A21 (patient leave of absence)" do
      assert_fixture_round_trip("adt_a21.hl7")
    end

    test "ADT_A24 (link patient information)" do
      assert_fixture_round_trip("adt_a24.hl7")
    end

    test "ADT_A30 (merge person information)" do
      assert_fixture_round_trip("adt_a30.hl7")
    end

    test "ADT_A37 (unlink patient information)" do
      assert_fixture_round_trip("adt_a37.hl7")
    end

    test "ADT_A39 (merge patient — patient ID)" do
      assert_fixture_round_trip("adt_a39.hl7")
    end

    test "ADT_A43 (move patient info — identifier list)" do
      assert_fixture_round_trip("adt_a43.hl7")
    end

    test "ADT_A54 (change attending doctor)" do
      assert_fixture_round_trip("adt_a54.hl7")
    end

    test "ADT_A61 (change consulting doctor)" do
      assert_fixture_round_trip("adt_a61.hl7")
    end

    test "DFT_P11 (post detail financial transaction — new)" do
      assert_fixture_round_trip("dft_p11.hl7")
    end

    test "QBP_Q11 (segment pattern query)" do
      assert_fixture_round_trip("qbp_q11.hl7")
    end

    test "QBP_Q13 (tabular query)" do
      assert_fixture_round_trip("qbp_q13.hl7")
    end

    test "QBP_Q15 (display-based query)" do
      assert_fixture_round_trip("qbp_q15.hl7")
    end

    test "QBP_Z73 (pending events query)" do
      assert_fixture_round_trip("qbp_z73.hl7")
    end

    test "RSP_K11 (segment pattern response)" do
      assert_fixture_round_trip("rsp_k11.hl7")
    end

    test "RSP_K13 (tabular response)" do
      assert_fixture_round_trip("rsp_k13.hl7")
    end

    test "RSP_K15 (display-based response)" do
      assert_fixture_round_trip("rsp_k15.hl7")
    end

    test "RSP_K23 (allocate identifiers response)" do
      assert_fixture_round_trip("rsp_k23.hl7")
    end

    test "RSP_K25 (personnel information response)" do
      assert_fixture_round_trip("rsp_k25.hl7")
    end

    test "RSP_K31 (pharmacy dispense response)" do
      assert_fixture_round_trip("rsp_k31.hl7")
    end

    test "RSP_Q11 (segment pattern response — query Q11)" do
      assert_fixture_round_trip("rsp_q11.hl7")
    end

    test "RSP_Z82 (dispense history response)" do
      assert_fixture_round_trip("rsp_z82.hl7")
    end

    test "RSP_Z86 (pharmacy information comprehensive response)" do
      assert_fixture_round_trip("rsp_z86.hl7")
    end

    test "RSP_Z88 (pharmacy encoded order response)" do
      assert_fixture_round_trip("rsp_z88.hl7")
    end

    test "RSP_Z90 (lab results history response)" do
      assert_fixture_round_trip("rsp_z90.hl7")
    end

    test "MFN_M03 (test/observation master file)" do
      assert_fixture_round_trip("mfn_m03.hl7")
    end

    test "MFN_M04 (charge description master)" do
      assert_fixture_round_trip("mfn_m04.hl7")
    end

    test "MFN_M05 (patient location master)" do
      assert_fixture_round_trip("mfn_m05.hl7")
    end

    test "MFN_M06 (clinical study with phases)" do
      assert_fixture_round_trip("mfn_m06.hl7")
    end

    test "MFN_M07 (clinical study schedule)" do
      assert_fixture_round_trip("mfn_m07.hl7")
    end

    test "MFN_M08 (test/observation numeric)" do
      assert_fixture_round_trip("mfn_m08.hl7")
    end

    test "MFN_M09 (test/observation categorical)" do
      assert_fixture_round_trip("mfn_m09.hl7")
    end

    test "MFN_M10 (test/observation batteries)" do
      assert_fixture_round_trip("mfn_m10.hl7")
    end

    test "MFN_M11 (test/calculated observations)" do
      assert_fixture_round_trip("mfn_m11.hl7")
    end

    test "MFN_M12 (master file charge override)" do
      assert_fixture_round_trip("mfn_m12.hl7")
    end

    test "MFN_M13 (master file inventory item)" do
      assert_fixture_round_trip("mfn_m13.hl7")
    end

    test "MFN_M15 (inventory item enhanced)" do
      assert_fixture_round_trip("mfn_m15.hl7")
    end

    test "BAR_P10 (transmit ambulance billing)" do
      assert_fixture_round_trip("bar_p10.hl7")
    end

    test "BAR_P12 (update diagnosis/procedure)" do
      assert_fixture_round_trip("bar_p12.hl7")
    end

    test "OML_O33 (lab order — multiple orders per specimen)" do
      assert_fixture_round_trip("oml_o33.hl7")
    end

    test "OML_O35 (lab order — multiple orders per container)" do
      assert_fixture_round_trip("oml_o35.hl7")
    end

    test "OML_O39 (specimen shipment order)" do
      assert_fixture_round_trip("oml_o39.hl7")
    end

    test "PMU_B03 (delete personnel record)" do
      assert_fixture_round_trip("pmu_b03.hl7")
    end

    test "PMU_B04 (active practicing person)" do
      assert_fixture_round_trip("pmu_b04.hl7")
    end

    test "PMU_B07 (grant certificate/permission)" do
      assert_fixture_round_trip("pmu_b07.hl7")
    end

    test "PMU_B08 (revoke certificate/permission)" do
      assert_fixture_round_trip("pmu_b08.hl7")
    end

    test "OMB_O27 (blood product order)" do
      assert_fixture_round_trip("omb_o27.hl7")
    end

    test "OMD_O03 (dietary order)" do
      assert_fixture_round_trip("omd_o03.hl7")
    end

    test "OMG_O19 (general clinical order)" do
      assert_fixture_round_trip("omg_o19.hl7")
    end

    test "OMN_O07 (non-stock requisition)" do
      assert_fixture_round_trip("omn_o07.hl7")
    end

    test "OMP_O09 (pharmacy/treatment order)" do
      assert_fixture_round_trip("omp_o09.hl7")
    end

    test "ORB_O28 (blood product order acknowledgment)" do
      assert_fixture_round_trip("orb_o28.hl7")
    end

    test "ORD_O04 (dietary order acknowledgment)" do
      assert_fixture_round_trip("ord_o04.hl7")
    end

    test "ORF_R04 (observation response)" do
      assert_fixture_round_trip("orf_r04.hl7")
    end

    test "ORG_O20 (general clinical order response)" do
      assert_fixture_round_trip("org_o20.hl7")
    end

    test "ORL_O22 (general laboratory order response)" do
      assert_fixture_round_trip("orl_o22.hl7")
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

  # Strict-clean fixture corpus: every wire fixture on disk must pass strict
  # validation with zero warnings. This is stronger than round-trip fidelity
  # (it exercises structural + field + conditional checks end-to-end), but its
  # breadth is bounded by the corpus — currently far narrower than the full
  # 186 official v2.5.1 structures. See `mix hl7v2.coverage` for exact breadth.
  describe "strict-clean fixture corpus" do
    for file <- Path.wildcard(Path.join(@fixture_dir, "*.hl7")) do
      name = Path.basename(file, ".hl7")

      test "#{name} passes strict validation" do
        assert_fixture_strict_clean(unquote(name) <> ".hl7")
      end
    end
  end

  # Adjacent-version tolerance: same ADT^A01 wire structure at v2.3, v2.4,
  # v2.6, v2.7, v2.8. Verifies the parser/encoder round-trip across non-2.5.1
  # version declarations in MSH-12.
  describe "adjacent-version tolerance" do
    for version <- ~w(2.3 2.4 2.6 2.7 2.8) do
      fixture = "adt_a01_v#{String.replace(version, ".", "")}.hl7"

      test "ADT_A01 at v#{version} round-trips" do
        wire = read_fixture(unquote(fixture))

        {:ok, raw} = HL7v2.parse(wire)
        assert HL7v2.encode(raw) |> byte_size() > 0

        {:ok, typed} = HL7v2.parse(wire, mode: :typed)
        msh = hd(typed.segments)
        assert msh.version_id.version_id == unquote(version)

        typed_encoded = HL7v2.encode(typed)
        {:ok, typed2} = HL7v2.parse(typed_encoded, mode: :typed)
        assert HL7v2.encode(typed2) == typed_encoded
      end
    end
  end
end
