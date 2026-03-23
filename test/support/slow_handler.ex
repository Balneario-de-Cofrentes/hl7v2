defmodule HL7v2.Test.SlowHandler do
  @moduledoc false
  @behaviour HL7v2.MLLP.Handler

  @impl true
  def handle_message("slow", _meta) do
    Process.sleep(:infinity)
    {:ok, "never"}
  end

  def handle_message(message, _meta) do
    {:ok, message}
  end
end
