defmodule HL7v2.Type.SAD do
  @moduledoc """
  Street Address (SAD) -- HL7v2 sub-component composite type.

  Used as component 1 of XAD (Extended Address). Contains 3
  sub-components delimited by `&` when embedded in a composite field.

  Sub-components:
  1. Street or Mailing Address (ST)
  2. Street Name (ST)
  3. Dwelling Number (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:street_or_mailing_address, :street_name, :dwelling_number]

  @type t :: %__MODULE__{
          street_or_mailing_address: binary() | nil,
          street_name: binary() | nil,
          dwelling_number: binary() | nil
        }

  @doc """
  Parses a street address from a list of sub-components.

  ## Examples

      iex> HL7v2.Type.SAD.parse(["123 Main St", "Main St", "123"])
      %HL7v2.Type.SAD{street_or_mailing_address: "123 Main St", street_name: "Main St", dwelling_number: "123"}

      iex> HL7v2.Type.SAD.parse(["123 Main St"])
      %HL7v2.Type.SAD{street_or_mailing_address: "123 Main St"}

      iex> HL7v2.Type.SAD.parse([])
      %HL7v2.Type.SAD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      street_or_mailing_address: Type.get_component(components, 0),
      street_name: Type.get_component(components, 1),
      dwelling_number: Type.get_component(components, 2)
    }
  end

  @doc """
  Encodes a street address to a list of sub-component strings.

  ## Examples

      iex> HL7v2.Type.SAD.encode(%HL7v2.Type.SAD{street_or_mailing_address: "123 Main St", street_name: "Main St", dwelling_number: "123"})
      ["123 Main St", "Main St", "123"]

      iex> HL7v2.Type.SAD.encode(%HL7v2.Type.SAD{street_or_mailing_address: "123 Main St"})
      ["123 Main St"]

      iex> HL7v2.Type.SAD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = sad) do
    [
      sad.street_or_mailing_address || "",
      sad.street_name || "",
      sad.dwelling_number || ""
    ]
    |> Type.trim_trailing()
  end
end
