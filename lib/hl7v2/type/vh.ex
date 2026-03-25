defmodule HL7v2.Type.VH do
  @moduledoc """
  Visiting Hours (VH) -- HL7v2 composite data type.

  Specifies visiting hours for a location.

  4 components:
  1. Start Day Range (ID) -- Table 0267: SAT, SUN, MON, TUE, WED, THU, FRI
  2. End Day Range (ID) -- Table 0267
  3. Start Hour Range (TM) -- HHMM
  4. End Hour Range (TM) -- HHMM
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:start_day_range, :end_day_range, :start_hour_range, :end_hour_range]

  @type t :: %__MODULE__{
          start_day_range: binary() | nil,
          end_day_range: binary() | nil,
          start_hour_range: binary() | nil,
          end_hour_range: binary() | nil
        }

  @doc """
  Parses a VH from a list of components.

  ## Examples

      iex> HL7v2.Type.VH.parse(["MON", "FRI", "0800", "1700"])
      %HL7v2.Type.VH{start_day_range: "MON", end_day_range: "FRI", start_hour_range: "0800", end_hour_range: "1700"}

      iex> HL7v2.Type.VH.parse(["SAT", "SUN"])
      %HL7v2.Type.VH{start_day_range: "SAT", end_day_range: "SUN"}

      iex> HL7v2.Type.VH.parse([])
      %HL7v2.Type.VH{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      start_day_range: Type.get_component(components, 0),
      end_day_range: Type.get_component(components, 1),
      start_hour_range: Type.get_component(components, 2),
      end_hour_range: Type.get_component(components, 3)
    }
  end

  @doc """
  Encodes a VH to a list of component strings.

  ## Examples

      iex> HL7v2.Type.VH.encode(%HL7v2.Type.VH{start_day_range: "MON", end_day_range: "FRI", start_hour_range: "0800", end_hour_range: "1700"})
      ["MON", "FRI", "0800", "1700"]

      iex> HL7v2.Type.VH.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = vh) do
    [
      vh.start_day_range || "",
      vh.end_day_range || "",
      vh.start_hour_range || "",
      vh.end_hour_range || ""
    ]
    |> Type.trim_trailing()
  end
end
