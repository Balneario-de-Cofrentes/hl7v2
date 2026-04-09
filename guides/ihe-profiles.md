# IHE Profile Pack

`HL7v2.Profiles.IHE` ships pre-built conformance profiles for the
most common IHE HL7 v2.x transactions. Each profile encodes the
segment/field/value constraints from the IHE Technical Framework so
you can validate an incoming wire for IHE conformance in three
lines of Elixir:

```elixir
profile = HL7v2.Profiles.IHE.PAM.iti_31_adt_a01()
{:ok, msg} = HL7v2.parse(wire, mode: :typed)
HL7v2.validate(msg, profile: profile)
```

## Coverage

**22 profiles across 5 IHE transactions**:

| Spec | Module | Transaction | Message | Version |
|------|--------|-------------|---------|---------|
| **IHE ITI** | `IHE.PAM` | ITI-31 Patient Encounter Management | ADT^A01, A03, A04, A08 | 2.5 |
| | | ITI-30 Patient Identity Management | ADT^A28, A31, A40 | 2.5 |
| **IHE ITI** | `IHE.PIX` | ITI-8 Patient Identity Feed | ADT^A01, A04, A08, A40 | 2.3.1 |
| | | ITI-9 PIX Query | QBP^Q23 → RSP^K23 | 2.5 |
| | | ITI-10 PIX Update Notification | ADT^A31 | 2.5 |
| **IHE ITI** | `IHE.PDQ` | ITI-21 Patient Demographics Query | QBP^Q22 → RSP^K22 | 2.5 |
| | | ITI-22 PDQ + Visit Query | QBP^ZV1 → RSP^ZV2 | 2.5 |
| **IHE PaLM** | `IHE.LTW` | LAB-1 Placer Order Management | OML^O21 | 2.5.1 |
| | | LAB-3 Order Results Management | ORU^R01 | 2.5.1 |
| **IHE RAD** | `IHE.RadSwf` | RAD-1 Patient Registration | ADT^A01 | 2.3.1 |
| | | RAD-4 Procedure Scheduled | OMI^O23 | 2.5.1 |

Note the **mixed HL7 versions**: ITI-8 PIX Feed and RAD-1 are
defined on HL7 v2.3.1 (they were authored early and have never been
rebased), while the newer query/update transactions use v2.5. LTW
and RAD-4 use v2.5.1. Profile version enforcement gates each
profile so you can load them all on the same listener without
cross-contamination.

Source documents:

