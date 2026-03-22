defmodule HL7v2.TelemetryTest do
  use ExUnit.Case, async: true

  @msg "MSH|^~\\&|SEND|FAC||RCV|20240101||ADT^A01|123|P|2.5\r"

  defmodule Handler do
    @moduledoc false
    def handle_event(event, measurements, metadata, %{pid: pid, ref: ref}) do
      send(pid, {ref, event, measurements, metadata})
    end
  end

  setup do
    ref = make_ref()
    handler_id = "telemetry-test-#{inspect(ref)}"

    :telemetry.attach_many(
      handler_id,
      [
        [:hl7v2, :parse, :start],
        [:hl7v2, :parse, :stop],
        [:hl7v2, :encode, :start],
        [:hl7v2, :encode, :stop]
      ],
      &Handler.handle_event/4,
      %{pid: self(), ref: ref}
    )

    on_exit(fn -> :telemetry.detach(handler_id) end)

    {:ok, ref: ref}
  end

  describe "parse/2 telemetry" do
    test "emits :start and :stop events", %{ref: ref} do
      {:ok, _raw} = HL7v2.parse(@msg)

      assert_receive {^ref, [:hl7v2, :parse, :start], %{system_time: _}, %{mode: :raw}}
      assert_receive {^ref, [:hl7v2, :parse, :stop], %{duration: duration}, %{mode: :raw}}
      assert is_integer(duration) and duration >= 0
    end

    test "emits events with :typed mode metadata", %{ref: ref} do
      {:ok, _typed} = HL7v2.parse(@msg, mode: :typed)

      assert_receive {^ref, [:hl7v2, :parse, :start], _measurements, %{mode: :typed}}
      assert_receive {^ref, [:hl7v2, :parse, :stop], _measurements, %{mode: :typed}}
    end
  end

  describe "encode/1 telemetry" do
    test "emits events for RawMessage", %{ref: ref} do
      {:ok, raw} = HL7v2.Parser.parse(@msg)

      _wire = HL7v2.encode(raw)

      assert_receive {^ref, [:hl7v2, :encode, :start], %{system_time: _}, %{type: :raw}}
      assert_receive {^ref, [:hl7v2, :encode, :stop], %{duration: duration}, %{type: :raw}}
      assert is_integer(duration) and duration >= 0
    end

    test "emits events for Message struct", %{ref: ref} do
      msg = HL7v2.Message.new("ADT", "A01", sending_application: "TEST")

      _wire = HL7v2.encode(msg)

      assert_receive {^ref, [:hl7v2, :encode, :start], _measurements, %{type: :message}}
      assert_receive {^ref, [:hl7v2, :encode, :stop], _measurements, %{type: :message}}
    end

    test "emits events for TypedMessage", %{ref: ref} do
      {:ok, typed} = HL7v2.Parser.parse(@msg, mode: :typed)

      _wire = HL7v2.encode(typed)

      assert_receive {^ref, [:hl7v2, :encode, :start], _measurements, %{type: :typed}}
      assert_receive {^ref, [:hl7v2, :encode, :stop], _measurements, %{type: :typed}}
    end
  end

  describe "HL7v2.Telemetry.span/3" do
    test "returns the function result" do
      result = HL7v2.Telemetry.span(:test_op, %{}, fn -> {:ok, 42} end)
      assert result == {:ok, 42}
    end
  end

  describe "HL7v2.Telemetry.emit/3" do
    test "emits a custom event", %{ref: ref} do
      handler_id = "custom-emit-#{inspect(ref)}"

      :telemetry.attach(
        handler_id,
        [:hl7v2, :custom],
        &Handler.handle_event/4,
        %{pid: self(), ref: ref}
      )

      HL7v2.Telemetry.emit(:custom, %{count: 1}, %{source: :test})

      assert_receive {^ref, [:hl7v2, :custom], %{count: 1}, %{source: :test}}

      :telemetry.detach(handler_id)
    end
  end
end
