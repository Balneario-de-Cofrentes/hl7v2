defmodule HL7v2.Type.CX do
  @moduledoc """
  Extended Composite ID with Check Digit (CX) -- HL7v2 composite data type.

  Used for MRN, patient IDs, visit numbers, and other identifiers.

  10 components:
  1. ID Number (ST)
  2. Check Digit (ST)
  3. Check Digit Scheme (ID) -- Table 0061
  4. Assigning Authority (HD) -- sub-components delimited by `&`
  5. Identifier Type Code (ID) -- Table 0203: MR, PI, VN, AN, SS, etc.
  6. Assigning Facility (HD) -- sub-components delimited by `&`
  7. Effective Date (DT)
  8. Expiration Date (DT)
  9. Assigning Jurisdiction (CWE) -- sub-components delimited by `&`
  10. Assigning Agency or Department (CWE) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{HD, DT, CWE}

  defstruct [
    :id,
    :check_digit,
    :check_digit_scheme,
    :assigning_authority,
    :identifier_type_code,
    :assigning_facility,
    :effective_date,
    :expiration_date,
    :assigning_jurisdiction,
    :assigning_agency
  ]

  @type t :: %__MODULE__{
          id: binary() | nil,
          check_digit: binary() | nil,
          check_digit_scheme: binary() | nil,
          assigning_authority: HD.t() | nil,
          identifier_type_code: binary() | nil,
          assigning_facility: HD.t() | nil,
          effective_date: Date.t() | DT.t() | nil,
          expiration_date: Date.t() | DT.t() | nil,
          assigning_jurisdiction: CWE.t() | nil,
          assigning_agency: CWE.t() | nil
        }

  @doc """
  Parses a CX from a list of components.

  Components containing sub-components (HD, CWE) are split by `&` and
  parsed into their respective structs.

  ## Examples

      iex> HL7v2.Type.CX.parse(["12345", "", "", "MRN", "MR"])
      %HL7v2.Type.CX{id: "12345", assigning_authority: %HL7v2.Type.HD{namespace_id: "MRN"}, identifier_type_code: "MR"}

      iex> HL7v2.Type.CX.parse(["12345", "", "", "MRN&1.2.3&ISO", "MR"])
      %HL7v2.Type.CX{
        id: "12345",
        assigning_authority: %HL7v2.Type.HD{namespace_id: "MRN", universal_id: "1.2.3", universal_id_type: "ISO"},
        identifier_type_code: "MR"
      }

      iex> HL7v2.Type.CX.parse([])
      %HL7v2.Type.CX{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      id: Type.get_component(components, 0),
      check_digit: Type.get_component(components, 1),
      check_digit_scheme: Type.get_component(components, 2),
      assigning_authority: Type.parse_sub(HD, Type.get_component(components, 3)),
      identifier_type_code: Type.get_component(components, 4),
      assigning_facility: Type.parse_sub(HD, Type.get_component(components, 5)),
      effective_date: components |> Type.get_component(6) |> DT.parse(),
      expiration_date: components |> Type.get_component(7) |> DT.parse(),
      assigning_jurisdiction: Type.parse_sub(CWE, Type.get_component(components, 8)),
      assigning_agency: Type.parse_sub(CWE, Type.get_component(components, 9))
    }
  end

  @doc """
  Encodes a CX to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CX.encode(%HL7v2.Type.CX{id: "12345", assigning_authority: %HL7v2.Type.HD{namespace_id: "MRN"}, identifier_type_code: "MR"})
      ["12345", "", "", "MRN", "MR"]

      iex> HL7v2.Type.CX.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = cx) do
    [
      cx.id || "",
      cx.check_digit || "",
      cx.check_digit_scheme || "",
      Type.encode_sub(HD, cx.assigning_authority),
      cx.identifier_type_code || "",
      Type.encode_sub(HD, cx.assigning_facility),
      DT.encode(cx.effective_date),
      DT.encode(cx.expiration_date),
      Type.encode_sub(CWE, cx.assigning_jurisdiction),
      Type.encode_sub(CWE, cx.assigning_agency)
    ]
    |> Type.trim_trailing()
  end
end
