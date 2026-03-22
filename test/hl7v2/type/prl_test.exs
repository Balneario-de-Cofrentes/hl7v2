defmodule HL7v2.Type.PRLTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.PRL
  alias HL7v2.Type.CE

  doctest PRL

  describe "parse/1" do
    test "parses all three components" do
      result = PRL.parse(["85025&CBC&CPT4", "1", "Hemoglobin"])

      assert %CE{identifier: "85025", text: "CBC", name_of_coding_system: "CPT4"} =
               result.parent_observation_identifier

      assert result.parent_observation_sub_identifier == "1"
      assert result.parent_observation_value_descriptor == "Hemoglobin"
    end

    test "parses identifier only" do
      result = PRL.parse(["85025&CBC&CPT4"])
      assert %CE{identifier: "85025", text: "CBC", name_of_coding_system: "CPT4"} = result.parent_observation_identifier
      assert result.parent_observation_sub_identifier == nil
      assert result.parent_observation_value_descriptor == nil
    end

    test "parses identifier with sub-identifier" do
      result = PRL.parse(["85025&CBC&CPT4", "3"])
      assert %CE{identifier: "85025"} = result.parent_observation_identifier
      assert result.parent_observation_sub_identifier == "3"
      assert result.parent_observation_value_descriptor == nil
    end

    test "parses empty list" do
      result = PRL.parse([])
      assert result.parent_observation_identifier == nil
      assert result.parent_observation_sub_identifier == nil
      assert result.parent_observation_value_descriptor == nil
    end
  end

  describe "encode/1" do
    test "encodes all three components" do
      prl = %PRL{
        parent_observation_identifier: %CE{identifier: "85025", text: "CBC", name_of_coding_system: "CPT4"},
        parent_observation_sub_identifier: "1",
        parent_observation_value_descriptor: "Hemoglobin"
      }

      assert PRL.encode(prl) == ["85025&CBC&CPT4", "1", "Hemoglobin"]
    end

    test "encodes identifier with sub-identifier" do
      prl = %PRL{
        parent_observation_identifier: %CE{identifier: "85025", text: "CBC", name_of_coding_system: "CPT4"},
        parent_observation_sub_identifier: "1"
      }

      assert PRL.encode(prl) == ["85025&CBC&CPT4", "1"]
    end

    test "encodes nil" do
      assert PRL.encode(nil) == []
    end

    test "encodes empty struct" do
      assert PRL.encode(%PRL{}) == []
    end
  end

  describe "round-trip" do
    test "full PRL round-trips" do
      components = ["85025&CBC&CPT4", "1", "Hemoglobin"]
      assert components |> PRL.parse() |> PRL.encode() == components
    end

    test "identifier-only round-trips" do
      components = ["85025&CBC&CPT4"]
      assert components |> PRL.parse() |> PRL.encode() == components
    end
  end
end
