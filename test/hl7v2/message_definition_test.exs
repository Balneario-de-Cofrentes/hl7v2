defmodule HL7v2.MessageDefinitionTest do
  use ExUnit.Case, async: true

  alias HL7v2.MessageDefinition

  describe "get/1" do
    test "returns definition for known structures" do
      definition = MessageDefinition.get("ADT_A01")

      assert definition.name == "ADT_A01"
      assert definition.description == "Admit/Visit Notification"
      assert is_list(definition.segments)
      assert {:MSH, :required, :once} in definition.segments
      assert {:EVN, :required, :once} in definition.segments
      assert {:PID, :required, :once} in definition.segments
      assert {:PV1, :required, :once} in definition.segments
    end

    test "returns definition for ACK" do
      definition = MessageDefinition.get("ACK")

      assert definition.name == "ACK"
      assert {:MSH, :required, :once} in definition.segments
      assert {:MSA, :required, :once} in definition.segments
      assert {:ERR, :optional, :repeating} in definition.segments
    end

    test "returns nil for unknown structures" do
      assert is_nil(MessageDefinition.get("UNKNOWN_X99"))
      assert is_nil(MessageDefinition.get(""))
    end
  end

  describe "names/0" do
    test "returns list of structure names" do
      names = MessageDefinition.names()

      assert is_list(names)
      assert "ADT_A01" in names
      assert "ADT_A04" in names
      assert "ORM_O01" in names
      assert "ORU_R01" in names
      assert "SIU_S12" in names
      assert "ACK" in names
    end
  end

  describe "all/0" do
    test "returns map of all definitions" do
      all = MessageDefinition.all()

      assert is_map(all)
      assert map_size(all) == length(MessageDefinition.names())

      for {key, value} <- all do
        assert is_binary(key)
        assert value.name == key
        assert is_binary(value.description)
        assert is_list(value.segments)
      end
    end
  end

  describe "validate_structure/2" do
    test "passes for valid ADT_A01 with all required segments" do
      segment_ids = ["MSH", "EVN", "PID", "PV1", "NK1", "AL1"]
      assert :ok = MessageDefinition.validate_structure("ADT_A01", segment_ids)
    end

    test "passes when only required segments are present" do
      segment_ids = ["MSH", "EVN", "PID", "PV1"]
      assert :ok = MessageDefinition.validate_structure("ADT_A01", segment_ids)
    end

    test "catches missing required segments" do
      # Missing EVN and PV1
      segment_ids = ["MSH", "PID"]
      assert {:error, errors} = MessageDefinition.validate_structure("ADT_A01", segment_ids)

      messages = Enum.map(errors, & &1.message)
      assert "Required segment EVN is missing" in messages
      assert "Required segment PV1 is missing" in messages

      for error <- errors do
        assert error.level == :error
        assert error.location == "message"
        assert is_nil(error.field)
      end
    end

    test "catches single missing required segment" do
      segment_ids = ["MSH", "EVN", "PID"]
      assert {:error, [error]} = MessageDefinition.validate_structure("ADT_A01", segment_ids)

      assert error.message == "Required segment PV1 is missing"
    end

    test "passes for unknown structures (no definition = no enforcement)" do
      assert :ok = MessageDefinition.validate_structure("UNKNOWN_X99", [])
      assert :ok = MessageDefinition.validate_structure("CUSTOM_MSG", ["MSH"])
    end

    test "validates ORU_R01 required segments" do
      assert :ok = MessageDefinition.validate_structure("ORU_R01", ["MSH", "PID", "OBR"])

      assert {:error, errors} = MessageDefinition.validate_structure("ORU_R01", ["MSH"])
      messages = Enum.map(errors, & &1.message)
      assert "Required segment PID is missing" in messages
      assert "Required segment OBR is missing" in messages
    end

    test "validates ACK required segments" do
      assert :ok = MessageDefinition.validate_structure("ACK", ["MSH", "MSA"])
      assert {:error, [error]} = MessageDefinition.validate_structure("ACK", ["MSH"])
      assert error.message == "Required segment MSA is missing"
    end
  end

  describe "integration with validation engine" do
    test "validates a typed ADT_A01 message missing EVN segment" do
      msg = %HL7v2.TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          %HL7v2.Segment.MSH{
            field_separator: "|",
            encoding_characters: "^~\\&",
            message_type: %HL7v2.Type.MSG{
              message_code: "ADT",
              trigger_event: "A01",
              message_structure: "ADT_A01"
            },
            message_control_id: "MSG001",
            processing_id: %HL7v2.Type.PT{processing_id: "P"},
            version_id: %HL7v2.Type.VID{version_id: "2.5.1"},
            date_time_of_message: %HL7v2.Type.TS{
              time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
            }
          },
          # EVN is missing
          %HL7v2.Segment.PID{
            patient_identifier_list: [%HL7v2.Type.CX{id: "12345"}],
            patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}}]
          },
          %HL7v2.Segment.PV1{
            patient_class: "I"
          }
        ]
      }

      assert {:error, errors} = HL7v2.Validation.validate(msg)
      assert Enum.any?(errors, &(&1.message == "Required segment EVN is missing"))
    end

    test "validates a typed ADT_A01 inferred from message_code + trigger_event" do
      msg = %HL7v2.TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          %HL7v2.Segment.MSH{
            field_separator: "|",
            encoding_characters: "^~\\&",
            message_type: %HL7v2.Type.MSG{
              message_code: "ADT",
              trigger_event: "A01"
              # message_structure is nil — inferred as "ADT_A01"
            },
            message_control_id: "MSG001",
            processing_id: %HL7v2.Type.PT{processing_id: "P"},
            version_id: %HL7v2.Type.VID{version_id: "2.5.1"},
            date_time_of_message: %HL7v2.Type.TS{
              time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
            }
          },
          # EVN is missing — should be caught via inferred structure
          %HL7v2.Segment.PID{
            patient_identifier_list: [%HL7v2.Type.CX{id: "12345"}],
            patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}}]
          },
          %HL7v2.Segment.PV1{
            patient_class: "I"
          }
        ]
      }

      assert {:error, errors} = HL7v2.Validation.validate(msg)
      assert Enum.any?(errors, &(&1.message == "Required segment EVN is missing"))
    end

    test "passes validation for complete ADT_A01" do
      msg = %HL7v2.TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          %HL7v2.Segment.MSH{
            field_separator: "|",
            encoding_characters: "^~\\&",
            message_type: %HL7v2.Type.MSG{
              message_code: "ADT",
              trigger_event: "A01",
              message_structure: "ADT_A01"
            },
            message_control_id: "MSG001",
            processing_id: %HL7v2.Type.PT{processing_id: "P"},
            version_id: %HL7v2.Type.VID{version_id: "2.5.1"},
            date_time_of_message: %HL7v2.Type.TS{
              time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
            }
          },
          %HL7v2.Segment.EVN{
            recorded_date_time: %HL7v2.Type.TS{
              time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
            }
          },
          %HL7v2.Segment.PID{
            patient_identifier_list: [%HL7v2.Type.CX{id: "12345"}],
            patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}}]
          },
          %HL7v2.Segment.PV1{
            patient_class: "I"
          }
        ]
      }

      assert :ok = HL7v2.Validation.validate(msg)
    end
  end
end
