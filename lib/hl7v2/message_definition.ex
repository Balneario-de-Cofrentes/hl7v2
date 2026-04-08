defmodule HL7v2.MessageDefinition do
  @moduledoc """
  Canonical message structure mappings and validation dispatch.

  Maps HL7v2 trigger events to their canonical message structures (e.g.,
  ADT^A04 → ADT_A01) and dispatches structural validation to
  `HL7v2.Standard.MessageStructure` and `HL7v2.Validation.Structural`.
  """

  # HL7 v2.5.1 canonical message structure map.
  # Many trigger events share the same abstract message definition.
  # If a {code, event} pair is not listed, the structure defaults to "CODE_EVENT".
  @canonical_structures %{
    # ADT aliases
    {"ADT", "A04"} => "ADT_A01",
    {"ADT", "A08"} => "ADT_A01",
    {"ADT", "A13"} => "ADT_A01",
    {"ADT", "A05"} => "ADT_A05",
    {"ADT", "A14"} => "ADT_A05",
    {"ADT", "A28"} => "ADT_A05",
    {"ADT", "A31"} => "ADT_A05",
    {"ADT", "A06"} => "ADT_A06",
    {"ADT", "A07"} => "ADT_A06",
    {"ADT", "A09"} => "ADT_A09",
    {"ADT", "A10"} => "ADT_A09",
    {"ADT", "A11"} => "ADT_A09",
    {"ADT", "A12"} => "ADT_A12",
    {"ADT", "A15"} => "ADT_A15",
    {"ADT", "A16"} => "ADT_A16",
    {"ADT", "A17"} => "ADT_A17",
    {"ADT", "A19"} => "ADR_A19",
    {"ADT", "A20"} => "ADT_A20",
    {"ADT", "A21"} => "ADT_A21",
    {"ADT", "A22"} => "ADT_A21",
    {"ADT", "A23"} => "ADT_A21",
    {"ADT", "A25"} => "ADT_A21",
    {"ADT", "A26"} => "ADT_A21",
    {"ADT", "A27"} => "ADT_A21",
    {"ADT", "A29"} => "ADT_A21",
    {"ADT", "A32"} => "ADT_A21",
    {"ADT", "A33"} => "ADT_A21",
    {"ADT", "A56"} => "ADT_A21",
    {"ADT", "A24"} => "ADT_A24",
    {"ADT", "A30"} => "ADT_A30",
    {"ADT", "A34"} => "ADT_A30",
    {"ADT", "A35"} => "ADT_A30",
    {"ADT", "A36"} => "ADT_A30",
    {"ADT", "A37"} => "ADT_A37",
    {"ADT", "A38"} => "ADT_A38",
    {"ADT", "A39"} => "ADT_A39",
    {"ADT", "A40"} => "ADT_A39",
    {"ADT", "A41"} => "ADT_A39",
    {"ADT", "A42"} => "ADT_A39",
    {"ADT", "A57"} => "ADT_A39",
    {"ADT", "A43"} => "ADT_A43",
    {"ADT", "A44"} => "ADT_A43",
    {"ADT", "A45"} => "ADT_A45",
    {"ADT", "A46"} => "ADT_A30",
    {"ADT", "A47"} => "ADT_A30",
    {"ADT", "A48"} => "ADT_A30",
    {"ADT", "A49"} => "ADT_A30",
    {"ADT", "A18"} => "ADT_A18",
    {"ADT", "A50"} => "ADT_A50",
    {"ADT", "A51"} => "ADT_A50",
    {"ADT", "A52"} => "ADT_A52",
    {"ADT", "A53"} => "ADT_A50",
    # BAR aliases
    {"BAR", "P01"} => "BAR_P01",
    {"BAR", "P02"} => "BAR_P02",
    {"BAR", "P05"} => "BAR_P05",
    {"BAR", "P06"} => "BAR_P06",
    {"BAR", "P10"} => "BAR_P10",
    {"BAR", "P12"} => "BAR_P12",
    # Blood Bank
    {"BPS", "O29"} => "BPS_O29",
    {"BRP", "O30"} => "BRP_O30",
    {"BRT", "O32"} => "BRT_O32",
    {"BTS", "O31"} => "BTS_O31",
    # Clinical Study — CRM C01-C08 share CRM_C01, CSU C09-C12 share CSU_C09
    {"CRM", "C01"} => "CRM_C01",
    {"CRM", "C02"} => "CRM_C01",
    {"CRM", "C03"} => "CRM_C01",
    {"CRM", "C04"} => "CRM_C01",
    {"CRM", "C05"} => "CRM_C01",
    {"CRM", "C06"} => "CRM_C01",
    {"CRM", "C07"} => "CRM_C01",
    {"CRM", "C08"} => "CRM_C01",
    {"CSU", "C09"} => "CSU_C09",
    {"CSU", "C10"} => "CSU_C09",
    {"CSU", "C11"} => "CSU_C09",
    {"CSU", "C12"} => "CSU_C09",
    # DFT
    {"DFT", "P03"} => "DFT_P03",
    {"DFT", "P11"} => "DFT_P11",
    # DOC
    {"DOC", "T12"} => "DOC_T12",
    # Equipment
    {"EAC", "U07"} => "EAC_U07",
    {"EAR", "U08"} => "EAR_U08",
    {"ESR", "U02"} => "ESR_U02",
    {"ESU", "U01"} => "ESU_U01",
    {"INR", "U06"} => "INR_U06",
    {"INU", "U05"} => "INU_U05",
    {"LSU", "U12"} => "LSU_U12",
    {"SSR", "U04"} => "SSR_U04",
    {"SSU", "U03"} => "SSU_U03",
    {"TCU", "U10"} => "TCU_U10",
    # MDM — odd triggers are notification-only, even triggers include content
    {"MDM", "T01"} => "MDM_T01",
    {"MDM", "T02"} => "MDM_T02",
    {"MDM", "T03"} => "MDM_T01",
    {"MDM", "T04"} => "MDM_T02",
    {"MDM", "T05"} => "MDM_T01",
    {"MDM", "T06"} => "MDM_T02",
    {"MDM", "T07"} => "MDM_T01",
    {"MDM", "T08"} => "MDM_T02",
    {"MDM", "T09"} => "MDM_T01",
    {"MDM", "T10"} => "MDM_T02",
    {"MDM", "T11"} => "MDM_T01",
    # Master File — MFN M03-M13 (not M02, M05 which have own) share MFN_M01
    {"MFK", "M01"} => "MFK_M01",
    {"MFK", "M02"} => "MFK_M01",
    {"MFK", "M03"} => "MFK_M01",
    {"MFK", "M04"} => "MFK_M01",
    {"MFK", "M05"} => "MFK_M01",
    {"MFK", "M06"} => "MFK_M01",
    {"MFK", "M07"} => "MFK_M01",
    {"MFK", "M08"} => "MFK_M01",
    {"MFK", "M09"} => "MFK_M01",
    {"MFK", "M10"} => "MFK_M01",
    {"MFK", "M11"} => "MFK_M01",
    {"MFK", "M12"} => "MFK_M01",
    {"MFK", "M13"} => "MFK_M01",
    {"MFN", "M01"} => "MFN_M01",
    {"MFN", "M02"} => "MFN_M02",
    {"MFN", "M03"} => "MFN_M03",
    {"MFN", "M04"} => "MFN_M04",
    {"MFN", "M05"} => "MFN_M05",
    {"MFN", "M06"} => "MFN_M06",
    {"MFN", "M07"} => "MFN_M07",
    {"MFN", "M08"} => "MFN_M08",
    {"MFN", "M09"} => "MFN_M09",
    {"MFN", "M10"} => "MFN_M10",
    {"MFN", "M11"} => "MFN_M11",
    {"MFN", "M12"} => "MFN_M12",
    {"MFN", "M13"} => "MFN_M13",
    {"MFQ", "M01"} => "MFQ_M01",
    # Network management
    {"NMD", "N02"} => "NMD_N02",
    {"NMQ", "N01"} => "NMQ_N01",
    {"NMR", "N01"} => "NMR_N01",
    # Orders
    {"OMB", "O27"} => "OMB_O27",
    {"OMD", "O03"} => "OMD_O03",
    {"OMG", "O19"} => "OMG_O19",
    {"OMI", "O23"} => "OMI_O23",
    {"OML", "O21"} => "OML_O21",
    {"OML", "O33"} => "OML_O33",
    {"OML", "O35"} => "OML_O35",
    {"OML", "O39"} => "OML_O39",
    {"OMN", "O07"} => "OMN_O07",
    {"OMP", "O09"} => "OMP_O09",
    {"OMS", "O05"} => "OMS_O05",
    {"ORA", "R33"} => "ORA_R33",
    {"ORA", "R41"} => "ORA_R41",
    {"ORB", "O28"} => "ORB_O28",
    {"ORD", "O04"} => "ORD_O04",
    {"ORG", "O20"} => "ORG_O20",
    {"ORI", "O24"} => "ORI_O24",
    {"ORL", "O22"} => "ORL_O22",
    {"ORL", "O34"} => "ORL_O34",
    {"ORL", "O36"} => "ORL_O36",
    {"ORL", "O40"} => "ORL_O40",
    {"ORM", "O01"} => "ORM_O01",
    {"ORN", "O08"} => "ORN_O08",
    {"ORP", "O10"} => "ORP_O10",
    {"ORR", "O02"} => "ORR_O02",
    {"ORS", "O06"} => "ORS_O06",
    {"ORU", "R30"} => "ORU_R30",
    {"ORU", "R31"} => "ORU_R30",
    {"ORU", "R32"} => "ORU_R30",
    {"OUL", "R21"} => "OUL_R21",
    {"OUL", "R22"} => "OUL_R22",
    {"OUL", "R23"} => "OUL_R23",
    {"OUL", "R24"} => "OUL_R24",
    # Pathway/Problem/Goal — PPR PC1-PC3, PGL PC6-PC8, PPP PCB-PCD, PPG PCG-PCJ
    {"PGL", "PC6"} => "PGL_PC6",
    {"PGL", "PC7"} => "PGL_PC6",
    {"PGL", "PC8"} => "PGL_PC6",
    {"PPG", "PCG"} => "PPG_PCG",
    {"PPG", "PCH"} => "PPG_PCG",
    {"PPG", "PCJ"} => "PPG_PCG",
    {"PPP", "PCB"} => "PPP_PCB",
    {"PPP", "PCC"} => "PPP_PCB",
    {"PPP", "PCD"} => "PPP_PCB",
    {"PPR", "PC1"} => "PPR_PC1",
    {"PPR", "PC2"} => "PPR_PC1",
    {"PPR", "PC3"} => "PPR_PC1",
    {"PPT", "PCL"} => "PPT_PCL",
    # Product Experience
    {"PEX", "P07"} => "PEX_P07",
    {"PEX", "P08"} => "PEX_P07",
    {"SUR", "P09"} => "SUR_P09",
    # Personnel — PMU B01-B08
    {"PMU", "B01"} => "PMU_B01",
    {"PMU", "B02"} => "PMU_B01",
    {"PMU", "B03"} => "PMU_B03",
    {"PMU", "B04"} => "PMU_B04",
    {"PMU", "B05"} => "PMU_B01",
    {"PMU", "B06"} => "PMU_B01",
    {"PMU", "B07"} => "PMU_B07",
    {"PMU", "B08"} => "PMU_B08",
    # Query
    {"QBP", "Q11"} => "QBP_Q11",
    {"QBP", "Q13"} => "QBP_Q13",
    {"QBP", "Q15"} => "QBP_Q15",
    {"QBP", "Q21"} => "QBP_Q21",
    {"QBP", "Q22"} => "QBP_Q21",
    {"QBP", "Q23"} => "QBP_Q21",
    {"QBP", "Q24"} => "QBP_Q21",
    {"QBP", "Q25"} => "QBP_Q21",
    {"QCK", "Q02"} => "QCK_Q02",
    {"QCN", "J01"} => "QCN_J01",
    {"QSB", "Q16"} => "QSB_Q16",
    {"QVR", "Q17"} => "QVR_Q17",
    {"RDY", "K15"} => "RDY_K15",
    {"RSP", "K11"} => "RSP_K11",
    {"RSP", "K13"} => "RSP_K13",
    {"RSP", "K15"} => "RSP_K15",
    {"RSP", "K21"} => "RSP_K21",
    {"RSP", "K22"} => "RSP_K21",
    {"RSP", "K31"} => "RSP_K31",
    {"RTB", "K13"} => "RTB_K13",
    # Pharmacy query responses
    {"RAR", "RAR"} => "RAR_RAR",
    {"RDR", "RDR"} => "RDR_RDR",
    {"RER", "RER"} => "RER_RER",
    {"ROR", "ROR"} => "ROR_ROR",
    # Pharmacy
    {"RAS", "O17"} => "RAS_O17",
    {"RDE", "O11"} => "RDE_O11",
    {"RDS", "O13"} => "RDS_O13",
    {"RGV", "O15"} => "RGV_O15",
    {"RRA", "O18"} => "RRA_O18",
    {"RRD", "O14"} => "RRD_O14",
    {"RRE", "O12"} => "RRE_O12",
    {"RRG", "O16"} => "RRG_O16",
    # Referral — REF/RRI I12-I15 share the same structures
    {"REF", "I12"} => "REF_I12",
    {"REF", "I13"} => "REF_I12",
    {"REF", "I14"} => "REF_I12",
    {"REF", "I15"} => "REF_I12",
    {"RRI", "I12"} => "RRI_I12",
    {"RRI", "I13"} => "RRI_I12",
    {"RRI", "I14"} => "RRI_I12",
    {"RRI", "I15"} => "RRI_I12",
    # SIU S12-S26 (except S25) share SIU_S12
    {"SIU", "S12"} => "SIU_S12",
    {"SIU", "S13"} => "SIU_S12",
    {"SIU", "S14"} => "SIU_S12",
    {"SIU", "S15"} => "SIU_S12",
    {"SIU", "S16"} => "SIU_S12",
    {"SIU", "S17"} => "SIU_S12",
    {"SIU", "S18"} => "SIU_S12",
    {"SIU", "S19"} => "SIU_S12",
    {"SIU", "S20"} => "SIU_S12",
    {"SIU", "S21"} => "SIU_S12",
    {"SIU", "S22"} => "SIU_S12",
    {"SIU", "S23"} => "SIU_S12",
    {"SIU", "S24"} => "SIU_S12",
    {"SIU", "S26"} => "SIU_S12",
    # SRM S01-S11 share SRM_S01, SRR S01-S11 share SRR_S01
    {"SRM", "S01"} => "SRM_S01",
    {"SRM", "S02"} => "SRM_S01",
    {"SRM", "S03"} => "SRM_S01",
    {"SRM", "S04"} => "SRM_S01",
    {"SRM", "S05"} => "SRM_S01",
    {"SRM", "S06"} => "SRM_S01",
    {"SRM", "S07"} => "SRM_S01",
    {"SRM", "S08"} => "SRM_S01",
    {"SRM", "S09"} => "SRM_S01",
    {"SRM", "S10"} => "SRM_S01",
    {"SRM", "S11"} => "SRM_S01",
    {"SRR", "S01"} => "SRR_S01",
    {"SRR", "S02"} => "SRR_S01",
    {"SRR", "S03"} => "SRR_S01",
    {"SRR", "S04"} => "SRR_S01",
    {"SRR", "S05"} => "SRR_S01",
    {"SRR", "S06"} => "SRR_S01",
    {"SRR", "S07"} => "SRR_S01",
    {"SRR", "S08"} => "SRR_S01",
    {"SRR", "S09"} => "SRR_S01",
    {"SRR", "S10"} => "SRR_S01",
    {"SRR", "S11"} => "SRR_S01",
    # Patient info requests/responses
    {"QRY", "A19"} => "QRY_A19",
    {"RCI", "I05"} => "RCI_I05",
    {"RPA", "I08"} => "RPA_I08",
    {"RPA", "I09"} => "RPA_I08",
    {"RPA", "I10"} => "RPA_I08",
    {"RPA", "I11"} => "RPA_I08",
    {"RPI", "I01"} => "RPI_I01",
    {"RPI", "I04"} => "RPI_I04",
    {"RPL", "I02"} => "RPL_I02",
    {"RPR", "I03"} => "RPR_I03",
    {"RQA", "I08"} => "RQA_I08",
    {"RQA", "I09"} => "RQA_I08",
    {"RQA", "I10"} => "RQA_I08",
    {"RQA", "I11"} => "RQA_I08",
    {"RQC", "I05"} => "RQC_I05",
    {"RQC", "I06"} => "RQC_I05",
    {"RQI", "I01"} => "RQI_I01",
    {"RQI", "I02"} => "RQI_I01",
    {"RQI", "I03"} => "RQI_I01",
    {"RQP", "I04"} => "RQP_I04",
    # Collaborative care
    {"CCR", "I16"} => "CCR_I16",
    {"CCR", "I17"} => "CCR_I16",
    {"CCR", "I18"} => "CCR_I16",
    {"CCI", "I22"} => "CCI_I22",
    {"CCU", "I20"} => "CCU_I20",
    {"CCU", "I21"} => "CCU_I20",
    {"CCQ", "I19"} => "CCQ_I19",
    {"CCF", "I22"} => "CCF_I22",
    # EHC (E-Health)
    {"EHC", "E01"} => "EHC_E01",
    {"EHC", "E02"} => "EHC_E02",
    {"EHC", "E04"} => "EHC_E04",
    {"EHC", "E10"} => "EHC_E10",
    {"EHC", "E12"} => "EHC_E12",
    {"EHC", "E13"} => "EHC_E13",
    {"EHC", "E15"} => "EHC_E15",
    {"EHC", "E20"} => "EHC_E20",
    {"EHC", "E21"} => "EHC_E21",
    {"EHC", "E24"} => "EHC_E24",
    # Master file response
    {"MFR", "M01"} => "MFR_M01",
    {"MFR", "M04"} => "MFR_M04",
    {"MFR", "M05"} => "MFR_M05",
    {"MFR", "M06"} => "MFR_M06",
    {"MFR", "M07"} => "MFR_M07",
    {"MFN", "M15"} => "MFN_M15",
    # Observation response
    {"ORF", "R04"} => "ORF_R04",
    # Legacy queries
    {"QRY", "Q01"} => "QRY_Q01",
    {"QRY", "Q02"} => "QRY_Q02",
    {"QRY", "R02"} => "QRY_R02",
    {"QRY", "PC4"} => "QRY_PC4",
    {"QRY", "PC5"} => "QRY_PC4",
    {"QRY", "PC9"} => "QRY_PC4",
    {"QRY", "PCE"} => "QRY_PC4",
    {"QRY", "PCK"} => "QRY_PC4",
    {"OSQ", "Q06"} => "OSQ_Q06",
    {"OSR", "Q06"} => "OSR_Q06",
    # Additional RSP responses
    {"RSP", "Q11"} => "RSP_Q11",
    {"RSP", "K23"} => "RSP_K23",
    {"RSP", "K24"} => "RSP_K23",
    {"RSP", "K25"} => "RSP_K25",
    {"RSP", "Z82"} => "RSP_Z82",
    {"RSP", "Z86"} => "RSP_Z86",
    {"RSP", "Z88"} => "RSP_Z88",
    {"RSP", "Z90"} => "RSP_Z90",
    # Scheduling query
    {"SQM", "S25"} => "SQM_S25",
    {"SQR", "S25"} => "SQR_S25",
    # UDM
    {"UDM", "Q05"} => "UDM_Q05",
    # Vaccination
    {"VXQ", "V01"} => "VXQ_V01",
    {"VXR", "V03"} => "VXR_V03",
    {"VXU", "V04"} => "VXU_V04",
    {"VXX", "V02"} => "VXX_V02",
    # ADT additional variants
    {"ADT", "A54"} => "ADT_A54",
    {"ADT", "A55"} => "ADT_A54",
    {"ADT", "A60"} => "ADT_A60",
    {"ADT", "A61"} => "ADT_A61",
    {"ADT", "A62"} => "ADT_A61",
    # -- Remaining v2.5.1 structures --
    {"EAN", "U09"} => "EAN_U09",
    {"PPV", "PCA"} => "PPV_PCA",
    {"PRR", "PC5"} => "PRR_PC5",
    {"PTR", "PCF"} => "PTR_PCF",
    {"QBP", "Z73"} => "QBP_Z73",
    {"RCL", "I06"} => "RCL_I06",
    {"RGR", "RGR"} => "RGR_RGR",
    {"RTB", "Z74"} => "RTB_Z74"
  }

  @doc """
  Returns the canonical message structure for a message code and trigger event.

  Many HL7v2 trigger events share the same abstract message definition. For
  example, ADT^A04, ADT^A08, and ADT^A13 all use the ADT_A01 structure.

  Falls back to `"CODE_EVENT"` when no canonical mapping exists.

  ## Examples

      iex> HL7v2.MessageDefinition.canonical_structure("ADT", "A28")
      "ADT_A05"

      iex> HL7v2.MessageDefinition.canonical_structure("ADT", "A01")
      "ADT_A01"

      iex> HL7v2.MessageDefinition.canonical_structure("ZZZ", "Z01")
      "ZZZ_Z01"

  """
  @spec canonical_structure(binary(), binary()) :: binary()
  def canonical_structure(code, event) do
    Map.get(@canonical_structures, {code, event}, "#{code}_#{event}")
  end

  @doc """
  Validates segment presence/structure against the message definition.

  Delegates to `HL7v2.Validation.Structural` for structures with group-aware
  definitions. Returns a warning for unknown structures.
  """
  @spec validate_structure(binary() | nil, [binary()]) :: :ok | {:error, [map()]}
  def validate_structure(nil, _segment_ids), do: :ok
  def validate_structure("", _segment_ids), do: :ok

  def validate_structure(structure, segment_ids) do
    case HL7v2.Standard.MessageStructure.get(structure) do
      %{} = struct_def ->
        case HL7v2.Validation.Structural.validate(struct_def, segment_ids) do
          [] -> :ok
          errors -> {:error, errors}
        end

      nil ->
        {:error,
         [
           %{
             level: :warning,
             location: "message",
             message:
               "message structure #{structure} has no validation definition — structure not checked"
           }
         ]}
    end
  end
end
