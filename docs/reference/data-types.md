# HL7 v2.5.1 Data Type Definitions

Complete component-by-component reference for all data types used in Phaos HL7v2
integration. Sourced from the HL7 v2.5.1 standard (Chapter 2A), cross-referenced
against hl7.eu/refactored, vico.org v2.5.1, and v2plus.hl7.org.

## Encoding Rules (General)

HL7v2 uses delimiter-based encoding. The delimiters are declared in MSH-1 and MSH-2:

| Delimiter | Default | Purpose |
|-----------|---------|---------|
| Field separator | `\|` | Separates fields within a segment |
| Component separator | `^` | Separates components within a field |
| Sub-component separator | `&` | Separates sub-components within a component |
| Repetition separator | `~` | Separates repeated occurrences of a field |
| Escape character | `\` | Introduces escape sequences |

Composite data types use `^` between components. When a component is itself a
composite (e.g., HD inside CX), its internal parts use `&` as sub-component
separators.

Empty components are represented by adjacent delimiters (`^^`). Trailing empty
components may be omitted.

---

## Part 1: Primitive Data Types

### 1. ST -- String Data

| Property | Value |
|----------|-------|
| **Abbreviation** | ST |
| **Full name** | String Data |
| **Category** | Primitive |
| **Max length** | 199 (v2.5.1 default; context-dependent) |

**Format specification:**
- Printable characters only. For ASCII (default): hex 20-7E (decimal 32-126),
  excluding HL7 delimiter and escape characters.
- Left-justified, no leading spaces.
- Trailing blanks are optional and ignored in comparisons.
- HL7 delimiter characters must be escaped per Section 2.7.1.
- Intended for short strings (under 1000 characters). Use TX or FT for longer
  content.
- Supports alternate character sets via MSH-18.
- Truncation pattern: standard (truncation character `#` may be appended).

### 2. NM -- Numeric

| Property | Value |
|----------|-------|
| **Abbreviation** | NM |
| **Full name** | Numeric |
| **Category** | Primitive |
| **Max length** | 16 |

**Format specification:**
- Pattern: `[+|-]digits[.digits]`
- Optional leading sign (`+` or `-`); assumed positive if omitted.
- Digits with optional decimal point.
- At least one digit required to the left of the decimal (e.g., `0.1` is valid;
  `.1` is NOT valid).
- If no decimal point, value is an integer.
- Only ASCII digits (0-9), optional sign, and optional decimal point are
  permitted. No other characters.
- Leading zeros are not significant (`01.20` equals `1.2`).
- Trailing zeros after decimal point are not significant.
- Truncation character is NEVER valid in NM.

### 3. DT -- Date

| Property | Value |
|----------|-------|
| **Abbreviation** | DT |
| **Full name** | Date |
| **Category** | Primitive |
| **Min length** | 4 |
| **Max length** | 8 |

**Format specification:**
- Pattern: `YYYY[MM[DD]]`
- Precision is determined by the number of populated digits:
  - 4 digits (`YYYY`) = year precision
  - 6 digits (`YYYYMM`) = month precision
  - 8 digits (`YYYYMMDD`) = day precision
- Truncation character is NEVER valid in DT.
- Month and day are optional as of v2.3 (previously YYYYMMDD was required).

**Examples:**
- `19880704` -- July 4, 1988 (day precision)
- `199503` -- March 1995 (month precision)
- `2026` -- year 2026 (year precision)

### 4. DTM -- Date/Time

| Property | Value |
|----------|-------|
| **Abbreviation** | DTM |
| **Full name** | Date/Time |
| **Category** | Primitive |
| **Min length** | 4 |
| **Max length** | 24 |

**Format specification:**
- Pattern: `YYYY[MM[DD[HH[MM[SS[.S[S[S[S]]]]]]]]][+/-ZZZZ]`
- Precision levels by character count (excluding timezone):

| Characters | Precision |
|------------|-----------|
| 4 | Year |
| 6 | Month |
| 8 | Day |
| 10 | Hour |
| 12 | Minute |
| 14 | Second |
| 15-18 | Fractional second (1-4 decimal places) |

- Timezone offset: `+/-ZZZZ` (hours and minutes offset from UTC).
  - `+0000` = UTC (or known zero offset in v2.9+).
  - `-0000` = UTC without offset info (v2.9+ distinction).
  - If timezone is omitted, the sender's local timezone is assumed.
- The standard recommends including timezone information.

**Examples:**
- `20260322` -- March 22, 2026 (day precision)
- `202603221430` -- March 22, 2026 at 14:30 (minute precision)
- `20260322143022.1234+0100` -- full precision with timezone

