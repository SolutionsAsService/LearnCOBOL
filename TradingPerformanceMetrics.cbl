IDENTIFICATION DIVISION.
PROGRAM-ID. TradingPerformanceMetrics.
AUTHOR. Your Name.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT trade-records ASSIGN TO 'trade-records.dat'.
    SELECT performance-report ASSIGN TO 'performance-report.dat'.

DATA DIVISION.
FILE SECTION.
FD trade-records.
01 TRADE-RECORD.
    05 TRADE-ID           PIC X(10).
    05 PROFIT-LOSS        PIC S9(7)V99.

FD performance-report.
01 REPORT-RECORD.
    05 TOTAL-TRADES       PIC 9(5).
    05 TOTAL-WINS         PIC 9(5).
    05 TOTAL-LOSSES       PIC 9(5).
    05 WIN-LOSS-PERCENT   PIC 99V99.

WORKING-STORAGE SECTION.
01 WS-TOTAL-TRADES       PIC 9(5) VALUE 0.
01 WS-TOTAL-WINS         PIC 9(5) VALUE 0.
01 WS-TOTAL-LOSSES       PIC 9(5) VALUE 0.
01 WS-WIN-LOSS-PERCENT   PIC 99V99.
01 WS-END-OF-FILE        PIC X VALUE 'N'.
    88 EOF               VALUE 'Y'.
    88 NOT-EOF           VALUE 'N'.

PROCEDURE DIVISION.
BEGIN.
    OPEN INPUT trade-records
        OUTPUT performance-report
    PERFORM UNTIL EOF
        READ trade-records INTO TRADE-RECORD AT END SET EOF TO TRUE
        IF NOT EOF
            ADD 1 TO WS-TOTAL-TRADES
            IF PROFIT-LOSS > 0
                ADD 1 TO WS-TOTAL-WINS
            ELSE
                ADD 1 TO WS-TOTAL-LOSSES
            END-IF
        END-IF
    END-PERFORM
    COMPUTE WS-WIN-LOSS-PERCENT = (WS-TOTAL-WINS / WS-TOTAL-TRADES) * 100

    MOVE WS-TOTAL-TRADES TO TOTAL-TRADES
    MOVE WS-TOTAL-WINS TO TOTAL-WINS
    MOVE WS-TOTAL-LOSSES TO TOTAL-LOSSES
    MOVE WS-WIN-LOSS-PERCENT TO WIN-LOSS-PERCENT
    WRITE REPORT-RECORD

    CLOSE trade-records performance-report
    STOP RUN.