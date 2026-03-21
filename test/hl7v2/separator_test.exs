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
  end
end
