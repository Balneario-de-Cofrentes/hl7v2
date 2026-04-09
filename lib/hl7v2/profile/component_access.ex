defmodule HL7v2.Profile.ComponentAccess do
  @moduledoc false

  # Canonical component field order for composite HL7 data types.
  #
  # `HL7v2.Profile.require_component/5` uses positional (integer)
  # component indices to match the IHE TF conventions — e.g.
  # "PID-3 repetition N, CX-4". To extract the Nth component from a
  # parsed struct, we need the defstruct field order at runtime, which
  # Elixir does not expose reliably for structs larger than a trivial
  # size. This module hardcodes the order for the composite types
  # that appear in the shipped IHE profiles.
  #
  # Adding a new type: add an entry to `@component_fields` matching
  # the defstruct order declared in the corresponding `HL7v2.Type.*`
  # module. If a type is referenced by a profile but missing here,
  # `component_at/2` returns `{:error, {:unknown_composite_type, mod}}`
  # and the profile check will emit a clean error that points at the
  # gap.

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
