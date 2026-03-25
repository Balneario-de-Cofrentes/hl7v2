defmodule HL7v2.Type.PIPTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{PIP, CE}

  doctest PIP

  describe "parse/1" do
    test "parses privileges with dates" do
      result = PIP.parse(["SURG&Surgery&LOCAL", "A&Active", "20281231", "20260101"])
      assert %CE{identifier: "SURG", text: "Surgery"} = result.privilege
      assert %CE{identifier: "A", text: "Active"} = result.privilege_class
      assert result.expiration_date == ~D[2028-12-31]
      assert result.activation_date == ~D[2026-01-01]
    end

    test "parses empty list" do
      assert PIP.parse([]).privilege == nil
    end
  end

  describe "encode/1" do
    test "encodes PIP" do
      pip = %PIP{privilege: %CE{identifier: "SURG"}, expiration_date: ~D[2028-12-31]}
      assert PIP.encode(pip) == ["SURG", "", "20281231"]
    end

    test "encodes nil" do
      assert PIP.encode(nil) == []
    end
  end
end
