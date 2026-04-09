# Changelog

All notable changes to this project will be documented in this file.

## v3.10.1 — 2026-04-09

### Fixed

- `mix docs` now builds cleanly. `HL7v2.Profile.ComponentAccess`
  was marked `@moduledoc false` in v3.10.0 but referenced from
  public docstrings in `HL7v2.Profile.require_component/5`,
  `HL7v2.Profile.bind_table/4`, `guides/conformance-profiles.md`,
  and the v3.10.0 CHANGELOG entry — producing "documentation
  references module ... but it is hidden" warnings on every
  docs build. Promoted `ComponentAccess` to a public module with
  a full `@moduledoc` that lists the registered composite types
  (CX, HD, CE, CWE) and explains how to extend the registry.
  Zero behavior change.

## v3.10.0 — 2026-04-09

### Profile DSL polish release

Closes the deferred HIGH and MEDIUM findings from the v3.9.0 iter-1
audit that were worked around with custom-rule closures in the IHE
Profile Pack. The DSL is now substantially more declarative —
profiles built with v3.10 are introspectable, diffable, and (in
principle) serializable. The IHE profile modules shipped with
v3.9.0 have been migrated end-to-end and dropped ~135 net lines of
bespoke helper code.

### Added — declarative value pins

- **`HL7v2.Profile.require_value/5`** — pin a field to an expected
  equality value. Supports an optional `:accessor` 1-arity function
  for struct-component matching (e.g. pinning the `identifier`
  component of a CE without a closure).

  ```elixir
  profile
  |> HL7v2.Profile.require_value("PV1", 2, "N")
  |> HL7v2.Profile.require_value("QPD", 1, "IHE PIX Query",
       accessor: & &1.identifier)
  ```

- **`HL7v2.Profile.require_value_in/5`** — pin a field to an
  allowed-value list.

  ```elixir
  profile
  |> HL7v2.Profile.require_value_in("MSA", 1, ["AA", "AE", "AR"])
  ```

Fires a new `:require_value` rule on mismatch or blank. Error
messages include both expected and actual values. The rule is data
— the profile's `required_values` field is a plain map, not a
closure store.

### Added — declarative component/subcomponent targeting

- **`HL7v2.Profile.require_component/5`** — target a specific
  component (and optionally subcomponent) within a composite field.
  Supports `:each_repetition`, `:subcomponent`, and `:repetition`
  options.

  ```elixir
  # "Every PID-3 repetition must carry CX-1 (ID Number)"
  profile
  |> HL7v2.Profile.require_component("PID", 3, 1,
       each_repetition: true)

  # "Every PID-3 repetition must carry CX-4.1 (HD namespace_id)"
  profile
  |> HL7v2.Profile.require_component("PID", 3, 4,
       each_repetition: true, subcomponent: 1)
  ```

Fires a new `:require_component` rule. Error messages follow the
`segment-field[repetition].component.subcomponent` format, e.g.
`"profile requires PID-3[2].4.1 to be populated"`.

Backed by a new `HL7v2.Profile.ComponentAccess` helper that maps
composite type modules to their canonical component field order.
Registered for **CX, HD, CE, CWE** — the composites referenced by
the shipped IHE profiles. Adding a new composite type is a
one-line entry. A compile-time guard raises if a declared field
is missing from the type's defstruct, preventing silent drift.

### Added — `bind_table/4` enforcement

`Profile.bind_table/4` was stored-but-ignored before v3.10.
Profiles declared table bindings that had no effect at validation
time — documented-as-feature-but-silently-ignored. Now fully
enforced against `HL7v2.Standard.Tables`:

```elixir
profile
|> HL7v2.Profile.bind_table("PV1", 2, "0004")

# At validation time, PV1-2 must be in HL7 table 0004
# (Patient Class): I, O, E, P, R, B, C, N, U.
# Anything else → :bind_table error.
```

- Table ID forms accepted: integer (`4`), plain string (`"4"`),
  zero-padded string (`"0004"`), atom (`:"0004"`).
- Coded-struct unwrapping: CE, CWE, CX, HD, and any other composite
  registered in `HL7v2.Profile.ComponentAccess` have their first
  component extracted before the table lookup.
- Unknown numeric table IDs silently pass (matches the existing
  `HL7v2.Standard.Tables.validate/2` semantics).
- Non-numeric table IDs (site-local codes) are silently skipped —
  only HL7 standard numeric tables are currently enforced.

### Changed (breaking) — `bind_table/4` now fires errors

Profiles that relied on the pre-v3.10 silent-success behavior will
now produce `:bind_table` errors at validation time. If this is
unwanted, delete the `bind_table` call from the profile definition.

### Changed (breaking) — custom rule exceptions surface as errors

Already landed in v3.9.0 but worth repeating for anyone skipping
versions: a `Profile.add_rule/3` closure that raises no longer
silently returns `[]`. It surfaces as a
`%{rule: :custom_rule_exception}` error with the rule name and the
exception message. Preserves the zero-silent-failures stance.

### Internal — IHE Profile Pack migrated to the new DSL

Every shipped `HL7v2.Profiles.IHE.*` module was migrated to use the
new declarative builders. Net **-135 lines** across 5 modules,
zero behavior change:

- **`HL7v2.Profiles.IHE.Common.pid_core/1`** — the ~60-line
  `pid3_identity_rule/1` custom rule was split: CX-1 (ID Number)
  validation moved to `require_component`, a much smaller ~25-line
  `:pid3_assigning_authority` custom rule remains for the
  `HD.namespace_id` OR `HD.universal_id` disjunction. Rule atom
  renamed to reflect the narrower scope.
- **`HL7v2.Profiles.IHE.PIX`, `.PDQ`** — ITI-9/21/22 query/response
  closures (`qpd_1_matches_*`, `rcp_1_is_immediate`,
  `msa_1_is_valid_ack`, `qak_2_is_valid_status`) all replaced with
  `require_value` / `require_value_in` calls. ~56 lines deleted
  across both modules.
- **`HL7v2.Profiles.IHE.LTW`** — LAB-1 ORC-1 and LAB-3 OBR-25 /
  OBX-11 value constraint closures replaced with
  `require_value_in`. ~25 lines deleted.
- **`HL7v2.Profiles.IHE.RadSwf`** — RAD-4 ORC-1 = "NW" and
  ORC-5 = "SC" closures replaced with `require_value`. ~12 lines
  deleted.
- **`HL7v2.Profiles.IHE.Common.pin_patient_class/2`** — now a
  one-line wrapper around `Profile.require_value("PV1", 2, expected)`.

### Documentation

- **`guides/conformance-profiles.md`** — full DSL reference table
  with examples for value pins, component targeting, and bind_table
  enforcement. Escape-hatch section explains when to use
  `add_value_constraint/4` vs `add_rule/3`.
- **`HL7v2.Validation.ProfileRules` moduledoc** — added a
  `## "Blank" semantics` section documenting the recursive
  `blank?/1` contract that several rules share.

### Deferred to v3.11

- `require_component` with `each_repetition: false` default
  silently validates only repetition 1 on a repeating field.
  Changing the default is breaking; documented the foot-gun.
- `custom_rules` LIFO execution order is undocumented.
- `blank?/1` fallback treats unknown terms as populated.
- `ProfileRules` is O(n²) — rebuilds the segment index per check.
  Not a bottleneck for typical profile sizes.
- Per-CX "namespace_id OR universal_id" disjunction — the one
  remaining custom rule in the IHE Common module. Could be
  expressed with a `require_any_of_components/3` primitive but
  not worth the DSL surface for one rule.

### Stats

5,140 tests (511 doctests + 32 properties + 4,597 tests),
0 failures.

## v3.9.0 — 2026-04-09

### Added — IHE Profile Pack

22 pre-built IHE conformance profiles covering the most common
HL7 v2.x transactions from IHE ITI, IHE PaLM (Lab), and IHE RAD
Technical Frameworks. `HL7v2.Profiles.IHE.*` lets integrators
validate IHE conformance in three lines:

```elixir
profile = HL7v2.Profiles.IHE.PAM.iti_31_adt_a01()
{:ok, msg} = HL7v2.parse(wire, mode: :typed)
HL7v2.validate(msg, profile: profile)
```

**PAM** (`HL7v2.Profiles.IHE.PAM`) — Patient Administration
Management. Source: IHE ITI TF-2b §3.30/§3.31.

- `iti_31_adt_a01` Admit Inpatient
- `iti_31_adt_a03` Discharge
- `iti_31_adt_a04` Register Outpatient
- `iti_31_adt_a08` Update Patient Information
- `iti_30_adt_a28` Create Patient (no visit)
- `iti_30_adt_a31` Update Patient (no visit)
- `iti_30_adt_a40` Merge Patient ID List

**PIX** (`HL7v2.Profiles.IHE.PIX`) — Patient Identifier
Cross-Reference. Source: IHE ITI TF-2 §3.8/§3.9/§3.10.

