IDENTIFICATION DIVISION.
PROGRAM-ID. LibraryManagementSystem.
AUTHOR. Your Name.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT item-catalog ASSIGN TO 'item-catalog.dat'.
    SELECT loan-records ASSIGN TO 'loan-records.dat'.
    SELECT overdue-notices ASSIGN TO 'overdue-notices.dat'.

DATA DIVISION.
FILE SECTION.
FD item-catalog.
01 ITEM-RECORD.
    05 ITEM-ID              PIC X(10).
    05 ITEM-TITLE           PIC X(50).
    05 ITEM-TYPE            PIC X(10).
    05 AVAILABLE-COPIES     PIC 9(3).

FD loan-records.
01 LOAN-RECORD.
    05 LR-ITEM-ID           PIC X(10).
    05 PATRON-ID            PIC X(10).
    05 LOAN-DATE            PIC 9(8).
    05 DUE-DATE             PIC 9(8).

FD overdue-notices.
01 OVERDUE-NOTICE.
    05 ON-PATRON-ID         PIC X(10).
    05 ON-ITEM-ID           PIC X(10).
    05 ON-ITEM-TITLE        PIC X(50).
    05 ON-DUE-DATE          PIC 9(8).

WORKING-STORAGE SECTION.
01 WS-CURRENT-DATE         PIC 9(8) VALUE 20231015.
01 WS-END-OF-FILE          PIC X VALUE 'N'.
    88 EOF                 VALUE 'Y'.
    88 NOT-EOF             VALUE 'N'.

PROCEDURE DIVISION.
BEGIN.
    OPEN INPUT item-catalog loan-records
        OUTPUT overdue-notices
    PERFORM PROCESS-LOANS UNTIL EOF
    CLOSE item-catalog loan-records overdue-notices
    STOP RUN.

PROCESS-LOANS.
    READ loan-records INTO LOAN-RECORD AT END SET EOF TO TRUE.
    PERFORM UNTIL EOF
        IF DUE-DATE < WS-CURRENT-DATE
            PERFORM GENERATE-OVERDUE-NOTICE
        END-IF
        READ loan-records INTO LOAN-RECORD AT END SET EOF TO TRUE.
    END-PERFORM.

GENERATE-OVERDUE-NOTICE.
    MOVE PATRON-ID TO ON-PATRON-ID
    MOVE LR-ITEM-ID TO ON-ITEM-ID
    MOVE DUE-DATE TO ON-DUE-DATE
    PERFORM FIND-ITEM-TITLE
    WRITE OVERDUE-NOTICE.

FIND-ITEM-TITLE.
    READ item-catalog INTO ITEM-RECORD AT END
        DISPLAY "Item not found in catalog."
        GO TO END-FIND-ITEM-TITLE
    END-READ
    IF ITEM-ID = LR-ITEM-ID
        MOVE ITEM-TITLE TO ON-ITEM-TITLE
    ELSE
        PERFORM FIND-ITEM-TITLE UNTIL ITEM-ID = LR-ITEM-ID OR EOF
    END-IF
    END-FIND-ITEM-TITLE.
