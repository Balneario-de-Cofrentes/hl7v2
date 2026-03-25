defmodule HL7v2.Type.AD do
  @moduledoc """
  Address (AD) -- HL7v2 composite data type.

  A simpler address type used in older HL7 versions. Superseded by XAD in v2.3+.

  8 components:
  1. Street Address (ST)
  2. Other Designation (ST)
  3. City (ST)
  4. State or Province (ST)
  5. Zip or Postal Code (ST)
  6. Country (ID) -- Table 0399
  7. Address Type (ID) -- Table 0190
  8. Other Geographic Designation (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :street_address,
    :other_designation,
    :city,
    :state_or_province,
    :zip_or_postal_code,
    :country,
    :address_type,
    :other_geographic_designation
  ]

  @type t :: %__MODULE__{
          street_address: binary() | nil,
          other_designation: binary() | nil,
          city: binary() | nil,
          state_or_province: binary() | nil,
          zip_or_postal_code: binary() | nil,
          country: binary() | nil,
          address_type: binary() | nil,
          other_geographic_designation: binary() | nil
        }

  @doc """
  Parses an AD from a list of components.

  ## Examples

      iex> HL7v2.Type.AD.parse(["123 Main St", "Suite 100", "Springfield", "IL", "62704", "USA"])
      %HL7v2.Type.AD{street_address: "123 Main St", other_designation: "Suite 100", city: "Springfield", state_or_province: "IL", zip_or_postal_code: "62704", country: "USA"}

      iex> HL7v2.Type.AD.parse(["456 Oak Ave"])
      %HL7v2.Type.AD{street_address: "456 Oak Ave"}

      iex> HL7v2.Type.AD.parse([])
      %HL7v2.Type.AD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      street_address: Type.get_component(components, 0),
      other_designation: Type.get_component(components, 1),
      city: Type.get_component(components, 2),
      state_or_province: Type.get_component(components, 3),
      zip_or_postal_code: Type.get_component(components, 4),
      country: Type.get_component(components, 5),
      address_type: Type.get_component(components, 6),
      other_geographic_designation: Type.get_component(components, 7)
    }
  end

  @doc """
  Encodes an AD to a list of component strings.

  ## Examples

      iex> HL7v2.Type.AD.encode(%HL7v2.Type.AD{street_address: "123 Main St", city: "Springfield", state_or_province: "IL"})
      ["123 Main St", "", "Springfield", "IL"]

      iex> HL7v2.Type.AD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ad) do
    [
      ad.street_address || "",
      ad.other_designation || "",
      ad.city || "",
      ad.state_or_province || "",
      ad.zip_or_postal_code || "",
      ad.country || "",
      ad.address_type || "",
      ad.other_geographic_designation || ""
    ]
    |> Type.trim_trailing()
  end
end
