defmodule HL7v2.Segment.ZXX do
  @moduledoc """
  Generic Z-Segment (ZXX) — HL7v2 v2.5.1.

  Handles any Z-segment (ZPD, ZPI, ZDX, etc.) by preserving all fields as raw
  values. Z-segments are site-defined extensions — their structure is unknown to
  the standard, so we store them losslessly.
  """

  @behaviour HL7v2.Segment

  defstruct [:segment_id, :raw_fields]

  @type t :: %__MODULE__{
          segment_id: binary(),
          raw_fields: list()
        }

  @impl HL7v2.Segment
  def fields, do: []

  @doc """
  Returns the segment identifier for a specific ZXX instance.
  """
  @spec segment_name(t()) :: binary()
  def segment_name(%__MODULE__{segment_id: id}), do: id

  @impl HL7v2.Segment
  @spec segment_id() :: binary()
  def segment_id, do: "ZXX"

  @doc """
  Parses a Z-segment, preserving all fields as raw values.

  The `segment_name` is stored so we can re-encode with the correct identifier.
  """
  @impl HL7v2.Segment
  @spec parse(list(), HL7v2.Separator.t()) :: t()
  def parse(raw_fields, _separators \\ HL7v2.Separator.default()) do
    %__MODULE__{
      segment_id: "ZXX",
      raw_fields: raw_fields
    }
  end

  @doc """
  Creates a ZXX from a specific Z-segment name and raw field list.
  """
  @spec new(binary(), list()) :: t()
  def new(segment_name, raw_fields) when is_binary(segment_name) do
    %__MODULE__{
      segment_id: segment_name,
      raw_fields: raw_fields
    }
  end

  @impl HL7v2.Segment
  @spec encode(t()) :: list()
  def encode(%__MODULE__{raw_fields: raw_fields}) do
    raw_fields || []
  end
end
