# HL7 v2.5.1 Message Structure Reference

Complete segment structure definitions for all 222 message
structures in the HL7 v2.5.1 standard as implemented by this library.

**Generated from code metadata** -- do not edit by hand.
Run `mix hl7v2.gen_docs` to regenerate.

## Notation

| Symbol | Meaning |
|--------|---------|
| `MSH` | Required segment (bold in tree) |
| `[SFT]` | Optional segment |
| `*` | Repeating (0..* or 1..*) |
| `GROUP { ... }` | Named segment group |
| `[GROUP] { ... }` | Optional group |
| Indentation | Nesting depth within groups |


## ACK

### ACK -- General Acknowledgment

Events: (direct)

```
MSH
[SFT*]
MSA
[ERR*]
```

---


## ADR

### ADR_A19 -- ADT Response

Events: ADT^A19

```
MSH
MSA
[ERR]
[QAK]
[QRD]
[QRF]
QUERY_RESPONSE* {
  [EVN]
  PID
  [PD1]
  [ROL*]
  [NK1*]
  PV1
  [PV2]
  [ROL*]
  [DB1*]
  [OBX*]
  [AL1*]
  [DG1*]
  [DRG]
  [PROCEDURE]* {
    PR1
    [ROL*]
  }
  [GT1*]
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3*]
    [ROL*]
  }
  [ACC]
  [UB1]
  [UB2]
}
```

---


## ADT

### ADT_A01 -- Admit/Visit Notification

Events: ADT^A01, ADT^A04, ADT^A08, ADT^A13

```
MSH
[SFT*]
EVN
PATIENT {
  PID
  [PD1]
  [ROL*]
  [NK1*]
  VISIT {
    PV1
    [PV2]
    [ROL*]
  }
  [DB1*]
  [AL1*]
  [DG1*]
  [DRG]
  [PROCEDURE]* {
    PR1
    [ROL*]
  }
  [GT1*]
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3*]
    [ROL*]
  }
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  [ACC]
  [UB1]
  [UB2]
  [PDA]
}
```

---

### ADT_A02 -- Transfer a Patient

Events: ADT^A02

```
MSH
[SFT*]
EVN
PID
[PD1]
[ROL*]
PV1
[PV2]
[ROL*]
[DB1*]
[OBX*]
[PDA]
```

---

### ADT_A03 -- Discharge/End Visit

Events: ADT^A03

```
MSH
[SFT*]
EVN
PID
[PD1]
[ROL*]
[NK1*]
VISIT {
  PV1
  [PV2]
  [ROL*]
}
[DB1*]
[AL1*]
[DG1*]
[DRG]
[PROCEDURE]* {
  PR1
  [ROL*]
}
[GT1*]
[INSURANCE]* {
  IN1
  [IN2]
  [IN3*]
  [ROL*]
}
[ACC]
[PDA]
```

---

### ADT_A04 -- Register a Patient

Events: (direct)

```
MSH
[SFT*]
EVN
PATIENT {
  PID
  [PD1]
  [ROL*]
  [NK1*]
  VISIT {
    PV1
    [PV2]
    [ROL*]
  }
  [DB1*]
  [AL1*]
  [DG1*]
  [DRG]
  [PROCEDURE]* {
    PR1
    [ROL*]
  }
  [GT1*]
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3*]
    [ROL*]
  }
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  [ACC]
  [UB1]
  [UB2]
  [PDA]
}
```

---

### ADT_A05 -- Pre-admit a Patient

Events: ADT^A05, ADT^A14, ADT^A28, ADT^A31

```
MSH
[SFT*]
EVN
PATIENT {
  PID
  [PD1]
  [ROL*]
  [NK1*]
  VISIT {
    PV1
    [PV2]
    [ROL*]
  }
  [DB1*]
  [AL1*]
  [DG1*]
  [DRG]
  [PROCEDURE]* {
    PR1
    [ROL*]
  }
  [GT1*]
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3*]
    [ROL*]
  }
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  [ACC]
  [UB1]
  [UB2]
  [PDA]
}
```

---

### ADT_A06 -- Change an Outpatient to an Inpatient

Events: ADT^A06, ADT^A07

```
MSH
[SFT*]
EVN
PID
[PD1]
[ROL*]
[MRG]
[NK1*]
PV1
[PV2]
[ROL*]
[DB1*]
[AL1*]
[DG1*]
[DRG]
[PROCEDURE]* {
  PR1
  [ROL*]
}
[GT1*]
[INSURANCE]* {
  IN1
  [IN2]
  [IN3*]
  [ROL*]
}
[ACC]
[UB1]
[UB2]
[NTE*]
```

---

### ADT_A08 -- Update Patient Information

Events: (direct)

```
MSH
[SFT*]
EVN
PATIENT {
  PID
  [PD1]
  [ROL*]
  [NK1*]
  VISIT {
    PV1
    [PV2]
    [ROL*]
  }
  [DB1*]
  [AL1*]
  [DG1*]
  [DRG]
  [PROCEDURE]* {
    PR1
    [ROL*]
  }
  [GT1*]
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3*]
    [ROL*]
  }
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  [ACC]
  [UB1]
  [UB2]
  [PDA]
}
```

---

### ADT_A09 -- Patient Departing — Tracking

Events: ADT^A09, ADT^A10, ADT^A11

```
MSH
[SFT*]
EVN
PID
[PD1]
PV1
[PV2]
[DB1*]
[OBX*]
[DG1*]
```

---

### ADT_A12 -- Cancel Transfer

Events: ADT^A12

```
MSH
[SFT*]
EVN
PID
[PD1]
PV1
[PV2]
[DB1*]
[OBX*]
[DG1*]
```

---

### ADT_A15 -- Pending Transfer

Events: ADT^A15

```
MSH
[SFT*]
EVN
PID
[PD1]
[ROL*]
PV1
[PV2]
[ROL*]
[DB1*]
[OBX*]
[DG1*]
```

---

### ADT_A16 -- Pending Discharge

Events: ADT^A16

```
MSH
[SFT*]
EVN
PID
[PD1]
[ROL*]
PV1
[PV2]
[ROL*]
[DB1*]
[OBX*]
[DG1*]
[DRG]
```

---

### ADT_A17 -- Swap Patients

Events: ADT^A17

```
MSH
[SFT*]
EVN
PATIENT_1 {
  PID
  PV1
  [PV2]
  [DB1*]
  [OBX*]
}
PATIENT_2 {
  PID
  PV1
  [PV2]
  [DB1*]
  [OBX*]
}
```

---

### ADT_A18 -- Merge Patient Information

Events: ADT^A18

```
MSH
[SFT*]
EVN
PID
[PD1]
MRG
PV1
```

---

### ADT_A20 -- Bed Status Update

Events: ADT^A20

```
MSH
[SFT*]
EVN
NPU
```

---

### ADT_A21 -- Patient Goes on Leave of Absence

Events: ADT^A21, ADT^A22, ADT^A23, ADT^A25, ADT^A26, ADT^A27, ADT^A29, ADT^A32, ADT^A33, ADT^A56

```
MSH
[SFT*]
EVN
PID
[PD1]
PV1
[PV2]
[DB1*]
[OBX*]
```

---

### ADT_A24 -- Link Patient Information

Events: ADT^A24

```
MSH
[SFT*]
EVN
PID
[PD1]
[PV1]
[DB1*]
PID
[PD1]
[PV1]
[DB1*]
```

---

### ADT_A30 -- Merge Person Information

Events: ADT^A30, ADT^A34, ADT^A35, ADT^A36, ADT^A46, ADT^A47, ADT^A48, ADT^A49

```
MSH
[SFT*]
EVN
PID
[PD1]
MRG
```

---

### ADT_A37 -- Unlink Patient Information

Events: ADT^A37

```
MSH
[SFT*]
EVN
PID
[PD1]
[PV1]
PID
[PD1]
[PV1]
```

---

### ADT_A38 -- Cancel Pre-admit

Events: ADT^A38

```
MSH
[SFT*]
EVN
PID
[PD1]
PV1
[PV2]
[DB1*]
[OBX*]
[DG1*]
[DRG]
```

---

### ADT_A39 -- Merge Patient — Patient ID

Events: ADT^A39, ADT^A40, ADT^A41, ADT^A42, ADT^A57

```
MSH
[SFT*]
EVN
PATIENT* {
  PID
  [PD1]
  MRG
  [PV1]
}
```

---

### ADT_A43 -- Move Patient Information — Patient Identifier List

Events: ADT^A43, ADT^A44

```
MSH
[SFT*]
EVN
PATIENT* {
  PID
  [PD1]
  MRG
}
```

---

### ADT_A45 -- Move Visit Information — Visit Number

Events: ADT^A45

```
MSH
[SFT*]
EVN
MERGE_INFO* {
  PID
  [PD1]
  MRG
  PV1
}
```

---

### ADT_A50 -- Change Visit Number

Events: ADT^A50, ADT^A51, ADT^A53

```
MSH
[SFT*]
EVN
PID
[PD1]
MRG
PV1
```

---

### ADT_A52 -- Cancel Leave of Absence

Events: ADT^A52

```
MSH
[SFT*]
EVN
PID
[PD1]
PV1
[PV2]
[DB1*]
[OBX*]
```

---

### ADT_A54 -- Change Attending Doctor

Events: ADT^A54, ADT^A55

```
MSH
[SFT*]
EVN
PID
[PD1]
ROL*
PV1
[PV2]
[ROL*]
```

---

### ADT_A60 -- Update Allergy Information

Events: ADT^A60

```
MSH
[SFT*]
EVN
PID
[PV1]
[PV2]
[IAM*]
```

---

### ADT_A61 -- Change Consulting Doctor

Events: ADT^A61, ADT^A62

```
MSH
[SFT*]
EVN
PID
[PD1]
[ROL*]
PV1
[PV2]
[ROL*]
```

---


## BAR

### BAR_P01 -- Add Patient Account

Events: BAR^P01

```
MSH
[SFT*]
EVN
PID
[PD1]
VISIT* {
  [PV1]
  [PV2]
  [ROL*]
  [DB1*]
  [OBX*]
  [AL1*]
  [DG1*]
  [DRG]
  [PROCEDURE]* {
    PR1
    [ROL*]
  }
  [GT1*]
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3*]
    [ROL*]
  }
  [ACC]
  [UB1]
  [UB2]
}
```

---

### BAR_P02 -- Purge Patient Account

Events: BAR^P02

```
MSH
[SFT*]
EVN
PATIENT* {
  PID
  PV1
}
```

---

### BAR_P05 -- Update Account

Events: BAR^P05

```
MSH
[SFT*]
EVN
PID
[PD1]
VISIT* {
  [PV1]
  [PV2]
  [ROL*]
  [DB1*]
  [OBX*]
  [AL1*]
  [DG1*]
  [DRG]
  [PROCEDURE]* {
    PR1
    [ROL*]
  }
  [GT1*]
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3*]
    [ROL*]
  }
  [ACC]
  [UB1]
  [UB2]
}
```

---

### BAR_P06 -- End Account

Events: BAR^P06

```
MSH
[SFT*]
EVN
PATIENT* {
  PID
  PV1
}
```

---

### BAR_P10 -- Transmit Ambulance Billing

