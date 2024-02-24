IDENTIFICATION DIVISION.
PROGRAM-ID. HouseholdBudgetManagement.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.

DATA DIVISION.
FILE SECTION.

WORKING-STORAGE SECTION.
01 HOUSEHOLD-BUDGET.
   05 MONTHLY-INCOME          PIC 9(7)v99.
   05 TOTAL-EXPENSES          PIC 9(7)v99.
   05 SAVINGS                 PIC 9(7)v99.

01 EXPENSE-CATEGORIES.
   05 HOUSING-EXPENSE         PIC 9(6)v99.
   05 UTILITIES-EXPENSE       PIC 9(6)v99.
   05 GROCERIES-EXPENSE       PIC 9(6)v99.
   05 TRANSPORTATION-EXPENSE  PIC 9(6)v99.
   05 ENTERTAINMENT-EXPENSE   PIC 9(6)v99.
   05 MISCELLANEOUS-EXPENSE   PIC 9(6)v99.

01 CATEGORY-CODE              PIC X.
    88 HOUSING-CODE           VALUE 'H'.
    88 UTILITIES-CODE         VALUE 'U'.
    88 GROCERIES-CODE         VALUE 'G'.
    88 TRANSPORTATION-CODE    VALUE 'T'.
    88 ENTERTAINMENT-CODE     VALUE 'E'.
    88 MISCELLANEOUS-CODE     VALUE 'M'.
    88 DONE-CODE              VALUE 'D'.

01 EXPENSE-AMOUNT             PIC 9(6)v99.

PROCEDURE DIVISION.
START-PROGRAM.
    DISPLAY "Enter Monthly Income: $"
    ACCEPT MONTHLY-INCOME

    PERFORM INITIALIZE-EXPENSES
    PERFORM COLLECT-EXPENSES UNTIL DONE-CODE
    COMPUTE TOTAL-EXPENSES = HOUSING-EXPENSE + UTILITIES-EXPENSE + 
                             GROCERIES-EXPENSE + TRANSPORTATION-EXPENSE + 
                             ENTERTAINMENT-EXPENSE + MISCELLANEOUS-EXPENSE
    COMPUTE SAVINGS = MONTHLY-INCOME - TOTAL-EXPENSES

    DISPLAY "Total Expenses: $" TOTAL-EXPENSES
    DISPLAY "Savings: $" SAVINGS
    STOP RUN.

INITIALIZE-EXPENSES.
    MOVE 0 TO HOUSING-EXPENSE
    MOVE 0 TO UTILITIES-EXPENSE
    MOVE 0 TO GROCERIES-EXPENSE
    MOVE 0 TO TRANSPORTATION-EXPENSE
    MOVE 0 TO ENTERTAINMENT-EXPENSE
    MOVE 0 TO MISCELLANEOUS-EXPENSE.

COLLECT-EXPENSES.
    DISPLAY "Enter Expense Category (H=Housing, U=Utilities, G=Groceries, T=Transportation, E=Entertainment, M=Miscellaneous, D=Done): "
    ACCEPT CATEGORY-CODE
    IF NOT DONE-CODE
        DISPLAY "Enter Expense Amount: $"
        ACCEPT EXPENSE-AMOUNT
        EVALUATE CATEGORY-CODE
            WHEN HOUSING-CODE
                ADD EXPENSE-AMOUNT TO HOUSING-EXPENSE
            WHEN UTILITIES-CODE
                ADD EXPENSE-AMOUNT TO UTILITIES-EXPENSE
            WHEN GROCERIES-CODE
                ADD EXPENSE-AMOUNT TO GROCERIES-EXPENSE
            WHEN TRANSPORTATION-CODE
                ADD EXPENSE-AMOUNT TO TRANSPORTATION-EXPENSE
            WHEN ENTERTAINMENT-CODE
                ADD EXPENSE-AMOUNT TO ENTERTAINMENT-EXPENSE
            WHEN MISCELLANEOUS-CODE
                ADD EXPENSE-AMOUNT TO MISCELLANEOUS-EXPENSE
        END-EVALUATE.

END PROGRAM HouseholdBudgetManagement.
