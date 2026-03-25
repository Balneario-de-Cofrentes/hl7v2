defmodule HL7v2.Type.VR do
  @moduledoc """
  Value Range (VR) -- HL7v2 composite data type.

  Specifies a range of values for a field. Used as a query parameter.

  2 components:
  1. First Data Code Value (ST)
  2. Last Data Code Value (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:first_data_code_value, :last_data_code_value]

  @type t :: %__MODULE__{
          first_data_code_value: binary() | nil,
          last_data_code_value: binary() | nil
        }

  @doc """
  Parses a VR from a list of components.

  ## Examples

      iex> HL7v2.Type.VR.parse(["A", "Z"])
      %HL7v2.Type.VR{first_data_code_value: "A", last_data_code_value: "Z"}

      iex> HL7v2.Type.VR.parse(["100"])
      %HL7v2.Type.VR{first_data_code_value: "100"}

      iex> HL7v2.Type.VR.parse([])
      %HL7v2.Type.VR{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      first_data_code_value: Type.get_component(components, 0),
      last_data_code_value: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes a VR to a list of component strings.

  ## Examples

      iex> HL7v2.Type.VR.encode(%HL7v2.Type.VR{first_data_code_value: "A", last_data_code_value: "Z"})
      ["A", "Z"]

      iex> HL7v2.Type.VR.encode(%HL7v2.Type.VR{first_data_code_value: "100"})
      ["100"]

      iex> HL7v2.Type.VR.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = vr) do
    [
      vr.first_data_code_value || "",
      vr.last_data_code_value || ""
    ]
    |> Type.trim_trailing()
  end
end