Events: BAR^P10

```
MSH
[SFT*]
EVN
PATIENT* {
  PID
  PV1
  [DG1*]
  [GP1]
  [PROCEDURE]* {
    PR1
    [GP2*]
  }
}
```

---

### BAR_P12 -- Update Diagnosis/Procedure

Events: BAR^P12

```
MSH
[SFT*]
EVN
PID
PV1
[DG1*]
[PROCEDURE]* {
  PR1
  [ROL*]
}
```

---


## BPS

### BPS_O29 -- Blood Product Dispense Status

Events: BPS^O29

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
  }
}
ORDER* {
  ORC
  BPO
  [NTE*]
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  PRODUCT* {
    BPX
    [NTE*]
  }
}
```

---


## BRP

### BRP_O30 -- Blood Product Dispense Status Ack

Events: BRP^O30

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
  }
  ORDER* {
    ORC
    [BPO]
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [BPX*]
  }
}
```

---


## BRT

### BRT_O32 -- Blood Product Transfusion/Disposition Ack

Events: BRT^O32

```
MSH
MSA
[ERR*]
[SFT*]
```

---


## BTS

### BTS_O31 -- Blood Product Transfusion/Disposition

Events: BTS^O31

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
  }
}
ORDER* {
  ORC
  BPO
  [NTE*]
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  PRODUCT_STATUS* {
    BTX
    [NTE*]
  }
}
```

---


## CCF

### CCF_I22 -- Collaborative Care Fetch

Events: CCF^I22

```
MSH
[SFT*]
PID
[REL*]
```

---


## CCI

### CCI_I22 -- Collaborative Care Information

Events: CCI^I22

```
MSH
[SFT*]
MSA
[ERR*]
PID
[PD1]
[NK1*]
[INSURANCE]* {
  IN1
  [IN2]
  [IN3]
}
[CLINICAL_HISTORY]* {
  ORC
  [CLINICAL_HISTORY_DETAIL]* {
    OBR
    [OBX*]
  }
}
PATIENT_VISITS* {
  PV1
  [PV2]
}
[MEDICATION_HISTORY]* {
  ORC
  [MEDICATION_ORDER_DETAIL] {
    RXO
    RXR*
  }
  [MEDICATION_ENCODING_DETAIL] {
    RXE
    RXR*
  }
  [MEDICATION_ADMINISTRATION_DETAIL]* {
    RXA
    RXR
  }
}
[PROBLEM]* {
  PRB
  [VAR*]
  [OBX*]
}
[GOAL]* {
  GOL
  [VAR*]
  [OBX*]
}
[PATHWAY]* {
  PTH
  [VAR*]
  [OBX*]
}
[REL*]
```

---


## CCQ

### CCQ_I19 -- Collaborative Care Query

Events: CCQ^I19

```
MSH
[SFT*]
RF1
[PROVIDER_CONTACT]* {
  PRD
  [CTD*]
}
[REL*]
```

---


## CCR

### CCR_I16 -- Collaborative Care Referral

Events: CCR^I16, CCR^I17, CCR^I18

```
MSH
[SFT*]
RF1
[PROVIDER_CONTACT]* {
  PRD
  [CTD*]
}
[CLINICAL_ORDER]* {
  ORC
  [CLINICAL_ORDER_TIMING]* {
    TQ1
    [TQ2*]
  }
  [CLINICAL_ORDER_DETAIL]* {
    OBR
    [OBX*]
  }
  [CTI*]
}
PATIENT* {
  PID
  [PD1]
}
[NK1*]
[INSURANCE]* {
  IN1
  [IN2]
  [IN3]
}
[APPOINTMENT_HISTORY]* {
  SCH
  [RESOURCES]* {
    RGS
    [RESOURCE_DETAIL]* {
      AIS
      [AIG]
      [AIL]
      [AIP]
    }
  }
}
[CLINICAL_HISTORY]* {
  ORC
  [CLINICAL_HISTORY_DETAIL]* {
    OBR
    [OBX*]
  }
  [ROLE_CLINICAL_HISTORY]* {
    ROL
    [VAR*]
  }
  [CTI*]
}
PATIENT_VISITS* {
  PV1
  [PV2]
}
[MEDICATION_HISTORY]* {
  ORC
  [MEDICATION_ORDER_DETAIL] {
    RXO
    RXR*
    [RXC*]
  }
  [MEDICATION_ENCODING_DETAIL] {
    RXE
    RXR*
  }
  [MEDICATION_ADMINISTRATION_DETAIL]* {
    RXA
    RXR
  }
  [CTI*]
}
[PROBLEM]* {
  PRB
  [VAR*]
  [ROLE_PROBLEM]* {
    ROL
    [VAR*]
  }
  [OBX*]
}
[GOAL]* {
  GOL
  [VAR*]
  [ROLE_GOAL]* {
    ROL
    [VAR*]
  }
  [OBX*]
}
[PATHWAY]* {
  PTH
  [VAR*]
  [ROLE_PATHWAY]* {
    ROL
    [VAR*]
  }
  [OBX*]
}
[REL*]
```

---


## CCU

### CCU_I20 -- Asynchronous Collaborative Care Update

Events: CCU^I20, CCU^I21

```
MSH
[SFT*]
RF1
[PROVIDER_CONTACT]* {
  PRD
  [CTD*]
}
PATIENT* {
  PID
  [PD1]
}
[NK1*]
[INSURANCE]* {
  IN1
  [IN2]
  [IN3]
}
[CLINICAL_HISTORY]* {
  ORC
  [CLINICAL_HISTORY_DETAIL]* {
    OBR
    [OBX*]
  }
}
PATIENT_VISITS* {
  PV1
  [PV2]
}
[MEDICATION_HISTORY]* {
  ORC
  [MEDICATION_ORDER_DETAIL] {
    RXO
    RXR*
  }
  [MEDICATION_ENCODING_DETAIL] {
    RXE
    RXR*
  }
  [MEDICATION_ADMINISTRATION_DETAIL]* {
    RXA
    RXR
  }
}
[PROBLEM]* {
  PRB
  [VAR*]
  [OBX*]
}
[GOAL]* {
  GOL
  [VAR*]
  [OBX*]
}
[PATHWAY]* {
  PTH
  [VAR*]
  [OBX*]
}
[REL*]
```

---


## CRM

### CRM_C01 -- Clinical Study Registration

Events: CRM^C01, CRM^C02, CRM^C03, CRM^C04, CRM^C05, CRM^C06, CRM^C07, CRM^C08

```
MSH
[SFT*]
PATIENT* {
  PID
  [PV1]
  CSR
  [CSP*]
}
```

---


## CSU

### CSU_C09 -- Unsolicited Study Data

Events: CSU^C09, CSU^C10, CSU^C11, CSU^C12

```
MSH
[SFT*]
PATIENT* {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  CSR
  [STUDY_PHASE]* {
    [CSP]
    [STUDY_SCHEDULE]* {
      [CSS]
      [STUDY_OBSERVATION]* {
        [ORC]
        OBR
        [TIMING_QTY]* {
          TQ1
          [TQ2*]
        }
        OBX*
      }
      [STUDY_PHARM]* {
        [ORC]
        RX_ADMIN* {
          RXA
          RXR
        }
      }
    }
  }
}
```

---


## DFT

### DFT_P03 -- Post Detail Financial Transaction

Events: DFT^P03

```
MSH
[SFT*]
EVN
PID
[PD1]
[ROL*]
[VISIT] {
  PV1
  [PV2]
  [ROL*]
  [DB1*]
}
FINANCIAL* {
  FT1
  [NTE*]
  [FINANCIAL_PROCEDURE]* {
    PR1
    [ROL*]
  }
  [FINANCIAL_INSURANCE]* {
    IN1
    [IN2]
    [IN3*]
  }
  [FINANCIAL_GUARANTOR]* {
    GT1
    [GUARANTOR_INSURANCE]* {
      IN1
      [IN2]
      [IN3*]
    }
  }
}
```

---

### DFT_P11 -- Post Detail Financial Transaction — New

Events: DFT^P11

```
MSH
[SFT*]
EVN
PID
[PD1]
[ROL*]
[VISIT] {
  PV1
  [PV2]
  [ROL*]
  [DB1*]
}
FINANCIAL* {
  FT1
  [FINANCIAL_PROCEDURE]* {
    PR1
    [ROL*]
  }
  [FINANCIAL_INSURANCE]* {
    IN1
    [IN2]
    [IN3*]
    [ROL*]
  }
  [FINANCIAL_GUARANTOR]* {
    GT1
  }
}
[DIAGNOSIS]* {
  DG1
  [DG1]
}
```

---


## DOC

### DOC_T12 -- Document Response

Events: DOC^T12

```
MSH
MSA
[ERR]
[QRD]
RESULT* {
  EVN
  PID
  PV1
  TXA
  [OBX*]
}
```

---


## EAC

### EAC_U07 -- Equipment Command

Events: EAC^U07

```
MSH
[SFT*]
EQU
ECD*
[SAC]
[CNS]
[ROL]
```

---


## EAN

### EAN_U09 -- Automated Equipment Notification

Events: EAN^U09

```
MSH
[SFT*]
EQU
NOTIFICATION* {
  NDS
  [NTE]
}
[ROL]
```

---


## EAR

### EAR_U08 -- Equipment Command Response

Events: EAR^U08

```
MSH
[SFT*]
EQU
COMMAND_RESPONSE* {
  ECD
  [SAC]
  [CNS]
  ECR
}
[ROL]
```

---


## EHC

### EHC_E01 -- Submit Health Care Services Invoice

Events: EHC^E01

```
MSH
[SFT*]
INVOICE_INFORMATION_SUBMIT* {
  IVC
  [CTD*]
  [LOC*]
  [ROL*]
  PRODUCT_SERVICE_SECTION* {
    PSS
    PRODUCT_SERVICE_GROUP* {
      PSG
      PRODUCT_SERVICE_LINE_ITEM* {
        PSL
        [NTE*]
        [ADJ*]
        [ABS]
        [LOC*]
        [ROL*]
      }
    }
  }
}
```

---

### EHC_E02 -- Cancel Health Care Services Invoice

Events: EHC^E02

```
MSH
[SFT*]
INVOICE_INFORMATION_CANCEL* {
  IVC
  [CTD*]
}
```

---

### EHC_E04 -- Re-Assess Health Care Services Invoice Request

Events: EHC^E04

```
MSH
[SFT*]
REASSESSMENT_REQUEST_INFO* {
  IVC
  [CTD*]
  [NTE*]
  PRODUCT_SERVICE_SECTION* {
    PSS
    PRODUCT_SERVICE_GROUP* {
      PSG
      PSL*
    }
  }
}
```

---

### EHC_E10 -- Edit/Adjudication Results

Events: EHC^E10

```
MSH
[SFT*]
MSA
[ERR*]
INVOICE_PROCESSING_RESULTS_INFO* {
  IVC
  IPR
  PRODUCT_SERVICE_SECTION* {
    PSS
    PRODUCT_SERVICE_GROUP* {
      PSG
      PRODUCT_SERVICE_LINE_ITEM* {
        PSL
        [ADJ*]
      }
    }
  }
}
```

---

### EHC_E12 -- Request Additional Information

Events: EHC^E12

```
MSH
[SFT*]
RFI
[CTD*]
IVC
PSS
PSG
[PID]
[PSL*]
REQUEST* {
  [CTD]
  OBR
  [NTE]
  [OBX*]
}
```

---

### EHC_E13 -- Additional Information Response

Events: EHC^E13

```
MSH
[SFT*]
MSA
[ERR*]
RFI
[CTD*]
IVC
PSS
PSG
[PID]
[PSL*]
REQUEST* {
  [CTD]
  OBR
  [NTE]
  [OBX*]
}
```

---

### EHC_E15 -- Payment/Remittance Advice

Events: EHC^E15

```
MSH
[SFT*]
PAYMENT_REMITTANCE_HEADER_INFO {
  PMT
  [PAYMENT_REMITTANCE_DETAIL_INFO]* {
    IPR
    IVC
    PRODUCT_SERVICE_SECTION* {
      PSS
      PRODUCT_SERVICE_GROUP* {
        PSG
        [PSL*]
        [ADJ*]
      }
    }
  }
}
[ADJUSTMENT_PAYEE]* {
  ADJ
  [ROL]
}
```

---

### EHC_E20 -- Submit Authorization Request

Events: EHC^E20

```
MSH
[SFT*]
AUTHORIZATION_REQUEST* {
  IVC
  [CTD*]
  [LOC*]
  [ROL*]
  PAT_INFO* {
    PID
    [ACC]
    INSURANCE* {
      IN1
      [IN2]
    }
    [DIAGNOSIS]* {
      DG1
      [NTE*]
    }
    [PROCEDURE]* {
      PR1
      [NTE*]
    }
  }
}
```

---

### EHC_E21 -- Cancel Authorization Request

Events: EHC^E21

```
MSH
[SFT*]
AUTHORIZATION_REQUEST* {
  IVC
  [CTD*]
}
```

---

### EHC_E24 -- Authorization Response

Events: EHC^E24

```
MSH
[SFT*]
MSA
[ERR*]
AUTHORIZATION_RESPONSE_INFO* {
  IVC
  [CTD*]
}
```

---


## ESR

### ESR_U02 -- Equipment Status Request

Events: ESR^U02

```
MSH
[SFT*]
EQU
[ROL]
```

---


## ESU

### ESU_U01 -- Equipment Status Update

Events: ESU^U01

```
MSH
[SFT*]
EQU
[ISD*]
[ROL]
```

---


## INR

### INR_U06 -- Inventory Request

Events: INR^U06

```
MSH
[SFT*]
EQU
INV*
[ROL]
```

---


## INU

### INU_U05 -- Inventory Update

Events: INU^U05

```
MSH
[SFT*]
EQU
INV*
[ROL]
```

---


## LSU

### LSU_U12 -- Equipment Log/Service Update

Events: LSU^U12

```
MSH
[SFT*]
EQU
EQP*
[ROL]
```

---


## MDM

### MDM_T01 -- Original Document Notification

Events: MDM^T01, MDM^T03, MDM^T05, MDM^T07, MDM^T09, MDM^T11

```
MSH
[SFT*]
EVN
PID
PV1
TXA
```

---

### MDM_T02 -- Original Document Notification and Content

Events: MDM^T02, MDM^T04, MDM^T06, MDM^T08, MDM^T10

```
MSH
[SFT*]
EVN
PID
PV1
TXA
OBSERVATION* {
  OBX
  [NTE*]
}
```

---

### MDM_T03 -- Document Status Change Notification

Events: (direct)

```
MSH
[SFT*]
EVN
PID
PV1
TXA
```

---

### MDM_T04 -- Document Status Change Notification and Content

Events: (direct)

```
MSH
[SFT*]
EVN
PID
PV1
TXA
OBSERVATION* {
  OBX
  [NTE*]
}
```

---

### MDM_T05 -- Document Addendum Notification

Events: (direct)

```
MSH
[SFT*]
EVN
PID
PV1
TXA
```

---

### MDM_T06 -- Document Addendum Notification and Content

Events: (direct)

```
MSH
[SFT*]
EVN
PID
PV1
TXA
OBSERVATION* {
  OBX
  [NTE*]
}
```

---

### MDM_T07 -- Document Edit Notification

Events: (direct)

```
MSH
[SFT*]
EVN
PID
PV1
TXA
```

---

### MDM_T08 -- Document Edit Notification and Content

Events: (direct)

```
MSH
[SFT*]
EVN
PID
PV1
TXA
OBSERVATION* {
  OBX
  [NTE*]
}
```

---

### MDM_T09 -- Document Replacement Notification

Events: (direct)

```
MSH
[SFT*]
EVN
PID
PV1
TXA
```

---

### MDM_T10 -- Document Replacement Notification and Content

Events: (direct)

```
MSH
[SFT*]
EVN
PID
PV1
TXA
OBSERVATION* {
  OBX
  [NTE*]
}
```

---

### MDM_T11 -- Document Cancel Notification

Events: (direct)

```
MSH
[SFT*]
EVN
PID
PV1
TXA
```

---


## MFK

### MFK_M01 -- Master File Acknowledgment

Events: MFK^M01, MFK^M02, MFK^M03, MFK^M04, MFK^M05, MFK^M06, MFK^M07, MFK^M08, MFK^M09, MFK^M10, MFK^M11, MFK^M12, MFK^M13

```
MSH
[SFT*]
MSA
[ERR*]
MFI
[MFA*]
```

---


## MFN

### MFN_M01 -- Master File Not Otherwise Specified

Events: MFN^M01, MFN^M03, MFN^M04, MFN^M06, MFN^M07, MFN^M08, MFN^M09, MFN^M10, MFN^M11, MFN^M12, MFN^M13

```
MSH
[SFT*]
MFI
MF* {
  MFE
  [NTE*]
}
```

---

### MFN_M02 -- Staff/Practitioner Master File

Events: MFN^M02

```
MSH
[SFT*]
MFI
MF_STAFF* {
  MFE
  STF
  [PRA]
  [ORG]
}
```

---

### MFN_M03 -- Master File — Test/Observation

Events: (direct)

```
MSH
[SFT*]
MFI
MF_TEST* {
  MFE
  OM1
  [NTE*]
}
```

---

### MFN_M04 -- Master File — Charge Description

Events: (direct)

```
MSH
[SFT*]
MFI
MF_CDM* {
  MFE
  CDM
  [NTE*]
}
```

---

### MFN_M05 -- Patient Location Master File

Events: MFN^M05

```
MSH
[SFT*]
MFI
MF_LOCATION* {
  MFE
  LOC
  [LCH*]
  [LRL*]
  [MF_LOC_DEPT]* {
    LDP
    [LCH*]
    [LCC*]
  }
}
```

---

### MFN_M06 -- Master File — Clinical Study

Events: (direct)

```
MSH
[SFT*]
MFI
MF_CLIN_STUDY* {
  MFE
  CM0
  [CM1*]
  [CM2*]
}
```

---

### MFN_M07 -- Master File — Observation — Numeric

Events: (direct)

```
MSH
[SFT*]
MFI
MF_OBS_ATTRIBUTES* {
  MFE
  OM1
  [OM2]
  [OM3]
  [OM4]
}
```

---

### MFN_M08 -- Master File — Test/Observation Numeric

Events: (direct)

```
MSH
[SFT*]
MFI
MF_TEST_NUMERIC* {
  MFE
  OM1
  [OM2]
  [OM3]
  [OM4]
}
```

---

### MFN_M09 -- Master File — Test/Observation Categorical

Events: (direct)

```
MSH
[SFT*]
MFI
MF_TEST_CATEGORICAL* {
  MFE
  OM1
  [OM3]
  [OM4*]
}
```

---

### MFN_M10 -- Master File — Test/Observation Batteries

Events: (direct)

```
MSH
[SFT*]
MFI
MF_TEST_BATTERIES* {
  MFE
  OM1
  [OM5]
  [OM4*]
}
```

---

### MFN_M11 -- Master File — Test/Calculated Observations

Events: (direct)

```
MSH
[SFT*]
MFI
MF_TEST_CALCULATED* {
  MFE
  OM1
  [OM6]
  OM2
}
```

---

### MFN_M12 -- Master File — Additional Observation Attributes

Events: (direct)

```
MSH
[SFT*]
MFI
MF_OBS_ATTRIBUTES* {
  MFE
  OM1
  [OM7]
}
```

---

### MFN_M13 -- Master File — Inventory Item

Events: (direct)

```
MSH
[SFT*]
MFI
MF_INV_ITEM* {
  MFE
  IIM
}
```

---

### MFN_M15 -- Master File Notification — Inventory Item Enhanced

Events: MFN^M15

```
MSH
[SFT*]
MFI
MF_INV_ITEM* {
  MFE
  IIM
}
```

---


## MFQ

### MFQ_M01 -- Master File Query

Events: MFQ^M01

```
MSH
[SFT*]
QRD
[QRF]
```

---


## MFR

### MFR_M01 -- Master File Query Response

Events: MFR^M01

```
MSH
[SFT*]
MSA
[ERR*]
[QAK]
QRD
[QRF]
MFI
MF_QUERY* {
  MFE
  [NTE*]
}
[DSC]
```

---

### MFR_M04 -- Master File Response — Charge Description

Events: MFR^M04

```
MSH
[SFT*]
MSA
[ERR*]
[QAK]
QRD
[QRF]
MFI
MF_QUERY* {
  MFE
  CDM
  [LOC*]
  [PRC*]
}
[DSC]
```

---

### MFR_M05 -- Master File Response — Patient Location

Events: MFR^M05

```
MSH
[SFT*]
MSA
[ERR*]
[QAK]
QRD
[QRF]
MFI
MF_QUERY* {
  MFE
  LOC
  [LCH*]
  [LRL*]
  [MF_LOC_DEPT]* {
    LDP
    [LCH*]
    [LCC*]
  }
}
[DSC]
```

---

### MFR_M06 -- Master File Response — Clinical Study

Events: MFR^M06

```
MSH
[SFT*]
MSA
[ERR*]
[QAK]
QRD
[QRF]
MFI
MF_QUERY* {
  MFE
  CM0
  [CM1*]
  [CM2*]
}
[DSC]
```

---

### MFR_M07 -- Master File Response — Calendar/Campaign

Events: MFR^M07

```
MSH
[SFT*]
MSA
[ERR*]
[QAK]
QRD
[QRF]
MFI
MF_QUERY* {
  MFE
  CM0
}
[DSC]
```

---


## NMD

### NMD_N02 -- Application Management Data

Events: NMD^N02

```
MSH
[SFT*]
CLOCK_AND_STATS* {
  NCK
  [NTE]
  [NST]
  [NTE]
  [NSC]
  [NTE]
}
```

---


## NMQ

### NMQ_N01 -- Application Management Query

Events: NMQ^N01

```
MSH
[SFT*]
QRD
[QRF]
[CLOCK_AND_STATS]* {
  NCK
  [NTE]
  [NST]
  [NTE]
  [NSC]
  [NTE]
}
```

---


## NMR

### NMR_N01 -- Application Management Response

Events: NMR^N01

```
MSH
[SFT*]
MSA
[ERR*]
CLOCK_AND_STATS* {
  NCK
  [NTE]
  [NST]
  [NTE]
  [NSC]
  [NTE]
}
```

---


## OMB

### OMB_O27 -- Blood Product Order

Events: OMB^O27

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
  [AL1*]
}
ORDER* {
  ORC
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  BPO
  [SPM]
  [NTE*]
  [DG1*]
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  [FT1*]
  [BLG]
}
```

