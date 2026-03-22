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
