# Test-only segment with bounded max_reps for validation testing.
# Defined outside the test module so the struct is available at compile time.
defmodule HL7v2.ValidationTest.BoundedSegment do
  use HL7v2.Segment,
    id: "TST",
    fields: [
      {1, :required_field, HL7v2.Type.ST, :r, 1},
      {2, :bounded_reps, HL7v2.Type.ST, :o, 3}
    ]
end

defmodule HL7v2.ValidationTest do
  use ExUnit.Case, async: true

  alias HL7v2.Validation
  alias HL7v2.Validation.FieldRules
  alias HL7v2.TypedMessage

  describe "validate/1" do
    test "returns :ok for a valid message with all required fields" do
      assert :ok = Validation.validate(valid_typed_message())
    end

    test "returns error when first segment is not MSH" do
      msg = %TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          %HL7v2.Segment.PID{
            patient_identifier_list: [%HL7v2.Type.CX{id: "12345"}],
            patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}}]
          }
        ]
      }

      assert {:error, errors} = Validation.validate(msg)
      assert Enum.any?(errors, &(&1.message =~ "first segment must be MSH"))
    end

    test "returns error when message has no segments" do
      msg = %TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"ADT", "A01"},
        segments: []
      }

      assert {:error, errors} = Validation.validate(msg)
      assert Enum.any?(errors, &(&1.message =~ "no segments"))
    end

    test "returns error when MSH message_type is missing" do
      msg = %TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          %HL7v2.Segment.MSH{
            field_separator: "|",
            encoding_characters: "^~\\&",
            message_type: nil,
            message_control_id: "MSG001",
            processing_id: %HL7v2.Type.PT{processing_id: "P"},
            version_id: %HL7v2.Type.VID{version_id: "2.5.1"},
            date_time_of_message: %HL7v2.Type.TS{
              time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
            }
          }
        ]
      }

      assert {:error, errors} = Validation.validate(msg)

      assert Enum.any?(
               errors,
               &(&1.field == :message_type and &1.location == "MSH")
             )
    end

    test "returns error when MSH message_control_id is missing" do
      msg = %TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          %HL7v2.Segment.MSH{
            field_separator: "|",
            encoding_characters: "^~\\&",
            message_type: %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"},
            message_control_id: nil,
            processing_id: %HL7v2.Type.PT{processing_id: "P"},
            version_id: %HL7v2.Type.VID{version_id: "2.5.1"},
            date_time_of_message: %HL7v2.Type.TS{
              time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
            }
          }
        ]
      }

      assert {:error, errors} = Validation.validate(msg)

      assert Enum.any?(
               errors,
               &(&1.field == :message_control_id and &1.location == "MSH")
             )
    end

    test "returns errors when PID required fields are missing" do
      msg = %TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          valid_msh(),
          valid_evn(),
          %HL7v2.Segment.PID{
            patient_identifier_list: nil,
            patient_name: nil
          },
          valid_pv1()
        ]
      }

      assert {:error, errors} = Validation.validate(msg)

      pid_errors = Enum.filter(errors, &(&1.location == "PID"))
      assert length(pid_errors) >= 2

      assert Enum.any?(pid_errors, &(&1.field == :patient_identifier_list))
      assert Enum.any?(pid_errors, &(&1.field == :patient_name))
    end

    test "accumulates errors across multiple segments" do
      msg = %TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"ADT", "A01"},
        segments: [
          %HL7v2.Segment.MSH{
            field_separator: "|",
            encoding_characters: "^~\\&",
            message_type: nil,
            message_control_id: nil,
            processing_id: nil,
            version_id: nil,
            date_time_of_message: nil
          },
          %HL7v2.Segment.PID{
            patient_identifier_list: nil,
            patient_name: nil
          }
        ]
      }

      assert {:error, errors} = Validation.validate(msg)

      msh_errors = Enum.filter(errors, &(&1.location == "MSH"))
      pid_errors = Enum.filter(errors, &(&1.location == "PID"))

      assert length(msh_errors) >= 2
      assert length(pid_errors) >= 2
    end

    test "optional fields can be nil without error" do
      msg = valid_typed_message()
      msh = hd(msg.segments)
      # sending_application is optional (:o)
      msh = %{msh | sending_application: nil, security: nil}
      msg = %{msg | segments: [msh | tl(msg.segments)]}

      assert :ok = Validation.validate(msg)
    end

    test "backwards-compat (:b) fields can be nil without error" do
      msg = valid_typed_message()
      pid = Enum.at(msg.segments, 2)
      # patient_id is :b, patient_alias is :b
      pid = %{pid | patient_id: nil, patient_alias: nil}
      msg = %{msg | segments: List.replace_at(msg.segments, 2, pid)}

      assert :ok = Validation.validate(msg)
    end

    test "conditional (:c) fields can be nil without error" do
      msg = valid_typed_message()
      pid = Enum.at(msg.segments, 2)
      # species_code and breed_code are :c
      pid = %{pid | species_code: nil, breed_code: nil}
      msg = %{msg | segments: List.replace_at(msg.segments, 2, pid)}

      assert :ok = Validation.validate(msg)
    end

    test "unbounded repeating fields do not trigger max_reps warnings" do
      pid = %HL7v2.Segment.PID{
        patient_identifier_list: [
          %HL7v2.Type.CX{id: "1"},
          %HL7v2.Type.CX{id: "2"},
          %HL7v2.Type.CX{id: "3"}
        ],
        patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}}]
      }

      errors = FieldRules.check(pid)
      refute Enum.any?(errors, &(&1.level == :warning))
    end

    test "ZXX segments are skipped during field validation" do
      msg = %TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"TST", "Z01"},
        segments: [
          %{
            valid_msh()
            | message_type: %HL7v2.Type.MSG{message_code: "TST", trigger_event: "Z01"}
          },
          %HL7v2.Segment.ZXX{segment_id: "ZPD", raw_fields: ["some", "data"]}
        ]
      }

      # Structure warning for unknown TST_Z01, but no field errors from ZXX
      case Validation.validate(msg) do
        :ok -> :ok
        {:ok, warnings} -> assert Enum.all?(warnings, &(&1.level == :warning))
        {:error, errors} -> refute Enum.any?(errors, &(&1.level == :error))
      end
    end

    test "raw tuple segments are skipped during field validation" do
      msg = %TypedMessage{
        separators: HL7v2.Separator.default(),
        type: {"TST", "Z01"},
        segments: [
          %{
            valid_msh()
            | message_type: %HL7v2.Type.MSG{message_code: "TST", trigger_event: "Z01"}
          },
          {"XYZ", ["unknown", "segment"]}
        ]
      }

      # Structure warning for unknown TST_Z01, but no field errors from raw tuple
      case Validation.validate(msg) do
        :ok -> :ok
        {:ok, warnings} -> assert Enum.all?(warnings, &(&1.level == :warning))
        {:error, errors} -> refute Enum.any?(errors, &(&1.level == :error))
      end
    end

    test "top-level HL7v2.validate/1 delegates to Validation" do
      assert :ok = HL7v2.validate(valid_typed_message())
    end

    test "top-level HL7v2.validate/1 returns :not_a_typed_message for non-typed input" do
      assert {:error, :not_a_typed_message} = HL7v2.validate(:not_a_message)
    end

    test "non-canonical MSH-9.3 alias is resolved to canonical structure" do
      # SIU^S14^SIU_S14 should validate structurally as SIU_S12
      wire =
        "MSH|^~\\&|S|F||R|20260408||SIU^S14^SIU_S14|1|P|2.5.1\r" <>
          "SCH|1|||||ROUTINE^Routine^HL70276|||60^MIN|||||||1234^Smith^Jane||||1234^Smith^Jane\r" <>
          "PID|1||12345^^^MRN||Doe^John\r" <>
          "PV1|1|O\r" <>
          "RGS|1\r" <>
          "AIS|1||99214^Visit^CPT\r"

      {:ok, typed} = HL7v2.parse(wire, mode: :typed)

      case HL7v2.validate(typed) do
        :ok -> :ok
        {:ok, warnings} -> refute Enum.any?(warnings, &(&1.message =~ "structure not checked"))
        {:error, errors} -> flunk("Validation failed: #{inspect(errors)}")
      end
    end

    test "ACK^A01^ACK_A01 falls back to bare ACK structure" do
      # ACK_A01 is not a registered structure — should fall back to ACK
      wire =
        "MSH|^~\\&|S|F||R|20260408||ACK^A01^ACK_A01|1|P|2.5.1\r" <>
          "MSA|AA|MSG001\r"

      {:ok, typed} = HL7v2.parse(wire, mode: :typed)

      case HL7v2.validate(typed) do
        :ok -> :ok
        {:ok, warnings} -> refute Enum.any?(warnings, &(&1.message =~ "structure not checked"))
        {:error, errors} -> flunk("Validation failed: #{inspect(errors)}")
      end
    end

    test "ADT^A28^ADT_A28 alias resolves to ADT_A05 for structural validation" do
      wire =
        "MSH|^~\\&|S|F||R|20260408||ADT^A28^ADT_A28|1|P|2.5.1\r" <>
          "EVN|A28|20260408\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|O\r"

      {:ok, typed} = HL7v2.parse(wire, mode: :typed)

      case HL7v2.validate(typed) do
        :ok -> :ok
        {:ok, warnings} -> refute Enum.any?(warnings, &(&1.message =~ "structure not checked"))
        {:error, errors} -> flunk("Validation failed: #{inspect(errors)}")
      end
    end

    test "version is plumbed through validation for a v2.7 message without errors" do
      wire =
        "MSH|^~\\&|S|F||R|20260408||ADT^A01^ADT_A01|1|P|2.7\r" <>
          "EVN|A01|20260408\r" <>
          "PID|1||12345^^^MRN||Smith^John\r" <>
          "PV1|1|O\r"

      {:ok, typed} = HL7v2.parse(wire, mode: :typed)

      # Smoke test: the version should flow through extract_trigger_context
      # into FieldRules without changing existing validation behavior.
      case HL7v2.validate(typed) do
        :ok -> :ok
        {:ok, _warnings} -> :ok
        {:error, errors} -> flunk("Validation failed unexpectedly: #{inspect(errors)}")
      end

      # Confirm the parsed message exposes the v2.7 version that the plumbing
      # extracts (sanity check on the fixture itself).
      [msh | _] = typed.segments
      assert msh.version_id.version_id == "2.7"
    end
  end

  describe "FieldRules bounded max_reps" do
    test "warns when bounded max_reps is exceeded" do
      segment = %HL7v2.ValidationTest.BoundedSegment{
        required_field: "present",
        bounded_reps: ["a", "b", "c", "d"]
      }

      errors = FieldRules.check(segment)

      assert Enum.any?(errors, fn err ->
               err.level == :warning and err.field == :bounded_reps and
                 err.message =~ "4 repetitions" and err.message =~ "max allowed is 3"
             end)
    end

    test "does not warn when bounded max_reps is not exceeded" do
      segment = %HL7v2.ValidationTest.BoundedSegment{
        required_field: "present",
        bounded_reps: ["a", "b"]
      }

      errors = FieldRules.check(segment)
      refute Enum.any?(errors, &(&1.level == :warning))
    end

    test "does not warn when bounded field is nil" do
      segment = %HL7v2.ValidationTest.BoundedSegment{
        required_field: "present",
        bounded_reps: nil
      }

      errors = FieldRules.check(segment)
      refute Enum.any?(errors, &(&1.level == :warning))
    end
  end

  describe "expanded table bindings" do
    test "PID marital_status validated via CE identifier" do
      pid = %HL7v2.Segment.PID{
        patient_identifier_list: [%HL7v2.Type.CX{id: "12345"}],
        patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}}],
        marital_status: %HL7v2.Type.CE{identifier: "ZZ"}
      }

      errors = FieldRules.check(pid, validate_tables: true)
      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert length(table_errors) == 1
      assert hd(table_errors).field == :marital_status
    end

    test "PID marital_status passes with valid code" do
      pid = %HL7v2.Segment.PID{
        patient_identifier_list: [%HL7v2.Type.CX{id: "12345"}],
        patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}}],
        marital_status: %HL7v2.Type.CE{identifier: "M"}
      }

      errors = FieldRules.check(pid, validate_tables: true)
      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert table_errors == []
    end

    test "PID race validated via CE identifier (repeating field)" do
      pid = %HL7v2.Segment.PID{
        patient_identifier_list: [%HL7v2.Type.CX{id: "12345"}],
        patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}}],
        race: [
          %HL7v2.Type.CE{identifier: "W"},
          %HL7v2.Type.CE{identifier: "BOGUS"}
        ]
      }

      errors = FieldRules.check(pid, validate_tables: true)
      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert length(table_errors) == 1
      assert hd(table_errors).field == :race
    end

    test "ORC order_control validated against table 0119" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.ORC{
            order_control: "BOGUS",
            placer_order_number: %HL7v2.Type.EI{entity_identifier: "123"}
          },
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert length(table_errors) == 1
      assert hd(table_errors).field == :order_control
    end

    test "ORC valid order_control passes" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.ORC{
            order_control: "NW",
            placer_order_number: %HL7v2.Type.EI{entity_identifier: "123"}
          },
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert table_errors == []
    end

    test "OBR result_status validated against table 0123" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.OBR{
            universal_service_identifier: %HL7v2.Type.CE{identifier: "CBC"},
            result_status: "ZZ",
            placer_order_number: %HL7v2.Type.EI{entity_identifier: "123"}
          },
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert Enum.any?(table_errors, &(&1.field == :result_status))
    end

    test "PV1 discharge_disposition validated against table 0112" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.PV1{patient_class: "I", discharge_disposition: "99"},
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert length(table_errors) == 1
      assert hd(table_errors).field == :discharge_disposition
    end

    test "PV1 bed_status validated against table 0116" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.PV1{patient_class: "I", bed_status: "Z"},
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert length(table_errors) == 1
      assert hd(table_errors).field == :bed_status
    end

    test "PV1 visit_indicator validated against table 0326" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.PV1{patient_class: "I", visit_indicator: "X"},
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert length(table_errors) == 1
      assert hd(table_errors).field == :visit_indicator
    end

    test "AL1 allergen_type_code validated via CE identifier" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.AL1{
            set_id: "1",
            allergen_code: %HL7v2.Type.CE{identifier: "PEANUT"},
            allergen_type_code: %HL7v2.Type.CE{identifier: "BOGUS"}
          },
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert Enum.any?(table_errors, &(&1.field == :allergen_type_code))
    end

    test "AL1 allergy_severity_code validated via CE identifier" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.AL1{
            set_id: "1",
            allergen_code: %HL7v2.Type.CE{identifier: "PEANUT"},
            allergy_severity_code: %HL7v2.Type.CE{identifier: "SV"}
          },
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert table_errors == []
    end

    test "NTE source_of_comment validated against table 0105" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.NTE{source_of_comment: "X"},
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert length(table_errors) == 1
      assert hd(table_errors).field == :source_of_comment
    end

    test "NTE valid source_of_comment passes" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.NTE{source_of_comment: "L"},
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert table_errors == []
    end

    test "EVN event_type_code validated against table 0003" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.EVN{
            event_type_code: "Z99",
            recorded_date_time: %HL7v2.Type.TS{
              time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
            }
          },
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert Enum.any?(table_errors, &(&1.field == :event_type_code))
    end

    test "DG1 diagnosis_type validated against table 0052" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.DG1{set_id: "1", diagnosis_type: "X"},
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert Enum.any?(table_errors, &(&1.field == :diagnosis_type))
    end

    test "OBX nature_of_abnormal_test validated against table 0080" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.OBX{
            observation_identifier: %HL7v2.Type.CE{identifier: "1234"},
            observation_result_status: "F",
            value_type: "NM",
            nature_of_abnormal_test: "Z"
          },
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert Enum.any?(table_errors, &(&1.field == :nature_of_abnormal_test))
    end

    test "MSH country_code validated against table 0399" do
      errors =
        FieldRules.check(
          %HL7v2.Segment.MSH{
            field_separator: "|",
            encoding_characters: "^~\\&",
            message_type: %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"},
            message_control_id: "MSG001",
            processing_id: %HL7v2.Type.PT{processing_id: "P"},
            version_id: %HL7v2.Type.VID{version_id: "2.5.1"},
            date_time_of_message: %HL7v2.Type.TS{
              time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
            },
            country_code: "BOGUS"
          },
          validate_tables: true
        )

      table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
      assert Enum.any?(table_errors, &(&1.field == :country_code))
    end
  end

  describe "conditional field rules" do
    test "OBX: value_type required when observation_value is populated (lenient = warning)" do
      obx = %HL7v2.Segment.OBX{
        observation_identifier: %HL7v2.Type.CE{identifier: "1234"},
        observation_result_status: "F",
        value_type: nil,
        observation_value: "42"
      }

      errors = FieldRules.check(obx, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert length(cond_errors) >= 1

      assert Enum.any?(cond_errors, fn err ->
               err.field == :value_type and err.level == :warning
             end)
    end

    test "OBX: value_type required when observation_value is populated (strict = error)" do
      obx = %HL7v2.Segment.OBX{
        observation_identifier: %HL7v2.Type.CE{identifier: "1234"},
        observation_result_status: "F",
        value_type: nil,
        observation_value: "42"
      }

      errors = FieldRules.check(obx, mode: :strict)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :value_type and err.level == :error
             end)
    end

    test "OBX: no conditional warning when both value_type and observation_value are nil" do
      obx = %HL7v2.Segment.OBX{
        observation_identifier: %HL7v2.Type.CE{identifier: "1234"},
        observation_result_status: "F",
        value_type: nil,
        observation_value: nil
      }

      errors = FieldRules.check(obx)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "OBX: no conditional warning when value_type is populated" do
      obx = %HL7v2.Segment.OBX{
        observation_identifier: %HL7v2.Type.CE{identifier: "1234"},
        observation_result_status: "F",
        value_type: "NM",
        observation_value: "42"
      }

      errors = FieldRules.check(obx)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "MSH: warns when MSH-15 is set but MSH-16 is not (lenient)" do
      msh = %HL7v2.Segment.MSH{
        field_separator: "|",
        encoding_characters: "^~\\&",
        message_type: %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"},
        message_control_id: "MSG001",
        processing_id: %HL7v2.Type.PT{processing_id: "P"},
        version_id: %HL7v2.Type.VID{version_id: "2.5.1"},
        date_time_of_message: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
        },
        accept_acknowledgment_type: "AL",
        application_acknowledgment_type: nil
      }

      errors = FieldRules.check(msh, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert length(cond_errors) == 1

      assert Enum.any?(cond_errors, fn err ->
               err.field == :application_acknowledgment_type and err.level == :warning
             end)
    end

    test "MSH: errors when MSH-16 is set but MSH-15 is not (strict)" do
      msh = %HL7v2.Segment.MSH{
        field_separator: "|",
        encoding_characters: "^~\\&",
        message_type: %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"},
        message_control_id: "MSG001",
        processing_id: %HL7v2.Type.PT{processing_id: "P"},
        version_id: %HL7v2.Type.VID{version_id: "2.5.1"},
        date_time_of_message: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
        },
        accept_acknowledgment_type: nil,
        application_acknowledgment_type: "NE"
      }

      errors = FieldRules.check(msh, mode: :strict)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :accept_acknowledgment_type and err.level == :error
             end)
    end

    test "MSH: no warning when both MSH-15 and MSH-16 are populated" do
      msh = %HL7v2.Segment.MSH{
        field_separator: "|",
        encoding_characters: "^~\\&",
        message_type: %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"},
        message_control_id: "MSG001",
        processing_id: %HL7v2.Type.PT{processing_id: "P"},
        version_id: %HL7v2.Type.VID{version_id: "2.5.1"},
        date_time_of_message: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
        },
        accept_acknowledgment_type: "AL",
        application_acknowledgment_type: "AL"
      }

      errors = FieldRules.check(msh)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "MSH: no warning when both MSH-15 and MSH-16 are absent" do
      msh = valid_msh()
      errors = FieldRules.check(msh)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "NK1: warns when set_id is present but nk_name is missing" do
      nk1 = %HL7v2.Segment.NK1{
        set_id: "1",
        nk_name: nil
      }

      errors = FieldRules.check(nk1, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :nk_name and err.level == :warning
             end)
    end

    test "NK1: no warning when set_id and nk_name are both present" do
      nk1 = %HL7v2.Segment.NK1{
        set_id: "1",
        nk_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Jones"}}]
      }

      errors = FieldRules.check(nk1)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "ORC: warns when both placer and filler order numbers are missing" do
      orc = %HL7v2.Segment.ORC{
        order_control: "NW",
        placer_order_number: nil,
        filler_order_number: nil
      }

      errors = FieldRules.check(orc, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.level == :warning and err.message =~ "placer_order_number"
             end)
    end

    test "ORC: no warning when placer_order_number is present" do
      orc = %HL7v2.Segment.ORC{
        order_control: "NW",
        placer_order_number: %HL7v2.Type.EI{entity_identifier: "P123"}
      }

      errors = FieldRules.check(orc)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "ORC: no warning when filler_order_number is present" do
      orc = %HL7v2.Segment.ORC{
        order_control: "NW",
        filler_order_number: %HL7v2.Type.EI{entity_identifier: "F456"}
      }

      errors = FieldRules.check(orc)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "OBR: warns when result_status is present but observation_date_time is missing" do
      obr = %HL7v2.Segment.OBR{
        universal_service_identifier: %HL7v2.Type.CE{identifier: "CBC"},
        result_status: "F",
        observation_date_time: nil,
        filler_order_number: %HL7v2.Type.EI{entity_identifier: "F789"}
      }

      errors = FieldRules.check(obr, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :observation_date_time and err.level == :warning
             end)
    end

    test "OBR: no conditional warning when result_status and observation_date_time are both present" do
      obr = %HL7v2.Segment.OBR{
        universal_service_identifier: %HL7v2.Type.CE{identifier: "CBC"},
        result_status: "F",
        observation_date_time: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
        },
        filler_order_number: %HL7v2.Type.EI{entity_identifier: "F789"}
      }

      errors = FieldRules.check(obr)
      cond_errors = Enum.filter(errors, &(&1.message =~ "observation_date_time"))
      assert cond_errors == []
    end

    test "SCH: warns when both placer and filler appointment IDs are missing" do
      sch = %HL7v2.Segment.SCH{
        event_reason: %HL7v2.Type.CE{identifier: "ROUTINE"},
        filler_contact_person: [%HL7v2.Type.XCN{id_number: "DOC1"}],
        entered_by_person: [%HL7v2.Type.XCN{id_number: "USER1"}],
        placer_appointment_id: nil,
        filler_appointment_id: nil
      }

      errors = FieldRules.check(sch, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.level == :warning and err.message =~ "placer_appointment_id"
             end)
    end

    test "conditional rules in strict mode produce :error" do
      nk1 = %HL7v2.Segment.NK1{
        set_id: "1",
        nk_name: nil
      }

      errors = FieldRules.check(nk1, mode: :strict)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :nk_name and err.level == :error
             end)
    end

    test "default segment with no conditional rules produces no conditional errors" do
      msa = %HL7v2.Segment.MSA{acknowledgment_code: "AA", message_control_id: "MSG001"}
      errors = FieldRules.check(msa)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    # -- BPX conditional rules --

    test "BPX: warns when neither donation nor commercial product is populated" do
      bpx = %HL7v2.Segment.BPX{
        set_id: "1",
        bp_dispense_status: %HL7v2.Type.CWE{identifier: "RA"},
        bp_status: "A",
        bp_date_time_of_status: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 6}
        },
        bp_quantity: "1",
        bc_donation_id: nil,
        cp_commercial_product: nil
      }

      errors = FieldRules.check(bpx, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :bc_donation_id and err.level == :warning
             end)
    end

    test "BPX: warns when donation is populated but component is missing" do
      bpx = %HL7v2.Segment.BPX{
        set_id: "1",
        bp_dispense_status: %HL7v2.Type.CWE{identifier: "RA"},
        bp_status: "A",
        bp_date_time_of_status: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 6}
        },
        bp_quantity: "1",
        bc_donation_id: %HL7v2.Type.EI{entity_identifier: "D001"},
        bc_component: nil
      }

      errors = FieldRules.check(bpx, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :bc_component and err.level == :warning
             end)
    end

    test "BPX: warns when commercial product populated but manufacturer/lot missing" do
      bpx = %HL7v2.Segment.BPX{
        set_id: "1",
        bp_dispense_status: %HL7v2.Type.CWE{identifier: "RA"},
        bp_status: "A",
        bp_date_time_of_status: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 6}
        },
        bp_quantity: "1",
        cp_commercial_product: %HL7v2.Type.CWE{identifier: "PROD1"},
        cp_manufacturer: nil,
        cp_lot_number: nil
      }

      errors = FieldRules.check(bpx, mode: :strict)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :cp_manufacturer and err.level == :error
             end)

      assert Enum.any?(cond_errors, fn err ->
               err.field == :cp_lot_number and err.level == :error
             end)
    end

    test "BPX: no conditional warnings when donation path is complete" do
      bpx = %HL7v2.Segment.BPX{
        set_id: "1",
        bp_dispense_status: %HL7v2.Type.CWE{identifier: "RA"},
        bp_status: "A",
        bp_date_time_of_status: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 6}
        },
        bp_quantity: "1",
        bc_donation_id: %HL7v2.Type.EI{entity_identifier: "D001"},
        bc_component: %HL7v2.Type.CNE{identifier: "RBC"}
      }

      errors = FieldRules.check(bpx)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    # -- BTX conditional rules --

    test "BTX: warns when neither donation nor commercial product is populated" do
      btx = %HL7v2.Segment.BTX{
        set_id: "1",
        bp_quantity: "1",
        bp_transfusion_disposition_status: %HL7v2.Type.CWE{identifier: "TX"},
        bp_message_status: "A",
        bp_date_time_of_status: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 6}
        },
        bc_donation_id: nil,
        cp_commercial_product: nil
      }

      errors = FieldRules.check(btx, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :bc_donation_id and err.level == :warning
             end)
    end

    test "BTX: warns when donation populated but component missing" do
      btx = %HL7v2.Segment.BTX{
        set_id: "1",
        bp_quantity: "1",
        bp_transfusion_disposition_status: %HL7v2.Type.CWE{identifier: "TX"},
        bp_message_status: "A",
        bp_date_time_of_status: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 6}
        },
        bc_donation_id: %HL7v2.Type.EI{entity_identifier: "D001"},
        bc_component: nil
      }

      errors = FieldRules.check(btx, mode: :strict)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :bc_component and err.level == :error
             end)
    end

    test "BTX: no conditional warnings when commercial path is complete" do
      btx = %HL7v2.Segment.BTX{
        set_id: "1",
        bp_quantity: "1",
        bp_transfusion_disposition_status: %HL7v2.Type.CWE{identifier: "TX"},
        bp_message_status: "A",
        bp_date_time_of_status: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 6}
        },
        cp_commercial_product: %HL7v2.Type.CWE{identifier: "PROD1"},
        cp_manufacturer: %HL7v2.Type.XON{organization_name: "MFG"},
        cp_lot_number: %HL7v2.Type.EI{entity_identifier: "LOT001"}
      }

      errors = FieldRules.check(btx)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    # -- CSP conditional rules --

    test "CSP: warns when phase ended but evaluability missing" do
      csp = %HL7v2.Segment.CSP{
        study_phase_identifier: %HL7v2.Type.CE{identifier: "PHASE1"},
        date_time_study_phase_began: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 1, day: 1}
        },
        date_time_study_phase_ended: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 1}
        },
        study_phase_evaluability: nil
      }

      errors = FieldRules.check(csp, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :study_phase_evaluability and err.level == :warning
             end)
    end

    test "CSP: no conditional warning when phase not ended" do
      csp = %HL7v2.Segment.CSP{
        study_phase_identifier: %HL7v2.Type.CE{identifier: "PHASE1"},
        date_time_study_phase_began: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 1, day: 1}
        },
        date_time_study_phase_ended: nil,
        study_phase_evaluability: nil
      }

      errors = FieldRules.check(csp)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "CSP: no conditional warning when phase ended and evaluability present" do
      csp = %HL7v2.Segment.CSP{
        study_phase_identifier: %HL7v2.Type.CE{identifier: "PHASE1"},
        date_time_study_phase_began: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 1, day: 1}
        },
        date_time_study_phase_ended: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 1}
        },
        study_phase_evaluability: %HL7v2.Type.CE{identifier: "EVAL"}
      }

      errors = FieldRules.check(csp)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    # -- CSR conditional rules --

    test "CSR: warns when registered but eligibility status missing" do
      csr = %HL7v2.Segment.CSR{
        sponsor_study_id: %HL7v2.Type.EI{entity_identifier: "STUDY1"},
        sponsor_patient_id: %HL7v2.Type.CX{id: "PAT001"},
        study_authorizing_provider: [%HL7v2.Type.XCN{id_number: "DOC1"}],
        date_time_of_patient_study_registration: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 1}
        },
        patient_study_eligibility_status: nil
      }

      errors = FieldRules.check(csr, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :patient_study_eligibility_status and err.level == :warning
             end)
    end

    test "CSR: warns when study ended but evaluability status missing" do
      csr = %HL7v2.Segment.CSR{
        sponsor_study_id: %HL7v2.Type.EI{entity_identifier: "STUDY1"},
        sponsor_patient_id: %HL7v2.Type.CX{id: "PAT001"},
        study_authorizing_provider: [%HL7v2.Type.XCN{id_number: "DOC1"}],
        date_time_ended_study: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 6, day: 1}
        },
        patient_evaluability_status: nil
      }

      errors = FieldRules.check(csr, mode: :strict)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :patient_evaluability_status and err.level == :error
             end)
    end

    test "CSR: no conditional warning when neither registered nor ended" do
      csr = %HL7v2.Segment.CSR{
        sponsor_study_id: %HL7v2.Type.EI{entity_identifier: "STUDY1"},
        sponsor_patient_id: %HL7v2.Type.CX{id: "PAT001"},
        study_authorizing_provider: [%HL7v2.Type.XCN{id_number: "DOC1"}]
      }

      errors = FieldRules.check(csr)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    # -- SID conditional rules --

    test "SID: warns when both identifiers are missing" do
      sid = %HL7v2.Segment.SID{
        application_method_identifier: nil,
        substance_manufacturer_identifier: nil
      }

      errors = FieldRules.check(sid, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :application_method_identifier and err.level == :warning
             end)
    end

    test "SID: no conditional warning when application_method_identifier is present" do
      sid = %HL7v2.Segment.SID{
        application_method_identifier: %HL7v2.Type.CE{identifier: "APP1"},
        substance_manufacturer_identifier: nil
      }

      errors = FieldRules.check(sid)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "SID: no conditional warning when substance_manufacturer_identifier is present" do
      sid = %HL7v2.Segment.SID{
        application_method_identifier: nil,
        substance_manufacturer_identifier: %HL7v2.Type.CE{identifier: "MFG1"}
      }

      errors = FieldRules.check(sid)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "SID: errors in strict mode when both identifiers are missing" do
      sid = %HL7v2.Segment.SID{
        application_method_identifier: nil,
        substance_manufacturer_identifier: nil
      }

      errors = FieldRules.check(sid, mode: :strict)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :application_method_identifier and err.level == :error
             end)
    end

    # -- STF conditional rules --

    test "STF: warns when staff_identifier_list is populated but primary_key_value is missing" do
      stf = %HL7v2.Segment.STF{
        staff_identifier_list: [%HL7v2.Type.CX{id: "STAFF001"}],
        primary_key_value: nil
      }

      errors = FieldRules.check(stf, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :primary_key_value and err.level == :warning
             end)
    end

    test "STF: no conditional warning when primary_key_value is populated" do
      stf = %HL7v2.Segment.STF{
        staff_identifier_list: [%HL7v2.Type.CX{id: "STAFF001"}],
        primary_key_value: %HL7v2.Type.CE{identifier: "KEY1"}
      }

      errors = FieldRules.check(stf)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "STF: no conditional warning when staff_identifier_list is empty" do
      stf = %HL7v2.Segment.STF{
        staff_identifier_list: nil,
        primary_key_value: nil
      }

      errors = FieldRules.check(stf)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    # -- PV2 conditional rules --

    test "PV2: warns when discharge date set but disposition missing" do
      pv2 = %HL7v2.Segment.PV2{
        expected_discharge_date_time: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 10}
        },
        expected_discharge_disposition: nil
      }

      errors = FieldRules.check(pv2, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :expected_discharge_disposition and err.level == :warning
             end)
    end

    test "PV2: no conditional warning when both discharge date and disposition present" do
      pv2 = %HL7v2.Segment.PV2{
        expected_discharge_date_time: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 10}
        },
        expected_discharge_disposition: "01"
      }

      errors = FieldRules.check(pv2)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "PV2: no conditional warning when discharge date not set" do
      pv2 = %HL7v2.Segment.PV2{}

      errors = FieldRules.check(pv2)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "PV2: strict mode produces error" do
      pv2 = %HL7v2.Segment.PV2{
        expected_discharge_date_time: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 10}
        },
        expected_discharge_disposition: nil
      }

      errors = FieldRules.check(pv2, mode: :strict)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :expected_discharge_disposition and err.level == :error
             end)
    end

    # -- QAK conditional rules --

    test "QAK: warns when query_tag present but query_response_status missing" do
      qak = %HL7v2.Segment.QAK{
        query_tag: "QRY001",
        query_response_status: nil
      }

      errors = FieldRules.check(qak, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :query_response_status and err.level == :warning
             end)
    end

    test "QAK: no conditional warning when both query_tag and status present" do
      qak = %HL7v2.Segment.QAK{
        query_tag: "QRY001",
        query_response_status: "OK"
      }

      errors = FieldRules.check(qak)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    test "QAK: no conditional warning when query_tag is absent" do
      qak = %HL7v2.Segment.QAK{}

      errors = FieldRules.check(qak)
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))
      assert cond_errors == []
    end

    # -- Trigger-aware AIS conditional rules --

    test "AIS: warns when trigger is a modification event and segment_action_code is blank" do
      ais = %HL7v2.Segment.AIS{
        set_id: "1",
        universal_service_identifier: %HL7v2.Type.CE{identifier: "CONSULT"},
        segment_action_code: nil
      }

      errors = FieldRules.check(ais, mode: :lenient, context: %{trigger_event: "S03"})
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :segment_action_code and err.level == :warning and
                 err.message =~ "required for modification event S03"
             end)
    end

    test "AIS: errors in strict mode when trigger is a modification event and segment_action_code is blank" do
      ais = %HL7v2.Segment.AIS{
        set_id: "1",
        universal_service_identifier: %HL7v2.Type.CE{identifier: "CONSULT"},
        segment_action_code: nil
      }

      errors = FieldRules.check(ais, mode: :strict, context: %{trigger_event: "S07"})
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :segment_action_code and err.level == :error and
                 err.message =~ "required for modification event S07"
             end)
    end

    test "AIS: no warning when trigger is NOT a modification event" do
      ais = %HL7v2.Segment.AIS{
        set_id: "1",
        universal_service_identifier: %HL7v2.Type.CE{identifier: "CONSULT"},
        start_date_time: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 8}
        },
        segment_action_code: nil
      }

      # S12 is a new appointment notification, not a modification
      errors = FieldRules.check(ais, mode: :lenient, context: %{trigger_event: "S12"})
      cond_errors = Enum.filter(errors, &(&1.message =~ "segment_action_code"))
      assert cond_errors == []
    end

    test "AIS: no warning when trigger is modification but segment_action_code is populated" do
      ais = %HL7v2.Segment.AIS{
        set_id: "1",
        universal_service_identifier: %HL7v2.Type.CE{identifier: "CONSULT"},
        segment_action_code: "U"
      }

      errors = FieldRules.check(ais, mode: :strict, context: %{trigger_event: "S03"})
      cond_errors = Enum.filter(errors, &(&1.message =~ "segment_action_code"))
      assert cond_errors == []
    end

    test "AIS: falls back to heuristic when no trigger context provided" do
      ais = %HL7v2.Segment.AIS{
        set_id: "1",
        universal_service_identifier: %HL7v2.Type.CE{identifier: "CONSULT"},
        start_date_time: %HL7v2.Type.TS{
          time: %HL7v2.Type.DTM{year: 2026, month: 4, day: 8}
        },
        segment_action_code: nil
      }

      errors = FieldRules.check(ais, mode: :lenient)
      cond_errors = Enum.filter(errors, &(&1.message =~ "may be required"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :segment_action_code and err.level == :warning
             end)
    end

    # -- Trigger-aware AIG/AIL/AIP conditional rules --

    test "AIG: warns when trigger is modification event and segment_action_code is blank" do
      aig = %HL7v2.Segment.AIG{
        set_id: "1",
        resource_type: %HL7v2.Type.CE{identifier: "ROOM"},
        segment_action_code: nil
      }

      errors = FieldRules.check(aig, mode: :lenient, context: %{trigger_event: "S04"})
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :segment_action_code and err.level == :warning and
                 err.message =~ "required for modification event S04"
             end)
    end

    test "AIG: no warning when trigger is not a modification event" do
      aig = %HL7v2.Segment.AIG{
        set_id: "1",
        resource_type: %HL7v2.Type.CE{identifier: "ROOM"},
        segment_action_code: nil
      }

      errors = FieldRules.check(aig, mode: :lenient, context: %{trigger_event: "S12"})
      cond_errors = Enum.filter(errors, &(&1.message =~ "segment_action_code"))
      assert cond_errors == []
    end

    # -- Trigger-aware RGS conditional rules --

    test "RGS: warns when trigger is modification event and segment_action_code is blank" do
      rgs = %HL7v2.Segment.RGS{
        set_id: "1",
        segment_action_code: nil
      }

      errors = FieldRules.check(rgs, mode: :lenient, context: %{trigger_event: "S05"})
      cond_errors = Enum.filter(errors, &(&1.message =~ "conditional"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :segment_action_code and err.level == :warning and
                 err.message =~ "required for modification event S05"
             end)
    end

    test "RGS: no warning when trigger is not a modification event" do
      rgs = %HL7v2.Segment.RGS{
        set_id: "1",
        segment_action_code: nil
      }

      errors = FieldRules.check(rgs, mode: :strict, context: %{trigger_event: "S12"})
      cond_errors = Enum.filter(errors, &(&1.message =~ "segment_action_code"))
      assert cond_errors == []
    end

    # -- Trigger-aware PV2 transfer rules --

    test "PV2: warns when trigger is a transfer event and prior_pending_location is blank" do
      pv2 = %HL7v2.Segment.PV2{
        prior_pending_location: nil
      }

      errors = FieldRules.check(pv2, mode: :lenient, context: %{trigger_event: "A02"})
      cond_errors = Enum.filter(errors, &(&1.message =~ "prior_pending_location"))

      assert Enum.any?(cond_errors, fn err ->
               err.field == :prior_pending_location and err.level == :warning and
                 err.message =~ "transfer event A02"
             end)
    end

    test "PV2: warns for other transfer triggers (A06, A07)" do
      pv2 = %HL7v2.Segment.PV2{prior_pending_location: nil}

      for trigger <- ~w(A06 A07 A12 A15 A25 A26 A27 A28 A31) do
        errors = FieldRules.check(pv2, mode: :lenient, context: %{trigger_event: trigger})

        assert Enum.any?(errors, fn err ->
                 err.field == :prior_pending_location and
                   err.message =~ "transfer event #{trigger}"
               end),
               "expected warning for transfer trigger #{trigger}"
      end
    end

    test "PV2: no prior_pending_location warning when trigger is not a transfer event" do
      pv2 = %HL7v2.Segment.PV2{
        prior_pending_location: nil
      }

      errors = FieldRules.check(pv2, mode: :lenient, context: %{trigger_event: "A01"})
      transfer_errors = Enum.filter(errors, &(&1.message =~ "prior_pending_location"))
      assert transfer_errors == []
    end

    test "PV2: no prior_pending_location warning when prior_pending_location is populated" do
      pv2 = %HL7v2.Segment.PV2{
        prior_pending_location: %HL7v2.Type.PL{point_of_care: "3W"}
      }

      errors = FieldRules.check(pv2, mode: :lenient, context: %{trigger_event: "A02"})
      transfer_errors = Enum.filter(errors, &(&1.message =~ "prior_pending_location"))
      assert transfer_errors == []
    end

    test "PV2: no prior_pending_location warning without trigger context" do
      pv2 = %HL7v2.Segment.PV2{
        prior_pending_location: nil
      }

      errors = FieldRules.check(pv2, mode: :lenient)
      transfer_errors = Enum.filter(errors, &(&1.message =~ "prior_pending_location"))
      assert transfer_errors == []
    end
  end

  # -- Helpers --

  defp valid_typed_message do
    %TypedMessage{
      separators: HL7v2.Separator.default(),
      type: {"ADT", "A01"},
      segments: [
        valid_msh(),
        valid_evn(),
        valid_pid(),
        valid_pv1()
      ]
    }
  end

  defp valid_msh do
    %HL7v2.Segment.MSH{
      field_separator: "|",
      encoding_characters: "^~\\&",
      message_type: %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"},
      message_control_id: "MSG001",
      processing_id: %HL7v2.Type.PT{processing_id: "P"},
      version_id: %HL7v2.Type.VID{version_id: "2.5.1"},
      date_time_of_message: %HL7v2.Type.TS{
        time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
      }
    }
  end

  defp valid_evn do
    %HL7v2.Segment.EVN{
      recorded_date_time: %HL7v2.Type.TS{
        time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}
      }
    }
  end

  defp valid_pid do
    %HL7v2.Segment.PID{
      patient_identifier_list: [%HL7v2.Type.CX{id: "12345"}],
      patient_name: [%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}}]
    }
  end

  defp valid_pv1 do
    %HL7v2.Segment.PV1{patient_class: "I"}
  end
end