---


## OMD

### OMD_O03 -- Dietary Order

Events: OMD^O03

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
  [AL1*]
}
ORDER_DIET* {
  ORC
  [DIET] {
    ODS*
    [NTE*]
  }
  [ORDER_TRAY] {
    ODT*
    [NTE*]
  }
}
```

---


## OMG

### OMG_O19 -- General Clinical Order

Events: OMG^O19

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
  [AL1*]
}
ORDER* {
  ORC
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  OBR
  [NTE*]
  [CTD]
  [DG1*]
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  [PRIOR_RESULT]* {
    ORDER_PRIOR* {
      ORC
      OBR
      [NTE*]
      [OBSERVATION_PRIOR]* {
        OBX
        [NTE*]
      }
    }
  }
  [FT1*]
  [CTI*]
  [BLG]
}
```

---


## OMI

### OMI_O23 -- Imaging Order

Events: OMI^O23

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
  [AL1*]
}
ORDER* {
  ORC
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  OBR
  [NTE*]
  [CTD]
  [DG1*]
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  IPC*
}
```

---


## OML

### OML_O21 -- Laboratory Order

Events: OML^O21

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
  [AL1*]
}
ORDER* {
  ORC
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  [OBSERVATION_REQUEST] {
    OBR
    [TCD]
    [NTE*]
    [DG1*]
    [OBSERVATION]* {
      OBX
      [TCD]
      [NTE*]
    }
    [SPM]
    [OBX*]
    [PRIOR_RESULT]* {
      [AL1*]
      ORDER_PRIOR* {
        ORC
        OBR
        [NTE*]
        [OBSERVATION_PRIOR]* {
          OBX
          [NTE*]
        }
      }
    }
  }
  [FT1*]
  [CTI*]
  [BLG]
}
```

