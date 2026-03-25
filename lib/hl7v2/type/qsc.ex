defmodule HL7v2.Type.QSC do
  @moduledoc """
  Query Selection Criteria (QSC) -- HL7v2 composite data type.

  Used in QRD for specifying selection criteria in queries.

  4 components:
  1. Segment Field Name (ST) -- e.g., "@PID.3"
  2. Relational Operator (ID) -- EQ, NE, GT, LT, GE, LE, CT, GN
  3. Value (ST)
  4. Relational Conjunction (ID) -- AND, OR
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:segment_field_name, :relational_operator, :value, :relational_conjunction]

  @type t :: %__MODULE__{
          segment_field_name: binary() | nil,
          relational_operator: binary() | nil,
          value: binary() | nil,
          relational_conjunction: binary() | nil
        }

  @doc """
  Parses a QSC from a list of components.

  ## Examples

      iex> HL7v2.Type.QSC.parse(["@PID.3", "EQ", "12345", "AND"])
      %HL7v2.Type.QSC{segment_field_name: "@PID.3", relational_operator: "EQ", value: "12345", relational_conjunction: "AND"}

      iex> HL7v2.Type.QSC.parse(["@PID.5.1", "CT", "Smith"])
      %HL7v2.Type.QSC{segment_field_name: "@PID.5.1", relational_operator: "CT", value: "Smith"}

      iex> HL7v2.Type.QSC.parse([])
      %HL7v2.Type.QSC{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      segment_field_name: Type.get_component(components, 0),
      relational_operator: Type.get_component(components, 1),
      value: Type.get_component(components, 2),
      relational_conjunction: Type.get_component(components, 3)
    }
  end

  @doc """
  Encodes a QSC to a list of component strings.

  ## Examples

      iex> HL7v2.Type.QSC.encode(%HL7v2.Type.QSC{segment_field_name: "@PID.3", relational_operator: "EQ", value: "12345"})
      ["@PID.3", "EQ", "12345"]

      iex> HL7v2.Type.QSC.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = qsc) do
    [
      qsc.segment_field_name || "",
      qsc.relational_operator || "",
      qsc.value || "",
      qsc.relational_conjunction || ""
    ]
    |> Type.trim_trailing()
  end
end
