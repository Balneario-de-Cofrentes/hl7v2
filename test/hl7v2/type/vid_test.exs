defmodule HL7v2.Type.VIDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.VID
  alias HL7v2.Type.CE

  doctest VID

  describe "parse/1" do
    test "parses version ID only" do
      result = VID.parse(["2.5.1"])

      assert result.version_id == "2.5.1"
      assert result.internationalization_code == nil
      assert result.international_version_id == nil
    end

    test "parses with internationalization code CE" do
      result = VID.parse(["2.5.1", "INT&International&99LOCAL"])

      assert result.version_id == "2.5.1"
      assert %CE{identifier: "INT", text: "International"} = result.internationalization_code
    end

    test "parses with international version ID CE" do
      result = VID.parse(["2.5.1", "", "USA&United States&ISO3166"])

      assert result.version_id == "2.5.1"
      assert result.internationalization_code == nil
      assert %CE{identifier: "USA", text: "United States"} = result.international_version_id
    end

    test "parses all three components" do
      result = VID.parse(["2.5.1", "INT&Intl&99L", "USA&US&ISO"])

      assert result.version_id == "2.5.1"
      assert %CE{identifier: "INT"} = result.internationalization_code
      assert %CE{identifier: "USA"} = result.international_version_id
    end

    test "parses empty list" do
      result = VID.parse([])
      assert %VID{} = result
      assert result.version_id == nil
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert VID.encode(nil) == []
    end

    test "encodes empty struct" do
      assert VID.encode(%VID{}) == []
    end

    test "encodes version ID only" do
      assert VID.encode(%VID{version_id: "2.5.1"}) == ["2.5.1"]
    end

    test "encodes with internationalization code CE" do
      vid = %VID{
        version_id: "2.5.1",
        internationalization_code: %CE{
          identifier: "INT",
          text: "International",
          name_of_coding_system: "99LOCAL"
        }
      }

      encoded = VID.encode(vid)
      assert Enum.at(encoded, 0) == "2.5.1"
      assert Enum.at(encoded, 1) == "INT&International&99LOCAL"
    end

    test "encodes with international version ID CE" do
      vid = %VID{
        version_id: "2.5.1",
        international_version_id: %CE{identifier: "USA", text: "United States"}
      }

      encoded = VID.encode(vid)
      assert Enum.at(encoded, 0) == "2.5.1"
      assert Enum.at(encoded, 2) == "USA&United States"
    end

    test "encodes with nil CE returns empty string" do
      vid = %VID{
        version_id: "2.5.1",
        internationalization_code: nil,
        international_version_id: %CE{identifier: "USA"}
      }

      encoded = VID.encode(vid)
      assert Enum.at(encoded, 1) == ""
      assert Enum.at(encoded, 2) == "USA"
    end

    test "encode round-trip preserves data" do
      original = %VID{
        version_id: "2.5.1",
        internationalization_code: %CE{identifier: "INT", text: "Intl"}
      }

      parsed = original |> VID.encode() |> VID.parse()
      assert parsed.version_id == "2.5.1"
      assert parsed.internationalization_code.identifier == "INT"
      assert parsed.internationalization_code.text == "Intl"
    end
  end
end
