defmodule HL7v2.Standard.VersionTest do
  use ExUnit.Case, async: true

  alias HL7v2.Standard.Version

  doctest HL7v2.Standard.Version

  describe "normalize/1" do
    test "passes through canonical versions unchanged" do
      assert Version.normalize("2.5.1") == "2.5.1"
      assert Version.normalize("2.7") == "2.7"
      assert Version.normalize("2") == "2"
    end

    test "strips an optional v/V prefix and surrounding whitespace" do
      assert Version.normalize("v2.5.1") == "2.5.1"
      assert Version.normalize("V2.7") == "2.7"
      assert Version.normalize("  2.5  ") == "2.5"
      assert Version.normalize(" v2.5.1 ") == "2.5.1"
    end

    test "returns nil for nil, empty, or unparseable input" do
      assert Version.normalize(nil) == nil
      assert Version.normalize("") == nil
      assert Version.normalize("garbage") == nil
      assert Version.normalize("2.5.x") == nil
      assert Version.normalize("2..5") == nil
      assert Version.normalize(:not_a_string) == nil
    end
  end

  describe "compare/2" do
    test "returns :lt when first version is older" do
      assert Version.compare("2.5", "2.7") == :lt
      assert Version.compare("2.5.1", "2.6") == :lt
      assert Version.compare("2.3", "2.8") == :lt
    end

    test "returns :eq when versions are equivalent" do
      assert Version.compare("2.5.1", "2.5.1") == :eq
      assert Version.compare("2.5", "2.5.0") == :eq
      assert Version.compare("v2.7", "2.7") == :eq
    end

    test "returns :gt when first version is newer" do
      assert Version.compare("2.7", "2.5") == :gt
      assert Version.compare("2.6", "2.5.1") == :gt
      assert Version.compare("2.8", "2.3") == :gt
    end

    test "raises ArgumentError on invalid input" do
      assert_raise ArgumentError, fn -> Version.compare("garbage", "2.5") end
      assert_raise ArgumentError, fn -> Version.compare("2.5", nil) end
    end
  end

  describe "at_least?/2" do
    test "returns true when version exceeds target" do
      assert Version.at_least?("2.7", "2.5")
      assert Version.at_least?("2.8", "2.3")
      assert Version.at_least?("2.5.1", "2.5")
    end

    test "returns true when version equals target" do
      assert Version.at_least?("2.5.1", "2.5.1")
      assert Version.at_least?("2.5", "2.5.0")
    end

    test "returns false when version is below target" do
      refute Version.at_least?("2.5", "2.7")
      refute Version.at_least?("2.3", "2.5.1")
    end
  end

  describe "supported?/1" do
    test "returns true for versions in the 2.3..2.8 range" do
      for v <- ["2.3", "2.4", "2.5", "2.5.1", "2.6", "2.7", "2.7.1", "2.8"] do
        assert Version.supported?(v), "expected #{v} to be supported"
      end
    end

    test "normalizes prefixed input before checking" do
      assert Version.supported?("v2.5.1")
      assert Version.supported?("  V2.7  ")
    end

    test "returns false for versions outside the supported range" do
      refute Version.supported?("2.2")
      refute Version.supported?("2.9")
      refute Version.supported?("3.0")
      refute Version.supported?("1.0")
    end

    test "returns false for nil or unparseable input" do
      refute Version.supported?(nil)
      refute Version.supported?("")
      refute Version.supported?("garbage")
    end
  end
end