### 5. TS -- Time Stamp (legacy, retained for backward compatibility)

| Property | Value |
|----------|-------|
| **Abbreviation** | TS |
| **Full name** | Time Stamp |
| **Category** | Composite (2 components) |
| **Max length** | 26 |
| **Note** | Retained for backward compatibility. In v2.5+, DTM is preferred for new fields. |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Time | DTM | R | 24 | -- |
| 2 | Degree of Precision | ID | B | 1 | 0529 |

- Component 1 follows DTM format rules (see DTM above).
- Component 2 is deprecated ("B" = backward compatible only). Values from Table
  0529: `Y` (year), `L` (month), `D` (day), `H` (hour), `M` (minute), `S`
  (second).
- In practice, TS is used as a single-component type since precision is encoded
  in the DTM format itself.

### 6. ID -- Coded Value for HL7-Defined Tables

| Property | Value |
|----------|-------|
| **Abbreviation** | ID |
| **Full name** | Coded Value for HL7 Defined Tables |
| **Category** | Primitive |
| **Max length** | Context-dependent (typically 1-15) |

**Format specification:**
- Follows ST formatting rules but values are constrained to a specific HL7-defined
  table (Chapter 2C).
- Must be associated with a table number in the field definition.
- Truncation is NOT permitted.
- Values are drawn exclusively from HL7-defined tables (not user-defined; see IS).

### 7. IS -- Coded Value for User-Defined Tables

| Property | Value |
|----------|-------|
| **Abbreviation** | IS |
| **Full name** | Coded Value for User-Defined Tables |
| **Category** | Primitive |
| **Max length** | 20 (standard; varies by table) |

**Format specification:**
- Follows ST formatting rules but values are constrained to a site-defined
  (user-defined) table.
- Must be associated with a table number in the field definition.
- Truncation is NOT permitted.
- As of v2.7, IS usage is restricted to specific fields (HD.1, EI.2, PL.6) and
  backward-compatible cases. CWE is preferred for new fields.

### 8. SI -- Sequence ID

| Property | Value |
|----------|-------|
| **Abbreviation** | SI |
| **Full name** | Sequence ID |
| **Category** | Primitive |
| **Min length** | 1 |
| **Max length** | 4 |

**Format specification:**
- A non-negative integer in NM format.
- Valid range: 0 to 9999.
- Truncation is NOT permitted.
- Used as a sequential counter within repeating structures (e.g., Set ID fields).

### 9. TX -- Text Data

| Property | Value |
|----------|-------|
| **Abbreviation** | TX |
| **Full name** | Text Data |
| **Category** | Primitive |
| **Max length** | No intrinsic limit (implementation-dependent) |

**Format specification:**
- String data intended for user display (terminal or printer).
- Leading spaces ARE significant and must be preserved (unlike ST).
- Trailing spaces must be removed.
- Supports escape character sequences for display control (Section 2.7).
- Repeat delimiters (`~`) function as paragraph terminators / hard carriage
  returns.
- Receiving systems should word-wrap text between delimiters.
- Supports alternate character sets via MSH-18 and MSH-20.

**Difference from ST:** TX preserves leading whitespace for formatting; ST does
not. TX is for display-oriented narrative text; ST is for machine-processable
short strings.

### 10. FT -- Formatted Text Data

| Property | Value |
|----------|-------|
| **Abbreviation** | FT |
| **Full name** | Formatted Text Data |
| **Category** | Primitive |
| **Max length** | 65536 (64 KB, backward-compatible limit) |

