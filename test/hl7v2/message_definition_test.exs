defmodule HL7v2.MessageDefinitionTest do
  use ExUnit.Case, async: true

  alias HL7v2.MessageDefinition

  describe "canonical_structure/2" do
    test "maps aliased ADT trigger events" do
      assert MessageDefinition.canonical_structure("ADT", "A04") == "ADT_A01"
      assert MessageDefinition.canonical_structure("ADT", "A08") == "ADT_A01"
      assert MessageDefinition.canonical_structure("ADT", "A13") == "ADT_A01"
      assert MessageDefinition.canonical_structure("ADT", "A28") == "ADT_A05"
      assert MessageDefinition.canonical_structure("ADT", "A12") == "ADT_A12"
      assert MessageDefinition.canonical_structure("ADT", "A40") == "ADT_A39"
    end

    test "maps aliased SIU trigger events" do
      for event <- ~w(S13 S14 S15 S16 S17 S18 S19 S20 S21 S22 S23 S24 S26) do
        assert MessageDefinition.canonical_structure("SIU", event) == "SIU_S12"
      end
    end

    test "falls back to CODE_EVENT for unmapped events" do
      assert MessageDefinition.canonical_structure("ADT", "A01") == "ADT_A01"
      assert MessageDefinition.canonical_structure("ORU", "R01") == "ORU_R01"
      assert MessageDefinition.canonical_structure("ZZZ", "Z01") == "ZZZ_Z01"
    end
  end

  describe "validate_structure/2" do
    test "passes for valid ADT_A01" do
      assert :ok = MessageDefinition.validate_structure("ADT_A01", ["MSH", "EVN", "PID", "PV1"])
    end

    test "detects missing required segments" do
      assert {:error, errors} = MessageDefinition.validate_structure("ADT_A01", ["MSH"])
      messages = Enum.map(errors, & &1.message)
      assert Enum.any?(messages, &(&1 =~ "EVN"))
      assert Enum.any?(messages, &(&1 =~ "PID"))
    end

    test "returns warning for unknown structures" do
      assert {:error, [warning]} = MessageDefinition.validate_structure("UNKNOWN_X99", [])
      assert warning.level == :warning
      assert warning.message =~ "no validation definition"
    end

    test "passes for nil/empty structure" do
      assert :ok = MessageDefinition.validate_structure(nil, [])
      assert :ok = MessageDefinition.validate_structure("", [])
    end

    test "validates ORU_R01" do
      assert :ok = MessageDefinition.validate_structure("ORU_R01", ["MSH", "OBR"])
      assert {:error, _} = MessageDefinition.validate_structure("ORU_R01", ["MSH"])
    end

    test "validates ORM_O01" do
      assert :ok = MessageDefinition.validate_structure("ORM_O01", ["MSH", "ORC"])
      assert {:error, _} = MessageDefinition.validate_structure("ORM_O01", ["MSH"])
    end

    test "validates SIU_S12 requires RGS" do
      assert :ok = MessageDefinition.validate_structure("SIU_S12", ["MSH", "SCH", "RGS"])
      assert {:error, errors} = MessageDefinition.validate_structure("SIU_S12", ["MSH", "SCH"])
      assert Enum.any?(errors, &(&1.message =~ "RGS"))
    end

    test "validates ACK" do
      assert :ok = MessageDefinition.validate_structure("ACK", ["MSH", "MSA"])
      assert {:error, _} = MessageDefinition.validate_structure("ACK", ["MSH"])
    end

    test "validates ADT_A39 requires MRG" do
      assert :ok = MessageDefinition.validate_structure("ADT_A39", ["MSH", "EVN", "PID", "MRG"])
      assert {:error, errors} = MessageDefinition.validate_structure("ADT_A39", ["MSH", "EVN", "PID"])
      assert Enum.any?(errors, &(&1.message =~ "MRG"))
    end
  end
end