---

### OML_O33 -- Laboratory Order — Multiple Orders Per Specimen

Events: OML^O33

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
  [AL1*]
}
SPECIMEN* {
  SPM
  [OBX*]
  [SAC*]
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [OBSERVATION_REQUEST] {
      OBR
      [TCD]
      [NTE*]
      [DG1*]
      [OBSERVATION]* {
        OBX
        [TCD]
        [NTE*]
      }
      [PRIOR_RESULT]* {
        [AL1*]
        ORDER_PRIOR* {
          ORC
          OBR
          [NTE*]
          [OBSERVATION_PRIOR]* {
            OBX
            [NTE*]
          }
        }
      }
    }
    [FT1*]
    [CTI*]
    [BLG]
  }
}
```

---

### OML_O35 -- Laboratory Order — Multiple Orders Per Container

Events: OML^O35

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
  [AL1*]
}
SPECIMEN* {
  SPM
  [OBX*]
  [SAC*]
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [OBSERVATION_REQUEST] {
      OBR
      [TCD]
      [NTE*]
      [DG1*]
      [OBSERVATION]* {
        OBX
        [TCD]
        [NTE*]
      }
    }
    [FT1*]
    [CTI*]
    [BLG]
  }
}
```

---

### OML_O39 -- Specimen Shipment Order

Events: OML^O39

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
  [AL1*]
}
SPECIMEN* {
  SPM
  [OBX*]
  [SAC*]
  [ORDER]* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [OBSERVATION_REQUEST] {
      OBR
      [TCD]
      [NTE*]
      [DG1*]
      [OBSERVATION]* {
        OBX
        [TCD]
        [NTE*]
      }
    }
    [FT1*]
    [CTI*]
    [BLG]
  }
}
```

---


## OMN

### OMN_O07 -- Non-Stock Requisition Order

Events: OMN^O07

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
  [AL1*]
}
ORDER* {
  ORC
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  RQD
  [RQ1]
  [NTE*]
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  [BLG]
}
```

---


## OMP

### OMP_O09 -- Pharmacy/Treatment Order

Events: OMP^O09

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
}
ORDER* {
  ORC
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  RXO
  [NTE*]
  RXR*
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  [FT1*]
  [BLG]
}
```

---


## OMS

### OMS_O05 -- Stock Requisition Order

Events: OMS^O05

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
  [AL1*]
}
ORDER* {
  ORC
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  RQD
  [RQ1]
  [NTE*]
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  [BLG]
}
```

---


## ORA

### ORA_R33 -- Observation Report Acknowledgment

Events: ORA^R33

```
MSH
MSA
[ERR*]
[SFT*]
```

---

### ORA_R41 -- Observation Report Alert Acknowledgment

Events: ORA^R41

```
MSH
MSA
[ERR*]
[SFT*]
```

---


## ORB

### ORB_O28 -- Blood Product Order Acknowledgment

Events: ORB^O28

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [BPO]
  }
}
```

---


## ORD

### ORD_O04 -- Dietary Order Acknowledgment

Events: ORD^O04

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER_DIET* {
    ORC
    [TIMING_DIET]* {
      TQ1
      [TQ2*]
    }
    [ODS*]
    [NTE*]
  }
  [ORDER_TRAY]* {
    ORC
    [TIMING_TRAY]* {
      TQ1
      [TQ2*]
    }
    [ODT*]
    [NTE*]
  }
}
```

---


## ORF

### ORF_R04 -- Response to Query — Transmission of Requested Observation

Events: ORF^R04

```
MSH
MSA
[QRD]
[QRF]
[QUERY_RESPONSE]* {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    [ORC]
    OBR
    [NTE*]
    [TIMING_QTY]* {
      TQ1
      [TQ2*]
    }
    [OBSERVATION]* {
      [OBX]
      [NTE*]
    }
  }
}
[ERR*]
[QAK]
[DSC]
```

---


## ORG

### ORG_O20 -- General Clinical Order Response

Events: ORG^O20

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [OBR]
    [NTE*]
    [CTI*]
  }
}
```

---


## ORI

### ORI_O24 -- Imaging Order Response

Events: ORI^O24

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [OBR]
    [NTE*]
    [IPC*]
  }
}
```

---


## ORL

### ORL_O22 -- General Laboratory Order Response

Events: ORL^O22

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [OBSERVATION_REQUEST] {
      OBR
      [SPM]
      [SAC]
    }
  }
}
```

---

### ORL_O34 -- Laboratory Order Response — Specimen Oriented

Events: ORL^O34

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
  }
  SPECIMEN* {
    SPM
    [SAC*]
    ORDER* {
      ORC
      [TIMING]* {
        TQ1
        [TQ2*]
      }
      [OBSERVATION_REQUEST] {
        OBR
        [SPM]
      }
    }
  }
}
```

---

### ORL_O36 -- Laboratory Order Response — Container Oriented

Events: ORL^O36

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
  }
  SPECIMEN* {
    SPM
    [SAC*]
    ORDER* {
      ORC
      [TIMING]* {
        TQ1
        [TQ2*]
      }
      [OBSERVATION_REQUEST] {
        OBR
      }
    }
  }
}
```

---

### ORL_O40 -- Specimen Shipment Order Response

Events: ORL^O40

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
  }
  SPECIMEN* {
    SPM
    [SAC*]
    [ORDER]* {
      ORC
      [TIMING]* {
        TQ1
        [TQ2*]
      }
      [OBSERVATION_REQUEST] {
        OBR
      }
    }
  }
}
```

---


## ORM

### ORM_O01 -- General Order Message

Events: ORM^O01

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
  [GT1]
}
ORDER* {
  ORC
  [ORDER_DETAIL] {
    OBR
    [NTE*]
    [CTD]
    [DG1*]
    [OBSERVATION]* {
      OBX
      [NTE*]
    }
  }
  [FT1*]
  [CTI*]
  [BLG]
}
```

---


## ORN

### ORN_O08 -- Non-Stock Requisition Acknowledgment

Events: ORN^O08

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [RQD]
    [RQ1]
    [NTE*]
  }
}
```

---


## ORP

### ORP_O10 -- Pharmacy/Treatment Order Acknowledgment

Events: ORP^O10

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [RXO]
    [NTE*]
    [RXR*]
    [RXC*]
  }
}
```

---


## ORR

### ORR_O02 -- General Order Response

Events: ORR^O02

```
MSH
MSA
[ERR*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [OBR]
    [NTE*]
  }
}
```

---


## ORS

### ORS_O06 -- Stock Requisition Acknowledgment

Events: ORS^O06

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [RQD]
    [RQ1]
    [NTE*]
  }
}
```

---


## ORU

### ORU_R01 -- Unsolicited Observation Result

Events: ORU^R01

```
MSH
[SFT*]
PATIENT_RESULT* {
  [PATIENT] {
    PID
    [PD1]
    [NTE*]
    [NK1*]
    [VISIT] {
      PV1
      [PV2]
    }
  }
  ORDER_OBSERVATION* {
    [ORC]
    OBR
    [NTE*]
    [TIMING_QTY]* {
      TQ1
      [TQ2*]
    }
    [CTD]
    [OBSERVATION]* {
      OBX
      [NTE*]
    }
    [SPECIMEN]* {
      SPM
      [OBSERVATION]* {
        OBX
        [NTE*]
      }
    }
    [FT1*]
    [CTI*]
  }
}
[DSC]
```

---

### ORU_R30 -- Unsolicited Point-Of-Care Observation Without Existing Order

Events: ORU^R30, ORU^R31, ORU^R32

```
MSH
[SFT*]
PID
[PD1]
[OBX*]
ORDER_OBSERVATION* {
  ORC
  OBR
  [NTE*]
  [TIMING_QTY]* {
    TQ1
    [TQ2*]
  }
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
}
```

---

### ORU_R32 -- Unsolicited Pre-ordered Point-of-Care Observation

Events: (direct)

```
MSH
[SFT*]
PID
[PD1]
[OBX*]
ORDER_OBSERVATION* {
  ORC
  OBR
  [NTE*]
  [TIMING_QTY]* {
    TQ1
    [TQ2*]
  }
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
}
```

---


## OSQ

### OSQ_Q06 -- Query for Order Status

Events: OSQ^Q06

```
MSH
[SFT*]
QRD
[QRF]
[DSC]
```

---


## OSR

### OSR_Q06 -- Query Response for Order Status

