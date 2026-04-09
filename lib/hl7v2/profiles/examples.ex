defmodule HL7v2.Profiles.Examples do
  @moduledoc """
  Example conformance profiles demonstrating common integrator patterns.

  These are starting points — real profiles should be customized to your
  organization's specific constraints. Use `HL7v2.Profile` directly for
  full control over rule composition.
  """

  alias HL7v2.Profile

  @doc """
  A strict hospital ADT_A01 profile that enforces common real-world
  constraints beyond the base v2.5.1 spec:

  - NK1 (next of kin) segment required
  - PID-18 (patient account number) must be populated
  - PV1-3 (assigned patient location) must be populated
  - Patient class (PV1-2) must be one of Inpatient/Outpatient/Emergency
  - At least one DG1 (diagnosis) segment required

  ## Example

      profile = HL7v2.Profiles.Examples.hospital_adt_a01()
      HL7v2.validate(msg, profile: profile)
  """
  @spec hospital_adt_a01() :: Profile.t()
  def hospital_adt_a01 do
    Profile.new("Hospital_ADT_A01",
      message_type: {"ADT", "A01"},
      version: "2.5.1",
      description:
        "Strict hospital ADT_A01 profile enforcing NK1, PID-18, PV1-3, " <>
          "valid patient_class, and at least one DG1"
    )
    |> Profile.require_segment("NK1")
    |> Profile.require_field("PID", 18)
    |> Profile.require_field("PV1", 3)
    |> Profile.add_value_constraint("PV1", 2, fn
      value when is_binary(value) -> value in ["I", "O", "E"]
      _ -> {:error, "patient_class must be I/O/E"}
    end)
    |> Profile.require_cardinality("DG1", min: 1, max: :unbounded)
  end

  @doc """
  An IHE-style ORU_R01 lab results profile enforcing common constraints:

  - OBR (observation request) required
  - At least one OBX (observation result) segment
  - OBR-4 (universal service identifier) must be populated
  - OBX-3 (observation identifier) must be populated
  - OBX-11 (observation result status) must be populated with a valid code

  ## Example

      profile = HL7v2.Profiles.Examples.ihe_lab_oru_r01()
      HL7v2.validate(msg, profile: profile)
  """
  @spec ihe_lab_oru_r01() :: Profile.t()
  def ihe_lab_oru_r01 do
    Profile.new("IHE_LAB_ORU_R01",
      message_type: {"ORU", "R01"},
      version: "2.5.1",
      description:
        "IHE-style lab results profile: OBR required, at least one OBX, " <>
          "OBR-4/OBX-3/OBX-11 populated with valid result status"
    )
    |> Profile.require_segment("OBR")
    |> Profile.require_cardinality("OBX", min: 1, max: :unbounded)
    |> Profile.require_field("OBR", 4)
    |> Profile.require_field("OBX", 3)
    |> Profile.require_field("OBX", 11)
    |> Profile.add_value_constraint("OBX", 11, fn
      value when is_binary(value) -> value in ["F", "P", "C", "X", "R", "S", "I", "D", "U"]
      _ -> {:error, "observation_result_status must be a valid HL7 table 0085 code"}
    end)
  end
end
