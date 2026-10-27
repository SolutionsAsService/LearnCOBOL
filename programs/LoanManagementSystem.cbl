IDENTIFICATION DIVISION.
PROGRAM-ID. LoanManagementSystem.
AUTHOR. Your Name.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT loan-details-file ASSIGN TO 'loan-details.dat'.
    SELECT payments-file ASSIGN TO 'payments.dat'.
    SELECT loan-status-report ASSIGN TO 'loan-status-report.dat'.

DATA DIVISION.
FILE SECTION.
FD loan-details-file.
01 LOAN-DETAILS-RECORD.
    05 CUSTOMER-ID        PIC 9(6).
    05 LOAN-ID            PIC 9(6).
    05 LOAN-AMOUNT        PIC 9(7)V99.
    05 REMAINING-BALANCE  PIC 9(7)V99.

FD payments-file.
01 PAYMENT-RECORD.
    05 PR-CUSTOMER-ID     PIC 9(6).
    05 PR-LOAN-ID         PIC 9(6).
    05 PAYMENT-AMOUNT     PIC 9(7)V99.

FD loan-status-report.
01 REPORT-RECORD.
    05 RR-CUSTOMER-ID     PIC 9(6).
    05 RR-LOAN-ID         PIC 9(6).
    05 RR-REMAINING-BAL   PIC 9(7)V99.

WORKING-STORAGE SECTION.
01 WS-END-OF-FILE       PIC X VALUE 'N'.
    88 EOF              VALUE 'Y'.
    88 NOT-EOF          VALUE 'N'.

PROCEDURE DIVISION.
BEGIN.
    OPEN INPUT loan-details-file payments-file
         OUTPUT loan-status-report
    READ loan-details-file AT END SET EOF TO TRUE.
    PERFORM UNTIL EOF
        PERFORM APPLY-PAYMENTS
        WRITE REPORT-RECORD FROM LOAN-DETAILS-RECORD
        READ loan-details-file AT END SET EOF TO TRUE.
    END-PERFORM
    CLOSE loan-details-file payments-file loan-status-report
    STOP RUN.

APPLY-PAYMENTS.
    PERFORM UNTIL EOF
        READ payments-file INTO PAYMENT-RECORD AT END SET EOF TO TRUE.
        IF NOT EOF AND PR-CUSTOMER-ID = CUSTOMER-ID AND PR-LOAN-ID = LOAN-ID
            SUBTRACT PAYMENT-AMOUNT FROM REMAINING-BALANCE
        END-IF
    END-PERFORM.
