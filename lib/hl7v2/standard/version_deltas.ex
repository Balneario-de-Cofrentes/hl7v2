defmodule HL7v2.Standard.VersionDeltas do
  @moduledoc """
  Tracks field optionality changes between HL7 v2.x versions.

  Currently tracks v2.7+ field deprecations (fields that became B — backward
  compatibility only — in v2.7). When validating a message at v2.7 or later,
  these fields should NOT be enforced as required even though the baseline
  v2.5.1 schema marks them `:r` or `:c`.

  HL7 does not change a field's optionality from `:o` → `:r` between versions.
  What it does is retire previously required/conditional fields by marking them
  `:b` (backward compatibility only) and introducing replacement fields. The
  [`HL7v2.Validation.FieldRules`](`HL7v2.Validation.FieldRules`) pipeline uses
  `exempt?/3` to skip required-field enforcement for known deprecations when a
  message declares itself at a version where the field is no longer required.

  ## Currently tracked v2.7 deprecations

  - `PID-13`, `PID-14` — telecom fields, replaced by `PID-40`
    (`patient_telecommunication_information`).
  - `OBR-10`, `OBR-16` — collector/ordering provider, replaced by the `PRT`
    segment (and `OBR-50` for parent service identifier).
  - `ORC-10`, `ORC-12` — entered_by / ordering_provider, replaced by the `PRT`
    segment.

  Note: the baseline v2.5.1 schema shipped with this library currently marks
  several of these deprecated fields as `:o` already, so the exemption is a
  no-op for them today. The deprecation list is still enforced so that any
  future schema tightening (e.g., reinstating the canonical v2.5.1 `:r`/`:c`
  markings for `OBR-10`/`OBR-16`) remains safe for v2.7+ messages without
  additional bookkeeping.
  """

  # Fields deprecated in v2.7 (became :b — backward compatibility only)
  # Format: {segment_id, field_sequence_number}
  @v27_deprecations [
    # PID telecom fields — replaced by PID-40
    {"PID", 13},
    {"PID", 14},
    # OBR fields — replaced by PRT segment or OBR-29/OBR-50
    {"OBR", 10},
    {"OBR", 16},
    # ORC fields — replaced by PRT segment
    {"ORC", 10},
    {"ORC", 12}
  ]

  @doc """
  Returns `true` if a field is exempt from required-field enforcement at the
  given version, and `false` if the field should still be required per the
  baseline v2.5.1 schema.

  The `version` argument should be a normalized HL7 version string (e.g.
  `"2.5.1"`, `"2.7"`). Pass `nil` when the validating caller has no version
  context — the function returns `false` in that case and the baseline
  v2.5.1 rules apply unchanged.

  ## Examples

      iex> HL7v2.Standard.VersionDeltas.exempt?("PID", 13, "2.7")
      true

      iex> HL7v2.Standard.VersionDeltas.exempt?("PID", 13, "2.8")
      true

      iex> HL7v2.Standard.VersionDeltas.exempt?("PID", 13, "2.5.1")
      false

      iex> HL7v2.Standard.VersionDeltas.exempt?("PID", 5, "2.7")
      false

      iex> HL7v2.Standard.VersionDeltas.exempt?("PID", 13, nil)
      false

  """
  @spec exempt?(binary(), pos_integer(), binary() | nil) :: boolean()
  def exempt?(segment_id, field_seq, version)
      when is_binary(segment_id) and is_integer(field_seq) and field_seq > 0 do
    # We normalize first so unparseable or non-binary versions fall through
    # to `false` instead of raising out of `Version.at_least?/2`.
    with canonical when is_binary(canonical) <- HL7v2.Standard.Version.normalize(version),
         true <- HL7v2.Standard.Version.at_least?(canonical, "2.7") do
      {segment_id, field_seq} in @v27_deprecations
    else
      _ -> false
    end
  end

  def exempt?(_segment_id, _field_seq, _version), do: false

  @doc """
  Returns all v2.7 deprecations as a list of `{segment_id, field_seq}` tuples.

  Useful for documentation, introspection, and tests that want to assert the
  exhaustive deprecation set without duplicating the literal.
  """
  @spec v27_deprecations() :: [{binary(), pos_integer()}]
  def v27_deprecations, do: @v27_deprecations
end
