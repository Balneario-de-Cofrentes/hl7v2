defmodule HL7v2.Type.MSG do
  @moduledoc """
  Message Type (MSG) -- HL7v2 composite data type.

  Used in MSH-9 to identify the message type, trigger event, and structure.

  3 components:
  1. Message Code (ID) -- Table 0076: ADT, ORM, ORU, ACK, etc.
  2. Trigger Event (ID) -- Table 0003: A01, O01, R01, etc.
  3. Message Structure (ID) -- Table 0354: ADT_A01, ORM_O01, etc.
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:message_code, :trigger_event, :message_structure]

  @type t :: %__MODULE__{
          message_code: binary() | nil,
          trigger_event: binary() | nil,
          message_structure: binary() | nil
        }

  @doc """
  Parses a MSG from a list of components.

  ## Examples

      iex> HL7v2.Type.MSG.parse(["ADT", "A01", "ADT_A01"])
      %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01", message_structure: "ADT_A01"}

      iex> HL7v2.Type.MSG.parse(["ADT", "A01"])
      %HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"}

      iex> HL7v2.Type.MSG.parse([])
      %HL7v2.Type.MSG{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      message_code: Type.get_component(components, 0),
      trigger_event: Type.get_component(components, 1),
      message_structure: Type.get_component(components, 2)
    }
  end

  @doc """
  Encodes a MSG to a list of component strings.

  ## Examples

      iex> HL7v2.Type.MSG.encode(%HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01", message_structure: "ADT_A01"})
      ["ADT", "A01", "ADT_A01"]

      iex> HL7v2.Type.MSG.encode(%HL7v2.Type.MSG{message_code: "ADT", trigger_event: "A01"})
      ["ADT", "A01"]

      iex> HL7v2.Type.MSG.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = msg) do
    [
      msg.message_code || "",
      msg.trigger_event || "",
      msg.message_structure || ""
    ]
    |> Type.trim_trailing()
  end
end
