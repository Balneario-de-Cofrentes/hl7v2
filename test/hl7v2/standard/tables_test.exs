defmodule HL7v2.Standard.TablesTest do
  use ExUnit.Case, async: true

  alias HL7v2.Standard.Tables

  describe "table_ids/0" do
    test "returns a sorted list of integers" do
      ids = Tables.table_ids()
      assert is_list(ids)
      assert ids == Enum.sort(ids)
      assert Enum.all?(ids, &is_integer/1)
    end

    test "includes core tables" do
      ids = Tables.table_ids()

      for id <- [
            1,
            2,
            3,
            4,
            7,
            8,
            52,
            63,
            74,
            76,
            85,
            103,
            104,
            125,
            155,
            190,
            200,
            203,
            278,
            396
          ] do
        assert id in ids, "expected table #{id} in table_ids()"
      end
    end
  end

  describe "get/1" do
    test "returns table map with name and codes for known tables" do
      for id <- Tables.table_ids() do
        table = Tables.get(id)
        assert %{name: name, codes: codes} = table
        assert is_binary(name)
        assert is_map(codes)
        assert map_size(codes) >= 2, "table #{id} (#{name}) must have at least 2 entries"
      end
    end

    test "returns nil for undefined table" do
      assert Tables.get(9999) == nil
    end
  end

  describe "valid?/2" do
    test "returns true for known codes" do
      assert Tables.valid?(1, "F")
      assert Tables.valid?(1, "M")
      assert Tables.valid?(8, "AA")
      assert Tables.valid?(8, "AE")
      assert Tables.valid?(76, "ADT")
      assert Tables.valid?(76, "ACK")
      assert Tables.valid?(85, "F")
      assert Tables.valid?(85, "P")
      assert Tables.valid?(103, "P")
      assert Tables.valid?(103, "T")
      assert Tables.valid?(104, "2.5.1")
      assert Tables.valid?(125, "NM")
      assert Tables.valid?(125, "ST")
      assert Tables.valid?(4, "I")
      assert Tables.valid?(4, "O")
    end

    test "returns false for unknown codes" do
      refute Tables.valid?(1, "ZZ")
      refute Tables.valid?(8, "XX")
      refute Tables.valid?(76, "INVALID")
      refute Tables.valid?(103, "X")
      refute Tables.valid?(85, "Q")
    end

    test "returns false for unknown table ID" do
      refute Tables.valid?(9999, "X")
    end

    test "is case-sensitive" do
      assert Tables.valid?(1, "F")
      refute Tables.valid?(1, "f")
      assert Tables.valid?(103, "P")
      refute Tables.valid?(103, "p")
    end
  end

  describe "validate/2" do
    test "returns :ok for valid codes" do
      assert :ok = Tables.validate(1, "F")
      assert :ok = Tables.validate(8, "AA")
      assert :ok = Tables.validate(76, "ADT")
      assert :ok = Tables.validate(103, "P")
      assert :ok = Tables.validate(104, "2.5.1")
    end

    test "returns {:error, message} for invalid codes" do
      assert {:error, msg} = Tables.validate(1, "ZZ")
      assert msg =~ "invalid code"
      assert msg =~ "ZZ"
      assert msg =~ "0001"
      assert msg =~ "Administrative Sex"
    end

    test "error message includes zero-padded table ID" do
      assert {:error, msg} = Tables.validate(8, "XX")
      assert msg =~ "0008"
      assert msg =~ "Acknowledgment Code"
    end

    test "returns :ok for unknown table ID (cannot validate)" do
      assert :ok = Tables.validate(9999, "anything")
    end
  end

  describe "specific table contents" do
    test "table 0001 (Administrative Sex)" do
      table = Tables.get(1)
      assert table.name == "Administrative Sex"
      assert Map.has_key?(table.codes, "F")
      assert Map.has_key?(table.codes, "M")
      assert Map.has_key?(table.codes, "O")
      assert Map.has_key?(table.codes, "U")
    end

    test "table 0004 (Patient Class)" do
      table = Tables.get(4)
      assert table.name == "Patient Class"
      assert Map.has_key?(table.codes, "E")
      assert Map.has_key?(table.codes, "I")
      assert Map.has_key?(table.codes, "O")
    end

    test "table 0076 (Message Type)" do
      table = Tables.get(76)
      assert table.name == "Message Type"
      assert Map.has_key?(table.codes, "ACK")
      assert Map.has_key?(table.codes, "ADT")
      assert Map.has_key?(table.codes, "ORM")
      assert Map.has_key?(table.codes, "ORU")
      assert Map.has_key?(table.codes, "SIU")
    end

    test "table 0085 (Observation Result Status)" do
      table = Tables.get(85)
      assert table.name == "Observation Result Status"

      for code <- ~w(C D F I N O P R S U W X) do
        assert Map.has_key?(table.codes, code), "expected #{code} in table 0085"
      end
    end

    test "table 0103 (Processing ID)" do
      table = Tables.get(103)
      assert table.name == "Processing ID"
      assert map_size(table.codes) == 3
      assert Map.has_key?(table.codes, "D")
      assert Map.has_key?(table.codes, "P")
      assert Map.has_key?(table.codes, "T")
    end

    test "table 0104 (Version ID)" do
      table = Tables.get(104)
      assert table.name == "Version ID"
      assert Map.has_key?(table.codes, "2.5.1")
      assert Map.has_key?(table.codes, "2.3")
    end

    test "table 0396 (Coding System)" do
      table = Tables.get(396)
      assert table.name == "Coding System"
      assert Map.has_key?(table.codes, "DCM")
      assert Map.has_key?(table.codes, "LN")
      assert Map.has_key?(table.codes, "SCT")
      assert Map.has_key?(table.codes, "SNM")
      assert Map.has_key?(table.codes, "I10")
    end
  end

  describe "integration: table validation in message validate" do
    test "table checking disabled by default ignores invalid codes" do
      msg = msg_with_invalid_processing_id()
      # Default: no table validation
      result = HL7v2.validate(msg)
      # Should not error on invalid processing_id value
      case result do
        :ok ->
          :ok

        {:ok, _warnings} ->
          :ok

        {:error, errors} ->
          table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
          assert table_errors == [], "should not have table errors when validate_tables is false"
      end
    end

    test "table checking enabled catches invalid processing_id" do
      msg = msg_with_invalid_processing_id()
      result = HL7v2.validate(msg, validate_tables: true)

      case result do
        {:error, errors} ->
          table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
          assert length(table_errors) >= 1
          assert Enum.any?(table_errors, &(&1.field == :processing_id))

        {:ok, _} ->
          flunk("expected errors for invalid processing_id")

        :ok ->
          flunk("expected errors for invalid processing_id")
      end
    end

    test "table checking enabled passes valid codes" do
      msg = valid_typed_message()
      result = HL7v2.validate(msg, validate_tables: true)

      case result do
        :ok ->
          :ok

        {:ok, _warnings} ->
          :ok

        {:error, errors} ->
          table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))

          assert table_errors == [],
                 "valid message should have no table errors, got: #{inspect(table_errors)}"
      end
    end

    test "table checking catches invalid patient_class on PV1" do
      msg = msg_with_invalid_patient_class()
      result = HL7v2.validate(msg, validate_tables: true)

      case result do
        {:error, errors} ->
          table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
          assert Enum.any?(table_errors, &(&1.field == :patient_class))

        _ ->
          flunk("expected table error for invalid patient_class")
      end
    end

    test "table checking catches invalid message_code on MSH" do
      msg = msg_with_invalid_message_code()
      result = HL7v2.validate(msg, validate_tables: true)

      case result do
        {:error, errors} ->
          table_errors = Enum.filter(errors, &(&1.message =~ "invalid code"))
          assert Enum.any?(table_errors, &(&1.field == :message_type and &1.location == "MSH"))

        _ ->
          flunk("expected table error for invalid message_code")
      end
    end

    test "table checking catches invalid acknowledgment_code on MSA" do
      result =
        HL7v2.Validation.FieldRules.check(
          %HL7v2.Segment.MSA{acknowledgment_code: "ZZ", message_control_id: "MSG001"},
          validate_tables: true
        )

      table_errors = Enum.filter(result, &(&1.message =~ "invalid code"))
      assert length(table_errors) == 1
      assert hd(table_errors).field == :acknowledgment_code
    end

    test "table checking catches invalid observation_result_status on OBX" do
      result =
        HL7v2.Validation.FieldRules.check(
          %HL7v2.Segment.OBX{
            observation_identifier: %HL7v2.Type.CE{identifier: "1234"},
            observation_result_status: "Q",
            value_type: "NM"
          },
          validate_tables: true
        )

      table_errors = Enum.filter(result, &(&1.message =~ "invalid code"))
      assert length(table_errors) == 1
      assert hd(table_errors).field == :observation_result_status
    end

    test "table checking catches invalid value_type on OBX" do
      result =
        HL7v2.Validation.FieldRules.check(
          %HL7v2.Segment.OBX{
            observation_identifier: %HL7v2.Type.CE{identifier: "1234"},
            observation_result_status: "F",
            value_type: "INVALID"
          },
          validate_tables: true
        )

      table_errors = Enum.filter(result, &(&1.message =~ "invalid code"))
      assert length(table_errors) == 1
      assert hd(table_errors).field == :value_type
    end

    test "table checking with valid OBX codes produces no table errors" do
      result =
        HL7v2.Validation.FieldRules.check(
          %HL7v2.Segment.OBX{
            observation_identifier: %HL7v2.Type.CE{identifier: "1234"},
            observation_result_status: "F",
            value_type: "NM"
          },
          validate_tables: true
        )

      table_errors = Enum.filter(result, &(&1.message =~ "invalid code"))
      assert table_errors == []
    end
  end

  # -- Helpers --

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

  defp valid_typed_message do
    %HL7v2.TypedMessage{
      separators: HL7v2.Separator.default(),
      type: {"ADT", "A01"},
      segments: [valid_msh(), valid_evn(), valid_pid(), valid_pv1()]
    }
  end

  defp msg_with_invalid_processing_id do
    msh = %{valid_msh() | processing_id: %HL7v2.Type.PT{processing_id: "X"}}

    %HL7v2.TypedMessage{
      separators: HL7v2.Separator.default(),
      type: {"ADT", "A01"},
      segments: [msh, valid_evn(), valid_pid(), valid_pv1()]
    }
  end

  defp msg_with_invalid_patient_class do
    pv1 = %HL7v2.Segment.PV1{patient_class: "ZZ"}

    %HL7v2.TypedMessage{
      separators: HL7v2.Separator.default(),
      type: {"ADT", "A01"},
      segments: [valid_msh(), valid_evn(), valid_pid(), pv1]
    }
  end

  defp msg_with_invalid_message_code do
    msh = %{
      valid_msh()
      | message_type: %HL7v2.Type.MSG{message_code: "BOGUS", trigger_event: "A01"}
    }

    %HL7v2.TypedMessage{
      separators: HL7v2.Separator.default(),
      type: {"ADT", "A01"},
      segments: [msh, valid_evn(), valid_pid(), valid_pv1()]
    }
  end
end
