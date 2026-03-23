defmodule HL7v2.Type.RP do
  @moduledoc """
  Reference Pointer (RP) -- HL7v2 composite data type.

  Points to data stored externally to the message. Common in OBX-5
  when value_type is "RP".

  4 components:
  1. Pointer (ST) -- reference to external data (e.g., URL, file path)
  2. Application ID (HD) -- sub-components delimited by `&`
  3. Type of Data (ID) -- Table 0191: e.g., "Application", "Audio", "Image", "TEXT"
  4. Subtype (ID) -- Table 0291: e.g., "PDF", "JPEG", "DICOM"
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.HD

  defstruct [:pointer, :application_id, :type_of_data, :subtype]

  @type t :: %__MODULE__{
          pointer: binary() | nil,
          application_id: HD.t() | nil,
          type_of_data: binary() | nil,
          subtype: binary() | nil
        }

  @doc """
  Parses an RP from a list of components.

  ## Examples

      iex> HL7v2.Type.RP.parse(["/reports/12345.pdf", "LAB&1.2.3&ISO", "Application", "PDF"])
      %HL7v2.Type.RP{
        pointer: "/reports/12345.pdf",
        application_id: %HL7v2.Type.HD{namespace_id: "LAB", universal_id: "1.2.3", universal_id_type: "ISO"},
        type_of_data: "Application",
        subtype: "PDF"
      }

      iex> HL7v2.Type.RP.parse(["http://example.com/image.jpg"])
      %HL7v2.Type.RP{pointer: "http://example.com/image.jpg"}

      iex> HL7v2.Type.RP.parse([])
      %HL7v2.Type.RP{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      pointer: Type.get_component(components, 0),
      application_id: Type.parse_sub(HD, Type.get_component(components, 1)),
      type_of_data: Type.get_component(components, 2),
      subtype: Type.get_component(components, 3)
    }
  end

  @doc """
  Encodes an RP to a list of component strings.

  ## Examples

      iex> HL7v2.Type.RP.encode(%HL7v2.Type.RP{
      ...>   pointer: "/reports/12345.pdf",
      ...>   application_id: %HL7v2.Type.HD{namespace_id: "LAB", universal_id: "1.2.3", universal_id_type: "ISO"},
      ...>   type_of_data: "Application",
      ...>   subtype: "PDF"
      ...> })
      ["/reports/12345.pdf", "LAB&1.2.3&ISO", "Application", "PDF"]

      iex> HL7v2.Type.RP.encode(%HL7v2.Type.RP{pointer: "/image.jpg"})
      ["/image.jpg"]

      iex> HL7v2.Type.RP.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = rp) do
    [
      rp.pointer || "",
      Type.encode_sub(HD, rp.application_id),
      rp.type_of_data || "",
      rp.subtype || ""
    ]
    |> Type.trim_trailing()
  end
end
