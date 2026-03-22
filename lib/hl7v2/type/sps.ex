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
      specimen_source_name_or_code: parse_sub_cwe(Type.get_component(components, 0)),
      additives: parse_sub_cwe(Type.get_component(components, 1)),
      specimen_collection_method: Type.get_component(components, 2),
      body_site: parse_sub_cwe(Type.get_component(components, 3)),
      site_modifier: parse_sub_cwe(Type.get_component(components, 4)),
      collection_method_modifier_code: parse_sub_cwe(Type.get_component(components, 5)),
      specimen_role: parse_sub_cwe(Type.get_component(components, 6))
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
      encode_sub_cwe(sps.specimen_source_name_or_code),
      encode_sub_cwe(sps.additives),
      sps.specimen_collection_method || "",
      encode_sub_cwe(sps.body_site),
      encode_sub_cwe(sps.site_modifier),
      encode_sub_cwe(sps.collection_method_modifier_code),
      encode_sub_cwe(sps.specimen_role)
    ]
    |> Type.trim_trailing()
  end

  defp parse_sub_cwe(nil), do: nil

  defp parse_sub_cwe(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    cwe_val = CWE.parse(subs)
    if all_nil?(cwe_val), do: nil, else: cwe_val
  end

  defp encode_sub_cwe(nil), do: ""

  defp encode_sub_cwe(%CWE{} = cwe) do
    cwe |> CWE.encode() |> Enum.join(Type.sub_component_separator())
  end

  defp all_nil?(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&is_nil/1)
  end
end
