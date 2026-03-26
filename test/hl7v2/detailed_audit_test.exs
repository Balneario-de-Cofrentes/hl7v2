defmodule HL7v2.DetailedAuditTest do
  use ExUnit.Case, async: true

  alias HL7v2.Access

  @oru_text "MSH|^~\\&|SEND|FAC||RCV||20260322||ORU^R01^ORU_R01|MSG001|P|2.5.1\r" <>
              "PID|1||12345^^^MRN^MR~67890^^^SSN^SS||Smith^John\r" <>
              "OBR|1||ORD001|CBC^Complete Blood Count^LN\r" <>
              "OBX|1|NM|WBC^White Blood Cell^LN||7.5|10*3/uL\r" <>
              "OBX|2|NM|RBC^Red Blood Cell^LN||4.8|10*6/uL\r"

  setup_all do
    {:ok, oru} = HL7v2.parse(@oru_text, mode: :typed)
    %{oru: oru}
  end

  # Issue 3: Zero index should not be valid (HL7 is 1-based)
  test "ISSUE 3: PID-3[0] returns second item instead of error", %{oru: oru} do
    result = Access.fetch(oru, "PID-3[0]")
    IO.puts("\nISSUE 3: PID-3[0]")
    IO.puts("  Result: #{inspect(result)}")
    # With [0], should get nil or error, not second item
    # The issue is Enum.at(list, 0 - 1) = Enum.at(list, -1) which in Elixir returns last item!
  end

  # Issue 5: Repetition on non-repeating field
  test "ISSUE 5: OBX[2]-5[1] should error on non-repeating field", %{oru: oru} do
    obx2_field5 = Access.get(oru, "OBX[2]-5")
    IO.puts("\nISSUE 5: OBX[2]-5[1]")
    IO.puts("  OBX[2]-5 is: #{inspect(obx2_field5)}")
    IO.puts("  OBX[2]-5 is NM struct (non-repeating)")
    
    result = Access.fetch(oru, "OBX[2]-5[1]")
    IO.puts("  OBX[2]-5[1] fetch: #{inspect(result)}")
    # Should be {:error, :invalid_repetition} not {:ok, ...}
  end

  # Issue 11: Inconsistency between get and fetch for out-of-range component
  test "ISSUE 11: OBX[*]-5.99 inconsistent get vs fetch", %{oru: oru} do
    result_get = Access.get(oru, "OBX[*]-5.99")
    result_fetch = Access.fetch(oru, "OBX[*]-5.99")
    IO.puts("\nISSUE 11: OBX[*]-5.99")
    IO.puts("  get: #{inspect(result_get)}")
    IO.puts("  fetch: #{inspect(result_fetch)}")
    # get returns [nil, nil] but fetch returns error - inconsistent!
  end

  # Issue 12: Check if PID-99-related is actually invalid_path
  test "ISSUE 12: Path validation for invalid field", %{oru: oru} do
    # Let's try without the selectors first
    result1 = Access.fetch(oru, "PID-99")
    IO.puts("\nISSUE 12: PID-99 path resolution")
    IO.puts("  PID-99 fetch: #{inspect(result1)}")
    
    result2 = Access.fetch(oru, "PID-99[2]")
    IO.puts("  PID-99[2] fetch: #{inspect(result2)}")
    
    result3 = Access.fetch(oru, "PID-99[2].1")
    IO.puts("  PID-99[2].1 fetch: #{inspect(result3)}")
  end

  # Additional issue: Out-of-range component on single value
  test "Additional: OBX-5.99 out-of-range component", %{oru: oru} do
    result = Access.fetch(oru, "OBX-5.99")
    IO.puts("\nADDITIONAL: OBX-5.99 out-of-range component")
    IO.puts("  Result: #{inspect(result)}")
  end
end
