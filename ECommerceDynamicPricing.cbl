IDENTIFICATION DIVISION.
PROGRAM-ID. ECommerceDynamicPricing.
AUTHOR. Your Name.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT product-details ASSIGN TO 'product-details.dat'.
    SELECT sales-data ASSIGN TO 'sales-data.dat'.
    SELECT pricing-recommendations ASSIGN TO 'pricing-recommendations.dat'.

DATA DIVISION.
FILE SECTION.
FD product-details.
01 PRODUCT-RECORD.
    05 PRODUCT-ID        PIC X(10).
    05 CURRENT-PRICE     PIC 9(5)V99.
    05 TARGET-STOCK      PIC 9(5).
    05 CURRENT-STOCK     PIC 9(5).

FD sales-data.
01 SALES-RECORD.
    05 SR-PRODUCT-ID     PIC X(10).
    05 UNITS-SOLD        PIC 9(5).

FD pricing-recommendations.
01 RECOMMENDATION-RECORD.
    05 RR-PRODUCT-ID     PIC X(10).
    05 RR-NEW-PRICE      PIC 9(5)V99.

WORKING-STORAGE SECTION.
01 SALES-SUMMARY.
    05 SS-PRODUCT-ID     PIC X(10).
    05 TOTAL-UNITS-SOLD  PIC 9(5) VALUE 0.

01 PRICE-ADJUSTMENT-FACTOR PIC V9(2) VALUE 0.05.
01 WS-END-OF-FILE          PIC X VALUE 'N'.
    88 EOF                 VALUE 'Y'.
    88 NOT-EOF             VALUE 'N'.

PROCEDURE DIVISION.
BEGIN.
    OPEN INPUT product-details sales-data
        OUTPUT pricing-recommendations
    PERFORM UNTIL EOF
        READ product-details INTO PRODUCT-RECORD AT END SET EOF TO TRUE
        PERFORM PROCESS-SALES-FOR-PRODUCT
        PERFORM CALCULATE-RECOMMENDATION
    END-PERFORM
    CLOSE product-details sales-data pricing-recommendations
    STOP RUN.

PROCESS-SALES-FOR-PRODUCT.
    PERFORM UNTIL EOF
        READ sales-data INTO SALES-RECORD AT END SET EOF TO TRUE
        IF SR-PRODUCT-ID = PRODUCT-ID
            ADD UNITS-SOLD TO TOTAL-UNITS-SOLD
        END-IF
    END-PERFORM.

CALCULATE-RECOMMENDATION.
    IF TOTAL-UNITS-SOLD < (TARGET-STOCK - CURRENT-STOCK) * 0.5
        COMPUTE RR-NEW-PRICE = CURRENT-PRICE * (1 - PRICE-ADJUSTMENT-FACTOR)
        WRITE RECOMMENDATION-RECORD
    ELSE IF TOTAL-UNITS-SOLD > (TARGET-STOCK - CURRENT-STOCK)
        COMPUTE RR-NEW-PRICE = CURRENT-PRICE * (1 + PRICE-ADJUSTMENT-FACTOR)
        WRITE RECOMMENDATION-RECORD.
