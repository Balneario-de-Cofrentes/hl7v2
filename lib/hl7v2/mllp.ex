defmodule HL7v2.MLLP do
  @moduledoc """
  MLLP (Minimal Lower Layer Protocol) framing for HL7v2 messages.

  MLLP wraps each HL7v2 message in a simple frame:

      <SB>message<EB><CR>

  Where:
  - SB (Start Block) = `0x0B`
  - EB (End Block)   = `0x1C`
  - CR (Carriage Return) = `0x0D`

  See HL7 Implementation Technology Specification — Minimal Lower Layer Protocol.
  """

  @compile {:inline, frame: 1}

  @sb 0x0B
  @eb 0x1C
  @cr 0x0D

  @doc """
  Wraps a message binary in an MLLP frame.

  ## Examples

      iex> HL7v2.MLLP.frame("MSH|...")
      <<0x0B, "MSH|...", 0x1C, 0x0D>>

  """
  @spec frame(binary()) :: binary()
  def frame(message) when is_binary(message) do
    <<@sb, message::binary, @eb, @cr>>
  end

  @doc """
  Extracts the message from an MLLP frame.

  Returns `{:ok, message}` when the binary starts with SB and ends with EB+CR.
  Returns `{:error, :invalid_frame}` otherwise.

  ## Examples

      iex> HL7v2.MLLP.unframe(<<0x0B, "MSH|...", 0x1C, 0x0D>>)
      {:ok, "MSH|..."}

      iex> HL7v2.MLLP.unframe("bad")
      {:error, :invalid_frame}

  """
  @spec unframe(binary()) :: {:ok, binary()} | {:error, :invalid_frame}
  def unframe(<<@sb, rest::binary>>) do
    case :binary.split(rest, <<@eb, @cr>>) do
      [message, <<>>] -> {:ok, message}
      _ -> {:error, :invalid_frame}
    end
  end

  def unframe(_), do: {:error, :invalid_frame}

  @doc """
  Extracts complete MLLP messages from a buffer.

  Returns `{messages, remaining_buffer}` where `messages` is a list of
  extracted message binaries (without MLLP framing) and `remaining_buffer`
  contains any incomplete data that needs more bytes.

  ## Examples

      iex> HL7v2.MLLP.extract_messages(<<0x0B, "MSG1", 0x1C, 0x0D, 0x0B, "MSG2", 0x1C, 0x0D>>)
      {["MSG1", "MSG2"], <<>>}

      iex> HL7v2.MLLP.extract_messages(<<0x0B, "MSG1", 0x1C, 0x0D, 0x0B, "partial">>)
      {["MSG1"], <<0x0B, "partial">>}

  """
  @spec extract_messages(binary()) :: {[binary()], binary()}
  def extract_messages(buffer) do
    extract_messages(buffer, [])
  end

  defp extract_messages(<<@sb, rest::binary>> = buffer, acc) do
    case :binary.split(rest, <<@eb, @cr>>) do
      [message, remainder] ->
        extract_messages(remainder, [message | acc])

      [_incomplete] ->
        {Enum.reverse(acc), buffer}
    end
  end

  defp extract_messages(<<>>, acc) do
    {Enum.reverse(acc), <<>>}
  end

  # Data before an SB byte — skip leading garbage
  defp extract_messages(buffer, acc) do
    case :binary.split(buffer, <<@sb>>) do
      [_garbage, rest] ->
        extract_messages(<<@sb, rest::binary>>, acc)

      [_no_sb] ->
        {Enum.reverse(acc), buffer}
    end
  end
end
