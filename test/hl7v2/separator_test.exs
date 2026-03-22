defmodule HL7v2.SeparatorTest do
  use ExUnit.Case, async: true

  alias HL7v2.Separator

  describe "default/0" do
    test "returns default separator set" do
      sep = Separator.default()

      assert sep.field == ?|
      assert sep.component == ?^
      assert sep.repetition == ?~
      assert sep.escape == ?\\
      assert sep.sub_component == ?&
      assert sep.segment == ?\r
    end
  end

  describe "from_msh/1" do
    test "extracts delimiters from standard MSH header" do
      assert {:ok, sep} = Separator.from_msh("MSH|^~\\&|SendApp|SendFac|RecvApp|")

      assert sep.field == ?|
      assert sep.component == ?^
      assert sep.repetition == ?~
      assert sep.escape == ?\\
      assert sep.sub_component == ?&
      assert sep.segment == ?\r
    end

    test "extracts delimiters from minimal MSH" do
      assert {:ok, sep} = Separator.from_msh("MSH|^~\\&")

      assert sep.field == ?|
      assert sep.component == ?^
    end

    test "extracts custom delimiters" do
      assert {:ok, sep} = Separator.from_msh("MSH!@#$%!SendApp!")

      assert sep.field == ?!
      assert sep.component == ?@
      assert sep.repetition == ?#
      assert sep.escape == ?$
      assert sep.sub_component == ?%
    end

    test "returns error for non-MSH input" do
      assert {:error, :not_msh} = Separator.from_msh("PID|1||12345")
      assert {:error, :not_msh} = Separator.from_msh("")
      assert {:error, :not_msh} = Separator.from_msh("MS")
    end

    test "returns error for truncated MSH" do
      assert {:error, :insufficient_encoding_characters} = Separator.from_msh("MSH|^~")
      assert {:error, :insufficient_encoding_characters} = Separator.from_msh("MSH|")
    end

    test "rejects 3-char MSH-2 (sub_component collides with field separator)" do
      # MSH|^~\| — only 3 encoding chars; the 4th byte is the field separator
      assert {:error, :invalid_encoding_characters} =
               Separator.from_msh("MSH|^~\\|SEND|FAC||RCV||20240101||ADT^A01|123|P|2.5")
    end

    test "rejects overlong MSH-2 (6+ encoding characters)" do
      assert {:error, :invalid_encoding_characters} =
               Separator.from_msh("MSH|^~\\&XY|SEND|FAC")
    end

    test "rejects duplicate delimiters in encoding characters" do
      # All four encoding chars are ^, creating duplicates
      assert {:error, :duplicate_delimiters} = Separator.from_msh("MSH|^^^^|SEND|FAC")
    end

    test "rejects duplicate between encoding characters (component == repetition)" do
      assert {:error, :duplicate_delimiters} = Separator.from_msh("MSH|^^\\&|SEND|FAC")
    end

    test "rejects truncation char that duplicates an encoding character" do
      # Truncation char # duplicates the repetition char (both ~)
      assert {:error, :duplicate_delimiters} = Separator.from_msh("MSH|^~\\&~|SEND|FAC")
    end
  end

  describe "truncation character (v2.7+)" do
    test "parses MSH with truncation character" do
      {:ok, sep} = Separator.from_msh("MSH|^~\\&#|SEND|FAC")
      assert sep.truncation == ?#
      assert sep.component == ?^
      assert sep.repetition == ?~
      assert sep.escape == ?\\
      assert sep.sub_component == ?&
      assert sep.field == ?|
    end

    test "standard MSH has nil truncation" do
      {:ok, sep} = Separator.from_msh("MSH|^~\\&|SEND|FAC")
      assert sep.truncation == nil
    end

    test "minimal MSH with truncation (no trailing fields)" do
      {:ok, sep} = Separator.from_msh("MSH|^~\\&#")
      assert sep.truncation == ?#
    end

    test "truncation char followed by field separator" do
      {:ok, sep} = Separator.from_msh("MSH|^~\\&#|")
      assert sep.truncation == ?#
      assert sep.field == ?|
    end

    test "custom delimiters with truncation" do
      {:ok, sep} = Separator.from_msh("MSH!@#$%*!SendApp!")
      assert sep.field == ?!
      assert sep.component == ?@
      assert sep.repetition == ?#
      assert sep.escape == ?$
      assert sep.sub_component == ?%
      assert sep.truncation == ?*
    end

    test "default/0 has nil truncation" do
      sep = Separator.default()
      assert sep.truncation == nil
    end
  end

  describe "encoding_characters/1" do
    test "returns encoding characters string for default separators" do
      sep = Separator.default()
      assert Separator.encoding_characters(sep) == "^~\\&"
    end

    test "returns encoding characters for custom separators" do
      sep = %Separator{component: ?@, repetition: ?#, escape: ?$, sub_component: ?%}
      assert Separator.encoding_characters(sep) == "@#$%"
    end

    test "includes truncation character when present" do
      {:ok, sep} = Separator.from_msh("MSH|^~\\&#|SEND|FAC")
      assert Separator.encoding_characters(sep) == "^~\\&#"
    end

    test "omits truncation character when nil" do
      {:ok, sep} = Separator.from_msh("MSH|^~\\&|SEND|FAC")
      assert Separator.encoding_characters(sep) == "^~\\&"
    end
  end
end
