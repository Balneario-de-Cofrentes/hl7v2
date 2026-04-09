defmodule HL7v2.TypedParser do
  @moduledoc """
  Converts a raw-parsed HL7v2 message into typed segment structs.

  Each segment in the `RawMessage` is dispatched to its corresponding segment
  module via a registry lookup:

  - **Known segments** (MSH, PID, PV1, ...) are parsed through
    `SegmentModule.parse(raw_fields, separators)`.
  - **Z-segments** (names starting with `"Z"`) become `HL7v2.Segment.ZXX` structs
    via `ZXX.new/2`, preserving the original segment name.
  - **Unknown segments** are kept as raw `{name, fields}` tuples so nothing is lost.
  """

  alias HL7v2.{RawMessage, TypedMessage}
  alias HL7v2.Segment.ZXX

  @segment_modules %{
    "ABS" => HL7v2.Segment.ABS,
    "ACC" => HL7v2.Segment.ACC,
    "ADD" => HL7v2.Segment.ADD,
    "AFF" => HL7v2.Segment.AFF,
    "AIG" => HL7v2.Segment.AIG,
    "AIL" => HL7v2.Segment.AIL,
    "AIP" => HL7v2.Segment.AIP,
    "AIS" => HL7v2.Segment.AIS,
    "AL1" => HL7v2.Segment.AL1,
    "APR" => HL7v2.Segment.APR,
    "ARQ" => HL7v2.Segment.ARQ,
    "ARV" => HL7v2.Segment.ARV,
    "AUT" => HL7v2.Segment.AUT,
    "BHS" => HL7v2.Segment.BHS,
    "BLC" => HL7v2.Segment.BLC,
    "BLG" => HL7v2.Segment.BLG,
    "BPO" => HL7v2.Segment.BPO,
    "BPX" => HL7v2.Segment.BPX,
    "BTS" => HL7v2.Segment.BTS,
    "BTX" => HL7v2.Segment.BTX,
    "CDM" => HL7v2.Segment.CDM,
    "CER" => HL7v2.Segment.CER,
    "CM0" => HL7v2.Segment.CM0,
    "CM1" => HL7v2.Segment.CM1,
    "CM2" => HL7v2.Segment.CM2,
    "CNS" => HL7v2.Segment.CNS,
    "CON" => HL7v2.Segment.CON,
    "CSP" => HL7v2.Segment.CSP,
    "CSR" => HL7v2.Segment.CSR,
    "CSS" => HL7v2.Segment.CSS,
    "CTD" => HL7v2.Segment.CTD,
    "CTI" => HL7v2.Segment.CTI,
    "DB1" => HL7v2.Segment.DB1,
    "DG1" => HL7v2.Segment.DG1,
    "DRG" => HL7v2.Segment.DRG,
    "DSC" => HL7v2.Segment.DSC,
    "DSP" => HL7v2.Segment.DSP,
    "ECD" => HL7v2.Segment.ECD,
    "ECR" => HL7v2.Segment.ECR,
    "EDU" => HL7v2.Segment.EDU,
    "EQL" => HL7v2.Segment.EQL,
    "EQP" => HL7v2.Segment.EQP,
    "EQU" => HL7v2.Segment.EQU,
    "ERQ" => HL7v2.Segment.ERQ,
    "ERR" => HL7v2.Segment.ERR,
    "EVN" => HL7v2.Segment.EVN,
    "FAC" => HL7v2.Segment.FAC,
    "FHS" => HL7v2.Segment.FHS,
    "FT1" => HL7v2.Segment.FT1,
    "FTS" => HL7v2.Segment.FTS,
    "GOL" => HL7v2.Segment.GOL,
    "GP1" => HL7v2.Segment.GP1,
    "GP2" => HL7v2.Segment.GP2,
    "GT1" => HL7v2.Segment.GT1,
    "IAM" => HL7v2.Segment.IAM,
    "IAR" => HL7v2.Segment.IAR,
    "IIM" => HL7v2.Segment.IIM,
    "IN1" => HL7v2.Segment.IN1,
    "IN2" => HL7v2.Segment.IN2,
    "IN3" => HL7v2.Segment.IN3,
    "INV" => HL7v2.Segment.INV,
    "IPC" => HL7v2.Segment.IPC,
    "ISD" => HL7v2.Segment.ISD,
    "LAN" => HL7v2.Segment.LAN,
    "LCC" => HL7v2.Segment.LCC,
    "LCH" => HL7v2.Segment.LCH,
    "LDP" => HL7v2.Segment.LDP,
    "LOC" => HL7v2.Segment.LOC,
    "LRL" => HL7v2.Segment.LRL,
    "MFA" => HL7v2.Segment.MFA,
    "MFE" => HL7v2.Segment.MFE,
    "MFI" => HL7v2.Segment.MFI,
    "MRG" => HL7v2.Segment.MRG,
    "MSA" => HL7v2.Segment.MSA,
    "MSH" => HL7v2.Segment.MSH,
    "NCK" => HL7v2.Segment.NCK,
    "NDS" => HL7v2.Segment.NDS,
    "NSC" => HL7v2.Segment.NSC,
    "NST" => HL7v2.Segment.NST,
    "NK1" => HL7v2.Segment.NK1,
    "NPU" => HL7v2.Segment.NPU,
    "NTE" => HL7v2.Segment.NTE,
    "OBR" => HL7v2.Segment.OBR,
    "OBX" => HL7v2.Segment.OBX,
    "ODS" => HL7v2.Segment.ODS,
    "ODT" => HL7v2.Segment.ODT,
    "ORC" => HL7v2.Segment.ORC,
    "OM1" => HL7v2.Segment.OM1,
    "OM2" => HL7v2.Segment.OM2,
    "OM3" => HL7v2.Segment.OM3,
    "OM4" => HL7v2.Segment.OM4,
    "OM5" => HL7v2.Segment.OM5,
    "OM6" => HL7v2.Segment.OM6,
    "OM7" => HL7v2.Segment.OM7,
    "ORG" => HL7v2.Segment.ORG,
    "OVR" => HL7v2.Segment.OVR,
    "PCR" => HL7v2.Segment.PCR,
    "PD1" => HL7v2.Segment.PD1,
    "PDA" => HL7v2.Segment.PDA,
    "PDC" => HL7v2.Segment.PDC,
    "PEO" => HL7v2.Segment.PEO,
    "PES" => HL7v2.Segment.PES,
    "PID" => HL7v2.Segment.PID,
    "PR1" => HL7v2.Segment.PR1,
    "PRA" => HL7v2.Segment.PRA,
    "PRB" => HL7v2.Segment.PRB,
    "PRC" => HL7v2.Segment.PRC,
    "PRD" => HL7v2.Segment.PRD,
    "PRT" => HL7v2.Segment.PRT,
    "PSH" => HL7v2.Segment.PSH,
    "PTH" => HL7v2.Segment.PTH,
    "PV1" => HL7v2.Segment.PV1,
    "PV2" => HL7v2.Segment.PV2,
    "QAK" => HL7v2.Segment.QAK,
    "QID" => HL7v2.Segment.QID,
    "QPD" => HL7v2.Segment.QPD,
    "QRI" => HL7v2.Segment.QRI,
    "QRD" => HL7v2.Segment.QRD,
    "QRF" => HL7v2.Segment.QRF,
    "RCP" => HL7v2.Segment.RCP,
    "RDF" => HL7v2.Segment.RDF,
    "RDT" => HL7v2.Segment.RDT,
    "RF1" => HL7v2.Segment.RF1,
    "RGS" => HL7v2.Segment.RGS,
    "RMI" => HL7v2.Segment.RMI,
    "ROL" => HL7v2.Segment.ROL,
    "RQ1" => HL7v2.Segment.RQ1,
    "RQD" => HL7v2.Segment.RQD,
    "RXA" => HL7v2.Segment.RXA,
    "RXC" => HL7v2.Segment.RXC,
    "RXD" => HL7v2.Segment.RXD,
    "RXE" => HL7v2.Segment.RXE,
    "RXG" => HL7v2.Segment.RXG,
    "RXO" => HL7v2.Segment.RXO,
    "RXR" => HL7v2.Segment.RXR,
    "SAC" => HL7v2.Segment.SAC,
    "SCD" => HL7v2.Segment.SCD,
    "SCH" => HL7v2.Segment.SCH,
    "SDD" => HL7v2.Segment.SDD,
    "SFT" => HL7v2.Segment.SFT,
    "SID" => HL7v2.Segment.SID,
    "SPM" => HL7v2.Segment.SPM,
    "SPR" => HL7v2.Segment.SPR,
    "STF" => HL7v2.Segment.STF,
    "TCC" => HL7v2.Segment.TCC,
    "TCD" => HL7v2.Segment.TCD,
    "TQ1" => HL7v2.Segment.TQ1,
    "TQ2" => HL7v2.Segment.TQ2,
    "TXA" => HL7v2.Segment.TXA,
    "UAC" => HL7v2.Segment.UAC,
    "UB1" => HL7v2.Segment.UB1,
    "UB2" => HL7v2.Segment.UB2,
    "URD" => HL7v2.Segment.URD,
    "URS" => HL7v2.Segment.URS,
    "VAR" => HL7v2.Segment.VAR,
    "VTQ" => HL7v2.Segment.VTQ
  }

  @doc """
  Returns the segment module for a given segment ID, or nil if unknown.
  """
  @spec segment_module(binary()) :: module() | nil
  def segment_module(seg_id), do: Map.get(@segment_modules, seg_id)

  @doc """
  Converts a `RawMessage` into a `TypedMessage` with parsed segment structs.

  Returns `{:ok, typed_message}` on success, or `{:error, reason}` if
  conversion fails.

  ## Examples

      iex> {:ok, raw} = HL7v2.Parser.parse("MSH|^~\\\\&|S|F||R|20240101||ADT^A01|1|P|2.5\\r")
      iex> {:ok, typed} = HL7v2.TypedParser.convert(raw)
      iex> %HL7v2.Segment.MSH{} = hd(typed.segments)

  """
  @spec convert(RawMessage.t()) :: {:ok, TypedMessage.t()} | {:error, term()}
  def convert(%RawMessage{separators: separators, type: type, segments: segments}) do
    typed_segments = Enum.map(segments, &convert_segment(&1, separators))

    {:ok,
     %TypedMessage{
       separators: separators,
       type: type,
       segments: typed_segments
     }}
  end

  @doc """
  Converts a `TypedMessage` back into a `RawMessage`.

  Each typed segment struct is encoded back to its raw field list via
  `SegmentModule.encode/1`. Z-segments use their stored `segment_id`, and
  unknown raw tuples pass through unchanged.

  ## Examples

      iex> {:ok, raw} = HL7v2.Parser.parse("MSH|^~\\\\&|S|F||R|20240101||ADT^A01|1|P|2.5\\r")
      iex> {:ok, typed} = HL7v2.TypedParser.convert(raw)
      iex> raw_again = HL7v2.TypedParser.to_raw(typed)
      iex> %HL7v2.RawMessage{} = raw_again

  """
  @spec to_raw(TypedMessage.t()) :: RawMessage.t()
  def to_raw(%TypedMessage{separators: separators, type: type, segments: segments}) do
    sep = <<separators.sub_component>>

    raw_segments =
      HL7v2.Type.with_sub_component_separator(sep, fn ->
        Enum.map(segments, &revert_segment/1)
      end)

    %RawMessage{
      separators: separators,
      type: type,
      segments: raw_segments
    }
  end

  # --- Private ---

  defp convert_segment({name, raw_fields}, separators) do
    case Map.get(@segment_modules, name) do
      nil ->
        if z_segment?(name) do
          ZXX.new(name, raw_fields)
        else
          {name, raw_fields}
        end

      module ->
        module.parse(raw_fields, separators)
    end
  end

  defp revert_segment(%ZXX{segment_id: name} = zxx) do
    {name, ZXX.encode(zxx)}
  end

  defp revert_segment({name, raw_fields}) when is_binary(name) and is_list(raw_fields) do
    {name, raw_fields}
  end

  defp revert_segment(%{__struct__: module} = segment) do
    name = module.segment_id()
    {name, module.encode(segment)}
  end

  defp z_segment?(<<"Z", _rest::binary>>), do: true
  defp z_segment?(_), do: false
end
