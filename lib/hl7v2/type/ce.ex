defmodule HL7v2.Type.CE do
  @moduledoc """
  Coded Element (CE) -- HL7v2 composite data type.

  Deprecated as of v2.5. Retained for backward compatibility.
  Use CWE or CNE for new implementations.

  6 components:
  1. Identifier (ST)
  2. Text (ST)
  3. Name of Coding System (ID) -- Table 0396
  4. Alternate Identifier (ST)
  5. Alternate Text (ST)
  6. Name of Alternate Coding System (ID) -- Table 0396
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :identifier,
    :text,
    :name_of_coding_system,
    :alternate_identifier,
    :alternate_text,
    :name_of_alternate_coding_system
  ]

  @type t :: %__MODULE__{
          identifier: binary() | nil,
          text: binary() | nil,
          name_of_coding_system: binary() | nil,
          alternate_identifier: binary() | nil,
          alternate_text: binary() | nil,
          name_of_alternate_coding_system: binary() | nil
        }

  @doc """
  Parses a CE from a list of components.

  ## Examples

      iex> HL7v2.Type.CE.parse(["784.0", "Headache", "I9C"])
      %HL7v2.Type.CE{identifier: "784.0", text: "Headache", name_of_coding_system: "I9C"}

      iex> HL7v2.Type.CE.parse([])
      %HL7v2.Type.CE{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      identifier: Type.get_component(components, 0),
      text: Type.get_component(components, 1),
      name_of_coding_system: Type.get_component(components, 2),
      alternate_identifier: Type.get_component(components, 3),
      alternate_text: Type.get_component(components, 4),
      name_of_alternate_coding_system: Type.get_component(components, 5)
    }
  end

  @doc """
  Encodes a CE to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CE.encode(%HL7v2.Type.CE{identifier: "784.0", text: "Headache", name_of_coding_system: "I9C"})
      ["784.0", "Headache", "I9C"]

      iex> HL7v2.Type.CE.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ce) do
    [
      ce.identifier || "",
      ce.text || "",
      ce.name_of_coding_system || "",
      ce.alternate_identifier || "",
      ce.alternate_text || "",
      ce.name_of_alternate_coding_system || ""
    ]
    |> Type.trim_trailing()
  end
end
