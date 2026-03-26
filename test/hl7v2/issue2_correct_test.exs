defmodule HL7v2.Issue2CorrectTest do
  use ExUnit.Case, async: true

  alias HL7v2.Access

  @oru_text "MSH|^~\\&|SEND|FAC||RCV||20260322||ORU^R01^ORU_R01|MSG001|P|2.5.1\r" <>
              "PID|1||12345^^^MRN^MR||Smith^John\r" <>
              "OBX|1|NM|WBC^White Blood Cell^LN||7.5|10*3/uL\r" <>
              "OBX|2|ST|RBC^Red Blood Cell^LN||NORMAL|10*6/uL\r"

  setup_all do
    {:ok, oru} = HL7v2.parse(@oru_text, mode: :typed)
    %{oru: oru}
  end

  test "OBX-5 is UNBOUNDED, not a good test for Issue 2", %{oru: oru} do
    # OBX-5 has max_reps: :unbounded, so [1] on OBX-5 is valid!
    result = Access.fetch(oru, "OBX-5[1]")
    IO.puts("\nOBX-5[1] (unbounded field): #{inspect(result)}")
  end

  test "ISSUE 2: PID-8[1] on non-repeating field", %{oru: oru} do
    # PID-8 is administrative_sex, max_reps: 1
    # So PID-8[1] should error
    
    result_get = Access.get(oru, "PID-8[1]")
    result_fetch = Access.fetch(oru, "PID-8[1]")
    
    IO.puts("\n=== ACTUAL ISSUE 2 TEST ===")
    IO.puts("PID-8 is non-repeating (max_reps=1)")
    IO.puts("PID-8 value: #{inspect(Access.get(oru, "PID-8"))}")
    IO.puts("PID-8[1] get: #{inspect(result_get)}")
    IO.puts("PID-8[1] fetch: #{inspect(result_fetch)}")
    
    if elem(result_fetch, 0) == :ok do
      IO.puts("BUG: Should return :invalid_repetition error!")
    end
  end

  test "ISSUE 2 with component: PID-8[1].1 on non-repeating field", %{oru: oru} do
    # Even more complex: non-repeating scalar field with both [1] and .1
    result = Access.fetch(oru, "PID-8[1].1")
    IO.puts("\nPID-8[1].1 fetch: #{inspect(result)}")
  end

  test "OBX-6 is non-repeating: OBX-6[1]", %{oru: oru} do
    # OBX-6 is units, max_reps: 1
    result_fetch = Access.fetch(oru, "OBX-6[1]")
    result_get = Access.get(oru, "OBX-6[1]")
    
    IO.puts("\n=== OBX-6[1] TEST ===")
    IO.puts("OBX-6 (units) is non-repeating")
    IO.puts("OBX-6 value: #{inspect(Access.get(oru, "OBX-6"))}")
    IO.puts("OBX-6[1] get: #{inspect(result_get)}")
    IO.puts("OBX-6[1] fetch: #{inspect(result_fetch)}")
  end
end
