defmodule HL7v2.Type.XAD do
  @moduledoc """
  Extended Address (XAD) -- HL7v2 composite data type.

  14 components:
  1. Street Address (SAD) -- sub-components delimited by `&`
  2. Other Designation (ST)
  3. City (ST)
  4. State or Province (ST)
  5. Zip or Postal Code (ST)
  6. Country (ID) -- Table 0399, ISO 3166-1
  7. Address Type (ID) -- Table 0190: H=Home, B=Business, M=Mailing, etc.
  8. Other Geographic Designation (ST)
  9. County/Parish Code (IS) -- Table 0289
  10. Census Tract (IS) -- Table 0288
  11. Address Representation Code (ID) -- Table 0465
  12. Address Validity Range (DR) -- deprecated, sub-components delimited by `&`
  13. Effective Date (TS) -- sub-components delimited by `&`
  14. Expiration Date (TS) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{SAD, DR, TS}

  defstruct [
    :street_address,
    :other_designation,
    :city,
    :state,
    :zip,
    :country,
    :address_type,
    :other_geographic,
    :county_code,
    :census_tract,
    :address_representation_code,
    :address_validity_range,
    :effective_date,
    :expiration_date
  ]

  @type t :: %__MODULE__{
          street_address: SAD.t() | nil,
          other_designation: binary() | nil,
          city: binary() | nil,
          state: binary() | nil,
          zip: binary() | nil,
          country: binary() | nil,
          address_type: binary() | nil,
          other_geographic: binary() | nil,
          county_code: binary() | nil,
          census_tract: binary() | nil,
          address_representation_code: binary() | nil,
          address_validity_range: DR.t() | nil,
          effective_date: TS.t() | nil,
          expiration_date: TS.t() | nil
        }

  @doc """
  Parses an XAD from a list of components.

  ## Examples

      iex> HL7v2.Type.XAD.parse(["123 Main St&Main St&123", "", "Springfield", "IL", "62704", "USA", "H"])
      %HL7v2.Type.XAD{
        street_address: %HL7v2.Type.SAD{street_or_mailing_address: "123 Main St", street_name: "Main St", dwelling_number: "123"},
        city: "Springfield",
        state: "IL",
        zip: "62704",
        country: "USA",
        address_type: "H"
      }

      iex> HL7v2.Type.XAD.parse([])
      %HL7v2.Type.XAD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      street_address: Type.parse_sub(SAD, Type.get_component(components, 0)),
      other_designation: Type.get_component(components, 1),
      city: Type.get_component(components, 2),
      state: Type.get_component(components, 3),
      zip: Type.get_component(components, 4),
      country: Type.get_component(components, 5),
      address_type: Type.get_component(components, 6),
      other_geographic: Type.get_component(components, 7),
      county_code: Type.get_component(components, 8),
      census_tract: Type.get_component(components, 9),
      address_representation_code: Type.get_component(components, 10),
      address_validity_range: Type.parse_sub(DR, Type.get_component(components, 11)),
      effective_date: Type.parse_sub_ts(Type.get_component(components, 12)),
      expiration_date: Type.parse_sub_ts(Type.get_component(components, 13))
    }
  end

  @doc """
  Encodes an XAD to a list of component strings.

  ## Examples

      iex> HL7v2.Type.XAD.encode(%HL7v2.Type.XAD{
      ...>   street_address: %HL7v2.Type.SAD{street_or_mailing_address: "123 Main St"},
      ...>   city: "Springfield",
      ...>   state: "IL",
      ...>   zip: "62704"
      ...> })
      ["123 Main St", "", "Springfield", "IL", "62704"]

      iex> HL7v2.Type.XAD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = xad) do
    [
      Type.encode_sub(SAD, xad.street_address),
      xad.other_designation || "",
      xad.city || "",
      xad.state || "",
      xad.zip || "",
      xad.country || "",
      xad.address_type || "",
      xad.other_geographic || "",
      xad.county_code || "",
      xad.census_tract || "",
      xad.address_representation_code || "",
      Type.encode_sub(DR, xad.address_validity_range),
      Type.encode_sub_ts(xad.effective_date),
      Type.encode_sub_ts(xad.expiration_date)
    ]
    |> Type.trim_trailing()
  end

end
