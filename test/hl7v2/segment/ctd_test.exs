defmodule HL7v2.Segment.CTDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.CTD

  describe "fields/0" do
    test "returns 7 field definitions" do
      assert length(CTD.fields()) == 7
    end
  end

  describe "segment_id/0" do
    test "returns CTD" do
      assert CTD.segment_id() == "CTD"
    end
  end

  describe "parse/1" do
    test "parses contact_role as repeating CE" do
      raw = [[["RP", "Referring Provider", "HL70131"]]]

      result = CTD.parse(raw)

      assert %CTD{} = result
      assert [%HL7v2.Type.CE{identifier: "RP", text: "Referring Provider"}] = result.contact_role
    end

    test "parses contact_name as repeating XPN" do
      raw = [["RP"], [["Smith", "John", "A"]]]

      result = CTD.parse(raw)

      assert [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}}] =
               result.contact_name
    end

    test "parses contact_address as repeating XAD" do
      raw = [["RP"], "", [["123 Main St", "", "", "Springfield", "IL", "62701"]]]

      result = CTD.parse(raw)

      assert [%HL7v2.Type.XAD{} = addr] = result.contact_address
      assert %HL7v2.Type.SAD{street_or_mailing_address: "123 Main St"} = addr.street_address
    end

    test "parses contact_location as PL" do
      raw = [["RP"], "", "", ["Clinic A", "Room 101"]]

      result = CTD.parse(raw)

      assert %HL7v2.Type.PL{point_of_care: "Clinic A", room: "Room 101"} =
               result.contact_location
    end

    test "parses contact_communication_information as repeating XTN" do
      raw = [["RP"], "", "", "", [["555-1234"]]]

      result = CTD.parse(raw)

      assert [%HL7v2.Type.XTN{}] = result.contact_communication_information
    end

    test "parses preferred_method_of_contact as CE" do
      raw = [["RP"], "", "", "", "", ["TEL", "Telephone"]]

      result = CTD.parse(raw)

      assert %HL7v2.Type.CE{identifier: "TEL", text: "Telephone"} =
               result.preferred_method_of_contact
    end

    test "preserves contact_identifiers as raw" do
      raw = [["RP"], "", "", "", "", "", ["raw_id_data"]]

      result = CTD.parse(raw)

      assert result.contact_identifiers == ["raw_id_data"]
    end

    test "parses empty list -- all fields nil" do
      result = CTD.parse([])

      assert %CTD{} = result
      assert result.contact_role == nil
      assert result.contact_name == nil
      assert result.contact_location == nil
    end
  end

  describe "encode/1" do
    test "round-trip preserves data" do
      raw = [[["RP", "Referring Provider"]], [["Smith", "John"]]]

      encoded = raw |> CTD.parse() |> CTD.encode()
      reparsed = CTD.parse(encoded)

      assert [%HL7v2.Type.CE{identifier: "RP"}] = reparsed.contact_role

      assert [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}}] =
               reparsed.contact_name
    end

    test "trailing nil fields trimmed" do
      ctd = %CTD{
        contact_role: [%HL7v2.Type.CE{identifier: "RP"}]
      }

      encoded = CTD.encode(ctd)

      assert length(encoded) == 1
    end

    test "encodes all-nil struct to empty list" do
      assert CTD.encode(%CTD{}) == []
    end
  end

  describe "typed parsing integration" do
    test "message with CTD parses as typed struct" do
      wire =
        "MSH|^~\\&|S|F||R|20260322||REF^I12|1|P|2.5.1\r" <>
          "CTD|RP^Referring Provider\r"

      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      ctd = Enum.find(msg.segments, &is_struct(&1, CTD))
      assert %CTD{} = ctd
      assert [%HL7v2.Type.CE{identifier: "RP"}] = ctd.contact_role
    end
  end
end
