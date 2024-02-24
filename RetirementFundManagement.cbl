IDENTIFICATION DIVISION.
PROGRAM-ID. RetirementFundManagement.
AUTHOR. Your Name.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT account-details ASSIGN TO 'account-details.dat'.
    SELECT annual-summary ASSIGN TO 'annual-summary.dat'.

DATA DIVISION.
FILE SECTION.
FD account-details.
01 ACCOUNT-RECORD.
    05 ACCOUNT-NUMBER      PIC 9(6).
    05 CUSTOMER-NAME       PIC X(25).
    05 CURRENT-BALANCE     PIC 9(7)V99.
    05 ANNUAL-CONTRIBUTION PIC 9(5)V99.

FD annual-summary.
01 SUMMARY-RECORD.
    05 SR-ACCOUNT-NUMBER   PIC 9(6).
    05 SR-CUSTOMER-NAME    PIC X(25).
    05 SR-YEAR-END-BALANCE PIC 9(7)V99.

WORKING-STORAGE SECTION.
01 INTEREST-RATE          PIC V9(3) VALUE 0.05.
01 END-OF-YEAR-BALANCE    PIC 9(7)V99.
01 WS-END-OF-FILE         PIC X VALUE 'N'.
    88 EOF                VALUE 'Y'.
    88 NOT-EOF            VALUE 'N'.

PROCEDURE DIVISION.
BEGIN.
    OPEN INPUT account-details
        OUTPUT annual-summary
    READ account-details AT END SET EOF TO TRUE.
    PERFORM UNTIL EOF
        COMPUTE END-OF-YEAR-BALANCE = CURRENT-BALANCE + (CURRENT-BALANCE * INTEREST-RATE) + ANNUAL-CONTRIBUTION
        MOVE ACCOUNT-NUMBER TO SR-ACCOUNT-NUMBER
        MOVE CUSTOMER-NAME TO SR-CUSTOMER-NAME
        MOVE END-OF-YEAR-BALANCE TO SR-YEAR-END-BALANCE
        WRITE SUMMARY-RECORD
        READ account-details AT END SET EOF TO TRUE.
    END-PERFORM
    CLOSE account-details annual-summary
    STOP RUN.