- `iti_8_feed_a01/a04/a08/a40` Patient Identity Feed (v2.3.1)
- `iti_9_query` PIX Query `QBP^Q23`
- `iti_9_response` PIX Response `RSP^K23`
- `iti_10_update` PIX Update Notification `ADT^A31`

**PDQ** (`HL7v2.Profiles.IHE.PDQ`) — Patient Demographics Query.
Source: IHE ITI TF-2 §3.21/§3.22.

- `iti_21_query` Demographics Query `QBP^Q22`
- `iti_21_response` Demographics Response `RSP^K22`
- `iti_22_query` Demographics + Visit Query `QBP^ZV1`
- `iti_22_response` Visit Response `RSP^ZV2`

**LTW** (`HL7v2.Profiles.IHE.LTW`) — Laboratory Testing Workflow.
Source: IHE PaLM TF-2a §3.1/§3.3 (Rev 11.0, 2024-04-08).

- `lab_1_placer_oml_o21` Placer Order Management `OML^O21`
- `lab_3_results_oru_r01` Order Results Management `ORU^R01`

**RAD-SWF** (`HL7v2.Profiles.IHE.RadSwf`) — Radiology Scheduled
Workflow. Source: IHE RAD TF-2 Rev 13.0 §4.1/§4.4.

- `rad_1_registration_a01` Patient Registration `ADT^A01` (v2.3.1)
- `rad_4_procedure_scheduled_omi` Procedure Scheduled `OMI^O23` (v2.5.1)

**Shared building blocks** in `HL7v2.Profiles.IHE.Common`:

- `msh_pam_core/1` — MSH-9/10/11/12 required, MSH-8 forbidden
- `evn_core/1` — EVN-2 required
- `pid_core/1` — PID-5 required + `:pid3_identity` custom rule
  that validates every PID-3 repetition has CX-1 (ID Number)
  and CX-4 (Assigning Authority) populated
- `pin_patient_class/2` — sugar for ITI-30/ITI-10 PV1-2 = "N"

**Mixed HL7 versions are supported**: ITI-8 PIX Feed and RAD-1 use
v2.3.1 (the earliest IHE profiles, never rebased), while ITI-9/10,
PDQ, LTW, and RAD-4 use v2.5 or v2.5.1. Profile version enforcement
gates each profile so cross-version mismatches are silently skipped
rather than flagged as false positives.

**Top-level catalog**: `HL7v2.Profiles.IHE.all/0` returns all 22
profiles keyed by IHE transaction code. Sub-catalogs exposed as
`pam/0`, `pix/0`, `pdq/0`, `ltw/0`, `rad_swf/0`.

### Added — DSL extension: `Profile.forbid_field/3`

IHE profiles frequently mark base-HL7 fields as "X" (not
supported). `HL7v2.Profile` gains a new builder:

```elixir
HL7v2.Profile.new("p")
|> HL7v2.Profile.forbid_field("MSH", 8)   # MSH-8 Security forbidden
|> HL7v2.Profile.forbid_field("EVN", 1)
```

The matching `:forbid_field` rule in `HL7v2.Validation.ProfileRules`
fires when the named field is present with a non-blank value.
Missing segments are silently ignored (use `require_segment/2` if
absence should also be an error).

### Changed (breaking) — Profile version enforcement is now active

`HL7v2.Profile.version` was previously stored but never enforced —
an ITI-8 v2.3.1 profile would silently validate a v2.5 feed,
producing false-positive errors because field sequence numbers can
drift between versions. `ProfileRules.check/2` now compares
`profile.version` against the message's MSH-12 version; mismatched
versions cause the profile to return `[]` (not applicable) instead
of running its rules.

**Migration**: if your code depended on the old silent-ignore
behavior, either pass a profile with `version: nil` (wildcard) or
match the profile version to your sender.

### Changed (breaking) — Custom rule exceptions surface as errors

A custom rule added via `Profile.add_rule/3` that raises no longer
silently returns `[]`. It now surfaces as a
`%{rule: :custom_rule_exception}` error containing the rule name
and the exception message, preventing buggy rules from silently
passing every message.

**Migration**: if you had a test asserting `ProfileRules.check/2`
returned `[]` for a raising rule (indicating the rule was swallowed),
update it to assert the synthetic error is present.

### Guides

New [`guides/ihe-profiles.md`](guides/ihe-profiles.md) walks
through the pack with usage examples, a transaction coverage
table, deployment caveats for the catalog dispatch patterns, and
a list of IHE TF sources.

### Stats

5,102 tests (505 doctests + 32 properties + 4,565 tests),
0 failures.

## v3.8.0 — 2026-04-09

### Added — v2.6 Materials Management Segments

Eight new typed segment modules covering HL7 v2.6 Chapter 17
(Materials Management). Supply-chain and sterilization flows that
arrive with these segments now parse as typed structs instead of
landing in `extra_fields`.

- **`HL7v2.Segment.ITM`** — Material Item Master. 18 fields.
  Canonical material item identity, manufacturer, category,
  regulatory flags, and cost data.
- **`HL7v2.Segment.IVT`** — Material Location. 26 fields.
  Per-location stocking policy: bin, par levels, reorder points,
  reusable/consignment flags, substitutes.
- **`HL7v2.Segment.ILT`** — Material Lot. 10 fields. Lot-level
  tracking — expiration, received date/quantity, on-hand quantity,
  lot cost — complementing ITM.
- **`HL7v2.Segment.PKG`** — Item Packaging. 7 fields. Packaging unit
  definitions and pricing per packaging level (each, box, case).
- **`HL7v2.Segment.VND`** — Purchasing Vendor. 10 fields. Vendor
  master: identifier, name, contact, contract, regulatory approvals.
- **`HL7v2.Segment.STZ`** — Sterilization Parameter. 3 fields.
  Sterilization type, cycle, and maintenance cycle for reusable
  medical devices. Complements SCD and SCP.
- **`HL7v2.Segment.SCP`** — Sterilizer Configuration. 8 fields.
  Device configuration for a sterilizer: number of devices, labor
  calculation, date format, identification, type, lot control.
- **`HL7v2.Segment.SLT`** — Sterilization Lot. 5 fields. Ties a
  sterilization batch to the device that processed it.

Catalog grows from **156 → 164** typed segments (152 v2.5.1 baseline
+ 12 common v2.6/v2.7 additions).

### Added — Migration Guide

New [`guides/migration.md`](guides/migration.md) for developers
moving from another HL7 v2 library. Covers:

- **`elixir_hl7`** (main Elixir alternative) — installation, parse,
  field access, builder, validation, ACK, MLLP, and a pitfalls
  section (empty-string vs nil, repeating fields, separator handling,
  version-aware rules). Includes a step-by-step adoption checklist.
- **HAPI v2 (Java)** — method-by-method mental-model mapping.
- **HL7apy (Python)** — attribute-traversal mental-model mapping.
- **Feature comparison table** — `hl7v2` vs the other three.

### Stats

4,997 tests (504 doctests + 32 properties + 4,461 tests), 0 failures.

## v3.7.0 — 2026-04-09

### Added — v2.6/v2.7 Typed Segments

Four new typed segment modules for post-v2.5.1 segments. Messages at
v2.7+ that use these segments now parse as typed structs instead of
landing in `extra_fields`.

- **`HL7v2.Segment.PRT`** (v2.7+) — Participation Information. 10
  fields. Introduced in HL7 v2.7 to replace ROL in many messages;
  captures the participation of a person, organization, location,
  device, or other entity in an event.
- **`HL7v2.Segment.ARV`** (v2.6+) — Access Restriction. 7 fields.
  "Break the glass" emergency access, patient-requested
  confidentiality, VIP flags.
- **`HL7v2.Segment.UAC`** (v2.7+) — User Authentication Credential.
  2 fields. Inter-system user authentication (Kerberos, SAML, etc.).
- **`HL7v2.Segment.IAR`** (v2.7+) — Allergy Reaction. 5 fields.
  Attaches to IAM to provide additional reaction details.

Catalog grows from **152 → 156** typed segments (100% v2.5.1 + 4
common v2.6/v2.7 additions).

### Stats

4,907 tests (504 doctests + 32 properties + 4,371 tests), 0 failures.

## v3.6.0 — 2026-04-09

### Added — Conformance Profiles

Second feature release closing the gap vs HAPI and HL7apy. HL7v2 now has
**conformance profile validation**: user-defined constraints that extend the
base HL7 schema with organization-specific rules.

- **`HL7v2.Profile`** — pure functional builder for conformance profiles:
  ```elixir
  profile =
    HL7v2.Profile.new("Hospital_ADT_A01", message_type: {"ADT", "A01"})
    |> HL7v2.Profile.require_segment("NK1")
    |> HL7v2.Profile.require_field("PID", 18)
    |> HL7v2.Profile.require_cardinality("OBX", min: 1, max: 10)
    |> HL7v2.Profile.bind_table("PV1", 14, "0069")
    |> HL7v2.Profile.add_value_constraint("PV1", 2, &(&1 in ["I", "O", "E"]))
    |> HL7v2.Profile.add_rule(:custom_check, &my_rule_fn/1)
  ```
  Eight builder functions: `new`, `require_segment`, `forbid_segment`,
  `require_field`, `bind_table`, `require_cardinality`, `add_value_constraint`,
  `add_rule`. Plus `applies_to?/2` for message-type gating.

