# HL7v2 Encoding Rules Reference

## 1. Message Delimiters

HL7v2 uses a configurable delimiter scheme. The delimiters are defined in the MSH segment header of every message.

### Default Delimiters

| Character | Code | Name | Default | Purpose |
|-----------|------|------|---------|---------|
| Segment terminator | 0x0D | CR | `\r` | Separates segments |
| Field separator | MSH-1 | Pipe | `\|` | Separates fields within a segment |
| Component separator | MSH-2[1] | Caret | `^` | Separates components within a field |
| Repetition separator | MSH-2[2] | Tilde | `~` | Separates repetitions of a field |
| Escape character | MSH-2[3] | Backslash | `\` | Introduces escape sequences |
| Sub-component separator | MSH-2[4] | Ampersand | `&` | Separates sub-components within a component |

### MSH-1 and MSH-2 Special Rules

MSH-1 and MSH-2 are NOT regular fields:

- **MSH-1** is a single character (the field separator itself). It is always `|` in practice.
- **MSH-2** contains 4 encoding characters as a literal string (not delimited). Default: `^~\&`
- When counting field positions in MSH, MSH-1 counts as field 1 and MSH-2 as field 2, but neither is delimited by `|` in the normal way.
- MSH field numbering: `MSH|^~\&|SendingApp|SendingFac|...` — "MSH" is not a field, `|` is MSH-1, `^~\&` is MSH-2, "SendingApp" is MSH-3.

### Delimiter Hierarchy

```
Segment:        CR (0x0D)
  Field:        | (pipe)
    Repetition: ~ (tilde)
      Component: ^ (caret)
        Sub-component: & (ampersand)
