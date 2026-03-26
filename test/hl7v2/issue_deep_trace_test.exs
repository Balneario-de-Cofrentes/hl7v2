defmodule HL7v2.IssueDeepTraceTest do
  use ExUnit.Case, async: true

  alias HL7v2.Access

  @text "MSH|^~\\&|SEND|FAC||RCV|20260322120000||ADT^A01^ADT_A01|MSG001|P|2.5.1\rPID|1||12345^^^MRN^MR~67890^^^SSN^SS||Smith^John^Q||19800101|M\rPV1|1|I|W^389^1\r"

  setup_all do
    {:ok, msg} = HL7v2.parse(@text, mode: :typed)
    %{msg: msg}
  end

  test "ISSUE 1 DEEP: PID-3[0] trace", %{msg: msg} do
    # Get first and second identifiers to understand the issue
    id1 = Access.get(msg, "PID-3[1]")
    id2 = Access.get(msg, "PID-3[2]")
    id0 = Access.get(msg, "PID-3[0]")
    
    IO.puts("\n=== ISSUE 1: Zero Index ===")
    IO.puts("PID-3[1]: #{inspect(id1.id)}")
    IO.puts("PID-3[2]: #{inspect(id2.id)}")
    IO.puts("PID-3[0]: #{inspect(id0)}")
    
    if id0 != nil and id0.id == id2.id do
      IO.puts("\nBUG CONFIRMED: [0] returns the LAST item (id2), not the first!")
      IO.puts("This happens because: Enum.at(list, 0-1) = Enum.at(list, -1) → last item")
    end
  end

  test "ISSUE 1 VARIANT: PID-8[0] on non-repeating nil field", %{msg: msg} do
    # PID-8 is non-repeating and in the test data it's "M" (not nil actually)
    pid8_direct = Access.get(msg, "PID-8")
    pid8_rep1 = Access.get(msg, "PID-8[1]")
    pid8_rep0 = Access.get(msg, "PID-8[0]")
    
    IO.puts("\n=== PID-8 (non-repeating) ===")
    IO.puts("PID-8 direct: #{inspect(pid8_direct)}")
    IO.puts("PID-8[1]: #{inspect(pid8_rep1)}")
    IO.puts("PID-8[0]: #{inspect(pid8_rep0)}")
  end

  test "ISSUE 2 VARIANT: OBX-6[1] returns error correctly", %{msg: msg} do
    # Check if nil value affects the error
    result_fetch = Access.fetch(msg, "PID-8[1]")
    IO.puts("\n=== PID-8[1] fetch ===")
    IO.puts("Result: #{inspect(result_fetch)}")
    IO.puts("Note: PID-8 value is not nil in this message")
  end

  test "ISSUE 3: Repetition error on nil value", %{msg: msg} do
    # What if the field value is nil?
    # Then unwrap_and_select should still error
    result = Access.fetch(msg, "PID-7[1]")  # PID-7 might be nil
    IO.puts("\n=== Repetition on nil field ===")
    IO.puts("PID-7 (dob): #{inspect(Access.get(msg, "PID-7"))}")
    IO.puts("PID-7[1] fetch: #{inspect(result)}")
  end
end
