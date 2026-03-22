defmodule HL7v2.Type.NDL do
  @moduledoc """
  Name with Date and Location (NDL) -- HL7v2 composite data type.

  Used in OBR fields 32-35 to identify persons (interpreters, technicians,
  transcriptionists) along with the time and location of their activity.

  11 components per HL7 v2.5.1:
  1. Name (CNN) -- sub-components delimited by `&`
  2. Start Date/Time (TS) -- sub-components delimited by `&`
  3. End Date/Time (TS) -- sub-components delimited by `&`
  4. Point of Care (IS)
  5. Room (IS)
  6. Bed (IS)
  7. Facility (HD) -- sub-components delimited by `&`
  8. Location Status (IS)
  9. Patient Location Type (IS)
  10. Building (IS)
  11. Floor (IS)
  """

  @behaviour HL7v2.Type

  alias HL7v2.Type
  alias HL7v2.Type.{CNN, HD, TS, DTM}

  defstruct [
    :name,
    :start_date_time,
    :end_date_time,
    :point_of_care,
    :room,
    :bed,
    :facility,
    :location_status,
    :patient_location_type,
    :building,
    :floor
  ]

  @type t :: %__MODULE__{
          name: CNN.t() | nil,
          start_date_time: TS.t() | nil,
          end_date_time: TS.t() | nil,
          point_of_care: binary() | nil,
          room: binary() | nil,
          bed: binary() | nil,
          facility: HD.t() | nil,
          location_status: binary() | nil,
          patient_location_type: binary() | nil,
          building: binary() | nil,
          floor: binary() | nil
        }

  @doc """
  Parses an NDL from a list of components.

  Component 1 (Name/CNN), 2-3 (TS), and 7 (HD) contain sub-components
  delimited by `&`.

  ## Examples

      iex> HL7v2.Type.NDL.parse(["12345&Smith&John"])
      %HL7v2.Type.NDL{
        name: %HL7v2.Type.CNN{id_number: "12345", family_name: "Smith", given_name: "John"}
      }

      iex> HL7v2.Type.NDL.parse([])
      %HL7v2.Type.NDL{}

  """
  @spec parse(list()) :: t()
  def parse(components) when is_list(components) do
    %__MODULE__{
      name: parse_sub_cnn(Type.get_component(components, 0)),
      start_date_time: parse_sub_ts(Type.get_component(components, 1)),
      end_date_time: parse_sub_ts(Type.get_component(components, 2)),
      point_of_care: Type.get_component(components, 3),
      room: Type.get_component(components, 4),
      bed: Type.get_component(components, 5),
      facility: parse_sub_hd(Type.get_component(components, 6)),
      location_status: Type.get_component(components, 7),
      patient_location_type: Type.get_component(components, 8),
      building: Type.get_component(components, 9),
      floor: Type.get_component(components, 10)
    }
  end

  @doc """
  Encodes an NDL to a list of component strings.

  ## Examples

      iex> HL7v2.Type.NDL.encode(%HL7v2.Type.NDL{name: %HL7v2.Type.CNN{id_number: "12345", family_name: "Smith", given_name: "John"}})
      ["12345&Smith&John"]

      iex> HL7v2.Type.NDL.encode(nil)
      []

      iex> HL7v2.Type.NDL.encode(%HL7v2.Type.NDL{})
      []

  """
  @spec encode(t() | nil) :: list()
  def encode(nil), do: []

  def encode(%__MODULE__{} = ndl) do
    [
      encode_sub_cnn(ndl.name),
      encode_sub_ts(ndl.start_date_time),
      encode_sub_ts(ndl.end_date_time),
      ndl.point_of_care || "",
      ndl.room || "",
      ndl.bed || "",
      encode_sub_hd(ndl.facility),
      ndl.location_status || "",
      ndl.patient_location_type || "",
      ndl.building || "",
      ndl.floor || ""
    ]
    |> Type.trim_trailing()
  end

  # -- Sub-component parsing helpers --

  defp parse_sub_cnn(nil), do: nil

  defp parse_sub_cnn(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    cnn_val = CNN.parse(subs)
    if all_nil?(cnn_val), do: nil, else: cnn_val
  end

  defp encode_sub_cnn(nil), do: ""

  defp encode_sub_cnn(%CNN{} = cnn),
    do: cnn |> CNN.encode() |> Enum.join(Type.sub_component_separator())

  defp parse_sub_ts(nil), do: nil

  defp parse_sub_ts(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    ts_val = TS.parse(subs)

    if ts_val.time == nil and ts_val.degree_of_precision == nil do
      nil
    else
      ts_val
    end
  end

  defp encode_sub_ts(nil), do: ""

  defp encode_sub_ts(%TS{} = ts) do
    case TS.encode(ts) do
      [] -> ""
      parts -> Enum.join(parts, Type.sub_component_separator())
    end
  end

  defp encode_sub_ts(%DTM{} = dtm) do
    DTM.encode(dtm)
  end

  defp parse_sub_hd(nil), do: nil

  defp parse_sub_hd(value) when is_binary(value) do
    subs = String.split(value, Type.sub_component_separator())
    hd_val = HD.parse(subs)
    if all_nil?(hd_val), do: nil, else: hd_val
  end

  defp encode_sub_hd(nil), do: ""

  defp encode_sub_hd(%HD{} = hd_val),
    do: hd_val |> HD.encode() |> Enum.join(Type.sub_component_separator())

  defp all_nil?(struct) do
    struct
    |> Map.from_struct()
    |> Map.values()
    |> Enum.all?(&is_nil/1)
  end
end
