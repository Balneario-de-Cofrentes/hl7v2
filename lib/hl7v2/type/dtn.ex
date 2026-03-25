defmodule HL7v2.Type.DTN do
  @moduledoc """
  Day Type and Number (DTN) -- HL7v2 composite data type.

  Specifies a day type and the number of days for insurance certification.

  2 components:
  1. Day Type (IS) -- Table 0149: e.g., "AP" (approved), "DE" (denied), "PE" (pending)
  2. Number of Days (NM) -- the number of days
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.NM

  defstruct [
    :day_type,
    :number_of_days
  ]

  @type t :: %__MODULE__{
          day_type: binary() | nil,
          number_of_days: NM.t() | nil
        }

  @doc """
  Parses a DTN from a list of components.

  ## Examples

      iex> HL7v2.Type.DTN.parse(["AP", "10"])
      %HL7v2.Type.DTN{day_type: "AP", number_of_days: %HL7v2.Type.NM{value: "10", original: "10"}}

      iex> HL7v2.Type.DTN.parse([])
      %HL7v2.Type.DTN{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      day_type: Type.get_component(components, 0),
      number_of_days: components |> Type.get_component(1) |> NM.parse()
    }
  end

  @doc """
  Encodes a DTN to a list of component strings.

  ## Examples

      iex> HL7v2.Type.DTN.encode(%HL7v2.Type.DTN{day_type: "AP", number_of_days: %HL7v2.Type.NM{value: "10", original: "10"}})
      ["AP", "10"]

      iex> HL7v2.Type.DTN.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = dtn) do
    [
      dtn.day_type || "",
      NM.encode(dtn.number_of_days)
    ]
    |> Type.trim_trailing()
  end
end
