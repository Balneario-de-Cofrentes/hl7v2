defmodule HL7v2.Type.PIP do
  @moduledoc """
  Practitioner Institutional Privileges (PIP) -- HL7v2 composite data type.

  Defines institutional privileges granted to a practitioner.

  5 components:
  1. Privilege (CE) -- sub-components
  2. Privilege Class (CE) -- sub-components
  3. Expiration Date (DT)
  4. Activation Date (DT)
  5. Facility (EI) -- sub-components
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{CE, DT, EI}

  defstruct [:privilege, :privilege_class, :expiration_date, :activation_date, :facility]

  @type t :: %__MODULE__{
          privilege: CE.t() | nil,
          privilege_class: CE.t() | nil,
          expiration_date: Date.t() | DT.t() | nil,
          activation_date: Date.t() | DT.t() | nil,
          facility: EI.t() | nil
        }

  @doc """
  Parses a PIP from a list of components.

  ## Examples

      iex> HL7v2.Type.PIP.parse(["SURG&Surgery&LOCAL", "A&Active", "20281231", "20260101"])
      %HL7v2.Type.PIP{
        privilege: %HL7v2.Type.CE{identifier: "SURG", text: "Surgery", name_of_coding_system: "LOCAL"},
        privilege_class: %HL7v2.Type.CE{identifier: "A", text: "Active"},
        expiration_date: ~D[2028-12-31],
        activation_date: ~D[2026-01-01]
      }

      iex> HL7v2.Type.PIP.parse([])
      %HL7v2.Type.PIP{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      privilege: Type.parse_sub(CE, Type.get_component(components, 0)),
      privilege_class: Type.parse_sub(CE, Type.get_component(components, 1)),
      expiration_date: components |> Type.get_component(2) |> DT.parse(),
      activation_date: components |> Type.get_component(3) |> DT.parse(),
      facility: Type.parse_sub(EI, Type.get_component(components, 4))
    }
  end

  @doc """
  Encodes a PIP to a list of component strings.

  ## Examples

      iex> HL7v2.Type.PIP.encode(%HL7v2.Type.PIP{privilege: %HL7v2.Type.CE{identifier: "SURG"}, expiration_date: ~D[2028-12-31]})
      ["SURG", "", "20281231"]

      iex> HL7v2.Type.PIP.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = pip) do
    [
      Type.encode_sub(CE, pip.privilege),
      Type.encode_sub(CE, pip.privilege_class),
      DT.encode(pip.expiration_date),
      DT.encode(pip.activation_date),
      Type.encode_sub(EI, pip.facility)
    ]
    |> Type.trim_trailing()
  end
end
