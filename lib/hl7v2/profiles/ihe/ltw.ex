defmodule HL7v2.Profiles.IHE.LTW do
  @moduledoc """
  IHE Laboratory Testing Workflow (LTW) conformance profiles.

  Ships factory functions for the two most common IHE PaLM TF
  laboratory transactions:

  - **LAB-1 Placer Order Management** — `OML^O21` placer → filler.
    Source: IHE PaLM TF-2a §3.1 (Rev 11.0, 2024-04-08).
  - **LAB-3 Order Results Management** — `ORU^R01` filler → results
    tracker. Source: IHE PaLM TF-2a §3.3.

  Both transactions are defined on HL7 v2.5.1. The IHE PaLM TF
  constrains several base-HL7 fields to `X` (not supported) in
  favor of newer segments — notably ORC-7 and OBR-5/6/8/27 are
  replaced by TQ1.

  ## Usage

      profile = HL7v2.Profiles.IHE.LTW.lab_1_placer_oml_o21()
      HL7v2.validate(msg, profile: profile)
  """

  alias HL7v2.Profile
  alias HL7v2.Profiles.IHE.Common

  # ------------------------------------------------------------------
  # LAB-1 Placer Order Management — OML^O21
  # ------------------------------------------------------------------

  @doc """
  LAB-1 OML^O21 — Placer Order Management.

  Placer → Filler new-order flow. Requires MSH, PID, ORC, OBR.
  PV1-2 is required (value "U" when patient class is unknown).
  ORC-1 must be a valid IHE subset code; ORC-9 carries the
  transaction timestamp; OBR-2/OBR-4/OBR-16 are all required.

  Forbidden fields (per IHE PaLM TF-2a §3.1.4.1.2.3):
  - ORC-7 (Quantity/Timing) — replaced by TQ1
  - OBR-5 (Priority) — replaced by TQ1
  - OBR-6 (Requested Date/Time) — replaced by TQ1
  - OBR-8 (Observation End Date/Time) — replaced by SPM
  - OBR-15 (Specimen Source) — replaced by SPM
  - OBR-22 (Results Rpt/Status Chng) — not supported in LAB-1
  - OBR-27 (Quantity/Timing) — replaced by TQ1

  Source: IHE PaLM TF-2a §3.1.
  """
  @spec lab_1_placer_oml_o21() :: Profile.t()
  def lab_1_placer_oml_o21 do
    "IHE_LAB-1_OML_O21"
    |> Profile.new(
      message_type: {"OML", "O21"},
      version: "2.5.1",
      description: "IHE LAB-1 Placer Order Management — OML^O21 (v2.5.1)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("PV1")
    |> Profile.require_segment("ORC")
    |> Profile.require_segment("OBR")
    |> Common.msh_pam_core()
    |> Common.pid_core()
    |> Profile.require_field("PV1", 2)
    |> Profile.require_field("ORC", 1)
    |> Profile.require_field("ORC", 9)
    |> Profile.require_field("OBR", 2)
    |> Profile.require_field("OBR", 4)
    |> Profile.require_field("OBR", 16)
    |> Profile.forbid_field("ORC", 7)
    |> Profile.forbid_field("OBR", 5)
    |> Profile.forbid_field("OBR", 6)
    |> Profile.forbid_field("OBR", 8)
    |> Profile.forbid_field("OBR", 15)
    |> Profile.forbid_field("OBR", 22)
    |> Profile.forbid_field("OBR", 27)
    |> Profile.require_value_in(
      "ORC",
      1,
      ~w(NW OK UA SC CA CR UC OC SN NA RP RQ UM RU XO XR UX PR)
    )
  end

  # ------------------------------------------------------------------
  # LAB-3 Order Results Management — ORU^R01
  # ------------------------------------------------------------------

  @doc """
  LAB-3 ORU^R01 — Order Results Management.

  Filler → Results Tracker results delivery. Requires MSH, PID,
  ORC, OBR, OBX. OBR-3 (Filler Order Number) is the primary
  correlation key; OBR-4 must carry Identifier + Text + Coding
  System subcomponents. OBR-25 (Order Result Status) is required
  and must be one of {S, I, R, P, F, C, X}. OBX-11 (Observation
  Result Status) is required and must be one of {O, I, D, R, P,
  F, C, X} — note `U` is explicitly forbidden.

  Source: IHE PaLM TF-2a §3.3.
  """
  @spec lab_3_results_oru_r01() :: Profile.t()
  def lab_3_results_oru_r01 do
    "IHE_LAB-3_ORU_R01"
    |> Profile.new(
      message_type: {"ORU", "R01"},
      version: "2.5.1",
      description: "IHE LAB-3 Order Results Management — ORU^R01 (v2.5.1)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("PV1")
    |> Profile.require_segment("ORC")
    |> Profile.require_segment("OBR")
    |> Profile.require_segment("OBX")
    |> Common.msh_pam_core()
    |> Common.pid_core()
    |> Profile.require_field("PV1", 2)
    |> Profile.require_field("OBR", 3)
    |> Profile.require_field("OBR", 4)
    |> Profile.require_field("OBR", 25)
    |> Profile.require_field("OBX", 1)
    |> Profile.require_field("OBX", 3)
    |> Profile.require_field("OBX", 11)
    |> Profile.forbid_field("OBX", 9)
    |> Profile.forbid_field("OBX", 10)
    |> Profile.forbid_field("OBX", 12)
    |> Profile.require_value_in("OBR", 25, ~w(S I R P F C X))
    |> Profile.require_value_in("OBX", 11, ~w(O I D R P F C X))
  end

  @doc """
  Returns the complete LTW profile catalog.
  """
  @spec all() :: %{String.t() => Profile.t()}
  def all do
    %{
      "LAB-1" => lab_1_placer_oml_o21(),
      "LAB-3" => lab_3_results_oru_r01()
    }
  end
end
