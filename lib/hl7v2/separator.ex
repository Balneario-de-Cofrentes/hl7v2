defmodule HL7v2.Separator do
  @moduledoc """
  Detects and manages HL7v2 message delimiters from MSH-1/MSH-2.

  Every HL7v2 message declares its delimiter set in the first 9 characters of the
  MSH segment: `MSH` (3 chars) + field separator (MSH-1, 1 char) + encoding
  characters (MSH-2, 4 chars). The defaults are `|^~\\&` but the standard allows
  any single-byte characters.

  ## Examples

      iex> HL7v2.Separator.default()
      %HL7v2.Separator{field: ?|, component: ?^, repetition: ?~, escape: ?\\\\, sub_component: ?&, segment: ?\\r}

      iex> {:ok, sep} = HL7v2.Separator.from_msh("MSH|^~\\\\&|SENDING_APP|")
      iex> sep.field
      ?|

  """

  defstruct field: ?|,
            component: ?^,
            repetition: ?~,
            escape: ?\\,
            sub_component: ?&,
            segment: ?\r

  @type t :: %__MODULE__{
          field: non_neg_integer(),
          component: non_neg_integer(),
          repetition: non_neg_integer(),
          escape: non_neg_integer(),
          sub_component: non_neg_integer(),
          segment: non_neg_integer()
        }

  @doc """
  Returns the default HL7v2 delimiter set (`|^~\\&` with CR segment terminator).
  """
  @spec default() :: t()
  def default, do: %__MODULE__{}

  @doc """
  Extracts delimiters from an MSH header binary.

  MSH-1 is the single character immediately after `"MSH"` (the field separator).
  MSH-2 is the next 4 characters (component, repetition, escape, sub-component),
  written as a literal string and NOT delimited.

  Returns `{:ok, separator}` or `{:error, reason}`.

  ## Examples

      iex> {:ok, sep} = HL7v2.Separator.from_msh("MSH|^~\\\\&|SendApp|")
      iex> sep.field
      ?|
      iex> sep.component
      ?^

  """
  @spec from_msh(binary()) :: {:ok, t()} | {:error, term()}
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

  ## Examples

      iex> HL7v2.Separator.encoding_characters(HL7v2.Separator.default())
      "^~\\\\&"

  """
  @spec encoding_characters(t()) :: binary()
  def encoding_characters(%__MODULE__{} = sep) do
    <<sep.component, sep.repetition, sep.escape, sep.sub_component>>
  end
end
