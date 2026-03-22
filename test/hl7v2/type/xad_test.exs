defmodule HL7v2.Type.XADTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.XAD
  alias HL7v2.Type.{SAD, DR, TS, DTM}

  doctest XAD

  describe "parse/1" do
    test "parses full address" do
      result =
        XAD.parse([
          "123 Main St&Main St&123",
          "Suite 100",
          "Springfield",
          "IL",
          "62704",
          "USA",
          "H",
          "District 5",
          "017",
          "0123",
          "A"
        ])

      assert %SAD{
               street_or_mailing_address: "123 Main St",
               street_name: "Main St",
               dwelling_number: "123"
             } = result.street_address

      assert result.other_designation == "Suite 100"
      assert result.city == "Springfield"
      assert result.state == "IL"
      assert result.zip == "62704"
      assert result.country == "USA"
      assert result.address_type == "H"
      assert result.other_geographic == "District 5"
      assert result.county_code == "017"
      assert result.census_tract == "0123"
      assert result.address_representation_code == "A"
    end

    test "parses with address validity range" do
      result =
        XAD.parse([
          "123 Main",
          "",
          "City",
          "ST",
          "12345",
          "",
          "",
          "",
          "",
          "",
          "",
          "20250101&20261231"
        ])

      assert %DR{} = result.address_validity_range
      assert %TS{time: %DTM{year: 2025}} = result.address_validity_range.range_start
    end

    test "parses with effective and expiration dates" do
      result =
        XAD.parse([
          "123 Main",
          "",
          "City",
          "ST",
          "12345",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "20250601",
          "20261231"
        ])

      assert %TS{time: %DTM{year: 2025, month: 6}} = result.effective_date
      assert %TS{time: %DTM{year: 2026, month: 12}} = result.expiration_date
    end

    test "parses empty sub-component SAD returns nil" do
      result = XAD.parse(["", "", "City"])

      assert result.street_address == nil
      assert result.city == "City"
    end
  end

  describe "encode/1" do
    test "encodes nil returns empty list" do
      assert XAD.encode(nil) == []
    end

    test "encodes empty struct" do
      assert XAD.encode(%XAD{}) == []
    end

    test "encodes with street address SAD" do
      xad = %XAD{
        street_address: %SAD{
          street_or_mailing_address: "123 Main St",
          street_name: "Main St",
          dwelling_number: "123"
        },
        city: "Springfield",
        state: "IL",
        zip: "62704"
      }

      encoded = XAD.encode(xad)
      assert Enum.at(encoded, 0) == "123 Main St&Main St&123"
      assert Enum.at(encoded, 2) == "Springfield"
      assert Enum.at(encoded, 3) == "IL"
      assert Enum.at(encoded, 4) == "62704"
    end

    test "encodes with nil street address" do
      xad = %XAD{city: "Springfield"}

      encoded = XAD.encode(xad)
      assert Enum.at(encoded, 0) == ""
      assert Enum.at(encoded, 2) == "Springfield"
    end

    test "encodes with address validity range DR" do
      xad = %XAD{
        city: "City",
        address_validity_range: %DR{
          range_start: %TS{time: %DTM{year: 2025, month: 1, day: 1}},
          range_end: %TS{time: %DTM{year: 2026, month: 12, day: 31}}
        }
      }

      encoded = XAD.encode(xad)
      assert Enum.at(encoded, 11) == "20250101&20261231"
    end

    test "encodes with nil DR returns empty string" do
      xad = %XAD{
        city: "City",
        effective_date: %TS{time: %DTM{year: 2025}}
      }

      encoded = XAD.encode(xad)
      assert Enum.at(encoded, 11) == ""
    end

    test "encodes with effective and expiration TS dates" do
      xad = %XAD{
        city: "City",
        effective_date: %TS{time: %DTM{year: 2025, month: 6, day: 1}},
        expiration_date: %TS{time: %DTM{year: 2026, month: 12, day: 31}}
      }

      encoded = XAD.encode(xad)
      assert Enum.at(encoded, 12) == "20250601"
      assert Enum.at(encoded, 13) == "20261231"
    end

    test "encodes with nil TS returns empty string" do
      xad = %XAD{city: "City", country: "USA"}

      encoded = XAD.encode(xad)
      # TS fields not in output since they're trailing nils
      assert length(encoded) == 6
    end

    test "encodes TS with empty encode result" do
      xad = %XAD{
        city: "City",
        effective_date: %TS{},
        expiration_date: %TS{time: %DTM{year: 2026}}
      }

      encoded = XAD.encode(xad)
      assert Enum.at(encoded, 12) == ""
      assert Enum.at(encoded, 13) == "2026"
    end

    test "encode round-trip preserves data" do
      original = %XAD{
        street_address: %SAD{street_or_mailing_address: "123 Main St"},
        city: "Springfield",
        state: "IL",
        zip: "62704",
        country: "USA",
        address_type: "H"
      }

      parsed = original |> XAD.encode() |> XAD.parse()

      assert parsed.street_address == %SAD{street_or_mailing_address: "123 Main St"}
      assert parsed.city == "Springfield"
      assert parsed.state == "IL"
      assert parsed.zip == "62704"
      assert parsed.country == "USA"
      assert parsed.address_type == "H"
    end
  end
end
