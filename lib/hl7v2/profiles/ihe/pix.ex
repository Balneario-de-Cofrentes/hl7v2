defmodule HL7v2.Profiles.IHE.PIX do
  @moduledoc """
  IHE Patient Identifier Cross-Reference (PIX) conformance profiles.

  Ships factory functions for the three PIX transactions in the IHE
  ITI Technical Framework Vol 2:

  - **ITI-8 Patient Identity Feed** — `ADT^A01/A04/A08/A40` sent from
    a Patient Identity Source to a PIX Manager or XDS Document
    Registry. Defined on **HL7 v2.3.1** (PIX is one of the earliest
    IHE profiles and its version has not been rebased). Source:
    IHE ITI TF-2 §3.8.
  - **ITI-9 PIX Query** — `QBP^Q23` request / `RSP^K23` response.
    Defined on HL7 v2.5. Source: IHE ITI TF-2 §3.9.
  - **ITI-10 PIX Update Notification** — `ADT^A31` with PV1-2 pinned
    to `"N"`. Defined on HL7 v2.5. Source: IHE ITI TF-2 §3.10.

  Note the version mix: ITI-8 is the only PIX transaction on v2.3.1.
  The profile DSL gates each profile by both message type AND
  version, so an ITI-8 v2.3.1 feed profile will not accidentally
  match a v2.5 ADT^A01.

  ## Usage

      profile = HL7v2.Profiles.IHE.PIX.iti_8_feed_a01()
      HL7v2.validate(msg, profile: profile)
  """

  alias HL7v2.Profile
  alias HL7v2.Profiles.IHE.Common

  # ------------------------------------------------------------------
  # ITI-8 Patient Identity Feed — HL7 v2.3.1
  # ------------------------------------------------------------------

  @doc """
  ITI-8 ADT^A01 Patient Identity Feed — Admit Inpatient. HL7 v2.3.1.
  Source: IHE ITI TF-2 §3.8.
  """
  @spec iti_8_feed_a01() :: Profile.t()
  def iti_8_feed_a01 do
    new_pix_feed({"ADT", "A01"}, "A01", "Admit Inpatient")
  end

  @doc """
  ITI-8 ADT^A04 Patient Identity Feed — Register Outpatient.
  HL7 v2.3.1. Source: IHE ITI TF-2 §3.8.
  """
  @spec iti_8_feed_a04() :: Profile.t()
  def iti_8_feed_a04 do
    new_pix_feed({"ADT", "A04"}, "A04", "Register Outpatient")
  end

  @doc """
  ITI-8 ADT^A08 Patient Identity Feed — Update Patient Information.
  HL7 v2.3.1. Source: IHE ITI TF-2 §3.8.
  """
  @spec iti_8_feed_a08() :: Profile.t()
  def iti_8_feed_a08 do
    new_pix_feed({"ADT", "A08"}, "A08", "Update Patient Information")
  end

  @doc """
  ITI-8 ADT^A40 Patient Identity Feed — Merge Patient.
  HL7 v2.3.1. Requires MRG segment and MRG-1 populated.
  Source: IHE ITI TF-2 §3.8.
  """
  @spec iti_8_feed_a40() :: Profile.t()
  def iti_8_feed_a40 do
    "IHE_ITI-8_ADT_A40"
    |> Profile.new(
      message_type: {"ADT", "A40"},
      version: "2.3.1",
      description: "IHE PIX Patient Identity Feed — Merge Patient (v2.3.1)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("EVN")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("MRG")
    |> Profile.require_field("MSH", 9)
    |> Profile.require_field("MSH", 10)
    |> Profile.require_field("MSH", 12)
    |> Common.pid_core()
    |> Profile.require_field("MRG", 1)
  end

  # ------------------------------------------------------------------
  # ITI-9 PIX Query — HL7 v2.5
  # ------------------------------------------------------------------

  @doc """
  ITI-9 QBP^Q23 — PIX Query. HL7 v2.5.

  Requires MSH, QPD, RCP. QPD-1 is pinned to `"IHE PIX Query"` and
  RCP-1 is pinned to `"I"` (Immediate mode). QPD-3 (Person
  Identifier) must be populated.

  Source: IHE ITI TF-2 §3.9.
  """
  @spec iti_9_query() :: Profile.t()
  def iti_9_query do
    "IHE_ITI-9_PIX_Query"
    |> Profile.new(
      message_type: {"QBP", "Q23"},
      version: "2.5",
      description: "IHE PIX Query — QBP^Q23 (v2.5)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("QPD")
    |> Profile.require_segment("RCP")
    |> Common.msh_pam_core()
    |> Profile.require_field("QPD", 1)
    |> Profile.require_field("QPD", 2)
    |> Profile.require_field("QPD", 3)
    |> Profile.require_field("RCP", 1)
    |> Profile.add_value_constraint("QPD", 1, &qpd_1_matches_pix_query/1)
    |> Profile.add_value_constraint("RCP", 1, &rcp_1_is_immediate/1)
  end

  @doc """
  ITI-9 RSP^K23 — PIX Query Response. HL7 v2.5.

  Requires MSH, MSA, QAK, QPD. PID is optional — present only when
  patient IDs were found. QAK-2 carries the response status (OK,
  NF, AE per IHE ITI TF-2 §3.9.4.2).

  Source: IHE ITI TF-2 §3.9.
  """
  @spec iti_9_response() :: Profile.t()
  def iti_9_response do
    "IHE_ITI-9_PIX_Response"
    |> Profile.new(
      message_type: {"RSP", "K23"},
      version: "2.5",
      description: "IHE PIX Query Response — RSP^K23 (v2.5)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("MSA")
    |> Profile.require_segment("QAK")
    |> Profile.require_segment("QPD")
    |> Common.msh_pam_core()
    |> Profile.require_field("MSA", 1)
    |> Profile.require_field("QAK", 1)
    |> Profile.require_field("QAK", 2)
    |> Profile.add_value_constraint("MSA", 1, &msa_1_is_valid_ack/1)
    |> Profile.add_value_constraint("QAK", 2, &qak_2_is_valid_status/1)
  end

  # ------------------------------------------------------------------
  # ITI-10 PIX Update Notification — HL7 v2.5
  # ------------------------------------------------------------------

  @doc """
  ITI-10 ADT^A31 — PIX Update Notification. HL7 v2.5.

  Sent by the PIX Manager when a patient's cross-reference set
  changes. PV1-2 is pinned to `"N"` (Not Applicable) because the
  notification is sent outside a visit context. The PIX Manager
  returns a single space for PID-5 to avoid domain-specific name
  conflicts (this is a recommendation, not a hard rule here).

  Source: IHE ITI TF-2 §3.10.
  """
  @spec iti_10_update() :: Profile.t()
  def iti_10_update do
    "IHE_ITI-10_PIX_Update"
    |> Profile.new(
      message_type: {"ADT", "A31"},
      version: "2.5",
      description: "IHE PIX Update Notification — ADT^A31 (v2.5)"
    )
    |> Profile.require_segment("MSH")
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
  Returns the complete PIX profile catalog.
  """
  @spec all() :: %{String.t() => Profile.t()}
  def all do
    %{
      "ITI-8.A01" => iti_8_feed_a01(),
      "ITI-8.A04" => iti_8_feed_a04(),
      "ITI-8.A08" => iti_8_feed_a08(),
      "ITI-8.A40" => iti_8_feed_a40(),
      "ITI-9.Query" => iti_9_query(),
      "ITI-9.Response" => iti_9_response(),
      "ITI-10" => iti_10_update()
    }
  end

  # ------------------------------------------------------------------
  # Internal
  # ------------------------------------------------------------------

  # Shared builder for ITI-8 Feed A01/A04/A08 (non-merge variants).
  defp new_pix_feed({_code, event} = message_type, event, trigger_description) do
    "IHE_ITI-8_ADT_#{event}"
    |> Profile.new(
      message_type: message_type,
      version: "2.3.1",
      description: "IHE PIX Patient Identity Feed — #{trigger_description} (v2.3.1)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("EVN")
    |> Profile.require_segment("PID")
    |> Profile.require_segment("PV1")
    |> Profile.require_field("MSH", 9)
    |> Profile.require_field("MSH", 10)
    |> Profile.require_field("MSH", 12)
    |> Common.pid_core()
  end

  # QPD-1 pin helpers — QPD-1 is a CE (Coded Element) whose first
  # component (identifier) carries the query name per IHE ITI TF-2 §3.9.
  defp qpd_1_matches_pix_query(%HL7v2.Type.CE{identifier: "IHE PIX Query"}), do: true

  defp qpd_1_matches_pix_query(other),
    do: {:error, "QPD-1 must be CE with identifier 'IHE PIX Query', got #{inspect(other)}"}

  defp rcp_1_is_immediate("I"), do: true

  defp rcp_1_is_immediate(other),
    do: {:error, "RCP-1 must be 'I' (Immediate) for IHE PIX Query, got #{inspect(other)}"}

  # IHE ITI TF-2 §3.9.4.2 — valid MSA-1 Acknowledgment Code values
  # for an RSP^K23 response are AA, AE, AR (Accept, Error, Reject).
  @msa_ack_codes ~w(AA AE AR)
  defp msa_1_is_valid_ack(code) when is_binary(code) and code in @msa_ack_codes, do: true

  defp msa_1_is_valid_ack(other),
    do: {:error, "MSA-1 must be one of #{inspect(@msa_ack_codes)}, got #{inspect(other)}"}

  # IHE ITI TF-2 §3.9.4.2 — valid QAK-2 Query Response Status values
  # for a PIX Query Response are OK (found), NF (not found), and AE
  # (application error).
  @qak_statuses ~w(OK NF AE)
  defp qak_2_is_valid_status(code) when is_binary(code) and code in @qak_statuses, do: true

  defp qak_2_is_valid_status(other),
    do: {:error, "QAK-2 must be one of #{inspect(@qak_statuses)}, got #{inspect(other)}"}
end
