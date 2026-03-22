defmodule HL7v2.Type.PRL do
  @moduledoc """
  Parent Result Link (PRL) -- HL7v2 composite data type.

  Links a child observation to its parent observation result.

  3 components:
  1. Parent Observation Identifier (CE) -- sub-components delimited by `&`
  2. Parent Observation Sub-Identifier (ST)
  3. Parent Observation Value Descriptor (TX)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.CE

  defstruct [
    :parent_observation_identifier,
    :parent_observation_sub_identifier,
    :parent_observation_value_descriptor
  ]

  @type t :: %__MODULE__{
          parent_observation_identifier: CE.t() | nil,
          parent_observation_sub_identifier: binary() | nil,
          parent_observation_value_descriptor: binary() | nil
        }

  @doc """
  Parses a PRL from a list of components.

  ## Examples

      iex> HL7v2.Type.PRL.parse(["85025&CBC&CPT4", "1", "Hemoglobin"])
      %HL7v2.Type.PRL{
        parent_observation_identifier: %HL7v2.Type.CE{identifier: "85025", text: "CBC", name_of_coding_system: "CPT4"},
        parent_observation_sub_identifier: "1",
        parent_observation_value_descriptor: "Hemoglobin"
      }

      iex> HL7v2.Type.PRL.parse(["85025&CBC&CPT4"])
      %HL7v2.Type.PRL{parent_observation_identifier: %HL7v2.Type.CE{identifier: "85025", text: "CBC", name_of_coding_system: "CPT4"}}

      iex> HL7v2.Type.PRL.parse([])
      %HL7v2.Type.PRL{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      parent_observation_identifier: parse_sub_ce(Type.get_component(components, 0)),
      parent_observation_sub_identifier: Type.get_component(components, 1),
      parent_observation_value_descriptor: Type.get_component(components, 2)
    }
  end

  @doc """
  Encodes a PRL to a list of component strings.

  ## Examples

      iex> HL7v2.Type.PRL.encode(%HL7v2.Type.PRL{parent_observation_identifier: %HL7v2.Type.CE{identifier: "85025", text: "CBC", name_of_coding_system: "CPT4"}, parent_observation_sub_identifier: "1"})
      ["85025&CBC&CPT4", "1"]

      iex> HL7v2.Type.PRL.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = prl) do
    [
      encode_sub_ce(prl.parent_observation_identifier),
      prl.parent_observation_sub_identifier || "",
      prl.parent_observation_value_descriptor || ""
    ]
    |> Type.trim_trailing()
  end

  defp parse_sub_ce(nil), do: nil

  defp parse_sub_ce(value) when is_binary(value) do
    subs = String.split(value, "&")
    ce_val = CE.parse(subs)
    if all_nil?(ce_val), do: nil, else: ce_val
  end

  defp encode_sub_ce(nil), do: ""
  defp encode_sub_ce(%CE{} = ce), do: ce |> CE.encode() |> Enum.join("&")

  defp all_nil?(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&is_nil/1)
  end
end