- [IHE ITI Technical Framework Vol 2](https://profiles.ihe.net/ITI/TF/)
- IHE PaLM Technical Framework Vol 2a/2x Rev 11.0 (2024-04-08)
- IHE Radiology Technical Framework Vol 2 Rev 13.0 (2014-07-30)

## Usage patterns

### 1. Single-profile validation

Pick the profile by name and pass it to `HL7v2.validate/2`:

```elixir
profile = HL7v2.Profiles.IHE.PAM.iti_31_adt_a01()

case HL7v2.validate(msg, profile: profile) do
  :ok ->
    :conformant

  {:ok, warnings} ->
    Logger.warning("IHE PAM warnings: #{inspect(warnings)}")
    :conformant

  {:error, errors} ->
    Logger.error("IHE PAM errors: #{inspect(errors)}")
    {:non_conformant, errors}
end
```

### 2. Low-level rule-only check

Bypass the validator's other layers and run just the profile rules:

```elixir
alias HL7v2.Validation.ProfileRules

errors = ProfileRules.check(msg, HL7v2.Profiles.IHE.PAM.iti_31_adt_a01())
# [] on success, [%{rule: ..., location: ..., message: ...}, ...] otherwise
```

Each error has a `:rule` atom you can pattern-match on:

- `:require_segment` — a required segment is missing
- `:forbid_segment` — a forbidden segment is present
- `:require_field` — a required field is blank in its segment
- `:forbid_field` — a forbidden field is populated
- `:require_cardinality` — segment occurrence count is out of range
- `:value_constraint` — a field failed its value predicate
- `:custom_rule_exception` — a custom rule raised (never silently
  swallowed)
- Custom atoms like `:pid3_identity` from transaction-specific rules

### 3. Composing with your own site-specific rules

The IHE profile is a normal `%HL7v2.Profile{}` — add your own
constraints on top before validating:

```elixir
profile =
  HL7v2.Profiles.IHE.PAM.iti_31_adt_a01()
  |> HL7v2.Profile.require_segment("AL1")
  |> HL7v2.Profile.require_field("PID", 18)
  |> HL7v2.Profile.add_value_constraint("PV1", 14, fn v ->
    v in ["F", "U", "I"]
  end)
```

## The catalog

```elixir
HL7v2.Profiles.IHE.all()
# %{
#   "ITI-31.A01" => %HL7v2.Profile{...},
#   "ITI-31.A04" => %HL7v2.Profile{...},
#   "ITI-8.A01" => %HL7v2.Profile{...},
#   ...
# }

HL7v2.Profiles.IHE.pam()     # ITI-30 + ITI-31
HL7v2.Profiles.IHE.pix()     # ITI-8 + ITI-9 + ITI-10
HL7v2.Profiles.IHE.pdq()     # ITI-21 + ITI-22
HL7v2.Profiles.IHE.ltw()     # LAB-1 + LAB-3
HL7v2.Profiles.IHE.rad_swf() # RAD-1 + RAD-4
```

### Deployment caveats

The catalog is a **browsing index**, not a dispatch table. Pick
the profile explicitly by name in your integration code:

```elixir
# GOOD — explicit choice
profile = HL7v2.Profiles.IHE.PAM.iti_31_adt_a01()
HL7v2.validate(msg, profile: profile)

# RISKY — multiple profiles can match {"ADT", "A01"}
# (ITI-31 PAM, ITI-8 PIX Feed v2.3.1, RAD-1 v2.3.1)
all_profiles = HL7v2.Profiles.IHE.all() |> Map.values()
Enum.find(all_profiles, &HL7v2.Profile.applies_to?(&1, msg.type))
```

Two deployment pitfalls to be aware of:

1. **Multiple profiles matching the same trigger.** ITI-31 PAM,
   ITI-8 PIX Feed, and RAD-1 all apply to `{"ADT", "A01"}`. Their
   version gates (v2.5 vs v2.3.1 vs v2.3.1) partially disambiguate,
   but if you dispatch by iterating the catalog you will pick the
   first match non-deterministically. Always pick by name.
2. **Version-mismatch silent skip.** A profile with a non-nil
   `:version` that does not match the message's MSH-12 is silently
   skipped (`ProfileRules.check/2` returns `[]`). This is correct
   for single-profile validation but means a catalog-based
   dispatcher can return "zero errors" for a message no profile
   actually validated. Match the profile version to the sender's
   version deliberately.

## Profile catalog by factory

### PAM (Patient Administration Management)

```elixir
HL7v2.Profiles.IHE.PAM.iti_31_adt_a01()  # Admit inpatient
HL7v2.Profiles.IHE.PAM.iti_31_adt_a03()  # Discharge
HL7v2.Profiles.IHE.PAM.iti_31_adt_a04()  # Register outpatient
HL7v2.Profiles.IHE.PAM.iti_31_adt_a08()  # Update patient info
HL7v2.Profiles.IHE.PAM.iti_30_adt_a28()  # Create patient (no visit)
HL7v2.Profiles.IHE.PAM.iti_30_adt_a31()  # Update patient (no visit)
HL7v2.Profiles.IHE.PAM.iti_30_adt_a40()  # Merge patient (patient ID list)
```

All PAM profiles enforce the IHE TF-2b §3.30/§3.31 baseline:

- `MSH-9/10/11/12` required, `MSH-8` (Security) forbidden
- `EVN-2` required
- `PID-5` required
- `PID-3` validated by the `:pid3_identity` custom rule (every
  repetition carries CX-1 ID Number and CX-4 Assigning Authority)
- ITI-31 visit triggers (A01/A04/A08) add `PV1-2`, `PV1-3` required
- ITI-30 no-visit triggers (A28/A31) pin `PV1-2` to `"N"`
- A40 merge forbids `PV1` and requires `MRG` + `MRG-1`

### PIX (Patient Identifier Cross-Reference)

```elixir
HL7v2.Profiles.IHE.PIX.iti_8_feed_a01()   # v2.3.1 feed, admit
HL7v2.Profiles.IHE.PIX.iti_8_feed_a04()   # v2.3.1 feed, outpatient
HL7v2.Profiles.IHE.PIX.iti_8_feed_a08()   # v2.3.1 feed, update
HL7v2.Profiles.IHE.PIX.iti_8_feed_a40()   # v2.3.1 feed, merge
HL7v2.Profiles.IHE.PIX.iti_9_query()      # QBP^Q23 PIX query
HL7v2.Profiles.IHE.PIX.iti_9_response()   # RSP^K23 response
HL7v2.Profiles.IHE.PIX.iti_10_update()    # ADT^A31 PV1-2=N
```

ITI-9 Query pins `QPD-1 = "IHE PIX Query"` and `RCP-1 = "I"`.
ITI-9 Response constrains `MSA-1 ∈ {AA, AE, AR}` and
`QAK-2 ∈ {OK, NF, AE}`.

### PDQ (Patient Demographics Query)

```elixir
HL7v2.Profiles.IHE.PDQ.iti_21_query()     # QBP^Q22 demographics query
HL7v2.Profiles.IHE.PDQ.iti_21_response()  # RSP^K22 response
HL7v2.Profiles.IHE.PDQ.iti_22_query()     # QBP^ZV1 demographics + visit
HL7v2.Profiles.IHE.PDQ.iti_22_response()  # RSP^ZV2 response
```

Same QPD-1/RCP-1/MSA-1/QAK-2 pinning pattern as ITI-9, but with
`"IHE PDQ Query"` as the QPD-1 constant.

### LTW (Laboratory Testing Workflow — IHE PaLM)

```elixir
HL7v2.Profiles.IHE.LTW.lab_1_placer_oml_o21()    # Placer → Filler new order
HL7v2.Profiles.IHE.LTW.lab_3_results_oru_r01()   # Filler → Tracker results
```

LAB-1 requires MSH, PID, PV1, ORC, OBR. `ORC-1` must be a valid
IHE subset code; `ORC-7` and `OBR-5/6/8/15/22/27` are forbidden
(replaced by TQ1 and SPM in the IHE PaLM TF).

LAB-3 additionally requires OBX and constrains `OBR-25` to
`{S, I, R, P, F, C, X}` and `OBX-11` to `{O, I, D, R, P, F, C, X}`
(note `U` is explicitly forbidden). `OBX-9/10/12` are X.

### RAD-SWF (Radiology Scheduled Workflow)

```elixir
HL7v2.Profiles.IHE.RadSwf.rad_1_registration_a01()       # v2.3.1 ADT
HL7v2.Profiles.IHE.RadSwf.rad_4_procedure_scheduled_omi() # v2.5.1 OMI^O23
```

RAD-1 (v2.3.1) adds `PV1-3/7/10/17` and `PID-8` on top of the PAM
baseline — the radiology-specific PV1 requirements for inpatient
admit.

RAD-4 (v2.5.1 Option) uses the `OMI^O23` message with a required
`IPC` segment carrying the DICOM correlation keys (Accession
Identifier, Requested Procedure ID, Study Instance UID, Scheduled
Procedure Step ID, Modality). `ORC-1 = "NW"` and `ORC-5 = "SC"`
are pinned for the new-procedure scheduling flow.

## Extending the pack

If you hit a transaction the pack doesn't cover:

1. Check [`HL7v2.Profile`](https://hexdocs.pm/hl7v2/HL7v2.Profile.html)
   for the builder DSL — `require_segment`, `forbid_segment`,
   `require_field`, `forbid_field`, `bind_table`,
   `require_cardinality`, `add_value_constraint`, `add_rule`.
2. Look at `HL7v2.Profiles.IHE.Common` for shared helpers (MSH
   baseline, EVN baseline, PID-3 identity rule, patient class
   pinning).
3. Pattern-match your new profile on the existing
   `HL7v2.Profiles.IHE.*` modules — especially the `:pid3_identity`
   custom rule, which is the reusable pattern for "every CX
   repetition must carry ID + Assigning Authority".
4. Upstream it! PRs to add more IHE transactions are welcome.

## What this pack is NOT

- Not a stamp of IHE Connectathon certification. Passing these
  profiles means your messages meet the field-level constraints
  from the public IHE TF as of v3.9.0 of this library. Formal
  certification requires testing against the [IHE Gazelle testing
  platform](https://gazelle.ihe.net).
- Not a complete IHE profile catalog. Deferred transactions
  include ITI-9 (PIX Query) v3, XDS-family (ITI-41/42/43), LAB-2
  Filler Order Management, LAB-4 Work Order Management, and
  RAD-12/13. These may land in future releases.
- Not a replacement for reading the IHE TF. The profiles encode
  the public constraints but the TFs contain rationale, option
  profiles, and state-machine details that no declarative profile
  can capture. If you're implementing a full IHE actor, read the
  TF sections cited in each factory's `@doc`.
