defmodule HL7v2.Profiles.IHE.PAM do
  @moduledoc """
  IHE Patient Administration Management (PAM) conformance profiles.

  Ships factory functions for the two PAM transactions in the IHE
  ITI Technical Framework Vol 2:

  - **ITI-30 Patient Identity Management** — manages patient
    demographics outside a visit context (A28 create, A31 update,
    A40 merge, A47 change ID list). Source: IHE ITI TF-2b §3.30.
  - **ITI-31 Patient Encounter Management** — manages the life cycle
    of a patient encounter (A01 admit, A02 transfer, A03 discharge,
    A04 register outpatient, A05 pre-admit, A06/A07 class change,
    A08 update, A11 cancel admit, A40 merge, and more). Source:
    IHE ITI TF-2b §3.31.

  Both transactions are defined on HL7 v2.5. Each factory returns a
  `%HL7v2.Profile{}` preconfigured with the IHE constraints from the
  TF — required segments, required fields, forbidden fields,
  cross-segment rules (e.g. PID-3 Assigning Authority).

  ## Usage

      profile = HL7v2.Profiles.IHE.PAM.iti_31_adt_a01()
      {:ok, msg} = HL7v2.parse(wire, mode: :typed)

      case HL7v2.Validation.ProfileRules.check(msg, profile) do
        []     -> :conformant
        errors -> {:non_conformant, errors}
      end

  Or pass as a validation option:

      HL7v2.validate(msg, profile: HL7v2.Profiles.IHE.PAM.iti_31_adt_a01())
  """

  alias HL7v2.Profile
  alias HL7v2.Profiles.IHE.Common

  # ------------------------------------------------------------------
  # ITI-31 Patient Encounter Management
  # ------------------------------------------------------------------

  @doc """
  ITI-31 ADT^A01 — Admit/Visit Notification.

  Requires MSH, EVN, PID, PV1. PV1-2 (Patient Class) and PV1-3
  (Assigned Patient Location) must be populated per IHE ITI TF-2b
  §3.31.4.1.2. PID-3 requires a populated Assigning Authority.

  Source: IHE ITI TF-2b §3.31.
  """
  @spec iti_31_adt_a01() :: Profile.t()
  def iti_31_adt_a01 do
    "IHE_ITI-31_ADT_A01"
    |> new_pam({"ADT", "A01"}, "IHE PAM Patient Encounter Management — Admit Inpatient")
    |> Profile.require_segment("EVN")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("PV1")
    |> Common.msh_pam_core()
    |> Common.evn_core()
    |> Common.pid_core()
    |> Profile.require_field("PV1", 2)
    |> Profile.require_field("PV1", 3)
  end

  @doc """
  ITI-31 ADT^A04 — Register a Patient (outpatient).

  Same constraints as A01. PV1-3 still required for bed/location.

  Source: IHE ITI TF-2b §3.31.
  """
  @spec iti_31_adt_a04() :: Profile.t()
  def iti_31_adt_a04 do
    "IHE_ITI-31_ADT_A04"
    |> new_pam({"ADT", "A04"}, "IHE PAM Patient Encounter Management — Register Outpatient")
    |> Profile.require_segment("EVN")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("PV1")
    |> Common.msh_pam_core()
    |> Common.evn_core()
    |> Common.pid_core()
    |> Profile.require_field("PV1", 2)
    |> Profile.require_field("PV1", 3)
  end

  @doc """
  ITI-31 ADT^A08 — Update Patient Information.

  Same baseline as A01 including PV1-3 (the updated visit is still
  referenced). Source: IHE ITI TF-2b §3.31.
  """
  @spec iti_31_adt_a08() :: Profile.t()
  def iti_31_adt_a08 do
    "IHE_ITI-31_ADT_A08"
    |> new_pam(
      {"ADT", "A08"},
      "IHE PAM Patient Encounter Management — Update Patient Information"
    )
    |> Profile.require_segment("EVN")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("PV1")
    |> Common.msh_pam_core()
    |> Common.evn_core()
    |> Common.pid_core()
    |> Profile.require_field("PV1", 2)
    |> Profile.require_field("PV1", 3)
  end

  @doc """
  ITI-31 ADT^A03 — Discharge/End Visit.

  Requires MSH, EVN, PID, PV1. PV1-3 is not required for A03
  (the discharge point is in PV1-45, not the bed). PV1-2 still
  required for the patient class context.

  Source: IHE ITI TF-2b §3.31.
  """
  @spec iti_31_adt_a03() :: Profile.t()
  def iti_31_adt_a03 do
    "IHE_ITI-31_ADT_A03"
    |> new_pam({"ADT", "A03"}, "IHE PAM Patient Encounter Management — Discharge/End Visit")
    |> Profile.require_segment("EVN")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("PV1")
    |> Common.msh_pam_core()
    |> Common.evn_core()
    |> Common.pid_core()
    |> Profile.require_field("PV1", 2)
  end

  @doc """
  ITI-30 ADT^A40 — Merge Patient — Patient ID List.

  Patient-level merge. Belongs to the IHE ITI-30 Patient Identity
  Management transaction, NOT to ITI-31 Patient Encounter
  Management. Requires MSH, EVN, PID, MRG. PV1 is forbidden because
  ITI-30 operates outside a visit context.

  MRG-1 (Prior Patient Identifier List) is required; its Assigning
  Authority should match PID-3's.

  Source: IHE ITI TF-2b §3.30 (Merge Option).
  """
  @spec iti_30_adt_a40() :: Profile.t()
  def iti_30_adt_a40 do
    "IHE_ITI-30_ADT_A40"
    |> new_pam(
      {"ADT", "A40"},
      "IHE PAM Patient Identity Management — Merge Patient ID List"
    )
    |> Profile.require_segment("EVN")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("MRG")
    |> Profile.forbid_segment("PV1")
    |> Common.msh_pam_core()
    |> Common.evn_core()
    |> Common.pid_core()
    |> Profile.require_field("MRG", 1)
  end

  # ------------------------------------------------------------------
  # ITI-30 Patient Identity Management
  # ------------------------------------------------------------------

  @doc """
  ITI-30 ADT^A28 — Add Person Information (no visit context).

  Used when the sender has no visit context for the patient. PV1 is
  still present as a "pseudo-segment" with PV1-2 pinned to `"N"`
  (Not Applicable).

  Source: IHE ITI TF-2b §3.30.
  """
  @spec iti_30_adt_a28() :: Profile.t()
  def iti_30_adt_a28 do
    "IHE_ITI-30_ADT_A28"
    |> new_pam({"ADT", "A28"}, "IHE PAM Patient Identity Management — Create Patient (no visit)")
    |> Profile.require_segment("EVN")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("PV1")
    |> Common.msh_pam_core()
    |> Common.evn_core()
    |> Common.pid_core()
    |> Profile.require_field("PV1", 2)
    |> Common.pin_patient_class("N")
  end

  @doc """
  ITI-30 ADT^A31 — Update Person Information (no visit context).

  Same structure as A28 — PV1-2 pinned to `"N"`.

  Source: IHE ITI TF-2b §3.30.
  """
  @spec iti_30_adt_a31() :: Profile.t()
  def iti_30_adt_a31 do
    "IHE_ITI-30_ADT_A31"
    |> new_pam({"ADT", "A31"}, "IHE PAM Patient Identity Management — Update Patient (no visit)")
    |> Profile.require_segment("EVN")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("PV1")
    |> Common.msh_pam_core()
    |> Common.evn_core()
    |> Common.pid_core()
    |> Profile.require_field("PV1", 2)
    |> Common.pin_patient_class("N")
  end

  @doc """
  Returns the complete PAM profile catalog as a map keyed by
  IHE transaction code.
  """
  @spec all() :: %{String.t() => Profile.t()}
  def all do
    %{
      "ITI-31.A01" => iti_31_adt_a01(),
      "ITI-31.A04" => iti_31_adt_a04(),
      "ITI-31.A08" => iti_31_adt_a08(),
      "ITI-31.A03" => iti_31_adt_a03(),
      "ITI-30.A28" => iti_30_adt_a28(),
      "ITI-30.A31" => iti_30_adt_a31(),
      "ITI-30.A40" => iti_30_adt_a40()
    }
  end

  # ------------------------------------------------------------------
  # Internal
  # ------------------------------------------------------------------

  defp new_pam(name, message_type, description) do
    Profile.new(name,
      message_type: message_type,
      version: "2.5",
      description: description
    )
    |> Profile.require_segment("MSH")
  end
end
