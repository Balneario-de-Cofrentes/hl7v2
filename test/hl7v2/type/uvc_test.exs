defmodule HL7v2.Type.UVCTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{UVC, CNE, MO}

  doctest UVC

  describe "parse/1" do
    test "parses value code and amount" do
      result = UVC.parse(["01&Blood deductible&NUBC", "150.00&USD"])
      assert %CNE{identifier: "01", text: "Blood deductible"} = result.value_code
      assert %MO{quantity: "150.00", denomination: "USD"} = result.value_amount
    end

    test "parses empty list" do
      assert UVC.parse([]).value_code == nil
    end
  end

  describe "encode/1" do
    test "encodes UVC" do
      uvc = %UVC{value_code: %CNE{identifier: "01"}, value_amount: %MO{quantity: "150.00"}}
      assert UVC.encode(uvc) == ["01", "150.00"]
    end

    test "encodes nil" do
      assert UVC.encode(nil) == []
    end
  end
end
