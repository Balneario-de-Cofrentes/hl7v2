defmodule HL7v2.Type.HD do
  @moduledoc """
  Hierarchic Designator (HD) -- HL7v2 composite data type.

  Used to identify sending/receiving applications, facilities, and assigning
  authorities. Appears as a top-level component and as a sub-component inside
  CX, EI, PL, and XON.

  3 components:
  1. Namespace ID (IS)
  2. Universal ID (ST)
  3. Universal ID Type (ID) -- DNS, GUID, ISO, UUID, etc.

  When HD appears inside another composite (e.g., CX.4), its internal parts
  are encoded as sub-components using `&`.
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:namespace_id, :universal_id, :universal_id_type]

  @type t :: %__MODULE__{
          namespace_id: binary() | nil,
          universal_id: binary() | nil,
          universal_id_type: binary() | nil
        }

  @doc """
  Parses an HD from a list of components (or sub-components).

  ## Examples

      iex> HL7v2.Type.HD.parse(["HOSP", "2.16.840.1.113883.19.4.6", "ISO"])
      %HL7v2.Type.HD{namespace_id: "HOSP", universal_id: "2.16.840.1.113883.19.4.6", universal_id_type: "ISO"}

      iex> HL7v2.Type.HD.parse(["MRN"])
      %HL7v2.Type.HD{namespace_id: "MRN"}

      iex> HL7v2.Type.HD.parse([])
      %HL7v2.Type.HD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      namespace_id: Type.get_component(components, 0),
      universal_id: Type.get_component(components, 1),
      universal_id_type: Type.get_component(components, 2)
    }
  end

  @doc """
  Encodes an HD to a list of component/sub-component strings.

  ## Examples

      iex> HL7v2.Type.HD.encode(%HL7v2.Type.HD{namespace_id: "HOSP", universal_id: "2.16.840.1.113883.19.4.6", universal_id_type: "ISO"})
      ["HOSP", "2.16.840.1.113883.19.4.6", "ISO"]

      iex> HL7v2.Type.HD.encode(%HL7v2.Type.HD{namespace_id: "MRN"})
      ["MRN"]

      iex> HL7v2.Type.HD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = hd_type) do
    [
      hd_type.namespace_id || "",
      hd_type.universal_id || "",
      hd_type.universal_id_type || ""
    ]
    |> Type.trim_trailing()
  end
end
