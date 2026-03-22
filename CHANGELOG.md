# Changelog

## v0.1.0 — 2026-03-22

### Features

- **Raw Parser** — Lossless delimiter-based parsing with CR/LF/CRLF support
- **Encoder** — Wire-format serialization with iodata performance
- **Type System** — 32 composite + 12 primitive HL7v2 data types
- **Segment Definitions** — 19 typed segments + ZXX generic Z-segment per HL7 v2.5.1
- **Typed Parser** — Raw to typed segment struct conversion
- **Message Builder** — Programmatic message construction with auto-populated MSH
- **ACK/NAK Builder** — Application Accept/Error/Reject with sender/receiver swap
- **Validation Engine** — Opt-in message and field validation
- **MLLP Transport** — Ranch 2.x TCP listener, GenServer client, TLS/mTLS
- **Telemetry** — Instrumented parse, encode, and MLLP operations

### Segments

MSH, EVN, PID, PV1, PV2, NK1, OBR, OBX, ORC, MSA, ERR, NTE, AL1, DG1, IN1, SCH, AIS, GT1, FT1, ZXX

### Data Types

Primitives: ST, NM, DT, DTM, SI, ID, IS, TX, FT, NR, TN
Composites: CX, XPN, XAD, XTN, CE, CWE, HD, PL, EI, MSG, PT, VID, CNE, XON, FN, SAD, DR, TS, XCN, CP, MO, FC, JCC, CQ, EIP, DLD, DLN, ERL
