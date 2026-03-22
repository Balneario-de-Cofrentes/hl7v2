defmodule HL7v2.Type.XON do
  @moduledoc """
  Extended Composite Name and ID for Organizations (XON) -- HL7v2 composite data type.

  10 components:
  1. Organization Name (ST)
  2. Organization Name Type Code (IS) -- Table 0204: A=Alias, D=Display, L=Legal
  3. ID Number (NM) -- deprecated
  4. Check Digit (NM)
  5. Check Digit Scheme (ID) -- Table 0061
  6. Assigning Authority (HD) -- sub-components delimited by `&`
  7. Identifier Type Code (ID) -- Table 0203
  8. Assigning Facility (HD) -- sub-components delimited by `&`
  9. Name Representation Code (ID) -- Table 0465
  10. Organization Identifier (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.HD

  defstruct [
    :organization_name,
    :organization_name_type_code,
    :id_number,
    :check_digit,
    :check_digit_scheme,
    :assigning_authority,
    :identifier_type_code,
    :assigning_facility,
    :name_representation_code,
    :organization_identifier
  ]

  @type t :: %__MODULE__{
          organization_name: binary() | nil,
          organization_name_type_code: binary() | nil,
          id_number: binary() | nil,
          check_digit: binary() | nil,
          check_digit_scheme: binary() | nil,
          assigning_authority: HD.t() | nil,
          identifier_type_code: binary() | nil,
          assigning_facility: HD.t() | nil,
          name_representation_code: binary() | nil,
          organization_identifier: binary() | nil
        }

  @doc """
  Parses an XON from a list of components.

  ## Examples

      iex> HL7v2.Type.XON.parse(["General Hospital", "L", "", "", "", "HOSP&2.16.840.1.113883.19.4.6&ISO", "XX", "", "", "GH001"])
      %HL7v2.Type.XON{
        organization_name: "General Hospital",
        organization_name_type_code: "L",
        assigning_authority: %HL7v2.Type.HD{namespace_id: "HOSP", universal_id: "2.16.840.1.113883.19.4.6", universal_id_type: "ISO"},
        identifier_type_code: "XX",
        organization_identifier: "GH001"
      }

      iex> HL7v2.Type.XON.parse([])
      %HL7v2.Type.XON{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      organization_name: Type.get_component(components, 0),
      organization_name_type_code: Type.get_component(components, 1),
      id_number: Type.get_component(components, 2),
      check_digit: Type.get_component(components, 3),
      check_digit_scheme: Type.get_component(components, 4),
      assigning_authority: parse_sub_hd(Type.get_component(components, 5)),
      identifier_type_code: Type.get_component(components, 6),
      assigning_facility: parse_sub_hd(Type.get_component(components, 7)),
      name_representation_code: Type.get_component(components, 8),
      organization_identifier: Type.get_component(components, 9)
    }
  end

  @doc """
  Encodes an XON to a list of component strings.

  ## Examples

      iex> HL7v2.Type.XON.encode(%HL7v2.Type.XON{organization_name: "General Hospital", organization_name_type_code: "L"})
      ["General Hospital", "L"]

      iex> HL7v2.Type.XON.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = xon) do
    [
      xon.organization_name || "",
      xon.organization_name_type_code || "",
      xon.id_number || "",
      xon.check_digit || "",
      xon.check_digit_scheme || "",
      encode_sub_hd(xon.assigning_authority),
      xon.identifier_type_code || "",
      encode_sub_hd(xon.assigning_facility),
      xon.name_representation_code || "",
      xon.organization_identifier || ""
    ]
    |> Type.trim_trailing()
  end

  defp parse_sub_hd(nil), do: nil

  defp parse_sub_hd(value) when is_binary(value) do
    subs = String.split(value, "&")
    hd_val = HD.parse(subs)
    if all_nil?(hd_val), do: nil, else: hd_val
  end

  defp encode_sub_hd(nil), do: ""
  defp encode_sub_hd(%HD{} = hd_val), do: hd_val |> HD.encode() |> Enum.join("&")

  defp all_nil?(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&is_nil/1)
  end
end
