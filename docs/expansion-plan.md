# HL7v2 Library Expansion Plan (Historical)

> **This document is historical.** It reflects the state at v1.3.0.
> For current coverage, run `mix hl7v2.coverage`. For known limitations, see README.md.

## State at v1.3.0

- 43/136 segments (31.6%), 54/89 types (60.7%), 20 structures
- Supported families: ADT, ORM_O01, ORU_R01, SIU_S12, ACK
- All segments in supported structures are typed (zero raw-only)
- 33 raw holes in typed segments (mostly UB1/UB2 legacy fields)
- 2,197 tests, 0 failures

## Phase 1: Pharmacy + Documents (highest impact)

### Why
Pharmacy is the second-highest message volume after ADT. Document management
(TXA) enables report metadata extraction beyond raw OBX text.

### New segments needed
- **RXO** — Pharmacy/Treatment Order (25 fields)
- **RXE** — Pharmacy/Treatment Encoded Order (44 fields)
- **RXD** — Pharmacy/Treatment Dispense (33 fields)
- **RXA** — Pharmacy/Treatment Administration (26 fields)
- **RXR** — Pharmacy/Treatment Route (6 fields)
- **RXG** — Pharmacy/Treatment Give (27 fields)
- **RXC** — Pharmacy/Treatment Component (9 fields)
- **TXA** — Transcription Document Header (23 fields)
- **IAM** — Patient Adverse Reaction (30 fields)

### New message structures
- **RDE_O11** — Pharmacy/Treatment Encoded Order
- **RDS_O13** — Pharmacy/Treatment Dispense
- **RGV_O15** — Pharmacy/Treatment Give
- **RAS_O17** — Pharmacy/Treatment Administration
- **MDM_T01** / **MDM_T02** — Original/Original+Notify Document

### ORM_O01 choice expansion
Update ORDER_DETAIL to support OBR | RXO choice (pharmacy orders).

### Impact
Unlocks pharmacy order integration. ~15% of hospital message volume.
After this phase: ~52 segments, ~54 types, ~26 structures.

## Phase 2: Query + Master Files (enterprise integration)

### New segments
- **QPD** — Query Parameter Definition
- **QAK** — Query Acknowledgment
- **RCP** — Response Control Parameter
- **MFI** — Master File Identification
- **MFE** — Master File Entry

### New message structures
- **QBP_Q11** — Query by Parameter
- **RSP_K21** — Response Segment Pattern
- **MFN_M01** — Master File Notification

### Impact
Enables MPI queries and master file sync. Enterprise integration tier.

## Phase 3: Extended Clinical (future)

- Blood products (BPO, BPX)
- Clinical studies (CSR, CSP)
- Equipment/lab automation (EQU, INV, SAC)
- Batch/file wrappers (BHS, BTS, FHS, FTS)

## Phaos Integration Points

Phaos currently handles ADT^A01/A08/A31 + ORM^O01 via:
- `phaos_core/lib/phaos_core/hl7/` — parser, message_handler
- MLLP listener for ADT patient sync and ORM order context

Phase 1 would enable:
- Pharmacy orders → DICOM study triggering (RXO → accession mapping)
- Document reports with metadata (TXA + OBX)
- Medication reconciliation workflows
