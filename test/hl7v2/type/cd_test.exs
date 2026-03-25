defmodule HL7v2.Type.CDTest do
  use ExUnit.Case, async: true

  alias HL7v2.Type.{CD, WVI, WVS}

  doctest CD

  describe "parse/1" do
    test "parses channel identifier and waveform source" do
      result = CD.parse(["1&Lead I", "RA&LA"])
      assert %WVI{channel_number: "1", channel_name: "Lead I"} = result.channel_identifier
      assert %WVS{source_one_name: "RA", source_two_name: "LA"} = result.waveform_source
    end

    test "parses with sampling frequency" do
      result = CD.parse(["1&ECG", "", "", "", "500"])
      assert result.channel_identifier.channel_number == "1"
      assert result.channel_sampling_frequency == "500"
    end

    test "parses empty list" do
      result = CD.parse([])
      assert result.channel_identifier == nil
      assert result.waveform_source == nil
    end
  end

  describe "encode/1" do
    test "encodes channel identifier" do
      cd = %CD{channel_identifier: %WVI{channel_number: "1", channel_name: "Lead I"}}
      assert CD.encode(cd) == ["1&Lead I"]
    end

    test "encodes nil" do
      assert CD.encode(nil) == []
    end

    test "encodes empty struct" do
      assert CD.encode(%CD{}) == []
    end
  end
end
