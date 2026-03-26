defmodule HL7v2.Segment.SAC do
  @moduledoc """
  Specimen Container Detail (SAC) segment -- HL7v2 v2.5.1.

  Contains specimen container detail information.
  44 fields per HL7 v2.5.1 specification.
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
      {26, :cap_type, HL7v2.Type.CE, :o, 1},
      {27, :additive, HL7v2.Type.CWE, :o, :unbounded},
      {28, :specimen_component, HL7v2.Type.CE, :o, 1},
      {29, :dilution_factor, HL7v2.Type.SN, :o, 1},
      {30, :treatment, HL7v2.Type.CE, :o, 1},
      {31, :temperature, HL7v2.Type.SN, :o, 1},
      {32, :hemolysis_index, HL7v2.Type.NM, :o, 1},
      {33, :hemolysis_index_units, HL7v2.Type.CE, :o, 1},
      {34, :lipemia_index, HL7v2.Type.NM, :o, 1},
      {35, :lipemia_index_units, HL7v2.Type.CE, :o, 1},
      {36, :icterus_index, HL7v2.Type.NM, :o, 1},
      {37, :icterus_index_units, HL7v2.Type.CE, :o, 1},
      {38, :fibrin_index, HL7v2.Type.NM, :o, 1},
      {39, :fibrin_index_units, HL7v2.Type.CE, :o, 1},
      {40, :system_induced_contaminants, HL7v2.Type.CE, :o, :unbounded},
      {41, :drug_interference, HL7v2.Type.CE, :o, :unbounded},
      {42, :artificial_blood, HL7v2.Type.CE, :o, 1},
      {43, :special_handling_code, HL7v2.Type.CWE, :o, :unbounded},
      {44, :other_environmental_factors, HL7v2.Type.CE, :o, :unbounded}
    ]
end
