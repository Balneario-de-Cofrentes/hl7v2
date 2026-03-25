defmodule HL7v2.Type.CCD do
  @moduledoc """
  Charge Code and Date (CCD) -- HL7v2 composite data type.

  Specifies when a charge should be invoked and the associated date/time.

  2 components:
  1. Invocation Event (ID) -- Table 0100: e.g., "D" (on discharge), "O" (on order),
     "R" (at time of service), "S" (at time of service)
  2. Date/Time (TS) -- when the charge applies
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [
    :invocation_event,
    :date_time
  ]

  @type t :: %__MODULE__{
          invocation_event: binary() | nil,
          date_time: Type.TS.t() | nil
        }

  @doc """
  Parses a CCD from a list of components.

  ## Examples

      iex> HL7v2.Type.CCD.parse(["D", "20260101120000"])
      %HL7v2.Type.CCD{invocation_event: "D", date_time: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 1, day: 1, hour: 12, minute: 0, second: 0}}}

      iex> HL7v2.Type.CCD.parse(["O"])
      %HL7v2.Type.CCD{invocation_event: "O"}

      iex> HL7v2.Type.CCD.parse([])
      %HL7v2.Type.CCD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      invocation_event: Type.get_component(components, 0),
      date_time: Type.parse_sub_ts(Type.get_component(components, 1))
    }
  end

  @doc """
  Encodes a CCD to a list of component strings.

  ## Examples

      iex> HL7v2.Type.CCD.encode(%HL7v2.Type.CCD{invocation_event: "D"})
      ["D"]

      iex> HL7v2.Type.CCD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ccd) do
    [
      ccd.invocation_event || "",
      Type.encode_sub_ts(ccd.date_time)
    ]
    |> Type.trim_trailing()
  end
end
