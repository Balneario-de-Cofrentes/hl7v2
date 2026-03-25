defmodule HL7v2.Segment.SAC do
  @moduledoc """
  Specimen Container Detail (SAC) segment -- HL7v2 v2.5.1.

  Contains specimen container detail information.
  44 fields per HL7 v2.5.1 specification. Fields 1-25 are typed,
  fields 26-44 use :raw.
  """

  use HL7v2.Segment,
    id: "SAC",
    fields: [
      {1, :external_accession_identifier, HL7v2.Type.EI, :o, 1},
      {2, :accession_identifier, HL7v2.Type.EI, :o, 1},
      {3, :container_identifier, HL7v2.Type.EI, :o, 1},
      {4, :primary_parent_container_identifier, HL7v2.Type.EI, :o, 1},
      {5, :equipment_container_identifier, HL7v2.Type.EI, :o, 1},
      {6, :specimen_source, HL7v2.Type.SPS, :o, 1},
      {7, :registration_date_time, HL7v2.Type.TS, :o, 1},
      {8, :container_status, HL7v2.Type.CE, :o, 1},
      {9, :carrier_type, HL7v2.Type.CE, :o, 1},
      {10, :carrier_identifier, HL7v2.Type.EI, :o, 1},
      {11, :position_in_carrier, HL7v2.Type.CE, :o, 1},
      {12, :tray_type, HL7v2.Type.CE, :o, 1},
      {13, :tray_identifier, HL7v2.Type.EI, :o, 1},
      {14, :position_in_tray, HL7v2.Type.CE, :o, 1},
      {15, :location, HL7v2.Type.CE, :o, :unbounded},
      {16, :container_height, HL7v2.Type.NM, :o, 1},
      {17, :container_diameter, HL7v2.Type.NM, :o, 1},
      {18, :barrier_delta, HL7v2.Type.NM, :o, 1},
      {19, :bottom_delta, HL7v2.Type.NM, :o, 1},
      {20, :container_height_diameter_delta_units, HL7v2.Type.CE, :o, 1},
      {21, :container_volume, HL7v2.Type.NM, :o, 1},
      {22, :available_specimen_volume, HL7v2.Type.NM, :o, 1},
      {23, :initial_specimen_volume, HL7v2.Type.NM, :o, 1},
      {24, :volume_units, HL7v2.Type.CE, :o, 1},
      {25, :separator_type, HL7v2.Type.CE, :o, 1},
      {26, :field_26, :raw, :o, 1},
      {27, :field_27, :raw, :o, 1},
      {28, :field_28, :raw, :o, 1},
      {29, :field_29, :raw, :o, 1},
      {30, :field_30, :raw, :o, 1},
      {31, :field_31, :raw, :o, 1},
      {32, :field_32, :raw, :o, 1},
      {33, :field_33, :raw, :o, 1},
      {34, :field_34, :raw, :o, 1},
      {35, :field_35, :raw, :o, 1},
      {36, :field_36, :raw, :o, 1},
      {37, :field_37, :raw, :o, 1},
      {38, :field_38, :raw, :o, 1},
      {39, :field_39, :raw, :o, 1},
      {40, :field_40, :raw, :o, 1},
      {41, :field_41, :raw, :o, 1},
      {42, :field_42, :raw, :o, 1},
      {43, :field_43, :raw, :o, 1},
      {44, :field_44, :raw, :o, 1}
    ]
end