Events: OSR^Q06

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
QAK
QRD
[QRF]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [OBR]
    [NTE*]
  }
}
[DSC]
```

---


## OUL

### OUL_R21 -- Unsolicited Laboratory Observation

Events: OUL^R21

```
MSH
[SFT*]
[NTE]
[PATIENT] {
  PID
  [PD1]
  [PV1]
  [PV2]
}
ORDER_OBSERVATION* {
  [ORC]
  OBR
  [NTE*]
  [TIMING_QTY]* {
    TQ1
    [TQ2*]
  }
  [OBSERVATION]* {
    [OBX]
    [TCD]
    [SID]
    [NTE*]
  }
  [CTI*]
}
```

---

### OUL_R22 -- Unsolicited Specimen Oriented Observation

Events: OUL^R22

```
MSH
[SFT*]
[NTE]
[PATIENT] {
  PID
  [PD1]
  [PV1]
  [PV2]
}
SPECIMEN* {
  SPM
  [OBX*]
  [CONTAINER]* {
    SAC
    [INV]
  }
  ORDER* {
    OBR
    [ORC]
    [NTE*]
    [TIMING_QTY]* {
      TQ1
      [TQ2*]
    }
    [RESULT]* {
      OBX
      [TCD]
      [SID]
      [NTE*]
    }
    [CTI*]
  }
}
```

---

### OUL_R23 -- Unsolicited Specimen Container Oriented Observation

Events: OUL^R23

```
MSH
[SFT*]
[NTE]
[PATIENT] {
  PID
  [PD1]
  [PV1]
  [PV2]
}
SPECIMEN* {
  SPM
  [OBX*]
  CONTAINER* {
    SAC
    [INV]
    ORDER* {
      OBR
      [ORC]
      [NTE*]
      [TIMING_QTY]* {
        TQ1
        [TQ2*]
      }
      [RESULT]* {
        OBX
        [TCD]
        [SID]
        [NTE*]
      }
      [CTI*]
    }
  }
}
```

---

### OUL_R24 -- Unsolicited Order Oriented Observation

Events: OUL^R24

```
MSH
[SFT*]
[NTE]
[PATIENT] {
  PID
  [PD1]
  [PV1]
  [PV2]
}
ORDER* {
  OBR
  [ORC]
  [NTE*]
  [TIMING_QTY]* {
    TQ1
    [TQ2*]
  }
  [SPECIMEN]* {
    SPM
    [OBX*]
    [CONTAINER]* {
      SAC
      [INV]
    }
  }
  [RESULT]* {
    OBX
    [TCD]
    [SID]
    [NTE*]
  }
  [CTI*]
}
```

---


## PEX

### PEX_P07 -- Product Experience

Events: PEX^P07, PEX^P08

```
MSH
[SFT*]
EVN
PID
[PD1]
[NTE*]
EXPERIENCE* {
  PES
  PEX_OBSERVATION* {
    PEO
    PEX_CAUSE* {
      PCR
      [RX_ORDER] {
        RXE
        [TIMING_QTY]* {
          TQ1
          [TQ2*]
        }
        [RXR*]
      }
      [RX_ADMINISTRATION]* {
        RXA
        [RXR]
      }
      [PRB*]
      [OBX*]
      [NTE*]
      [NK1_TIMING_QTY]* {
        NK1
        [TIMING_QTY]* {
          TQ1
          [TQ2*]
        }
      }
    }
  }
}
```

---


## PGL

### PGL_PC6 -- Goal Add

Events: PGL^PC6, PGL^PC7, PGL^PC8

```
MSH
[SFT*]
PID
PATIENT_VISIT {
  PV1
  [PV2]
}
GOAL* {
  GOL
  [NTE*]
  [VAR*]
  [GOAL_ROLE]* {
    ROL
    [VAR*]
  }
  [PATHWAY]* {
    PTH
    [VAR*]
  }
  [GOAL_OBSERVATION]* {
    OBX
    [NTE*]
  }
  [PROBLEM]* {
    PRB
    [NTE*]
    [VAR*]
    [PROBLEM_ROLE]* {
      ROL
      [VAR*]
    }
    [PROBLEM_OBSERVATION]* {
      OBX
      [NTE*]
    }
  }
  [ORDER]* {
    ORC
    [ORDER_DETAIL] {
      OBR
      [NTE*]
      [VAR*]
      [ORDER_OBSERVATION]* {
        OBX
        [NTE*]
        [VAR*]
      }
    }
  }
}
```

---


## PMU

### PMU_B01 -- Add Personnel Record

Events: PMU^B01, PMU^B02, PMU^B05, PMU^B06

```
MSH
[SFT*]
EVN
STF
[PRA*]
[ORG*]
[AFF*]
[LAN*]
[EDU*]
[CER*]
```

---

### PMU_B03 -- Delete Personnel Record

Events: PMU^B03

```
MSH
[SFT*]
EVN
STF
```

---

### PMU_B04 -- Active Practicing Person

Events: PMU^B04

```
MSH
[SFT*]
EVN
STF
[PRA*]
[ORG*]
```

---

### PMU_B07 -- Grant Certificate/Permission

Events: PMU^B07

```
MSH
[SFT*]
EVN
STF
[PRA*]
[CER*]
```

---

### PMU_B08 -- Revoke Certificate/Permission

Events: PMU^B08

```
MSH
[SFT*]
EVN
STF
[PRA*]
[CER*]
```

---


## PPG

### PPG_PCG -- Goal Query Response

Events: PPG^PCG, PPG^PCH, PPG^PCJ

```
MSH
[SFT*]
MSA
[ERR]
[QAK]
QRD
PID
PATIENT_VISIT {
  PV1
  [PV2]
}
GOAL* {
  GOL
  [NTE*]
  [VAR*]
  [GOAL_ROLE]* {
    ROL
    [VAR*]
  }
  [GOAL_OBSERVATION]* {
    OBX
    [NTE*]
  }
  [PROBLEM]* {
    PRB
    [NTE*]
    [VAR*]
    [PROBLEM_OBSERVATION]* {
      OBX
      [NTE*]
    }
    [ORDER]* {
      ORC
      [ORDER_DETAIL] {
        OBR
        [NTE*]
        [VAR*]
        [ORDER_OBSERVATION]* {
          OBX
          [NTE*]
          [VAR*]
        }
      }
    }
  }
}
```

---


## PPP

### PPP_PCB -- Pathway Add

Events: PPP^PCB, PPP^PCC, PPP^PCD

```
MSH
[SFT*]
PID
PATIENT_VISIT {
  PV1
  [PV2]
}
PATHWAY* {
  PTH
  [NTE*]
  [VAR*]
  [PATHWAY_ROLE]* {
    ROL
    [VAR*]
  }
  [PROBLEM]* {
    PRB
    [NTE*]
    [VAR*]
    [PROBLEM_ROLE]* {
      ROL
      [VAR*]
    }
    [PROBLEM_OBSERVATION]* {
      OBX
      [NTE*]
    }
    [GOAL]* {
      GOL
      [NTE*]
      [VAR*]
      [GOAL_ROLE]* {
        ROL
        [VAR*]
      }
      [GOAL_OBSERVATION]* {
        OBX
        [NTE*]
      }
    }
    [ORDER]* {
      ORC
      [ORDER_DETAIL] {
        OBR
        [NTE*]
        [VAR*]
        [ORDER_OBSERVATION]* {
          OBX
          [NTE*]
          [VAR*]
        }
      }
    }
  }
}
```

---


## PPR

### PPR_PC1 -- Problem Add

Events: PPR^PC1, PPR^PC2, PPR^PC3

```
MSH
[SFT*]
PID
PATIENT_VISIT {
  PV1
  [PV2]
}
PROBLEM* {
  PRB
  [NTE*]
  [VAR*]
  [PROBLEM_ROLE]* {
    ROL
    [VAR*]
  }
  [PATHWAY]* {
    PTH
    [VAR*]
  }
  [PROBLEM_OBSERVATION]* {
    OBX
    [NTE*]
  }
  [GOAL]* {
    GOL
    [NTE*]
    [VAR*]
    [GOAL_ROLE]* {
      ROL
      [VAR*]
    }
    [GOAL_OBSERVATION]* {
      OBX
      [NTE*]
    }
  }
  [ORDER]* {
    ORC
    [ORDER_DETAIL] {
      OBR
      [NTE*]
      [VAR*]
      [ORDER_OBSERVATION]* {
        OBX
        [NTE*]
        [VAR*]
      }
    }
  }
}
```

---


## PPT

### PPT_PCL -- Pathway Query Response

Events: PPT^PCL

```
MSH
[SFT*]
MSA
[ERR]
[QAK]
QRD
PID
PATIENT_VISIT {
  PV1
  [PV2]
}
PATHWAY* {
  PTH
  [NTE*]
  [VAR*]
  [PROBLEM]* {
    PRB
    [NTE*]
    [VAR*]
    [PROBLEM_OBSERVATION]* {
      OBX
      [NTE*]
    }
    [ORDER]* {
      ORC
      [ORDER_DETAIL] {
        OBR
        [NTE*]
        [VAR*]
        [ORDER_OBSERVATION]* {
          OBX
          [NTE*]
          [VAR*]
        }
      }
    }
  }
}
```

---


## PPV

### PPV_PCA -- Patient Goal Response

Events: PPV^PCA

```
MSH
[SFT*]
MSA
[ERR*]
[QAK]
QRD
PATIENT* {
  PID
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  GOAL* {
    GOL
    [NTE*]
    [VAR*]
    [GOAL_ROLE]* {
      ROL
      [VAR*]
    }
    [GOAL_PATHWAY]* {
      PTH
      [VAR*]
    }
    [GOAL_OBSERVATION]* {
      OBX
      [NTE*]
    }
    [PROBLEM]* {
      PRB
      [NTE*]
      [VAR*]
      [PROBLEM_ROLE]* {
        ROL
        [VAR*]
      }
      [PROBLEM_OBSERVATION]* {
        OBX
        [NTE*]
      }
    }
    [ORDER]* {
      ORC
      [ORDER_DETAIL] {
        OBR
        [NTE*]
        [VAR*]
        [ORDER_OBSERVATION]* {
          OBX
          [NTE*]
          [VAR*]
        }
      }
    }
  }
}
```

---


## PRR

### PRR_PC5 -- Patient Problem Response

Events: PRR^PC5

```
MSH
[SFT*]
MSA
[ERR*]
[QAK]
QRD
PATIENT* {
  PID
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  PROBLEM* {
    PRB
    [NTE*]
    [VAR*]
    [PROBLEM_ROLE]* {
      ROL
      [VAR*]
    }
    [PROBLEM_PATHWAY]* {
      PTH
      [VAR*]
    }
    [PROBLEM_OBSERVATION]* {
      OBX
      [NTE*]
    }
    [GOAL]* {
      GOL
      [NTE*]
      [VAR*]
      [GOAL_ROLE]* {
        ROL
        [VAR*]
      }
      [GOAL_OBSERVATION]* {
        OBX
        [NTE*]
      }
    }
    [ORDER]* {
      ORC
      [ORDER_DETAIL] {
        OBR
        [NTE*]
        [VAR*]
        [ORDER_OBSERVATION]* {
          OBX
          [NTE*]
          [VAR*]
        }
      }
    }
  }
}
```

---


## PTR

### PTR_PCF -- Patient Pathway Response

Events: PTR^PCF

```
MSH
[SFT*]
MSA
[ERR*]
[QAK]
QRD
PATIENT* {
  PID
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  PROBLEM* {
    PRB
    [NTE*]
    [VAR*]
    [PROBLEM_ROLE]* {
      ROL
      [VAR*]
    }
    [PROBLEM_PATHWAY]* {
      PTH
      [VAR*]
    }
    [PROBLEM_OBSERVATION]* {
      OBX
      [NTE*]
    }
    [GOAL]* {
      GOL
      [NTE*]
      [VAR*]
      [GOAL_ROLE]* {
        ROL
        [VAR*]
      }
      [GOAL_OBSERVATION]* {
        OBX
        [NTE*]
      }
    }
    [ORDER]* {
      ORC
      [ORDER_DETAIL] {
        OBR
        [NTE*]
        [VAR*]
        [ORDER_OBSERVATION]* {
          OBX
          [NTE*]
          [VAR*]
        }
      }
    }
  }
}
```

---


## QBP

### QBP_Q11 -- Query by Parameter — Segment Pattern Response

Events: QBP^Q11

```
MSH
[SFT*]
QPD
RCP
[DSC]
```

---

### QBP_Q13 -- Query by Parameter — Tabular Response

Events: QBP^Q13

```
MSH
[SFT*]
QPD
[RDF]
RCP
[DSC]
```

---

### QBP_Q15 -- Query by Parameter — Display Response

Events: QBP^Q15

```
MSH
[SFT*]
QPD
RCP
[DSC]
```

---

### QBP_Q21 -- Query by Parameter

Events: QBP^Q21, QBP^Q22, QBP^Q23, QBP^Q24, QBP^Q25

```
MSH
[SFT*]
QPD
RCP
[DSC]
```

---

### QBP_Z73 -- Information about Pending Events

Events: QBP^Z73

```
MSH
[SFT*]
QPD
RCP
[DSC]
```

---


## QCK

### QCK_Q02 -- Cancel Query

Events: QCK^Q02

```
MSH
[SFT*]
MSA
[ERR]
[QAK]
```

---


## QCN

### QCN_J01 -- Cancel Subscription

Events: QCN^J01

```
MSH
[SFT*]
QID
```

---


## QRY

### QRY -- Original-Style Query

Events: (direct)

```
MSH
[SFT*]
QRD
[QRF]
[DSC]
```

---

### QRY_A19 -- Patient Query

Events: QRY^A19

```
MSH
[SFT*]
QRD
[QRF]
```

---

### QRY_PC4 -- Problem Query

Events: QRY^PC4, QRY^PC5, QRY^PC9, QRY^PCE, QRY^PCK

```
MSH
[SFT*]
QRD
[QRF]
```

---

### QRY_Q01 -- Query Sent for Immediate Response

Events: QRY^Q01

```
MSH
[SFT*]
QRD
[QRF]
[DSC]
```

---

### QRY_Q02 -- Query Sent for Deferred Response

Events: QRY^Q02

```
MSH
[SFT*]
QRD
[QRF]
[DSC]
```

---

### QRY_R02 -- Query for Results of Observation

Events: QRY^R02

```
MSH
[SFT*]
QRD
[QRF]
[DSC]
```

---


## QSB

### QSB_Q16 -- Create Subscription

Events: QSB^Q16

```
MSH
[SFT*]
QPD
RCP
[DSC]
```

---


## QVR

### QVR_Q17 -- Query for Previous Events

Events: QVR^Q17

```
MSH
[SFT*]
QPD
RCP
[DSC]
```

---


## RAR

### RAR_RAR -- Pharmacy Administration Information

Events: RAR^RAR

```
MSH
MSA
[ERR*]
[SFT*]
DEFINITION* {
  QRD
  [QRF]
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [ADMINISTRATION]* {
      RXA
      RXR
    }
  }
}
```

---


## RAS

### RAS_O17 -- Pharmacy/Treatment Administration

Events: RAS^O17

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [AL1*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
}
ORDER* {
  ORC
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  ADMINISTRATION* {
    RXA
    RXR
    [OBX*]
  }
  [CTI*]
}
```