- **`HL7v2.Validation.ProfileRules`** — evaluates a profile against a typed
  message and returns standard error maps with two extra keys (`:rule` and
  `:profile`) for traceability.

- **`HL7v2.validate/2` `:profile` option** — validates against one profile
  or a list of profiles alongside the base schema:
  ```elixir
  HL7v2.validate(msg, profile: profile)
  HL7v2.validate(msg, profile: [p1, p2, p3])
  ```
  Profiles with a specific `:message_type` are silently skipped for
  non-matching messages.

- **`HL7v2.Profiles.Examples`** — ships two example profiles as starting
  points for integrators:
  - `hospital_adt_a01/0` — strict hospital profile (NK1 + DG1 + PID-18 +
    PV1-3 required, patient_class constrained to I/O/E)
  - `ihe_lab_oru_r01/0` — IHE-style lab results (OBR + OBX required,
    observation_result_status constrained to HL7 table 0085 codes)

- **`guides/conformance-profiles.md`** — user guide covering concepts,
  DSL builders, validation integration, error shape, and custom rules.
  Included in HexDocs.

### Changed

- **README comparative table** — hl7v2 Validation cell updated to include
  **conformance profiles**. On the BEAM, hl7v2 is now the only package
  with typed structs + builder + structural + conditional + version-aware
  + profile validation + MLLP/TLS.

### Stats

4,864 tests (504 doctests + 32 properties + 4,328 tests), 0 failures.

## v3.5.0 — 2026-04-09

### Added — Version-Aware Validation (v2.3 → v2.8)

HL7v2 now applies **version-specific rules** driven by MSH-12 (`version_id`).
Previously the library enforced v2.5.1 rules on every message regardless of
the declared version.

- **`HL7v2.validate/2` is version-aware** — reads MSH-12 automatically, or
  accepts an explicit `:version` override:
  ```elixir
  HL7v2.validate(msg)                       # reads MSH-12
  HL7v2.validate(msg, version: "2.7")       # explicit override
  ```
  Invalid/unrecognized overrides silently fall back to MSH-12 (prevents
  typos from weakening validation).

- **v2.7+ segment fields** — MSH-22/23 (sending/receiving responsible
  organization), MSH-24/25 (network addresses), PID-40 (telecommunication
  information, replaces PID-13/14), OBR-50 (parent universal service
  identifier), OBX 20-25 (observation site, instance ID, mood code,
  performing organization) are now declared typed fields and round-trip
  cleanly.

- **B-field deprecation tracking** — v2.7+ messages exempt fields that
  became backward-compatibility-only in v2.7: PID-13/14, OBR-10/16,
  ORC-10/12. Required-field enforcement skips these when the message is
  v2.7 or later, matching the HL7 conformance model.

- **`HL7v2.Standard.Version`** — new public module with `normalize/1`,
  `compare/2`, `at_least?/2`, and `supported?/1` for HL7 version strings.
  Accepts `"2.7"`, `"v2.7"`, `"2.7.1"`, etc.

- **`HL7v2.Standard.VersionDeltas`** — tracks field optionality changes
  between versions. `exempt?/3` returns true when a field should not be
  enforced as required at a given version.

- **v2.7 extended fixture** — new `adt_a01_v27_extended.hl7` exercises
  MSH-22/23 and PID-40 end-to-end. All 5 adjacent-version fixtures
  (v2.3/v2.4/v2.6/v2.7/v2.8) now pass strict validation, not just
  round-trip.

### Changed

- **README Scope section** — updated to describe the version-aware support
  explicitly. v2.3-v2.8 messages parse, round-trip, and validate under
  their declared version's rules.

### Stats

4,761 tests (499 doctests + 32 properties + 4,230 tests), 0 failures.

## v3.4.0 — 2026-04-09

## v3.4.0 — 2026-04-09

### Fixes

- **Conditional rule test proves each clause exists** — each of the 24
  segment-specific rules is now triggered with data that MUST produce
  non-empty output. A blank struct hitting the default catch-all would
  fail. Previously only tested `is_list(errors)`.
- **Raw gap identities pinned** — `Coverage.raw_holes()` asserted as
  exact tuples `[{"QPD", ...}, {"RDT", ...}]` and `runtime_dispatched()`
  as `[{"OBX", ...}]`. A swap to different fields fails CI.
- **Tarball test is safe and exact** — builds into temp dir (`--output`),
  uses `System.cmd` argument lists (safe for paths with spaces), derives
  tarball name from `Mix.Project.config()[:version]`, asserts `.hl7`
  count == frozen fixture count (exact equality). Never mutates the
  project root.
- **Zero test noise** — `@moduletag capture_log: true` on ConnectionTest,
  `@tag capture_log: true` on timeout tests in ListenerTest and ClientTest,
  named `&handle_telemetry_event/4` replaces anonymous handler lambdas.
  Test output is pure dots.
- **ListenerTest teardown flake fixed** — `on_exit` wraps `Listener.stop/1`
  in `try/catch :exit` to handle concurrent-client tests where the listener
  exits before cleanup.
- **All overclaims narrowed** — PackagingTest moduledoc, Fixtures moduledoc,
  README, and CHANGELOG wording aligned to what CI actually proves (tarball
  file count equality, not compile-and-compare coverage map parity).

### Stats

4,688 tests (472 doctests + 32 properties + 4,184 tests), 0 failures.
Zero noise in test output.

## v3.3.6 — 2026-04-09

### Fixes

- **Tarball-level packaging smoke test** — `mix hex.build` is run in CI and
  the built tarball is unpacked to assert the `.hl7` fixture count exactly
  equals the compile-time frozen list. Previously only project config was
  checked, not the actual artifact.
- **OBX value type count pinned** — `length(OBXValue.known_types()) == 41`
  asserted (matches README claim).
- **Conditional rule count corrected and pinned** — actual count is 24
  segments (was incorrectly claimed as 25 in README/docs, then 23 in an
  overcorrection). Now pinned by an explicit test listing all 24 segments
  with conditional rules.
- **CHANGELOG `/0` → `/1`** — stale v3.3.1 entries still said
  `check_freshness/0`; normalized to `/1` throughout.

### Stats

4,688 tests (472 doctests + 32 properties + 4,184 tests), 0 failures

## v3.3.5 — 2026-04-09

### Fixes

- **Schema coverage claims pinned by exact tests** — segment count (152),
  type count (90), structure count (222), and `coverage_summary` fields are
  now asserted as exact values, not ranges. Shrinkage or expansion without
  updating tests fails CI.
- **Corpus breadth pinned with exact equality** — three new tests assert
  `@exact_fixture_files`, `@exact_canonical`, `@exact_pct` alongside the
  existing minimums. Any fixture add/remove now requires updating both the
  test pins AND the README/CHANGELOG in the same commit. This closes the
  final claim-proof drift gap: expansion no longer silently passes CI while
  published numbers go stale.
- **Packaging smoke test** — new `HL7v2.Conformance.PackagingTest` asserts
  `mix.exs` `package()[:files]` includes `test/fixtures/conformance`, the
  directory exists with `.hl7` files, and the on-disk count matches the
  frozen list. A `package()[:files]` regression now fails CI before reaching
  Hex.

### Stats

4,682 tests (472 doctests + 32 properties + 4,178 tests), 0 failures

## v3.3.4 — 2026-04-08

### Fixes

- **`check_freshness/1` is now strict-by-default on missing fixture dir** —
  returns `{:error, :fixture_dir_unavailable}` instead of silently passing
  as `:ok`. Since v3.3.3 ships the corpus in the Hex package, a missing
  directory is itself a packaging/pathing regression and should fail loudly.
  Pass `allow_missing: true` to opt back into the lenient behavior.
- **Strict-clean suite freshness guard** now flunks on
  `{:error, :fixture_dir_unavailable}` with a packaging-hint error message.
- **Release-surface test pins** — four new tests in
  `HL7v2.Conformance.FixturesTest` lock the documented minimums
  (`@min_fixture_files`, `@min_canonical_structures`, `@min_pct`) and
  cross-check that `list_fixtures/0` and `unique_canonical_structures/0`
  sizes match `coverage/0`. Silent corpus shrinkage now fails CI with a
  clear message.
- **Removed duplicate `groups_for_extras`** in `mix.exs` — the second
  (inert) block was shadowed by the first and would have silently absorbed
  future edits. Only the `Guides` + `Reference` block remains.

### Stats

4,676 tests (472 doctests + 32 properties + 4,172 tests), 0 failures

## v3.3.3 — 2026-04-08

### Fixes

- **Fixture corpus now ships in the Hex package** — `test/fixtures/conformance`
  is included in `files:`, so installed artifacts compile against the same
  110 .hl7 fixtures as the source tree and report identical counts.
  Verified via `mix hex.build` (110 conformance fixtures present in the
  tarball). Previously, an installed user's
  `HL7v2.Conformance.Fixtures.coverage()` returned `%{files: 0, canonical: 0}`
  while README claimed parity.
