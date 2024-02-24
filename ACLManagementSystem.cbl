IDENTIFICATION DIVISION.
PROGRAM-ID. ACLManagementSystem.
AUTHOR. Your Name.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT acl-logs ASSIGN TO 'acl-logs.dat'.
    SELECT unauthorized-access-reports ASSIGN TO 'unauthorized-access-reports.dat'.

DATA DIVISION.
FILE SECTION.
FD acl-logs.
01 ACL-LOG-RECORD.
    05 LOG-DATE            PIC 9(8).
    05 LOG-TIME            PIC 9(6).
    05 ATTEMPTED-IP        PIC X(15).
    05 RESOURCE-ATTEMPTED  PIC X(30).
    05 ACCESS-RESULT       PIC X(10).
        88 ACCESS-GRANTED  VALUE 'GRANTED'.
        88 ACCESS-DENIED   VALUE 'DENIED'.

FD unauthorized-access-reports.
01 UNAUTHORIZED-ACCESS-REPORT.
    05 REPORT-DATE         PIC 9(8).
    05 REPORT-TIME         PIC 9(6).
    05 UAR-ATTEMPTED-IP    PIC X(15).
    05 UAR-RESOURCE        PIC X(30).

WORKING-STORAGE SECTION.
01 WS-CURRENT-DATE        PIC 9(8) VALUE 20231015.
01 WS-END-OF-FILE         PIC X VALUE 'N'.
    88 EOF                VALUE 'Y'.
    88 NOT-EOF            VALUE 'N'.

PROCEDURE DIVISION.
BEGIN.
    OPEN INPUT acl-logs
        OUTPUT unauthorized-access-reports
    PERFORM PROCESS-ACL-LOGS UNTIL EOF
    CLOSE acl-logs unauthorized-access-reports
    STOP RUN.

PROCESS-ACL-LOGS.
    READ acl-logs INTO ACL-LOG-RECORD AT END SET EOF TO TRUE.
    PERFORM UNTIL EOF
        IF ACCESS-DENIED
            PERFORM GENERATE-UNAUTHORIZED-REPORT
        END-IF
        READ acl-logs INTO ACL-LOG-RECORD AT END SET EOF TO TRUE.
    END-PERFORM.

GENERATE-UNAUTHORIZED-REPORT.
    MOVE LOG-DATE TO REPORT-DATE
    MOVE LOG-TIME TO REPORT-TIME
    MOVE ATTEMPTED-IP TO UAR-ATTEMPTED-IP
    MOVE RESOURCE-ATTEMPTED TO UAR-RESOURCE
    WRITE UNAUTHORIZED-ACCESS-REPORT.