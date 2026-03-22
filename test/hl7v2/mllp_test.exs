defmodule HL7v2.MLLPTest do
  use ExUnit.Case, async: true

  alias HL7v2.MLLP

  @sb 0x0B
  @eb 0x1C
  @cr 0x0D

  describe "frame/1" do
    test "wraps message in MLLP frame" do
      assert <<@sb, "hello", @eb, @cr>> == MLLP.frame("hello")
    end

    test "wraps empty message" do
      assert <<@sb, @eb, @cr>> == MLLP.frame("")
    end

    test "wraps HL7 message" do
      msg = "MSH|^~\\&|SEND|FAC||RCV||20240101||ADT^A01|123|P|2.5\r"
      framed = MLLP.frame(msg)
      assert <<@sb, _::binary>> = framed
      assert :binary.last(framed) == @cr
    end
  end

  describe "unframe/1" do
    test "extracts message from valid frame" do
      assert {:ok, "hello"} == MLLP.unframe(<<@sb, "hello", @eb, @cr>>)
    end

    test "extracts empty message" do
      assert {:ok, ""} == MLLP.unframe(<<@sb, @eb, @cr>>)
    end

    test "rejects missing start block" do
      assert {:error, :invalid_frame} == MLLP.unframe(<<"hello", @eb, @cr>>)
    end

    test "rejects missing end block" do
      assert {:error, :invalid_frame} == MLLP.unframe(<<@sb, "hello">>)
    end

    test "rejects missing carriage return" do
      assert {:error, :invalid_frame} == MLLP.unframe(<<@sb, "hello", @eb>>)
    end

    test "rejects empty binary" do
      assert {:error, :invalid_frame} == MLLP.unframe(<<>>)
    end

    test "rejects frame with trailing data" do
      assert {:error, :invalid_frame} == MLLP.unframe(<<@sb, "hello", @eb, @cr, "extra">>)
    end
  end

  describe "extract_messages/1" do
    test "extracts single message" do
      buffer = <<@sb, "MSG1", @eb, @cr>>
      assert {["MSG1"], <<>>} == MLLP.extract_messages(buffer)
    end

    test "extracts multiple messages" do
      buffer = <<@sb, "MSG1", @eb, @cr, @sb, "MSG2", @eb, @cr>>
      assert {["MSG1", "MSG2"], <<>>} == MLLP.extract_messages(buffer)
    end

    test "handles partial message at end" do
      partial = <<@sb, "partial">>
      buffer = <<@sb, "MSG1", @eb, @cr, partial::binary>>
      assert {["MSG1"], ^partial} = MLLP.extract_messages(buffer)
    end

    test "returns empty list for incomplete message" do
      buffer = <<@sb, "incomplete">>
      assert {[], ^buffer} = MLLP.extract_messages(buffer)
    end

    test "returns empty list for empty buffer" do
      assert {[], <<>>} == MLLP.extract_messages(<<>>)
    end

    test "handles three messages" do
      buffer =
        <<@sb, "A", @eb, @cr, @sb, "B", @eb, @cr, @sb, "C", @eb, @cr>>

      assert {["A", "B", "C"], <<>>} == MLLP.extract_messages(buffer)
    end

    test "skips garbage before start block" do
      buffer = <<"garbage", @sb, "MSG1", @eb, @cr>>
      assert {["MSG1"], <<>>} == MLLP.extract_messages(buffer)
    end
  end

  describe "round-trip" do
    test "frame then unframe returns original message" do
      message = "MSH|^~\\&|SEND|FAC||RCV||20240101||ADT^A01|123|P|2.5\r"
      assert {:ok, ^message} = message |> MLLP.frame() |> MLLP.unframe()
    end

    test "frame then extract returns original message" do
      message = "test message"
      {[extracted], <<>>} = message |> MLLP.frame() |> MLLP.extract_messages()
      assert extracted == message
    end

    test "round-trip with binary data" do
      message = <<0, 1, 2, 3, 255, 254, 253>>
      assert {:ok, ^message} = message |> MLLP.frame() |> MLLP.unframe()
    end
  end
end
