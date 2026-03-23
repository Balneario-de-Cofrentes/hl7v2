defmodule HL7v2.Type.XPN do
  @moduledoc """
  Extended Person Name (XPN) -- HL7v2 composite data type.

  Used for patient names, provider names, next of kin, etc.

  14 components:
  1. Family Name (FN) -- sub-components delimited by `&`
  2. Given Name (ST)
  3. Second and Further Given Names or Initials (ST)
  4. Suffix (ST) -- e.g., JR, III
  5. Prefix (ST) -- e.g., DR
  6. Degree (IS) -- deprecated, Table 0360
  7. Name Type Code (ID) -- Table 0200: L=Legal, D=Display, A=Alias, etc.
  8. Name Representation Code (ID) -- Table 0465: A=Alphabetic, I=Ideographic, P=Phonetic
  9. Name Context (CE) -- sub-components delimited by `&`, Table 0448
  10. Name Validity Range (DR) -- deprecated, sub-components delimited by `&`
  11. Name Assembly Order (ID) -- Table 0444: G=Given-first, F=Family-first
  12. Effective Date (TS) -- sub-components delimited by `&`
  13. Expiration Date (TS) -- sub-components delimited by `&`
  14. Professional Suffix (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{FN, CE, DR, TS}

  defstruct [
    :family_name,
    :given_name,
    :second_name,
    :suffix,
    :prefix,
    :degree,
    :name_type_code,
    :name_representation_code,
    :name_context,
    :name_validity_range,
    :name_assembly_order,
    :effective_date,
    :expiration_date,
    :professional_suffix
  ]

  @type t :: %__MODULE__{
          family_name: FN.t() | nil,
          given_name: binary() | nil,
          second_name: binary() | nil,
          suffix: binary() | nil,
          prefix: binary() | nil,
          degree: binary() | nil,
          name_type_code: binary() | nil,
          name_representation_code: binary() | nil,
          name_context: CE.t() | nil,
          name_validity_range: DR.t() | nil,
          name_assembly_order: binary() | nil,
          effective_date: TS.t() | nil,
          expiration_date: TS.t() | nil,
          professional_suffix: binary() | nil
        }

  @doc """
  Parses an XPN from a list of components.

  Component 1 (Family Name) contains sub-components delimited by `&`.

  ## Examples

      iex> HL7v2.Type.XPN.parse(["Smith", "John", "Q", "JR", "DR", "", "L"])
      %HL7v2.Type.XPN{
        family_name: %HL7v2.Type.FN{surname: "Smith"},
        given_name: "John",
        second_name: "Q",
        suffix: "JR",
        prefix: "DR",
        name_type_code: "L"
      }

      iex> HL7v2.Type.XPN.parse(["Smith&Van", "John"])
      %HL7v2.Type.XPN{
        family_name: %HL7v2.Type.FN{surname: "Smith", own_surname_prefix: "Van"},
        given_name: "John"
      }

      iex> HL7v2.Type.XPN.parse([])
      %HL7v2.Type.XPN{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      family_name: Type.parse_sub(FN, Type.get_component(components, 0)),
      given_name: Type.get_component(components, 1),
      second_name: Type.get_component(components, 2),
      suffix: Type.get_component(components, 3),
      prefix: Type.get_component(components, 4),
      degree: Type.get_component(components, 5),
      name_type_code: Type.get_component(components, 6),
      name_representation_code: Type.get_component(components, 7),
      name_context: Type.parse_sub(CE, Type.get_component(components, 8)),
      name_validity_range: Type.parse_sub(DR, Type.get_component(components, 9)),
      name_assembly_order: Type.get_component(components, 10),
      effective_date: Type.parse_sub_ts(Type.get_component(components, 11)),
      expiration_date: Type.parse_sub_ts(Type.get_component(components, 12)),
      professional_suffix: Type.get_component(components, 13)
    }
  end

  @doc """
  Encodes an XPN to a list of component strings.

  ## Examples

      iex> HL7v2.Type.XPN.encode(%HL7v2.Type.XPN{family_name: %HL7v2.Type.FN{surname: "Smith"}, given_name: "John"})
      ["Smith", "John"]

      iex> HL7v2.Type.XPN.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = xpn) do
    [
      Type.encode_sub(FN, xpn.family_name),
      xpn.given_name || "",
      xpn.second_name || "",
      xpn.suffix || "",
      xpn.prefix || "",
      xpn.degree || "",
      xpn.name_type_code || "",
      xpn.name_representation_code || "",
      Type.encode_sub(CE, xpn.name_context),
      Type.encode_sub(DR, xpn.name_validity_range),
      xpn.name_assembly_order || "",
      Type.encode_sub_ts(xpn.effective_date),
      Type.encode_sub_ts(xpn.expiration_date),
      xpn.professional_suffix || ""
    ]
    |> Type.trim_trailing()
  end
end
