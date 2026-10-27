IDENTIFICATION DIVISION.
PROGRAM-ID. SubscriptionManagementSystem.
AUTHOR. Your Name.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT subscription-file ASSIGN TO 'subscription-file.dat'.
    SELECT billing-file ASSIGN TO 'billing-file.dat'.
    SELECT cancellation-file ASSIGN TO 'cancellation-file.dat'.

DATA DIVISION.
FILE SECTION.
FD subscription-file.
01 SUBSCRIPTION-RECORD.
    05 CUSTOMER-ID         PIC X(10).
    05 SUBSCRIPTION-STATUS PIC X.
        88 ACTIVE          VALUE 'A'.
        88 CANCELLED       VALUE 'C'.
    05 SUBSCRIPTION-FEE    PIC 9(5)V99.
    05 RENEWAL-DATE        PIC 9(8).

FD billing-file.
01 BILLING-RECORD.
    05 BR-CUSTOMER-ID      PIC X(10).
    05 BR-SUBSCRIPTION-FEE PIC 9(5)V99.

FD cancellation-file.
01 CANCELLATION-RECORD.
    05 CR-CUSTOMER-ID      PIC X(10).

WORKING-STORAGE SECTION.
01 WS-CURRENT-DATE        PIC 9(8) VALUE 20231001.  /* Example Date */
01 WS-END-OF-FILE         PIC X VALUE 'N'.
    88 EOF                VALUE 'Y'.
    88 NOT-EOF            VALUE 'N'.

PROCEDURE DIVISION.
BEGIN.
    OPEN INPUT subscription-file cancellation-file
        OUTPUT billing-file
    READ subscription-file AT END SET EOF TO TRUE.
    PERFORM UNTIL EOF
        PERFORM PROCESS-CANCELLATIONS
        IF ACTIVE AND RENEWAL-DATE <= WS-CURRENT-DATE
            PERFORM PROCESS-RENEWAL
        END-IF
        READ subscription-file AT END SET EOF TO TRUE.
    END-PERFORM
    CLOSE subscription-file billing-file cancellation-file
    STOP RUN.

PROCESS-CANCELLATIONS.
    PERFORM UNTIL EOF
        READ cancellation-file INTO CANCELLATION-RECORD AT END SET EOF TO TRUE
        IF CR-CUSTOMER-ID = CUSTOMER-ID
            SET CANCELLED TO TRUE
            EXIT PERFORM
        END-IF
    END-PERFORM.

PROCESS-RENEWAL.
    IF NOT CANCELLED
        WRITE BILLING-RECORD FROM SUBSCRIPTION-RECORD
        /* Additional logic to update RENEWAL-DATE in the subscription record could be added here */
    END-IF.
