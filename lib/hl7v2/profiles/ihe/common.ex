defmodule HL7v2.Profiles.IHE.Common do
  @moduledoc """
  Shared constraint helpers for the IHE profile pack.

  Most IHE profiles (PAM, PIX, PDQ, LTW, RAD-SWF) share a common base
  set of MSH/EVN/PID requirements. This module composes those into
  reusable building blocks so each profile module stays declarative
  and focused on the transaction-specific rules.

  These helpers are deliberately fine-grained. Profile modules pipe
  them together in whatever combination their transaction requires.
  """

  alias HL7v2.Profile
  alias HL7v2.Segment.PID
  alias HL7v2.Type.{CX, HD}
  alias HL7v2.TypedMessage

  @doc """
  Adds the IHE PAM/PIX MSH baseline — requires MSH-9/10/11/12 and
  forbids MSH-8 (Security), which IHE marks as "X" (not supported).

  NOTE: MSH-14 (Continuation Pointer) is deliberately NOT forbidden
  here. ITI-9 PIX Query uses it for the continuation protocol; IHE
  PAM leaves it as "not used" (O) rather than strictly forbidden,
  and real-world wires from vendors occasionally populate it.
  """
  @spec msh_pam_core(Profile.t()) :: Profile.t()
  def msh_pam_core(%Profile{} = profile) do
    profile
    |> Profile.require_field("MSH", 9)
    |> Profile.require_field("MSH", 10)
    |> Profile.require_field("MSH", 11)
    |> Profile.require_field("MSH", 12)
    |> Profile.forbid_field("MSH", 8)
  end

  @doc """
  Requires EVN-2 (Recorded Date/Time). Used by all IHE ADT-based
  transactions.

  NOTE: EVN-1 (Event Type Code) is NOT forbidden. Although the HL7
  v2.5.1 base marks it as "B" (backwards compat) and the IHE PAM TF
  recommends carrying the trigger in MSH-9 instead, real-world
  systems (Epic, Cerner Millennium, Meditech, most Spanish HIS
  products) still populate EVN-1 with the trigger event code.
  Forbidding it would flag conformant messages.
  """
  @spec evn_core(Profile.t()) :: Profile.t()
  def evn_core(%Profile{} = profile) do
    Profile.require_field(profile, "EVN", 2)
  end

  @doc """
  IHE patient identification baseline — requires PID-5 (Patient
  Name), declaratively requires CX-1 (ID Number) for every PID-3
  repetition via `Profile.require_component/5`, and adds a small
  custom rule for the IHE Assigning Authority requirement:

  - every non-empty CX carries CX-4 (Assigning Authority) with
    either a `namespace_id` OR a `universal_id` populated

  The CX-4 OR semantics cannot be expressed with `require_component`
  alone (which checks a single subcomponent), so the rule is kept as
  a custom closure — but it is now ~25 lines instead of ~60, since
  CX-1 handling moved to the declarative DSL.

  This is the single most common IHE constraint across
  PAM/PIX/PDQ/LAB/RAD-1.
  """
  @spec pid_core(Profile.t()) :: Profile.t()
  def pid_core(%Profile{} = profile) do
    profile
    |> Profile.require_field("PID", 5)
    |> Profile.require_component("PID", 3, 1, each_repetition: true)
    |> Profile.add_rule(:pid3_assigning_authority, &pid3_assigning_authority_rule/1)
  end

  @doc """
  Custom rule: validates the IHE "PID-3 must have either
  namespace_id or universal_id" OR semantics that cannot be
  expressed with the declarative component DSL.
  """
  @spec pid3_assigning_authority_rule(TypedMessage.t()) :: [map()]
  def pid3_assigning_authority_rule(%TypedMessage{segments: segments}) do
    segments
    |> Enum.filter(&match?(%PID{}, &1))
    |> Enum.flat_map(&check_cx_aa/1)
  end

  defp check_cx_aa(%PID{patient_identifier_list: ids}) when is_list(ids) do
    ids
    |> Enum.with_index(1)
    |> Enum.flat_map(fn
      {%CX{} = cx, idx} -> check_single_cx_aa(cx, idx)
      _ -> []
    end)
  end

  defp check_cx_aa(_), do: []

  defp check_single_cx_aa(%CX{} = cx, idx) do
    if empty_cx?(cx) or assigning_authority_populated?(cx) do
      []
    else
      [
        %{
          level: :error,
          location: "PID",
          field: :patient_identifier_list,
          message:
            "IHE requires PID-3 repetition #{idx} to carry CX-4 " <>
              "(Assigning Authority: namespace_id or universal_id)"
        }
      ]
    end
  end

  defp empty_cx?(%CX{} = cx),
    do: blank?(cx.id) and not assigning_authority_populated?(cx)

  defp empty_cx?(_), do: true

  defp assigning_authority_populated?(%CX{assigning_authority: %HD{} = hd}) do
    not (blank?(hd.namespace_id) and blank?(hd.universal_id))
  end

  defp assigning_authority_populated?(_), do: false

  defp blank?(nil), do: true
  defp blank?(""), do: true
  defp blank?(_), do: false

  @doc """
  Pins PV1-2 (Patient Class) to a specific value. Used by IHE
  transactions that operate outside a visit context (ITI-30 A28/A31,
  ITI-10) where PV1-2 SHALL be `"N"` (Not Applicable).

  Sugar for `Profile.require_value("PV1", 2, expected)`.
  """
  @spec pin_patient_class(Profile.t(), String.t()) :: Profile.t()
  def pin_patient_class(%Profile{} = profile, expected) when is_binary(expected) do
    Profile.require_value(profile, "PV1", 2, expected)
  end

  @doc """
  Requires a specific segment AND a specific field within that
  segment in one call. Convenience for the common IHE pattern of
  "this transaction requires segment X, and within X field N must
  be populated".
  """
  @spec require_segment_field(Profile.t(), String.t(), pos_integer()) :: Profile.t()
  def require_segment_field(%Profile{} = profile, seg_id, field_seq) do
    profile
    |> Profile.require_segment(seg_id)
    |> Profile.require_field(seg_id, field_seq)
  end
end
