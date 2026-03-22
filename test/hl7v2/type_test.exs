defmodule HL7v2.TypeTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type

  describe "get_component/2" do
    test "returns nil for out-of-bounds index" do
      assert Type.get_component([], 0) == nil
      assert Type.get_component(["a"], 5) == nil
    end

    test "returns nil for empty string" do
      assert Type.get_component([""], 0) == nil
    end

    test "returns nil for nil element" do
      assert Type.get_component([nil], 0) == nil
    end

    test "returns binary value" do
      assert Type.get_component(["hello"], 0) == "hello"
    end

    test "rejoins sub-component lists with &" do
      assert Type.get_component([["MRN", "1.2.3", "ISO"]], 0) == "MRN&1.2.3&ISO"
    end

    test "returns nil for sub-component list of empty strings" do
      assert Type.get_component([["", "", ""]], 0) == nil
    end

    test "returns nil for non-binary, non-list, non-nil values" do
      assert Type.get_component([123], 0) == nil
    end
  end

  describe "pad_components/2" do
    test "pads short list" do
      assert Type.pad_components(["a"], 3) == ["a", nil, nil]
    end

    test "does not pad list already at target length" do
      assert Type.pad_components(["a", "b", "c"], 3) == ["a", "b", "c"]
    end

    test "does not truncate list longer than target" do
      assert Type.pad_components(["a", "b", "c", "d"], 3) == ["a", "b", "c", "d"]
    end

    test "pads empty list" do
      assert Type.pad_components([], 2) == [nil, nil]
    end
  end

  describe "trim_trailing/1" do
    test "trims trailing nils" do
      assert Type.trim_trailing(["a", "b", nil, nil]) == ["a", "b"]
    end

    test "trims trailing empty strings" do
      assert Type.trim_trailing(["a", "b", "", ""]) == ["a", "b"]
    end

    test "trims trailing empty lists" do
      assert Type.trim_trailing(["a", "b", []]) == ["a", "b"]
    end

    test "trims mixed trailing empty values" do
      assert Type.trim_trailing(["a", nil, "", []]) == ["a"]
    end

    test "preserves middle empty values" do
      assert Type.trim_trailing(["a", "", "b"]) == ["a", "", "b"]
    end

    test "returns empty list when all values are empty" do
      assert Type.trim_trailing([nil, "", []]) == []
    end

    test "returns empty list for empty input" do
      assert Type.trim_trailing([]) == []
    end

    test "preserves non-empty trailing values" do
      assert Type.trim_trailing(["a", "b", "c"]) == ["a", "b", "c"]
    end
  end
end
