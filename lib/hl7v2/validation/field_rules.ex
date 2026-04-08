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
    # -- ABS (Abstract) --
    {"ABS", :caesarian_section_indicator} => {136, :scalar},

    # -- ACC (Accident) --
    {"ACC", :accident_job_related_indicator} => {136, :scalar},
    {"ACC", :accident_death_indicator} => {136, :scalar},
    {"ACC", :police_notified_indicator} => {136, :scalar},

    # -- AIG (Appointment Information — General Resource) --
    {"AIG", :segment_action_code} => {206, :scalar},
    {"AIG", :allow_substitution_code} => {279, :scalar},
    {"AIG", :filler_status_code} => {278, :identifier},

    # -- AIL (Appointment Information — Location Resource) --
    {"AIL", :segment_action_code} => {206, :scalar},
    {"AIL", :allow_substitution_code} => {279, :scalar},
    {"AIL", :filler_status_code} => {278, :identifier},

    # -- AIP (Appointment Information — Personnel Resource) --
    {"AIP", :segment_action_code} => {206, :scalar},
    {"AIP", :allow_substitution_code} => {279, :scalar},
    {"AIP", :filler_status_code} => {278, :identifier},

    # -- AIS (Appointment Information — Service) --
    {"AIS", :segment_action_code} => {206, :scalar},
    {"AIS", :allow_substitution_code} => {279, :scalar},
    {"AIS", :filler_status_code} => {278, :identifier},

    # -- AL1 (Allergy Information) --
    {"AL1", :allergen_type_code} => {127, :identifier},
    {"AL1", :allergy_severity_code} => {128, :identifier},

    # -- BLG (Billing) --
    {"BLG", :charge_type} => {122, :scalar},

    # -- BPO (Blood Product Order) --
    {"BPO", :bp_informed_consent_indicator} => {136, :scalar},

    # -- BPX (Blood Product Dispense Status) --
    {"BPX", :bp_status} => {511, :scalar},

    # -- BTX (Blood Product Transfusion/Disposition) --
    {"BTX", :bp_message_status} => {513, :scalar},

    # -- CDM (Charge Description Master) --
    {"CDM", :active_inactive_flag} => {183, :scalar},
    {"CDM", :room_fee_indicator} => {136, :scalar},

    # -- CER (Certificate Detail) --
    {"CER", :granting_country} => {399, :scalar},
    {"CER", :basic_constraint} => {136, :scalar},
    {"CER", :jurisdiction_country} => {399, :scalar},

    # -- CON (Consent) --
    {"CON", :subject_competence_indicator} => {136, :scalar},
    {"CON", :translator_assistance_indicator} => {136, :scalar},
    {"CON", :language_translated_to} => {399, :scalar},
    {"CON", :informational_material_supplied_indicator} => {136, :scalar},
    {"CON", :consent_disclosure_level} => {500, :scalar},

    # -- DB1 (Disability) --
    {"DB1", :disabled_indicator} => {136, :scalar},

    # -- DG1 (Diagnosis) --
    {"DG1", :diagnosis_coding_method} => {53, :scalar},
    {"DG1", :diagnosis_type} => {52, :scalar},
    {"DG1", :drg_approval_indicator} => {136, :scalar},
    {"DG1", :diagnosis_priority} => {359, :scalar},
    {"DG1", :diagnosis_classification} => {228, :scalar},
    {"DG1", :confidential_indicator} => {136, :scalar},
    {"DG1", :diagnosis_action_code} => {323, :scalar},

    # -- DRG (Diagnosis Related Group) --
    {"DRG", :drg_approval_indicator} => {136, :scalar},
    {"DRG", :drg_payor} => {229, :scalar},
    {"DRG", :confidential_indicator} => {136, :scalar},

    # -- DSC (Continuation Pointer) --
    {"DSC", :continuation_style} => {398, :scalar},

    # -- ECD (Equipment Command) --
    {"ECD", :response_required} => {136, :scalar},

    # -- EQL (Embedded Query Language) --
    {"EQL", :query_response_format_code} => {106, :scalar},

    # -- ERR (Error) --
    {"ERR", :severity} => {516, :scalar},

    # -- EVN (Event Type) --
    {"EVN", :event_type_code} => {3, :scalar},

    # -- FAC (Facility) --
    {"FAC", :facility_type} => {331, :scalar},

    # -- FT1 (Financial Transaction) --
    {"FT1", :transaction_type} => {17, :scalar},
    {"FT1", :patient_type} => {18, :scalar},

    # -- GOL (Goal Detail) --
    {"GOL", :action_code} => {287, :scalar},

    # -- GT1 (Guarantor) --
    {"GT1", :guarantor_billing_hold_flag} => {136, :scalar},
    {"GT1", :guarantor_death_flag} => {136, :scalar},
    {"GT1", :protection_indicator} => {136, :scalar},

    # -- IAM (Patient Adverse Reaction) --
    {"IAM", :allergen_type_code} => {127, :identifier},
    {"IAM", :allergy_severity_code} => {128, :identifier},

    # -- IN1 (Insurance) --
    {"IN1", :insureds_administrative_sex} => {1, :scalar},
    {"IN1", :insureds_relationship_to_patient} => {63, :identifier},
    {"IN1", :notice_of_admission_flag} => {136, :scalar},
    {"IN1", :report_of_eligibility_flag} => {136, :scalar},

    # -- IN2 (Insurance Additional) --
    {"IN2", :military_non_avail_cert_on_file} => {136, :scalar},
    {"IN2", :baby_coverage} => {136, :scalar},
    {"IN2", :combine_baby_bill} => {136, :scalar},
    {"IN2", :protection_indicator} => {136, :scalar},
    {"IN2", :suspend_flag} => {136, :scalar},
    {"IN2", :copay_limit_flag} => {136, :scalar},
    {"IN2", :stoploss_limit_flag} => {136, :scalar},

    # -- IN3 (Insurance Additional — Certification) --
    {"IN3", :certification_required} => {136, :scalar},

    # -- LDP (Location Department) --
    {"LDP", :active_inactive_flag} => {183, :scalar},

    # -- MFA (Master File Acknowledgment) --
    {"MFA", :record_level_event_code} => {180, :scalar},
    {"MFA", :primary_key_value_type_mfe} => {355, :scalar},

    # -- MFE (Master File Entry) --
    {"MFE", :record_level_event_code} => {180, :scalar},
    {"MFE", :primary_key_value_type} => {355, :scalar},

    # -- MFI (Master File Identification) --
    {"MFI", :file_level_event_code} => {178, :scalar},
    {"MFI", :response_level_code} => {179, :scalar},

    # -- MSA (Acknowledgment) --
    {"MSA", :acknowledgment_code} => {8, :scalar},
    {"MSA", :delayed_acknowledgment_type} => {102, :scalar},

    # -- MSH (Message Header) --
    {"MSH", :message_type} => {76, :message_code},
    {"MSH", :processing_id} => {103, :processing_id},
    {"MSH", :version_id} => {104, :version_id},
    {"MSH", :accept_acknowledgment_type} => {155, :scalar},
    {"MSH", :application_acknowledgment_type} => {155, :scalar},
    {"MSH", :country_code} => {399, :scalar},
    {"MSH", :character_set} => {211, :scalar},
    {"MSH", :alternate_character_set_handling_scheme} => {356, :scalar},

    # -- NK1 (Next of Kin) --
    {"NK1", :relationship} => {63, :identifier},
    {"NK1", :contact_role} => {131, :identifier},
    {"NK1", :administrative_sex} => {1, :scalar},
    {"NK1", :marital_status} => {2, :identifier},
    {"NK1", :religion} => {6, :identifier},
    {"NK1", :protection_indicator} => {136, :scalar},
    {"NK1", :handicap} => {295, :scalar},

    # -- NST (Application Control Level Statistics) --
    {"NST", :statistics_available} => {136, :scalar},
    {"NST", :source_type} => {332, :scalar},

    # -- NTE (Notes and Comments) --
    {"NTE", :source_of_comment} => {105, :scalar},
    {"NTE", :comment_type} => {364, :identifier},

    # -- OBR (Observation Request) --
    {"OBR", :priority} => {27, :scalar},
    {"OBR", :specimen_action_code} => {65, :scalar},
    {"OBR", :diagnostic_serv_sect_id} => {74, :scalar},
    {"OBR", :result_status} => {123, :scalar},
    {"OBR", :transportation_mode} => {124, :scalar},
    {"OBR", :transport_arranged} => {224, :scalar},
    {"OBR", :escort_required} => {225, :scalar},

    # -- OBX (Observation/Result) --
    {"OBX", :value_type} => {125, :scalar},
    {"OBX", :observation_result_status} => {85, :scalar},
    {"OBX", :nature_of_abnormal_test} => {80, :scalar},

    # -- ODS (Dietary Orders, Supplements, and Preferences) --
    {"ODS", :type} => {159, :scalar},

    # -- OM1 (General Segment) --
    {"OM1", :permitted_data_types} => {125, :scalar},
    {"OM1", :specimen_required} => {136, :scalar},
    {"OM1", :orderability} => {136, :scalar},
    {"OM1", :portable_device_indicator} => {136, :scalar},
    {"OM1", :processing_priority} => {168, :scalar},
    {"OM1", :reporting_priority} => {169, :scalar},

    # -- OM3 (Categorical Service/Test/Observation) --
    {"OM3", :value_type} => {125, :scalar},

    # -- OM4 (Observations that Require Specimens) --
    {"OM4", :derived_specimen} => {170, :scalar},
    {"OM4", :specimen_priorities} => {27, :scalar},

    # -- OM7 (Additional Basic Attributes) --
    {"OM7", :consent_indicator} => {136, :scalar},
    {"OM7", :special_order_indicator} => {136, :scalar},

    # -- ORC (Common Order) --
    {"ORC", :order_control} => {119, :scalar},
    {"ORC", :order_status} => {38, :scalar},
    {"ORC", :response_flag} => {121, :scalar},

    # -- ORG (Practitioner Organization Unit) --
    {"ORG", :primary_org_unit_indicator} => {136, :scalar},
    {"ORG", :board_approval_indicator} => {136, :scalar},
    {"ORG", :primary_care_physician_indicator} => {136, :scalar},

    # -- PCR (Possible Causal Relationship) --
    {"PCR", :evaluated_product_source} => {248, :scalar},
    {"PCR", :device_operator_qualifications} => {242, :scalar},
    {"PCR", :relatedness_assessment} => {250, :scalar},
    {"PCR", :action_taken_in_response_to_the_event} => {251, :scalar},
    {"PCR", :event_causality_observations} => {252, :scalar},
    {"PCR", :indirect_exposure_mechanism} => {253, :scalar},

    # -- PD1 (Patient Additional Demographic) --
    {"PD1", :protection_indicator} => {136, :scalar},
    {"PD1", :separate_bill} => {136, :scalar},

    # -- PDA (Patient Death and Autopsy) --
    {"PDA", :death_certified_indicator} => {136, :scalar},
    {"PDA", :autopsy_indicator} => {136, :scalar},
    {"PDA", :coroner_indicator} => {136, :scalar},

    # -- PDC (Product Detail Country) --
    {"PDC", :marketing_basis} => {330, :scalar},

    # -- PEO (Product Experience Observation) --
    {"PEO", :event_qualification} => {237, :scalar},
    {"PEO", :event_serious} => {238, :scalar},
    {"PEO", :event_expected} => {239, :scalar},
    {"PEO", :event_outcome} => {240, :scalar},
    {"PEO", :patient_outcome} => {241, :scalar},
    {"PEO", :primary_observers_qualification} => {242, :scalar},
    {"PEO", :confirmation_provided_by} => {242, :scalar},
    {"PEO", :primary_observers_identity_may_be_divulged} => {243, :scalar},

    # -- PES (Product Experience Sender) --
    {"PES", :event_report_timing_type} => {234, :scalar},
    {"PES", :event_report_source} => {235, :scalar},
    {"PES", :event_reported_to} => {236, :scalar},

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

    # -- PR1 (Procedures) --
    {"PR1", :procedure_priority} => {418, :scalar},
    {"PR1", :procedure_action_code} => {323, :scalar},

    # -- PRA (Practitioner Detail) --
    {"PRA", :provider_billing} => {187, :scalar},

    # -- PRB (Problem Detail) --
    {"PRB", :action_code} => {287, :scalar},

    # -- PRC (Pricing) --
    {"PRC", :chargeable_flag} => {136, :scalar},
    {"PRC", :active_inactive_flag} => {183, :scalar},

    # -- PSH (Product Summary Header) --
    {"PSH", :quantity_distributed_method} => {329, :scalar},
    {"PSH", :quantity_in_use_method} => {329, :scalar},

    # -- PTH (Pathway) --
    {"PTH", :action_code} => {287, :scalar},

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
    {"PV2", :retention_indicator} => {136, :scalar},
    {"PV2", :visit_priority_code} => {217, :scalar},
    {"PV2", :visit_protection_indicator} => {136, :scalar},
    {"PV2", :billing_media_code} => {136, :scalar},
    {"PV2", :military_partnership_code} => {136, :scalar},
    {"PV2", :military_non_availability_code} => {136, :scalar},
    {"PV2", :newborn_baby_indicator} => {136, :scalar},
    {"PV2", :baby_detained_indicator} => {136, :scalar},
    {"PV2", :employment_illness_related_indicator} => {136, :scalar},

    # -- QAK (Query Acknowledgment) --
    {"QAK", :query_response_status} => {208, :scalar},

    # -- QRD (Original-Style Query Definition) --
    {"QRD", :query_format_code} => {106, :scalar},
    {"QRD", :query_priority} => {91, :scalar},
    {"QRD", :deferred_response_type} => {107, :scalar},
    {"QRD", :query_results_level} => {108, :scalar},

    # -- QRF (Original Style Query Filter) --
    {"QRF", :which_date_time_qualifier} => {156, :scalar},
    {"QRF", :which_date_time_status_qualifier} => {157, :scalar},
    {"QRF", :date_time_selection_qualifier} => {158, :scalar},

    # -- RCP (Response Control Parameter) --
    {"RCP", :query_priority} => {91, :scalar},
    {"RCP", :modify_indicator} => {395, :scalar},

    # -- RGS (Resource Group) --
    {"RGS", :segment_action_code} => {206, :scalar},

    # -- ROL (Role) --
    {"ROL", :action_code} => {287, :scalar},

    # -- RQ1 (Requisition Detail-1) --
    {"RQ1", :taxable} => {136, :scalar},
    {"RQ1", :substitute_allowed} => {136, :scalar},

    # -- RXA (Pharmacy/Treatment Administration) --
    {"RXA", :completion_status} => {322, :scalar},
    {"RXA", :action_code} => {323, :scalar},
    {"RXA", :pharmacy_order_type} => {480, :scalar},

    # -- RXC (Pharmacy/Treatment Component Order) --
    {"RXC", :rx_component_type} => {166, :scalar},

    # -- RXD (Pharmacy/Treatment Dispense) --
    {"RXD", :substitution_status} => {167, :scalar},
    {"RXD", :needs_human_review} => {136, :scalar},
    {"RXD", :dispense_package_method} => {321, :scalar},
    {"RXD", :pharmacy_order_type} => {480, :scalar},

    # -- RXE (Pharmacy/Treatment Encoded Order) --
    {"RXE", :substitution_status} => {167, :scalar},
    {"RXE", :needs_human_review} => {136, :scalar},
    {"RXE", :dispense_package_method} => {321, :scalar},
    {"RXE", :formulary_status} => {136, :scalar},
    {"RXE", :pharmacy_order_type} => {480, :scalar},

    # -- RXG (Pharmacy/Treatment Give) --
    {"RXG", :substitution_status} => {167, :scalar},
    {"RXG", :needs_human_review} => {136, :scalar},
    {"RXG", :pharmacy_order_type} => {480, :scalar},

    # -- RXO (Pharmacy/Treatment Order) --
    {"RXO", :allow_substitutions} => {161, :scalar},
    {"RXO", :needs_human_review} => {136, :scalar},

    # -- RXR (Pharmacy Route) --
    {"RXR", :route} => {162, :identifier},

    # -- SCH (Scheduling Activity) --
    {"SCH", :filler_status_code} => {278, :identifier},
    {"SCH", :appointment_reason} => {276, :identifier},
    {"SCH", :appointment_type} => {277, :identifier},

    # -- SPM (Specimen) --
    {"SPM", :specimen_availability} => {136, :scalar},

    # -- SPR (Stored Procedure Request) --
    {"SPR", :query_response_format_code} => {106, :scalar},

    # -- STF (Staff Identification) --
    {"STF", :active_inactive_flag} => {183, :scalar},
    {"STF", :additional_insured_on_auto} => {136, :scalar},
    {"STF", :copy_auto_ins} => {136, :scalar},
    {"STF", :re_activation_approval_indicator} => {136, :scalar},
    {"STF", :death_indicator} => {136, :scalar},
    {"STF", :generic_classification_indicator} => {136, :scalar},

    # -- TCC (Test Code Configuration) --
    {"TCC", :automatic_rerun_allowed} => {136, :scalar},
    {"TCC", :automatic_repeat_allowed} => {136, :scalar},
    {"TCC", :automatic_reflex_allowed} => {136, :scalar},

    # -- TCD (Test Code Detail) --
    {"TCD", :automatic_repeat_allowed} => {136, :scalar},
    {"TCD", :reflex_allowed} => {136, :scalar},

    # -- TQ1 (Timing/Quantity) --
    {"TQ1", :conjunction} => {472, :scalar},

    # -- TQ2 (Timing/Quantity Relationship) --
    {"TQ2", :sequence_results_flag} => {503, :scalar},
    {"TQ2", :sequence_condition_code} => {504, :scalar},
    {"TQ2", :cyclic_entry_exit_indicator} => {505, :scalar},
    {"TQ2", :special_service_request_relationship} => {506, :scalar},

    # -- TXA (Transcription Document Header) --
    {"TXA", :document_content_presentation} => {191, :scalar},
    {"TXA", :document_completion_status} => {271, :scalar},
    {"TXA", :document_confidentiality_status} => {272, :scalar},
    {"TXA", :document_availability_status} => {273, :scalar},
    {"TXA", :document_storage_status} => {275, :scalar},

    # -- UB1 (UB82 Data) --
    {"UB1", :priority} => {27, :scalar},
    {"UB1", :special_program_code} => {348, :scalar},

    # -- URD (Results/Update Definition) --
    {"URD", :report_priority} => {109, :scalar},
    {"URD", :r_u_results_level} => {108, :scalar},

    # -- URS (Unsolicited Selection) --
    {"URS", :r_u_which_date_time_qualifier} => {156, :scalar},
    {"URS", :r_u_which_date_time_status_qualifier} => {157, :scalar},
    {"URS", :r_u_date_time_selection_qualifier} => {158, :scalar},

    # -- VTQ (Virtual Table Query Request) --
    {"VTQ", :query_response_format_code} => {106, :scalar}
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
    context = Keyword.get(opts, :context, %{})

    field_errors =
      Enum.flat_map(field_defs, fn {_seq, name, _type, optionality, max_reps} ->
        value = Map.get(segment, name)

        required_errors(location, name, optionality, value) ++
          max_reps_errors(location, name, max_reps, value, mode) ++
          table_errors(location, name, value, validate_tables?)
      end)

    field_errors ++ conditional_errors(segment, location, mode, context)
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

  # Scheduling modification triggers (SIU Chapter 10):
  # S03=Notification of appointment modification, S04=Notification of appointment cancellation,
  # S05=Notification of appointment discontinuation, S06=Notification of appointment deletion,
  # S07=Notification of filler appointment modification, S08=Notification of filler appointment cancellation,
  # S09=Notification of filler appointment discontinuation, S10=Notification of filler appointment deletion,
  # S11=Notification of appointment placement
  @scheduling_modification_triggers MapSet.new(~w(S03 S04 S05 S06 S07 S08 S09 S10 S11))

  # Transfer triggers (ADT Chapter 3): events where prior_pending_location (PV2-1) is conditional
  @transfer_triggers MapSet.new(~w(A02 A06 A07 A12 A15 A25 A26 A27 A28 A31))

  @doc """
  Returns a list of conditional-rule errors/warnings for a segment.

  Conditional rules are HL7-specified dependencies between fields. In strict
  mode they produce `:error`, in lenient mode `:warning`.

  An optional `context` map may contain `:trigger_event` and `:message_code`
  extracted from MSH-9. When provided, trigger-aware rules (e.g., scheduling
  modification segments, PV2 transfer events) use definitive checks instead
  of heuristic approximations.

  ## Examples

      # Without context (backwards compatible)
      conditional_errors(segment, "AIS", :lenient)

      # With trigger context
      conditional_errors(segment, "AIS", :strict, %{trigger_event: "S03", message_code: "SIU"})

  """
  @spec conditional_errors(struct(), String.t(), atom(), map()) :: [map()]
  def conditional_errors(segment, location, mode, context \\ %{})

  # OBX: value_type (OBX-2) is required when observation_value (OBX-5) is populated
  def conditional_errors(%HL7v2.Segment.OBX{} = obx, location, mode, _context) do
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
  def conditional_errors(%HL7v2.Segment.MSH{} = msh, location, mode, _context) do
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
  def conditional_errors(%HL7v2.Segment.NK1{} = nk1, location, mode, _context) do
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
  def conditional_errors(%HL7v2.Segment.ORC{} = orc, location, mode, _context) do
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
  def conditional_errors(%HL7v2.Segment.OBR{} = obr, location, mode, _context) do
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
  def conditional_errors(%HL7v2.Segment.SCH{} = sch, location, mode, _context) do
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
  def conditional_errors(%HL7v2.Segment.AIS{} = ais, location, mode, context) do
    trigger = Map.get(context, :trigger_event)

    cond do
      # Trigger is a known scheduling modification event: definitive check
      is_binary(trigger) and MapSet.member?(@scheduling_modification_triggers, trigger) ->
        if semantic_blank?(ais.segment_action_code) do
          level = if mode == :strict, do: :error, else: :warning

          [
            %{
              level: level,
              location: location,
              field: :segment_action_code,
              message:
                "conditional field segment_action_code is required for modification event #{trigger}"
            }
          ]
        else
          []
        end

      # Trigger is known but NOT a modification event: skip entirely
      is_binary(trigger) ->
        []

      # No trigger context: fall back to heuristic (backwards compat)
      true ->
        if not semantic_blank?(ais.universal_service_identifier) and
             not semantic_blank?(ais.start_date_time) and
             semantic_blank?(ais.segment_action_code) do
          cond_level = if mode == :strict, do: :error, else: :warning

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
  end

  # AIG/AIL/AIP: segment_action_code required for modification events (same pattern as AIS)
  def conditional_errors(%mod{} = seg, location, mode, context)
      when mod in [HL7v2.Segment.AIG, HL7v2.Segment.AIL, HL7v2.Segment.AIP] do
    trigger = Map.get(context, :trigger_event)

    cond do
      # Trigger is a known scheduling modification event: definitive check
      is_binary(trigger) and MapSet.member?(@scheduling_modification_triggers, trigger) ->
        if semantic_blank?(seg.segment_action_code) do
          level = if mode == :strict, do: :error, else: :warning

          [
            %{
              level: level,
              location: location,
              field: :segment_action_code,
              message:
                "conditional field segment_action_code is required for modification event #{trigger}"
            }
          ]
        else
          []
        end

      # Trigger is known but NOT a modification event: skip entirely
      is_binary(trigger) ->
        []

      # No trigger context: fall back to heuristic
      true ->
        has_content? =
          case mod do
            HL7v2.Segment.AIG -> not semantic_blank?(seg.resource_type)
            HL7v2.Segment.AIL -> not semantic_blank?(seg.location_resource_id)
            HL7v2.Segment.AIP -> not semantic_blank?(seg.personnel_resource_id)
          end

        if has_content? and semantic_blank?(seg.segment_action_code) do
          cond_level = if mode == :strict, do: :error, else: :warning

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
  end

  # RGS: segment_action_code conditional on modification context
  def conditional_errors(%HL7v2.Segment.RGS{} = rgs, location, mode, context) do
    trigger = Map.get(context, :trigger_event)

    cond do
      # Trigger is a known scheduling modification event: definitive check
      is_binary(trigger) and MapSet.member?(@scheduling_modification_triggers, trigger) ->
        if semantic_blank?(rgs.segment_action_code) do
          level = if mode == :strict, do: :error, else: :warning

          [
            %{
              level: level,
              location: location,
              field: :segment_action_code,
              message:
                "conditional field segment_action_code is required for modification event #{trigger}"
            }
          ]
        else
          []
        end

      # Trigger is known but NOT a modification event: skip entirely
      is_binary(trigger) ->
        []

      # No trigger context: fall back to heuristic
      true ->
        if not semantic_blank?(rgs.set_id) and semantic_blank?(rgs.segment_action_code) do
          cond_level = if mode == :strict, do: :error, else: :warning

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
  end

  # ARQ: filler_appointment_id conditional — at least one of placer/filler required
  def conditional_errors(%HL7v2.Segment.ARQ{} = arq, location, mode, _context) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if semantic_blank?(arq.placer_appointment_id) and semantic_blank?(arq.filler_appointment_id) do
      [
        %{
          level: cond_level,
          location: location,
          field: :placer_appointment_id,
          message:
            "conditional: at least one of placer_appointment_id or filler_appointment_id should be populated"
        }
      ]
    else
      []
    end
  end

  # DG1: diagnosis_action_code conditional when used in update messages
  def conditional_errors(%HL7v2.Segment.DG1{} = dg1, location, mode, _context) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if not semantic_blank?(dg1.diagnosis_identifier) and
         semantic_blank?(dg1.diagnosis_action_code) do
      [
        %{
          level: cond_level,
          location: location,
          field: :diagnosis_action_code,
          message:
            "conditional field diagnosis_action_code should be populated when diagnosis_identifier is present"
        }
      ]
    else
      []
    end
  end

  # PID: species_code/breed_code conditional — breed requires species
  def conditional_errors(%HL7v2.Segment.PID{} = pid, location, mode, _context) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if not semantic_blank?(pid.breed_code) and semantic_blank?(pid.species_code) do
      [
        %{
          level: cond_level,
          location: location,
          field: :species_code,
          message: "conditional field species_code is required when breed_code is populated"
        }
      ]
    else
      []
    end
  end

  # PV2: expected_discharge_disposition (PV2-27) should be populated when
  # expected_discharge_date_time (PV2-9) is set.
  # PV2-1 (prior_pending_location) is conditional on transfer event context.
  def conditional_errors(%HL7v2.Segment.PV2{} = pv2, location, mode, context) do
    cond_level = if mode == :strict, do: :error, else: :warning

    discharge_errors =
      if not semantic_blank?(pv2.expected_discharge_date_time) and
           semantic_blank?(pv2.expected_discharge_disposition) do
        [
          %{
            level: cond_level,
            location: location,
            field: :expected_discharge_disposition,
            message:
              "conditional field expected_discharge_disposition should be populated when expected_discharge_date_time is set"
          }
        ]
      else
        []
      end

    trigger = Map.get(context, :trigger_event)

    transfer_errors =
      if is_binary(trigger) and MapSet.member?(@transfer_triggers, trigger) and
           semantic_blank?(pv2.prior_pending_location) do
        [
          %{
            level: cond_level,
            location: location,
            field: :prior_pending_location,
            message:
              "conditional field prior_pending_location should be populated for transfer event #{trigger}"
          }
        ]
      else
        []
      end

    discharge_errors ++ transfer_errors
  end

  # QAK: query_response_status (QAK-2) should be populated when query_tag (QAK-1) is present.
  # Note: query_tag should also match the original query's QPD-2, but that requires
  # cross-segment context not available at segment scope.
  def conditional_errors(%HL7v2.Segment.QAK{} = qak, location, mode, _context) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if not semantic_blank?(qak.query_tag) and semantic_blank?(qak.query_response_status) do
      [
        %{
          level: cond_level,
          location: location,
          field: :query_response_status,
          message:
            "conditional field query_response_status should be populated when query_tag is present"
        }
      ]
    else
      []
    end
  end

  # MFE/MFA: mfn_control_id conditional on master file operations
  def conditional_errors(%mod{} = seg, location, mode, _context)
      when mod in [HL7v2.Segment.MFE, HL7v2.Segment.MFA] do
    cond_level = if mode == :strict, do: :error, else: :warning

    if semantic_blank?(Map.get(seg, :mfn_control_id)) do
      [
        %{
          level: cond_level,
          location: location,
          field: :mfn_control_id,
          message:
            "conditional field mfn_control_id should be populated for master file operations"
        }
      ]
    else
      []
    end
  end

  # BPX: Blood Product Dispense Status — donation vs commercial product mutual exclusion
  # BPX-5 (bc_donation_id) required when BPX-8 (cp_commercial_product) is not populated
  # BPX-6 (bc_component) required when BPX-5 (bc_donation_id) is populated
  # BPX-8 (cp_commercial_product) required when BPX-5 (bc_donation_id) is not populated
  # BPX-9 (cp_manufacturer) required when BPX-8 (cp_commercial_product) is populated
  # BPX-10 (cp_lot_number) required when BPX-8 (cp_commercial_product) is populated
  def conditional_errors(%HL7v2.Segment.BPX{} = bpx, location, mode, _context) do
    cond_level = if mode == :strict, do: :error, else: :warning
    donation? = not semantic_blank?(bpx.bc_donation_id)
    commercial? = not semantic_blank?(bpx.cp_commercial_product)

    donation_when_no_commercial =
      if not donation? and not commercial? do
        [
          %{
            level: cond_level,
            location: location,
            field: :bc_donation_id,
            message:
              "conditional: at least one of bc_donation_id (BPX-5) or cp_commercial_product (BPX-8) must be populated"
          }
        ]
      else
        []
      end

    component_when_donation =
      if donation? and semantic_blank?(bpx.bc_component) do
        [
          %{
            level: cond_level,
            location: location,
            field: :bc_component,
            message: "conditional field bc_component is required when bc_donation_id is populated"
          }
        ]
      else
        []
      end

    manufacturer_when_commercial =
      if commercial? and semantic_blank?(bpx.cp_manufacturer) do
        [
          %{
            level: cond_level,
            location: location,
            field: :cp_manufacturer,
            message:
              "conditional field cp_manufacturer is required when cp_commercial_product is populated"
          }
        ]
      else
        []
      end

    lot_number_when_commercial =
      if commercial? and semantic_blank?(bpx.cp_lot_number) do
        [
          %{
            level: cond_level,
            location: location,
            field: :cp_lot_number,
            message:
              "conditional field cp_lot_number is required when cp_commercial_product is populated"
          }
        ]
      else
        []
      end

    donation_when_no_commercial ++
      component_when_donation ++ manufacturer_when_commercial ++ lot_number_when_commercial
  end

  # BTX: Blood Product Transfusion — same donation vs commercial pattern as BPX
  # BTX-2 (bc_donation_id) required when BTX-5 (cp_commercial_product) is not populated
  # BTX-3 (bc_component) required when BTX-2 (bc_donation_id) is populated
  # BTX-5 (cp_commercial_product) required when BTX-2 (bc_donation_id) is not populated
  # BTX-6 (cp_manufacturer) required when BTX-5 (cp_commercial_product) is populated
  # BTX-7 (cp_lot_number) required when BTX-5 (cp_commercial_product) is populated
  # BTX-20 (bp_unique_id) required when message status indicates completion
  def conditional_errors(%HL7v2.Segment.BTX{} = btx, location, mode, _context) do
    cond_level = if mode == :strict, do: :error, else: :warning
    donation? = not semantic_blank?(btx.bc_donation_id)
    commercial? = not semantic_blank?(btx.cp_commercial_product)

    donation_when_no_commercial =
      if not donation? and not commercial? do
        [
          %{
            level: cond_level,
            location: location,
            field: :bc_donation_id,
            message:
              "conditional: at least one of bc_donation_id (BTX-2) or cp_commercial_product (BTX-5) must be populated"
          }
        ]
      else
        []
      end

    component_when_donation =
      if donation? and semantic_blank?(btx.bc_component) do
        [
          %{
            level: cond_level,
            location: location,
            field: :bc_component,
            message: "conditional field bc_component is required when bc_donation_id is populated"
          }
        ]
      else
        []
      end

    manufacturer_when_commercial =
      if commercial? and semantic_blank?(btx.cp_manufacturer) do
        [
          %{
            level: cond_level,
            location: location,
            field: :cp_manufacturer,
            message:
              "conditional field cp_manufacturer is required when cp_commercial_product is populated"
          }
        ]
      else
        []
      end

    lot_number_when_commercial =
      if commercial? and semantic_blank?(btx.cp_lot_number) do
        [
          %{
            level: cond_level,
            location: location,
            field: :cp_lot_number,
            message:
              "conditional field cp_lot_number is required when cp_commercial_product is populated"
          }
        ]
      else
        []
      end

    donation_when_no_commercial ++
      component_when_donation ++ manufacturer_when_commercial ++ lot_number_when_commercial
  end

  # CSP: Clinical Study Phase — study_phase_evaluability required at end of phase
  # CSP-4 (study_phase_evaluability) required when CSP-3 (date_time_study_phase_ended) is populated
  def conditional_errors(%HL7v2.Segment.CSP{} = csp, location, mode, _context) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if not semantic_blank?(csp.date_time_study_phase_ended) and
         semantic_blank?(csp.study_phase_evaluability) do
      [
        %{
          level: cond_level,
          location: location,
          field: :study_phase_evaluability,
          message:
            "conditional field study_phase_evaluability is required when date_time_study_phase_ended is populated (end of phase)"
        }
      ]
    else
      []
    end
  end

  # CSR: Clinical Study Registration
  # CSR-10 (patient_study_eligibility_status) required when registration is complete
  #   (indicated by date_time_of_patient_study_registration being populated)
  # CSR-14 (patient_evaluability_status) required when study is complete
  #   (indicated by date_time_ended_study being populated)
  def conditional_errors(%HL7v2.Segment.CSR{} = csr, location, mode, _context) do
    cond_level = if mode == :strict, do: :error, else: :warning

    eligibility_when_registered =
      if not semantic_blank?(csr.date_time_of_patient_study_registration) and
           semantic_blank?(csr.patient_study_eligibility_status) do
        [
          %{
            level: cond_level,
            location: location,
            field: :patient_study_eligibility_status,
            message:
              "conditional field patient_study_eligibility_status is required when date_time_of_patient_study_registration is populated"
          }
        ]
      else
        []
      end

    evaluability_when_ended =
      if not semantic_blank?(csr.date_time_ended_study) and
           semantic_blank?(csr.patient_evaluability_status) do
        [
          %{
            level: cond_level,
            location: location,
            field: :patient_evaluability_status,
            message:
              "conditional field patient_evaluability_status is required when date_time_ended_study is populated"
          }
        ]
      else
        []
      end

    eligibility_when_registered ++ evaluability_when_ended
  end

  # SID: Substance Identifier — at least one of SID-1 or SID-4 required
  def conditional_errors(%HL7v2.Segment.SID{} = sid, location, mode, _context) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if semantic_blank?(sid.application_method_identifier) and
         semantic_blank?(sid.substance_manufacturer_identifier) do
      [
        %{
          level: cond_level,
          location: location,
          field: :application_method_identifier,
          message:
            "conditional: at least one of application_method_identifier (SID-1) or substance_manufacturer_identifier (SID-4) must be populated"
        }
      ]
    else
      []
    end
  end

  # STF: Staff Identification — primary_key_value required for MFN messages
  # Since we can't know message context, we flag when staff_identifier_list is populated
  # (indicating an active record) but primary_key_value is missing
  def conditional_errors(%HL7v2.Segment.STF{} = stf, location, mode, _context) do
    cond_level = if mode == :strict, do: :error, else: :warning

    if not semantic_blank?(stf.staff_identifier_list) and
         semantic_blank?(stf.primary_key_value) do
      [
        %{
          level: cond_level,
          location: location,
          field: :primary_key_value,
          message:
            "conditional field primary_key_value should be populated (required for MFN messages)"
        }
      ]
    else
      []
    end
  end

  # Default: no conditional rules for segments without specific rules
  def conditional_errors(_segment, _location, _mode, _context), do: []
end
