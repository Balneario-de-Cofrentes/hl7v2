defmodule HL7v2.Standard.Coverage do
  @moduledoc """
  Computes library coverage against the HL7 v2.5.1 standard.

  Reports which segments, types, and structures are typed, raw, or unsupported,
  and identifies specific fields that fall back to `:raw` within typed segments.
  """

  alias HL7v2.Standard

  @doc """
  Returns the list of segments with full typed parse/encode support.

  ## Examples

      iex> "PID" in HL7v2.Standard.Coverage.typed_segments()
      true

  """
  @spec typed_segments() :: [binary()]
  def typed_segments, do: Standard.typed_segment_ids()

  @doc """
  Returns segments that exist in the standard but are not typed.
  These segments are preserved as raw tuples during typed parsing.
  """
  @spec unsupported_segments() :: [binary()]
  def unsupported_segments do
    Standard.segment_ids()
    |> Enum.filter(&(Standard.segment_tier(&1) == :unsupported))
  end

  @doc """
  Returns data types with full parse/encode modules.
  """
  @spec typed_types() :: [binary()]
  def typed_types, do: Standard.typed_type_codes()

  @doc """
  Returns data types that exist in the standard but are not implemented.
  """
  @spec unsupported_types() :: [binary()]
  def unsupported_types do
    Standard.type_codes()
    |> Enum.filter(&(Standard.type_tier(&1) == :unsupported))
  end

  @doc """
  Returns specific segment fields that are typed as `:raw` within
  otherwise typed segments — the "raw holes."
  """
  @spec raw_holes() :: [{binary(), atom(), pos_integer()}]
  def raw_holes do
    Standard.typed_segment_ids()
    |> Enum.flat_map(fn seg_id ->
      module = Standard.segment_module(seg_id)

      module.fields()
      |> Enum.filter(fn {_seq, _name, type, _opt, _max} -> type == :raw end)
      |> Enum.map(fn {seq, name, _type, _opt, _max} -> {seg_id, name, seq} end)
    end)
  end

  @doc """
  Returns a summary map of coverage statistics.

  ## Examples

      iex> summary = HL7v2.Standard.Coverage.coverage_summary()
      iex> is_integer(summary.typed_segment_count)
      true

  """
  @spec coverage_summary() :: map()
  def coverage_summary do
    typed_segs = typed_segments()
    all_segs = Standard.segment_ids()
    typed_typs = typed_types()
    all_typs = Standard.type_codes()
    holes = raw_holes()

    total_fields =
      typed_segs
      |> Enum.map(&Standard.segment_module/1)
      |> Enum.map(&length(&1.fields()))
      |> Enum.sum()

    %{
      typed_segment_count: length(typed_segs),
      total_segment_count: length(all_segs),
      segment_coverage_pct: Float.round(length(typed_segs) / length(all_segs) * 100, 1),
      typed_type_count: length(typed_typs),
      total_type_count: length(all_typs),
      type_coverage_pct: Float.round(length(typed_typs) / length(all_typs) * 100, 1),
      total_typed_fields: total_fields,
      raw_hole_count: length(holes),
      raw_holes: holes
    }
  end
end
