# HL7 v2.x Encoding Specification

Reference document for implementing a conformant HL7 v2.x parser, encoder, MLLP transport,
and ACK/NAK responder. Covers versions 2.3 through 2.8.2; differences are noted where they
apply.

Sources: HL7 Standard Chapters 2 (Control) and 2C (Code Tables), versions 2.5.1 / 2.7.1 /
2.8.2; Transport Specification: MLLP Release 1 (Rene Spronk, HL7 v3 Standard, 2003);
IHE ITI TF Volume 2 Appendix C.

---

## 1. Message Delimiters

HL7 v2 messages are variable-length, pipe-delimited text. Seven delimiter characters
control structure:

| Delimiter              | Default | Position            | Notes                             |
|------------------------|---------|---------------------|-----------------------------------|
| Segment terminator     | `<CR>`  | Fixed (0x0D)        | CANNOT be redefined               |
| Field separator        | `\|`    | MSH-1 (byte 4)      | Single character; defines itself  |
| Component separator    | `^`     | MSH-2, position 1   | Within composite data types       |
| Repetition separator   | `~`     | MSH-2, position 2   | Between repeated field values     |
| Escape character       | `\`     | MSH-2, position 3   | Begins/ends escape sequences      |
| Sub-component separator| `&`     | MSH-2, position 4   | Within components                 |
| Truncation character   | `#`     | MSH-2, position 5   | v2.7+ only; marks truncated data  |

### 1.1. Segment Terminator

Always ASCII CR (0x0D). This is hardcoded in the specification and cannot be overridden.
Every segment, including the last segment in a message, ends with CR.

Implementations must normalize `\r\n` (CRLF) and bare `\n` (LF) to `\r` (CR) during
parsing, since real-world systems often transmit CRLF despite the standard.

### 1.2. Field Separator (MSH-1)

A single character occupying the byte immediately after the three-character segment ID
`MSH`. It is simultaneously the value AND the delimiter for the rest of the message.

The default is pipe (`|`, 0x7C). Any printable ASCII character may be used, but
interoperability demands sticking with pipe.

### 1.3. Encoding Characters (MSH-2)

MSH-2 contains 4 characters (5 in v2.7+) in strict positional order:

```
Position 1: Component separator       (default ^)
Position 2: Repetition separator      (default ~)
Position 3: Escape character          (default \)
Position 4: Sub-component separator   (default &)
Position 5: Truncation character      (default #)  -- v2.7+ only
```

MSH-2 is parsed positionally, NOT by delimiter. The field separator does NOT precede
MSH-2 in the byte stream -- MSH-2 immediately follows the MSH-1 character. See
Section 2 for full MSH parsing rules.

---

## 2. MSH Segment Special Rules

The MSH segment is the only segment with non-standard parsing rules. Every other segment
follows the regular `SEGMENT_ID | field1 | field2 | ...` pattern.

### 2.1. MSH Byte Layout

```
Byte offset:  0  1  2  3  4  5  6  7  8  9
Content:      M  S  H  |  ^  ~  \  &  |  ... (first real field, MSH-3)
              ^^^      ^  ^^^^^^^^  ^
              Seg ID   |  MSH-2     |
                       MSH-1        Next field separator
```

**Critical parsing rules:**

1. MSH-1 is at byte offset 3. It is a SINGLE CHARACTER. It is NOT delimited -- it IS
   the delimiter.

2. MSH-2 occupies bytes 4 through 7 (or 4-8 in v2.7+ with truncation char). These bytes
   are read positionally, not split by the field separator.

3. The field separator at byte offset 8 (or 9 in v2.7+) begins normal field-delimited
   parsing from MSH-3 onward.

4. When counting MSH fields for field numbering, MSH-1 is field 1, MSH-2 is field 2.
   The first pipe-delimited token after MSH-2 is MSH-3.

### 2.2. MSH Field Reference

| Field  | Name                          | DT   | Opt   | Rep | Length    |
|--------|-------------------------------|------|-------|-----|-----------|
| MSH-1  | Field Separator               | ST   | SHALL | N   | 1         |
| MSH-2  | Encoding Characters           | ST   | SHALL | N   | 4..5      |
| MSH-3  | Sending Application           | HD   | MAY   | N   | --        |
| MSH-4  | Sending Facility              | HD   | MAY   | N   | --        |
| MSH-5  | Receiving Application         | HD   | MAY   | N   | --        |
| MSH-6  | Receiving Facility            | HD   | MAY   | Y   | --        |
| MSH-7  | Date/Time of Message          | DTM  | SHALL | N   | --        |
| MSH-8  | Security                      | ST   | MAY   | N   | 0..40     |
| MSH-9  | Message Type                  | MSG  | SHALL | N   | --        |
| MSH-10 | Message Control ID            | ST   | SHALL | N   | 1..199    |
| MSH-11 | Processing ID                 | PT   | SHALL | N   | --        |
| MSH-12 | Version ID                    | VID  | SHALL | N   | --        |
| MSH-13 | Sequence Number               | NM   | MAY   | N   | --        |
| MSH-14 | Continuation Pointer          | ST   | MAY   | N   | 0..180    |
| MSH-15 | Accept Acknowledgment Type    | ID   | MAY   | N   | 2         |
| MSH-16 | Application Acknowledgment Type | ID | MAY   | N   | 2         |
| MSH-17 | Country Code                  | ID   | MAY   | N   | 3         |
| MSH-18 | Character Set                 | ID   | MAY   | Y   | 5..15     |
| MSH-19 | Principal Language            | CWE  | MAY   | N   | --        |
| MSH-20 | Alt. Char Set Handling Scheme  | ID   | MAY   | N   | 3..13     |
| MSH-21 | Message Profile Identifier    | EI   | MAY   | Y   | --        |

