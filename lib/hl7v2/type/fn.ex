defmodule HL7v2.Type.FN do
  @moduledoc """
  Family Name (FN) -- HL7v2 sub-component composite type.

  Used as component 1 of XPN (Extended Person Name). Contains 5
  sub-components delimited by `&` when embedded in a composite field.

  Sub-components:
  1. Surname (ST) -- required
  2. Own Surname Prefix (ST)
  3. Own Surname (ST)
  4. Surname Prefix From Partner/Spouse (ST)
  5. Surname From Partner/Spouse (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :surname,
    :own_surname_prefix,
    :own_surname,
    :surname_prefix_from_partner,
    :surname_from_partner
  ]

  @type t :: %__MODULE__{
          surname: binary() | nil,
          own_surname_prefix: binary() | nil,
          own_surname: binary() | nil,
          surname_prefix_from_partner: binary() | nil,
          surname_from_partner: binary() | nil
        }

  @doc """
  Parses a family name from a list of sub-components.

  ## Examples

      iex> HL7v2.Type.FN.parse(["Smith"])
      %HL7v2.Type.FN{surname: "Smith"}

      iex> HL7v2.Type.FN.parse(["Smith", "Van"])
      %HL7v2.Type.FN{surname: "Smith", own_surname_prefix: "Van"}

      iex> HL7v2.Type.FN.parse([])
      %HL7v2.Type.FN{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      surname: Type.get_component(components, 0),
      own_surname_prefix: Type.get_component(components, 1),
      own_surname: Type.get_component(components, 2),
      surname_prefix_from_partner: Type.get_component(components, 3),
      surname_from_partner: Type.get_component(components, 4)
    }
  end

  @doc """
  Encodes a family name to a list of sub-component strings.

  ## Examples

      iex> HL7v2.Type.FN.encode(%HL7v2.Type.FN{surname: "Smith"})
      ["Smith"]

      iex> HL7v2.Type.FN.encode(%HL7v2.Type.FN{surname: "Smith", own_surname_prefix: "Van"})
      ["Smith", "Van"]

      iex> HL7v2.Type.FN.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = fn_type) do
    [
      fn_type.surname || "",
      fn_type.own_surname_prefix || "",
      fn_type.own_surname || "",
      fn_type.surname_prefix_from_partner || "",
      fn_type.surname_from_partner || ""
    ]
    |> Type.trim_trailing()
  end
end
