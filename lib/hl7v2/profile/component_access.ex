defmodule HL7v2.Profile.ComponentAccess do
  @moduledoc """
  Positional component access for HL7 composite data type structs.

  `HL7v2.Profile.require_component/5` and `bind_table/4`'s
  struct-unwrap path both use 1-indexed component positions to match
  the IHE TF conventions — e.g. "PID-3 CX-4" targets component 4 of
  the `CX` composite. To extract the Nth component from a parsed
  struct, we need the canonical defstruct field order at runtime,
  which Elixir does not expose reliably for arbitrary structs. This
  module hardcodes the order for the composite types referenced by
  the shipped profiles.

  ## Registered types

  - `HL7v2.Type.CX` — 10 components (id, check_digit, ...
    assigning_authority, identifier_type_code, ...)
  - `HL7v2.Type.HD` — 3 components (namespace_id, universal_id,
    universal_id_type)
  - `HL7v2.Type.CE` — 6 components (identifier, text,
    name_of_coding_system, ...)
  - `HL7v2.Type.CWE` — 9 components (identifier, text,
    name_of_coding_system, ... original_text)

  ## Extending the registry

  To add a new composite type, append an entry to the internal
  `@component_fields` map with the struct fields listed in the exact
  order declared by the type module's `defstruct`. A compile-time
  guard raises if the declared fields do not match the type's actual
  defstruct keys, so typos and drift are caught immediately.

  Unknown types produce `{:error, {:unknown_composite_type, module}}`
  from `component_at/2`, which the profile rules surface as a clean
  error pointing at the gap. Open an issue or PR if you hit one.

  ## Example

      iex> HL7v2.Profile.ComponentAccess.component_at(
      ...>   %HL7v2.Type.HD{namespace_id: "MRN", universal_id: "1.2.3"},
      ...>   1
      ...> )
      {:ok, "MRN"}

      iex> HL7v2.Profile.ComponentAccess.component_at(
      ...>   %HL7v2.Type.CX{id: "12345", assigning_authority: %HL7v2.Type.HD{namespace_id: "MRN"}},
      ...>   4
      ...> )
      {:ok, %HL7v2.Type.HD{namespace_id: "MRN"}}

      iex> HL7v2.Profile.ComponentAccess.component_at(nil, 1)
      {:error, :nil_struct}
  """

  @component_fields %{
    HL7v2.Type.CX => [
      :id,
      :check_digit,
      :check_digit_scheme,
      :assigning_authority,
      :identifier_type_code,
      :assigning_facility,
      :effective_date,
      :expiration_date,
      :assigning_jurisdiction,
      :assigning_agency
    ],
    HL7v2.Type.HD => [
      :namespace_id,
      :universal_id,
      :universal_id_type
    ],
    HL7v2.Type.CE => [
      :identifier,
      :text,
      :name_of_coding_system,
      :alternate_identifier,
      :alternate_text,
      :name_of_alternate_coding_system
    ],
    HL7v2.Type.CWE => [
      :identifier,
      :text,
      :name_of_coding_system,
      :alternate_identifier,
      :alternate_text,
      :name_of_alternate_coding_system,
      :coding_system_version_id,
      :alternate_coding_system_version_id,
      :original_text
    ]
  }

  # Compile-time invariant: every declared field for a registered
  # type must exist on that type's defstruct. If a type module
  # renames or removes a field, this guard raises at compile time
  # so the DSL consumer cannot silently pick the wrong component.
  #
  # Field ORDER is checked at runtime in the tests
  # (component_access_test.exs) against the type module's `parse/1`
  # behavior — a change in defstruct order would break parse/encode
  # round-trip tests that already exist, giving us a second safety
  # net.
  for {type_module, expected_fields} <- @component_fields do
    actual_fields =
      type_module.__struct__()
      |> Map.from_struct()
      |> Map.keys()

    missing = expected_fields -- actual_fields

    if missing != [] do
      raise "HL7v2.Profile.ComponentAccess: type #{inspect(type_module)} " <>
              "is missing declared component fields #{inspect(missing)}. " <>
              "Reconcile @component_fields with the type's defstruct."
    end
  end

  @doc """
  Returns `{:ok, value}` for the nth component (1-indexed) of a parsed
  composite struct, or an error tuple for unknown types or
  out-of-range indices.
  """
  @spec component_at(struct() | nil, pos_integer()) ::
          {:ok, term()} | {:error, atom() | {atom(), module()}}
  def component_at(nil, _n), do: {:error, :nil_struct}

  def component_at(%module{} = struct, n) when is_integer(n) and n > 0 do
    case Map.get(@component_fields, module) do
      nil ->
        {:error, {:unknown_composite_type, module}}

      fields ->
        case Enum.at(fields, n - 1) do
          nil -> {:error, :component_out_of_range}
          field -> {:ok, Map.get(struct, field)}
        end
    end
  end

  @doc """
  Returns the canonical field atoms for a known composite type,
  or `nil` if the type is not registered.
  """
  @spec fields_for(module()) :: [atom()] | nil
  def fields_for(module), do: Map.get(@component_fields, module)
end
