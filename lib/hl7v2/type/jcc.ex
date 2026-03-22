defmodule HL7v2.Type.JCC do
  @moduledoc """
  Job Code/Class (JCC) -- HL7v2 composite data type.

  Used for employment classification.

  2 components:
  1. Job Code (IS)
  2. Job Class (IS)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type

  defstruct [:job_code, :job_class]

  @type t :: %__MODULE__{
          job_code: binary() | nil,
          job_class: binary() | nil
        }

  @doc """
  Parses a JCC from a list of components.

  ## Examples

      iex> HL7v2.Type.JCC.parse(["NURSE", "FT"])
      %HL7v2.Type.JCC{job_code: "NURSE", job_class: "FT"}

      iex> HL7v2.Type.JCC.parse(["ADMIN"])
      %HL7v2.Type.JCC{job_code: "ADMIN"}

      iex> HL7v2.Type.JCC.parse([])
      %HL7v2.Type.JCC{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      job_code: Type.get_component(components, 0),
      job_class: Type.get_component(components, 1)
    }
  end

  @doc """
  Encodes a JCC to a list of component strings.

  ## Examples

      iex> HL7v2.Type.JCC.encode(%HL7v2.Type.JCC{job_code: "NURSE", job_class: "FT"})
      ["NURSE", "FT"]

      iex> HL7v2.Type.JCC.encode(%HL7v2.Type.JCC{job_code: "ADMIN"})
      ["ADMIN"]

      iex> HL7v2.Type.JCC.encode(nil)
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = jcc) do
    [
      jcc.job_code || "",
      jcc.job_class || ""
    ]
    |> Type.trim_trailing()
  end
end
