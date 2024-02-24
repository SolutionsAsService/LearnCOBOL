IDENTIFICATION DIVISION.
PROGRAM-ID. CropRotationManagement.
AUTHOR. Your Name.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT plot-details ASSIGN TO 'plot-details.dat'.
    SELECT rotation-schedule ASSIGN TO 'rotation-schedule.dat'.
    SELECT planting-recommendations ASSIGN TO 'planting-recommendations.dat'.

DATA DIVISION.
FILE SECTION.
FD plot-details.
01 PLOT-RECORD.
    05 PLOT-ID               PIC X(5).
    05 CURRENT-CROP          PIC X(20).
    05 LAST-PLANTED-CROP     PIC X(20).

FD rotation-schedule.
01 ROTATION-RECORD.
    05 ROTATION-CROP         PIC X(20).
    05 FOLLOWING-CROP        PIC X(20).

FD planting-recommendations.
01 RECOMMENDATION-RECORD.
    05 REC-PLOT-ID           PIC X(5).
    05 REC-CROP              PIC X(20).

WORKING-STORAGE SECTION.
01 WS-END-OF-FILE             PIC X VALUE 'N'.
    88 EOF                    VALUE 'Y'.
    88 NOT-EOF                VALUE 'N'.

PROCEDURE DIVISION.
BEGIN.
    OPEN INPUT plot-details rotation-schedule
        OUTPUT planting-recommendations
    PERFORM UNTIL EOF
        READ plot-details INTO PLOT-RECORD AT END SET EOF TO TRUE
        PERFORM GENERATE-RECOMMENDATIONS
    END-PERFORM
    CLOSE plot-details rotation-schedule planting-recommendations
    STOP RUN.

GENERATE-RECOMMENDATIONS.
    READ rotation-schedule INTO ROTATION-RECORD AT END SET EOF TO TRUE.
    PERFORM UNTIL EOF
        IF CURRENT-CROP = ROTATION-CROP
            MOVE PLOT-ID TO REC-PLOT-ID
            MOVE FOLLOWING-CROP TO REC-CROP
            WRITE RECOMMENDATION-RECORD
            EXIT PERFORM
        END-IF
        READ rotation-schedule INTO ROTATION-RECORD AT END SET EOF TO TRUE.
    END-PERFORM.
