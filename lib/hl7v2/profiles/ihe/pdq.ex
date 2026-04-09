defmodule HL7v2.Profiles.IHE.PDQ do
  @moduledoc """
  IHE Patient Demographics Query (PDQ) conformance profiles.

  Ships factory functions for the two PDQ transactions in the IHE
  ITI Technical Framework Vol 2:

  - **ITI-21 Patient Demographics Query** — demographics-only query,
    `QBP^Q22` request → `RSP^K22` response. Source: IHE ITI TF-2
    §3.21.
  - **ITI-22 Patient Demographics and Visit Query** — demographics
    plus visit information, `QBP^ZV1` request → `RSP^ZV2` response.
    The response carries a `PV1` segment per matched patient.
    Source: IHE ITI TF-2 §3.22.

  Both transactions are defined on HL7 v2.5. QPD-1 (Message Query
  Name) is pinned to `"IHE PDQ Query"` for both transactions — the
  distinction is the trigger event in MSH-9.

  ## Usage

      profile = HL7v2.Profiles.IHE.PDQ.iti_21_query()
      HL7v2.validate(msg, profile: profile)
  """

  alias HL7v2.Profile
  alias HL7v2.Profiles.IHE.Common

  # ------------------------------------------------------------------
  # ITI-21 Patient Demographics Query
  # ------------------------------------------------------------------

  @doc """
  ITI-21 QBP^Q22 — Patient Demographics Query (request).

  Requires MSH, QPD, RCP. QPD-1 pinned to `"IHE PDQ Query"`, RCP-1
  pinned to `"I"` (Immediate). QPD-3 carries the search criteria
  and must be populated with at least one @PID field reference.

  Source: IHE ITI TF-2 §3.21.4.
  """
  @spec iti_21_query() :: Profile.t()
  def iti_21_query do
    "IHE_ITI-21_PDQ_Query"
    |> Profile.new(
      message_type: {"QBP", "Q22"},
      version: "2.5",
      description: "IHE PDQ Query — QBP^Q22 (v2.5)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("QPD")
    |> Profile.require_segment("RCP")
    |> Common.msh_pam_core()
    |> Profile.require_field("QPD", 1)
    |> Profile.require_field("QPD", 2)
    |> Profile.require_field("QPD", 3)
    |> Profile.require_field("RCP", 1)
    |> Profile.require_value("QPD", 1, "IHE PDQ Query", accessor: & &1.identifier)
    |> Profile.require_value("RCP", 1, "I")
  end

  @doc """
  ITI-21 RSP^K22 — Patient Demographics Query Response.

  Requires MSH, MSA, QAK, QPD. PID, PD1 and QRI segments are part
  of the optional per-patient group and are validated as present
  when MSA-1 = AA and QAK-2 = OK.

  MSA-1 ∈ {AA, AE, AR}. QAK-2 ∈ {OK, NF, AE}.

  Source: IHE ITI TF-2 §3.21.4.2.
  """
  @spec iti_21_response() :: Profile.t()
  def iti_21_response do
    "IHE_ITI-21_PDQ_Response"
    |> Profile.new(
      message_type: {"RSP", "K22"},
      version: "2.5",
      description: "IHE PDQ Query Response — RSP^K22 (v2.5)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("MSA")
    |> Profile.require_segment("QAK")
    |> Profile.require_segment("QPD")
    |> Common.msh_pam_core()
    |> Profile.require_field("MSA", 1)
    |> Profile.require_field("QAK", 1)
    |> Profile.require_field("QAK", 2)
    |> Profile.require_value_in("MSA", 1, ~w(AA AE AR))
    |> Profile.require_value_in("QAK", 2, ~w(OK NF AE))
  end

  # ------------------------------------------------------------------
  # ITI-22 Patient Demographics and Visit Query
  # ------------------------------------------------------------------

  @doc """
  ITI-22 QBP^ZV1 — Patient Demographics and Visit Query (request).

  Identical shape to ITI-21 Query except for the trigger event
  (`ZV1` vs `Q22`). Supports additional visit-oriented search
  fields in QPD-3 (PV1.2, PV1.3, PV1.7, etc.).

  QPD-1 is still `"IHE PDQ Query"` (the message name does not
  change between ITI-21 and ITI-22 — the trigger event does).

  Source: IHE ITI TF-2 §3.22.4.
  """
  @spec iti_22_query() :: Profile.t()
  def iti_22_query do
    "IHE_ITI-22_PDQ_Visit_Query"
    |> Profile.new(
      message_type: {"QBP", "ZV1"},
      version: "2.5",
      description: "IHE PDQ + Visit Query — QBP^ZV1 (v2.5)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("QPD")
    |> Profile.require_segment("RCP")
    |> Common.msh_pam_core()
    |> Profile.require_field("QPD", 1)
    |> Profile.require_field("QPD", 2)
    |> Profile.require_field("QPD", 3)
    |> Profile.require_field("RCP", 1)
    |> Profile.require_value("QPD", 1, "IHE PDQ Query", accessor: & &1.identifier)
    |> Profile.require_value("RCP", 1, "I")
  end

  @doc """
  ITI-22 RSP^ZV2 — Patient Demographics and Visit Query Response.

  Like ITI-21 response but each matched patient also carries a PV1
  segment with PV1-2 (Patient Class) populated.

  Source: IHE ITI TF-2 §3.22.4.2.
  """
  @spec iti_22_response() :: Profile.t()
  def iti_22_response do
    "IHE_ITI-22_PDQ_Visit_Response"
    |> Profile.new(
      message_type: {"RSP", "ZV2"},
      version: "2.5",
      description: "IHE PDQ + Visit Query Response — RSP^ZV2 (v2.5)"
    )
    |> Profile.require_segment("MSH")
    |> Profile.require_segment("MSA")
    |> Profile.require_segment("QAK")
    |> Profile.require_segment("QPD")
    |> Common.msh_pam_core()
    |> Profile.require_field("MSA", 1)
    |> Profile.require_field("QAK", 1)
    |> Profile.require_field("QAK", 2)
    |> Profile.require_value_in("MSA", 1, ~w(AA AE AR))
    |> Profile.require_value_in("QAK", 2, ~w(OK NF AE))
  end

  @doc """
  Returns the complete PDQ profile catalog.
  """
  @spec all() :: %{String.t() => Profile.t()}
  def all do
    %{
      "ITI-21.Query" => iti_21_query(),
      "ITI-21.Response" => iti_21_response(),
      "ITI-22.Query" => iti_22_query(),
      "ITI-22.Response" => iti_22_response()
    }
  end
end
