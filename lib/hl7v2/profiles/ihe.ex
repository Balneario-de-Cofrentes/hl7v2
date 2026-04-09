defmodule HL7v2.Profiles.IHE do
  @moduledoc """
  Pre-built IHE conformance profiles for HL7 v2.x transactions.

  Each profile is a `%HL7v2.Profile{}` preconfigured with the
  constraints from the IHE Technical Framework for its transaction.
  Use them directly with `HL7v2.validate/2` or
  `HL7v2.Validation.ProfileRules.check/2`.

  ## Coverage

  This module ships profiles across five IHE specifications:

  | Spec | Category | Transactions |
  |---|---|---|
  | **IHE ITI** | PAM (Patient Administration Management) | ITI-30, ITI-31 |
  | **IHE ITI** | PIX (Patient Identifier Cross-Reference) | ITI-8, ITI-9, ITI-10 |
  | **IHE ITI** | PDQ (Patient Demographics Query) | ITI-21, ITI-22 |
  | **IHE PaLM** | LTW (Laboratory Testing Workflow) | LAB-1, LAB-3 |
  | **IHE RAD** | SWF (Scheduled Workflow) | RAD-1, RAD-4 |

  See the individual sub-modules (`HL7v2.Profiles.IHE.PAM`,
  `HL7v2.Profiles.IHE.PIX`, etc.) for the transaction-level factory
  functions.

  ## Example

      profile = HL7v2.Profiles.IHE.PAM.iti_31_adt_a01()
      {:ok, msg} = HL7v2.parse(wire, mode: :typed)
      HL7v2.validate(msg, profile: profile)

  Or look up by IHE transaction code:

      catalog = HL7v2.Profiles.IHE.all()
      profile = Map.fetch!(catalog, "ITI-31.A01")

  ## Disclaimer

  The profiles encode the public constraints from the IHE Technical
  Framework Volume 2 documents at the time of this release. IHE
  updates its TFs regularly — consult the latest published version
  at [profiles.ihe.net](https://profiles.ihe.net) for any
  clarification, and feel free to compose additional constraints on
  top of these profiles with the full `HL7v2.Profile` DSL.
  """

  alias HL7v2.Profile
  alias HL7v2.Profiles.IHE.{PAM, PIX}

  @doc """
  Returns the full IHE profile catalog as a map keyed by IHE
  transaction code (e.g. `"ITI-31.A01"`, `"LAB-3"`, `"RAD-4"`).

  The exact set grows over time. Callers should not assume the
  cardinality is fixed.
  """
  @spec all() :: %{String.t() => Profile.t()}
  def all do
    pam()
    |> Map.merge(pix())
  end

  @doc """
  Returns the PAM (Patient Administration Management) profile
  catalog — ITI-30 and ITI-31 transactions.
  """
  @spec pam() :: %{String.t() => Profile.t()}
  def pam, do: PAM.all()

  @doc """
  Returns the PIX (Patient Identifier Cross-Reference) profile
  catalog — ITI-8 (Feed, v2.3.1), ITI-9 (Query/Response, v2.5),
  and ITI-10 (Update Notification, v2.5).
  """
  @spec pix() :: %{String.t() => Profile.t()}
  def pix, do: PIX.all()
end
