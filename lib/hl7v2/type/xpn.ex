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
  alias HL7v2.Type.{FN, CE, DR, TS, DTM}

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
      family_name: parse_sub_fn(Type.get_component(components, 0)),
      given_name: Type.get_component(components, 1),
      second_name: Type.get_component(components, 2),
      suffix: Type.get_component(components, 3),
      prefix: Type.get_component(components, 4),
      degree: Type.get_component(components, 5),
      name_type_code: Type.get_component(components, 6),
      name_representation_code: Type.get_component(components, 7),
      name_context: parse_sub_ce(Type.get_component(components, 8)),
      name_validity_range: parse_sub_dr(Type.get_component(components, 9)),
      name_assembly_order: Type.get_component(components, 10),
      effective_date: parse_sub_ts(Type.get_component(components, 11)),
      expiration_date: parse_sub_ts(Type.get_component(components, 12)),
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
      encode_sub_fn(xpn.family_name),
      xpn.given_name || "",
      xpn.second_name || "",
      xpn.suffix || "",
      xpn.prefix || "",
      xpn.degree || "",
      xpn.name_type_code || "",
      xpn.name_representation_code || "",
      encode_sub_ce(xpn.name_context),
      encode_sub_dr(xpn.name_validity_range),
      xpn.name_assembly_order || "",
      encode_sub_ts(xpn.effective_date),
      encode_sub_ts(xpn.expiration_date),
      xpn.professional_suffix || ""
    ]
    |> Type.trim_trailing()
  end

  # -- Sub-component parsing helpers --

  defp parse_sub_fn(nil), do: nil

  defp parse_sub_fn(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    fn_val = FN.parse(subs)
    if all_nil?(fn_val), do: nil, else: fn_val
  end

  defp encode_sub_fn(nil), do: ""

  defp encode_sub_fn(%FN{} = fn_val),
    do: fn_val |> FN.encode() |> Enum.join(Type.sub_component_separator())

  defp parse_sub_ce(nil), do: nil

  defp parse_sub_ce(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    ce_val = CE.parse(subs)
    if all_nil?(ce_val), do: nil, else: ce_val
  end

  defp encode_sub_ce(nil), do: ""

  defp encode_sub_ce(%CE{} = ce),
    do: ce |> CE.encode() |> Enum.join(Type.sub_component_separator())

  defp parse_sub_dr(nil), do: nil

  defp parse_sub_dr(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    dr_val = DR.parse(subs)
    if all_nil?(dr_val), do: nil, else: dr_val
  end

  defp encode_sub_dr(nil), do: ""

  defp encode_sub_dr(%DR{} = dr),
    do: dr |> DR.encode() |> Enum.join(Type.sub_component_separator())

  defp parse_sub_ts(nil), do: nil

  defp parse_sub_ts(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    ts_val = TS.parse(subs)

    # A TS with no time component is effectively nil
    if ts_val.time == nil and ts_val.degree_of_precision == nil do
      nil
    else
      ts_val
    end
  end

  defp encode_sub_ts(nil), do: ""

  defp encode_sub_ts(%TS{} = ts) do
    case TS.encode(ts) do
      [] -> ""
      parts -> Enum.join(parts, Type.sub_component_separator())
    end
  end

  defp encode_sub_ts(%DTM{} = dtm) do
    HL7v2.Type.DTM.encode(dtm)
  end

  defp all_nil?(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&is_nil/1)
  end
end
