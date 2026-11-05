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

  def handle_message("throw", _meta) do
    throw("handler_threw")
  end

  # The value comes from `meta` so the compiler cannot see the mismatch.
  def handle_message("badmatch", meta) do
    {:ok, _} = Map.get(meta, :no_such_key, {:error, "handler_badmatch"})
  end

  def handle_message(message, _meta) do
    {:ok, message}
  end
end
