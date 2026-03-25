defmodule HL7v2.Type.QIP do
  @moduledoc """
  Query Input Parameter List (QIP) -- HL7v2 composite data type.

  Used in QPD segment for passing query parameters.

  2 components:
  1. Segment Field Name (ST) -- e.g., "@PID.3.1"
  2. Values (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:segment_field_name, :values]

  @type t :: %__MODULE__{
          segment_field_name: binary() | nil,
          values: binary() | nil
        }

  @doc """
  Parses a QIP from a list of components.

  ## Examples

      iex> HL7v2.Type.QIP.parse(["@PID.3.1", "12345"])
      %HL7v2.Type.QIP{segment_field_name: "@PID.3.1", values: "12345"}

      iex> HL7v2.Type.QIP.parse(["@PID.5.1"])
      %HL7v2.Type.QIP{segment_field_name: "@PID.5.1"}

      iex> HL7v2.Type.QIP.parse([])
      %HL7v2.Type.QIP{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      segment_field_name: Type.get_component(components, 0),
      values: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes a QIP to a list of component strings.

  ## Examples

      iex> HL7v2.Type.QIP.encode(%HL7v2.Type.QIP{segment_field_name: "@PID.3.1", values: "12345"})
      ["@PID.3.1", "12345"]

      iex> HL7v2.Type.QIP.encode(%HL7v2.Type.QIP{segment_field_name: "@PID.5.1"})
      ["@PID.5.1"]

      iex> HL7v2.Type.QIP.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = qip) do
    [
      qip.segment_field_name || "",
      qip.values || ""
    ]
    |> Type.trim_trailing()
  end
end