---


## RCI

### RCI_I05 -- Return Clinical Information

Events: RCI^I05

```
MSH
[SFT*]
MSA
QRD
[QRF]
PROVIDER* {
  PRD
  [CTD*]
}
PID
[DG1*]
[DRG*]
[AL1*]
[OBSERVATION]* {
  OBR
  [NTE*]
  [RESULTS]* {
    OBX
    [NTE*]
  }
}
[NTE*]
```

---


## RCL

### RCL_I06 -- Request Clinical Data Listing

Events: RCL^I06

```
MSH
[SFT*]
MSA
QRD
[QRF]
PROVIDER* {
  PRD
  [CTD*]
}
PID
[DG1*]
[DRG*]
[AL1*]
[NTE*]
[DSP*]
[DSC]
```

---


## RDE

### RDE_O11 -- Pharmacy/Treatment Encoded Order

Events: RDE^O11

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
}
ORDER* {
  ORC
  [TIMING_ENCODED]* {
    TQ1
    [TQ2*]
  }
  RXE
  [NTE*]
  RXR*
  [RXC*]
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  [FT1*]
  [CTI*]
}
```

---


## RDR

### RDR_RDR -- Pharmacy Dispense Information

Events: RDR^RDR

```
MSH
MSA
[ERR*]
[SFT*]
DEFINITION* {
  QRD
  [QRF]
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [DISPENSE]* {
      RXD
      RXR*
      [RXC*]
    }
  }
}
```

---


## RDS

### RDS_O13 -- Pharmacy/Treatment Dispense

Events: RDS^O13

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [PD1]
  [NTE*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
  [INSURANCE]* {
    IN1
    [IN2]
    [IN3]
  }
}
ORDER* {
  ORC
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  RXD
  [NTE*]
  RXR*
  [RXC*]
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
  [FT1*]
}
```

---


## RDY

### RDY_K15 -- Display Based Response

Events: RDY^K15

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[DISPLAY]* {
  DSP
}
[DSC]
```

---


## REF

### REF_I12 -- Patient Referral

Events: REF^I12, REF^I13, REF^I14, REF^I15

```
MSH
[SFT*]
[RF1]
[AUTHORIZATION_CONTACT] {
  AUT
  [CTD]
}
PROVIDER_CONTACT* {
  PRD
  [CTD*]
}
PID
[NK1*]
[GT1*]
[INSURANCE]* {
  IN1
  [IN2]
  [IN3]
}
[ACC]
[DG1*]
[DRG*]
[AL1*]
[PROCEDURE]* {
  PR1
  [ROL*]
}
[OBSERVATION]* {
  OBX
  [NTE*]
}
[PATIENT_VISIT] {
  PV1
  [PV2]
}
[NTE*]
```

---


## RER

### RER_RER -- Pharmacy Encoded Order Information

Events: RER^RER

```
MSH
MSA
[ERR*]
[SFT*]
DEFINITION* {
  QRD
  [QRF]
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    RXE
    RXR*
    [RXC*]
  }
}
```

---


## RGR

### RGR_RGR -- Pharmacy/Treatment Dose Information

Events: RGR^RGR

```
MSH
[SFT*]
MSA
[ERR*]
DEFINITION* {
  QRD
  [QRF]
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [ENCODING] {
      RXE
      RXR*
      [RXC*]
    }
    RXG*
    RXR*
    [RXC*]
  }
}
[DSC]
```

---


## RGV

### RGV_O15 -- Pharmacy/Treatment Give

Events: RGV^O15

```
MSH
[SFT*]
[NTE*]
[PATIENT] {
  PID
  [NTE*]
  [AL1*]
  [PATIENT_VISIT] {
    PV1
    [PV2]
  }
}
ORDER* {
  ORC
  [TIMING_GIVE]* {
    TQ1
    [TQ2*]
  }
  GIVE {
    RXG
    [TIMING_GIVE]* {
      TQ1
      [TQ2*]
    }
    RXR*
    [RXC*]
  }
  [OBSERVATION]* {
    [OBX]
    [NTE*]
  }
}
```

---


## ROR

### ROR_ROR -- Pharmacy Prescription Order Information

Events: ROR^ROR

```
MSH
MSA
[ERR*]
[SFT*]
DEFINITION* {
  QRD
  [QRF]
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    RXO
    RXR*
    [RXC*]
  }
}
```

---


## RPA

### RPA_I08 -- Request for Treatment Authorization Information Response

Events: RPA^I08, RPA^I09, RPA^I10, RPA^I11

```
MSH
[SFT*]
MSA
[RF1]
[AUTHORIZATION] {
  AUT
  [CTD]
}
PROVIDER* {
  PRD
  [CTD*]
}
PID
[NK1*]
[GT1*]
[INSURANCE]* {
  IN1
  [IN2]
  [IN3]
}
[ACC]
[DG1*]
[DRG*]
[AL1*]
PROCEDURE* {
  PR1
  [ROL*]
}
[OBSERVATION]* {
  OBR
  [NTE*]
  [RESULTS]* {
    OBX
    [NTE*]
  }
}
[VISIT] {
  PV1
  [PV2]
}
[NTE*]
```

---


## RPI

### RPI_I01 -- Return Patient Information

Events: RPI^I01

```
MSH
[SFT*]
MSA
PROVIDER* {
  PRD
  [CTD*]
}
PID
[NK1*]
[GUARANTOR_INSURANCE] {
  [GT1*]
  INSURANCE* {
    IN1
    [IN2]
    [IN3]
  }
}
[NTE*]
```

---

### RPI_I04 -- Return Patient Information — Insurance

Events: RPI^I04

```
MSH
[SFT*]
MSA
PROVIDER* {
  PRD
  [CTD*]
}
PID
[NK1*]
[GUARANTOR_INSURANCE] {
  [GT1*]
  INSURANCE* {
    IN1
    [IN2]
    [IN3]
  }
}
[NTE*]
```

---


## RPL

### RPL_I02 -- Return Patient Display List

Events: RPL^I02

```
MSH
[SFT*]
MSA
PROVIDER* {
  PRD
  [CTD*]
}
[NTE*]
[DSP*]
[DSC]
```

---


## RPR

### RPR_I03 -- Return Patient Subscription List

Events: RPR^I03

```
MSH
[SFT*]
MSA
PROVIDER* {
  PRD
  [CTD*]
}
[NTE*]
```

---


## RQA

### RQA_I08 -- Request for Treatment Authorization Information

Events: RQA^I08, RQA^I09, RQA^I10, RQA^I11

```
MSH
[SFT*]
[RF1]
[AUTHORIZATION] {
  AUT
  [CTD]
}
PROVIDER* {
  PRD
  [CTD*]
}
PID
[NK1*]
[GT1*]
[INSURANCE]* {
  IN1
  [IN2]
  [IN3]
}
[ACC]
[DG1*]
[DRG*]
[AL1*]
PROCEDURE* {
  PR1
  [ROL*]
}
[OBSERVATION]* {
  OBR
  [NTE*]
  [RESULTS]* {
    OBX
    [NTE*]
  }
}
[VISIT] {
  PV1
  [PV2]
}
[NTE*]
```

---


## RQC

### RQC_I05 -- Request for Patient Clinical Information

Events: RQC^I05, RQC^I06

```
MSH
[SFT*]
QRD
[QRF]
PROVIDER* {
  PRD
  [CTD*]
}
PID
[NK1*]
[GT1*]
[NTE*]
```

---


## RQI

### RQI_I01 -- Request for Insurance Information

Events: RQI^I01, RQI^I02, RQI^I03

```
MSH
[SFT*]
PROVIDER* {
  PRD
  [CTD*]
}
PID
[NK1*]
[GUARANTOR_INSURANCE] {
  [GT1*]
  INSURANCE* {
    IN1
    [IN2]
    [IN3]
  }
}
[NTE*]
```

---


## RQP

### RQP_I04 -- Request for Patient Demographics

Events: RQP^I04

```
MSH
[SFT*]
PROVIDER* {
  PRD
  [CTD*]
}
PID
[NK1*]
[GT1*]
[NTE*]
```

---


## RRA

### RRA_O18 -- Pharmacy/Treatment Administration Acknowledgment

Events: RRA^O18

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [ADMINISTRATION] {
      [RXA*]
      RXR
    }
  }
}
```