Fields MSH-22 through MSH-28 exist in v2.7+ (responsible org, network address,
security classification). See HL7 v2.8.2 Section 2.14.9 for full definitions.

### 2.3. MSH-9: Message Type (MSG Data Type)

Three components separated by the component separator:

```
<Message Code>^<Trigger Event>^<Message Structure>
```

| Component | Table    | Example | Notes                               |
|-----------|----------|---------|-------------------------------------|
| MSG-1     | 0076     | ADT     | Message type category                |
| MSG-2     | 0003     | A01     | Trigger event                        |
| MSG-3     | 0354     | ADT_A01 | Abstract message structure (v2.3.1+) |

Examples:
- `ADT^A01^ADT_A01` -- admission
- `ORM^O01^ORM_O01` -- order
- `ORU^R01^ORU_R01` -- result
- `ACK^A01^ACK`     -- acknowledgment

MSG-3 may differ from MSG-1+MSG-2 when messages share a structure:
`ADT^A04^ADT_A01` means event A04 uses the ADT_A01 structure.

### 2.4. MSH-10: Message Control ID

Must uniquely identify the message. The receiver echoes it in MSA-2. Maximum 199
characters; truncation is NOT allowed. Must be unique within the scope of the
sending application.

### 2.5. MSH-11: Processing ID (PT Data Type)

Two components:

| Component | Values           | Meaning                            |
|-----------|------------------|------------------------------------|
| PT-1      | P / D / T        | Production / Debugging / Training  |
| PT-2      | A / T / (empty)  | Archive / Not archive              |

Receivers must validate PT-1 matches their operational mode and reject with AR/CR
if mismatched.

### 2.6. MSH-12: Version ID

First component is the version string: `2.3`, `2.3.1`, `2.4`, `2.5`, `2.5.1`,
`2.6`, `2.7`, `2.7.1`, `2.8`, `2.8.2`. Receivers should reject messages with
unsupported versions (AR/CR in acknowledgment).

### 2.7. MSH-15 and MSH-16: Acknowledgment Types

These fields control acknowledgment behavior. Both reference HL7 Table 0155:

| Code | Description                       |
|------|-----------------------------------|
| AL   | Always send acknowledgment        |
| NE   | Never send acknowledgment         |
| SU   | Send only on successful completion|
| ER   | Send only on error/reject         |

**Rule:** Either both MSH-15 and MSH-16 SHALL be populated, or both SHALL be empty.
If both are empty, original mode acknowledgment applies.

### 2.8. MSH-18: Character Set

Repeating field specifying character encoding. If empty, 7-bit ASCII is assumed.
The first repetition is the default character set; subsequent repetitions are
alternates available via escape sequences.

See Section 8 for the complete Table 0211.

---

## 3. Field, Component, and Sub-Component Rules

### 3.1. Hierarchy

```
Message
  +-- Segment (terminated by CR)
        +-- Field (separated by field separator |)
              +-- Repetition (separated by repetition separator ~)
                    +-- Component (separated by component separator ^)
                          +-- Sub-component (separated by sub-component separator &)
```

Sub-components are the lowest level. They cannot contain further nesting.

### 3.2. Repetition Rules

Only fields explicitly marked as repeating (Rep=Y or Rep=N where N > 1 in the segment
definition) may have multiple values separated by the repetition separator.

Components and sub-components NEVER repeat.

```
Example: Three phone numbers in a repeating field:
|555-1111~555-2222~555-3333|
```

### 3.3. Trailing Empty Elements

Empty trailing fields, components, and sub-components MAY be omitted. Receivers must
treat them as not present (equivalent to `||`).

```
Equivalent:
PID|1||12345^^^MRN||Doe^John
PID|1||12345^^^MRN||Doe^John||||||||||||||||||
```

### 3.4. Counting Rules for Non-MSH Segments

For all segments other than MSH, fields are numbered starting at 1 for the first field
after the segment ID. The segment ID itself is not a numbered field.

```
PID|1||12345|...
    ^   ^
    |   PID-3
    PID-1

(PID-2 is empty between PID-1 and PID-3)
```

