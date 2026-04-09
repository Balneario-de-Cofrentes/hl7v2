defmodule HL7v2.Profile do
  @moduledoc """
  Conformance profile for constraining HL7v2 message structures beyond
  the base HL7 spec.

  A profile lets integrators express "our hospital's version of ADT_A01"
  in terms of segment requirements, field constraints, table bindings,
  cardinality, and value predicates. Profiles are evaluated alongside
  structural, field, and conditional validation via `HL7v2.validate/2`:

      profile =
        HL7v2.Profile.new("MyHospital_ADT_A01", message_type: {"ADT", "A01"})
        |> HL7v2.Profile.require_segment("ROL")
        |> HL7v2.Profile.require_field("PID", 18)
        |> HL7v2.Profile.bind_table("PV1", 14, "0069")
        |> HL7v2.Profile.require_cardinality("OBX", min: 1, max: 10)

      HL7v2.validate(msg, profile: profile)

  Profiles are pure data — no code execution at load time. Custom business
  rules can be added via `add_rule/3` which takes a function that receives
  the typed message and returns a list of error maps.
  """

  @type segment_id :: String.t()
  @type field_seq :: pos_integer()
  @type table_id :: String.t() | atom()
  @type cardinality :: {non_neg_integer(), non_neg_integer() | :unbounded}

  @type error :: %{
          level: :error | :warning,
          location: String.t(),
          field: atom() | nil,
          message: String.t(),
          rule: atom(),
          profile: String.t()
        }

  @type custom_rule :: (HL7v2.TypedMessage.t() -> [error()])

  @type t :: %__MODULE__{
          name: String.t(),
          message_type: {String.t(), String.t()} | nil,
          version: String.t() | nil,
          description: String.t(),
          required_segments: MapSet.t(segment_id()),
          forbidden_segments: MapSet.t(segment_id()),
          required_fields: %{{segment_id(), field_seq()} => :required},
          field_table_bindings: %{{segment_id(), field_seq()} => table_id()},
          cardinality_constraints: %{segment_id() => cardinality()},
          value_constraints: %{
            {segment_id(), field_seq()} => (term() -> boolean() | {:error, String.t()})
          },
          custom_rules: [{atom(), custom_rule()}]
        }

  defstruct name: "",
            message_type: nil,
            version: nil,
            description: "",
            required_segments: nil,
            forbidden_segments: nil,
            required_fields: %{},
            field_table_bindings: %{},
            cardinality_constraints: %{},
            value_constraints: %{},
            custom_rules: []

  @doc """
  Creates a new empty profile.

  ## Options

  - `:message_type` — tuple `{code, event}`, e.g. `{"ADT", "A01"}`. When set,
    the profile only applies to messages matching this type. Nil means the
    profile applies to any message.
  - `:version` — HL7 version this profile targets (e.g. `"2.5.1"`). Nil means
    any version.
  - `:description` — human-readable description.

  ## Examples

      iex> profile = HL7v2.Profile.new("Minimal", message_type: {"ADT", "A01"})
      iex> profile.name
      "Minimal"
      iex> profile.message_type
      {"ADT", "A01"}
  """
  @spec new(String.t(), keyword()) :: t()
  def new(name, opts \\ []) when is_binary(name) do
    %__MODULE__{
      name: name,
      message_type: Keyword.get(opts, :message_type),
      version: Keyword.get(opts, :version),
      description: Keyword.get(opts, :description, ""),
      required_segments: MapSet.new(),
      forbidden_segments: MapSet.new()
    }
  end

  @doc """
  Requires a segment to appear at least once in the message.

  ## Examples

      iex> HL7v2.Profile.new("p")
      ...> |> HL7v2.Profile.require_segment("ROL")
      ...> |> HL7v2.Profile.required_segments?()
      ["ROL"]
  """
  @spec require_segment(t(), segment_id()) :: t()
  def require_segment(%__MODULE__{} = profile, segment_id) when is_binary(segment_id) do
    %{profile | required_segments: MapSet.put(profile.required_segments, segment_id)}
  end

  @doc """
  Forbids a segment from appearing in the message.
  """
  @spec forbid_segment(t(), segment_id()) :: t()
  def forbid_segment(%__MODULE__{} = profile, segment_id) when is_binary(segment_id) do
    %{profile | forbidden_segments: MapSet.put(profile.forbidden_segments, segment_id)}
  end

  @doc """
  Requires a specific field in a segment to be populated.

  ## Examples

      iex> HL7v2.Profile.new("p")
      ...> |> HL7v2.Profile.require_field("PID", 18)
      ...> |> Map.get(:required_fields)
      %{{"PID", 18} => :required}
  """
  @spec require_field(t(), segment_id(), field_seq()) :: t()
  def require_field(%__MODULE__{} = profile, segment_id, field_seq)
      when is_binary(segment_id) and is_integer(field_seq) and field_seq > 0 do
    key = {segment_id, field_seq}
    %{profile | required_fields: Map.put(profile.required_fields, key, :required)}
  end

  @doc """
  Binds a coded field to a specific HL7 table, overriding any base binding.
  """
  @spec bind_table(t(), segment_id(), field_seq(), table_id()) :: t()
  def bind_table(%__MODULE__{} = profile, segment_id, field_seq, table_id)
      when is_binary(segment_id) and is_integer(field_seq) and field_seq > 0 do
    key = {segment_id, field_seq}
    %{profile | field_table_bindings: Map.put(profile.field_table_bindings, key, table_id)}
  end

  @doc """
  Sets cardinality constraints on a segment.

  ## Examples

      iex> HL7v2.Profile.new("p") |> HL7v2.Profile.require_cardinality("OBX", min: 1, max: 10)
      ...> |> Map.get(:cardinality_constraints)
      %{"OBX" => {1, 10}}

      iex> HL7v2.Profile.new("p") |> HL7v2.Profile.require_cardinality("NTE", min: 0, max: :unbounded)
      ...> |> Map.get(:cardinality_constraints)
      %{"NTE" => {0, :unbounded}}
  """
  @spec require_cardinality(t(), segment_id(), keyword()) :: t()
  def require_cardinality(%__MODULE__{} = profile, segment_id, opts)
      when is_binary(segment_id) and is_list(opts) do
    min = Keyword.fetch!(opts, :min)
    max = Keyword.fetch!(opts, :max)
    key = segment_id

    %{
      profile
      | cardinality_constraints: Map.put(profile.cardinality_constraints, key, {min, max})
    }
  end

  @doc """
  Adds a value constraint for a field. The constraint function receives the
  parsed field value and returns `true`, `false`, or `{:error, message}`.
  """
  @spec add_value_constraint(
          t(),
          segment_id(),
          field_seq(),
          (term() -> boolean() | {:error, String.t()})
        ) :: t()
  def add_value_constraint(%__MODULE__{} = profile, segment_id, field_seq, fun)
      when is_binary(segment_id) and is_integer(field_seq) and is_function(fun, 1) do
    key = {segment_id, field_seq}
    %{profile | value_constraints: Map.put(profile.value_constraints, key, fun)}
  end

  @doc """
  Adds a custom business rule. The rule function receives the full typed
  message and returns a list of error maps.
  """
  @spec add_rule(t(), atom(), custom_rule()) :: t()
  def add_rule(%__MODULE__{} = profile, rule_name, fun)
      when is_atom(rule_name) and is_function(fun, 1) do
    %{profile | custom_rules: [{rule_name, fun} | profile.custom_rules]}
  end

  @doc """
  Returns the sorted list of required segment IDs.
  """
  @spec required_segments?(t()) :: [segment_id()]
  def required_segments?(%__MODULE__{required_segments: set}) do
    set |> MapSet.to_list() |> Enum.sort()
  end

  @doc """
  Returns the sorted list of forbidden segment IDs.
  """
  @spec forbidden_segments?(t()) :: [segment_id()]
  def forbidden_segments?(%__MODULE__{forbidden_segments: set}) do
    set |> MapSet.to_list() |> Enum.sort()
  end

  @doc """
  Returns true if this profile applies to the given message type tuple.
  A nil message_type (wildcard) matches any type.
  """
  @spec applies_to?(t(), {String.t(), String.t()} | nil) :: boolean()
  def applies_to?(%__MODULE__{message_type: nil}, _), do: true
  def applies_to?(%__MODULE__{message_type: profile_type}, msg_type), do: profile_type == msg_type
end