- **`guides/getting-started.md`** — install snippet bumped from `~> 2.9` to
  `~> 3.0`.
- **`check_freshness/1`** is now **testable** via `:dir` and `:frozen`
  keyword options. Automated stale-case tests cover: matching dir+frozen,
  on-disk additions, frozen removals, simultaneous drift, non-.hl7 filtering,
  and missing-dir (installed Hex artifact case).
- **Strict-clean suite freshness guard** now delegates to
  `Fixtures.check_freshness/1` instead of reimplementing the comparison —
  regressions in the helper fail the guard.

### Stats

4,671 tests (472 doctests + 32 properties + 4,167 tests), 0 failures

## v3.3.2 — 2026-04-08

### Fixes

- **Strict-clean fixture suite is now runtime-discovered** — previously, the
  `describe "strict-clean fixture corpus"` block expanded `Path.wildcard` at
  compile time, so newly added fixture files were silently ignored until the
  test module recompiled. The suite now enumerates fixtures at runtime via
  `File.ls` inside a single test, so additions and removals are picked up
  on every test run without recompilation.
- **Freshness guard test** — a new test in the strict-clean suite fails if
  the compile-time-frozen `HL7v2.Conformance.Fixtures.list_fixtures/0` drifts
  from the on-disk corpus. This catches stale `@external_resource` snapshots
  that would otherwise pass silently.
- **README wording narrowed** — explicit caveat that `@external_resource`
  only tracks files present at compile time, with instructions to call
  `HL7v2.Conformance.Fixtures.check_freshness/1` in dev/test.

### Added

- **`HL7v2.Conformance.Fixtures.check_freshness/1`** — returns `:ok` or
  `{:stale, on_disk_only: [...], frozen_only: [...]}` comparing the
  compile-time snapshot against the current on-disk fixture directory.
  Returns `:ok` when the directory is not accessible (installed Hex artifact
  case).
- Test for `check_freshness/1` in `HL7v2.Conformance.FixturesTest`.

### Verified

Ran the new drift guard against a temporary `zzz_probe_drift.hl7` fixture —
the guard correctly reported:
`fixtures on disk but missing from compile-time frozen list: ["zzz_probe_drift.hl7"]`.
Probe file removed after verification.

### Stats

4,665 tests (472 doctests + 32 properties + 4,161 tests), 0 failures

## v3.3.1 — 2026-04-08

### Fixes

- **`HL7v2.Conformance.Fixtures` ACK fallback** — `unique_canonical_structures/0`
  now uses the same alias fallback as `HL7v2.Validation`: when the
  trigger-specific structure (e.g. `ACK_A01`) is unregistered, it falls back to
  the bare message_code (`ACK`). Previously the helper returned the unregistered
  alias as a "canonical" entry.
- **Corpus stats are now compile-time frozen** — fixture filenames, canonical
  structures, and families are computed at compile time by walking the fixture
  directory and extracting MSH-9 via lightweight string parsing.
  `coverage/0`/`list_fixtures/0`/`unique_canonical_structures/0` return
  identical results whether running from source or from an installed Hex
  artifact. `@external_resource` ensures recompilation when any fixture
  changes.
