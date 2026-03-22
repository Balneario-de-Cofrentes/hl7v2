defmodule HL7v2.Type.CNE do
  @moduledoc """
  Coded with No Exceptions (CNE) -- HL7v2 composite data type.

  Like CWE but requires a valid code. Free text alone (component 9 only)
  is NOT permitted. Component 1 (Identifier) is required.

  9 components (same layout as CWE):
  1. Identifier (ST) -- REQUIRED
  2. Text (ST)
  3. Name of Coding System (ID) -- Table 0396
  4. Alternate Identifier (ST)
  5. Alternate Text (ST)
  6. Name of Alternate Coding System (ID) -- Table 0396
  7. Coding System Version ID (ST)
  8. Alternate Coding System Version ID (ST)
  9. Original Text (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :identifier,
    :text,
    :name_of_coding_system,
    :alternate_identifier,
    :alternate_text,
    :name_of_alternate_coding_system,
    :coding_system_version_id,
    :alternate_coding_system_version_id,
    :original_text
  ]

  @type t :: %__MODULE__{
          identifier: binary() | nil,
          text: binary() | nil,
          name_of_coding_system: binary() | nil,
          alternate_identifier: binary() | nil,
          alternate_text: binary() | nil,
          name_of_alternate_coding_system: binary() | nil,
          coding_system_version_id: binary() | nil,
          alternate_coding_system_version_id: binary() | nil,
          original_text: binary() | nil
        }

  @doc """
  Parses a CNE from a list of components.

  ## Examples

      iex> HL7v2.Type.CNE.parse(["F", "Female", "HL70001"])
      %HL7v2.Type.CNE{identifier: "F", text: "Female", name_of_coding_system: "HL70001"}

      iex> HL7v2.Type.CNE.parse([])
      %HL7v2.Type.CNE{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      identifier: Type.get_component(components, 0),
      text: Type.get_component(components, 1),
      name_of_coding_system: Type.get_component(components, 2),
      alternate_identifier: Type.get_component(components, 3),
      alternate_text: Type.get_component(components, 4),
      name_of_alternate_coding_system: Type.get_component(components, 5),
      coding_system_version_id: Type.get_component(components, 6),
      alternate_coding_system_version_id: Type.get_component(components, 7),
      original_text: Type.get_component(components, 8)
    }
  end

  @doc """
  Encodes a CNE to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CNE.encode(%HL7v2.Type.CNE{identifier: "F", text: "Female", name_of_coding_system: "HL70001"})
      ["F", "Female", "HL70001"]

      iex> HL7v2.Type.CNE.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = cne) do
    [
      cne.identifier || "",
      cne.text || "",
      cne.name_of_coding_system || "",
      cne.alternate_identifier || "",
      cne.alternate_text || "",
      cne.name_of_alternate_coding_system || "",
      cne.coding_system_version_id || "",
      cne.alternate_coding_system_version_id || "",
      cne.original_text || ""
    ]
    |> Type.trim_trailing()
  end
end
