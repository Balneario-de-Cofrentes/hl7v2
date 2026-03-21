defmodule HL7v2Test do
  use ExUnit.Case, async: true

  describe "parse/1" do
    test "delegates to Parser for raw mode" do
      msg = "MSH|^~\\&|S|F||R|20240101||ADT^A01|1|P|2.5\r"
      assert {:ok, raw} = HL7v2.parse(msg)
      assert raw.type == {"ADT", "A01"}
    end

    test "returns error for empty input" do
      assert {:error, :empty_message} = HL7v2.parse("")
    end
  end

  describe "encode/1" do
    test "delegates to Encoder" do
      msg = "MSH|^~\\&|SEND|FAC||RCV|20240101||ADT^A01|123|P|2.5\r"
      {:ok, raw} = HL7v2.parse(msg)
      assert HL7v2.encode(raw) == msg
    end
  end
end
