defmodule HL7v2.Type.CWE do
  @moduledoc """
  Coded with Exceptions (CWE) -- HL7v2 composite data type.

  Replaces CE in v2.5+. Used when multiple coding systems may apply,
  the table can be extended locally, or free text may substitute for a code.

  9 components:
  1. Identifier (ST)
  2. Text (ST)
  3. Name of Coding System (ID) -- Table 0396
  4. Alternate Identifier (ST)
  5. Alternate Text (ST)
  6. Name of Alternate Coding System (ID) -- Table 0396
  7. Coding System Version ID (ST)
  8. Alternate Coding System Version ID (ST)
  9. Original Text (ST)

  If only free text is available, populate component 9 and leave 1-3 empty.
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
  Parses a CWE from a list of components.

  ## Examples

      iex> HL7v2.Type.CWE.parse(["I48.0", "Paroxysmal atrial fibrillation", "I10"])
      %HL7v2.Type.CWE{identifier: "I48.0", text: "Paroxysmal atrial fibrillation", name_of_coding_system: "I10"}

      iex> HL7v2.Type.CWE.parse([])
      %HL7v2.Type.CWE{}

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
  Encodes a CWE to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CWE.encode(%HL7v2.Type.CWE{identifier: "I48.0", text: "Paroxysmal atrial fibrillation", name_of_coding_system: "I10"})
      ["I48.0", "Paroxysmal atrial fibrillation", "I10"]

      iex> HL7v2.Type.CWE.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = cwe) do
    [
      cwe.identifier || "",
      cwe.text || "",
      cwe.name_of_coding_system || "",
      cwe.alternate_identifier || "",
      cwe.alternate_text || "",
      cwe.name_of_alternate_coding_system || "",
      cwe.coding_system_version_id || "",
      cwe.alternate_coding_system_version_id || "",
      cwe.original_text || ""
    ]
    |> Type.trim_trailing()
  end
end
