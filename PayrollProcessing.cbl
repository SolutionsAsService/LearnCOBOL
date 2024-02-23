IDENTIFICATION DIVISION.
PROGRAM-ID. PayrollProcessing.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.

DATA DIVISION.
FILE SECTION.

WORKING-STORAGE SECTION.
01 EMPLOYEE-RECORD.
   05 EMPLOYEE-NAME        PIC X(30).
   05 BASIC-SALARY         PIC 9(5)v99.
   05 TAX-RATE              PIC 9(3)v99.
   05 BONUS                 PIC 9(4)v99.
   05 NET-PAY               PIC 9(5)v99.

01 TAX-DEDUCTION          PIC 9(5)v99.
01 TEMP-NET               PIC 9(5)v99.

PROCEDURE DIVISION.
START-PROGRAM.
    MOVE "John Doe" TO EMPLOYEE-NAME
    MOVE 50000 TO BASIC-SALARY
    MOVE 20 TO TAX-RATE
    MOVE 1500 TO BONUS

    PERFORM CALCULATE-TAX
    PERFORM CALCULATE-NET-PAY
    DISPLAY "Employee Name: " EMPLOYEE-NAME
    DISPLAY "Net Pay: $" NET-PAY
    STOP RUN.

CALCULATE-TAX.
    COMPUTE TAX-DEDUCTION = (BASIC-SALARY * TAX-RATE) / 100.

CALCULATE-NET-PAY.
    COMPUTE TEMP-NET = BASIC-SALARY - TAX-DEDUCTION + BONUS
    MOVE TEMP-NET TO NET-PAY.

END PROGRAM PayrollProcessing.