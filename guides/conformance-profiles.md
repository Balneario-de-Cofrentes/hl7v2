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
  |> HL7v2.Profile.add_value_constraint("PV1", 2, fn value ->
       value in ["I", "O", "E"]
     end)
```

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
