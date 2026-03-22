defmodule HL7v2.Type.CNN do
  @moduledoc """
  Composite Number and Name without Authority (CNN) -- HL7v2 composite data type.

  A simplified person identifier used as the name component of NDL (Name with
  Date and Location). Unlike XCN, CNN does not carry assigning authority or
  identifier type information.

  11 components per HL7 v2.5.1:
  1. ID Number (ST)
  2. Family Name (ST) -- simple string, not FN composite
  3. Given Name (ST)
  4. Second and Further Given Names or Initials (ST)
  5. Suffix (ST)
  6. Prefix (ST)
  7. Degree (IS)
  8. Source Table (IS)
  9. Assigning Authority - Namespace ID (IS)
  10. Assigning Authority - Universal ID (ST)
  11. Assigning Authority - Universal ID Type (ID)

  Note: components 9-11 are flattened parts of an HD, not a nested HD composite.
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :id_number,
    :family_name,
    :given_name,
    :second_name,
    :suffix,
    :prefix,
    :degree,
    :source_table,
    :assigning_authority_namespace_id,
    :assigning_authority_universal_id,
    :assigning_authority_universal_id_type
  ]

  @type t :: %__MODULE__{
          id_number: binary() | nil,
          family_name: binary() | nil,
          given_name: binary() | nil,
          second_name: binary() | nil,
          suffix: binary() | nil,
          prefix: binary() | nil,
          degree: binary() | nil,
          source_table: binary() | nil,
          assigning_authority_namespace_id: binary() | nil,
          assigning_authority_universal_id: binary() | nil,
          assigning_authority_universal_id_type: binary() | nil
        }

  @doc """
  Parses a CNN from a list of components (or sub-components).

  ## Examples

      iex> HL7v2.Type.CNN.parse(["12345", "Smith", "John"])
      %HL7v2.Type.CNN{id_number: "12345", family_name: "Smith", given_name: "John"}

      iex> HL7v2.Type.CNN.parse(["12345", "Smith", "John", "Q", "JR", "DR", "MD", "PHYS", "NPI", "2.16.840.1.113883.4.6", "ISO"])
      %HL7v2.Type.CNN{
        id_number: "12345",
        family_name: "Smith",
        given_name: "John",
        second_name: "Q",
        suffix: "JR",
        prefix: "DR",
        degree: "MD",
        source_table: "PHYS",
        assigning_authority_namespace_id: "NPI",
        assigning_authority_universal_id: "2.16.840.1.113883.4.6",
        assigning_authority_universal_id_type: "ISO"
      }

      iex> HL7v2.Type.CNN.parse([])
      %HL7v2.Type.CNN{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      id_number: Type.get_component(components, 0),
      family_name: Type.get_component(components, 1),
      given_name: Type.get_component(components, 2),
      second_name: Type.get_component(components, 3),
      suffix: Type.get_component(components, 4),
      prefix: Type.get_component(components, 5),
      degree: Type.get_component(components, 6),
      source_table: Type.get_component(components, 7),
      assigning_authority_namespace_id: Type.get_component(components, 8),
      assigning_authority_universal_id: Type.get_component(components, 9),
      assigning_authority_universal_id_type: Type.get_component(components, 10)
    }
  end

  @doc """
  Encodes a CNN to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CNN.encode(%HL7v2.Type.CNN{id_number: "12345", family_name: "Smith", given_name: "John"})
      ["12345", "Smith", "John"]

      iex> HL7v2.Type.CNN.encode(nil)
      []

      iex> HL7v2.Type.CNN.encode(%HL7v2.Type.CNN{})
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = cnn) do
    [
      cnn.id_number || "",
      cnn.family_name || "",
      cnn.given_name || "",
      cnn.second_name || "",
      cnn.suffix || "",
      cnn.prefix || "",
      cnn.degree || "",
      cnn.source_table || "",
      cnn.assigning_authority_namespace_id || "",
      cnn.assigning_authority_universal_id || "",
      cnn.assigning_authority_universal_id_type || ""
    ]
    |> Type.trim_trailing()
  end
end
