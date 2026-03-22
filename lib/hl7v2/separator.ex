defmodule HL7v2.Separator do
  @moduledoc """
  Detects and manages HL7v2 message delimiters from MSH-1/MSH-2.

  Every HL7v2 message declares its delimiter set in the first 9 characters of the
  MSH segment: `MSH` (3 chars) + field separator (MSH-1, 1 char) + encoding
  characters (MSH-2, 4 or 5 chars). The defaults are `|^~\\&` but the standard
  allows any single-byte characters.

  HL7 v2.7+ allows an optional 5th encoding character: the **truncation character**.
  When present (e.g., `^~\\&#`), it indicates that field values ending with this
  character were truncated. It is a display hint, not a delimiter.

  ## Examples

      iex> HL7v2.Separator.default()
      %HL7v2.Separator{field: ?|, component: ?^, repetition: ?~, escape: ?\\\\, sub_component: ?&, truncation: nil, segment: ?\\r}

      iex> {:ok, sep} = HL7v2.Separator.from_msh("MSH|^~\\\\&|SENDING_APP|")
      iex> sep.field
      ?|

      iex> {:ok, sep} = HL7v2.Separator.from_msh("MSH|^~\\\\&#|SENDING_APP|")
      iex> sep.truncation
      ?#

  """

  defstruct field: ?|,
            component: ?^,
            repetition: ?~,
            escape: ?\\,
            sub_component: ?&,
            truncation: nil,
            segment: ?\r

  @type t :: %__MODULE__{
          field: non_neg_integer(),
          component: non_neg_integer(),
          repetition: non_neg_integer(),
          escape: non_neg_integer(),
          sub_component: non_neg_integer(),
          truncation: non_neg_integer() | nil,
          segment: non_neg_integer()
        }

  @doc """
  Returns the default HL7v2 delimiter set (`|^~\\&` with CR segment terminator, no truncation character).
  """
  @spec default() :: t()
  def default, do: %__MODULE__{}

  @doc """
  Extracts delimiters from an MSH header binary.

  MSH-1 is the single character immediately after `"MSH"` (the field separator).
  MSH-2 is the next 4 characters (component, repetition, escape, sub-component),
  written as a literal string and NOT delimited. In HL7 v2.7+, a 5th character
  (truncation) may follow. The truncation character is distinguished from the
  start of the next field by checking whether the 5th byte equals the field
  separator: if it does not, it is the truncation character.

  Returns `{:ok, separator}` or `{:error, reason}`.

  ## Examples

      iex> {:ok, sep} = HL7v2.Separator.from_msh("MSH|^~\\\\&|SendApp|")
      iex> sep.field
      ?|
      iex> sep.component
      ?^

      iex> {:ok, sep} = HL7v2.Separator.from_msh("MSH|^~\\\\&#|SendApp|")
      iex> sep.truncation
      ?#

  """
  @spec from_msh(binary()) :: {:ok, t()} | {:error, term()}

  # Extended: 5 encoding chars with truncation character (v2.7+).
  # The 5th byte after MSH-1 is a truncation char if it is NOT the field separator.
  def from_msh(<<"MSH", field, c, r, e, s, t, _rest::binary>>) when t != field do
    {:ok,
     %__MODULE__{
       field: field,
       component: c,
       repetition: r,
       escape: e,
       sub_component: s,
       truncation: t,
       segment: ?\r
     }}
  end

  # Standard: 4 encoding chars (MSH-2). The next byte is the field separator
  # or the message ends right after the encoding characters.
  def from_msh(<<"MSH", field, c, r, e, s, _rest::binary>>) do
    {:ok,
     %__MODULE__{
       field: field,
       component: c,
       repetition: r,
       escape: e,
       sub_component: s,
       segment: ?\r
     }}
  end

  def from_msh(<<"MSH", _::binary>>) do
    {:error, :insufficient_encoding_characters}
  end

  def from_msh(_) do
    {:error, :not_msh}
  end

  @doc """
  Returns the encoding characters string (MSH-2 value) for this separator set.

  When a truncation character is present (v2.7+), the returned string is 5 characters.

  ## Examples

      iex> HL7v2.Separator.encoding_characters(HL7v2.Separator.default())
      "^~\\\\&"

  """
  @spec encoding_characters(t()) :: binary()
  def encoding_characters(%__MODULE__{truncation: nil} = sep) do
    <<sep.component, sep.repetition, sep.escape, sep.sub_component>>
  end

  def encoding_characters(%__MODULE__{truncation: t} = sep) when not is_nil(t) do
    <<sep.component, sep.repetition, sep.escape, sep.sub_component, t>>
  end
end
