IDENTIFICATION DIVISION.
PROGRAM-ID. PersonalTaxReturnCalculation.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.

DATA DIVISION.
FILE SECTION.

WORKING-STORAGE SECTION.
01 TAXPAYER-INFO.
   05 TAXPAYER-NAME          PIC X(50).
   05 ANNUAL-INCOME          PIC 9(8)v99.
   05 TAX-DEDUCTIONS         PIC 9(8)v99.
   05 TAXABLE-INCOME         PIC 9(8)v99.
   05 TAX-OWED               PIC 9(8)v99.
   05 TAX-PAID               PIC 9(8)v99.
   05 TAX-REFUND             PIC 9(8)v99.
   05 TAX-DUE                PIC 9(8)v99.

01 TAX-RATES.
   05 LOW-INCOME-RATE        PIC V9(2) VALUE 0.10.
   05 MEDIUM-INCOME-RATE     PIC V9(2) VALUE 0.20.
   05 HIGH-INCOME-RATE       PIC V9(2) VALUE 0.30.

PROCEDURE DIVISION.
START-PROGRAM.
    DISPLAY "Enter Taxpayer Name: "
    ACCEPT TAXPAYER-NAME
    DISPLAY "Enter Annual Income: $"
    ACCEPT ANNUAL-INCOME
    DISPLAY "Enter Tax Deductions: $"
    ACCEPT TAX-DEDUCTIONS

    COMPUTE TAXABLE-INCOME = ANNUAL-INCOME - TAX-DEDUCTIONS

    EVALUATE TRUE
        WHEN TAXABLE-INCOME <= 30000
            COMPUTE TAX-OWED = TAXABLE-INCOME * LOW-INCOME-RATE
        WHEN TAXABLE-INCOME > 30000 AND TAXABLE-INCOME <= 70000
            COMPUTE TAX-OWED = TAXABLE-INCOME * MEDIUM-INCOME-RATE
        WHEN TAXABLE-INCOME > 70000
            COMPUTE TAX-OWED = TAXABLE-INCOME * HIGH-INCOME-RATE
    END-EVALUATE

    DISPLAY "Enter Tax Already Paid: $"
    ACCEPT TAX-PAID

    IF TAX-OWED > TAX-PAID
        COMPUTE TAX-DUE = TAX-OWED - TAX-PAID
        DISPLAY "Additional Tax Due: $" TAX-DUE
    ELSE
        COMPUTE TAX-REFUND = TAX-PAID - TAX-OWED
        DISPLAY "Tax Refund Due: $" TAX-REFUND
    END-IF

    STOP RUN.

END PROGRAM PersonalTaxReturnCalculation.