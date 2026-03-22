defmodule HL7v2.Type.XCN do
  @moduledoc """
  Extended Composite ID Number and Name for Persons (XCN) -- HL7v2 composite data type.

  Used for attending doctors, ordering providers, entered-by persons, and other
  person identifiers that carry both an ID and a name.

  23 components per HL7 v2.5.1:
  1. ID Number (ST)
  2. Family Name (FN) -- sub-components delimited by `&`
  3. Given Name (ST)
  4. Second and Further Given Names (ST)
  5. Suffix (ST)
  6. Prefix (ST)
  7. Degree (IS) -- deprecated
  8. Source Table (IS)
  9. Assigning Authority (HD) -- sub-components delimited by `&`
  10. Name Type Code (ID)
  11. Identifier Check Digit (ST)
  12. Check Digit Scheme (ID)
  13. Identifier Type Code (ID)
  14. Assigning Facility (HD) -- sub-components delimited by `&`
  15. Name Representation Code (ID)
  16. Name Context (CE) -- sub-components delimited by `&`
  17. Name Validity Range (DR) -- deprecated, sub-components delimited by `&`
  18. Name Assembly Order (ID)
  19. Effective Date (TS) -- sub-components delimited by `&`
  20. Expiration Date (TS) -- sub-components delimited by `&`
  21. Professional Suffix (ST)
  22. Assigning Jurisdiction (CWE) -- sub-components delimited by `&`
  23. Assigning Agency or Department (CWE) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{FN, HD, CE, CWE, DR, TS, DTM}

  defstruct [
    :id_number,
    :family_name,
    :given_name,
    :second_name,
    :suffix,
    :prefix,
    :degree,
    :source_table,
    :assigning_authority,
    :name_type_code,
    :identifier_check_digit,
    :check_digit_scheme,
    :identifier_type_code,
    :assigning_facility,
    :name_representation_code,
    :name_context,
    :name_validity_range,
    :name_assembly_order,
    :effective_date,
    :expiration_date,
    :professional_suffix,
    :assigning_jurisdiction,
    :assigning_agency
  ]

  @type t :: %__MODULE__{
          id_number: binary() | nil,
          family_name: FN.t() | nil,
          given_name: binary() | nil,
          second_name: binary() | nil,
          suffix: binary() | nil,
          prefix: binary() | nil,
          degree: binary() | nil,
          source_table: binary() | nil,
          assigning_authority: HD.t() | nil,
          name_type_code: binary() | nil,
          identifier_check_digit: binary() | nil,
          check_digit_scheme: binary() | nil,
          identifier_type_code: binary() | nil,
          assigning_facility: HD.t() | nil,
          name_representation_code: binary() | nil,
          name_context: CE.t() | nil,
          name_validity_range: DR.t() | nil,
          name_assembly_order: binary() | nil,
          effective_date: TS.t() | nil,
          expiration_date: TS.t() | nil,
          professional_suffix: binary() | nil,
          assigning_jurisdiction: CWE.t() | nil,
          assigning_agency: CWE.t() | nil
        }

  @doc """
  Parses an XCN from a list of components.

  Component 2 (Family Name) contains sub-components delimited by `&`.
  Components 9, 14 (HD), 16 (CE), 17 (DR), 19-20 (TS), 22-23 (CWE)
  also contain sub-components delimited by `&`.

  ## Examples

      iex> HL7v2.Type.XCN.parse(["12345", "Smith", "John", "Q", "JR", "DR"])
      %HL7v2.Type.XCN{
        id_number: "12345",
        family_name: %HL7v2.Type.FN{surname: "Smith"},
        given_name: "John",
        second_name: "Q",
        suffix: "JR",
        prefix: "DR"
      }

      iex> HL7v2.Type.XCN.parse(["12345", "Smith", "John", "", "", "", "", "", "MRN&1.2.3&ISO", "", "", "", "NPI"])
      %HL7v2.Type.XCN{
        id_number: "12345",
        family_name: %HL7v2.Type.FN{surname: "Smith"},
        given_name: "John",
        assigning_authority: %HL7v2.Type.HD{namespace_id: "MRN", universal_id: "1.2.3", universal_id_type: "ISO"},
        identifier_type_code: "NPI"
      }

      iex> HL7v2.Type.XCN.parse([])
      %HL7v2.Type.XCN{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      id_number: Type.get_component(components, 0),
      family_name: parse_sub_fn(Type.get_component(components, 1)),
      given_name: Type.get_component(components, 2),
      second_name: Type.get_component(components, 3),
      suffix: Type.get_component(components, 4),
      prefix: Type.get_component(components, 5),
      degree: Type.get_component(components, 6),
      source_table: Type.get_component(components, 7),
      assigning_authority: parse_sub_hd(Type.get_component(components, 8)),
      name_type_code: Type.get_component(components, 9),
      identifier_check_digit: Type.get_component(components, 10),
      check_digit_scheme: Type.get_component(components, 11),
      identifier_type_code: Type.get_component(components, 12),
      assigning_facility: parse_sub_hd(Type.get_component(components, 13)),
      name_representation_code: Type.get_component(components, 14),
      name_context: parse_sub_ce(Type.get_component(components, 15)),
      name_validity_range: parse_sub_dr(Type.get_component(components, 16)),
      name_assembly_order: Type.get_component(components, 17),
      effective_date: parse_sub_ts(Type.get_component(components, 18)),
      expiration_date: parse_sub_ts(Type.get_component(components, 19)),
      professional_suffix: Type.get_component(components, 20),
      assigning_jurisdiction: parse_sub_cwe(Type.get_component(components, 21)),
      assigning_agency: parse_sub_cwe(Type.get_component(components, 22))
    }
  end

  @doc """
  Encodes an XCN to a list of component strings.

  ## Examples

      iex> HL7v2.Type.XCN.encode(%HL7v2.Type.XCN{id_number: "12345", family_name: %HL7v2.Type.FN{surname: "Smith"}, given_name: "John"})
      ["12345", "Smith", "John"]

      iex> HL7v2.Type.XCN.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = xcn) do
    [
      xcn.id_number || "",
      encode_sub_fn(xcn.family_name),
      xcn.given_name || "",
      xcn.second_name || "",
      xcn.suffix || "",
      xcn.prefix || "",
      xcn.degree || "",
      xcn.source_table || "",
      encode_sub_hd(xcn.assigning_authority),
      xcn.name_type_code || "",
      xcn.identifier_check_digit || "",
      xcn.check_digit_scheme || "",
      xcn.identifier_type_code || "",
      encode_sub_hd(xcn.assigning_facility),
      xcn.name_representation_code || "",
      encode_sub_ce(xcn.name_context),
      encode_sub_dr(xcn.name_validity_range),
      xcn.name_assembly_order || "",
      encode_sub_ts(xcn.effective_date),
      encode_sub_ts(xcn.expiration_date),
      xcn.professional_suffix || "",
      encode_sub_cwe(xcn.assigning_jurisdiction),
      encode_sub_cwe(xcn.assigning_agency)
    ]
    |> Type.trim_trailing()
  end

  # -- Sub-component parsing helpers --

  defp parse_sub_fn(nil), do: nil

  defp parse_sub_fn(value) when is_binary(value) do
    subs = String.split(value, "&")
    fn_val = FN.parse(subs)
    if all_nil?(fn_val), do: nil, else: fn_val
  end

  defp encode_sub_fn(nil), do: ""
  defp encode_sub_fn(%FN{} = fn_val), do: fn_val |> FN.encode() |> Enum.join("&")

  defp parse_sub_hd(nil), do: nil

  defp parse_sub_hd(value) when is_binary(value) do
    subs = String.split(value, "&")
    hd_val = HD.parse(subs)
    if all_nil?(hd_val), do: nil, else: hd_val
  end

  defp encode_sub_hd(nil), do: ""
  defp encode_sub_hd(%HD{} = hd_val), do: hd_val |> HD.encode() |> Enum.join("&")

  defp parse_sub_ce(nil), do: nil

  defp parse_sub_ce(value) when is_binary(value) do
    subs = String.split(value, "&")
    ce_val = CE.parse(subs)
    if all_nil?(ce_val), do: nil, else: ce_val
  end

  defp encode_sub_ce(nil), do: ""
  defp encode_sub_ce(%CE{} = ce), do: ce |> CE.encode() |> Enum.join("&")

  defp parse_sub_cwe(nil), do: nil

  defp parse_sub_cwe(value) when is_binary(value) do
    subs = String.split(value, "&")
    cwe_val = CWE.parse(subs)
    if all_nil?(cwe_val), do: nil, else: cwe_val
  end

  defp encode_sub_cwe(nil), do: ""
  defp encode_sub_cwe(%CWE{} = cwe), do: cwe |> CWE.encode() |> Enum.join("&")

  defp parse_sub_dr(nil), do: nil

  defp parse_sub_dr(value) when is_binary(value) do
    subs = String.split(value, "&")
    dr_val = DR.parse(subs)
    if all_nil?(dr_val), do: nil, else: dr_val
  end

  defp encode_sub_dr(nil), do: ""
  defp encode_sub_dr(%DR{} = dr), do: dr |> DR.encode() |> Enum.join("&")

  defp parse_sub_ts(nil), do: nil

  defp parse_sub_ts(value) when is_binary(value) do
    subs = String.split(value, "&")
    ts_val = TS.parse(subs)

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
      parts -> Enum.join(parts, "&")
    end
  end

  defp encode_sub_ts(%DTM{} = dtm) do
    DTM.encode(dtm)
  end

  defp all_nil?(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&is_nil/1)
  end
end
