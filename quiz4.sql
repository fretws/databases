-- Write the single query to determine which customers meet all the following conditions: 
-- Boarded more than 44 trips on 'Route 305' from stops in the neighborhood of 'U-District' between March 17, 2016 and July 8, 2019 
-- Spent more than $235 with a payment type 'ORCA' for trips on vehicles that had Jimi Hendrix assigned as 'Coach Operator' during October 2019
-- Boarded fewer than 12 trips with destination 'Northgate' in the past 3 years.  

Select qryA.CustID, qryA.CustName, qryA.[Num 305 boarding from U-Dist]
From (
    Select C.CustID, C.CustFname + ' ' + C.CustLname As CustName, COUNT(B.BoardingID) As ['Num 305 boarding from U-Dist']
    From tblCustomer C
        Join tblBoarding B On B.CustID = C.CustID
        Join tblSchedule_Trip ST On ST.ScheduleTripID = B.ScheduleTripID
        Join tblSchedule S On S.ScheduleID = ST.ScheduleID
        Join tblStop Sto On Sto.StopID = S.StopID
        Join tblNeighborhood N On N.NeighborhoodID = Sto.NeighborhoodID
        Join tblRoute R On R.RouteID = S.RouteID
    Where N.NeighborhoodName = 'U-District'
        And R.RouteName = 'Route 305'
        And ST.ActualDateTime Between '2016-03-17' And '2019-07-08'
    Group By C.CustID, C.CustFname, C.CustLname, COUNT(B.BoardingID)
    Having COUNT(B.BoardingID) > 44
) As qryA, (
    Select C.CustID, SUM(F.FareAmount) As [Total Jimi ORCA Fare]
    From tblCustomer C
        Join tblBoarding B On B.CustID = C.CustID
        Join tblSchedule_Trip ST On ST.ScheduleTripID = B.ScheduleTripID
        Join tblFare F On F.FareID = B.FareID
        Join tblPayment P On P.PaymentID = B.PaymentID
        Join tblTrip T On T.TripID = ST.TripID
        Join tblEmployee_Position EP On EP.EmpPositionID = T.EmpPositionID
        Join tblPosition Pos On Pos.PositionID = EP.PositionID
        Join tblEmployee E On E.EmpID = EP.EmpID
    Where P.PaymentName = 'ORCA'
        And Pos.PositionName = 'Coach Operator'
        And E.EmpFname + ' ' + E.EmpLname = 'Jimi Hendrix'
        And ST.ActualDateTime Between '2019-10-1' And '2019-10-31'
    Group By C.CustID, SUM(F.FareAmount)
    Having SUM(F.FareAmount) > 235
) As qryB, (
    Select C.CustID, COUNT(B.BoardingID) As [Trips to Northgate]
    From tblCustomer C
        Join tblBoarding B On B.CustID = C.CustID
        Join tblSchedule_Trip ST On ST.ScheduleTripID = B.ScheduleTripID
        Join tblSchedule S On S.ScheduleID = ST.ScheduleID
        Join tblRoute R On R.RouteID = S.RouteID
        Join tblRoute_Destination RD On RD.RouteID = R.RouteID
        Join tblDestination D On D.DestID = RD.DestID
    Where D.DestName = 'Northgate'
        And DATEDIFF('year', ST.ActualDateTime, GETDATE()) < 3
    Group By C.CustID, COUNT(B.BoardingID)
    Having COUNT(B.BoardingID) < 12
) As qryC
Where qryA.CustID = qryB.CustID
    And qryA.CustID = qryC.CustID

-- Write the SQL code to create a stored procedure to INSERT one row into SCHEDULE_TRIP.
-- Takes in 9 parameters of non-ID values 
-- Uses variables to look-up required FK values 
Go

Create Procedure usp_InsertSchedule
    @ActualDateTime DATETIME,
    @SchedDateTime DATETIME,
    @TripDate DATE,
    @StopName VARCHAR(30),
    @RouteName VARCHAR(30),
    @VehicleSerialNum VARCHAR(30),
    @EmpFname VARCHAR(30),
    @EmpLname VARCHAR(30),
    @PositionName VARCHAR(30)
As
Begin
Declare @TripID INT, @ScheduleID INT

Set @TripID = (
    Select T.TripID
    From tblTrip T
        Join tblVehicle V On V.VehicleID = T.VehicleID
        Join tblEmployee_Position EP On EP.EmpPositionID = T.EmpPositionID
        Join tblEmployee E On E.EmpID = EP.EmpID
        Join tblPosition P On P.PositionID = EP.PositionID
    Where V.VehicleSerialNum = @VehicleSerialNum
        And E.EmpFname = @EmpFname
        And E.EmpLname = @EmpLname
        And P.PositionName = @PositionName
        And T.TripDate = @TripDate
)

Set @ScheduleID = (
    Select S.ScheduleID
    From tblSchedule S
        Join tblRoute R On R.RouteID = S.RouteID
        Join tblStop Sto On Sto.StopID = S.StopID
    Where R.RouteName = @RouteName
        And Sto.StopName = @StopName
        And S.ScheduleDateTime = @ScheduleDateTime
)

Begin Transaction T1
Insert Into tblSchedule_Trip(ScheduleID, TripID, ActualDateTime)
Values (@ScheduleID, @TripID, @ActualDateTime)
Commit Transaction T1

End




-- "No vehicle of type 'articulated double-length' older than than 12 years old may be assigned a trip through the neighborhood of 'Capitol Hill' in the months of December, January, or February" 
Go

Create Function OldAccordionInCapHillWinter()
Returns INT
As
Begin
Declare @Ret INT = 0
If Exists (
    Select *
    From tblVehicle_Type VT
        Join tblVehicle V On V.VehicleTypeID = VT.VehicleTypeID
        Join tblTrip T On T.VehicleID = V.VehicleID
        Join tblSchedule_Trip ST On ST.TripID = T.TripID
        Join tblSchedule S On S.ScheduleID = ST.ScheduleID
        Join tblStop Sto On Sto.StopID = S.StopID
        Join tblNeighborhood N On N.NeighborhoodID = Sto.NeighborhoodID
    Where N.NeighborhoodID = 'Capitol Hill'
        And MONTH(T.TripDate) In (12, 1, 2)
) Set @Ret = 1
Return @Ret
End

Go

Alter Table tblSchedule_Trip
Add Constraint noOldAccordionInCapHillWinter
Check (OldAccordionInCapHillWinter() = 0)