---

## 4. Null and Empty Field Handling

HL7 distinguishes three population states for every field, component, and sub-component:

### 4.1. Populated (Valued)

The element contains data between delimiters:
```
|Smith^John|
```

### 4.2. Not Populated (Empty)

No characters between consecutive delimiters. The sender has no value to communicate.
The receiver makes no inference about the value in its database:
```
||
```

### 4.3. Explicit Null (Delete)

Two consecutive double-quote characters as the ONLY content of a field. This instructs
the receiver to DELETE the previously stored value:
```
|""|
```

**Critical constraint:** Using `""` for any purpose other than deletion is prohibited by
the standard.

**Delete indicator length:** The deletion indicator `""` is treated as having zero length
and fits within any length specification.

### 4.4. Null at Component Level

Explicit null can apply to individual components within a composite field:
```
|""^John^""^Dr|
```
This deletes the family name and suffix while preserving given name and prefix.

### 4.5. Interaction with Updates

In update transactions (e.g., ADT^A08):
- Empty field (`||`): no change to existing value
- Populated field (`|Smith|`): replace existing value
- Explicit null (`|""|`): delete existing value

---

## 5. Escape Sequences

### 5.1. Structure

An escape sequence begins and ends with the escape character (default `\`):

```
\<code><data>\
```

Where `<code>` is a single uppercase letter and `<data>` is zero or more characters.

**Nesting is prohibited:** No escape sequence may contain another escape sequence.

### 5.2. Delimiter Escape Sequences

These are valid in ALL text-bearing data types (ST, TX, FT, CF, CWE text components,
etc.):

| Sequence | Represents              | Purpose                              |
|----------|-------------------------|--------------------------------------|
| `\F\`    | Field separator (`\|`)  | Literal pipe in data                 |
| `\S\`    | Component separator (`^`) | Literal caret in data              |
| `\T\`    | Sub-component separator (`&`) | Literal ampersand in data       |
| `\R\`    | Repetition separator (`~`) | Literal tilde in data             |
| `\E\`    | Escape character (`\`)  | Literal backslash in data            |
| `\P\`    | Truncation character (`#`) | Literal hash in data (v2.7+)     |

**Case sensitivity:** Escape codes are CASE-SENSITIVE. `\F\` is valid; `\f\` is not.

### 5.3. Formatting Escape Sequences

Valid ONLY in TX (text data), FT (formatted text), and CF (coded element with formatted
text) data types:

| Sequence      | Effect                                              |
|---------------|-----------------------------------------------------|
| `\H\`         | Start highlighting                                  |
| `\N\`         | End highlighting (return to normal text)             |
| `\.br\`       | Begin new output line                               |
| `\.sp\`       | End current line, skip 1 vertical space             |
| `\.sp<n>\`    | End current line, skip n vertical spaces            |
| `\.fi\`       | Begin word wrap / fill mode (default)               |
| `\.nf\`       | Begin no-wrap mode                                  |
| `\.in<n>\`    | Indent n spaces from left margin (+/- integer)      |
| `\.ti<n>\`    | Temporarily indent n spaces (next line only)        |
| `\.sk<n>\`    | Skip n spaces to the right                         |
| `\.ce\`       | End current line, center the next line              |

### 5.4. Hexadecimal Data Escape

```
\Xdddd...\
```

Where `dddd...` is one or more pairs of hexadecimal digits (0-9, A-F). Each pair
represents one byte. Interpretation is application-specific.

Common uses:
- `\X0D\` -- carriage return byte
- `\X0A\` -- line feed byte
- `\X0D0A\` -- CRLF sequence

### 5.5. Character Set Escape Sequences

For fields supporting multiple character sets (PN, XPN, XCN, XON, XAD, as well as
TX, FT, CF):

**Single-byte character set:**
```
\Cxxyy\
```
Where `xx` and `yy` are hexadecimal values identifying an ISO 2022 character set
via ISO-IR registration numbers.

**Multi-byte character set:**
```
\Mxxyyzz\
```
Where `xx`, `yy`, and optionally `zz` are hexadecimal values.

Examples:
- `\C2842\` -- ISO-IR6 (ASCII)
- `\C2D41\` -- ISO-IR100 (ISO 8859-1 Latin-1)
- `\C2D46\` -- ISO-IR101 (ISO 8859-2 Latin-2)
- `\C2D48\` -- ISO-IR138 (ISO 8859-8 Hebrew)
- `\M2442\` -- ISO-IR87 (JIS X 0208 Japanese)

### 5.6. Locally Defined Escape Sequences

```
\Zdddd...\
```

The `Z` prefix is reserved for local/vendor-specific extensions. Content after `Z` must
be valid TX characters. Interpretation requires prior agreement between sender and
receiver.

### 5.7. Escape Sequence Rules Summary

1. Escape sequences are case-sensitive.
2. No nested escape sequences.
3. All characters inside the escape (between the opening and closing `\`, excluding
   the `\` delimiters themselves) count toward field length.
4. Delimiter escape sequences (`\F\`, `\S\`, `\T\`, `\R\`, `\E\`, `\P\`) are valid
   in ST fields as well as TX/FT/CF.
5. Formatting escapes (`\H\`, `\N\`, `\.xx\`) are valid ONLY in TX, FT, CF fields.
6. Unrecognized escape sequences should be passed through unchanged (the standard
   provides no explicit guidance, but defensive implementations preserve them).

---

## 6. MLLP (Minimal Lower Layer Protocol)

Reference: Transport Specification: MLLP, Release 1 (HL7 v3 Standard, 2003). Based on
HL7 Implementation Guide for HL7 v2.3.1, Appendix C "Lower Layer Protocols", Section
C.4.3.

### 6.1. Purpose

MLLP is a minimalistic OSI session-layer framing protocol that wraps HL7 messages for
transmission over TCP/IP. It relies on TCP for error detection, retransmission, and flow
control.

### 6.2. Block Format

```
<SB> dddd <EB> <CR>
```

| Element | Value  | ASCII Name     | Hex  | Description                                    |
|---------|--------|----------------|------|------------------------------------------------|
| `<SB>`  | VT     | Vertical Tab   | 0x0B | Start Block -- begins the frame                |
| `dddd`  | (data) | --             | --   | HL7 message content (variable length)          |
| `<EB>`  | FS     | File Separator | 0x1C | End Block -- marks end of message data         |
| `<CR>`  | CR     | Carriage Return| 0x0D | Required trailing CR after End Block           |

**Do NOT confuse:**
- SB (0x0B) with SOH (0x01) or STX (0x02)
- EB (0x1C) with ETX (0x03) or EOT (0x04)

### 6.3. Data Content Rules

The data portion (`dddd`) can contain:
- Any single-byte values greater than 0x1F (printable characters)
- The ASCII carriage return character (0x0D) -- used as segment terminator within the
  HL7 message itself

The data portion MUST NOT contain:
- 0x0B (Start Block) -- would be misinterpreted as a new frame start
- 0x1C (End Block)   -- would be misinterpreted as frame end
- Byte values 0x00 through 0x1E (except 0x0D)

### 6.4. Character Encoding Restrictions

MLLP is framed by single-byte values. The characters within the block must be encoded
using a character encoding whose byte values do not conflict with the framing bytes
(0x0B, 0x1C).

**Supported encodings:**
- All single-byte encodings: ASCII, ISO 8859-x, cp1252
- UTF-8 (byte values for multi-byte sequences are always >= 0x80, so no conflict)
- Shift_JIS

**NOT supported:**
- UTF-16 (byte values may equal 0x0B or 0x1C within multi-byte sequences)
- UTF-32 (same problem)

### 6.5. Connection Lifecycle

1. **Sender** opens a TCP connection to the receiver's MLLP port.
2. **Sender** transmits `<SB>` + message + `<EB>` + `<CR>`.
3. **Receiver** reads until it encounters `<EB><CR>`, extracts the message.
4. **Receiver** processes the message and generates an ACK response.
5. **Receiver** transmits the ACK as `<SB>` + ack + `<EB>` + `<CR>`.
6. **Sender** reads the ACK.
7. Connection may remain open for additional messages (persistent) or be closed.

### 6.6. Multiple Messages Per Connection

The specification does not mandate one-message-per-connection. In practice:

- **Persistent connections:** The sender may transmit multiple messages sequentially on
  the same TCP connection, waiting for each ACK before sending the next message.
- **One-shot connections:** Some implementations open a new TCP connection per message.
- **Pipeline concern:** The standard does not support pipelining (sending message N+1
  before receiving ACK for message N). Each message-ACK pair must complete before the
  next begins.

### 6.7. Timeout Considerations

The specification does not define timeouts. Implementations should:
- Set a TCP read timeout (commonly 30-60 seconds) when waiting for data.
- Set a connection timeout for the initial TCP handshake.
- Handle `<SB>` without a corresponding `<EB><CR>` within a reasonable time as a
  protocol error.

### 6.8. Error Handling

MLLP itself provides no error detection beyond frame boundary recognition. Error
detection and correction are delegated to:
- TCP (packet-level reliability)
- HL7 ACK/NAK (application-level confirmation)

If a receiver cannot parse a valid MLLP frame, the implementation should:
1. Log the error.
2. Close the TCP connection (the sender will detect the closed connection).

---

## 7. ACK/NAK Acknowledgment

### 7.1. Mode Determination

HL7 defines two acknowledgment modes. The mode is determined by MSH-15 and MSH-16 of
the INBOUND message:

| MSH-15 | MSH-16 | Mode Selected                        |
|--------|--------|--------------------------------------|
| empty  | empty  | Original mode                        |
| valued | valued | Enhanced mode                        |
| valued | empty  | Enhanced mode (accept ACK only)      |
| empty  | valued | Enhanced mode (application ACK only) |

**Original mode is equivalent to:** MSH-15=NE, MSH-16=AL.

### 7.2. Acknowledgment Codes (Table 0008)

| Code | Mode     | Type                  | Meaning                                         |
|------|----------|-----------------------|-------------------------------------------------|
| AA   | Original | Application Accept    | Message successfully processed                  |
| AE   | Original | Application Error     | Error during application processing             |
| AR   | Original | Application Reject    | Rejected (bad type/version/processing ID, or system failure) |
| CA   | Enhanced | Commit Accept         | Message safely stored for processing            |
| CE   | Enhanced | Commit Error          | Cannot accept message (validation failure, etc.)|
| CR   | Enhanced | Commit Reject         | Rejected (bad type/version/processing ID)       |

### 7.3. Original Mode Processing

The receiver performs two validation steps:

**Step 1 -- Protocol validation:**
1. Is the message type (MSH-9) one the receiver accepts?
2. Is the version (MSH-12) supported?
3. Is the processing ID (MSH-11) appropriate?

If any check fails: return ACK with MSA-1 = `AR`.

**Step 2 -- Application processing:**
The validated message is passed to the receiving application:
- Success: return MSA-1 = `AA`
- Application-level error: return MSA-1 = `AE` with error details in ERR segment
- Application-level rejection: return MSA-1 = `AR`

### 7.4. Enhanced Mode Processing

Enhanced mode separates commit acknowledgment from application acknowledgment:

**Phase 1 -- Commit (Accept) Acknowledgment:**

Upon receiving a message, the receiver:
1. Checks interface status and safe storage availability.
2. Optionally validates syntax, message type, version, processing ID.
3. If MSH-15 indicates an accept ACK is needed (AL, SU, ER):
   - `CA`: Message stored safely for later processing.
   - `CR`: Message type, version, or processing ID is invalid.
   - `CE`: Cannot accept for any other reason (storage failure, etc.).

**Phase 2 -- Application Acknowledgment:**

After processing completes (may be asynchronous), if MSH-16 indicates an application
ACK is needed:
- `AA`: Processing succeeded.
- `AE`: Application-level error.
- `AR`: Application-level rejection.

The application acknowledgment message itself CANNOT request a further application
acknowledgment (its MSH-16 is always empty).

### 7.5. ACK Message Structure

An ACK message contains these segments:

```
MSH|...|ACK^<trigger_event>^ACK|<unique_control_id>|...|
MSA|<ack_code>|<original_message_control_id>|<text_message>|
[ERR|...]
[{SFT|...}]
```

**MSH construction for ACK:**
- MSH-3/MSH-4: Swap with original MSH-5/MSH-6 (sender becomes receiver)
- MSH-5/MSH-6: Swap with original MSH-3/MSH-4
- MSH-9: `ACK^<original_trigger_event>^ACK`
- MSH-10: A NEW unique message control ID (not the original's)
- MSH-11: Same processing ID as original
- MSH-12: Same version as original

### 7.6. MSA Segment

| Field | Name                | DT | Opt   | Description                                  |
|-------|---------------------|----|-------|----------------------------------------------|
| MSA-1 | Acknowledgment Code | ID | SHALL | AA/AE/AR/CA/CE/CR (Table 0008)               |
| MSA-2 | Message Control ID  | ST | SHALL | Echoes MSH-10 from the ORIGINAL message      |
| MSA-3 | Text Message        | ST | MAY   | Human-readable error/status text              |
| MSA-4 | Expected Seq Number | NM | MAY   | For sequence number protocol                 |
| MSA-6 | Error Condition     | --  | --    | Deprecated; use ERR segment instead          |

### 7.7. ERR Segment

Used in AE/AR/CE/CR responses to provide structured error details:

| Field  | Name                     | DT  | Opt   | Rep   | Description                           |
|--------|--------------------------|-----|-------|-------|---------------------------------------|
| ERR-1  | Error Code and Location  | --  | --    | --    | Withdrawn in v2.7; do not use         |
| ERR-2  | Error Location           | ERL | MAY   | 0..*  | Segment/field/component location      |
| ERR-3  | HL7 Error Code           | CWE | SHALL | 1..1  | Table 0357 error code (see 7.8)       |
| ERR-4  | Severity                 | ID  | SHALL | 1..1  | E=Error, W=Warning, I=Information     |
| ERR-5  | Application Error Code   | CWE | MAY   | 0..1  | Application-specific error            |
| ERR-6  | Application Error Param  | ST  | MAY   | 0..10 | Parameter substitution values (max 80 chars) |
| ERR-7  | Diagnostic Information   | TX  | MAY   | 0..1  | Technical details (max 2048 chars)    |
| ERR-8  | User Message             | TX  | MAY   | 0..1  | User-facing text (max 250 chars)      |
| ERR-9  | Inform Person Indicator  | CWE | MAY   | 0..*  | Who should be notified                |
| ERR-10 | Override Type            | CWE | MAY   | 0..1  | Whether override is permitted         |
| ERR-11 | Override Reason Code     | CWE | MAY   | 0..*  | Justification for override            |
| ERR-12 | Help Desk Contact        | XTN | MAY   | 0..*  | Support contact information           |

### 7.8. Table 0357 -- Message Error Condition Codes

| Code | Description                  | Category      |
|------|------------------------------|---------------|
| 0    | Message accepted             | Success       |
| 100  | Segment sequence error       | Syntax error  |
| 101  | Required field missing       | Syntax error  |
| 102  | Data type error              | Syntax error  |
| 103  | Table value not found        | Semantic error|
| 104  | Value too long               | Length error   |
| 200  | Unsupported message type     | Rejection     |
| 201  | Unsupported event code       | Rejection     |
| 202  | Unsupported processing ID    | Rejection     |
| 203  | Unsupported version ID       | Rejection     |
| 204  | Unknown key identifier       | Business error|
| 205  | Duplicate key identifier     | Business error|
| 206  | Application record locked    | System error  |
| 207  | Application internal error   | System error  |

### 7.9. When to Use Each Acknowledgment Code

**AA (Application Accept):**
- Message parsed, validated, and processed successfully.
- Receiver has committed the data changes.

**AE (Application Error):**
- Message parsed and understood, but business logic failed.
- The sender may correct the data and resend.
- Include ERR segment with specific error details.
- ERR-4 = "E" (Error) or "W" (Warning).

**AR (Application Reject):**
- Message cannot be processed for systemic reasons.
- Bad message type/version/processing ID, or system is down.
- May be transient (system overload) -- sender may retry unchanged.
- For enhanced mode, use CR instead when type/version/ID is the cause.

**CA (Commit Accept):**
- Enhanced mode only. Message received and safely stored.
- Does NOT mean the message has been processed.
- Application processing will happen asynchronously.

**CE (Commit Error):**
- Enhanced mode only. Cannot accept the message.
- Storage failure, validation error, or other infrastructure issue.

**CR (Commit Reject):**
- Enhanced mode only. Message type, version, or processing ID is unacceptable.
- Sender should not retry without fixing the cause.

---

## 8. Character Sets and Encoding

### 8.1. Default Character Set

If MSH-18 is empty, the message uses 7-bit ASCII (decimal 0-127, hex 0x00-0x7F).

### 8.2. Table 0211 -- Alternate Character Sets

| Code             | Character Set                  | Type        |
|------------------|--------------------------------|-------------|
| ASCII            | 7-bit ASCII                    | Single-byte |
| 8859/1           | ISO 8859-1 (Latin-1)           | Single-byte |
| 8859/2           | ISO 8859-2 (Latin-2)           | Single-byte |
| 8859/3           | ISO 8859-3 (Latin-3)           | Single-byte |
| 8859/4           | ISO 8859-4 (Latin-4)           | Single-byte |
| 8859/5           | ISO 8859-5 (Cyrillic)          | Single-byte |
| 8859/6           | ISO 8859-6 (Arabic)            | Single-byte |
| 8859/7           | ISO 8859-7 (Greek)             | Single-byte |
| 8859/8           | ISO 8859-8 (Hebrew)            | Single-byte |
| 8859/9           | ISO 8859-9 (Latin-5/Turkish)   | Single-byte |
| 8859/15          | ISO 8859-15 (Latin-9)          | Single-byte |
| ISO IR6          | ISO 646 (ASCII graphic subset) | Single-byte |
| ISO IR14         | JIS X 0201-1976                | Single-byte |
| ISO IR87         | JIS X 0208-1990 (Kanji)        | Multi-byte  |
| ISO IR159        | JIS X 0212-1990 (Supplementary)| Multi-byte  |
| KS X 1001        | Korean (EUC-KR)                | Multi-byte  |
| CNS 11643-1992   | Taiwanese                      | Multi-byte  |
| BIG-5            | Taiwanese (Big5)               | Multi-byte  |
| GB 18030-2000    | Chinese (GB18030)              | Multi-byte  |
| UNICODE          | ISO 10646 UCS-2 (deprecated)   | Multi-byte  |
| UNICODE UTF-8    | UTF-8                          | Variable    |
| UNICODE UTF-16   | UTF-16 (removed from standard) | Multi-byte  |
| UNICODE UTF-32   | UTF-32 (removed from standard) | Multi-byte  |

### 8.3. MSH-18 Semantics

- If MSH-18 is blank: ASCII is the character set for the entire message.
- If MSH-18 has one value: that is the character set for the entire message.
- If MSH-18 has multiple repetitions: the first is the default; subsequent repetitions
  are alternates available via `\Cxxyy\` and `\Mxxyyzz\` escape sequences.

### 8.4. MSH-20: Alternate Character Set Handling Scheme

Controls how character set switching works when MSH-18 has alternates:

| Code     | Description                                                |
|----------|------------------------------------------------------------|
| ISO 2022-1994 | ISO 2022 escape sequences select character sets       |
| 2.3      | HL7 v2.3-compatible handling (deprecated)                  |
| (empty)  | Implementation-defined                                     |

### 8.5. UTF-8 in Practice

Most modern implementations use `UNICODE UTF-8` in MSH-18 exclusively. UTF-8 properties
relevant to HL7:

1. ASCII-compatible: bytes 0x00-0x7F are identical to ASCII. All HL7 delimiters (pipe,
   caret, tilde, backslash, ampersand, CR) fall in this range. Therefore, a parser can
   safely split on delimiters at the byte level without worrying about multi-byte
   character boundaries.

2. MLLP-safe: UTF-8 multi-byte sequences use bytes 0x80-0xFF, which do not conflict
   with MLLP framing bytes (0x0B, 0x1C, 0x0D).

3. A message encoded in 7-bit ASCII can be submitted to a UTF-8 destination with no
   modification.

---

## 9. Message Construction Rules

### 9.1. Encoding Procedure (Pseudocode)

```
function encode_message(segments) -> binary:
    for each segment in segment_order:
        emit segment_id                              # e.g., "MSH", "PID"

        if segment_id == "MSH":
            emit field_separator                     # MSH-1 (e.g., |)
            emit encoding_characters                 # MSH-2 (e.g., ^~\&)
            start_field_index = 3                    # Skip to MSH-3
        else:
            start_field_index = 1

        for each field from start_field_index:
            emit field_separator

            for each repetition in field:
                if not first_repetition:
                    emit repetition_separator

                for each component in repetition:
                    if not first_component:
                        emit component_separator

                    for each sub_component in component:
                        if not first_sub_component:
                            emit sub_component_separator

                        emit escape(sub_component_value)

            # Stop emitting fields after the last populated field
            # (trailing empty fields may be omitted)

        emit CR                                      # Segment terminator
```

### 9.2. Escape Procedure

When encoding field values, replace delimiter characters with escape sequences:

```
function escape(value) -> string:
    replace field_separator       with \F\
    replace component_separator   with \S\
    replace sub_component_sep     with \T\
    replace repetition_separator  with \R\
    replace escape_character      with \E\
    replace truncation_character  with \P\   # v2.7+ only
    return value
```

**Order matters:** The escape character itself MUST be escaped FIRST, before replacing
other delimiters. Otherwise, the backslashes introduced by other replacements would
themselves get escaped.

### 9.3. Decoding Procedure

When parsing received messages:

1. Split on CR to get segments.
2. For the first segment (MSH), extract MSH-1 (byte 4) and MSH-2 (bytes 5-8 or 5-9).
3. For remaining fields in MSH and all fields in other segments, split by field separator.
4. For each field, split by repetition separator.
5. For each repetition, split by component separator.
6. For each component, split by sub-component separator.
7. Apply unescape to each terminal value.

```
function unescape(value) -> string:
    replace \F\ with field_separator
    replace \S\ with component_separator
    replace \T\ with sub_component_separator
    replace \R\ with repetition_separator
    replace \E\ with escape_character
    replace \P\ with truncation_character    # v2.7+ only
    # Process \Xdd\ hex escapes
    # Process \Cxxyy\ and \Mxxyyzz\ character set escapes
    # Preserve unrecognized \Z...\ and other unknown escapes
    return value
```

### 9.4. Recipient Processing Rules

Receivers SHALL:

1. **Ignore unexpected elements:** Segments, fields, components, sub-components, and
   extra repetitions not defined in the expected message structure must be silently
   ignored. This enables forward compatibility.

2. **Treat absent optional segments** as consisting entirely of empty fields.

3. **Treat absent trailing fields and components** as not present (empty).

This means a parser must NOT fail when encountering unknown segments or extra fields
beyond what it expects.

---

## 10. Truncation (v2.7+)

### 10.1. Truncation Indicator

When a field value exceeds the conformance length and the field is marked as truncatable
(`#` in the conformance length column):

1. Truncate at position N-1 (where N is the maximum length).
2. Place the truncation character (default `#`) as the last character.

```
Example: Maximum length 6, value "abcdefgh"
Result:  "abcde#"
```

### 10.2. Edge Case: Data Ends With Truncation Character

If the original data's last character is the truncation character itself, escape it:

```
Example: Maximum length 6, value "abcde#"
Result:  "abcde\P\"
```

### 10.3. Fields Without Truncation Support

Fields marked with `=` in the conformance length column do NOT support truncation.
Values exceeding the limit must be rejected (the sender must fix the data).

---

## 11. Segment Groups and Message Structure

### 11.1. Segment Groups

Segments may be organized into logical groups (enclosed in brackets `[...]` for
optional, braces `{...}` for repeating in the abstract message definition):

```
ADT_A01:
    MSH
    [{SFT}]
    [UAC]
    EVN
    PID
    [PD1]
    [{ROL}]
    [{NK1}]
    PV1
    [PV2]
    [{ROL}]
    [{DB1}]
    [{OBX}]
    ...
```

### 11.2. Segment Ordering

Segments must appear in the order specified by the abstract message definition. Out-of-
order segments should be treated as unexpected and ignored per Section 9.4.

### 11.3. Ambiguity Prevention

If a segment name appears in multiple group positions (at least one optional or
repeating), the appearances must be separated by at least one required segment of a
different name. This prevents parsing ambiguity.

---

## 12. Complete Example

### 12.1. ADT^A08 (Patient Update) with MLLP Framing

```
<0x0B>MSH|^~\&|HIS|HOSPITAL|PHAOS|ARCHIVE|20260322143000||ADT^A08^ADT_A01|MSG00001|P|2.5.1|||AL|NE<CR>EVN|A08|20260322143000<CR>PID|||12345^^^HOSP^MR||Smith^John^M||19800115|M|||123 Main St^^Springfield^IL^62701||555-1234<CR>PV1||I|ICU^301^A|<CR><0x1C><0x0D>
```

### 12.2. ACK Response

```
<0x0B>MSH|^~\&|PHAOS|ARCHIVE|HIS|HOSPITAL|20260322143001||ACK^A08^ACK|ACK_MSG00001|P|2.5.1<CR>MSA|AA|MSG00001<CR><0x1C><0x0D>
```

### 12.3. NAK Response with ERR Segment

```
<0x0B>MSH|^~\&|PHAOS|ARCHIVE|HIS|HOSPITAL|20260322143001||ACK^A08^ACK|ACK_MSG00001|P|2.5.1<CR>MSA|AE|MSG00001|Patient not found<CR>ERR||PID^1^3|204^Unknown key identifier^HL70357|E|||Patient ID 12345 not found in registry<CR><0x1C><0x0D>
```

### 12.4. Escape Sequence Examples

```
# Field containing a literal pipe character:
OBX|1|ST|1234||Blood pressure: 120\F\80 mmHg||

# Field containing a literal caret:
OBX|2|ST|5678||Grade: A\S\B (combined)||

# Field containing a literal backslash:
OBX|3|ST|9012||Path: C:\E\Users\E\Data||

# Formatted text with line breaks:
OBX|4|FT|3456||Line 1\.br\Line 2\.br\Line 3||

# Hex-encoded binary data:
OBX|5|ST|7890||\X48454C4C4F\||  (encodes "HELLO")
```

---

## 13. Implementation Checklist

### 13.1. Parser Must Handle

- [ ] MSH-1 and MSH-2 non-standard positional parsing
- [ ] Custom delimiters (even if always `|^~\&` in practice)
- [ ] Segment splitting on CR (normalize CRLF and LF first)
- [ ] Field splitting by field separator
- [ ] Repetition splitting by repetition separator
- [ ] Component splitting by component separator
- [ ] Sub-component splitting by sub-component separator
- [ ] Trailing empty fields/components (treat as absent)
- [ ] Explicit null (`""`) recognition
- [ ] All delimiter escape sequences (`\F\`, `\S\`, `\T\`, `\R\`, `\E\`, `\P\`)
- [ ] Hex escape sequences (`\Xdd...\`)
- [ ] Formatting escape sequences for FT fields (`\.br\`, `\H\`, `\N\`, etc.)
- [ ] Character set escapes (`\Cxxyy\`, `\Mxxyyzz\`)
- [ ] Unknown escape sequences (preserve, do not error)
- [ ] Forward compatibility (ignore unknown segments and extra fields)

### 13.2. Encoder Must Handle

- [ ] MSH-1/MSH-2 special construction
- [ ] Escape delimiters in field values (escape `\` first)
- [ ] Omit trailing empty fields
- [ ] Segment terminator (CR only, not CRLF)
- [ ] Unique MSH-10 generation
- [ ] Timestamp formatting (DTM: YYYYMMDDHHMMSS[.S[S[S[S]]]][+/-ZZZZ])

### 13.3. MLLP Must Handle

- [ ] Frame wrapping: `<0x0B>` + message + `<0x1C>` + `<0x0D>`
- [ ] Frame extraction: buffer until `<0x1C><0x0D>` sequence found
- [ ] Multiple messages per connection (sequential, not pipelined)
- [ ] Read timeout handling
- [ ] Graceful connection closure
- [ ] Reject data with embedded 0x0B or 0x1C within message body

### 13.4. ACK Builder Must Handle

- [ ] Mode determination from MSH-15/MSH-16
- [ ] Correct sender/receiver field swapping
- [ ] MSA-2 echoing original MSH-10
- [ ] Unique MSH-10 for the ACK itself
- [ ] ERR segment construction with Table 0357 codes
- [ ] ERR-4 severity (E/W/I)
- [ ] AA/AE/AR for original mode
- [ ] CA/CE/CR for enhanced mode (if supported)