**Format specification:**
- Derived from TX with embedded formatting commands.
- Formatting commands are enclosed in escape characters (e.g., `\.sp\` = skip
  one vertical line).
- Formatting instructions must be intrinsic and independent of usage context.
- Formatting command specification: Section 2.7.6.
- Supports alternate character sets via escape sequences.
- Repeat delimiters act as paragraph separators (same as TX).

**Difference from TX:** FT supports embedded formatting escape sequences for
rich-text rendering. TX is plain display text.

### 11. NR -- Numeric Range

| Property | Value |
|----------|-------|
| **Abbreviation** | NR |
| **Full name** | Numeric Range |
| **Category** | Composite (2 components) |
| **Max length** | 33 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Low Value | NM | O | 16 | -- |
| 2 | High Value | NM | O | 16 | -- |

- Specifies the interval between lowest and highest values.
- When a range is open-ended on one side, the corresponding component is null.
- Whether endpoints are inclusive depends on the field-specific usage notes.
- Replaced the CM (composite) data type as of v2.5.

**Example:** `2.5^10.0` -- range from 2.5 to 10.0.

### 12. TN -- Telephone Number (deprecated)

| Property | Value |
|----------|-------|
| **Abbreviation** | TN |
| **Full name** | Telephone Number |
| **Category** | Primitive |
| **Max length** | 199 |
| **Status** | Deprecated as of v2.3. Use XTN instead. |

**Format specification:**
- North American format: `(nnn)nnn-nnnn[Xnnnn][Bnnnn][Cany text]`
  - `(nnn)` = area code
  - `nnn-nnnn` = local number
  - `Xnnnn` = extension
  - `Bnnnn` = beeper code
  - `Cany text` = comment
- International format: digits only, no formatting enforced.
- This type is retained only for backward compatibility with pre-v2.3 messages.

---

## Part 2: Composite Data Types

### 13. CX -- Extended Composite ID with Check Digit

Used for MRN, patient IDs, visit numbers, and other identifiers.

| Property | Value |
|----------|-------|
| **Abbreviation** | CX |
| **Full name** | Extended Composite ID with Check Digit |
| **Category** | Composite |
| **Max length** | 1913 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | ID Number | ST | R | 15 | -- |
| 2 | Check Digit | ST | O | 1 | -- |
| 3 | Check Digit Scheme | ID | O | 3 | 0061 |
| 4 | Assigning Authority | HD | O | 227 | 0363 |
| 5 | Identifier Type Code | ID | O | 5 | 0203 |
| 6 | Assigning Facility | HD | O | 227 | -- |
| 7 | Effective Date | DT | O | 8 | -- |
| 8 | Expiration Date | DT | O | 8 | -- |
| 9 | Assigning Jurisdiction | CWE | O | 705 | -- |
| 10 | Assigning Agency or Department | CWE | O | 705 | 0530 |

**Key tables:**
- **0061** (Check Digit Scheme): `BCV` (Bank Card Validation), `M10` (Mod 10),
  `M11` (Mod 11), `NPI` (NPI check digit).
- **0203** (Identifier Type Code): `MR` (Medical Record), `PI` (Patient Internal),
  `VN` (Visit Number), `AN` (Account Number), `SS` (Social Security), etc.
- **0363** (Assigning Authority): User-defined namespace identifiers.

**Sub-components of CX.4 (Assigning Authority = HD):**

| Sub | Sub-component | Type | Opt | Len | Table |
|-----|---------------|------|-----|-----|-------|
| 4.1 | Namespace ID | IS | O | 20 | 0300 |
| 4.2 | Universal ID | ST | C | 199 | -- |
| 4.3 | Universal ID Type | ID | C | 6 | 0301 |

**Example:** `12345^^^HOSP&2.16.840.1.113883.19.4.6&ISO^MR`
- ID=12345, Assigning Authority=HOSP (OID 2.16.840.1.113883.19.4.6, type ISO),
  Identifier Type=MR (Medical Record Number).

### 14. XPN -- Extended Person Name

Used for patient names, provider names, next of kin, etc.

| Property | Value |
|----------|-------|
| **Abbreviation** | XPN |
| **Full name** | Extended Person Name |
| **Category** | Composite |
| **Max length** | 1103 (v2.5.1) |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Family Name | FN | O | 194 | -- |
| 2 | Given Name | ST | O | 30 | -- |
| 3 | Second and Further Given Names or Initials | ST | O | 30 | -- |
| 4 | Suffix (e.g., JR or III) | ST | O | 20 | -- |
| 5 | Prefix (e.g., DR) | ST | O | 20 | -- |
| 6 | Degree (e.g., MD) | IS | B | 6 | 0360 |
| 7 | Name Type Code | ID | O | 1 | 0200 |
| 8 | Name Representation Code | ID | O | 1 | 0465 |
| 9 | Name Context | CE | O | 483 | 0448 |
| 10 | Name Validity Range | DR | B | 53 | -- |
| 11 | Name Assembly Order | ID | O | 1 | 0444 |
| 12 | Effective Date | TS | O | 26 | -- |
| 13 | Expiration Date | TS | O | 26 | -- |
| 14 | Professional Suffix | ST | O | 199 | -- |

**Optionality key:** `B` = Backward compatible (deprecated; retained for old
implementations).

**Sub-components of XPN.1 (Family Name = FN):**

| Sub | Sub-component | Type | Opt | Len |
|-----|---------------|------|-----|-----|
| 1.1 | Surname | ST | R | 50 |
| 1.2 | Own Surname Prefix | ST | O | 20 |
| 1.3 | Own Surname | ST | O | 50 |
| 1.4 | Surname Prefix From Partner/Spouse | ST | O | 20 |
| 1.5 | Surname From Partner/Spouse | ST | O | 50 |

**Key tables:**
- **0200** (Name Type): `L` (Legal), `D` (Display/Alias), `M` (Maiden), `B`
  (Birth), `A` (Alias), `N` (Nickname), `S` (Coded pseudo-name), `U`
  (Unspecified).
- **0444** (Name Assembly Order): `G` (Prefix Given Middle Family Suffix), `F`
  (Prefix Family Middle Given Suffix).
- **0465** (Name/Address Representation): `A` (Alphabetic), `I` (Ideographic),
  `P` (Phonetic).

**Example:** `Smith&Van&^John^Q^JR^DR^^L^^^G`
- Family=Smith (surname prefix "Van"), Given=John, Middle=Q, Suffix=JR,
  Prefix=DR, Type=Legal, Assembly=Given-first.

### 15. XAD -- Extended Address

| Property | Value |
|----------|-------|
| **Abbreviation** | XAD |
| **Full name** | Extended Address |
| **Category** | Composite |
| **Max length** | 631 (v2.5.1) |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Street Address | SAD | O | 184 | -- |
| 2 | Other Designation | ST | O | 120 | -- |
| 3 | City | ST | O | 50 | -- |
| 4 | State or Province | ST | O | 50 | -- |
| 5 | Zip or Postal Code | ST | O | 12 | -- |
| 6 | Country | ID | O | 3 | 0399 |
| 7 | Address Type | ID | O | 3 | 0190 |
| 8 | Other Geographic Designation | ST | O | 50 | -- |
| 9 | County/Parish Code | IS | O | 20 | 0289 |
| 10 | Census Tract | IS | O | 20 | 0288 |
| 11 | Address Representation Code | ID | O | 1 | 0465 |
| 12 | Address Validity Range | DR | B | 53 | -- |
| 13 | Effective Date | TS | O | 26 | -- |
| 14 | Expiration Date | TS | O | 26 | -- |

**Sub-components of XAD.1 (Street Address = SAD):**

| Sub | Sub-component | Type | Opt | Len |
|-----|---------------|------|-----|-----|
| 1.1 | Street or Mailing Address | ST | O | 120 |
| 1.2 | Street Name | ST | O | 50 |
| 1.3 | Dwelling Number | ST | O | 12 |

**Key tables:**
- **0190** (Address Type): `H` (Home), `B` (Business/Office), `M` (Mailing), `C`
  (Current), `P` (Permanent), `O` (Office), `BR` (Birth), `RH` (Registry Home),
  `BA` (Bad Address), `BDL` (Birth Delivery Location), `L` (Legal), `N`
  (Birth/Nee).
- **0399** (Country Code): ISO 3166-1 three-character codes.

**Example:** `123 Main St&Main St&123^^Springfield^IL^62704^USA^H`

### 16. XTN -- Extended Telecommunication Number

| Property | Value |
|----------|-------|
| **Abbreviation** | XTN |
| **Full name** | Extended Telecommunication Number |
| **Category** | Composite |
| **Max length** | 850 (v2.5.1) |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Telephone Number | ST | B | 199 | -- |
| 2 | Telecommunication Use Code | ID | O | 3 | 0201 |
| 3 | Telecommunication Equipment Type | ID | O | 8 | 0202 |
| 4 | Email Address | ST | O | 199 | -- |
| 5 | Country Code | NM | O | 3 | -- |
| 6 | Area/City Code | NM | O | 5 | -- |
| 7 | Local Number | NM | O | 9 | -- |
| 8 | Extension | NM | O | 5 | -- |
| 9 | Any Text | ST | O | 199 | -- |
| 10 | Extension Prefix | ST | O | 4 | -- |
| 11 | Speed Dial Code | ST | O | 6 | -- |
| 12 | Unformatted Telephone Number | ST | C | 199 | -- |

**Key tables:**
- **0201** (Telecommunication Use Code): `PRN` (Primary Residence Number), `WPN`
  (Work Number), `NET` (Network/Email), `BPN` (Beeper/Pager), `ORN` (Other
  Residence Number), `EMR` (Emergency), `VHN` (Vacation Home).
- **0202** (Telecommunication Equipment Type): `PH` (Telephone), `FX` (Fax), `MD`
  (Modem), `CP` (Cellular), `Internet` (Internet address/email), `BP` (Beeper),
  `X.400` (X.400 email), `TDD` (Telecommunication Device for the Deaf), `TTY`
  (Teletypewriter).

**Usage notes:**
- Component 1 is deprecated (B). Use components 5-7 for structured phone numbers
  or component 12 for unformatted.
- For email addresses: set component 2 = `NET`, component 3 = `Internet`,
  component 4 = email address.
- Component 12 is conditional (C): used when components 5-7 cannot represent the
  number.

**Example (phone):** `^PRN^PH^^34^961^123456^789`
- Use=Primary Residence, Equipment=Phone, Country=34 (Spain), Area=961,
  Local=123456, Extension=789.

**Example (email):** `^NET^Internet^john@example.com`

### 17. CE -- Coded Element (deprecated, retained for backward compatibility)

| Property | Value |
|----------|-------|
| **Abbreviation** | CE |
| **Full name** | Coded Element |
| **Category** | Composite |
| **Max length** | 483 |
| **Status** | Retained for backward compatibility only as of v2.5. Use CWE or CNE instead. |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Identifier | ST | O | 20 | -- |
| 2 | Text | ST | O | 199 | -- |
| 3 | Name of Coding System | ID | O | 20 | 0396 |
| 4 | Alternate Identifier | ST | O | 20 | -- |
| 5 | Alternate Text | ST | O | 199 | -- |
| 6 | Name of Alternate Coding System | ID | O | 20 | 0396 |

**Key table 0396** (Coding System): `I9C` (ICD-9-CM), `I10` (ICD-10), `SNM`
(SNOMED), `LN` (LOINC), `L` (Local), `99zzz` (Local codes), etc.

**Example:** `784.0^Headache^I9C`
- Identifier=784.0, Text=Headache, Coding System=ICD-9-CM.

### 18. CWE -- Coded with Exceptions

Replaces CE in v2.5+. Used when multiple coding systems may apply, the table
can be extended locally, or free text may substitute for a code.

| Property | Value |
|----------|-------|
| **Abbreviation** | CWE |
| **Full name** | Coded with Exceptions |
| **Category** | Composite |
| **Max length** | 705 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Identifier | ST | O | 20 | -- |
| 2 | Text | ST | O | 199 | -- |
| 3 | Name of Coding System | ID | O | 20 | 0396 |
| 4 | Alternate Identifier | ST | O | 20 | -- |
| 5 | Alternate Text | ST | O | 199 | -- |
| 6 | Name of Alternate Coding System | ID | O | 20 | 0396 |
| 7 | Coding System Version ID | ST | C | 10 | -- |
| 8 | Alternate Coding System Version ID | ST | O | 10 | -- |
| 9 | Original Text | ST | O | 199 | -- |

**Usage rules:**
- If only free text is available (no code), populate component 9 (Original Text)
  and leave components 1-3 empty. This is the "exception" that gives CWE its name.
- Component 7 is conditional (C): required if the coding system in component 3
  does not have a default version and the version is ambiguous.
- Components 1-3 form the primary triplet; 4-6 form the alternate triplet.

**Example:** `I48.0^Paroxysmal atrial fibrillation^I10^427.31^Atrial fibrillation^I9C`
- Primary: ICD-10 code I48.0; Alternate: ICD-9-CM code 427.31.

### 19. HD -- Hierarchic Designator

Used to identify sending/receiving applications, facilities, and assigning
authorities. Appears as a component inside CX, EI, PL, and XON.

| Property | Value |
|----------|-------|
| **Abbreviation** | HD |
| **Full name** | Hierarchic Designator |
| **Category** | Composite |
| **Max length** | 227 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Namespace ID | IS | O | 20 | 0300 |
| 2 | Universal ID | ST | C | 199 | -- |
| 3 | Universal ID Type | ID | C | 6 | 0301 |

**Conditional rules:**
- Component 1 may be valued independently as a local identifier.
- Components 2 and 3 must BOTH be valued or BOTH be null (they are a pair).
- If component 1 is present, components 2-3 are optional.
- If components 2-3 are present, component 1 is optional.

**Key table 0301** (Universal ID Type): `DNS` (Internet domain name), `GUID`
(globally unique identifier), `HCD` (CEN Healthcare Coding), `HL7` (HL7
registration), `ISO` (ISO Object Identifier/OID), `L,M,N` (local), `Random`
(random UUID), `URI` (Uniform Resource Identifier), `UUID` (DCE UUID), `x400`
(X.400 MHS identifier), `x500` (X.500 directory name).

**Example:** `HOSP&2.16.840.1.113883.19.4.6&ISO`
- Namespace=HOSP, Universal ID=OID 2.16.840.1.113883.19.4.6, Type=ISO.

### 20. PL -- Person Location

Used to specify patient location (point of care, room, bed, facility, etc.).

| Property | Value |
|----------|-------|
| **Abbreviation** | PL |
| **Full name** | Person Location |
| **Category** | Composite |
| **Max length** | 1230 (v2.5.1) |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Point of Care | IS | O | 20 | 0302 |
| 2 | Room | IS | O | 20 | 0303 |
| 3 | Bed | IS | O | 20 | 0304 |
| 4 | Facility | HD | O | 227 | -- |
| 5 | Location Status | IS | O | 20 | 0306 |
| 6 | Person Location Type | IS | C | 20 | 0305 |
| 7 | Building | IS | O | 20 | 0307 |
| 8 | Floor | IS | O | 20 | 0308 |
| 9 | Location Description | ST | O | 199 | -- |
| 10 | Comprehensive Location Identifier | EI | O | 427 | -- |
| 11 | Assigning Authority for Location | HD | O | 227 | 0363 |

**Key tables:**
- **0302** (Point of Care): Site-defined (e.g., `ER`, `ICU`, `NICU`, `OR`).
- **0305** (Person Location Type): `C` (Clinic), `D` (Department), `H` (Home),
  `N` (Nursing Unit), `O` (Provider's Office), `P` (Phone), `S` (SNF).
- **0306** (Location Status): Site-defined (e.g., `A` (Active), `I` (Inactive)).

**Example:** `ICU^101^A^HOSP&2.16.840.1.113883.19.4.6&ISO^^N`
- Point of Care=ICU, Room=101, Bed=A, Facility=HOSP (OID), Type=Nursing Unit.

### 21. EI -- Entity Identifier

Used for order numbers, filler/placer numbers, and other entity identifiers.

| Property | Value |
|----------|-------|
| **Abbreviation** | EI |
| **Full name** | Entity Identifier |
| **Category** | Composite |
| **Max length** | 427 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Entity Identifier | ST | O | 199 | -- |
| 2 | Namespace ID | IS | O | 20 | 0363 |
| 3 | Universal ID | ST | C | 199 | -- |
| 4 | Universal ID Type | ID | C | 6 | 0301 |

**Conditional rules:**
- Components 3 and 4 follow the same pairing rules as HD: both must be valued or
  both null.
- Components 2-4 collectively identify the assigning authority (the system that
  generated the identifier in component 1).

**Example:** `ORD12345^HOSP^2.16.840.1.113883.19.4.6^ISO`

### 22. MSG -- Message Type

Used in MSH-9 to identify the message type, trigger event, and structure.

| Property | Value |
|----------|-------|
| **Abbreviation** | MSG |
| **Full name** | Message Type |
| **Category** | Composite |
| **Max length** | 15 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Message Code | ID | R | 3 | 0076 |
| 2 | Trigger Event | ID | R | 3 | 0003 |
| 3 | Message Structure | ID | R | 7 | 0354 |

**Key tables:**
- **0076** (Message Type): `ACK` (Acknowledge), `ADT` (Admit/Discharge/Transfer),
  `ORM` (Order), `ORU` (Observation Result Unsolicited), `QBP` (Query by
  Parameter), `RSP` (Segment Pattern Response), `SIU` (Schedule Information
  Unsolicited), `MDM` (Medical Document Management), `BAR` (Add/change billing
  account), `DFT` (Detail Financial Transaction).
- **0003** (Event Type): `A01` (Admit), `A02` (Transfer), `A03` (Discharge), `A04`
  (Register), `A08` (Update Patient Info), `A31` (Update Person Info), `O01`
  (Order), `R01` (Unsolicited Observation), etc.
- **0354** (Message Structure): `ADT_A01`, `ADT_A03`, `ORM_O01`, `ORU_R01`, etc.

**Example:** `ADT^A01^ADT_A01`

### 23. PT -- Processing Type

Used in MSH-11 to indicate processing mode.

| Property | Value |
|----------|-------|
| **Abbreviation** | PT |
| **Full name** | Processing Type |
| **Category** | Composite |
| **Max length** | 3 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Processing ID | ID | O | 1 | 0103 |
| 2 | Processing Mode | ID | O | 1 | 0207 |

**Key tables:**
- **0103** (Processing ID): `D` (Debugging), `P` (Production), `T` (Training).
- **0207** (Processing Mode): `A` (Archive), `R` (Restore from archive), `I`
  (Initial load), `T` (Current processing), not present (Not present; default).

**Example:** `P` (production, no mode specified) or `P^T` (production, current
processing).

### 24. VID -- Version Identifier

Used in MSH-12 to identify the HL7 version.

| Property | Value |
|----------|-------|
| **Abbreviation** | VID |
| **Full name** | Version Identifier |
| **Category** | Composite |
| **Max length** | 973 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Version ID | ID | O | 5 | 0104 |
| 2 | Internationalization Code | CE | O | 483 | 0399 |
| 3 | International Version ID | CE | O | 483 | -- |

**Key table 0104** (Version ID): `2.0`, `2.1`, `2.2`, `2.3`, `2.3.1`, `2.4`,
`2.5`, `2.5.1`, `2.6`, `2.7`, `2.7.1`, `2.8`, `2.8.1`, `2.8.2`, `2.9`.

**Example:** `2.5.1` or `2.5.1^DEU^ISO3166` (v2.5.1, Germany).

### 25. CNE -- Coded with No Exceptions

Like CWE but requires a valid code. Free text alone is NOT permitted.

| Property | Value |
|----------|-------|
| **Abbreviation** | CNE |
| **Full name** | Coded with No Exceptions |
| **Category** | Composite |
| **Max length** | 705 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Identifier | ST | R | 20 | -- |
| 2 | Text | ST | O | 199 | -- |
| 3 | Name of Coding System | ID | O | 20 | 0396 |
| 4 | Alternate Identifier | ST | O | 20 | -- |
| 5 | Alternate Text | ST | O | 199 | -- |
| 6 | Name of Alternate Coding System | ID | O | 20 | 0396 |
| 7 | Coding System Version ID | ST | C | 10 | -- |
| 8 | Alternate Coding System Version ID | ST | O | 10 | -- |
| 9 | Original Text | ST | O | 199 | -- |

**Difference from CWE:** Component 1 (Identifier) is REQUIRED (R) in CNE,
whereas it is optional in CWE. In CNE, a valid coded value must always be
provided; the "exception" of free-text-only is not allowed.

### 26. DR -- Date/Time Range

| Property | Value |
|----------|-------|
| **Abbreviation** | DR |
| **Full name** | Date/Time Range |
| **Category** | Composite |
| **Max length** | 53 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Range Start Date/Time | TS | O | 26 | -- |
| 2 | Range End Date/Time | TS | O | 26 | -- |

- Both components use TS (Time Stamp) format in v2.5.1.
- When only a start is known, component 2 is null (open-ended range).
- When only an end is known, component 1 is null.

**Example:** `20260101^^20261231` (January 1 through December 31, 2026).

### 27. FC -- Financial Class

| Property | Value |
|----------|-------|
| **Abbreviation** | FC |
| **Full name** | Financial Class |
| **Category** | Composite |
| **Max length** | 47 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Financial Class Code | IS | R | 20 | 0064 |
| 2 | Effective Date | TS | O | 26 | -- |

**Key table 0064** (Financial Class): User-defined. Common values include
site-specific codes for insurance types, self-pay, charity, etc.

**Example:** `INS^20260101` (Insurance, effective January 1, 2026).

### 28. XON -- Extended Composite Name and ID for Organizations

| Property | Value |
|----------|-------|
| **Abbreviation** | XON |
| **Full name** | Extended Composite Name and Identification Number for Organizations |
| **Category** | Composite |
| **Max length** | 567 |

| Seq | Component | Type | Opt | Len | Table |
|-----|-----------|------|-----|-----|-------|
| 1 | Organization Name | ST | O | 50 | -- |
| 2 | Organization Name Type Code | IS | O | 20 | 0204 |
| 3 | ID Number | NM | B | 4 | -- |
| 4 | Check Digit | NM | O | 1 | -- |
| 5 | Check Digit Scheme | ID | O | 3 | 0061 |
| 6 | Assigning Authority | HD | O | 227 | 0363 |
| 7 | Identifier Type Code | ID | O | 5 | 0203 |
| 8 | Assigning Facility | HD | O | 227 | -- |
| 9 | Name Representation Code | ID | O | 1 | 0465 |
| 10 | Organization Identifier | ST | O | 20 | -- |

**Key tables:**
- **0204** (Organizational Name Type): `A` (Alias), `D` (Display), `L` (Legal),
  `SL` (Stock Exchange Listing Name).
- Component 3 is deprecated (`B`); use component 10 (Organization Identifier)
  instead.

**Example:** `General Hospital^L^^^^HOSP&2.16.840.1.113883.19.4.6&ISO^XX^^GH001`

---

## Part 3: Sub-Component Types

These types appear as components of composite types and use `&` sub-component
delimiters when embedded.

### FN -- Family Name

Sub-type of XPN component 1.

| Seq | Sub-component | Type | Opt | Len |
|-----|---------------|------|-----|-----|
| 1 | Surname | ST | R | 50 |
| 2 | Own Surname Prefix | ST | O | 20 |
| 3 | Own Surname | ST | O | 50 |
| 4 | Surname Prefix From Partner/Spouse | ST | O | 20 |
| 5 | Surname From Partner/Spouse | ST | O | 50 |

**Encoding:** Sub-components are delimited by `&`. Example:
`Smith&Van&&&` or simply `Smith` when only the surname is needed.

### SAD -- Street Address

Sub-type of XAD component 1.

| Seq | Sub-component | Type | Opt | Len |
|-----|---------------|------|-----|-----|
| 1 | Street or Mailing Address | ST | O | 120 |
| 2 | Street Name | ST | O | 50 |
| 3 | Dwelling Number | ST | O | 12 |

**Encoding:** Sub-components are delimited by `&`. Example:
`123 Main St&Main St&123`

### HD -- Hierarchic Designator (when used as sub-component)

When HD appears inside another composite (e.g., CX.4, PL.4, EI.2-4), its
internal parts are encoded as sub-components using `&`:

`HOSP&2.16.840.1.113883.19.4.6&ISO`

---

## Part 4: Optionality Key

| Code | Meaning |
|------|---------|
| R | Required -- must always be populated |
| O | Optional -- may be empty |
| C | Conditional -- required under certain conditions (specified per field) |
| B | Backward compatible -- deprecated; retained for old implementations |
| W | Withdrawn -- must not be populated (removed from standard) |

---

## Part 5: Quick Reference Summary

### Primitive Types

| Type | Name | Max Len | Format |
|------|------|---------|--------|
| ST | String Data | 199 | Printable chars, left-justified |
| NM | Numeric | 16 | `[+\|-]digits[.digits]` |
| DT | Date | 8 | `YYYY[MM[DD]]` |
| DTM | Date/Time | 24 | `YYYY[MM[DD[HH[MM[SS[.S[S[S[S]]]]]]]]][+/-ZZZZ]` |
| ID | Coded (HL7 tables) | 15 | ST format, constrained to HL7 table |
| IS | Coded (user tables) | 20 | ST format, constrained to user table |
| SI | Sequence ID | 4 | Non-negative integer, 0-9999 |
| TX | Text Data | unlimited | Display text, leading spaces preserved |
| FT | Formatted Text | 65536 | TX with embedded formatting escapes |

### Composite Types

| Type | Name | Components | Max Len |
|------|------|------------|---------|
| TS | Time Stamp | 2 (Time + Degree of Precision) | 26 |
| NR | Numeric Range | 2 (Low + High) | 33 |
| CX | Extended Composite ID | 10 | 1913 |
| XPN | Extended Person Name | 14 | 1103 |
| XAD | Extended Address | 14 | 631 |
| XTN | Extended Telecom Number | 12 | 850 |
| CE | Coded Element | 6 | 483 |
| CWE | Coded with Exceptions | 9 | 705 |
| CNE | Coded with No Exceptions | 9 | 705 |
| HD | Hierarchic Designator | 3 | 227 |
| PL | Person Location | 11 | 1230 |
| EI | Entity Identifier | 4 | 427 |
| MSG | Message Type | 3 | 15 |
| PT | Processing Type | 2 | 3 |
| VID | Version Identifier | 3 | 973 |
| DR | Date/Time Range | 2 | 53 |
| FC | Financial Class | 2 | 47 |
| XON | Organization Name+ID | 10 | 567 |

### Sub-Component Types

| Type | Name | Components |
|------|------|------------|
| FN | Family Name | 5 (Surname + prefixes + partner names) |
| SAD | Street Address | 3 (Street + Street Name + Dwelling Number) |

---

## References

- HL7 v2.5.1 Standard, Chapter 2A: Data Types
- https://www.hl7.eu/HL7v2x/v251/std251/ch02a.html
- https://www.hl7.eu/refactored/dt{TYPE}.html
- https://www.vico.org/HL7_V2_5/v251/hl7v251typ{TYPE}.htm
- http://v2plus.hl7.org/2021Jan/data-type/{TYPE}.html
- HL7 International: https://www.hl7.org/implement/standards/product_brief.cfm?product_id=185
