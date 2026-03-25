defmodule HL7v2.Type.SCV do
  @moduledoc """
  Scheduling Class Value Pair (SCV) -- HL7v2 composite data type.

  Associates a scheduling parameter class with its value. Used in APR segment.

  2 components:
  1. Parameter Class (CWE) -- sub-components, Table 0294
  2. Parameter Value (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.CWE

  defstruct [:parameter_class, :parameter_value]

  @type t :: %__MODULE__{
          parameter_class: CWE.t() | nil,
          parameter_value: binary() | nil
        }

  @doc """
  Parses an SCV from a list of components.

  ## Examples

      iex> HL7v2.Type.SCV.parse(["PREFDAY&Preferred Day&HL70294", "MON"])
      %HL7v2.Type.SCV{
        parameter_class: %HL7v2.Type.CWE{identifier: "PREFDAY", text: "Preferred Day", name_of_coding_system: "HL70294"},
        parameter_value: "MON"
      }

      iex> HL7v2.Type.SCV.parse([])
      %HL7v2.Type.SCV{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      parameter_class: Type.parse_sub(CWE, Type.get_component(components, 0)),
      parameter_value: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes an SCV to a list of component strings.

  ## Examples

      iex> HL7v2.Type.SCV.encode(%HL7v2.Type.SCV{parameter_class: %HL7v2.Type.CWE{identifier: "PREFDAY"}, parameter_value: "MON"})
      ["PREFDAY", "MON"]

      iex> HL7v2.Type.SCV.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = scv) do
    [
      Type.encode_sub(CWE, scv.parameter_class),
      scv.parameter_value || ""
    ]
    |> Type.trim_trailing()
  end
end
