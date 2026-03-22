defmodule HL7v2.Type.CXTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.CX
  alias HL7v2.Type.{HD, CWE}

  doctest CX

  describe "parse/1" do
    test "parses with all 10 components" do
      result =
        CX.parse([
          "12345",
          "5",
          "M11",
          "MRN&1.2.3&ISO",
          "MR",
          "FAC&2.3.4&ISO",
          "20250101",
          "20261231",
          "STATE&State Name&99ST",
          "DEPT&Dept Name&99DP"
        ])

      assert result.id == "12345"
      assert result.check_digit == "5"
      assert result.check_digit_scheme == "M11"
      assert %HD{namespace_id: "MRN", universal_id: "1.2.3"} = result.assigning_authority
      assert result.identifier_type_code == "MR"
      assert %HD{namespace_id: "FAC", universal_id: "2.3.4"} = result.assigning_facility

      assert result.effective_date == ~D[2025-01-01]
      assert result.expiration_date == ~D[2026-12-31]

      assert %CWE{identifier: "STATE", text: "State Name"} = result.assigning_jurisdiction
      assert %CWE{identifier: "DEPT", text: "Dept Name"} = result.assigning_agency
    end

    test "parses with simple assigning authority" do
      result = CX.parse(["12345", "", "", "MRN", "MR"])

      assert result.id == "12345"
      assert %HD{namespace_id: "MRN"} = result.assigning_authority
      assert result.identifier_type_code == "MR"
    end

    test "parses empty assigning authority string as nil" do
      result = CX.parse(["12345", "", "", "", "MR"])

      assert result.assigning_authority == nil
    end

    test "parses empty CWE sub-components as nil" do
      result = CX.parse(["12345", "", "", "", "", "", "", "", "", ""])

      assert result.assigning_jurisdiction == nil
      assert result.assigning_agency == nil
    end

    test "parses empty list" do
      result = CX.parse([])

      assert %CX{} = result
      assert result.id == nil
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert CX.encode(nil) == []
    end

    test "encodes empty struct" do
      assert CX.encode(%CX{}) == []
    end

    test "encodes with assigning authority HD" do
      cx = %CX{
        id: "12345",
        assigning_authority: %HD{namespace_id: "MRN", universal_id: "1.2.3", universal_id_type: "ISO"},
        identifier_type_code: "MR"
      }

      encoded = CX.encode(cx)
      assert Enum.at(encoded, 0) == "12345"
      assert Enum.at(encoded, 3) == "MRN&1.2.3&ISO"
      assert Enum.at(encoded, 4) == "MR"
    end

    test "encodes with nil assigning authority" do
      cx = %CX{id: "12345", identifier_type_code: "MR"}

      encoded = CX.encode(cx)
      assert Enum.at(encoded, 3) == ""
    end

    test "encodes with assigning facility HD" do
      cx = %CX{
        id: "12345",
        assigning_facility: %HD{namespace_id: "FAC"}
      }

      encoded = CX.encode(cx)
      assert Enum.at(encoded, 5) == "FAC"
    end

    test "encodes with effective and expiration dates" do
      cx = %CX{
        id: "12345",
        effective_date: ~D[2025-01-01],
        expiration_date: ~D[2026-12-31]
      }

      encoded = CX.encode(cx)
      assert Enum.at(encoded, 6) == "20250101"
      assert Enum.at(encoded, 7) == "20261231"
    end

    test "encodes with nil dates" do
      cx = %CX{
        id: "12345",
        assigning_jurisdiction: %CWE{identifier: "STATE"}
      }

      encoded = CX.encode(cx)
      assert Enum.at(encoded, 6) == ""
      assert Enum.at(encoded, 7) == ""
    end

    test "encodes with assigning jurisdiction CWE" do
      cx = %CX{
        id: "12345",
        assigning_jurisdiction: %CWE{
          identifier: "STATE",
          text: "State Name",
          name_of_coding_system: "99ST"
        }
      }

      encoded = CX.encode(cx)
      assert Enum.at(encoded, 8) == "STATE&State Name&99ST"
    end

    test "encodes with assigning agency CWE" do
      cx = %CX{
        id: "12345",
        assigning_agency: %CWE{identifier: "DEPT", text: "Department"}
      }

      encoded = CX.encode(cx)
      assert Enum.at(encoded, 9) == "DEPT&Department"
    end

    test "encodes with nil CWE returns empty string" do
      cx = %CX{id: "12345"}

      encoded = CX.encode(cx)
      assert length(encoded) == 1
    end

    test "encode round-trip preserves data" do
      original = %CX{
        id: "12345",
        check_digit: "5",
        check_digit_scheme: "M11",
        assigning_authority: %HD{namespace_id: "MRN", universal_id: "1.2.3", universal_id_type: "ISO"},
        identifier_type_code: "MR"
      }

      parsed = original |> CX.encode() |> CX.parse()

      assert parsed.id == "12345"
      assert parsed.check_digit == "5"
      assert parsed.check_digit_scheme == "M11"
      assert parsed.assigning_authority.namespace_id == "MRN"
      assert parsed.identifier_type_code == "MR"
    end
  end
end
