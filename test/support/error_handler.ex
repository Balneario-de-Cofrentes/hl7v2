defmodule HL7v2.Test.ErrorHandler do
  @moduledoc false
  @behaviour HL7v2.MLLP.Handler

  @impl true
  def handle_message("error", _meta) do
    {:error, :test_error}
  end

  def handle_message("raise", _meta) do
    raise "handler_exploded"
  end

  def handle_message(message, _meta) do
    {:ok, message}
  end
end