```

## 2. Escape Sequences

When delimiter characters appear in data, they must be escaped:

| Sequence | Meaning |
|----------|---------|
| `\F\` | Field separator (`\|`) |
| `\S\` | Component separator (`^`) |
| `\T\` | Sub-component separator (`&`) |
| `\R\` | Repetition separator (`~`) |
| `\E\` | Escape character (`\`) |
| `\Xdddd...\` | Hexadecimal data (each `dd` is a hex byte) |
| `\.br\` | Line break (carriage return / line feed) |
| `\.sp N\` | N spaces (default 1) |
| `\.ce\` | Center next line |
| `\.sk N\` | Skip N spaces |
| `\.fi\` | Start normal text wrapping |
| `\.nf\` | Start pre-formatted (no-wrap) text |
| `\.in N\` | Indent N spaces |
| `\.ti N\` | Temporary indent N spaces |

### Escape Sequence Processing Rules

1. Escape sequences are only processed in ST, TX, FT, and CF data types
2. In other data types, `\` is treated as literal
3. Unrecognized escape sequences should be passed through unchanged
4. Escape processing applies within fields, not across field boundaries

## 3. Null and Empty Field Handling

| Wire Format | Meaning |
|-------------|---------|
| `\|\|` | Field not present (no value) |
| `\|""\|` | Explicit null — "delete any existing value" |
| `\|value\|` | Field has a value |

### Rules

- **Empty** (`||`): The sending system has no value. The receiving system should not modify any existing value.
- **Null** (`|""|`): The sending system explicitly states "this field has no value." The receiving system should clear any existing value (set to null/empty).
- **Trailing empty fields**: May be omitted. `PID|1||12345` is valid even though PID has 39 fields.
- **Trailing components**: May be omitted. `Smith^John` is valid for XPN even though it has 14 components.

## 4. Segment Rules

- Each segment begins with a 3-character segment identifier (e.g., MSH, PID, OBR)
- Segment identifier is followed by the field separator
- Segments are terminated by CR (0x0D)
- A message is a sequence of segments
- The first segment MUST be MSH
- Unknown segments should be preserved (pass-through) but not validated

## 5. Repetition

- Fields that allow repetition use `~` to separate instances
- Example: `PID-3` (Patient Identifier List) can have multiple IDs: `12345^^^MRN~67890^^^SSN`
- Each repetition has the same structure (components, sub-components) as a single occurrence
- Maximum repetitions may be defined per field in the standard

## 6. MLLP Protocol (Minimal Lower Layer Protocol)

### Frame Format

```
<SB> message <EB><CR>
```

| Byte | Name | Value | Description |
|------|------|-------|-------------|
| SB | Start Block | 0x0B | Vertical Tab — marks start of HL7 message |
| EB | End Block | 0x1C | File Separator — marks end of HL7 message |
| CR | Carriage Return | 0x0D | Follows EB to complete the frame |

### Connection Lifecycle

1. **Client connects** to server via TCP
2. **Client sends** MLLP-framed message
3. **Server processes** the message
4. **Server responds** with MLLP-framed ACK/NAK
5. **Connection may persist** for multiple message exchanges
6. **Either side** may close the connection

### Multiple Messages

- Multiple messages can be sent on a single TCP connection
- Each message is independently framed with SB...EB CR
- The receiver should be prepared for messages to arrive in rapid succession
- No pipelining — wait for ACK before sending next message

### Error Handling

- If a malformed MLLP frame is received (no SB, no EB CR), the connection should be closed
- Timeouts should be configurable on both client and server
- The receiver should handle partial reads (TCP may deliver data in chunks)

## 7. ACK/NAK Conventions

### Acknowledgment Codes (MSA-1)

| Code | Name | Meaning |
|------|------|---------|
| AA | Application Accept | Message processed successfully |
| AE | Application Error | Message has errors but was received |
| AR | Application Reject | Message rejected — not processed |
| CA | Commit Accept | Message committed to safe storage (enhanced mode) |
| CE | Commit Error | Message has errors (enhanced mode) |
| CR | Commit Reject | Message rejected at commit level (enhanced mode) |

### Original Mode Acknowledgment

The default acknowledgment mode. Every message gets an ACK.

**ACK message structure:**
```
MSH|^~\&|<receiving_app>|<receiving_fac>|<sending_app>|<sending_fac>|<datetime>||ACK|<new_msg_id>|P|2.5
MSA|AA|<original_msg_control_id>|<optional_text>
[ERR|...]
```

**MSA segment fields:**
1. MSA-1: Acknowledgment Code (AA/AE/AR)
2. MSA-2: Message Control ID (must match MSH-10 of the original message)
3. MSA-3: Text Message (optional, human-readable description)

### Enhanced Mode Acknowledgment

Two-phase: commit acknowledgment + application acknowledgment. Rarely used in practice.

### When to Use Each Code

- **AA**: Message received and processed successfully. The expected response.
- **AE**: Message received but had errors. Some processing may have occurred. The sender should investigate.
- **AR**: Message rejected entirely. No processing occurred. The sender should not retry without fixing the message. Used for: unknown message type, missing required segments, authentication failure.

### ERR Segment in NAK

When returning AE or AR, include an ERR segment:

```
ERR||PID^1|101^Required field missing^HL70357|E
```

ERR fields:
1. ERR-1: Error Code and Location (deprecated, use ERR-2)
2. ERR-2: Error Location (segment^sequence^field^component^sub-component)
3. ERR-3: HL7 Error Code (from table 0357)
4. ERR-4: Severity (E=Error, W=Warning, I=Information)
5. ERR-5: Application Error Code
6. ERR-7: Diagnostic Information (TX, developer-readable)
7. ERR-8: User Message (TX, user-readable)

## 8. MSH Segment Special Fields

### MSH-9: Message Type

Format: `MSG_CODE^TRIGGER_EVENT^MSG_STRUCTURE`

Example: `ADT^A01^ADT_A01`

- Component 1: Message code (ADT, ORM, ORU, ACK, SIU, etc.)
- Component 2: Trigger event (A01, O01, R01, etc.)
- Component 3: Message structure (abstract message definition, e.g., ADT_A01)

### MSH-10: Message Control ID

- Must be unique within the sending application
- Used by the receiver to reference the message in the ACK (MSA-2)
- Typically: timestamp + sequence number, UUID, or incrementing counter

### MSH-11: Processing ID

| Code | Meaning |
|------|---------|
| P | Production |
| D | Debugging |
| T | Training |

### MSH-12: Version ID

Format: `VID` data type. Common values: `2.1`, `2.2`, `2.3`, `2.3.1`, `2.4`, `2.5`, `2.5.1`, `2.6`, `2.7`, `2.8`

## 9. Character Sets

### Default

HL7v2 defaults to ASCII (printable characters 0x20-0x7E plus CR 0x0D).

### MSH-18: Character Set

Specifies the character set for the message. Values from HL7 Table 0211:

| Value | Character Set |
|-------|--------------|
| ASCII | 7-bit ASCII (default) |
| 8859/1 | ISO 8859-1 (Latin-1) |
| 8859/2 | ISO 8859-2 (Latin-2) |
| UNICODE | UTF-8 in practice |
| UNICODE UTF-8 | Explicit UTF-8 |

### Practical Considerations

- Most modern HL7v2 implementations use UTF-8 regardless of MSH-18
- The parser should handle UTF-8 by default
- If MSH-18 is absent, treat as ASCII-compatible (UTF-8 is a superset)
- Character set conversion between messages is out of scope for a parsing library

## 10. Version Compatibility

### Field Changes Across Versions

- v2.1: Basic segments (MSH, PID, PV1, OBR, OBX)
- v2.2: Added ORC, extended PID
- v2.3: Added many segments, CWE/CNE types
- v2.3.1: Minor corrections
- v2.4: CE deprecated in favor of CWE. TS deprecated in favor of DTM.
- v2.5: Added ERR segment (new fields), VID type for version
- v2.5.1: Minor corrections (our primary target)
- v2.6+: Additional segments, mostly additive

### Backward Compatibility Rules

1. New fields are always added at the END of segments (never inserted)
2. New components are added at the END of data types
3. Data type changes are backward-compatible (CE → CWE adds components, doesn't remove)
4. A v2.5.1 parser can handle v2.3+ messages by ignoring unknown trailing fields
5. A v2.3 message parsed with a v2.5.1 schema just has fewer populated fields
