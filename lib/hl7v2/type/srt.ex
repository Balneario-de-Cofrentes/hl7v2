defmodule HL7v2.Type.SRT do
  @moduledoc """
  Sort Order (SRT) -- HL7v2 composite data type.

  Used in query definitions to specify result sorting.

  2 components:
  1. Sort-by Field (ST) -- segment field name, e.g., "PID.3"
  2. Sequencing (ID) -- A (ascending), D (descending), N (none)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:sort_by_field, :sequencing]

  @type t :: %__MODULE__{
          sort_by_field: binary() | nil,
          sequencing: binary() | nil
        }

  @doc """
  Parses a SRT from a list of components.

  ## Examples

      iex> HL7v2.Type.SRT.parse(["PID.3", "A"])
      %HL7v2.Type.SRT{sort_by_field: "PID.3", sequencing: "A"}

      iex> HL7v2.Type.SRT.parse(["OBR.4"])
      %HL7v2.Type.SRT{sort_by_field: "OBR.4"}

      iex> HL7v2.Type.SRT.parse([])
      %HL7v2.Type.SRT{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      sort_by_field: Type.get_component(components, 0),
      sequencing: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes a SRT to a list of component strings.

  ## Examples

      iex> HL7v2.Type.SRT.encode(%HL7v2.Type.SRT{sort_by_field: "PID.3", sequencing: "A"})
      ["PID.3", "A"]

      iex> HL7v2.Type.SRT.encode(%HL7v2.Type.SRT{sort_by_field: "OBR.4"})
      ["OBR.4"]

      iex> HL7v2.Type.SRT.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = srt) do
    [
      srt.sort_by_field || "",
      srt.sequencing || ""
    ]
    |> Type.trim_trailing()
  end
end
