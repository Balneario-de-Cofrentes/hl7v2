defmodule HL7v2.Type.PPN do
  @moduledoc """
  Performing Person Time Stamp (PPN) -- HL7v2 composite data type.

  Identifies a performing person with a timestamp of the action. Similar to XCN
  but includes a date/time field for when the action was performed.

  24 components per HL7 v2.5.1:
  1. ID Number (ST)
  2. Family Name (FN) -- sub-components
  3. Given Name (ST)
  4. Second and Further Given Names (ST)
  5. Suffix (ST)
  6. Prefix (ST)
  7. Degree (IS)
  8. Source Table (IS)
  9. Assigning Authority (HD) -- sub-components
  10. Name Type Code (ID)
  11. Identifier Check Digit (ST)
  12. Check Digit Scheme (ID)
  13. Identifier Type Code (ID)
  14. Assigning Facility (HD) -- sub-components
  15. Date/Time Action Performed (TS) -- sub-components
  16. Name Representation Code (ID)
  17-24: Additional components (raw)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{FN, HD, TS}

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
    :date_time_action_performed,
    :name_representation_code,
    :raw_17_24
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
          date_time_action_performed: TS.t() | nil,
          name_representation_code: binary() | nil,
          raw_17_24: [binary()] | nil
        }

  @typed_count 16

  @doc """
  Parses a PPN from a list of components.

  The first 16 components are parsed into typed fields. Components 17-24
  are preserved as raw strings.

  ## Examples

      iex> HL7v2.Type.PPN.parse(["12345", "Smith", "John"])
      %HL7v2.Type.PPN{
        id_number: "12345",
        family_name: %HL7v2.Type.FN{surname: "Smith"},
        given_name: "John"
      }

      iex> HL7v2.Type.PPN.parse([])
      %HL7v2.Type.PPN{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    raw_tail = Enum.drop(components, @typed_count)
    raw_values = Enum.map(raw_tail, &Type.get_component([&1], 0))
    raw_17_24 = if Enum.all?(raw_values, &is_nil/1), do: nil, else: raw_values

    %__MODULE__{
      id_number: Type.get_component(components, 0),
      family_name: Type.parse_sub(FN, Type.get_component(components, 1)),
      given_name: Type.get_component(components, 2),
      second_name: Type.get_component(components, 3),
      suffix: Type.get_component(components, 4),
      prefix: Type.get_component(components, 5),
      degree: Type.get_component(components, 6),
      source_table: Type.get_component(components, 7),
      assigning_authority: Type.parse_sub(HD, Type.get_component(components, 8)),
      name_type_code: Type.get_component(components, 9),
      identifier_check_digit: Type.get_component(components, 10),
      check_digit_scheme: Type.get_component(components, 11),
      identifier_type_code: Type.get_component(components, 12),
      assigning_facility: Type.parse_sub(HD, Type.get_component(components, 13)),
      date_time_action_performed: Type.parse_sub_ts(Type.get_component(components, 14)),
      name_representation_code: Type.get_component(components, 15),
      raw_17_24: raw_17_24
    }
  end

  @doc """
  Encodes a PPN to a list of component strings.

  ## Examples

      iex> HL7v2.Type.PPN.encode(%HL7v2.Type.PPN{id_number: "12345", family_name: %HL7v2.Type.FN{surname: "Smith"}, given_name: "John"})
      ["12345", "Smith", "John"]

      iex> HL7v2.Type.PPN.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ppn) do
    typed = [
      ppn.id_number || "",
      Type.encode_sub(FN, ppn.family_name),
      ppn.given_name || "",
      ppn.second_name || "",
      ppn.suffix || "",
      ppn.prefix || "",
      ppn.degree || "",
      ppn.source_table || "",
      Type.encode_sub(HD, ppn.assigning_authority),
      ppn.name_type_code || "",
      ppn.identifier_check_digit || "",
      ppn.check_digit_scheme || "",
      ppn.identifier_type_code || "",
      Type.encode_sub(HD, ppn.assigning_facility),
      Type.encode_sub_ts(ppn.date_time_action_performed),
      ppn.name_representation_code || ""
    ]

    tail = if ppn.raw_17_24, do: Enum.map(ppn.raw_17_24, &(&1 || "")), else: []

    (typed ++ tail)
    |> Type.trim_trailing()
  end
end
