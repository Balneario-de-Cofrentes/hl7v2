defmodule HL7v2.Test.EchoHandler do
  @moduledoc false
  @behaviour HL7v2.MLLP.Handler

  @impl true
  def handle_message(message, _meta) do
    {:ok, message}
  end
end
