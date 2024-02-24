IDENTIFICATION DIVISION.
PROGRAM-ID. SmartGridEnergyManagement.
AUTHOR. Your Name.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT consumption-data ASSIGN TO 'consumption-data.dat'.
    SELECT demand-predictions ASSIGN TO 'demand-predictions.dat'.
    SELECT efficiency-recommendations ASSIGN TO 'efficiency-recommendations.dat'.

DATA DIVISION.
FILE SECTION.
FD consumption-data.
01 CONSUMPTION-RECORD.
    05 METER-ID           PIC X(10).
    05 DATE-TIME          PIC 9(12).
    05 ENERGY-USED        PIC 9(5)V99.

FD demand-predictions.
01 PREDICTION-RECORD.
    05 PD-DATE-TIME       PIC 9(12).
    05 PD-EXPECTED-DEMAND PIC 9(7)V99.

FD efficiency-recommendations.
01 EFFICIENCY-RECORD.
    05 ER-DATE-TIME       PIC 9(12).
    05 ER-ACTION          PIC X(50).

WORKING-STORAGE SECTION.
01 DAILY-CONSUMPTION-TOTALS.
    05 DC-DATE            PIC 9(8).
    05 DC-TOTAL-ENERGY    PIC 9(7)V99.

01 WS-PEAK-DEMAND-THRESHOLD PIC 9(7)V99 VALUE 100000.
01 WS-END-OF-FILE            PIC X VALUE 'N'.
    88 EOF                   VALUE 'Y'.
    88 NOT-EOF               VALUE 'N'.

PROCEDURE DIVISION.
BEGIN.
    OPEN INPUT consumption-data
        OUTPUT demand-predictions efficiency-recommendations
    PERFORM PROCESS-CONSUMPTION-DATA
    CLOSE consumption-data demand-predictions efficiency-recommendations
    STOP RUN.

PROCESS-CONSUMPTION-DATA.
    PERFORM UNTIL EOF
        READ consumption-data INTO CONSUMPTION-RECORD AT END SET EOF TO TRUE
        PERFORM AGGREGATE-DAILY-CONSUMPTION
        PERFORM PREDICT-DEMAND
        PERFORM GENERATE-EFFICIENCY-RECOMMENDATIONS
    END-PERFORM.

AGGREGATE-DAILY-CONSUMPTION.
    COMPUTE DC-TOTAL-ENERGY = DC-TOTAL-ENERGY + ENERGY-USED.

PREDICT-DEMAND.
    IF DC-TOTAL-ENERGY > WS-PEAK-DEMAND-THRESHOLD
        MOVE DC-DATE TO PD-DATE-TIME
        MOVE DC-TOTAL-ENERGY TO PD-EXPECTED-DEMAND
        WRITE PREDICTION-RECORD.

GENERATE-EFFICIENCY-RECOMMENDATIONS.
    IF DC-TOTAL-ENERGY > WS-PEAK-DEMAND-THRESHOLD
        MOVE "Consider reducing non-essential energy usage" TO ER-ACTION
        MOVE DC-DATE TO ER-DATE-TIME
        WRITE EFFICIENCY-RECORD.