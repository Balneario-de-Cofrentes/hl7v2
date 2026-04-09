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
  Adds the IHE PAM/PIX MSH baseline — requires MSH-9/10/11/12,
  forbids MSH-8 (Security) and MSH-14 (Continuation Pointer) which
  IHE marks as deprecated/X.
  """
  @spec msh_pam_core(Profile.t()) :: Profile.t()
  def msh_pam_core(%Profile{} = profile) do
    profile
    |> Profile.require_field("MSH", 9)
    |> Profile.require_field("MSH", 10)
    |> Profile.require_field("MSH", 11)
    |> Profile.require_field("MSH", 12)
    |> Profile.forbid_field("MSH", 8)
    |> Profile.forbid_field("MSH", 14)
  end

  @doc """
  Requires EVN-2 (Recorded Date/Time) and forbids EVN-1 (deprecated
  — use MSH-9). Used by all IHE ADT-based transactions.
  """
  @spec evn_core(Profile.t()) :: Profile.t()
  def evn_core(%Profile{} = profile) do
    profile
    |> Profile.require_field("EVN", 2)
    |> Profile.forbid_field("EVN", 1)
  end

  @doc """
  IHE patient identification baseline — requires PID-3 (Patient
  Identifier List) and PID-5 (Patient Name), and adds a custom rule
  that checks every PID-3 repetition has a populated Assigning
  Authority (CX-4). This is the single most common IHE constraint
  across PAM/PIX/PDQ/LAB/RAD-1.
  """
  @spec pid_core(Profile.t()) :: Profile.t()
  def pid_core(%Profile{} = profile) do
    profile
    |> Profile.require_field("PID", 3)
    |> Profile.require_field("PID", 5)
    |> Profile.add_rule(:pid3_assigning_authority, &pid3_assigning_authority_rule/1)
  end

  @doc """
  Custom rule: every PID-3 repetition in every PID segment must have
  CX-4 (Assigning Authority) populated with at least a namespace ID
  or a universal ID. Returns a list of error maps.
  """
  @spec pid3_assigning_authority_rule(TypedMessage.t()) :: [map()]
  def pid3_assigning_authority_rule(%TypedMessage{segments: segments}) do
    segments
    |> Enum.filter(&match?(%PID{}, &1))
    |> Enum.flat_map(&check_pid3_repetitions/1)
  end

  defp check_pid3_repetitions(%PID{patient_identifier_list: nil}), do: []
  defp check_pid3_repetitions(%PID{patient_identifier_list: []}), do: []

  defp check_pid3_repetitions(%PID{patient_identifier_list: ids}) when is_list(ids) do
    ids
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {cx, idx} ->
      if assigning_authority_populated?(cx) do
        []
      else
        [
          %{
            level: :error,
            location: "PID",
            field: :patient_identifier_list,
            message: "IHE requires PID-3 repetition #{idx} to carry an Assigning Authority (CX-4)"
          }
        ]
      end
    end)
  end

  defp check_pid3_repetitions(_), do: []

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
  """
  @spec pin_patient_class(Profile.t(), String.t()) :: Profile.t()
  def pin_patient_class(%Profile{} = profile, expected) when is_binary(expected) do
    Profile.add_value_constraint(profile, "PV1", 2, fn
      ^expected -> true
      other -> {:error, "PV1-2 must be #{inspect(expected)}, got #{inspect(other)}"}
    end)
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
