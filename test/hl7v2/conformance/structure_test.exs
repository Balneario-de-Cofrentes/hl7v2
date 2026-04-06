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

    test "catalog has realistic segment count" do
      count = Standard.segment_count()
      assert count >= 100, "Expected 100+ standard segments, got #{count}"
      assert count <= 200, "Expected <200 standard segments, got #{count}"
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

    test "catalog has realistic type count" do
      count = Standard.type_count()
      assert count >= 70, "Expected 70+ standard types, got #{count}"
      assert count <= 120, "Expected <120 standard types, got #{count}"
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

    test "coverage_summary returns valid structure" do
      summary = Coverage.coverage_summary()
      assert is_integer(summary.typed_segment_count)
      assert is_integer(summary.total_segment_count)
      assert is_float(summary.segment_coverage_pct)
      assert is_integer(summary.typed_type_count)
      assert is_integer(summary.total_type_count)
      assert is_float(summary.type_coverage_pct)
      assert is_integer(summary.total_typed_fields)
      assert is_integer(summary.raw_hole_count)
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
  end
end
