# Conformance Profiles

Conformance profiles let you validate HL7 v2 messages against
organization-specific constraints beyond the base HL7 spec.

## What is a profile?

A profile is a set of rules that extend the base HL7 schema:

- **Required segments** — this message type MUST contain segment X
- **Forbidden segments** — this message type MUST NOT contain segment Y
- **Required fields** — beyond what the base spec requires (e.g. PID-18
  is optional in the spec but required in your integration)
- **Table bindings** — override which HL7 table a coded field must be in
- **Cardinality** — this message must have between N and M occurrences
  of segment X
- **Value constraints** — arbitrary predicates on field values
- **Custom rules** — multi-segment business logic

## Building a profile

Profiles are built via the functional `HL7v2.Profile` DSL:

```elixir
profile =
  HL7v2.Profile.new("Hospital_ADT_A01", message_type: {"ADT", "A01"})
  |> HL7v2.Profile.require_segment("NK1")
  |> HL7v2.Profile.require_field("PID", 18)
  |> HL7v2.Profile.require_cardinality("OBX", min: 1, max: 10)
  |> HL7v2.Profile.bind_table("PV1", 14, "0069")
  |> HL7v2.Profile.require_value_in("PV1", 2, ["I", "O", "E"])
```

### Declarative DSL builders (recommended)

| Builder | Purpose |
|---|---|
| `require_segment/2` | segment must appear at least once |
| `forbid_segment/2` | segment must not appear |
| `require_field/3` | field must be populated when its segment is present |
| `forbid_field/3` | field must be blank/absent when its segment is present |
| `require_value/5` | field must equal a specific value (with optional `:accessor`) |
| `require_value_in/5` | field must be in a specific allowed-value list |
| `require_component/5` | composite field must have a specific component (or subcomponent) populated — supports `:each_repetition`, `:subcomponent`, `:repetition` |
| `bind_table/4` | field value must be in a specific HL7 table (uses `HL7v2.Standard.Tables`) |
| `require_cardinality/3` | segment must appear within a `{min, max}` range |

All builders above store the constraint as **data** — no closures,
no opaque function references. That means your profiles are:

- **Introspectable**: `inspect(profile)` shows a full data tree
- **Serializable**: the profile can be round-tripped through
  JSON/YAML/etc. (minus the optional `:accessor` function)
- **Diffable**: two profiles can be compared structurally
- **Reusable**: a profile built by one module can be composed,
  extended, or loaded by another without executing code

### Custom rule escape hatches

For cases the declarative DSL can't express (custom predicates,
multi-field invariants, cross-segment rules), two escape hatches
remain:

- `add_value_constraint/4` — a 1-arity closure that receives the
  field value and returns `true`, `false`, or `{:error, reason}`.
- `add_rule/3` — a 1-arity closure that receives the whole
  typed message and returns a list of error maps.

Both still run as part of `HL7v2.Validation.ProfileRules.check/2`
and are fully integrated with the evaluation pipeline. Use them
sparingly — the declarative DSL is preferred because closures are
opaque to tooling.

### Value pinning examples

```elixir
# Simple equality pin
profile
|> HL7v2.Profile.require_value("PV1", 2, "N")

# Allowed-values list
profile
|> HL7v2.Profile.require_value_in("MSA", 1, ["AA", "AE", "AR"])

# Struct-component pin via :accessor
# (QPD-1 is a CE — validate only its identifier component)
profile
|> HL7v2.Profile.require_value("QPD", 1, "IHE PIX Query",
     accessor: & &1.identifier)
```

### Component targeting examples

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

`require_component` currently supports the composite types
registered in `HL7v2.Profile.ComponentAccess`: CX, HD, CE, CWE.
Additional types are a one-line addition — open an issue or PR.

## Validating with a profile

Pass the profile via the `:profile` option to `HL7v2.validate/2`:

```elixir
case HL7v2.validate(msg, profile: profile) do
  :ok ->
    IO.puts("valid against profile")

  {:error, errors} ->
    for %{rule: rule, location: loc, message: msg} <- errors do
      IO.puts("[\#{rule}] \#{loc}: \#{msg}")
    end
end
```

You can also pass a list of profiles:

```elixir
HL7v2.validate(msg, profile: [profile_1, profile_2, profile_3])
```

Profiles with a specific `:message_type` only apply to matching
messages — a profile keyed to `{"ADT", "A01"}` is silently skipped
for an ORU_R01 message.

## Example profiles

The library ships with example profiles in `HL7v2.Profiles.Examples`:

- `hospital_adt_a01/0` — strict hospital ADT profile
- `ihe_lab_oru_r01/0` — IHE-style lab results profile

Copy and customize these for your use case.

## Profile error shape

Profile violations follow the standard validation error shape plus
two profile-specific keys:

```elixir
%{
  level: :error,              # or :warning
  location: "PID",            # segment ID
  field: :patient_account_number,  # field name (if applicable)
  message: "profile requires PID-18 to be populated",
  rule: :require_field,       # which rule type fired
  profile: "Hospital_ADT_A01" # which profile produced this error
}
```

This makes it easy to trace violations back to a specific profile
when multiple profiles are active.

## Custom business rules

For complex multi-segment rules, use `add_rule/3`:

```elixir
profile
|> HL7v2.Profile.add_rule(:guarantor_required_for_inpatient, fn msg ->
  has_inpatient_pv1? = ...  # your logic
  has_gt1? = ...

  if has_inpatient_pv1? and not has_gt1? do
    [%{
      level: :error,
      location: "GT1",
      field: nil,
      message: "guarantor required for inpatient visits"
    }]
  else
    []
  end
end)
```

Custom rule functions receive the full `%HL7v2.TypedMessage{}` and
return a list of error maps. Exceptions inside custom rules are
caught and treated as silent — they don't crash validation.
