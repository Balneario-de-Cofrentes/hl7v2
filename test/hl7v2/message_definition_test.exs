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

    test "returns definition for ADT_A05 (pre-admit)" do
      definition = MessageDefinition.get("ADT_A05")

      assert definition.name == "ADT_A05"
      assert definition.description == "Pre-admit a Patient"
      assert {:MSH, :required, :once} in definition.segments
      assert {:EVN, :required, :once} in definition.segments
      assert {:PID, :required, :once} in definition.segments
      assert {:PV1, :required, :once} in definition.segments
      assert {:NK1, :optional, :repeating} in definition.segments
      assert {:AL1, :optional, :repeating} in definition.segments
      assert {:DG1, :optional, :repeating} in definition.segments
    end

    test "returns definition for ADT_A06 (change outpatient/inpatient)" do
      definition = MessageDefinition.get("ADT_A06")

      assert definition.name == "ADT_A06"
      assert {:MSH, :required, :once} in definition.segments
      assert {:EVN, :required, :once} in definition.segments
      assert {:PID, :required, :once} in definition.segments
      assert {:PV1, :required, :once} in definition.segments
      assert {:MRG, :optional, :once} in definition.segments
    end

    test "returns definition for ADT_A09 (patient departing)" do
      definition = MessageDefinition.get("ADT_A09")

      assert definition.name == "ADT_A09"
      assert {:MSH, :required, :once} in definition.segments
      assert {:EVN, :required, :once} in definition.segments
      assert {:PID, :required, :once} in definition.segments
      assert {:PV1, :required, :once} in definition.segments
      assert {:PV2, :optional, :once} in definition.segments
    end

    test "returns definition for ADT_A15 (pending transfer)" do
      definition = MessageDefinition.get("ADT_A15")

      assert definition.name == "ADT_A15"
      assert {:MSH, :required, :once} in definition.segments
      assert {:EVN, :required, :once} in definition.segments
      assert {:PID, :required, :once} in definition.segments
      assert {:PV1, :required, :once} in definition.segments
    end

    test "returns definition for ADT_A16 (pending discharge)" do
      definition = MessageDefinition.get("ADT_A16")

      assert definition.name == "ADT_A16"
      assert {:MSH, :required, :once} in definition.segments
      assert {:EVN, :required, :once} in definition.segments
      assert {:PID, :required, :once} in definition.segments
      assert {:PV1, :required, :once} in definition.segments
      assert {:DG1, :optional, :repeating} in definition.segments
    end

    test "returns definition for ADT_A21 (leave of absence)" do
      definition = MessageDefinition.get("ADT_A21")

      assert definition.name == "ADT_A21"
      assert {:MSH, :required, :once} in definition.segments
      assert {:EVN, :required, :once} in definition.segments
      assert {:PID, :required, :once} in definition.segments
      assert {:PV1, :required, :once} in definition.segments
    end

    test "returns definition for ADT_A24 (link patient)" do
      definition = MessageDefinition.get("ADT_A24")

      assert definition.name == "ADT_A24"
      assert {:MSH, :required, :once} in definition.segments
      assert {:EVN, :required, :once} in definition.segments
      assert {:PID, :required, :repeating} in definition.segments
      assert {:PV1, :optional, :repeating} in definition.segments
    end

    test "returns definition for ADT_A37 (unlink patient)" do
      definition = MessageDefinition.get("ADT_A37")

      assert definition.name == "ADT_A37"
      assert {:MSH, :required, :once} in definition.segments
      assert {:EVN, :required, :once} in definition.segments
      assert {:PID, :required, :repeating} in definition.segments
    end

    test "returns definition for ADT_A38 (cancel pre-admit)" do
      definition = MessageDefinition.get("ADT_A38")

      assert definition.name == "ADT_A38"
      assert {:MSH, :required, :once} in definition.segments
      assert {:EVN, :required, :once} in definition.segments
      assert {:PID, :required, :once} in definition.segments
      assert {:PV1, :required, :once} in definition.segments
    end

    test "returns definition for ADT_A39 (merge patient)" do
      definition = MessageDefinition.get("ADT_A39")

      assert definition.name == "ADT_A39"
      assert {:MSH, :required, :once} in definition.segments
      assert {:EVN, :required, :once} in definition.segments
      assert {:PID, :required, :repeating} in definition.segments
      assert {:MRG, :required, :repeating} in definition.segments
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
      assert "ADT_A05" in names
      assert "ADT_A06" in names
      assert "ADT_A09" in names
      assert "ADT_A15" in names
      assert "ADT_A16" in names
      assert "ADT_A21" in names
      assert "ADT_A24" in names
      assert "ADT_A37" in names
      assert "ADT_A38" in names
      assert "ADT_A39" in names
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

    test "returns warning for unknown structures" do
      assert {:error, [warning]} = MessageDefinition.validate_structure("UNKNOWN_X99", [])
      assert warning.level == :warning
      assert warning.message =~ "no validation definition"

      assert {:error, [_]} = MessageDefinition.validate_structure("CUSTOM_MSG", ["MSH"])
    end

    test "passes for nil/empty structure" do
      assert :ok = MessageDefinition.validate_structure(nil, [])
      assert :ok = MessageDefinition.validate_structure("", [])
    end

    test "validates ORU_R01 required segments" do
      # PID is optional per spec (patient group is optional)
      assert :ok = MessageDefinition.validate_structure("ORU_R01", ["MSH", "OBR"])
      assert :ok = MessageDefinition.validate_structure("ORU_R01", ["MSH", "PID", "OBR"])

      assert {:error, errors} = MessageDefinition.validate_structure("ORU_R01", ["MSH"])
      messages = Enum.map(errors, & &1.message)
      assert "Required segment OBR is missing" in messages
      refute "Required segment PID is missing" in messages
    end

    test "ORM_O01 does not require PID (patient group is optional)" do
      assert :ok = MessageDefinition.validate_structure("ORM_O01", ["MSH", "ORC"])

      assert {:error, errors} = MessageDefinition.validate_structure("ORM_O01", ["MSH"])
      messages = Enum.map(errors, & &1.message)
      assert "Required segment ORC is missing" in messages
      refute "Required segment PID is missing" in messages
    end

    test "SIU_S12 requires RGS (resource group anchor)" do
      assert :ok =
               MessageDefinition.validate_structure("SIU_S12", ["MSH", "SCH", "RGS"])

      assert {:error, errors} = MessageDefinition.validate_structure("SIU_S12", ["MSH", "SCH"])
      messages = Enum.map(errors, & &1.message)
      assert "Required segment RGS is missing" in messages
      refute "Required segment PID is missing" in messages
    end

    test "ADT^A12 resolves to ADT_A09 and validates" do
      structure = MessageDefinition.canonical_structure("ADT", "A12")
      assert structure == "ADT_A09"
      assert :ok = MessageDefinition.validate_structure(structure, ["MSH", "EVN", "PID", "PV1"])
    end

    test "SIU^S18 resolves to SIU_S12 and validates" do
      structure = MessageDefinition.canonical_structure("SIU", "S18")
      assert structure == "SIU_S12"
      assert :ok = MessageDefinition.validate_structure(structure, ["MSH", "SCH", "RGS"])
    end

    test "validates ACK required segments" do
      assert :ok = MessageDefinition.validate_structure("ACK", ["MSH", "MSA"])
      assert {:error, [error]} = MessageDefinition.validate_structure("ACK", ["MSH"])
      assert error.message == "Required segment MSA is missing"
    end

    test "validates ADT_A05 required segments" do
      assert :ok = MessageDefinition.validate_structure("ADT_A05", ["MSH", "EVN", "PID", "PV1"])

      assert {:error, errors} = MessageDefinition.validate_structure("ADT_A05", ["MSH"])
      messages = Enum.map(errors, & &1.message)
      assert "Required segment EVN is missing" in messages
      assert "Required segment PID is missing" in messages
      assert "Required segment PV1 is missing" in messages
    end

    test "validates ADT_A06 required segments" do
      assert :ok = MessageDefinition.validate_structure("ADT_A06", ["MSH", "EVN", "PID", "PV1"])

      assert {:error, errors} = MessageDefinition.validate_structure("ADT_A06", ["MSH", "PID"])
      messages = Enum.map(errors, & &1.message)
      assert "Required segment EVN is missing" in messages
      assert "Required segment PV1 is missing" in messages
    end

    test "validates ADT_A09 required segments" do
      assert :ok = MessageDefinition.validate_structure("ADT_A09", ["MSH", "EVN", "PID", "PV1"])

      assert {:error, errors} = MessageDefinition.validate_structure("ADT_A09", ["MSH"])
      messages = Enum.map(errors, & &1.message)
      assert "Required segment EVN is missing" in messages
      assert "Required segment PID is missing" in messages
      assert "Required segment PV1 is missing" in messages
    end

    test "validates ADT_A15 required segments" do
      assert :ok = MessageDefinition.validate_structure("ADT_A15", ["MSH", "EVN", "PID", "PV1"])

      assert {:error, [error]} =
               MessageDefinition.validate_structure("ADT_A15", ["MSH", "EVN", "PID"])

      assert error.message == "Required segment PV1 is missing"
    end

    test "validates ADT_A16 required segments" do
      assert :ok = MessageDefinition.validate_structure("ADT_A16", ["MSH", "EVN", "PID", "PV1"])

      assert {:error, errors} = MessageDefinition.validate_structure("ADT_A16", ["MSH", "EVN"])
      messages = Enum.map(errors, & &1.message)
      assert "Required segment PID is missing" in messages
      assert "Required segment PV1 is missing" in messages
    end

    test "validates ADT_A21 required segments" do
      assert :ok = MessageDefinition.validate_structure("ADT_A21", ["MSH", "EVN", "PID", "PV1"])

      assert {:error, [error]} =
               MessageDefinition.validate_structure("ADT_A21", ["MSH", "EVN", "PV1"])

      assert error.message == "Required segment PID is missing"
    end

    test "validates ADT_A24 required segments" do
      assert :ok = MessageDefinition.validate_structure("ADT_A24", ["MSH", "EVN", "PID"])

      assert {:error, [error]} = MessageDefinition.validate_structure("ADT_A24", ["MSH", "PID"])
      assert error.message == "Required segment EVN is missing"
    end

    test "validates ADT_A37 required segments" do
      assert :ok = MessageDefinition.validate_structure("ADT_A37", ["MSH", "EVN", "PID"])

      assert {:error, errors} = MessageDefinition.validate_structure("ADT_A37", ["MSH"])
      messages = Enum.map(errors, & &1.message)
      assert "Required segment EVN is missing" in messages
      assert "Required segment PID is missing" in messages
    end

    test "validates ADT_A38 required segments" do
      assert :ok = MessageDefinition.validate_structure("ADT_A38", ["MSH", "EVN", "PID", "PV1"])

      assert {:error, errors} = MessageDefinition.validate_structure("ADT_A38", ["MSH"])
      messages = Enum.map(errors, & &1.message)
      assert "Required segment EVN is missing" in messages
      assert "Required segment PID is missing" in messages
      assert "Required segment PV1 is missing" in messages
    end

    test "validates ADT_A39 required segments (merge requires MRG)" do
      assert :ok = MessageDefinition.validate_structure("ADT_A39", ["MSH", "EVN", "PID", "MRG"])

      assert {:error, errors} =
               MessageDefinition.validate_structure("ADT_A39", ["MSH", "EVN", "PID"])

      messages = Enum.map(errors, & &1.message)
      assert "Required segment MRG is missing" in messages
    end
  end

  describe "canonical_structure/2" do
    test "maps aliased ADT trigger events to their canonical structures" do
      assert MessageDefinition.canonical_structure("ADT", "A04") == "ADT_A01"
      assert MessageDefinition.canonical_structure("ADT", "A08") == "ADT_A01"
      assert MessageDefinition.canonical_structure("ADT", "A13") == "ADT_A01"

      assert MessageDefinition.canonical_structure("ADT", "A05") == "ADT_A05"
      assert MessageDefinition.canonical_structure("ADT", "A14") == "ADT_A05"
      assert MessageDefinition.canonical_structure("ADT", "A28") == "ADT_A05"
      assert MessageDefinition.canonical_structure("ADT", "A31") == "ADT_A05"

      assert MessageDefinition.canonical_structure("ADT", "A06") == "ADT_A06"
      assert MessageDefinition.canonical_structure("ADT", "A07") == "ADT_A06"

      assert MessageDefinition.canonical_structure("ADT", "A09") == "ADT_A09"
      assert MessageDefinition.canonical_structure("ADT", "A10") == "ADT_A09"
      assert MessageDefinition.canonical_structure("ADT", "A11") == "ADT_A09"
      assert MessageDefinition.canonical_structure("ADT", "A12") == "ADT_A09"

      assert MessageDefinition.canonical_structure("ADT", "A15") == "ADT_A15"
      assert MessageDefinition.canonical_structure("ADT", "A16") == "ADT_A16"

      assert MessageDefinition.canonical_structure("ADT", "A21") == "ADT_A21"
      assert MessageDefinition.canonical_structure("ADT", "A22") == "ADT_A21"
      assert MessageDefinition.canonical_structure("ADT", "A23") == "ADT_A21"
      assert MessageDefinition.canonical_structure("ADT", "A25") == "ADT_A21"
      assert MessageDefinition.canonical_structure("ADT", "A26") == "ADT_A21"
      assert MessageDefinition.canonical_structure("ADT", "A27") == "ADT_A21"

      assert MessageDefinition.canonical_structure("ADT", "A24") == "ADT_A24"
      assert MessageDefinition.canonical_structure("ADT", "A37") == "ADT_A37"
      assert MessageDefinition.canonical_structure("ADT", "A38") == "ADT_A38"

      assert MessageDefinition.canonical_structure("ADT", "A39") == "ADT_A39"
      assert MessageDefinition.canonical_structure("ADT", "A40") == "ADT_A39"
      assert MessageDefinition.canonical_structure("ADT", "A41") == "ADT_A39"
      assert MessageDefinition.canonical_structure("ADT", "A42") == "ADT_A39"
    end

    test "maps aliased SIU trigger events to SIU_S12" do
      for event <- ~w(S13 S14 S15 S16 S17 S18 S19 S20 S21 S22 S23 S24 S26) do
        assert MessageDefinition.canonical_structure("SIU", event) == "SIU_S12"
      end
    end

    test "falls back to CODE_EVENT for unmapped trigger events" do
      assert MessageDefinition.canonical_structure("ADT", "A01") == "ADT_A01"
      assert MessageDefinition.canonical_structure("ORU", "R01") == "ORU_R01"
      assert MessageDefinition.canonical_structure("ZZZ", "Z01") == "ZZZ_Z01"
    end

    test "every canonical target has a matching definition" do
      canonical_targets =
        [
          "ADT_A01",
          "ADT_A05",
          "ADT_A06",
          "ADT_A09",
          "ADT_A15",
          "ADT_A16",
          "ADT_A21",
          "ADT_A24",
          "ADT_A37",
          "ADT_A38",
          "ADT_A39",
          "SIU_S12"
        ]

      for structure <- canonical_targets do
        definition = MessageDefinition.get(structure)

        assert definition != nil,
               "canonical structure #{structure} has no definition in MessageDefinition"

        assert definition.name == structure
      end
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

    test "validates aliased event without MSH-9.3 via canonical resolution" do
      # ADT^A28 should infer ADT_A05 (not ADT_A28 which has no definition)
      msg = %HL7v2.TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"ADT", "A28"},
        segments: [
          %HL7v2.Segment.MSH{
            field_separator: "|",
            encoding_characters: "^~\\&",
            message_type: %HL7v2.Type.MSG{
              message_code: "ADT",
              trigger_event: "A28"
              # message_structure is nil -- must infer ADT_A05
            },
            message_control_id: "MSG_A28",
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
            patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Garcia"}}]
          },
          %HL7v2.Segment.PV1{
            patient_class: "O"
          }
        ]
      }

      assert :ok = HL7v2.Validation.validate(msg)
    end

    test "validates aliased event A40 without MSH-9.3 detects missing MRG" do
      # ADT^A40 should infer ADT_A39 which requires MRG
      msg = %HL7v2.TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"ADT", "A40"},
        segments: [
          %HL7v2.Segment.MSH{
            field_separator: "|",
            encoding_characters: "^~\\&",
            message_type: %HL7v2.Type.MSG{
              message_code: "ADT",
              trigger_event: "A40"
              # message_structure is nil -- must infer ADT_A39
            },
            message_control_id: "MSG_A40",
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
            patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Doe"}}]
          }
        ]
      }

      assert {:error, errors} = HL7v2.Validation.validate(msg)
      assert Enum.any?(errors, &(&1.message == "Required segment MRG is missing"))
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
