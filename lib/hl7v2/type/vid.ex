defmodule HL7v2.Type.VID do
  @moduledoc """
  Version Identifier (VID) -- HL7v2 composite data type.

  Used in MSH-12 to identify the HL7 version.

  3 components:
  1. Version ID (ID) -- Table 0104: 2.5, 2.5.1, etc.
  2. Internationalization Code (CE)
  3. International Version ID (CE)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.CE

  defstruct [:version_id, :internationalization_code, :international_version_id]

  @type t :: %__MODULE__{
          version_id: binary() | nil,
          internationalization_code: CE.t() | nil,
          international_version_id: CE.t() | nil
        }

  @doc """
  Parses a VID from a list of components.

  Components 2 and 3 are CE types, which when embedded use `&` sub-components.

  ## Examples

      iex> HL7v2.Type.VID.parse(["2.5.1"])
      %HL7v2.Type.VID{version_id: "2.5.1"}

      iex> HL7v2.Type.VID.parse([])
      %HL7v2.Type.VID{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      version_id: Type.get_component(components, 0),
      internationalization_code: parse_sub_ce(Type.get_component(components, 1)),
      international_version_id: parse_sub_ce(Type.get_component(components, 2))
    }
  end

  @doc """
  Encodes a VID to a list of component strings.

  ## Examples

      iex> HL7v2.Type.VID.encode(%HL7v2.Type.VID{version_id: "2.5.1"})
      ["2.5.1"]

      iex> HL7v2.Type.VID.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = vid) do
    [
      vid.version_id || "",
      Type.encode_sub(CE, vid.internationalization_code),
      Type.encode_sub(CE, vid.international_version_id)
    ]
    |> Type.trim_trailing()
  end

  defp parse_sub_ce(nil), do: nil

  defp parse_sub_ce(value) when is_binary(value) do
    value
    |> String.split(Type.sub_component_separator(), parts: 6)
    |> CE.parse()
  end

end
