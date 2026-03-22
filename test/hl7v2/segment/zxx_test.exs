defmodule HL7v2.Segment.ZXXTest do
  use ExUnit.Case, async: true

  alias HL7v2.Segment.ZXX

  describe "fields/0" do
    test "returns empty list (no typed fields)" do
      assert ZXX.fields() == []
    end
  end

  describe "segment_id/0" do
    test "returns ZXX" do
      assert ZXX.segment_id() == "ZXX"
    end
  end

  describe "new/2" do
    test "creates struct with segment_id and raw_fields" do
      zxx = ZXX.new("ZPD", ["field1", "field2", ["comp1", "comp2"]])

      assert %ZXX{} = zxx
      assert zxx.segment_id == "ZPD"
      assert zxx.raw_fields == ["field1", "field2", ["comp1", "comp2"]]
    end

    test "creates struct with empty raw fields" do
      zxx = ZXX.new("ZPI", [])

      assert zxx.segment_id == "ZPI"
      assert zxx.raw_fields == []
    end
  end

  describe "segment_name/1" do
    test "returns the Z-segment identifier from instance" do
      zxx = ZXX.new("ZPD", ["field1"])

      assert ZXX.segment_name(zxx) == "ZPD"
    end

    test "returns ZXX for parse-created instances" do
      zxx = ZXX.parse(["field1"])

      assert ZXX.segment_name(zxx) == "ZXX"
    end
  end

  describe "parse/1" do
    test "preserves all raw fields" do
      raw = ["field1", "field2", ["comp1", "comp2"], "field4"]

      result = ZXX.parse(raw)

      assert %ZXX{} = result
      assert result.segment_id == "ZXX"
      assert result.raw_fields == raw
    end

    test "preserves empty list" do
      result = ZXX.parse([])

      assert result.raw_fields == []
    end

    test "preserves nested structures" do
      raw = [["a", "b"], [["c", "d"], ["e", "f"]], "g"]

      result = ZXX.parse(raw)

      assert result.raw_fields == raw
    end
  end

  describe "encode/1" do
    test "returns the raw fields unchanged" do
      raw = ["field1", "field2", ["comp1", "comp2"]]
      zxx = ZXX.new("ZPD", raw)

      assert ZXX.encode(zxx) == raw
    end

    test "returns empty list for nil raw_fields" do
      zxx = %ZXX{segment_id: "ZPD", raw_fields: nil}

      assert ZXX.encode(zxx) == []
    end

    test "returns empty list for struct with empty raw_fields" do
      zxx = ZXX.new("ZPD", [])

      assert ZXX.encode(zxx) == []
    end
  end

  describe "round-trip" do
    test "new then encode returns same fields" do
      fields = ["field1", "field2", ["comp1", "comp2"]]
      zxx = ZXX.new("ZDX", fields)

      assert ZXX.encode(zxx) == fields
    end

    test "parse then encode returns same fields" do
      fields = ["alpha", "beta", ["gamma", "delta"]]

      assert fields |> ZXX.parse() |> ZXX.encode() == fields
    end
  end
end
