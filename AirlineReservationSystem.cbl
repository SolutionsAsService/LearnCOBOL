IDENTIFICATION DIVISION.
PROGRAM-ID. AirlineReservationSystem.
AUTHOR. Your Name.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT flight-schedule ASSIGN TO 'flight-schedule.dat'.
    SELECT bookings ASSIGN TO 'bookings.dat'.

DATA DIVISION.
FILE SECTION.
FD flight-schedule.
01 FLIGHT-RECORD.
    05 FLIGHT-NUMBER      PIC X(6).
    05 DEPARTURE-DATE     PIC 9(8).
    05 AVAILABLE-SEATS    PIC 9(4).

FD bookings.
01 BOOKING-RECORD.
    05 BR-FLIGHT-NUMBER   PIC X(6).
    05 BR-DEPARTURE-DATE  PIC 9(8).
    05 BR-CUSTOMER-ID     PIC X(10).
    05 BR-SEATS-BOOKED    PIC 9(4).

WORKING-STORAGE SECTION.
01 WS-BOOKING-DETAILS.
    05 WS-BR-FLIGHT-NUMBER  PIC X(6).
    05 WS-BR-DEPARTURE-DATE PIC 9(8).
    05 WS-BR-CUSTOMER-ID    PIC X(10).
    05 WS-BR-SEATS-BOOKED   PIC 9(4).
01 WS-END-OF-FILE          PIC X VALUE 'N'.
    88 EOF                 VALUE 'Y'.
    88 NOT-EOF             VALUE 'N'.

PROCEDURE DIVISION.
BEGIN.
    OPEN INPUT flight-schedule
        OUTPUT bookings
    DISPLAY "Enter Flight Number: "
    ACCEPT WS-BR-FLIGHT-NUMBER
    DISPLAY "Enter Departure Date (YYYYMMDD): "
    ACCEPT WS-BR-DEPARTURE-DATE
    DISPLAY "Enter Customer ID: "
    ACCEPT WS-BR-CUSTOMER-ID
    DISPLAY "Enter Seats to Book: "
    ACCEPT WS-BR-SEATS-BOOKED

    PERFORM FIND-FLIGHT
    PERFORM BOOK-SEAT
    CLOSE flight-schedule bookings
    STOP RUN.

FIND-FLIGHT.
    READ flight-schedule INTO FLIGHT-RECORD AT END SET EOF TO TRUE.
    PERFORM UNTIL EOF OR (FLIGHT-NUMBER = WS-BR-FLIGHT-NUMBER AND DEPARTURE-DATE = WS-BR-DEPARTURE-DATE)
        READ flight-schedule INTO FLIGHT-RECORD AT END SET EOF TO TRUE.
    END-PERFORM.

BOOK-SEAT.
    IF AVAILABLE-SEATS >= WS-BR-SEATS-BOOKED
        SUBTRACT WS-BR-SEATS-BOOKED FROM AVAILABLE-SEATS
        MOVE FLIGHT-NUMBER TO BR-FLIGHT-NUMBER
        MOVE DEPARTURE-DATE TO BR-DEPARTURE-DATE
        MOVE WS-BR-CUSTOMER-ID TO BR-CUSTOMER-ID
        MOVE WS-BR-SEATS-BOOKED TO BR-SEATS-BOOKED
        WRITE BOOKING-RECORD
        DISPLAY "Booking Confirmed"
    ELSE
        DISPLAY "Not enough seats available".
