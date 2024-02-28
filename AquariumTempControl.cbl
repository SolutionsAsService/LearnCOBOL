IDENTIFICATION DIVISION.
PROGRAM-ID. AquariumTempControl.
* This program simulates regulating an aquarium's temperature.

ENVIRONMENT DIVISION.
* Defines the computer environment - not specifically used here.

DATA DIVISION.
WORKING-STORAGE SECTION.
01 DESIRED-TEMP PIC 9(2) VALUE 78.
01 CURRENT-TEMP PIC 9(2).
01 TEMP-DIFF PIC S9(3) VALUE 0.
01 ADJUSTMENT PIC X(10) VALUE SPACES.

PROCEDURE DIVISION.
* Main logic to regulate aquarium temperature.
BEGIN.
    DISPLAY "Enter current aquarium temperature: "
    ACCEPT CURRENT-TEMP
    PERFORM CHECK-TEMPERATURE
    DISPLAY "Adjustment needed: ", ADJUSTMENT
    STOP RUN.

CHECK-TEMPERATURE.
    COMPUTE TEMP-DIFF = DESIRED-TEMP - CURRENT-TEMP
    IF TEMP-DIFF > 2
        MOVE "Heat On" TO ADJUSTMENT
    ELSE IF TEMP-DIFF < -2
        MOVE "Cool On" TO ADJUSTMENT
    ELSE
        MOVE "No Change" TO ADJUSTMENT
    END-IF.
    
END PROGRAM AquariumTempControl.
