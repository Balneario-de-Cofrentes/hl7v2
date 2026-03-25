defmodule HL7v2.Type.CF do
  @moduledoc """
  Coded Element with Formatted Values (CF) -- HL7v2 composite data type.

  Same structure as CE but components 2 and 5 are FT (Formatted Text) instead of ST.

  6 components:
  1. Identifier (ST)
  2. Formatted Text (FT)
  3. Name of Coding System (ID) -- Table 0396
  4. Alternate Identifier (ST)
  5. Alternate Formatted Text (FT)
  6. Name of Alternate Coding System (ID) -- Table 0396
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :identifier,
    :formatted_text,
    :name_of_coding_system,
    :alternate_identifier,
    :alternate_formatted_text,
    :name_of_alternate_coding_system
  ]

  @type t :: %__MODULE__{
          identifier: binary() | nil,
          formatted_text: binary() | nil,
          name_of_coding_system: binary() | nil,
          alternate_identifier: binary() | nil,
          alternate_formatted_text: binary() | nil,
          name_of_alternate_coding_system: binary() | nil
        }

  @doc """
  Parses a CF from a list of components.

  ## Examples

      iex> HL7v2.Type.CF.parse(["I9", "Diagnosis text", "I9C"])
      %HL7v2.Type.CF{identifier: "I9", formatted_text: "Diagnosis text", name_of_coding_system: "I9C"}

      iex> HL7v2.Type.CF.parse([])
      %HL7v2.Type.CF{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      identifier: Type.get_component(components, 0),
      formatted_text: Type.get_component(components, 1),
      name_of_coding_system: Type.get_component(components, 2),
      alternate_identifier: Type.get_component(components, 3),
      alternate_formatted_text: Type.get_component(components, 4),
      name_of_alternate_coding_system: Type.get_component(components, 5)
    }
  end

  @doc """
  Encodes a CF to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CF.encode(%HL7v2.Type.CF{identifier: "I9", formatted_text: "Diagnosis text", name_of_coding_system: "I9C"})
      ["I9", "Diagnosis text", "I9C"]

      iex> HL7v2.Type.CF.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = cf) do
    [
      cf.identifier || "",
      cf.formatted_text || "",
      cf.name_of_coding_system || "",
      cf.alternate_identifier || "",
      cf.alternate_formatted_text || "",
      cf.name_of_alternate_coding_system || ""
    ]
    |> Type.trim_trailing()
  end
end
