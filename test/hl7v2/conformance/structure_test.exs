defmodule HL7v2.Conformance.StructureTest do
  @moduledoc """
  Tests that validate the standard metadata itself — segment catalogs,
  type catalogs, message structures, and coverage ledger consistency.
  """
  use ExUnit.Case, async: true

  alias HL7v2.Standard
  alias HL7v2.Standard.{Coverage, MessageStructure}

  describe "segment catalog" do
    test "all typed segment modules are in the catalog" do
      for seg_id <- Standard.typed_segment_ids() do
        assert Standard.segment(seg_id) != nil,
               "Typed segment #{seg_id} missing from catalog"

        assert Standard.segment(seg_id).tier == :typed,
               "Typed segment #{seg_id} not marked as :typed"
      end
    end

    test "all typed segments have a module with segment_id/0" do
      for seg_id <- Standard.typed_segment_ids() do
        module = Standard.segment_module(seg_id)
        assert module != nil, "No module for typed segment #{seg_id}"
        Code.ensure_loaded!(module)
        assert module.segment_id() == seg_id
      end
    end

    test "typed parser registry matches standard catalog" do
      for id <- Standard.typed_segment_ids() do
        assert Standard.segment_module(id) != nil,
               "Standard lists #{id} as typed but has no module"

        module = Standard.segment_module(id)

        assert HL7v2.TypedParser.segment_module(id) == module,
               "TypedParser missing #{id}"
      end
    end

    test "segment count is exactly 156 (152 v2.5.1 + 4 v2.6/v2.7: ARV, PRT, UAC, IAR)" do
      assert Standard.segment_count() == 156
    end
  end

  describe "type catalog" do
    test "all typed types have corresponding modules" do
      for code <- Standard.typed_type_codes() do
        module = Module.concat([HL7v2, Type, String.to_atom(String.upcase(code))])

        assert Code.ensure_loaded?(module) or
                 Code.ensure_loaded?(Module.concat([HL7v2, Type, String.to_atom(code)])),
               "No module for typed type #{code}"
      end
    end

    test "type count is exactly 90 (89 official v2.5.1 + legacy TN)" do
      assert Standard.type_count() == 90
    end
  end

  describe "message structures" do
    test "all structures have valid segment references" do
      for name <- MessageStructure.names() do
        structure = MessageStructure.get(name)
        assert structure != nil
        assert structure.name == name
        assert is_binary(structure.description)
        assert is_list(structure.nodes)
        assert length(structure.nodes) > 0
      end
    end

    test "all structures start with MSH" do
      for name <- MessageStructure.names() do
        structure = MessageStructure.get(name)
        [{:segment, first_seg, _} | _] = structure.nodes
        assert first_seg == :MSH, "#{name} does not start with MSH"
      end
    end

    test "required_segments extracts expected segments" do
      adt_a01 = MessageStructure.get("ADT_A01")
      required = MessageStructure.required_segments(adt_a01)
      assert :MSH in required
      assert :EVN in required
      assert :PID in required
      assert :PV1 in required
    end

    test "ORM_O01 patient group is optional" do
      orm = MessageStructure.get("ORM_O01")
      required = MessageStructure.required_segments(orm)
      assert :MSH in required
      assert :ORC in required
      refute :PID in required, "PID should be optional in ORM_O01"
    end

    test "ORU_R01 patient group is optional" do
      oru = MessageStructure.get("ORU_R01")
      required = MessageStructure.required_segments(oru)
      assert :MSH in required
      assert :OBR in required
      refute :PID in required, "PID should be optional in ORU_R01"
    end

    test "SIU_S12 requires RGS" do
      siu = MessageStructure.get("SIU_S12")
      required = MessageStructure.required_segments(siu)
      assert :MSH in required
      assert :SCH in required
      assert :RGS in required
    end

    test "ACK requires MSA" do
      ack = MessageStructure.get("ACK")
      required = MessageStructure.required_segments(ack)
      assert :MSH in required
      assert :MSA in required
    end

    test "ADT_A39 requires MRG" do
      a39 = MessageStructure.get("ADT_A39")
      required = MessageStructure.required_segments(a39)
      assert :MSH in required
      assert :EVN in required
      assert :PID in required
      assert :MRG in required
    end

    test "canonical structure mapping covers all supported structures" do
      for name <- MessageStructure.names() do
        assert MessageStructure.get(name) != nil,
               "Structure #{name} listed but has no definition"
      end
    end

    test "structure count is exactly 222" do
      assert MessageStructure.count() == 222
    end
  end

  describe "coverage ledger" do
    test "typed segments match standard catalog" do
      assert Coverage.typed_segments() == Standard.typed_segment_ids()
    end

    test "coverage_summary returns valid structure with exact counts" do
      summary = Coverage.coverage_summary()

      # Exact counts that match README claims (152 v2.5.1 + 4 v2.6/v2.7)
      assert summary.typed_segment_count == 156
      assert summary.total_segment_count == 156
      assert summary.segment_coverage_pct == 100.0
      assert summary.typed_type_count == 90
      assert summary.total_type_count == 90
      assert summary.type_coverage_pct == 100.0

      # Shape checks for less-pinnable fields
      assert is_integer(summary.total_typed_fields)
      assert summary.total_typed_fields > 2000
      assert summary.raw_hole_count == 2
      assert is_list(summary.raw_holes)
    end

    test "raw holes are real" do
      holes = Coverage.raw_holes()
      assert length(holes) > 0

      for {seg_id, field_name, seq} <- holes do
        assert is_binary(seg_id)
        assert is_atom(field_name)
        assert is_integer(seq)
        assert Standard.segment_tier(seg_id) == :typed
      end
    end

    test "no unsupported segments remain" do
      unsupported = Coverage.unsupported_segments()
      assert unsupported == [], "Expected 0 unsupported segments, got: #{inspect(unsupported)}"
    end

    test "raw holes are exactly QPD-3 and RDT-1" do
      assert Coverage.raw_holes() == [
               {"QPD", :user_parameters_in_successive_fields, 3},
               {"RDT", :column_value, 1}
             ]
    end

    test "runtime-dispatched is exactly OBX-5" do
      assert Coverage.runtime_dispatched() == [
               {"OBX", :observation_value, 5}
             ]
    end
  end

  describe "conditional rule count" do
    # Each entry: {module, trigger_data} where trigger_data is a struct that
    # MUST produce at least one conditional error/warning when checked. This
    # proves the segment-specific clause exists — a blank struct hitting the
    # default catch-all would return [].
    @conditional_triggers [
      {HL7v2.Segment.OBX, %HL7v2.Segment.OBX{observation_value: "present", value_type: nil}},
      {HL7v2.Segment.MSH,
       %HL7v2.Segment.MSH{
         accept_acknowledgment_type: "AL",
         application_acknowledgment_type: nil
       }},
      {HL7v2.Segment.NK1, %HL7v2.Segment.NK1{set_id: "1", nk_name: nil}},
      {HL7v2.Segment.ORC, %HL7v2.Segment.ORC{placer_order_number: nil, filler_order_number: nil}},
      {HL7v2.Segment.OBR,
       %HL7v2.Segment.OBR{
         universal_service_identifier: %HL7v2.Type.CE{identifier: "CBC"},
         result_status: "F",
         observation_date_time: nil
       }},
      {HL7v2.Segment.SCH,
       %HL7v2.Segment.SCH{placer_appointment_id: nil, filler_appointment_id: nil}},
      {HL7v2.Segment.AIS,
       %HL7v2.Segment.AIS{
         universal_service_identifier: %HL7v2.Type.CE{identifier: "CONSULT"},
         start_date_time: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026}},
         segment_action_code: nil
       }},
      {HL7v2.Segment.AIG,
       %HL7v2.Segment.AIG{
         resource_type: %HL7v2.Type.CE{identifier: "PROV"},
         segment_action_code: nil
       }},
      {HL7v2.Segment.AIL,
       %HL7v2.Segment.AIL{
         location_resource_id: %HL7v2.Type.PL{point_of_care: "W"},
         segment_action_code: nil
       }},
      {HL7v2.Segment.AIP,
       %HL7v2.Segment.AIP{
         personnel_resource_id: [%HL7v2.Type.XCN{id_number: "1"}],
         segment_action_code: nil
       }},
      {HL7v2.Segment.RGS, %HL7v2.Segment.RGS{set_id: "1", segment_action_code: nil}},
      {HL7v2.Segment.ARQ,
       %HL7v2.Segment.ARQ{placer_appointment_id: nil, filler_appointment_id: nil}},
      {HL7v2.Segment.DG1,
       %HL7v2.Segment.DG1{
         diagnosis_identifier: %HL7v2.Type.CE{identifier: "I10"},
         diagnosis_action_code: nil
       }},
      {HL7v2.Segment.PID,
       %HL7v2.Segment.PID{breed_code: %HL7v2.Type.CE{identifier: "DOG"}, species_code: nil}},
      {HL7v2.Segment.PV2,
       %HL7v2.Segment.PV2{
         expected_discharge_date_time: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026}},
         expected_discharge_disposition: nil
       }},
      {HL7v2.Segment.QAK, %HL7v2.Segment.QAK{query_tag: "QRY001", query_response_status: nil}},
      {HL7v2.Segment.MFE, %HL7v2.Segment.MFE{mfn_control_id: nil}},
      {HL7v2.Segment.MFA, %HL7v2.Segment.MFA{mfn_control_id: nil}},
      {HL7v2.Segment.BPX,
       %HL7v2.Segment.BPX{
         set_id: "1",
         bp_dispense_status: %HL7v2.Type.CWE{identifier: "RA"},
         bc_donation_id: nil,
         cp_commercial_product: nil
       }},
      {HL7v2.Segment.BTX,
       %HL7v2.Segment.BTX{
         set_id: "1",
         bp_quantity: "1",
         bp_transfusion_disposition_status: %HL7v2.Type.CWE{identifier: "TX"},
         bc_donation_id: nil,
         cp_commercial_product: nil
       }},
      {HL7v2.Segment.CSP,
       %HL7v2.Segment.CSP{
         study_phase_identifier: %HL7v2.Type.CE{identifier: "P1"},
         date_time_study_phase_began: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026}},
         date_time_study_phase_ended: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026}},
         study_phase_evaluability: nil
       }},
      {HL7v2.Segment.CSR,
       %HL7v2.Segment.CSR{
         sponsor_study_id: %HL7v2.Type.EI{entity_identifier: "S1"},
         sponsor_patient_id: %HL7v2.Type.CX{id: "P1"},
         date_time_of_patient_study_registration: %HL7v2.Type.TS{
           time: %HL7v2.Type.DTM{year: 2026}
         },
         patient_study_eligibility_status: nil
       }},
      {HL7v2.Segment.SID,
       %HL7v2.Segment.SID{
         application_method_identifier: nil,
         substance_manufacturer_identifier: nil
       }},
      {HL7v2.Segment.STF,
       %HL7v2.Segment.STF{
         staff_identifier_list: [%HL7v2.Type.CX{id: "STAFF001"}],
         primary_key_value: nil
       }}
    ]

    test "each of the 24 segments produces a non-empty conditional result" do
      for {mod, trigger} <- @conditional_triggers do
        errors =
          HL7v2.Validation.FieldRules.conditional_errors(trigger, "TEST", :lenient)

        assert length(errors) > 0,
               "#{inspect(mod)} with trigger data returned [] — clause may have been removed"
      end

      assert length(@conditional_triggers) == 24
    end

    test "default catch-all returns empty list for unlisted segments" do
      msa = %HL7v2.Segment.MSA{acknowledgment_code: "AA", message_control_id: "MSG001"}
      assert HL7v2.Validation.FieldRules.conditional_errors(msa, "TEST", :lenient) == []
    end
  end
end
