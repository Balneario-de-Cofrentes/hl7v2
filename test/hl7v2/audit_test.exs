defmodule HL7v2.AuditTest do
  use ExUnit.Case, async: true

  alias HL7v2.Access

  @text "MSH|^~\\&|SEND|FAC||RCV|20260322120000||ADT^A01^ADT_A01|MSG001|P|2.5.1\rPID|1||12345^^^MRN^MR~67890^^^SSN^SS||Smith^John^Q||19800101|M\rPV1|1|I|W^389^1\rNTE|1||Note text\r"
  @oru_text "MSH|^~\\&|SEND|FAC||RCV||20260322||ORU^R01^ORU_R01|MSG001|P|2.5.1\r" <>
              "PID|1||12345^^^MRN^MR~67890^^^SSN^SS||Smith^John\r" <>
              "OBR|1||ORD001|CBC^Complete Blood Count^LN\r" <>
              "OBX|1|NM|WBC^White Blood Cell^LN||7.5|10*3/uL\r" <>
              "OBX|2|NM|RBC^Red Blood Cell^LN||4.8|10*6/uL\r"

  setup_all do
    {:ok, msg} = HL7v2.parse(@text, mode: :typed)
    {:ok, oru} = HL7v2.parse(@oru_text, mode: :typed)
    %{msg: msg, oru: oru}
  end

  # 1. Segment index on non-repeating segment
  test "1: PID[2] returns nil silently (should error?)", %{msg: msg} do
    result = Access.get(msg, "PID[2]")
    IO.puts("\n[1] PID[2] get: #{inspect(result)}")
    
    result_fetch = Access.fetch(msg, "PID[2]")
    IO.puts("[1] PID[2] fetch: #{inspect(result_fetch)}")
  end

  # 2. Negative indices (regex should reject)
  test "2: PID-3[-1] should be invalid_path", %{msg: msg} do
    result = Access.fetch(msg, "PID-3[-1]")
    IO.puts("\n[2] PID-3[-1] fetch: #{inspect(result)}")
    # Regex only accepts digits, not "-", so should be invalid_path
  end

  # 3. Zero indices (regex only accepts digits)
  test "3: PID-3[0] should be valid but return nil or error", %{msg: msg} do
    result = Access.fetch(msg, "PID-3[0]")
    IO.puts("\n[3] PID-3[0] fetch: #{inspect(result)}")
    # Regex allows 0, but HL7 is 1-based
  end

  # 4 & 5. Wildcard on non-repeating field
  test "4/5: PID-8[*] (non-repeating field) should error", %{msg: msg} do
    # PID-8 is administrative_sex, max_reps=1
    result_get = Access.get(msg, "PID-8[*]")
    result_fetch = Access.fetch(msg, "PID-8[*]")
    IO.puts("\n[4/5] PID-8[*] get: #{inspect(result_get)}")
    IO.puts("[4/5] PID-8[*] fetch: #{inspect(result_fetch)}")
    # Should return :invalid_repetition, not wrap in list
  end

  # 6. Component on list values
  test "6: OBX[*]-5.1 components on wildcard results", %{oru: oru} do
    result = Access.get(oru, "OBX[*]-5.1")
    IO.puts("\n[6] OBX[*]-5.1 get: #{inspect(result)}")
    # OBX-5 is NM, which is struct with :value and :original
    # .1 should map across list
  end

  # 7. Double selectors
  test "7: OBX[2]-5[1] segment index + repetition", %{oru: oru} do
    result = Access.fetch(oru, "OBX[2]-5[1]")
    IO.puts("\n[7] OBX[2]-5[1] fetch: #{inspect(result)}")
    # OBX[2]-5 is NM (not repeating), so [1] should be invalid
  end

  # 8. Out-of-range segment index
  test "8: OBX[999] out-of-range", %{oru: oru} do
    result = Access.fetch(oru, "OBX[999]")
    IO.puts("\n[8] OBX[999] fetch: #{inspect(result)}")
    # Should be {:error, :segment_not_found}
  end

  # 10. Component on NM struct
  test "10: OBX-5.1 on NM struct", %{oru: oru} do
    nm = Access.get(oru, "OBX-5")
    IO.puts("\n[10] OBX-5 full struct: #{inspect(nm)}")
    
    result = Access.get(oru, "OBX-5.1")
    IO.puts("[10] OBX-5.1 component: #{inspect(result)}")
    # NM struct order: :value, :original
    # .1 should be value (first field)
  end

  # 11. Component propagation on wildcard
  test "11: OBX[*]-5.99 out-of-range component on wildcard", %{oru: oru} do
    result_fetch = Access.fetch(oru, "OBX[*]-5.99")
    result_get = Access.get(oru, "OBX[*]-5.99")
    IO.puts("\n[11] OBX[*]-5.99 fetch: #{inspect(result_fetch)}")
    IO.puts("[11] OBX[*]-5.99 get: #{inspect(result_get)}")
    # Should propagate :invalid_component or return error
  end

  # 12. unwrap_and_select nil guard
  test "12: PID-99[2].1 non-existent field with selectors", %{msg: msg} do
    result = Access.fetch(msg, "PID-99[2].1")
    IO.puts("\n[12] PID-99[2].1 fetch: #{inspect(result)}")
    # Field 99 doesn't exist, should be {:error, :field_not_found}
  end
end
