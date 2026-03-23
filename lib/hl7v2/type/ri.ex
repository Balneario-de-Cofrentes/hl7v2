defmodule HL7v2.Type.RI do
  @moduledoc """
  Repeat Interval (RI) -- HL7v2 composite data type.

  Specifies the interval between repeated services. Used in TQ-2
  (Timing/Quantity interval component).

  2 components:
  1. Repeat Pattern (IS) -- coded pattern, e.g., "Q6H", "BID", "TID"
  2. Explicit Time Interval (ST) -- explicit interval, e.g., "Q2H", "300S"
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:repeat_pattern, :explicit_time_interval]

  @type t :: %__MODULE__{
          repeat_pattern: binary() | nil,
          explicit_time_interval: binary() | nil
        }

  @doc """
  Parses an RI from a list of components.

  ## Examples

      iex> HL7v2.Type.RI.parse(["Q6H", "6 hours"])
      %HL7v2.Type.RI{repeat_pattern: "Q6H", explicit_time_interval: "6 hours"}

      iex> HL7v2.Type.RI.parse(["BID"])
      %HL7v2.Type.RI{repeat_pattern: "BID"}

      iex> HL7v2.Type.RI.parse([])
      %HL7v2.Type.RI{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      repeat_pattern: Type.get_component(components, 0),
      explicit_time_interval: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes an RI to a list of component strings.

  ## Examples

      iex> HL7v2.Type.RI.encode(%HL7v2.Type.RI{repeat_pattern: "Q6H", explicit_time_interval: "6 hours"})
      ["Q6H", "6 hours"]

      iex> HL7v2.Type.RI.encode(%HL7v2.Type.RI{repeat_pattern: "BID"})
      ["BID"]

      iex> HL7v2.Type.RI.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ri) do
    [
      ri.repeat_pattern || "",
      ri.explicit_time_interval || ""
    ]
    |> Type.trim_trailing()
  end
end
