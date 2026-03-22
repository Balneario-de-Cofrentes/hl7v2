defmodule HL7v2.Validation.MessageRules do
  @moduledoc """
  Message-level validation rules for HL7v2 typed messages.

  Checks structural invariants that apply to the message as a whole:
  first segment must be MSH, and critical MSH fields must be present.
  """

  alias HL7v2.TypedMessage

  @doc """
  Returns a list of message-level validation errors.

  Checks:
  - First segment is `%HL7v2.Segment.MSH{}`
  - `MSH.message_type` is present
  - `MSH.message_control_id` is present
  """
  @spec check(TypedMessage.t()) :: [map()]
  def check(%TypedMessage{segments: segments}) do
    case segments do
      [%HL7v2.Segment.MSH{} = msh | _] ->
        check_msh_fields(msh)

      [_ | _] ->
        [%{level: :error, location: "MSH", field: nil, message: "first segment must be MSH"}]

      [] ->
        [%{level: :error, location: "MSH", field: nil, message: "message has no segments"}]
    end
  end

  defp check_msh_fields(msh) do
    errors = []

    errors =
      if is_nil(msh.message_type) do
        [
          %{
            level: :error,
            location: "MSH",
            field: :message_type,
            message: "required field message_type is missing"
          }
          | errors
        ]
      else
        errors
      end

    errors =
      if is_nil(msh.message_control_id) do
        [
          %{
            level: :error,
            location: "MSH",
            field: :message_control_id,
            message: "required field message_control_id is missing"
          }
          | errors
        ]
      else
        errors
      end

    Enum.reverse(errors)
  end
end
