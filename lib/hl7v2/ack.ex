defmodule HL7v2.Ack do
  @moduledoc """
  Builds HL7v2 ACK/NAK response messages.

  Given an original message's MSH segment, generates an acknowledgment message
  with properly swapped sender/receiver fields and a matching message control ID
  in the MSA segment.

  ## Examples

      iex> msh = %HL7v2.Segment.MSH{
      ...>   field_separator: "|",
      ...>   encoding_characters: "^~\\\\&",
      ...>   sending_application: %HL7v2.Type.HD{namespace_id: "SENDER"},
      ...>   receiving_application: %HL7v2.Type.HD{namespace_id: "RECEIVER"},
      ...>   message_type: %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"},
      ...>   message_control_id: "MSG001",
      ...>   processing_id: %HL7v2.Type.PT{processing_id: "P"},
      ...>   version_id: %HL7v2.Type.VID{version_id: "2.5.1"}
      ...> }
      iex> {ack_msh, msa} = HL7v2.Ack.accept(msh)
      iex> msa.acknowledgment_code
      "AA"
      iex> msa.message_control_id
      "MSG001"
      iex> ack_msh.sending_application.namespace_id
      "RECEIVER"

  """

  alias HL7v2.Segment.{MSH, MSA, ERR}
  alias HL7v2.Type.{MSG, TS, DTM, CWE}
  alias HL7v2.{RawMessage, Encoder, Separator}

  @doc """
  Builds an AA (Application Accept) acknowledgment.

  Returns `{ack_msh, msa}`.

  ## Options

    * `:text` — optional text message for MSA-3
    * `:message_control_id` — override the generated ACK message control ID

  """
  @spec accept(MSH.t(), keyword()) :: {MSH.t(), MSA.t()}
  def accept(%MSH{} = original_msh, opts \\ []) do
    build(original_msh, "AA", opts)
  end

  @doc """
  Builds an AE (Application Error) acknowledgment.

  Returns `{ack_msh, msa}` or `{ack_msh, msa, err}` when `:error_code` is provided.

  ## Options

    * `:text` — optional text message for MSA-3
    * `:error_code` — HL7 error code identifier (e.g., "207"); triggers ERR segment
    * `:error_text` — descriptive text for the error code
    * `:severity` — error severity: "E" (error), "W" (warning), "I" (information); defaults to "E"
    * `:message_control_id` — override the generated ACK message control ID

  """
  @spec error(MSH.t(), keyword()) :: {MSH.t(), MSA.t()} | {MSH.t(), MSA.t(), ERR.t()}
  def error(%MSH{} = original_msh, opts \\ []) do
    build(original_msh, "AE", opts)
  end

  @doc """
  Builds an AR (Application Reject) acknowledgment.

  Returns `{ack_msh, msa}` or `{ack_msh, msa, err}` when `:error_code` is provided.

  ## Options

    * `:text` — optional text message for MSA-3
    * `:error_code` — HL7 error code identifier (e.g., "207"); triggers ERR segment
    * `:error_text` — descriptive text for the error code
    * `:severity` — error severity: "E" (error), "W" (warning), "I" (information); defaults to "E"
    * `:message_control_id` — override the generated ACK message control ID

  """
  @spec reject(MSH.t(), keyword()) :: {MSH.t(), MSA.t()} | {MSH.t(), MSA.t(), ERR.t()}
  def reject(%MSH{} = original_msh, opts \\ []) do
    build(original_msh, "AR", opts)
  end

  @doc """
  Encodes an ACK response to wire format.

  Accepts the tuple returned by `accept/2`, `error/2`, or `reject/2`.

  ## Examples

      iex> msh = %HL7v2.Segment.MSH{
      ...>   field_separator: "|",
      ...>   encoding_characters: "^~\\\\&",
      ...>   sending_application: %HL7v2.Type.HD{namespace_id: "SENDER"},
      ...>   message_type: %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"},
      ...>   message_control_id: "MSG001",
      ...>   processing_id: %HL7v2.Type.PT{processing_id: "P"},
      ...>   version_id: %HL7v2.Type.VID{version_id: "2.5.1"}
      ...> }
      iex> ack = HL7v2.Ack.accept(msh)
      iex> wire = HL7v2.Ack.encode(ack)
      iex> String.starts_with?(wire, "MSH|^~\\\\&|")
      true

  """
  @spec encode({MSH.t(), MSA.t()} | {MSH.t(), MSA.t(), ERR.t()}) :: binary()
  def encode({%MSH{} = msh, %MSA{} = msa}) do
    encode_segments(msh, [{"MSA", MSA.encode(msa)}])
  end

  def encode({%MSH{} = msh, %MSA{} = msa, %ERR{} = err}) do
    encode_segments(msh, [{"MSA", MSA.encode(msa)}, {"ERR", ERR.encode(err)}])
  end

  # -- Private --

  defp build(original_msh, ack_code, opts) do
    ack_msh = build_ack_msh(original_msh, opts)
    msa = build_msa(original_msh, ack_code, opts)

    if ack_code != "AA" and Keyword.has_key?(opts, :error_code) do
      err = build_err(opts)
      {ack_msh, msa, err}
    else
      {ack_msh, msa}
    end
  end

  defp build_ack_msh(original_msh, opts) do
    original_trigger =
      case original_msh.message_type do
        %MSG{trigger_event: te} when is_binary(te) -> te
        _ -> nil
      end

    control_id = Keyword.get_lazy(opts, :message_control_id, &generate_control_id/0)

    %MSH{
      field_separator: original_msh.field_separator || "|",
      encoding_characters: original_msh.encoding_characters || "^~\\&",
      sending_application: original_msh.receiving_application,
      sending_facility: original_msh.receiving_facility,
      receiving_application: original_msh.sending_application,
      receiving_facility: original_msh.sending_facility,
      date_time_of_message: now_ts(),
      message_type: %MSG{
        message_code: "ACK",
        trigger_event: original_trigger,
        message_structure: "ACK"
      },
      message_control_id: control_id,
      processing_id: original_msh.processing_id,
      version_id: original_msh.version_id
    }
  end

  defp build_msa(original_msh, ack_code, opts) do
    %MSA{
      acknowledgment_code: ack_code,
      message_control_id: original_msh.message_control_id,
      text_message: Keyword.get(opts, :text)
    }
  end

  defp build_err(opts) do
    error_code = Keyword.get(opts, :error_code)
    error_text = Keyword.get(opts, :error_text)
    severity = Keyword.get(opts, :severity, "E")

    %ERR{
      hl7_error_code: %CWE{
        identifier: error_code,
        text: error_text
      },
      severity: severity
    }
  end

  defp encode_segments(%MSH{} = msh, extra_segments) do
    sep = separator_from_msh(msh)
    msh_fields = MSH.encode(msh)

    raw = %RawMessage{
      separators: sep,
      type: extract_type(msh),
      segments: [{"MSH", msh_fields} | extra_segments]
    }

    Encoder.encode(raw)
  end

  defp separator_from_msh(%MSH{} = msh) do
    enc = msh.encoding_characters || "^~\\&"

    case enc do
      <<c, r, e, s>> ->
        %Separator{
          field: char_to_int(msh.field_separator) || ?|,
          component: c,
          repetition: r,
          escape: e,
          sub_component: s
        }

      _ ->
        Separator.default()
    end
  end

  defp char_to_int(<<c>>), do: c
  defp char_to_int(_), do: nil

  defp extract_type(%MSH{message_type: %MSG{message_code: mc, trigger_event: te}})
       when is_binary(mc) do
    {mc, te || ""}
  end

  defp extract_type(_), do: {"ACK", ""}

  defp now_ts do
    now = NaiveDateTime.utc_now()

    %TS{
      time: %DTM{
        year: now.year,
        month: now.month,
        day: now.day,
        hour: now.hour,
        minute: now.minute,
        second: now.second
      }
    }
  end

  defp generate_control_id do
    # Use system time in microseconds + random suffix for uniqueness
    ts = System.system_time(:microsecond)
    rand = :rand.uniform(9999)
    "ACK#{ts}#{rand}"
  end
end