---


## RRD

### RRD_O14 -- Pharmacy/Treatment Dispense Acknowledgment

Events: RRD^O14

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [DISPENSE] {
      RXD
      [RXR*]
      [RXC*]
    }
  }
}
```

---


## RRE

### RRE_O12 -- Pharmacy/Treatment Encoded Order Acknowledgment

Events: RRE^O12

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    RXE
    [RXR*]
    [RXC*]
  }
}
```

---


## RRG

### RRG_O16 -- Pharmacy/Treatment Give Acknowledgment

Events: RRG^O16

```
MSH
MSA
[ERR*]
[SFT*]
[NTE*]
[RESPONSE] {
  [PATIENT] {
    PID
    [NTE*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    [GIVE] {
      RXG
      [TIMING_GIVE]* {
        TQ1
        [TQ2*]
      }
      [RXR*]
      [RXC*]
    }
  }
}
```

---


## RRI

### RRI_I12 -- Return Referral Info

Events: RRI^I12, RRI^I13, RRI^I14, RRI^I15

```
MSH
MSA
[SFT*]
[RF1]
[AUTHORIZATION_CONTACT] {
  AUT
  [CTD]
}
PROVIDER_CONTACT* {
  PRD
  [CTD*]
}
PID
[NK1*]
[GT1*]
[INSURANCE]* {
  IN1
  [IN2]
  [IN3]
}
[ACC]
[DG1*]
[DRG*]
[AL1*]
[PROCEDURE]* {
  PR1
  [ROL*]
}
[OBSERVATION]* {
  OBX
  [NTE*]
}
[PATIENT_VISIT] {
  PV1
  [PV2]
}
[NTE*]
```

---


## RSP

### RSP_K11 -- Segment Pattern Response in Response to QBP^Q11

Events: RSP^K11

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[ROW_DEFINITION] {
  RDF
  [RDT*]
}
[DSC]
```

---

### RSP_K13 -- Segment Pattern Response in Response to QBP^Q13

Events: RSP^K13

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[ROW_DEFINITION] {
  RDF
  [RDT*]
}
[DSC]
```

---

### RSP_K15 -- Display Based Response

Events: RSP^K15

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[DSP*]
[DSC]
```

---

### RSP_K21 -- Segment Pattern Response

Events: RSP^K21, RSP^K22

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[QUERY_RESPONSE]* {
  PID
  [PD1]
  [NK1*]
  [QRI]
}
[DSC]
```

---

### RSP_K23 -- Allocate Identifiers Response

Events: RSP^K23, RSP^K24

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[PID]
[DSC]
```

---

### RSP_K25 -- Personnel Information Response

Events: RSP^K25

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[STAFF]* {
  STF
  [PRA]
  [ORG*]
  [AFF*]
  [LAN*]
  [EDU*]
  [CER*]
}
[DSC]
```

---

### RSP_K31 -- Pharmacy Information Comprehensive Response

Events: RSP^K31

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[RCP]
[RESPONSE]* {
  [PATIENT] {
    PID
    [PD1]
    [NTE*]
    [AL1*]
    [PATIENT_VISIT] {
      PV1
      [PV2]
    }
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    RXD
    RXR*
    [RXC*]
    [OBSERVATION]* {
      [OBX]
      [NTE*]
    }
  }
}
[DSC]
```

---

### RSP_Q11 -- Segment Pattern Response

Events: RSP^Q11

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[QUERY_RESPONSE]* {
  PID
  [PD1]
  [NK1*]
  [QRI]
}
[DSC]
```

---

### RSP_Z82 -- Dispense History Response

