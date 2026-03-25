defmodule HL7v2.Type.DLT do
  @moduledoc """
  Delta (DLT) -- HL7v2 composite data type.

  Specifies delta check parameters for observation values.

  4 components:
  1. Normal Range (NR) -- sub-components (low & high)
  2. Numeric Threshold (NM)
  3. Change Computation (ID) -- percent, absolute
  4. Days Retained (NM)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.NR

  defstruct [:normal_range, :numeric_threshold, :change_computation, :days_retained]

  @type t :: %__MODULE__{
          normal_range: NR.t() | nil,
          numeric_threshold: binary() | nil,
          change_computation: binary() | nil,
          days_retained: binary() | nil
        }

  @doc """
  Parses a DLT from a list of components.

  ## Examples

      iex> HL7v2.Type.DLT.parse(["2.5&10.0", "5", "P", "7"])
      %HL7v2.Type.DLT{
        normal_range: %HL7v2.Type.NR{
          low: %HL7v2.Type.NM{value: "2.5", original: "2.5"},
          high: %HL7v2.Type.NM{value: "10", original: "10.0"}
        },
        numeric_threshold: "5",
        change_computation: "P",
        days_retained: "7"
      }

      iex> HL7v2.Type.DLT.parse([])
      %HL7v2.Type.DLT{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      normal_range: Type.parse_sub(NR, Type.get_component(components, 0)),
      numeric_threshold: Type.get_component(components, 1),
      change_computation: Type.get_component(components, 2),
      days_retained: Type.get_component(components, 3)
    }
  end

  @doc """
  Encodes a DLT to a list of component strings.

  ## Examples

      iex> HL7v2.Type.DLT.encode(%HL7v2.Type.DLT{numeric_threshold: "5", change_computation: "P"})
      ["", "5", "P"]

      iex> HL7v2.Type.DLT.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = dlt) do
    [
      Type.encode_sub(NR, dlt.normal_range),
      dlt.numeric_threshold || "",
      dlt.change_computation || "",
      dlt.days_retained || ""
    ]
    |> Type.trim_trailing()
  end
end
