defmodule HL7v2.Profiles.IHE.RadSwf do
  @moduledoc """
  IHE Radiology Scheduled Workflow (RAD-SWF) conformance profiles.

  Ships factory functions for the two core radiology order
  transactions from the IHE Radiology Technical Framework Vol 2
  Rev 13.0:

  - **RAD-1 Patient Registration** — ADT^A01 sent from ADT Patient
    Registration to Order Placer, DSS/Order Filler, and optionally
    the MPI. Defined on **HL7 v2.3.1** (RAD-SWF v2.5.1 is an
    optional extension that most sites have not adopted). Source:
    IHE RAD TF-2 §4.1.
  - **RAD-4 Procedure Scheduled** — `OMI^O23` (HL7 v2.5.1 Option).
    DSS/Order Filler → Image Manager/Report Manager when the
    Requested Procedure with a given Study Instance UID has not
    been transmitted before. Source: IHE RAD TF-2 §4.4.

  Note the version mix: RAD-1 is v2.3.1, RAD-4 is v2.5.1.

  ## Usage

      profile = HL7v2.Profiles.IHE.RadSwf.rad_1_registration_a01()
      HL7v2.validate(msg, profile: profile)
  """

  alias HL7v2.Profile
  alias HL7v2.Profiles.IHE.Common

  # ------------------------------------------------------------------
  # RAD-1 Patient Registration — HL7 v2.3.1
  # ------------------------------------------------------------------

  @doc """
  RAD-1 ADT^A01 — Patient Registration (Admit Inpatient).

  HL7 v2.3.1. Requires MSH, EVN, PID, PV1. Beyond the IHE PAM
  baseline, RAD-1 adds:

  - PID-8 (Administrative Sex) R
  - PV1-3 (Assigned Patient Location) R for A01
  - PV1-7 (Attending Doctor) R for A01
  - PV1-10 (Hospital Service) R for A01
  - PV1-17 (Admitting Doctor) R for A01

  Source: IHE RAD TF-2 §4.1.
  """
  @spec rad_1_registration_a01() :: Profile.t()
  def rad_1_registration_a01 do
    "IHE_RAD-1_ADT_A01"
    |> Profile.new(
      message_type: {"ADT", "A01"},
      version: "2.3.1",
      description: "IHE RAD-1 Patient Registration — Admit Inpatient (v2.3.1)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("EVN")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("PV1")
    |> Profile.require_field("MSH", 9)
    |> Profile.require_field("MSH", 10)
    |> Profile.require_field("MSH", 12)
    |> Profile.require_field("EVN", 2)
    |> Common.pid_core()
    |> Profile.require_field("PID", 8)
    |> Profile.require_field("PV1", 2)
    |> Profile.require_field("PV1", 3)
    |> Profile.require_field("PV1", 7)
    |> Profile.require_field("PV1", 10)
    |> Profile.require_field("PV1", 17)
  end

  # ------------------------------------------------------------------
  # RAD-4 Procedure Scheduled — HL7 v2.5.1 OMI^O23
  # ------------------------------------------------------------------

  @doc """
  RAD-4 OMI^O23 — Procedure Scheduled (HL7 v2.5.1 Option).

  Sent once per Requested Procedure with a new Study Instance UID.
  Requires MSH, PID, PV1, ORC, TQ1, OBR, IPC. ORC-1 must be `"NW"`
  (New) and ORC-5 must be `"SC"` (Scheduled). TQ1-7 carries the
  Scheduled Procedure Step start date/time (replaces the
  deprecated ORC-7.4 / OBR-27.4).

  The IPC segment carries the DICOM correlation keys:
  - IPC-1 Accession Identifier
  - IPC-2 Requested Procedure ID
  - IPC-3 **Study Instance UID** (the immutable correlation key)
  - IPC-4 Scheduled Procedure Step ID
  - IPC-5 Modality

  NOTE: Unlike LAB-1/LAB-3, RAD-4 does NOT forbid OBR-15
  (Specimen Source). Image-guided biopsy and interventional
  radiology workflows legitimately populate OBR-15.

  Source: IHE RAD TF-2 §4.4 (v2.5.1 Option).
  """
  @spec rad_4_procedure_scheduled_omi() :: Profile.t()
  def rad_4_procedure_scheduled_omi do
    "IHE_RAD-4_OMI_O23"
    |> Profile.new(
      message_type: {"OMI", "O23"},
      version: "2.5.1",
      description: "IHE RAD-4 Procedure Scheduled — OMI^O23 (v2.5.1)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("PV1")
    |> Profile.require_segment("ORC")
    |> Profile.require_segment("TQ1")
    |> Profile.require_segment("OBR")
    |> Profile.require_segment("IPC")
    |> Common.msh_pam_core()
    |> Common.pid_core()
    |> Profile.require_field("PID", 8)
    |> Profile.require_field("PV1", 2)
    |> Profile.require_field("ORC", 1)
    |> Profile.require_field("ORC", 3)
    |> Profile.require_field("ORC", 5)
    |> Profile.require_field("TQ1", 7)
    |> Profile.require_field("OBR", 1)
    |> Profile.require_field("OBR", 3)
    |> Profile.require_field("OBR", 4)
    |> Profile.require_field("IPC", 1)
    |> Profile.require_field("IPC", 2)
    |> Profile.require_field("IPC", 3)
    |> Profile.require_field("IPC", 4)
    |> Profile.require_field("IPC", 5)
    |> Profile.forbid_field("ORC", 7)
    |> Profile.forbid_field("OBR", 27)
    |> Profile.add_value_constraint("ORC", 1, &orc_1_is_new/1)
    |> Profile.add_value_constraint("ORC", 5, &orc_5_is_scheduled/1)
  end

  @doc """
  Returns the complete RAD-SWF profile catalog.
  """
  @spec all() :: %{String.t() => Profile.t()}
  def all do
    %{
      "RAD-1" => rad_1_registration_a01(),
      "RAD-4" => rad_4_procedure_scheduled_omi()
    }
  end

  # ------------------------------------------------------------------
  # Value constraint helpers
  # ------------------------------------------------------------------

  defp orc_1_is_new("NW"), do: true

  defp orc_1_is_new(other),
    do: {:error, "ORC-1 must be 'NW' for RAD-4 Procedure Scheduled, got #{inspect(other)}"}

  defp orc_5_is_scheduled("SC"), do: true

  defp orc_5_is_scheduled(other),
    do: {:error, "ORC-5 must be 'SC' for RAD-4 Procedure Scheduled, got #{inspect(other)}"}
end
