defmodule HL7v2.Type.ED do
  @moduledoc """
  Encapsulated Data (ED) -- HL7v2 composite data type.

  Used for transmitting encapsulated data from other standards (e.g., PDF,
  JPEG, DICOM, CDA). Common in OBX-5 when value_type is "ED".

  5 components:
  1. Source Application (HD) -- sub-components delimited by `&`
  2. Type of Data (ID) -- Table 0191: e.g., "Application", "Audio", "Image", "TEXT"
  3. Data Subtype (ID) -- Table 0291: e.g., "PDF", "RTF", "JPEG", "DICOM", "x-hl7-cda-level-one"
  4. Encoding (ID) -- Table 0299: "A" (no encoding), "Hex", "Base64"
  5. Data (TX) -- the actual encoded data
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.HD

  defstruct [:source_application, :type_of_data, :data_subtype, :encoding, :data]

  @type t :: %__MODULE__{
          source_application: HD.t() | nil,
          type_of_data: binary() | nil,
          data_subtype: binary() | nil,
          encoding: binary() | nil,
          data: binary() | nil
        }

  @doc """
  Parses an ED from a list of components.

  ## Examples

      iex> HL7v2.Type.ED.parse(["LAB&1.2.3&ISO", "Application", "PDF", "Base64", "JVBER..."])
      %HL7v2.Type.ED{
        source_application: %HL7v2.Type.HD{namespace_id: "LAB", universal_id: "1.2.3", universal_id_type: "ISO"},
        type_of_data: "Application",
        data_subtype: "PDF",
        encoding: "Base64",
        data: "JVBER..."
      }

      iex> HL7v2.Type.ED.parse(["", "TEXT", "plain", "A", "Hello world"])
      %HL7v2.Type.ED{type_of_data: "TEXT", data_subtype: "plain", encoding: "A", data: "Hello world"}

      iex> HL7v2.Type.ED.parse([])
      %HL7v2.Type.ED{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      source_application: Type.parse_sub(HD, Type.get_component(components, 0)),
      type_of_data: Type.get_component(components, 1),
      data_subtype: Type.get_component(components, 2),
      encoding: Type.get_component(components, 3),
      data: Type.get_component(components, 4)
    }
  end

  @doc """
  Encodes an ED to a list of component strings.

  ## Examples

      iex> HL7v2.Type.ED.encode(%HL7v2.Type.ED{
      ...>   source_application: %HL7v2.Type.HD{namespace_id: "LAB"},
      ...>   type_of_data: "Application",
      ...>   data_subtype: "PDF",
      ...>   encoding: "Base64",
      ...>   data: "JVBER..."
      ...> })
      ["LAB", "Application", "PDF", "Base64", "JVBER..."]

      iex> HL7v2.Type.ED.encode(%HL7v2.Type.ED{type_of_data: "TEXT", data_subtype: "plain", encoding: "A", data: "Hello"})
      ["", "TEXT", "plain", "A", "Hello"]

      iex> HL7v2.Type.ED.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ed) do
    [
      Type.encode_sub(HD, ed.source_application),
      ed.type_of_data || "",
      ed.data_subtype || "",
      ed.encoding || "",
      ed.data || ""
    ]
    |> Type.trim_trailing()
  end
end
