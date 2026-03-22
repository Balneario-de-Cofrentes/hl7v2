defmodule HL7v2.Type.PT do
  @moduledoc """
  Processing Type (PT) -- HL7v2 composite data type.

  Used in MSH-11 to indicate processing mode.

  2 components:
  1. Processing ID (ID) -- Table 0103: D (Debugging), P (Production), T (Training)
  2. Processing Mode (ID) -- Table 0207: A (Archive), R (Restore), I (Initial), T (Current)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:processing_id, :processing_mode]

  @type t :: %__MODULE__{
          processing_id: binary() | nil,
          processing_mode: binary() | nil
        }

  @doc """
  Parses a PT from a list of components.

  ## Examples

      iex> HL7v2.Type.PT.parse(["P"])
      %HL7v2.Type.PT{processing_id: "P"}

      iex> HL7v2.Type.PT.parse(["P", "T"])
      %HL7v2.Type.PT{processing_id: "P", processing_mode: "T"}

      iex> HL7v2.Type.PT.parse([])
      %HL7v2.Type.PT{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      processing_id: Type.get_component(components, 0),
      processing_mode: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes a PT to a list of component strings.

  ## Examples

      iex> HL7v2.Type.PT.encode(%HL7v2.Type.PT{processing_id: "P"})
      ["P"]

      iex> HL7v2.Type.PT.encode(%HL7v2.Type.PT{processing_id: "P", processing_mode: "T"})
      ["P", "T"]

      iex> HL7v2.Type.PT.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = pt) do
    [
      pt.processing_id || "",
      pt.processing_mode || ""
    ]
    |> Type.trim_trailing()
  end
end
