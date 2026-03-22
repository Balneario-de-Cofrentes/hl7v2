defmodule HL7v2.Type.XTN do
  @moduledoc """
  Extended Telecommunication Number (XTN) -- HL7v2 composite data type.

  12 components:
  1. Telephone Number (ST) -- deprecated
  2. Telecommunication Use Code (ID) -- Table 0201: PRN, WPN, NET, etc.
  3. Telecommunication Equipment Type (ID) -- Table 0202: PH, FX, CP, Internet, etc.
  4. Email Address (ST)
  5. Country Code (NM)
  6. Area/City Code (NM)
  7. Local Number (NM)
  8. Extension (NM)
  9. Any Text (ST)
  10. Extension Prefix (ST)
  11. Speed Dial Code (ST)
  12. Unformatted Telephone Number (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :telephone_number,
    :telecom_use_code,
    :telecom_equipment_type,
    :email_address,
    :country_code,
    :area_code,
    :local_number,
    :extension,
    :any_text,
    :extension_prefix,
    :speed_dial_code,
    :unformatted_telephone_number
  ]

  @type t :: %__MODULE__{
          telephone_number: binary() | nil,
          telecom_use_code: binary() | nil,
          telecom_equipment_type: binary() | nil,
          email_address: binary() | nil,
          country_code: binary() | nil,
          area_code: binary() | nil,
          local_number: binary() | nil,
          extension: binary() | nil,
          any_text: binary() | nil,
          extension_prefix: binary() | nil,
          speed_dial_code: binary() | nil,
          unformatted_telephone_number: binary() | nil
        }

  @doc """
  Parses an XTN from a list of components.

  ## Examples

      iex> HL7v2.Type.XTN.parse(["", "PRN", "PH", "", "34", "961", "123456", "789"])
      %HL7v2.Type.XTN{
        telecom_use_code: "PRN",
        telecom_equipment_type: "PH",
        country_code: "34",
        area_code: "961",
        local_number: "123456",
        extension: "789"
      }

      iex> HL7v2.Type.XTN.parse(["", "NET", "Internet", "john@example.com"])
      %HL7v2.Type.XTN{
        telecom_use_code: "NET",
        telecom_equipment_type: "Internet",
        email_address: "john@example.com"
      }

      iex> HL7v2.Type.XTN.parse([])
      %HL7v2.Type.XTN{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      telephone_number: Type.get_component(components, 0),
      telecom_use_code: Type.get_component(components, 1),
      telecom_equipment_type: Type.get_component(components, 2),
      email_address: Type.get_component(components, 3),
      country_code: Type.get_component(components, 4),
      area_code: Type.get_component(components, 5),
      local_number: Type.get_component(components, 6),
      extension: Type.get_component(components, 7),
      any_text: Type.get_component(components, 8),
      extension_prefix: Type.get_component(components, 9),
      speed_dial_code: Type.get_component(components, 10),
      unformatted_telephone_number: Type.get_component(components, 11)
    }
  end

  @doc """
  Encodes an XTN to a list of component strings.

  ## Examples

      iex> HL7v2.Type.XTN.encode(%HL7v2.Type.XTN{telecom_use_code: "NET", telecom_equipment_type: "Internet", email_address: "john@example.com"})
      ["", "NET", "Internet", "john@example.com"]

      iex> HL7v2.Type.XTN.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = xtn) do
    [
      xtn.telephone_number || "",
      xtn.telecom_use_code || "",
      xtn.telecom_equipment_type || "",
      xtn.email_address || "",
      xtn.country_code || "",
      xtn.area_code || "",
      xtn.local_number || "",
      xtn.extension || "",
      xtn.any_text || "",
      xtn.extension_prefix || "",
      xtn.speed_dial_code || "",
      xtn.unformatted_telephone_number || ""
    ]
    |> Type.trim_trailing()
  end
end