Events: RSP^Z82

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[RCP]
[QUERY_RESPONSE]* {
  [PATIENT] {
    PID
    [PD1]
    [NTE*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    RXD
    RXR*
    [RXC*]
    [OBSERVATION]* {
      [OBX]
      [NTE*]
    }
  }
}
[DSC]
```

---

### RSP_Z86 -- Pharmacy Information Comprehensive Response

Events: RSP^Z86

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[QUERY_RESPONSE]* {
  [PATIENT] {
    PID
    [PD1]
    [NTE*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    RXE
    RXR*
    [RXC*]
    [OBSERVATION]* {
      [OBX]
      [NTE*]
    }
  }
}
[DSC]
```

---

### RSP_Z88 -- Pharmacy Encoded Order Response

Events: RSP^Z88

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
RCP
[QUERY_RESPONSE]* {
  [PATIENT] {
    PID
    [PD1]
    [NTE*]
    [AL1*]
  }
  ORDER* {
    ORC
    [TIMING]* {
      TQ1
      [TQ2*]
    }
    RXE
    RXR*
    [RXC*]
    [OBSERVATION]* {
      [OBX]
      [NTE*]
    }
  }
}
[DSC]
```

---

### RSP_Z90 -- Lab Results History Response

Events: RSP^Z90

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
RCP
[QUERY_RESPONSE]* {
  [PATIENT] {
    PID
    [PD1]
    [NK1*]
    [NTE*]
    [VISIT] {
      PV1
      [PV2]
    }
  }
  ORDER* {
    [ORC]
    OBR
    [NTE*]
    [TIMING_QTY]* {
      TQ1
      [TQ2*]
    }
    [OBSERVATION]* {
      OBX
      [NTE*]
    }
  }
}
[DSC]
```

---


## RTB

### RTB_K13 -- Tabular Response

Events: RTB^K13

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[RDF]
[ROW_DEFINITION]* {
  RDT
}
[DSC]
```

---

### RTB_Z74 -- Tabular Response — Pending Events

Events: RTB^Z74

```
MSH
[SFT*]
MSA
[ERR]
QAK
QPD
[RDF]
[RDT*]
[DSC]
```

---


## SIU

### SIU_S12 -- Notification of New Appointment Booking

Events: SIU^S12, SIU^S13, SIU^S14, SIU^S15, SIU^S16, SIU^S17, SIU^S18, SIU^S19, SIU^S20, SIU^S21, SIU^S22, SIU^S23, SIU^S24, SIU^S26

```
MSH
SCH
[TQ1*]
[NTE*]
[PATIENT]* {
  PID
  [PD1]
  [PV1]
  [PV2]
  [DG1*]
}
RESOURCES* {
  RGS
  [SERVICE]* {
    AIS
    [NTE*]
  }
  [GENERAL_RESOURCE]* {
    AIG
    [NTE*]
  }
  [LOCATION_RESOURCE]* {
    AIL
    [NTE*]
  }
  [PERSONNEL_RESOURCE]* {
    AIP
    [NTE*]
  }
}
```

---


## SQM

### SQM_S25 -- Schedule Query Message

Events: SQM^S25

```
MSH
[SFT*]
QRD
[QRF]
[REQUEST] {
  ARQ
  [APR]
  RESOURCES* {
    RGS
    [SERVICE]* {
      AIS
      [APR]
    }
    [GENERAL_RESOURCE]* {
      AIG
      [APR]
    }
    [PERSONNEL_RESOURCE]* {
      AIP
      [APR]
    }
    [LOCATION_RESOURCE]* {
      AIL
      [APR]
    }
  }
}
```

---


## SQR

### SQR_S25 -- Schedule Query Response

Events: SQR^S25

```
MSH
MSA
[ERR*]
[SFT*]
QAK
[SCHEDULE]* {
  SCH
  [TQ1*]
  [NTE*]
  [PATIENT] {
    PID
    [PV1]
    [PV2]
    [DG1*]
  }
  RESOURCES* {
    RGS
    [SERVICE]* {
      AIS
      [NTE*]
    }
    [GENERAL_RESOURCE]* {
      AIG
      [NTE*]
    }
    [PERSONNEL_RESOURCE]* {
      AIP
      [NTE*]
    }
    [LOCATION_RESOURCE]* {
      AIL
      [NTE*]
    }
  }
}
```

---


## SRM

### SRM_S01 -- Schedule Request

Events: SRM^S01, SRM^S02, SRM^S03, SRM^S04, SRM^S05, SRM^S06, SRM^S07, SRM^S08, SRM^S09, SRM^S10, SRM^S11

```
MSH
ARQ
[APR]
[NTE*]
[PATIENT]* {
  PID
  [PV1]
  [PV2]
  [DG1*]
  RESOURCES* {
    RGS
    [SERVICE]* {
      AIS
      [APR]
      [NTE*]
    }
    [GENERAL_RESOURCE]* {
      AIG
      [APR]
      [NTE*]
    }
    [LOCATION_RESOURCE]* {
      AIL
      [APR]
      [NTE*]
    }
    [PERSONNEL_RESOURCE]* {
      AIP
      [APR]
      [NTE*]
    }
  }
}
```

---


## SRR

### SRR_S01 -- Schedule Response

Events: SRR^S01, SRR^S02, SRR^S03, SRR^S04, SRR^S05, SRR^S06, SRR^S07, SRR^S08, SRR^S09, SRR^S10, SRR^S11

```
MSH
MSA
[ERR*]
[SCHEDULE] {
  SCH
  [TQ1*]
  [NTE*]
  [PATIENT]* {
    PID
    [PV1]
    [PV2]
    [DG1*]
  }
  RESOURCES* {
    RGS
    [SERVICE]* {
      AIS
      [NTE*]
    }
    [GENERAL_RESOURCE]* {
      AIG
      [NTE*]
    }
    [LOCATION_RESOURCE]* {
      AIL
      [NTE*]
    }
    [PERSONNEL_RESOURCE]* {
      AIP
      [NTE*]
    }
  }
}
```

---


## SSR

### SSR_U04 -- Specimen Status Request

Events: SSR^U04

```
MSH
[SFT*]
EQU
[ROL]
```

---


## SSU

### SSU_U03 -- Specimen Status Update

Events: SSU^U03

```
MSH
[SFT*]
EQU
SPECIMEN_CONTAINER* {
  SAC
  [SPM]
  [OBX*]
}
```

---


## SUR

### SUR_P09 -- Summary Product Experience

Events: SUR^P09

```
MSH
FACILITY* {
  FAC
  PRODUCT* {
    PSH
    PDC
  }
}
```

---


## TCU

### TCU_U10 -- Test Code Settings Update

Events: TCU^U10

```
MSH
[SFT*]
EQU
TCC*
[ROL]
```

---


## UDM

### UDM_Q05 -- Unsolicited Display Update

Events: UDM^Q05

```
MSH
[SFT*]
URD
[URS]
DSP*
[DSC]
```

---


## VXQ

### VXQ_V01 -- Query for Vaccination Record

Events: VXQ^V01

```
MSH
[SFT*]
QRD
[QRF]
```

---


## VXR

### VXR_V03 -- Vaccination Record Response

Events: VXR^V03

```
MSH
MSA
[SFT*]
[ERR]
QRD
[QRF]
PID
[PD1]
[NK1*]
[ORDER]* {
  ORC
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  RXA
  [RXR]
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
}
```

---


## VXU

### VXU_V04 -- Vaccination Update

Events: VXU^V04

```
MSH
[SFT*]
PID
[PD1]
[NK1*]
[GT1*]
[INSURANCE] {
  IN1
  [IN2]
  [IN3]
}
[ORDER]* {
  ORC
  [TIMING]* {
    TQ1
    [TQ2*]
  }
  RXA
  [RXR]
  [OBSERVATION]* {
    OBX
    [NTE*]
  }
}
```

---


## VXX

### VXX_V02 -- Response to Vaccination Query with Multiple PID Matches

Events: VXX^V02

```
MSH
MSA
[SFT*]
QRD
[QRF]
PATIENT* {
  PID
  [NK1*]
}
```

---


## Abstract Message Structure Sharing Summary

Multiple trigger events share the same abstract message structure.

| Structure | Trigger Events |
|-----------|----------------|
| ADT_A01 | ADT^A01, ADT^A04, ADT^A08, ADT^A13 |
| ADT_A05 | ADT^A05, ADT^A14, ADT^A28, ADT^A31 |
| ADT_A06 | ADT^A06, ADT^A07 |
| ADT_A09 | ADT^A09, ADT^A10, ADT^A11 |
| ADT_A21 | ADT^A21, ADT^A22, ADT^A23, ADT^A25, ADT^A26, ADT^A27, ADT^A29, ADT^A32, ADT^A33, ADT^A56 |
| ADT_A30 | ADT^A30, ADT^A34, ADT^A35, ADT^A36, ADT^A46, ADT^A47, ADT^A48, ADT^A49 |
| ADT_A39 | ADT^A39, ADT^A40, ADT^A41, ADT^A42, ADT^A57 |
| ADT_A43 | ADT^A43, ADT^A44 |
| ADT_A50 | ADT^A50, ADT^A51, ADT^A53 |
| ADT_A54 | ADT^A54, ADT^A55 |
| ADT_A61 | ADT^A61, ADT^A62 |
| CCR_I16 | CCR^I16, CCR^I17, CCR^I18 |
| CCU_I20 | CCU^I20, CCU^I21 |
| CRM_C01 | CRM^C01, CRM^C02, CRM^C03, CRM^C04, CRM^C05, CRM^C06, CRM^C07, CRM^C08 |
| CSU_C09 | CSU^C09, CSU^C10, CSU^C11, CSU^C12 |
| MDM_T01 | MDM^T01, MDM^T03, MDM^T05, MDM^T07, MDM^T09, MDM^T11 |
| MDM_T02 | MDM^T02, MDM^T04, MDM^T06, MDM^T08, MDM^T10 |
| MFK_M01 | MFK^M01, MFK^M02, MFK^M03, MFK^M04, MFK^M05, MFK^M06, MFK^M07, MFK^M08, MFK^M09, MFK^M10, MFK^M11, MFK^M12, MFK^M13 |
| MFN_M01 | MFN^M01, MFN^M03, MFN^M04, MFN^M06, MFN^M07, MFN^M08, MFN^M09, MFN^M10, MFN^M11, MFN^M12, MFN^M13 |
| ORU_R30 | ORU^R30, ORU^R31, ORU^R32 |
| PEX_P07 | PEX^P07, PEX^P08 |
| PGL_PC6 | PGL^PC6, PGL^PC7, PGL^PC8 |
| PMU_B01 | PMU^B01, PMU^B02, PMU^B05, PMU^B06 |
| PPG_PCG | PPG^PCG, PPG^PCH, PPG^PCJ |
| PPP_PCB | PPP^PCB, PPP^PCC, PPP^PCD |
| PPR_PC1 | PPR^PC1, PPR^PC2, PPR^PC3 |
| QBP_Q21 | QBP^Q21, QBP^Q22, QBP^Q23, QBP^Q24, QBP^Q25 |
| QRY_PC4 | QRY^PC4, QRY^PC5, QRY^PC9, QRY^PCE, QRY^PCK |
| REF_I12 | REF^I12, REF^I13, REF^I14, REF^I15 |
| RPA_I08 | RPA^I08, RPA^I09, RPA^I10, RPA^I11 |
| RQA_I08 | RQA^I08, RQA^I09, RQA^I10, RQA^I11 |
| RQC_I05 | RQC^I05, RQC^I06 |
| RQI_I01 | RQI^I01, RQI^I02, RQI^I03 |
| RRI_I12 | RRI^I12, RRI^I13, RRI^I14, RRI^I15 |
| RSP_K21 | RSP^K21, RSP^K22 |
| RSP_K23 | RSP^K23, RSP^K24 |
| SIU_S12 | SIU^S12, SIU^S13, SIU^S14, SIU^S15, SIU^S16, SIU^S17, SIU^S18, SIU^S19, SIU^S20, SIU^S21, SIU^S22, SIU^S23, SIU^S24, SIU^S26 |
| SRM_S01 | SRM^S01, SRM^S02, SRM^S03, SRM^S04, SRM^S05, SRM^S06, SRM^S07, SRM^S08, SRM^S09, SRM^S10, SRM^S11 |
| SRR_S01 | SRR^S01, SRR^S02, SRR^S03, SRR^S04, SRR^S05, SRR^S06, SRR^S07, SRR^S08, SRR^S09, SRR^S10, SRR^S11 |

---


## Segment Quick Reference

| Code | Full Name |
|------|-----------|
| ABS | Abstract |
| ACC | Accident |
| ADJ | ADJ |
| AFF | Professional Affiliation |
| AIG | Appointment Information — General Resource |
| AIL | Appointment Information — Location Resource |
| AIP | Appointment Information — Personnel Resource |
| AIS | Appointment Information — Service |
| AL1 | Patient Allergy Information |
| APR | Appointment Preferences |
| ARQ | Appointment Request |
| AUT | Authorization Information |
| BLG | Billing |
| BPO | Blood Product Order |
| BPX | Blood Product Dispense Status |
| BTX | Blood Product Transfusion/Disposition |
| CDM | Charge Description Master |
| CER | Certificate Detail |
| CM0 | Clinical Study Master |
| CM1 | Clinical Study Phase Master |
| CM2 | Clinical Study Schedule Master |
| CNS | Clear Notification |
| CSP | Clinical Study Phase |
| CSR | Clinical Study Registration |
| CSS | Clinical Study Data Schedule Segment |
| CTD | Contact Data |
| CTI | Clinical Trial Identification |
| DB1 | Disability |
| DG1 | Diagnosis |
| DRG | Diagnosis Related Group |
| DSC | Continuation Pointer |
| DSP | Display Data |
| ECD | Equipment Command |
| ECR | Equipment Command Response |
| EDU | Educational Detail |
| EQP | Equipment/log Service |
| EQU | Equipment Detail |
| ERR | Error |
| EVN | Event Type |
| FAC | Facility |
| FT1 | Financial Transaction |
| GOL | Goal Detail |
| GP1 | Grouping/Reimbursement — Visit |
| GP2 | Grouping/Reimbursement — Procedure Line Item |
| GT1 | Guarantor |
| IAM | Patient Adverse Reaction Information |
| IIM | Inventory Item Master |
| IN1 | Insurance |
| IN2 | Insurance Additional Information |
| IN3 | Insurance Additional Information, Certification |
| INV | Inventory Detail |
| IPC | Imaging Procedure Control Segment |
| IPR | IPR |
| ISD | Interaction Status Detail |
| IVC | IVC |
| LAN | Language Detail |
| LCC | Location Charge Code |
| LCH | Location Characteristic |
| LDP | Location Department |
| LOC | Location Identification |
| LRL | Location Relationship |
| MFA | Master File Acknowledgment |
| MFE | Master File Entry |
| MFI | Master File Identification |
| MRG | Merge Patient Information |
| MSA | Message Acknowledgment |
| MSH | Message Header |
| NCK | System Clock |
| NDS | Notification Detail |
| NK1 | Next of Kin / Associated Parties |
| NPU | Bed Status Update |
| NSC | Application Status Change |
| NST | Application Control Level Statistics |
| NTE | Notes and Comments |
| OBR | Observation Request |
| OBX | Observation/Result |
| ODS | Dietary Orders, Supplements, and Preferences |
| ODT | Diet Tray Instructions |
| OM1 | General Segment |
| OM2 | Numeric Observation |
| OM3 | Categorical Service/Test/Observation |
| OM4 | Observations that Require Specimens |
| OM5 | Observation Batteries (Sets) |
| OM6 | Observations Calculated from Other Observations |
| OM7 | Additional Basic Attributes |
| ORC | Common Order |
| ORG | Practitioner Organization Unit |
| PCR | Possible Causal Relationship |
| PD1 | Patient Additional Demographic |
| PDA | Patient Death and Autopsy |
| PDC | Product Detail Country |
| PEO | Product Experience Observation |
| PES | Product Experience Sender |
| PID | Patient Identification |
| PMT | PMT |
| PR1 | Procedures |
| PRA | Practitioner Detail |
| PRB | Problem Details |
| PRC | Pricing |
| PRD | Provider Data |
| PSG | PSG |
| PSH | Product Summary Header |
| PSL | PSL |
| PSS | PSS |
| PTH | Pathway |
| PV1 | Patient Visit |
| PV2 | Patient Visit — Additional Information |
| QAK | Query Acknowledgment |
| QID | Query Identification |
| QPD | Query Parameter Definition |
| QRD | Original-Style Query Definition |
| QRF | Original Style Query Filter |
| QRI | Query Response Instance |
| RCP | Response Control Parameter |
| RDF | Table Row Definition |
| RDT | Table Row Data |
| REL | REL |
| RF1 | Referral Information |
| RFI | RFI |
| RGS | Resource Group |
| ROL | Role |
| RQ1 | Requisition Detail-1 |
| RQD | Requisition Detail |
| RXA | Pharmacy/Treatment Administration |
| RXC | Pharmacy/Treatment Component Order |
| RXD | Pharmacy/Treatment Dispense |
| RXE | Pharmacy/Treatment Encoded Order |
| RXG | Pharmacy/Treatment Give |
| RXO | Pharmacy/Treatment Order |
| RXR | Pharmacy/Treatment Route |
| SAC | Specimen Container Detail |
| SCH | Scheduling Activity Information |
| SFT | Software Segment |
| SID | Substance Identifier |
| SPM | Specimen |
| STF | Staff Identification |
| TCC | Test Code Configuration |
| TCD | Test Code Detail |
| TQ1 | Timing/Quantity |
| TQ2 | Timing/Quantity Relationship |
| TXA | Transcription Document Header |
| UB1 | UB82 |
| UB2 | UB92 Data |
| URD | Results/Update Definition |
| URS | Unsolicited Selection |
| VAR | Variance |

---

## Sources

- HL7 v2.5.1 Standard
- [Caristix HL7-Definition V2](https://hl7-definition.caristix.com/v2/HL7v2.5.1/TriggerEvents)
- [HL7 Europe v2.5.1 Message Structures](https://www.hl7.eu/HL7v2x/v251/hl7v251msgstruct.htm)
