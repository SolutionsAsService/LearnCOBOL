IDENTIFICATION DIVISION.
PROGRAM-ID. MammalRescueManagement.
AUTHOR. Your Name.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT animal-details ASSIGN TO 'animal-details.dat'.
    SELECT treatment-records ASSIGN TO 'treatment-records.dat'.
    SELECT adoption-status ASSIGN TO 'adoption-status.dat'.

DATA DIVISION.
FILE SECTION.
FD animal-details.
01 ANIMAL-RECORD.
    05 ANIMAL-ID            PIC X(10).
    05 SPECIES              PIC X(20).
    05 INTAKE-DATE          PIC 9(8).
    05 HEALTH-STATUS        PIC X(20).

FD treatment-records.
01 TREATMENT-RECORD.
    05 TR-ANIMAL-ID         PIC X(10).
    05 TREATMENT-DATE       PIC 9(8).
    05 TREATMENT            PIC X(50).

FD adoption-status.
01 ADOPTION-RECORD.
    05 AD-ANIMAL-ID         PIC X(10).
    05 ADOPTION-DATE        PIC 9(8).
    05 ADOPTED-BY           PIC X(30).

WORKING-STORAGE SECTION.
01 WS-END-OF-FILE           PIC X VALUE 'N'.
    88 EOF                  VALUE 'Y'.
    88 NOT-EOF              VALUE 'N'.

PROCEDURE DIVISION.
BEGIN.
    OPEN INPUT animal-details treatment-records
        OUTPUT adoption-status
    PERFORM PROCESS-ANIMALS UNTIL EOF
    CLOSE animal-details treatment-records adoption-status
    STOP RUN.

PROCESS-ANIMALS.
    READ animal-details INTO ANIMAL-RECORD AT END SET EOF TO TRUE.
    PERFORM UNTIL EOF
        PERFORM TRACK-TREATMENTS
        PERFORM UPDATE-ADOPTION-STATUS
        READ animal-details INTO ANIMAL-RECORD AT END SET EOF TO TRUE.
    END-PERFORM.

TRACK-TREATMENTS.
    PERFORM UNTIL EOF
        READ treatment-records INTO TREATMENT-RECORD AT END SET EOF TO TRUE.
        IF TR-ANIMAL-ID = ANIMAL-ID
            DISPLAY "Treatment for ", ANIMAL-ID, ": ", TREATMENT
        END-IF
    END-PERFORM.

UPDATE-ADOPTION-STATUS.
    IF HEALTH-STATUS = "Ready for Adoption"
        MOVE ANIMAL-ID TO AD-ANIMAL-ID
        DISPLAY "Enter Adoption Date (YYYYMMDD) for ", ANIMAL-ID, ": "
        ACCEPT ADOPTION-DATE
        DISPLAY "Enter Adopted By for ", ANIMAL-ID, ": "
        ACCEPT ADOPTED-BY
        WRITE ADOPTION-RECORD
    END-IF.
