defmodule HL7v2.Validation.FieldRules do
  @moduledoc """
  Field-level validation rules for HL7v2 typed segments.

  For each typed segment struct, checks:
  - Required fields (`:r` optionality) are not nil
  - Repeating fields with bounded `max_reps` do not exceed the limit
  - Coded fields against HL7-defined tables (opt-in via `validate_tables: true`)
  """

  alias HL7v2.Standard.Tables

  # Mapping of {segment_id, field_name} to HL7 table ID.
  # Only fields where we know the canonical table binding are listed.
  # Mapping of {segment_id, field_name} to {table_id, extraction_mode}.
  # :scalar — the field value is a plain string (ID/IS types)
  # :identifier — extract the :identifier component from a CE/CWE struct
  # :message_code — extract the :message_code component from an MSG struct
  # :processing_id — extract the :processing_id component from a PT struct
  # :version_id — extract the :version_id component from a VID struct
  @table_bindings %{
    # -- MSH (Message Header) --
    {"MSH", :message_type} => {76, :message_code},
    {"MSH", :processing_id} => {103, :processing_id},
    {"MSH", :version_id} => {104, :version_id},
    {"MSH", :accept_acknowledgment_type} => {155, :scalar},
    {"MSH", :application_acknowledgment_type} => {155, :scalar},
    {"MSH", :country_code} => {399, :scalar},
    {"MSH", :alternate_character_set_handling_scheme} => {356, :scalar},

    # -- MSA (Acknowledgment) --
    {"MSA", :acknowledgment_code} => {8, :scalar},

    # -- EVN (Event Type) --
    {"EVN", :event_type_code} => {3, :scalar},

    # -- ERR (Error) --
    {"ERR", :severity} => {516, :scalar},

    # -- PID (Patient Identification) --
    {"PID", :administrative_sex} => {1, :scalar},
    {"PID", :marital_status} => {2, :identifier},
    {"PID", :race} => {5, :identifier},
    {"PID", :religion} => {6, :identifier},
    {"PID", :ethnic_group} => {189, :identifier},
    {"PID", :citizenship} => {171, :identifier},
    {"PID", :veterans_military_status} => {172, :identifier},
    {"PID", :multiple_birth_indicator} => {136, :scalar},
    {"PID", :patient_death_indicator} => {136, :scalar},
    {"PID", :identity_unknown_indicator} => {136, :scalar},
    {"PID", :production_class_code} => {429, :identifier},

    # -- PV1 (Patient Visit) --
    {"PV1", :patient_class} => {4, :scalar},
    {"PV1", :admission_type} => {7, :scalar},
    {"PV1", :ambulatory_status} => {9, :scalar},
    {"PV1", :admit_source} => {23, :scalar},
    {"PV1", :patient_type} => {18, :scalar},
    {"PV1", :discharge_disposition} => {112, :scalar},
    {"PV1", :bed_status} => {116, :scalar},
    {"PV1", :account_status} => {117, :scalar},
    {"PV1", :visit_indicator} => {326, :scalar},
    {"PV1", :visit_user_code} => {130, :scalar},

    # -- PV2 (Patient Visit — Additional) --
    {"PV2", :visit_user_code} => {130, :scalar},
    {"PV2", :visit_priority_code} => {217, :scalar},
    {"PV2", :employment_illness_related_indicator} => {136, :scalar},
    {"PV2", :newborn_baby_indicator} => {136, :scalar},

    # -- NK1 (Next of Kin) --
    {"NK1", :relationship} => {63, :identifier},
    {"NK1", :contact_role} => {131, :identifier},
    {"NK1", :administrative_sex} => {1, :scalar},
    {"NK1", :marital_status} => {2, :identifier},
    {"NK1", :religion} => {6, :identifier},
    {"NK1", :handicap} => {295, :scalar},

    # -- AL1 (Allergy Information) --
    {"AL1", :allergen_type_code} => {127, :identifier},
    {"AL1", :allergy_severity_code} => {128, :identifier},

    # -- IAM (Patient Adverse Reaction) --
    {"IAM", :allergen_type_code} => {127, :identifier},
    {"IAM", :allergy_severity_code} => {128, :identifier},

    # -- DG1 (Diagnosis) --
    {"DG1", :diagnosis_type} => {52, :scalar},
    {"DG1", :diagnosis_classification} => {228, :scalar},
    {"DG1", :diagnosis_action_code} => {323, :scalar},

    # -- DRG (Diagnosis Related Group) --
    {"DRG", :drg_payor} => {229, :scalar},

    # -- NTE (Notes and Comments) --
    {"NTE", :source_of_comment} => {105, :scalar},
    {"NTE", :comment_type} => {364, :identifier},

    # -- ORC (Common Order) --
    {"ORC", :order_control} => {119, :scalar},
    {"ORC", :order_status} => {38, :scalar},
    {"ORC", :response_flag} => {121, :scalar},

    # -- OBR (Observation Request) --
    {"OBR", :specimen_action_code} => {65, :scalar},
    {"OBR", :result_status} => {123, :scalar},
    {"OBR", :diagnostic_serv_sect_id} => {74, :scalar},

    # -- OBX (Observation/Result) --
    {"OBX", :value_type} => {125, :scalar},
    {"OBX", :observation_result_status} => {85, :scalar},
    {"OBX", :nature_of_abnormal_test} => {80, :scalar},

    # -- IN1 (Insurance) --
    {"IN1", :insureds_administrative_sex} => {1, :scalar},
    {"IN1", :insureds_relationship_to_patient} => {63, :identifier},
    {"IN1", :notice_of_admission_flag} => {136, :scalar},
    {"IN1", :report_of_eligibility_flag} => {136, :scalar},

    # -- FT1 (Financial Transaction) --
    {"FT1", :transaction_type} => {17, :scalar},
    {"FT1", :patient_type} => {18, :scalar},

    # -- TXA (Transcription Document Header) --
    {"TXA", :document_completion_status} => {271, :scalar},
    {"TXA", :document_confidentiality_status} => {272, :scalar},
    {"TXA", :document_availability_status} => {273, :scalar},
    {"TXA", :document_storage_status} => {275, :scalar},

    # -- SCH (Scheduling Activity) --
    {"SCH", :filler_status_code} => {278, :identifier},
    {"SCH", :appointment_reason} => {276, :identifier},
    {"SCH", :appointment_type} => {277, :identifier},

    # -- AIS (Appointment Information — Service) --
    {"AIS", :segment_action_code} => {206, :scalar},
    {"AIS", :filler_status_code} => {278, :identifier},
    {"AIS", :allow_substitution_code} => {279, :scalar},

    # -- AIG (Appointment Information — General Resource) --
    {"AIG", :segment_action_code} => {206, :scalar},
    {"AIG", :filler_status_code} => {278, :identifier},
    {"AIG", :allow_substitution_code} => {279, :scalar},

    # -- RXR (Pharmacy Route) --
    {"RXR", :route} => {162, :identifier}
  }

  @doc """
  Returns a list of field-level validation errors/warnings for a single segment.

  Skips validation for:
  - `HL7v2.Segment.ZXX` (site-defined, no typed fields)
  - Raw tuples `{name, fields}` (not typed)

  ## Options

  - `:validate_tables` -- when `true`, checks coded fields against HL7 tables.
    Defaults to `false`.
  """
  @spec check(struct() | {binary(), list()}, keyword()) :: [map()]
  def check(segment, opts \\ [])

  def check(%HL7v2.Segment.ZXX{}, _opts), do: []
  def check({name, _fields}, _opts) when is_binary(name), do: []

  def check(%{__struct__: module} = segment, opts) do
    location = module.segment_id()
    field_defs = module.fields()
    validate_tables? = Keyword.get(opts, :validate_tables, false)
    mode = Keyword.get(opts, :mode, :lenient)

    field_errors =
      Enum.flat_map(field_defs, fn {_seq, name, _type, optionality, max_reps} ->
        value = Map.get(segment, name)

        required_errors(location, name, optionality, value) ++
          max_reps_errors(location, name, max_reps, value, mode) ++
          table_errors(location, name, value, validate_tables?)
      end)

    field_errors ++ conditional_errors(segment, location, mode)
  end

  defp required_errors(location, name, :r, value) do
    if semantic_blank?(value) do
      [
        %{
          level: :error,
          location: location,
          field: name,
          message: "required field #{name} is missing"
        }
      ]
    else
      []
    end
  end

  defp required_errors(_location, _name, _optionality, _value), do: []

  # A value is semantically blank if it's nil, an empty list, or a struct
  # where every field is nil (e.g., %XPN{} with all nil fields).
  defp semantic_blank?(nil), do: true
  defp semantic_blank?(""), do: true
  defp semantic_blank?([]), do: true

  defp semantic_blank?(list) when is_list(list) do
    Enum.all?(list, &semantic_blank?/1)
  end

  defp semantic_blank?(struct) when is_struct(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&semantic_blank?/1)
  end

  defp semantic_blank?(_), do: false

  # Non-repeating field (max_reps == 1) with a list-of-lists value — illegal repetition.
  # Flat lists (["M", "EXTRA"]) are extra components from non-conformant input, not repetitions.
  defp max_reps_errors(location, name, 1, value, mode)
       when is_list(value) and length(value) > 0 do
    has_nested_lists? = Enum.any?(value, &is_list/1)

    if has_nested_lists? do
      level = if mode == :strict, do: :error, else: :warning

      [
        %{
          level: level,
          location: location,
          field: name,
          message: "field #{name} has #{length(value)} repetitions but is not repeatable"
        }
      ]
    else
      []
    end
  end

  defp max_reps_errors(location, name, max_reps, value, mode)
       when is_integer(max_reps) and max_reps > 1 and is_list(value) do
    if length(value) > max_reps do
      level = if mode == :strict, do: :error, else: :warning

      [
        %{
          level: level,
          location: location,
          field: name,
          message: "field #{name} has #{length(value)} repetitions, max allowed is #{max_reps}"
        }
      ]
    else
      []
    end
  end

  defp max_reps_errors(_location, _name, _max_reps, _value, _mode), do: []

  # Table validation — only runs when validate_tables? is true and the field
  # has a known table binding. Returns errors for invalid coded values.
  defp table_errors(_location, _name, _value, false), do: []
  defp table_errors(_location, _name, nil, _validate?), do: []

  defp table_errors(location, name, value, true) do
    case Map.get(@table_bindings, {location, name}) do
      nil ->
        []

      {table_id, :scalar} ->
        validate_scalar(location, name, table_id, value)

      {table_id, subfield} ->
        validate_subfield(location, name, table_id, subfield, value)
    end
  end

  defp validate_scalar(_location, _name, _table_id, value) when not is_binary(value), do: []

  defp validate_scalar(location, name, table_id, value) do
    case Tables.validate(table_id, value) do
      :ok -> []
      {:error, msg} -> [table_error(location, name, msg)]
    end
  end

  # Repeating fields: validate each element in the list
  defp validate_subfield(location, name, table_id, subfield, values) when is_list(values) do
    Enum.flat_map(values, fn value ->
      validate_subfield(location, name, table_id, subfield, value)
    end)
  end

  defp validate_subfield(_location, _name, _table_id, _subfield, value)
       when not is_struct(value),
       do: []

  defp validate_subfield(location, name, table_id, subfield, value) do
    code = Map.get(value, subfield)

    if is_binary(code) do
      case Tables.validate(table_id, code) do
        :ok -> []
        {:error, msg} -> [table_error(location, name, msg)]
      end
    else
      []
    end
  end

  defp table_error(location, field, message) do
    %{level: :error, location: location, field: field, message: message}
  end

  # ---------------------------------------------------------------------------
  # Conditional field rules — checks for :c (conditional) fields
  # ---------------------------------------------------------------------------

  @doc """
  Returns a list of conditional-rule errors/warnings for a segment.

  Conditional rules are HL7-specified dependencies between fields. In strict
  mode they produce `:error`, in lenient mode `:warning`.
  """
  @spec conditional_errors(struct(), String.t(), atom()) :: [map()]
  def conditional_errors(segment, location, mode)

  # OBX: value_type (OBX-2) is required when observation_value (OBX-5) is populated
  def conditional_errors(%HL7v2.Segment.OBX{} = obx, location, mode) do
    cond_level = if mode == :strict, do: :error, else: :warning

    obx2_when_obx5 =
      if not semantic_blank?(obx.observation_value) and semantic_blank?(obx.value_type) do
        [
          %{
            level: cond_level,
            location: location,
            field: :value_type,
            message:
              "conditional field value_type is required when observation_value is populated"
          }
        ]
      else
        []
      end

    obx2_when_obx5
  end

  # MSH: accept_acknowledgment_type (MSH-15) and application_acknowledgment_type (MSH-16)
  # must be both populated or both empty
  def conditional_errors(%HL7v2.Segment.MSH{} = msh, location, mode) do
    cond_level = if mode == :strict, do: :error, else: :warning

    a15 = not semantic_blank?(msh.accept_acknowledgment_type)
    a16 = not semantic_blank?(msh.application_acknowledgment_type)

    if a15 != a16 do
      missing = if a15, do: :application_acknowledgment_type, else: :accept_acknowledgment_type

      [
        %{
          level: cond_level,
          location: location,
          field: missing,
          message:
            "conditional field #{missing} must be populated when its counterpart is (MSH-15 and MSH-16 should both be present or both absent)"
        }
      ]
    else
      []
    end
  end

  # NK1: nk_name (NK1-2) should be populated when set_id (NK1-1) is present
  def conditional_errors(%HL7v2.Segment.NK1{} = nk1, location, mode) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if not semantic_blank?(nk1.set_id) and semantic_blank?(nk1.nk_name) do
      [
        %{
          level: cond_level,
          location: location,
          field: :nk_name,
          message: "conditional field nk_name should be populated when set_id is present"
        }
      ]
    else
      []
    end
  end

  # ORC: order_control (ORC-1) is marked :r, but reinforce conditional logic:
  # placer_order_number (ORC-2) or filler_order_number (ORC-3) should be populated
  def conditional_errors(%HL7v2.Segment.ORC{} = orc, location, mode) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if semantic_blank?(orc.placer_order_number) and semantic_blank?(orc.filler_order_number) do
      [
        %{
          level: cond_level,
          location: location,
          field: :placer_order_number,
          message:
            "conditional: at least one of placer_order_number (ORC-2) or filler_order_number (ORC-3) should be populated"
        }
      ]
    else
      []
    end
  end

  # OBR: observation_date_time (OBR-7) required for results
  # result_status (OBR-25) conditionally required for result messages
  def conditional_errors(%HL7v2.Segment.OBR{} = obr, location, mode) do
    cond_level = if mode == :strict, do: :error, else: :warning

    # If result_status is present (this is a result), observation_date_time should be populated
    obr7_when_result =
      if not semantic_blank?(obr.result_status) and semantic_blank?(obr.observation_date_time) do
        [
          %{
            level: cond_level,
            location: location,
            field: :observation_date_time,
            message:
              "conditional field observation_date_time should be populated when result_status is present"
          }
        ]
      else
        []
      end

    # placer_order_number or filler_order_number should be populated
    obr2_or_3 =
      if semantic_blank?(obr.placer_order_number) and semantic_blank?(obr.filler_order_number) do
        [
          %{
            level: cond_level,
            location: location,
            field: :placer_order_number,
            message:
              "conditional: at least one of placer_order_number (OBR-2) or filler_order_number (OBR-3) should be populated"
          }
        ]
      else
        []
      end

    obr7_when_result ++ obr2_or_3
  end

  # SCH: placer_appointment_id (SCH-1) or filler_appointment_id (SCH-2) must be present
  def conditional_errors(%HL7v2.Segment.SCH{} = sch, location, mode) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if semantic_blank?(sch.placer_appointment_id) and semantic_blank?(sch.filler_appointment_id) do
      [
        %{
          level: cond_level,
          location: location,
          field: :placer_appointment_id,
          message:
            "conditional: at least one of placer_appointment_id (SCH-1) or filler_appointment_id (SCH-2) should be populated"
        }
      ]
    else
      []
    end
  end

  # AIS: segment_action_code (AIS-2) required for modification events
  def conditional_errors(%HL7v2.Segment.AIS{} = ais, location, mode) do
    cond_level = if mode == :strict, do: :error, else: :warning

    # segment_action_code is required when segment is used in an update/modification message
    # Since we can't always know the context, we check: if universal_service_identifier is
    # populated but segment_action_code is not, it could indicate a missing conditional field.
    # Only flag if both start_date_time and universal_service_identifier are present (active AIS).
    if not semantic_blank?(ais.universal_service_identifier) and
         not semantic_blank?(ais.start_date_time) and
         semantic_blank?(ais.segment_action_code) do
      [
        %{
          level: cond_level,
          location: location,
          field: :segment_action_code,
          message:
            "conditional field segment_action_code may be required for modification messages"
        }
      ]
    else
      []
    end
  end

  # AIG/AIL/AIP: segment_action_code required for modification events (same pattern as AIS)
  def conditional_errors(%mod{} = seg, location, mode)
      when mod in [HL7v2.Segment.AIG, HL7v2.Segment.AIL, HL7v2.Segment.AIP] do
    cond_level = if mode == :strict, do: :error, else: :warning

    has_content? =
      case mod do
        HL7v2.Segment.AIG -> not semantic_blank?(seg.resource_type)
        HL7v2.Segment.AIL -> not semantic_blank?(seg.location_resource_id)
        HL7v2.Segment.AIP -> not semantic_blank?(seg.personnel_resource_id)
      end

    if has_content? and semantic_blank?(seg.segment_action_code) do
      [%{level: cond_level, location: location, field: :segment_action_code,
         message: "conditional field segment_action_code may be required for modification messages"}]
    else
      []
    end
  end

  # RGS: segment_action_code conditional on modification context
  def conditional_errors(%HL7v2.Segment.RGS{} = rgs, location, mode) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if not semantic_blank?(rgs.set_id) and semantic_blank?(rgs.segment_action_code) do
      [%{level: cond_level, location: location, field: :segment_action_code,
         message: "conditional field segment_action_code may be required for modification messages"}]
    else
      []
    end
  end

  # ARQ: filler_appointment_id conditional — at least one of placer/filler required
  def conditional_errors(%HL7v2.Segment.ARQ{} = arq, location, mode) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if semantic_blank?(arq.placer_appointment_id) and semantic_blank?(arq.filler_appointment_id) do
      [%{level: cond_level, location: location, field: :placer_appointment_id,
         message: "conditional: at least one of placer_appointment_id or filler_appointment_id should be populated"}]
    else
      []
    end
  end

  # DG1: diagnosis_action_code conditional when used in update messages
  def conditional_errors(%HL7v2.Segment.DG1{} = dg1, location, mode) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if not semantic_blank?(dg1.diagnosis_identifier) and semantic_blank?(dg1.diagnosis_action_code) do
      [%{level: cond_level, location: location, field: :diagnosis_action_code,
         message: "conditional field diagnosis_action_code should be populated when diagnosis_identifier is present"}]
    else
      []
    end
  end

  # PID: species_code/breed_code conditional — breed requires species
  def conditional_errors(%HL7v2.Segment.PID{} = pid, location, mode) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if not semantic_blank?(pid.breed_code) and semantic_blank?(pid.species_code) do
      [%{level: cond_level, location: location, field: :species_code,
         message: "conditional field species_code is required when breed_code is populated"}]
    else
      []
    end
  end

  # PV2: prior_pending_location conditional on transfer events
  def conditional_errors(%HL7v2.Segment.PV2{} = _pv2, _location, _mode), do: []

  # QAK: query_tag conditional — should match original query tag
  def conditional_errors(%HL7v2.Segment.QAK{} = _qak, _location, _mode), do: []

  # MFE/MFA: mfn_control_id conditional on master file operations
  def conditional_errors(%mod{} = seg, location, mode)
      when mod in [HL7v2.Segment.MFE, HL7v2.Segment.MFA] do
    cond_level = if mode == :strict, do: :error, else: :warning

    if semantic_blank?(Map.get(seg, :mfn_control_id)) do
      [%{level: cond_level, location: location, field: :mfn_control_id,
         message: "conditional field mfn_control_id should be populated for master file operations"}]
    else
      []
    end
  end

  # Default: no conditional rules for segments without specific rules
  def conditional_errors(_segment, _location, _mode), do: []
end
