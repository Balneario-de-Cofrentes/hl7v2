defmodule HL7v2.Type.SN do
  @moduledoc """
  Structured Numeric (SN) -- HL7v2 composite data type.

  Used for numeric values that include comparators, ranges, ratios, or
  other structured formats. Common in OBX-5 when value_type is "SN".

  4 components:
  1. Comparator (ST) -- e.g., ">", "<", ">=", "<="
  2. Num1 (NM) -- first numeric value
  3. Separator/Suffix (ST) -- e.g., "-" (range), "+" (sum), "/" (ratio), ":" (titer)
  4. Num2 (NM) -- second numeric value

  Examples: ">100", "100-200", "1:256", ">=5.0"
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.NM

  defstruct [:comparator, :num1, :separator_suffix, :num2]

  @type t :: %__MODULE__{
          comparator: binary() | nil,
          num1: NM.t() | nil,
          separator_suffix: binary() | nil,
          num2: NM.t() | nil
        }

  @doc """
  Parses an SN from a list of components.

  ## Examples

      iex> HL7v2.Type.SN.parse([">", "100"])
      %HL7v2.Type.SN{comparator: ">", num1: %HL7v2.Type.NM{value: "100", original: "100"}}

      iex> HL7v2.Type.SN.parse(["", "100", "-", "200"])
      %HL7v2.Type.SN{num1: %HL7v2.Type.NM{value: "100", original: "100"}, separator_suffix: "-", num2: %HL7v2.Type.NM{value: "200", original: "200"}}

      iex> HL7v2.Type.SN.parse(["", "1", ":", "256"])
      %HL7v2.Type.SN{num1: %HL7v2.Type.NM{value: "1", original: "1"}, separator_suffix: ":", num2: %HL7v2.Type.NM{value: "256", original: "256"}}

      iex> HL7v2.Type.SN.parse([])
      %HL7v2.Type.SN{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      comparator: Type.get_component(components, 0),
      num1: components |> Type.get_component(1) |> NM.parse(),
      separator_suffix: Type.get_component(components, 2),
      num2: components |> Type.get_component(3) |> NM.parse()
    }
  end

  @doc """
  Encodes an SN to a list of component strings.

  ## Examples

      iex> HL7v2.Type.SN.encode(%HL7v2.Type.SN{comparator: ">", num1: %HL7v2.Type.NM{value: "100", original: "100"}})
      [">", "100"]

      iex> HL7v2.Type.SN.encode(%HL7v2.Type.SN{num1: %HL7v2.Type.NM{value: "100", original: "100"}, separator_suffix: "-", num2: %HL7v2.Type.NM{value: "200", original: "200"}})
      ["", "100", "-", "200"]

      iex> HL7v2.Type.SN.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = sn) do
    [
      sn.comparator || "",
      NM.encode(sn.num1),
      sn.separator_suffix || "",
      NM.encode(sn.num2)
    ]
    |> Type.trim_trailing()
  end
end
