defmodule HL7v2.EscapeTest do
  use ExUnit.Case, async: true

  alias HL7v2.{Escape, Separator}

  @sep Separator.default()

  describe "decode/2" do
    test "decodes field separator escape" do
      assert Escape.decode("foo\\F\\bar", @sep) == "foo|bar"
    end

    test "decodes component separator escape" do
      assert Escape.decode("foo\\S\\bar", @sep) == "foo^bar"
    end

    test "decodes sub-component separator escape" do
      assert Escape.decode("foo\\T\\bar", @sep) == "foo&bar"
    end

    test "decodes repetition separator escape" do
      assert Escape.decode("foo\\R\\bar", @sep) == "foo~bar"
    end

    test "decodes escape character escape" do
      assert Escape.decode("foo\\E\\bar", @sep) == "foo\\bar"
    end

    test "decodes line break escape" do
      assert Escape.decode("line1\\.br\\line2", @sep) == "line1\r\nline2"
    end

    test "decodes hex data escape" do
      # 0x41 = 'A', 0x42 = 'B'
      assert Escape.decode("\\X4142\\", @sep) == "AB"
    end

    test "decodes hex data with lowercase" do
      assert Escape.decode("\\X4a4b\\", @sep) == "JK"
    end

    test "decodes space escape with default count" do
      assert Escape.decode("\\X41\\\\.sp\\\\X42\\", @sep) == "A B"
    end

    test "decodes space escape with explicit count" do
      assert Escape.decode("a\\.sp 3\\b", @sep) == "a   b"
    end

    test "passes through unrecognized escape sequences" do
      assert Escape.decode("foo\\Z\\bar", @sep) == "foo\\Z\\bar"
    end

    test "handles multiple escape sequences" do
      assert Escape.decode("a\\F\\b\\S\\c\\E\\d", @sep) == "a|b^c\\d"
    end

    test "handles text with no escapes" do
      assert Escape.decode("plain text", @sep) == "plain text"
    end

    test "handles empty string" do
      assert Escape.decode("", @sep) == ""
    end

    test "handles escape at end of string without closing" do
      # Lone escape character without closing — treat literally
      assert Escape.decode("foo\\", @sep) == "foo\\"
    end

    test "works with custom separators" do
      custom = %Separator{field: ?!, component: ?@, repetition: ?#, escape: ?$, sub_component: ?%}
      assert Escape.decode("foo$F$bar", custom) == "foo!bar"
      assert Escape.decode("foo$S$bar", custom) == "foo@bar"
      assert Escape.decode("foo$E$bar", custom) == "foo$bar"
    end
  end

  describe "encode/2" do
    test "encodes field separator" do
      assert Escape.encode("pipe|here", @sep) == "pipe\\F\\here"
    end

    test "encodes component separator" do
      assert Escape.encode("caret^here", @sep) == "caret\\S\\here"
    end

    test "encodes sub-component separator" do
      assert Escape.encode("amp&here", @sep) == "amp\\T\\here"
    end

    test "encodes repetition separator" do
      assert Escape.encode("tilde~here", @sep) == "tilde\\R\\here"
    end

    test "encodes escape character" do
      assert Escape.encode("back\\slash", @sep) == "back\\E\\slash"
    end

    test "encodes multiple special characters" do
      assert Escape.encode("a|b^c\\d", @sep) == "a\\F\\b\\S\\c\\E\\d"
    end

    test "leaves non-special characters unchanged" do
      assert Escape.encode("plain text 123", @sep) == "plain text 123"
    end

    test "handles empty string" do
      assert Escape.encode("", @sep) == ""
    end

    test "works with custom separators" do
      custom = %Separator{field: ?!, component: ?@, repetition: ?#, escape: ?$, sub_component: ?%}
      assert Escape.encode("foo!bar", custom) == "foo$F$bar"
    end
  end

  describe "decode/2 edge cases" do
    test "decodes hex data with odd-length nibble (trailing ignored)" do
      # Odd-length hex: last nibble is dropped
      assert Escape.decode("\\X414\\", @sep) == "A"
    end

    test "decodes space escape with numeric count" do
      assert Escape.decode("\\.sp5\\", @sep) == "     "
    end

    test "decodes space escape with zero count defaults to 1" do
      assert Escape.decode("\\.sp0\\", @sep) == " "
    end

    test "decodes space escape with negative count defaults to 1" do
      assert Escape.decode("\\.sp-1\\", @sep) == " "
    end

    test "decodes space escape with leading spaces" do
      assert Escape.decode("\\.sp 2\\", @sep) == "  "
    end

    test "decodes multiple consecutive escapes" do
      assert Escape.decode("\\F\\\\S\\\\T\\", @sep) == "|^&"
    end

    test "decodes empty hex data" do
      assert Escape.decode("\\X\\", @sep) == ""
    end
  end

  describe "round-trip" do
    test "decode(encode(text)) preserves delimiter characters" do
      text = "has|pipe^caret~tilde\\backslash&amp"
      encoded = Escape.encode(text, @sep)
      assert Escape.decode(encoded, @sep) == text
    end

    test "encode(decode(escaped)) preserves standard escapes" do
      escaped = "has\\F\\pipe\\S\\caret\\R\\tilde\\E\\backslash\\T\\amp"
      decoded = Escape.decode(escaped, @sep)
      assert Escape.encode(decoded, @sep) == escaped
    end
  end
end
