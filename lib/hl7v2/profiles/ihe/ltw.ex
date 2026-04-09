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
    |> Profile.add_value_constraint("ORC", 1, &orc_1_is_valid_lab_control/1)
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
    |> Profile.add_value_constraint("OBR", 25, &obr_25_is_valid_status/1)
    |> Profile.add_value_constraint("OBX", 11, &obx_11_is_valid_status/1)
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

  # ------------------------------------------------------------------
  # Value constraint helpers
  # ------------------------------------------------------------------

  # Subset of HL7 table 0119 allowed by IHE PaLM TF-2a §3.1.4 for
  # laboratory order control codes.
  @orc_1_codes ~w(NW OK UA SC CA CR UC OC SN NA RP RQ UM RU XO XR UX PR)
  defp orc_1_is_valid_lab_control(code) when is_binary(code) and code in @orc_1_codes,
    do: true

  defp orc_1_is_valid_lab_control(other),
    do: {:error, "ORC-1 must be one of #{inspect(@orc_1_codes)}, got #{inspect(other)}"}

  # IHE LAB-3 subset of HL7 table 0123 for OBR-25 Result Status.
  @obr_25_codes ~w(S I R P F C X)
  defp obr_25_is_valid_status(code) when is_binary(code) and code in @obr_25_codes,
    do: true

  defp obr_25_is_valid_status(other),
    do: {:error, "OBR-25 must be one of #{inspect(@obr_25_codes)}, got #{inspect(other)}"}

  # IHE LAB-3 subset of HL7 table 0085 for OBX-11 Observation
  # Result Status. `U` is explicitly NOT allowed.
  @obx_11_codes ~w(O I D R P F C X)
  defp obx_11_is_valid_status(code) when is_binary(code) and code in @obx_11_codes,
    do: true

  defp obx_11_is_valid_status(other),
    do: {:error, "OBX-11 must be one of #{inspect(@obx_11_codes)}, got #{inspect(other)}"}
end
