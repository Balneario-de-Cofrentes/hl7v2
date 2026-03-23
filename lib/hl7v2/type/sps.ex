defmodule HL7v2.Type.SPS do
  @moduledoc """
  Specimen Source (SPS) -- HL7v2 composite data type.

  Deprecated in v2.5.1 (replaced by SPM segment), but retained for backward
  compatibility with OBR-15 which uses this type.

  7 components:
  1. Specimen Source Name or Code (CWE) -- sub-components delimited by `&`
  2. Additives (CWE) -- sub-components delimited by `&`
  3. Specimen Collection Method (TX)
  4. Body Site (CWE) -- sub-components delimited by `&`
  5. Site Modifier (CWE) -- sub-components delimited by `&`
  6. Collection Method Modifier Code (CWE) -- sub-components delimited by `&`
  7. Specimen Role (CWE) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.CWE

  defstruct [
    :specimen_source_name_or_code,
    :additives,
    :specimen_collection_method,
    :body_site,
    :site_modifier,
    :collection_method_modifier_code,
    :specimen_role
  ]

  @type t :: %__MODULE__{
          specimen_source_name_or_code: CWE.t() | nil,
          additives: CWE.t() | nil,
          specimen_collection_method: binary() | nil,
          body_site: CWE.t() | nil,
          site_modifier: CWE.t() | nil,
          collection_method_modifier_code: CWE.t() | nil,
          specimen_role: CWE.t() | nil
        }

  @doc """
  Parses an SPS from a list of components.

  ## Examples

      iex> HL7v2.Type.SPS.parse(["BLD&Blood&HL70070", "", "Venipuncture"])
      %HL7v2.Type.SPS{
        specimen_source_name_or_code: %HL7v2.Type.CWE{identifier: "BLD", text: "Blood", name_of_coding_system: "HL70070"},
        specimen_collection_method: "Venipuncture"
      }

      iex> HL7v2.Type.SPS.parse([])
      %HL7v2.Type.SPS{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      specimen_source_name_or_code: Type.parse_sub(CWE, Type.get_component(components, 0)),
      additives: Type.parse_sub(CWE, Type.get_component(components, 1)),
      specimen_collection_method: Type.get_component(components, 2),
      body_site: Type.parse_sub(CWE, Type.get_component(components, 3)),
      site_modifier: Type.parse_sub(CWE, Type.get_component(components, 4)),
      collection_method_modifier_code: Type.parse_sub(CWE, Type.get_component(components, 5)),
      specimen_role: Type.parse_sub(CWE, Type.get_component(components, 6))
    }
  end

  @doc """
  Encodes an SPS to a list of component strings.

  ## Examples

      iex> HL7v2.Type.SPS.encode(%HL7v2.Type.SPS{specimen_source_name_or_code: %HL7v2.Type.CWE{identifier: "BLD", text: "Blood"}, specimen_collection_method: "Venipuncture"})
      ["BLD&Blood", "", "Venipuncture"]

      iex> HL7v2.Type.SPS.encode(nil)
      []

      iex> HL7v2.Type.SPS.encode(%HL7v2.Type.SPS{})
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = sps) do
    [
      Type.encode_sub(CWE, sps.specimen_source_name_or_code),
      Type.encode_sub(CWE, sps.additives),
      sps.specimen_collection_method || "",
      Type.encode_sub(CWE, sps.body_site),
      Type.encode_sub(CWE, sps.site_modifier),
      Type.encode_sub(CWE, sps.collection_method_modifier_code),
      Type.encode_sub(CWE, sps.specimen_role)
    ]
    |> Type.trim_trailing()
  end
end
