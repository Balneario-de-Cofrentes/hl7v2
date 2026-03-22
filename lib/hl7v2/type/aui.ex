defmodule HL7v2.Type.AUI do
  @moduledoc """
  Authorization Information (AUI) -- HL7v2 composite data type.

  Used to convey insurance authorization details.

  3 components:
  1. Authorization Number (ST)
  2. Date (DT)
  3. Source (ST)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.DT

  defstruct [:authorization_number, :date, :source]

  @type t :: %__MODULE__{
          authorization_number: binary() | nil,
          date: Date.t() | DT.t() | nil,
          source: binary() | nil
        }

  @doc """
  Parses an AUI from a list of components.

  ## Examples

      iex> HL7v2.Type.AUI.parse(["AUTH123", "20260315", "BCBS"])
      %HL7v2.Type.AUI{authorization_number: "AUTH123", date: ~D[2026-03-15], source: "BCBS"}

      iex> HL7v2.Type.AUI.parse(["AUTH123"])
      %HL7v2.Type.AUI{authorization_number: "AUTH123"}

      iex> HL7v2.Type.AUI.parse([])
      %HL7v2.Type.AUI{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      authorization_number: Type.get_component(components, 0),
      date: components |> Type.get_component(1) |> DT.parse(),
      source: Type.get_component(components, 2)
    }
  end

  @doc """
  Encodes an AUI to a list of component strings.

  ## Examples

      iex> HL7v2.Type.AUI.encode(%HL7v2.Type.AUI{authorization_number: "AUTH123", date: ~D[2026-03-15], source: "BCBS"})
      ["AUTH123", "20260315", "BCBS"]

      iex> HL7v2.Type.AUI.encode(%HL7v2.Type.AUI{authorization_number: "AUTH123"})
      ["AUTH123"]

      iex> HL7v2.Type.AUI.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = aui) do
    [
      aui.authorization_number || "",
      DT.encode(aui.date),
      aui.source || ""
    ]
    |> Type.trim_trailing()
  end
end
