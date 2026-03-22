defmodule HL7v2.Validation.StructuralTest do
  use ExUnit.Case, async: true

  alias HL7v2.Validation.Structural
  alias HL7v2.Standard.MessageStructure

  # Helper to get errors only
  defp errors_only(results), do: Enum.filter(results, &(&1.level == :error))
  defp warnings_only(results), do: Enum.filter(results, &(&1.level == :warning))
  defp messages(results), do: Enum.map(results, & &1.message)

  describe "ADT_A01 structural validation" do
    setup do
      %{structure: MessageStructure.get("ADT_A01")}
    end

    test "valid ADT_A01 passes", %{structure: s} do
      ids = ["MSH", "EVN", "PID", "PV1"]
      assert Structural.validate(s, ids) == []
    end

    test "valid ADT_A01 with optional segments passes", %{structure: s} do
      ids = ["MSH", "EVN", "PID", "NK1", "PV1", "PV2", "AL1", "DG1", "GT1", "IN1", "NTE"]
      assert Structural.validate(s, ids) == []
    end

    test "missing required EVN is an error", %{structure: s} do
      ids = ["MSH", "PID", "PV1"]
      errors = errors_only(Structural.validate(s, ids))
      assert length(errors) > 0
      assert Enum.any?(messages(errors), &(&1 =~ "EVN"))
    end

    test "missing required PID is an error", %{structure: s} do
      ids = ["MSH", "EVN", "PV1"]
      errors = errors_only(Structural.validate(s, ids))
      assert Enum.any?(messages(errors), &(&1 =~ "PID"))
    end

    test "wrong order: PV1 before EVN is a warning in lenient mode", %{structure: s} do
      ids = ["MSH", "PID", "PV1", "EVN"]
      warnings = warnings_only(Structural.validate(s, ids))
      assert length(warnings) > 0
      assert Enum.any?(messages(warnings), &(&1 =~ "order" or &1 =~ "before" or &1 =~ "after"))
    end

    test "wrong order: PV1 before EVN is an error in strict mode", %{structure: s} do
      ids = ["MSH", "PID", "PV1", "EVN"]
      errors = errors_only(Structural.validate(s, ids, mode: :strict))
      assert length(errors) > 0
    end

    test "duplicate non-repeating PV1 is flagged", %{structure: s} do
      ids = ["MSH", "EVN", "PID", "PV1", "PV1"]
      results = Structural.validate(s, ids)
      assert Enum.any?(messages(results), &(&1 =~ "PV1" and &1 =~ "not repeating"))
    end

    test "repeated NK1 is allowed (repeating segment)", %{structure: s} do
      ids = ["MSH", "EVN", "PID", "NK1", "NK1", "NK1", "PV1"]
      results = Structural.validate(s, ids)
      refute Enum.any?(messages(results), &(&1 =~ "NK1" and &1 =~ "not repeating"))
    end

    test "unknown Z-segment is ignored", %{structure: s} do
      ids = ["MSH", "EVN", "PID", "PV1", "ZPD"]
      assert Structural.validate(s, ids) == []
    end
  end

  describe "ORU_R01 structural validation" do
    setup do
      %{structure: MessageStructure.get("ORU_R01")}
    end

    test "valid ORU_R01 passes", %{structure: s} do
      ids = ["MSH", "PID", "OBR", "OBX"]
      assert Structural.validate(s, ids) == []
    end

    test "ORU_R01 without PID passes (patient group optional)", %{structure: s} do
      ids = ["MSH", "OBR", "OBX"]
      assert Structural.validate(s, ids) == []
    end

    test "ORU_R01 without OBR fails (required)", %{structure: s} do
      ids = ["MSH", "PID", "OBX"]
      errors = errors_only(Structural.validate(s, ids))
      assert Enum.any?(messages(errors), &(&1 =~ "OBR"))
    end

    test "OBX before OBR is a warning in lenient mode", %{structure: s} do
      ids = ["MSH", "OBX", "OBR"]
      warnings = warnings_only(Structural.validate(s, ids))
      assert length(warnings) > 0
    end

    test "OBX before OBR is an error in strict mode", %{structure: s} do
      ids = ["MSH", "OBX", "OBR"]
      errors = errors_only(Structural.validate(s, ids, mode: :strict))
      assert length(errors) > 0
    end

    test "multiple OBR groups pass (repeating ORDER_OBSERVATION)", %{structure: s} do
      ids = ["MSH", "PID", "OBR", "OBX", "OBX", "OBR", "OBX"]
      errors = errors_only(Structural.validate(s, ids))
      assert errors == []
    end
  end

  describe "ORM_O01 structural validation" do
    setup do
      %{structure: MessageStructure.get("ORM_O01")}
    end

    test "valid ORM_O01 passes", %{structure: s} do
      ids = ["MSH", "PID", "ORC", "OBR"]
      assert Structural.validate(s, ids) == []
    end

    test "ORM without PID passes (patient group optional)", %{structure: s} do
      ids = ["MSH", "ORC"]
      assert Structural.validate(s, ids) == []
    end

    test "ORM without ORC fails", %{structure: s} do
      ids = ["MSH", "PID"]
      errors = errors_only(Structural.validate(s, ids))
      assert Enum.any?(messages(errors), &(&1 =~ "ORC"))
    end
  end

  describe "SIU_S12 structural validation" do
    setup do
      %{structure: MessageStructure.get("SIU_S12")}
    end

    test "valid SIU_S12 passes", %{structure: s} do
      ids = ["MSH", "SCH", "PID", "RGS", "AIS"]
      assert Structural.validate(s, ids) == []
    end

    test "SIU without RGS fails (required group anchor)", %{structure: s} do
      ids = ["MSH", "SCH", "PID", "AIS"]
      errors = errors_only(Structural.validate(s, ids))
      assert Enum.any?(messages(errors), &(&1 =~ "RGS"))
    end

    test "SIU without PID passes (patient group optional)", %{structure: s} do
      ids = ["MSH", "SCH", "RGS", "AIS"]
      assert Structural.validate(s, ids) == []
    end
  end

  describe "ACK structural validation" do
    setup do
      %{structure: MessageStructure.get("ACK")}
    end

    test "valid ACK passes", %{structure: s} do
      ids = ["MSH", "MSA"]
      assert Structural.validate(s, ids) == []
    end

    test "ACK without MSA fails", %{structure: s} do
      ids = ["MSH"]
      errors = errors_only(Structural.validate(s, ids))
      assert Enum.any?(messages(errors), &(&1 =~ "MSA"))
    end

    test "ACK with ERR passes (optional)", %{structure: s} do
      ids = ["MSH", "MSA", "ERR"]
      assert Structural.validate(s, ids) == []
    end
  end

  describe "ADT_A39 structural validation" do
    setup do
      %{structure: MessageStructure.get("ADT_A39")}
    end

    test "valid A39 with PID+MRG passes", %{structure: s} do
      ids = ["MSH", "EVN", "PID", "MRG"]
      assert Structural.validate(s, ids) == []
    end

    test "A39 without MRG fails", %{structure: s} do
      ids = ["MSH", "EVN", "PID"]
      errors = errors_only(Structural.validate(s, ids))
      assert Enum.any?(messages(errors), &(&1 =~ "MRG"))
    end
  end

  describe "integration with HL7v2.validate/1" do
    test "out-of-order segments produce warnings" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ORU^R01^ORU_R01|1|P|2.5.1\r" <>
          "OBX|1|NM|WBC||7.5\r" <>
          "OBR|1||ORD1|CBC^Complete Blood Count\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)

      case HL7v2.validate(msg) do
        {:ok, warnings} ->
          assert Enum.any?(warnings, &(&1.message =~ "before" or &1.message =~ "after"))

        {:error, errors} ->
          # May have both errors and warnings
          assert Enum.any?(errors, &(&1.message =~ "before" or &1.message =~ "after"))

        :ok ->
          flunk("Expected ordering warning for OBX before OBR")
      end
    end

    test "valid message returns :ok" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||ACK^A01^ACK|1|P|2.5.1\r" <>
          "MSA|AA|MSG001\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      assert :ok = HL7v2.validate(msg)
    end
  end
end
