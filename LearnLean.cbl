IDENTIFICATION DIVISION.
PROGRAM-ID. LearnLean.
* This is a basic COBOL program structure to introduce you to the language.

ENVIRONMENT DIVISION.
* This division specifies the computer environment on which the program will run.
* Not used in this simple example.

DATA DIVISION.
* This division is used for declaring variables.
WORKING-STORAGE SECTION.
01 LEAN-COUNTER PIC 9(2) VALUE 0.
* 'LEAN-COUNTER' is a numeric variable with a maximum of 2 digits, initialized to 0.

PROCEDURE DIVISION.
* This is where the program's instructions are defined.
BEGIN.
    PERFORM INCREMENT-LEAN UNTIL LEAN-COUNTER = 10
    STOP RUN.
    
INCREMENT-LEAN.
    ADD 1 TO LEAN-COUNTER
    DISPLAY "Lean iteration: " LEAN-COUNTER
    .
* 'INCREMENT-LEAN' is a simple procedure that increments 'LEAN-COUNTER' by 1 and displays it.

END PROGRAM LearnLean.
