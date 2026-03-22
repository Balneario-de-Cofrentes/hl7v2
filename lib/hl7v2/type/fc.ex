defmodule HL7v2.Type.FC do
  @moduledoc """
  Financial Class (FC) -- HL7v2 composite data type.

  Used to classify patient financial responsibility.

  2 components:
  1. Financial Class Code (IS) -- Table 0064
  2. Effective Date (TS) -- sub-components delimited by `&`
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.TS

  defstruct [:financial_class_code, :effective_date]

  @type t :: %__MODULE__{
          financial_class_code: binary() | nil,
          effective_date: TS.t() | nil
        }

  @doc """
  Parses an FC from a list of components.

  ## Examples

      iex> HL7v2.Type.FC.parse(["01"])
      %HL7v2.Type.FC{financial_class_code: "01"}

      iex> HL7v2.Type.FC.parse(["01", "20260322"])
      %HL7v2.Type.FC{financial_class_code: "01", effective_date: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22}}}

      iex> HL7v2.Type.FC.parse([])
      %HL7v2.Type.FC{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      financial_class_code: Type.get_component(components, 0),
      effective_date: parse_sub_ts(Type.get_component(components, 1))
    }
  end

  @doc """
  Encodes an FC to a list of component strings.

  ## Examples

      iex> HL7v2.Type.FC.encode(%HL7v2.Type.FC{financial_class_code: "01"})
      ["01"]

      iex> HL7v2.Type.FC.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = fc) do
    [
      fc.financial_class_code || "",
      encode_sub_ts(fc.effective_date)
    ]
    |> Type.trim_trailing()
  end

  defp parse_sub_ts(nil), do: nil

  defp parse_sub_ts(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    ts_val = TS.parse(subs)
    if ts_val.time == nil and ts_val.degree_of_precision == nil, do: nil, else: ts_val
  end

  defp encode_sub_ts(nil), do: ""

  defp encode_sub_ts(%TS{} = ts) do
    ts |> TS.encode() |> Enum.join(Type.sub_component_separator())
  end
end
