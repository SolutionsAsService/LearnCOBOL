       IDENTIFICATION DIVISION.
       PROGRAM-ID. SoftwareCompanyPayroll.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT EmployeeFile ASSIGN TO 'EMPLOYEE.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  EmployeeFile.
       01  EmployeeRecord.
           05  EmployeeName        PIC X(25).
           05  HoursWorked          PIC 9(3).
           05  HourlyRate           PIC 9(3)V99.
           05  GrossPay             PIC 9(5)V99.

       WORKING-STORAGE SECTION.
       01  EndOfFile               PIC X VALUE 'N'.
           88  EOF                 VALUE 'Y'.
           88  NOT-EOF             VALUE 'N'.
       01  OvertimeHours           PIC 9(3) VALUE ZERO.
       01  RegularHours            PIC 9(3) VALUE ZERO.
       01  OvertimePay             PIC 9(5)V99 VALUE ZERO.
       01  RegularPay              PIC 9(5)V99 VALUE ZERO.
       01  TotalGrossPay           PIC 9(7)V99 VALUE ZERO.

       PROCEDURE DIVISION.
       BEGIN.
           OPEN INPUT EmployeeFile
           PERFORM UNTIL EOF
               READ EmployeeFile INTO EmployeeRecord
                   AT END
                       SET EOF TO TRUE
                   NOT AT END
                       PERFORM CalculateGrossPay
               END-READ
           END-PERFORM
           CLOSE EmployeeFile
           DISPLAY 'Total Gross Pay for all employees: $', TotalGrossPay
           STOP RUN.

       CalculateGrossPay.
           IF HoursWorked > 40 THEN
               COMPUTE RegularHours = 40
               COMPUTE OvertimeHours = HoursWorked - RegularHours
               COMPUTE RegularPay = RegularHours * HourlyRate
               COMPUTE OvertimePay = OvertimeHours * HourlyRate * 1.5
               COMPUTE GrossPay = RegularPay + OvertimePay
           ELSE
               COMPUTE RegularHours = HoursWorked
               COMPUTE GrossPay = HoursWorked * HourlyRate
           END-IF
           DISPLAY 'Employee: ', EmployeeName, ', Gross Pay: $', GrossPay
           ADD GrossPay TO TotalGrossPay.
