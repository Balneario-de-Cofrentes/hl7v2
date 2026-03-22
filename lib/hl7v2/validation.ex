defmodule HL7v2.Validation do
  @moduledoc """
  Validates HL7v2 typed messages.

  Opt-in validation that returns accumulated errors without blocking parsing.
  Call `validate/1` on a `HL7v2.TypedMessage` to check message-level and
  field-level rules.

  ## Examples

      {:ok, msg} = HL7v2.parse(text, mode: :typed)
      :ok = HL7v2.Validation.validate(msg)

      {:error, errors} = HL7v2.Validation.validate(invalid_msg)
      # errors is a list of %{level: :error | :warning, location: ..., field: ..., message: ...}

  """

  alias HL7v2.TypedMessage
  alias HL7v2.Validation.{MessageRules, FieldRules}

  @doc """
  Validates a typed message.

  Returns `:ok` when no errors are found, or `{:error, errors}` with a list
  of error/warning maps.

  Each error map has:
  - `:level` — `:error` or `:warning`
  - `:location` — segment identifier (e.g., `"MSH"`, `"PID"`)
  - `:field` — field name atom or `nil` for structural issues
  - `:message` — human-readable description
  """
  @spec validate(TypedMessage.t()) :: :ok | {:error, [map()]}
  def validate(%TypedMessage{} = msg) do
    errors =
      MessageRules.check(msg) ++
        Enum.flat_map(msg.segments, &FieldRules.check/1)

    case errors do
      [] -> :ok
      errors -> {:error, errors}
    end
  end
end
