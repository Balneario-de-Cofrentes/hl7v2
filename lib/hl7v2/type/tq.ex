defmodule HL7v2.Type.TQ do
  @moduledoc """
  Timing/Quantity (TQ) -- HL7v2 composite data type.

  Deprecated in v2.5.1 (replaced by TQ1/TQ2 segments), but retained for
  backward compatibility with OBR-27, ORC-7, and SCH-11 which use this type.

  12 components:
  1. Quantity (CQ) -- sub-components delimited by `&`
  2. Interval (RI) -- `:raw`, RI not yet implemented
  3. Duration (ST)
  4. Start Date/Time (TS) -- sub-components delimited by `&`
  5. End Date/Time (TS) -- sub-components delimited by `&`
  6. Priority (ST)
  7. Condition (ST)
  8. Text (TX)
  9. Conjunction (ID) -- Table 0472: S (synchronous), A (asynchronous)
  10. Order Sequencing (OSD) -- `:raw`, OSD not yet implemented
  11. Occurrence Duration (CE) -- sub-components delimited by `&`
  12. Total Occurrences (NM)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{CQ, CE, TS, DTM}

  defstruct [
    :quantity,
    :interval,
    :duration,
    :start_date_time,
    :end_date_time,
    :priority,
    :condition,
    :text,
    :conjunction,
    :order_sequencing,
    :occurrence_duration,
    :total_occurrences
  ]

  @type t :: %__MODULE__{
          quantity: CQ.t() | nil,
          interval: binary() | nil,
          duration: binary() | nil,
          start_date_time: TS.t() | nil,
          end_date_time: TS.t() | nil,
          priority: binary() | nil,
          condition: binary() | nil,
          text: binary() | nil,
          conjunction: binary() | nil,
          order_sequencing: binary() | nil,
          occurrence_duration: CE.t() | nil,
          total_occurrences: binary() | nil
        }

  @doc """
  Parses a TQ from a list of components.

  Components containing sub-components (CQ, TS, CE) are split by `&` and
  parsed into their respective structs. RI (component 2) and OSD (component 10)
  are preserved as raw strings.

  ## Examples

      iex> HL7v2.Type.TQ.parse(["1&mL", "", "S10", "20260322143000"])
      %HL7v2.Type.TQ{
        quantity: %HL7v2.Type.CQ{quantity: "1", units: %HL7v2.Type.CE{identifier: "mL"}},
        duration: "S10",
        start_date_time: %HL7v2.Type.TS{time: %HL7v2.Type.DTM{year: 2026, month: 3, day: 22, hour: 14, minute: 30, second: 0}}
      }

      iex> HL7v2.Type.TQ.parse([])
      %HL7v2.Type.TQ{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      quantity: parse_sub_cq(Type.get_component(components, 0)),
      interval: Type.get_component(components, 1),
      duration: Type.get_component(components, 2),
      start_date_time: parse_sub_ts(Type.get_component(components, 3)),
      end_date_time: parse_sub_ts(Type.get_component(components, 4)),
      priority: Type.get_component(components, 5),
      condition: Type.get_component(components, 6),
      text: Type.get_component(components, 7),
      conjunction: Type.get_component(components, 8),
      order_sequencing: Type.get_component(components, 9),
      occurrence_duration: parse_sub_ce(Type.get_component(components, 10)),
      total_occurrences: Type.get_component(components, 11)
    }
  end

  @doc """
  Encodes a TQ to a list of component strings.

  ## Examples

      iex> HL7v2.Type.TQ.encode(%HL7v2.Type.TQ{quantity: %HL7v2.Type.CQ{quantity: "1"}, duration: "S10"})
      ["1", "", "S10"]

      iex> HL7v2.Type.TQ.encode(nil)
      []

      iex> HL7v2.Type.TQ.encode(%HL7v2.Type.TQ{})
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = tq) do
    [
      encode_sub_cq(tq.quantity),
      tq.interval || "",
      tq.duration || "",
      encode_sub_ts(tq.start_date_time),
      encode_sub_ts(tq.end_date_time),
      tq.priority || "",
      tq.condition || "",
      tq.text || "",
      tq.conjunction || "",
      tq.order_sequencing || "",
      encode_sub_ce(tq.occurrence_duration),
      tq.total_occurrences || ""
    ]
    |> Type.trim_trailing()
  end

  # -- Sub-component parsing helpers --

  defp parse_sub_cq(nil), do: nil

  defp parse_sub_cq(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    cq_val = CQ.parse(subs)
    if all_nil?(cq_val), do: nil, else: cq_val
  end

  defp encode_sub_cq(nil), do: ""

  defp encode_sub_cq(%CQ{} = cq) do
    cq |> CQ.encode() |> Enum.join(Type.sub_component_separator())
  end

  defp parse_sub_ts(nil), do: nil

  defp parse_sub_ts(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    ts_val = TS.parse(subs)

    if ts_val.time == nil and ts_val.degree_of_precision == nil do
      nil
    else
      ts_val
    end
  end

  defp encode_sub_ts(nil), do: ""

  defp encode_sub_ts(%TS{} = ts) do
    case TS.encode(ts) do
      [] -> ""
      parts -> Enum.join(parts, Type.sub_component_separator())
    end
  end

  defp encode_sub_ts(%DTM{} = dtm) do
    DTM.encode(dtm)
  end

  defp parse_sub_ce(nil), do: nil

  defp parse_sub_ce(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    ce_val = CE.parse(subs)
    if all_nil?(ce_val), do: nil, else: ce_val
  end

  defp encode_sub_ce(nil), do: ""

  defp encode_sub_ce(%CE{} = ce) do
    ce |> CE.encode() |> Enum.join(Type.sub_component_separator())
  end

  defp all_nil?(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&is_nil/1)
  end
end