- **`mix hl7v2.coverage` no longer emits telemetry noise** — the task starts
  the `:telemetry` application before running and, more importantly, no longer
  parses fixtures at runtime (they're compile-time frozen).
- **README family list is now live-derived** — the hand-curated (and stale)
  family enumeration was replaced with a pointer to
  `HL7v2.Conformance.Fixtures.families/0`, which cannot drift from the actual
  corpus.

### Added

- **`HL7v2.Conformance.Fixtures.families/0`** — returns the sorted list of
  message family prefixes (`ADT`, `ORU`, `MFN`, ...) covered by the corpus,
  derived at compile time from canonical structure names.
- **5 new tests** in `HL7v2.Conformance.FixturesTest`: ACK fallback guard,
  registry validity check (every entry must be in `MessageStructure`),
  families accessors, and an explicit "ORI is NOT in corpus" regression to
  prevent future hand-curated drift.

### Stats

4,772 tests (472 doctests + 32 properties + 4,268 tests), 0 failures

## v3.3.0 — 2026-04-08

### Fixes

- **MFN canonicalization bug** — `MFN^M03` through `MFN^M13` (except M05) were
  incorrectly collapsed to `MFN_M01` in `HL7v2.MessageDefinition.canonical_structure/2`,
  even though all 14 MFN structures are registered. Each trigger now resolves
  to its own structure for strict validation. This was exposed by the v3.3.0
  corpus expansion — fixtures for MFN_M03/M04/M06..M13 failed strict validation
  until the canonical map was corrected.

### Added

**58 new conformance fixtures covering 58 new canonical structures** — corpus
expansion from 43 to 101 unique canonical structures (**54.3% of 186 official
v2.5.1 structures**):

- **ADT variants** (11): A12, A15, A20, A21, A24, A30, A37, A39, A43, A54, A61
- **Financial** (3): DFT_P11, BAR_P10, BAR_P12
- **Queries & responses** (15): QBP_Q11/Q13/Q15/Z73, RSP_K11/K13/K15/K23/K25/K31/Q11/Z82/Z86/Z88/Z90
- **Master files** (12): MFN_M03 through MFN_M15 (11 MFN structures + MFK coverage)
- **Lab orders** (3): OML_O33, OML_O35, OML_O39
- **Order variants** (5): OMB_O27, OMD_O03, OMG_O19, OMN_O07, OMP_O09
- **Order responses** (5): ORB_O28, ORD_O04, ORF_R04, ORG_O20, ORL_O22
- **Personnel management** (4): PMU_B03, PMU_B04, PMU_B07, PMU_B08

All new fixtures pass **strict-clean validation** (`mode: :strict`) with zero
warnings. Fixture round-trip suite has 105 explicit test cases; strict-clean
suite auto-discovers all 110 fixture files via `Path.wildcard`.

### Corpus Growth

| | v3.2.0 | v3.3.0 |
|---|---|---|
| Wire fixtures | 52 | **110** (+58) |
| Unique canonical structures | 43 | **101** (+58) |
| % of 186 official | 23.1% | **54.3%** (+31.2pp) |

### Method

This release was produced by a **Forge loop**: fresh-context audit selected
60 highest-value targets, then iterative tranches (A: ADT+DFT, B: RSP+QBP,
C: MFN, D+E: orders & personnel) each fed back through strict validation.
The MFN canonicalization bug was uncovered by Tranche C and fixed in the
same iteration.

### Stats

4,763 tests (472 doctests + 32 properties + 4,259 tests), 0 failures

## v3.2.0 — 2026-04-08

### Added

- **15 new conformance fixtures covering 15 new canonical structures**:
  ADT_A03 (discharge), ADT_A06 (change outpatient to inpatient), ADT_A09
  (patient departing tracking), ADT_A16 (pending discharge), ADT_A18 (merge
  patient info), ADT_A38 (cancel pre-admit), ADT_A45 (move visit info),
  ADT_A50 (change visit number), ADT_A60 (update allergy info), BAR_P02
  (purge patient accounts), DOC_T12 (document response), MDM_T01 (original
  document notification), MFK_M01 (master file application ack), QRY_A19
  (patient demographics query), SSU_U03 (specimen status update).
- All new fixtures pass strict-clean validation with zero warnings.
- Fixture round-trip suite now has 47 explicit test cases; strict-clean
  suite auto-discovers all 52 fixture files via `Path.wildcard`.

### Corpus Growth

**52 wire fixtures, 43 unique canonical structures, 23.1% of 186 official
v2.5.1** (up from 37 / 28 / 15.1% in v3.1.1).

### Stats

4,651 tests (472 doctests + 32 properties + 4,147 tests), 0 failures

## v3.1.1 — 2026-04-08

### Fixes

- **Fixture coverage counts computed live from disk** — `HL7v2.Conformance.Fixtures`
  module is now the single source of truth. `mix hl7v2.coverage` reads the
  fixture directory and reports current file count, unique canonical structures,
  and percentage of 186 official. Prevents doc drift.
- **Strict-clean suite wording** — describe block renamed from "real conformance
  proof" to "strict-clean fixture corpus" with a comment noting its breadth is
  bounded by the on-disk corpus, not the full standard.
- **Generated non-repeating test wording** — moduledoc no longer claims the
  assertion checks specifically for a "cardinality error"; the test asserts only
  that the validator emits *some* diagnostic (cardinality, out-of-order, or
  unexpected) for the duplicated segment.

### Added

- `HL7v2.Conformance.Fixtures.coverage/0` — returns `%{files, canonical,
  total_official, pct}` computed from the fixture directory.
- `HL7v2.Conformance.Fixtures.list_fixtures/0` — sorted list of .hl7 files.
- `HL7v2.Conformance.Fixtures.unique_canonical_structures/1` — deduplicated
  canonical structures covered by the corpus.

### Current Fixture Corpus

37 wire fixtures, 28 unique canonical structures, 15.1% of 186 official v2.5.1.

### Stats

4,621 tests (472 doctests + 32 properties + 4,117 tests), 0 failures

## v3.1.0 — 2026-04-08

### Fixes

- **ACK_A01-style aliases now resolve** — `ACK^A01^ACK_A01`, `ACK^A02^ACK_A02`,
  etc. now fall back to the bare `ACK` structure when the specific alias isn't
  registered. Previously these returned "structure not checked" warnings.

### Added

- **Richer generated structural negatives** — every one of the 222 message
  structures now has 5 generated tests instead of 2: positive in order,
  MSH-only fails, MSH-not-first flagged in strict mode, non-repeating required
  duplicated is flagged, and unknown segment injection does not crash. Total:
  1,110 generated structure tests.
- **Version-matrix fixtures** — ADT_A01 fixtures at v2.3, v2.4, v2.6, v2.7, and
  v2.8. Adjacent-version tolerance is now exercised by real wire messages at
  each version declaration.

### Changed

- **Scope claim narrowed** — README now describes adjacent-version tolerance as
  "parser/encoder round-trip" rather than broad interoperability. The version
  matrix slice is small by design.

### Stats

4,615 tests (472 doctests + 32 properties + 4,111 tests), 0 failures

## v3.0.2 — 2026-04-08

### Fixes

- **PV2 transfer rule respects strict mode** — `prior_pending_location` check
  now escalates to `:error` in strict mode for transfer triggers. Previously
  hardcoded to `:warning` regardless of mode.
- **All 32 fixtures pass strict-clean validation** — fixtures fixed: NTE ordering
  in ADT_A01, PV2-1 populated in ADT_A02, BPX donation/commercial path in
  BPS_O29. Zero warnings under `mode: :strict`.
- **Fixture coverage percentage corrected** — 32 files map to 28 unique canonical
  structures (15.1% of 186 official), not 30% as previously claimed.

### Added

- **Strict-clean conformance suite** — new test describe block runs every fixture
  under `mode: :strict` and fails on any warning. Lenient round-trip suite is
  preserved separately.

### Stats

3,938 tests (472 doctests + 32 properties + 3,434 tests), 0 failures

## v3.0.1 — 2026-04-08

### Fixes

- **Structural validation skipped for non-canonical MSH-9.3 aliases** — messages
  with alias structures in MSH-9.3 (e.g., `SIU_S14`, `ADT_A28`, `REF_I13`) now
  canonicalize to the correct registered structure (SIU_S12, ADT_A05, REF_I12)
  before structural validation. Previously these returned "structure not checked"
  warnings despite having known canonical mappings.
- **MLLP client docs** — `send_message/3` docs now correctly state that protocol
  desync is terminal (closes connection, stops client process). Previously still
  described the old drain-and-continue behavior.
- **README install snippet** — updated from `~> 2.9` to `~> 3.0` with upgrade
  note about the breaking desync change.
- **Conformance roadmap** — current state updated to reflect 32 fixtures, 25
  trigger-aware conditional rules, and accurate raw gap counts.

### Stats

3,906 tests (472 doctests + 32 properties + 3,402 tests), 0 failures

## v3.0.0 — 2026-04-08

### Breaking

- **MLLP protocol desync is now a fatal error** — `send_message/3` returns
  `{:error, :protocol_desync}` and closes the connection if any stale bytes
  (complete or partial frames) are found in the buffer at a send boundary.
  Previously, complete stale frames were silently discarded and partial bytes
  were carried forward, potentially corrupting the next response.

### Added

- **Trigger-aware conditional validation** — scheduling segments (AIS, AIG,
  AIL, AIP, RGS) now check the message trigger event from MSH-9.2. Modification
  triggers (S03-S11) produce definitive checks; non-modification triggers skip
  the heuristic. PV2 `prior_pending_location` is validated against transfer
  triggers (A02, A06, A07, etc.). Without trigger context, the original
  heuristic fallback is preserved for backwards compatibility.
- **14 new conformance fixtures** — ADT_A02/A04/A08/A17, ORU_R01 multi-OBR,
  ORU_R30, OML_O21, OMI_O23, OMS_O05, RDS_O13, RAS_O17, BPS_O29, MFN_M01,
  SIU_S14. 32 fixture files covering 28 unique canonical structures (15% of
  186 official). All pass strict-clean validation.
- **OBX-5 runtime-dispatched** in coverage reporting — `mix hl7v2.coverage`
  now distinguishes between true raw gaps (QPD-3, RDT-1) and intentionally
  runtime-typed fields (OBX-5 VARIES via OBXValue dispatch).

### Stats

3,904 tests (472 doctests + 32 properties + 3,400 tests), 0 failures

## v2.12.0 — 2026-04-08

### Fixes

- **MLLP protocol desync** — any non-empty buffer at a send boundary now returns
  `{:error, :protocol_desync}` and closes the connection. Previously, stale
  complete frames were silently discarded (hiding protocol violations) and
  partial stale bytes could corrupt the next response by concatenating with it.
  MLLP is strictly 1:1 request/response; leftover bytes of any kind are now
  treated as a fatal protocol violation.
- **Stale secondary docs** — `docs/expansion-plan.md` marked as historical
  (was showing v1.3.0 state); `docs/conformance-roadmap.md` corrected to
  reflect the 3 remaining raw holes and current conditional rule count.

### Stats

3,876 tests (472 doctests + 32 properties + 3,372 tests), 0 failures

## v2.11.0 — 2026-04-08

### Fixes

- **MLLP request/response desync** — stale frames from misbehaving peers are
  now drained before each send, maintaining strict 1:1 request/response pairing.
  Previously, buffered extra frames would be returned as the response to a
  subsequent request, mispairing ACKs with outbound messages.
- **~h sigil** — now validates repetition legality (non-repeating field +
  repetition selector = compile error) and component bounds against typed
  field metadata at compile time.
- **Typed round-trip contract** — tests and docs now correctly describe typed
  encode/parse as "canonicalization is idempotent" rather than
  "identity-preserving" (trailing empty components are trimmed per HL7 encoding
  rules).

### Added

- **Reference docs in HexDocs** — segments, data types, message structures, and
  encoding rules are now included in the published documentation.
- **Known Limitations** section in README — documents the 3 raw field holes
  (OBX-5 VARIES, QPD-3, RDT-1), segment-local conditional validation, and typed
  canonicalization behavior.

### Stats

3,875 tests (472 doctests + 32 properties + 3,371 tests), 0 failures

## v2.10.0 — 2026-04-07

### Fixes

- **MLLP client multi-frame safety** — extra complete frames in a single TCP
  read are now re-framed back into the buffer instead of silently dropped;
  previous fix only preserved partial-frame remainders
- **fetch/2 component out-of-range on composites** — `MSH-9.99` and
  `PID-3.99[*]` now return `{:error, :invalid_component}` instead of
  `{:ok, nil}` or `{:ok, [nil, nil]}`
- **Flaky MLLP client test** — server-close test uses 1ms timeout + 300ms
  margin (was 50ms/100ms race)
- **parse/2 docs** — `validate: true` now documented as typed-mode only

### Added

- **8 new OBX-5 value types** — AD, MA, NA, NDL, PL, PPN, SPS, VR added to
  the dispatch map (41 types total, up from 33)
- **PV2 conditional rule** — warns when `expected_discharge_date_time` is set
  without `expected_discharge_disposition`
- **QAK conditional rule** — warns when `query_tag` is present without
  `query_response_status`

### Stats

3,875 tests (472 doctests + 32 properties + 3,371 tests), 0 failures

## v2.9.1 — 2026-04-07

### Fixes

- **MLLP client frame buffering** — leftover frames from multi-frame responses
  are now buffered in GenServer state and consumed on the next `send_message`
  call (was silently discarding extra frames)
- **fetch/2 out-of-range repetitions** — `PID-3[3]` with only 2 reps now returns
  `{:error, :repetition_out_of_range}` instead of `{:ok, nil}`

## v2.9.0 — 2026-04-07

### Generated Reference Docs + Structure Proof

- **`mix hl7v2.gen_docs`** — generates all reference docs from code metadata
- **message-structures.md**: 6,726 lines — all 222 structures with group notation
- **segments.md**: 3,516 lines — all 152 segments with field tables
- **data-types.md**: 1,162 lines — all 90 types with components
- **444 generated structure validation tests** — positive + negative for every
  structure. No more "selectively tested."
- Conformance assertions tightened to exact counts
- Stale moduledocs and roadmap fixed

### Stats

3,863 tests (472 doctests + 32 properties + 3,359 tests), 0 failures

## v2.8.2 — 2026-04-06

### Fixes

- **Flaky MLLP test** — increased sleep and assert_receive timeouts for telemetry
  exception events (was timing-sensitive under CI load)
- **TQ moduledoc** — removed stale "RI/OSD preserved as raw strings" (now typed)
- **SCD/SDD moduledoc** — removed contradictory "per HL7 v2.5.1 specification"

## v2.8.1 — 2026-04-06

### Fixes

- **RPT data loss** — all 10 v2.5.1 components now parsed and encoded (was 6,
  silently dropping components 7-10)
- **TQ depth** — `interval` parsed as RI struct, `order_sequencing` as OSD struct
  (were raw strings despite typed modules existing)
- **Stale moduledocs** — IN2, SCD, SDD corrected

## v2.8.0 — 2026-04-06

### Full Conformance Expansion

- **189 HL7 tables** (was 108) — coded-value tables across all v2.5.1 domains
- **255 field bindings** (was 80) — 100% of ID-typed fields bound to tables
- **23/23 conditional rules** — all segments with `:c` fields have enforcement
- **18 conformance fixtures** — end-to-end round-trip + validation per family
- **222 message structures** (186/186 official v2.5.1 + aliases)

## v2.7.1 — 2026-03-27

### Fixes

- **parse/2 table validation** — `validate_tables: true` option now forwarded to
  validator (was silently ignored)
- **add_segment/2 guards** — rejects MSH (ArgumentError) and non-segment structs
- **ACK 5-char delimiter support** — ACK encoder handles truncation-character MSH-2
- **parse/2 typespec** — includes `{:ok, msg, warnings}` return shape

## v2.7.0 — 2026-03-27

### Full v2.5.1 Structure Coverage

- **9 final missing structures**: EAN_U09, PPV_PCA, PRR_PC5, PTR_PCF, QBP_Z73,
  QRY, RCL_I06, RGR_RGR, RTB_Z74
- **186/186 official v2.5.1 structures** covered (222 total with aliases)
- All official segments, types, and structures at 100%

## v2.6.0 — 2026-03-26

### Full v2.5.1 Structure Coverage

- **23 new structures** closing all identified gaps vs the official v2.5.1 index:
  ADT_A18, ADT_A52, MFR_M04-M07, MFN_M15, ORF_R04, QRY variants, OSQ/OSR_Q06,
  RSP_Q11/K23/K25/Z82/Z86/Z88/Z90, SQM/SQR_S25
- **213 message structure definitions** total (186 official + aliases/responses)
- README: tightened type count (89 + legacy TN), version scope, raw mode claims

## v2.5.0 — 2026-03-26

### Deep Semantic Validation

- **108 HL7 tables** (was 20) — demographics, clinical, scheduling, administrative,
  financial coded-value tables
- **80 coded field bindings** (was 11) — across MSH, PID, PV1, PV2, NK1, AL1, IAM,
  DG1, DRG, NTE, ORC, OBR, OBX, IN1, FT1, TXA, SCH, AIS, AIG, RXR, EVN, ERR, MSA
- **Conditional field rules** for 17 segments — OBX, MSH, NK1, ORC, OBR, SCH, AIS,
  AIG, AIL, AIP, RGS, ARQ, DG1, PID, PV2, QAK, MFE/MFA. Rules produce warnings
  in lenient mode, errors in strict mode.

## v2.4.0 — 2026-03-26

### CCP Type + 190 Message Structures

- **CCP type** (Channel Calibration Parameters) — last missing v2.5.1 type. 90/90.
- **86 new message structures** (104 → 190) covering all major v2.5.1 families
- README and docs updated to current coverage

## v2.3.0 — 2026-03-25

### 104 Message Structures

- 81 new message structures across all HL7 v2.5.1 families: ADT, BAR, DFT,
  pharmacy, lab, query, master files, scheduling, referrals, pathways, equipment,
  blood bank, clinical study, personnel, network management
- 226 canonical trigger-event mappings

## v2.2.0 — 2026-03-25

### Zero Raw Holes

- 218 raw field holes filled across 36 segments
- Only 3 intentional raw holes remaining (OBX-5 dispatch, RDT-1 variable, QPD-3 query)

## v2.1.3 — 2026-03-26

### Fixes

- **SI/TM/DT invalid value preservation** — completes the lossless round-trip
  work started in v2.1.2. Invalid SI values preserved as raw strings, invalid
  TM/DT values preserved in `original` field. No primitive type silently drops
  malformed values anymore.

## v2.1.2 — 2026-03-26

### Fixes

- **DT/DTM invalid value preservation** — invalid dates (e.g., `20240230`, `20250229`)
  and malformed DTM values are now preserved in an `original` field instead of silently
  dropping to nil. Prevents clinical data loss on dirty feeds during typed round-trip.

## v2.1.1 — 2026-03-26

### Fixes

- **Strict repetition validation** — non-repeatable fields with illegal repetitions
  (e.g., `M~F` on PID-8) are now caught in strict mode as errors and in lenient
  mode as warnings. Previously silently accepted.

## v2.1.0 — 2026-03-26

### Full v2.5.1 Segment Catalog

- **16 new segments**: ABS, AFF, BTX, EQL, ERQ, NCK, NDS, NSC, NST, ODS, ODT,
  PRC, QRI, RMI, SPR, VTQ — completing the official v2.5.1 segment index
- **152/152 v2.5.1 segments** in catalog, all typed (115 fully, 37 partial)
- **89/89 v2.5.1 data types** implemented
- SCD/SDD marked as v2.6 extensions
- Fixed unused alias warning in DLT type

## v2.0.0 — 2026-03-25

### Full Standard Coverage

- **84 new segments** — all remaining v2.5.1 standard segments
- **35 new data types** — all remaining v2.5.1 data types
- **66 raw holes filled** across 13 segments
- Segment coverage: 136/136 → 152/152 (after v2.1.0 corrections)
- Type coverage: 89/89 (100%)

## v1.4.6 — 2026-03-25

### Fixes

- **Nested composite validation** — `semantic_blank?` now recurses into nested
  structs. `[%XPN{family_name: %FN{}}]` is correctly detected as blank for
  required-field checks.
- **Strict mode unsupported structures** — `validate(msg, mode: :strict)` now
  returns errors (not warnings) for unsupported message structures.

## v1.4.5 — 2026-03-24

### Fixes

- **Escape.decode/2 crash** — malformed hex escapes (`\XGG\`, `\X4Z\`) no longer
  raise `FunctionClauseError`; invalid hex bytes gracefully terminate decoding
- **parse(validate: true) warnings** — now returns `{:ok, msg, warnings}` when
  validation produces only warnings (was silently discarding them as `{:ok, msg}`)
- **Empty string required fields** — `""` on required fields now caught by validation
  (was passing as non-blank)
- **MLLP connection stop reason** — telemetry now carries actual reason (`:closed`,
  `:timeout`, `:message_too_large`, `{:error, reason}`) instead of always `:normal`
- **Getting-started guide** — install `~> 1.4`, fixed `CX` field name (`id` not `id_number`)
- **README TLS example** — uses `HL7v2.MLLP.TLS.mutual_tls_options/1`
- **OBX moduledoc** — removed stale claim that ED/SN/RP are raw (they're typed)
- **PRD** — marked as historical

## v1.4.4 — 2026-03-24

### Fixes

- **ADT structure definitions** — 8 structures corrected against v2.5.1 spec:
  A09, A12, A15, A16, A21, A24, A37, A38 had incorrect NTE (removed) and
  missing OBX/DG1 (added). Structural validation now matches the standard.
- **Coverage metrics** — `mix hl7v2.coverage` now shows fully typed vs partially
  typed segment split. `--detail` flag shows per-segment field completeness.
- **Builder moduledoc** — clarified as low-level constructor (does not validate)

## v1.4.3 — 2026-03-24

### Fixes

- **Structural validator strictness** — unknown non-Z segments are no longer silently
  consumed during matching. They now stop the matcher and are flagged as leftover
  warnings (e.g., ACC in an ACK message is now caught).
- **ADT_A02** — added OBX and PDA per v2.5.1 spec (were missing)
- **ADT_A03** — added NK1, VISIT group, AL1, GT1, INSURANCE group, ACC, PDA
  per v2.5.1 spec (was incomplete)
- **Canonical aliases** — added A29, A32, A33 → ADT_A21 (were falling through)
- **Conformance roadmap** — updated to current state

## v1.4.2 — 2026-03-23

### MLLP Hardening

- **`max_message_size` option** — configurable buffer limit for both MLLP
  server connections and client recv loops (default: 10 MB). Connections
  exceeding the limit are closed with telemetry and logging. Protects against
  memory exhaustion from misbehaving or malicious senders.
- **`handler_timeout` option** — configurable timeout for handler execution
  (default: 60 s). Handlers that exceed the deadline are killed via
  `spawn_monitor`/`Process.exit(:kill)`; the connection continues accepting
  new messages. Telemetry event emitted on timeout.

### Property Testing

- Added delimiter-aware generators (`gen_hl7_field/0` family) that produce
  fields with repetitions (`~`), components (`^`), and sub-components (`&`).
  Two new property tests verify round-trip idempotency for structured messages
  and individual structured fields.

### Documentation

- **Escape sequence behavior** documented in `TypedMessage` moduledoc and
  README Scope section: typed field values preserve HL7 escape sequences
  literally; users must call `HL7v2.Escape.decode/2` explicitly.

### Stats

2,383 tests (303 doctests + 32 properties + 2,048 tests), 0 failures

## v1.4.1 — 2026-03-23

### Fixes

- **Raw parser/encoder round-trip data corruption** — fields with mixed-structure
  repetitions (e.g., `a~b^c`) were silently corrupted: the encoder misidentified
  repetitions as components, encoding `a~b^c` as `a^b&c`. The parser now normalizes
  each repetition to a list, making the representation unambiguous. This also fixes
  the same ambiguity in the typed parser (mixed repetitions were collapsed into a
  single garbled composite value).
- **`HL7v2.type/1`** — now returns `{:ok, typed}` instead of raising `MatchError`
  on conversion failure. Aligns with the library's error-tuple convention.
- **README/CHANGELOG accuracy** — stale segment counts, stale ROL example (was shown
  as raw tuple but is typed since v1.2.0), missing changelog entries, UB1/UB2
  disclosure (mostly raw shells).

### Stats

2,376 tests (303 doctests + 30 properties + 2,043 tests), 0 failures

## v1.4.0 — 2026-03-23

### Pharmacy, Documents & Adverse Reactions

- **9 new segments**: RXO (Order, 25 fields), RXE (Encoded Order, 44 fields),
  RXD (Dispense, 33 fields), RXA (Administration, 26 fields), RXR (Route, 6 fields),
  RXG (Give, 27 fields), RXC (Component, 9 fields), TXA (Transcription Document Header,
  23 fields), IAM (Patient Adverse Reaction, 20 fields)
- **3 new message structures**: RDE_O11 (Pharmacy Encoded Order), RDS_O13 (Pharmacy
  Dispense), MDM_T02 (Document Notification and Content)
- **Segment coverage**: 52/136 (38.2%, up from 31.6%)

### Fixes

- **Atom leak in structural validator** — segment IDs from untrusted input were
  converted to atoms via `String.to_atom/1`. Now uses string-based MapSet comparison.
- **Strict mode field cardinality** — field cardinality overflow escalated to `:error`
  in strict mode (was always `:warning` regardless of mode).

### Stats

2,370 tests (303 doctests + 30 properties + 2,037 tests), 0 failures

## v1.3.0 — 2026-03-23

### Standards Expansion

- **6 new segments**: UB1 (UB82), UB2 (UB92 Data), CTD (Contact Data),
  CTI (Clinical Trial Identification), BLG (Billing), DSC (Continuation Pointer)
- **Segment coverage**: 43/136 (31.6%, up from 27.2%)

### Stats

2,126 tests (303 doctests + 30 properties + 1,793 tests), 0 failures

## v1.2.0 — 2026-03-23

### Standards Expansion

- **8 new segments**: ROL (Role), IN2 (Insurance Additional Info, 72 fields),
  IN3 (Insurance Certification, 28 fields), DRG (Diagnosis Related Group),
  SPM (Specimen, 30 fields), TQ1 (Timing/Quantity), TQ2 (Timing Relationship),
  PDA (Patient Death and Autopsy)
- **6 new types**: RI (Repeat Interval), SN (Structured Numeric),
  ED (Encapsulated Data), RP (Reference Pointer), RPT (Repeat Pattern),
  PLN (Practitioner License)
- **OBX dispatch**: Added SN, ED, RP to value_type_map
- **Segment coverage**: 37/136 (27.2%, up from 21.3%)
- **Type coverage**: 54/89 (60.7%, up from 53.9%)
- **833 declared fields** across typed segments
- All 14 previously-raw segments in supported structures now typed
  (ROL, IN2, IN3, DRG, SPM, TQ1, TQ2, PDA + previously done)
- Improved structural validator diagnostics: out-of-order segments no longer
  double-reported

### Stats

2,126 tests (303 doctests + 30 properties + 1,793 tests), 0 failures

## v1.1.0 — 2026-03-23

### Positional Structural Validation

- **Rewritten structural validator** — state-machine-style positional matcher that walks
  the segment stream against the structure AST. Replaces flat deduplicated checks.
  - Handles segments in multiple groups (ROL in PATIENT, VISIT, PROCEDURE, INSURANCE)
  - Validates repeating groups per-occurrence (A39 PATIENT requires PID+MRG each time)
  - Ordering enforced naturally by sequential walk
- **ADT_A01**: Added OBSERVATION group (OBX+NTE) per HL7 v2.5.1
- **ORU_R01**: Added SPECIMEN group (SPM+OBX+NTE) per HL7 v2.5.1
- **Type catalog**: Added 5 missing v2.5.1 types (CD, DLT, DTN, ICD, MOP) — 89 total
- **Type coverage**: 48/89 (53.9%, corrected from inflated 57.1%)
- 10 new structural validation tests

### Stats

1,933 tests (266 doctests + 30 properties + 1,637 tests), 0 failures

## v1.0.0 — 2026-03-23

### M6: Conformance Platform

- **HL7 table validation** — 20 coded-value tables from HL7 v2.5.1 (administrative sex,
  patient class, message type, processing ID, acknowledgment codes, observation status,
  value types, identifier types, and more). Opt-in via `validate(msg, validate_tables: true)`.
- **Table-aware field validation** — 11 coded fields checked against their HL7 tables:
  MSH-9.1, MSH-11.1, MSH-12.1, MSH-15, MSH-16, PID-8, PV1-2, PV1-4, MSA-1, OBX-2, OBX-11
- **Tables API** — `HL7v2.Standard.Tables.valid?(table_id, code)`, `validate/2`, `get/1`
- 26 new table validation tests

### Stats

1,921 tests (266 doctests + 30 properties + 1,625 tests), 0 failures

## v0.9.0 — 2026-03-23

### M5: Broad Clinical Coverage

- **8 new segments**: SFT (Software), PD1 (Patient Additional Demographic),
  PR1 (Procedures), AIG/AIL/AIP (Scheduling Resources), DB1 (Disability),
  ACC (Accident)
- **Segment coverage**: 29/136 standard segments (21.3%, up from 15.4%)
- **647 declared fields** across typed segments
- All segments referenced in ADT/ORU/SIU message structure definitions are now
  typed (except ROL, DRG, IN2, IN3 which are lower priority)
- 98 new tests across 8 test files

### Stats

1,893 tests (266 doctests + 30 properties + 1,597 tests), 0 failures

## v0.8.0 — 2026-03-23

### M4: Datatype Expansion

- **TQ type** — Timing/Quantity (12 components) — closes raw holes in OBR-27, ORC-7, SCH-11
- **ELD type** — Error Location and Description (4 components) — closes raw hole in ERR-1
- **SPS type** — Specimen Source (7 components) — closes raw hole in OBR-15
- **TM type** — Time primitive (HH[MM[SS[.SSSS]]][+/-ZZZZ]) — added to OBX-5 dispatch
- **Raw holes**: 6 → 1 (only OBX-5 remains, by design — uses dispatch)
- **Type coverage**: 48/84 standard types (57.1%, up from 52.4%)
- 56 new tests + 25 new doctests

### Stats

1,795 tests (266 doctests + 30 properties + 1,499 tests), 0 failures

## v0.7.0 — 2026-03-22

### M3: Structural Validation

- **Structural validator** — `HL7v2.Validation.Structural` checks segment ordering,
  group anchors, and cardinality against group-aware message structure definitions.
  Replaces presence-only validation for all 20 supported message structures.
- **Strict/lenient modes** — `HL7v2.validate(msg, mode: :strict)` treats ordering and
  cardinality violations as errors. Default `:lenient` mode reports them as warnings.
- **Order checking** — Detects when segments appear in wrong order relative to the
  abstract message definition (e.g., OBX before OBR in ORU_R01)
- **Cardinality checking** — Flags non-repeating segments that appear multiple times
- **28 structural tests** — Positive and negative cases for ADT_A01, ORU_R01, ORM_O01,
  SIU_S12, ACK, ADT_A39 including missing anchors, wrong order, duplicates, Z-segments

### Stats

1,700 tests (241 doctests + 30 properties + 1,429 tests), 0 failures

## v0.6.0 — 2026-03-22

### M2: Standard Model

- **HL7v2.Standard** — Single source of truth for HL7 v2.5.1 metadata: segment catalog
  (~136 entries), type catalog (~84 entries), capability tiers (`:typed` / `:unsupported`)
- **MessageStructure** — Group-aware abstract message definitions for 20 structures
  (ADT A01-A39, ORM_O01, ORU_R01, SIU_S12, ACK). Includes groups, anchors, cardinality
  and optionality per the HL7 v2.5.1 abstract message definitions.
- **Coverage ledger** — `HL7v2.Standard.Coverage` computes typed segments, raw holes,
  unsupported types, and coverage percentages
- **`mix hl7v2.coverage`** — Prints human-readable coverage report to stdout
- **Conformance tests** — `test/hl7v2/conformance/` with structure metadata validation
  (27 tests) and fixture round-trips for ADT_A01, ORU_R01, ORM_O01, SIU_S12, ACK
- **MessageDefinition** now delegates to MessageStructure for presence validation,
  extracting required segments from group-aware definitions

### Stats

1,672 tests (241 doctests + 30 properties + 1,401 tests), 0 failures

## v0.5.6 — 2026-03-22

### Fixes

- **DTM encode precision** — DateTime/NaiveDateTime encode now caps fractional seconds
  at 4 digits per HL7 v2.5.1 spec (was emitting up to 6, which the parser couldn't
  re-parse)
- **fetch/2 raw tuple bounds** — `fetch(msg, "PR1-99")` on raw tuple segments now
  returns `{:error, :field_not_found}` instead of `{:ok, nil}` for out-of-range fields
- **Type count** — README: "43 v2.5.1 types + legacy TN" (TN is deprecated, not in the
  v2.5.1 data-structure catalog)
- **Implementation plan** — Marked as historical reference, no longer claims "COMPLETE"

## v0.5.5 — 2026-03-22

### Fixes

- **fetch/2 component bounds** — `fetch(msg, "PID-5.99")` now returns
  `{:error, :component_not_found}` instead of `{:ok, nil}` for out-of-range
  component indices on typed fields
- **MRG/RGS tests** — Added parse/encode/round-trip tests for both segments
  (were at 0% coverage). Added SIU^S12 integration test with RGS.
- **Parser docs** — Changed "preserves the original wire format exactly" to
  "canonical round-trip fidelity" (line endings are normalized to CR)

## v0.5.4 — 2026-03-22

### Fixes

- **Validation return shape** — `validate/1` now returns `{:ok, warnings}` when only
  warnings are present, instead of treating warnings as errors. Warnings-only results
  no longer block `parse(..., validate: true)`.
- **Install snippet** — README updated from `~> 0.1` to `~> 0.5`
- **Segment count** — README now says "21 standard segments + generic ZXX" (was counting
  ZXX as a standard segment)
- **Raw tuple access** — README now documents that component/repetition selectors are not
  applied to raw tuples (only typed segments get full descent)
- **Segment reference** — docs/reference/segments.md now says "13 of 21" segments
  documented (was claiming all 22)

## v0.5.3 — 2026-03-22

### Additions

- **MRG segment** — Merge Patient Information (7 fields), registered in typed parser.
  ADT^A39-A42 merge workflows now fully typed end-to-end.
- **OBX dispatch** — Extended value_type_map with CQ, MO, DR, XON, CP, FC, TN. All
  implemented types now available for OBX-5 dispatch.

### Fixes

- **Builder separator** — `Message.to_raw/1` now derives separators from MSH instead
  of hardcoding defaults. Custom-delimiter builder messages encode correctly.
- **NM whitespace** — `original` field now preserves raw wire value including any
  whitespace for lossless round-trip. `value` field still uses trimmed+normalized form.
- **README accuracy** — 22 segments (was 21), ~95% coverage (was 95%+), explicit note
  about raw holes (TQ, SPS, ELD fields)

## v0.5.2 — 2026-03-22

### Fixes

- **Subcomponent separator** — Non-default sub-component separators (e.g., `$` in
  MSH-2 `^~\$`) now preserved through typed round-trip. Previously hardcoded as `&`
  in 15 composite type modules. Uses process-dictionary-scoped separator context
  threaded from the Separator struct through segment parse/encode.
- **RGS typed parsing** — RGS segment now registered in typed parser (was defined
  but not dispatched, so SIU messages returned raw tuples instead of structs)
- **ADT_A12** — ADT^A12 (Cancel Transfer) now correctly mapped to ADT_A12, not ADT_A09
- **Presence validation** — Renamed "structure validation" to "presence validation"
  throughout docs to clarify scope (no ordering/group/cardinality)
- **Docs accuracy** — Fixed DICOM PS3.x citation in message-structures.md (was wrong
  standard), updated README coverage numbers

## v0.5.1 — 2026-03-22

### Fixes

- **ORM_O01 / ORU_R01** — PID is now optional (patient group is optional per spec)
- **SIU_S12** — RGS required as resource group anchor; PID now optional; AIS optional
  within the resource group
- **Primitive extra components** — Non-conformant input like `M^EXTRA` on primitive
  fields now preserved through typed round-trip instead of being silently truncated
- **Canonical structure mappings** — Added ADT^A12 and SIU S18-S24 to match the
  documented reference

## v0.5.0 — 2026-03-22

### Conformance Hardening

- **Extra fields preservation** — Typed segments now capture fields beyond the declared
  count in `extra_fields`, preventing silent data loss on messages with trailing standard
  fields (e.g. OBX-20 through OBX-25)
- **MSH-2 validation** — Reject malformed encoding characters: overlong (6+), field
  separator collision, duplicate delimiters
- **CNN type** — Composite Number and Name without Authority (11 components, flat HD)
- **NDL type** — Name with Date and Location (11 components with CNN sub-components)
- **OBR fields 32-35** corrected from XCN to NDL per HL7 v2.5.1
- **NM lexical preservation** — `original` field preserves raw wire format (`+01.20`
  round-trips as `+01.20`, not `1.2`)
- **DTM offset preservation** — Malformed timezone offsets preserved instead of silently
  dropped
- **Message definition completeness** — Canonical structure mapping moved to single source
  of truth in `MessageDefinition`

### Stats

44 type modules (36 composite + 8 primitive), 20 segments + ZXX, 1,620 tests, 0 failures

## v0.4.0 — 2026-03-22

### Ergonomics & Polish

- **`~h` sigil** — Compile-time validated HL7v2 path access (`~h"PID-5.1"`)
- **`fetch/2`** — Error-returning path access (`{:ok, value}` or `{:error, reason}`)
- **String.Chars protocol** — `to_string/1` on RawMessage, TypedMessage, and Message
- **Truncation character** — v2.7+ 5th encoding character support
- **Wildcard paths** — `OBX[*]-5` returns all OBX observation values, `PID-3[*]` returns
  all repetitions
- **Copy mode** — `parse(text, copy: true)` prevents GC pressure on long-lived messages
- **Unknown segment handling** — ZXX pass-through for vendor Z-segments and unrecognized
  standard segments
- **Benchmarks** — Parse/encode throughput benchmarks

### Fixes

- 4 rounds of analyst review fixes: scope claims, data correctness bugs, doc
  accuracy, fetch/2 error semantics

### Stats

42 type modules, 20 segments + ZXX, 1,470 tests, 0 failures

## v0.3.0 — 2026-03-22

### Type Coverage Push

- **16 new composite types** — XCN, CP, MO, FC, JCC, CQ, EIP, DLD, DLN, ERL, MOC, PRL,
  AUI plus others; 97% of segment fields now typed (up from ~60%)
- **Path-based access API** — `HL7v2.Access.get(msg, "PID-5.1")` for field/component/
  repetition extraction
- **Message structure definitions** — 9 message types (ADT_A01-A04/A08, ORM_O01, ORU_R01,
  SIU_S12, ACK) with required/optional segment rules
- **Property-based tests** — 25 StreamData properties for parser/encoder round-trip
- **Coverage** — 81% to 96%+ with 244 additional tests
- **ExDoc** — Module groups, getting-started guide, hex.pm package metadata

### Stats

42 type modules (34 composite + 8 primitive), 20 segments + ZXX, 1,132 tests, 0 failures

## v0.2.0 — 2026-03-22

### Feature-Complete MVP

- **20 typed segment structs** — MSH, EVN, PID, PV1, PV2, NK1, OBR, OBX, ORC, MSA, ERR,
  NTE, AL1, DG1, IN1, SCH, AIS, GT1, FT1 via DRY behaviour macro; plus ZXX generic
  Z-segment
- **Typed parser** — Raw message to typed segment struct conversion with OBX-5 VARIES
  dispatch
- **Message builder** — `HL7v2.Message.new/3` with auto-populated MSH (timestamp, control
  ID, version, processing ID)
- **ACK/NAK builder** — `HL7v2.ack/2` with sender/receiver swap
- **Validation engine** — Opt-in required-field and segment-presence checks
- **MLLP transport** — Ranch 2.x TCP listener, GenServer client, TLS/mTLS support
- **Telemetry** — Instrumented parse, encode, and MLLP operations
- **26 base type modules** — 12 primitives (ST, NM, SI, ID, IS, TX, FT, TN, DT, DTM, TS,
  NR) + 14 composites (CX, XPN, XAD, XTN, CE, CWE, HD, PL, EI, MSG, PT, VID, CNE, XON,
  FN, SAD, DR)

### Stats

26 type modules, 20 segments + ZXX, 319 tests, 0 failures

## v0.1.0 — 2026-03-22

### Initial Release — Core Parser

- **Separator parsing** — Field, component, repetition, escape, sub-component delimiters
  from MSH
- **Escape/unescape** — Full HL7v2 escape sequence handling (`\F\`, `\S\`, `\R\`, `\E\`,
  `\T\`, hex `\Xhh\`, `\Cxxyy\`, `\Mxxyyzz\`)
- **Raw parser** — Lossless message parsing with CR/LF/CRLF line-ending normalization
- **Encoder** — Wire-format serialization with iodata performance and trailing-empty
  trimming

### Stats

Core foundation, 45 tests, 0 failures
