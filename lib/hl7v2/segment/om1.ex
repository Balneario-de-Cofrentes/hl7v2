defmodule HL7v2.Segment.OM1 do
  @moduledoc """
  General Segment (OM1) -- HL7v2 v2.5.1.

  Contains general information about an observation definition.
  47 fields per HL7 v2.5.1 specification.
  """

  use HL7v2.Segment,
    id: "OM1",
    fields: [
      {1, :sequence_number, HL7v2.Type.NM, :r, 1},
      {2, :producers_service_test_observation_id, HL7v2.Type.CE, :r, 1},
      {3, :permitted_data_types, HL7v2.Type.ID, :o, :unbounded},
      {4, :specimen_required, HL7v2.Type.ID, :r, 1},
      {5, :producer_id, HL7v2.Type.CE, :r, 1},
      {6, :observation_description, HL7v2.Type.TX, :o, 1},
      {7, :other_service_test_observation_ids_for_the_observation, HL7v2.Type.CE, :o, 1},
      {8, :other_names, HL7v2.Type.ST, :r, :unbounded},
      {9, :preferred_report_name, HL7v2.Type.ST, :o, 1},
      {10, :preferred_short_name, HL7v2.Type.ST, :o, 1},
      {11, :preferred_long_name, HL7v2.Type.ST, :o, 1},
      {12, :orderability, HL7v2.Type.ID, :o, 1},
      {13, :identity_of_instrument_used_to_perform_this_study, HL7v2.Type.CE, :o, :unbounded},
      {14, :coded_representation_of_method, HL7v2.Type.CE, :o, :unbounded},
      {15, :portable_device_indicator, HL7v2.Type.ID, :o, 1},
      {16, :observation_producing_department_section, HL7v2.Type.CE, :o, :unbounded},
      {17, :telephone_number_of_section, HL7v2.Type.XTN, :o, 1},
      {18, :nature_of_service_test_observation, HL7v2.Type.IS, :r, 1},
      {19, :report_subheader, HL7v2.Type.CE, :o, 1},
      {20, :report_display_order, HL7v2.Type.ST, :o, 1},
      {21, :date_time_stamp_for_any_change_in_definition_for_the_observation, HL7v2.Type.TS, :o,
       1},
      {22, :effective_date_time_of_change, HL7v2.Type.TS, :o, 1},
      {23, :typical_turn_around_time, HL7v2.Type.NM, :o, 1},
      {24, :processing_time, HL7v2.Type.NM, :o, 1},
      {25, :processing_priority, HL7v2.Type.ID, :o, :unbounded},
      {26, :reporting_priority, HL7v2.Type.ID, :o, 1},
      {27, :outside_site, HL7v2.Type.CE, :o, :unbounded},
      {28, :address_of_outside_site, HL7v2.Type.XAD, :o, :unbounded},
      {29, :phone_number_of_outside_site, HL7v2.Type.XTN, :o, 1},
      {30, :confidentiality_code, HL7v2.Type.CWE, :o, 1},
      {31, :observations_required_to_interpret_the_observation, HL7v2.Type.CE, :o, 1},
      {32, :interpretation_of_observations, HL7v2.Type.TX, :o, 1},
      {33, :contraindications_to_observations, HL7v2.Type.CE, :o, 1},
      {34, :reflex_tests_observations, HL7v2.Type.CE, :o, :unbounded},
      {35, :rules_that_trigger_reflex_testing, HL7v2.Type.TX, :o, 1},
      {36, :fixed_canned_message, HL7v2.Type.CE, :o, 1},
      {37, :patient_preparation, HL7v2.Type.TX, :o, 1},
      {38, :procedure_medication, HL7v2.Type.CE, :o, 1},
      {39, :factors_that_may_affect_the_observation, HL7v2.Type.TX, :o, 1},
      {40, :service_test_observation_performance_schedule, HL7v2.Type.ST, :o, :unbounded},
      {41, :description_of_test_methods, HL7v2.Type.TX, :o, 1},
      {42, :kind_of_quantity_observed, HL7v2.Type.CE, :o, 1},
      {43, :point_versus_interval, HL7v2.Type.CE, :o, 1},
      {44, :challenge_information, HL7v2.Type.TX, :o, 1},
      {45, :relationship_modifier, HL7v2.Type.CE, :o, 1},
      {46, :target_anatomic_site_of_test, HL7v2.Type.CE, :o, 1},
      {47, :modality_of_imaging_measurement, HL7v2.Type.CE, :o, 1}
    ]
end
