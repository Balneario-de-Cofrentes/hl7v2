defmodule HL7v2.Type.SPD do
  @moduledoc """
  Specialty Description (SPD) -- HL7v2 composite data type.

  Describes a practitioner's specialty or board certification.

  4 components:
  1. Specialty Name (ST)
  2. Governing Board (ST)
  3. Eligible or Certified (ID) -- C (certified), E (eligible)
  4. Date of Certification (DT)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.DT

  defstruct [:specialty_name, :governing_board, :eligible_or_certified, :date_of_certification]

  @type t :: %__MODULE__{
          specialty_name: binary() | nil,
          governing_board: binary() | nil,
          eligible_or_certified: binary() | nil,
          date_of_certification: Date.t() | DT.t() | nil
        }

  @doc """
  Parses an SPD from a list of components.

  ## Examples

      iex> HL7v2.Type.SPD.parse(["Cardiology", "ABIM", "C", "20200601"])
      %HL7v2.Type.SPD{specialty_name: "Cardiology", governing_board: "ABIM", eligible_or_certified: "C", date_of_certification: ~D[2020-06-01]}

      iex> HL7v2.Type.SPD.parse(["Internal Medicine"])
      %HL7v2.Type.SPD{specialty_name: "Internal Medicine"}

      iex> HL7v2.Type.SPD.parse([])
      %HL7v2.Type.SPD{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      specialty_name: Type.get_component(components, 0),
      governing_board: Type.get_component(components, 1),
      eligible_or_certified: Type.get_component(components, 2),
      date_of_certification: components |> Type.get_component(3) |> DT.parse()
    }
  end

  @doc """
  Encodes an SPD to a list of component strings.

  ## Examples

      iex> HL7v2.Type.SPD.encode(%HL7v2.Type.SPD{specialty_name: "Cardiology", governing_board: "ABIM", eligible_or_certified: "C", date_of_certification: ~D[2020-06-01]})
      ["Cardiology", "ABIM", "C", "20200601"]

      iex> HL7v2.Type.SPD.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = spd) do
    [
      spd.specialty_name || "",
      spd.governing_board || "",
      spd.eligible_or_certified || "",
      DT.encode(spd.date_of_certification)
    ]
    |> Type.trim_trailing()
  end
end
