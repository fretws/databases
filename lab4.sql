-- Write the SQL to determine which customers have booked more than 5 flights between March 3, 2015 and November 12, 2018 arriving in airports in the region of South America who have also booked fewer than 10 total flights on planes from Boeing Airplane manufacturer before January 15, 2019.

Select qryA.CustName, qryA.[SA Flights in Range]
From (
  Select C.CustomerID, C.CustomerFname + ' ' + C.CustomerLname As [CustName], COUNT(F.FlightID) As [SA Flights in Range]
  From tblCustomer C
    Join tblBooking B On B.CustomerID = C.CustomerID
    Join tblRoute_Flight RF On RF.RouteFlightID = B.RouteFlightID
    Join tblFlight F On F.FlightID = RF.FlightID
    Join tblAirport A On A.AirportID = F.ArrivalAirportID
    Join tblCity Cty On Cty.CityID = A.CityID
    Join tblCountry Ctry On Ctry.CountryID = Cty.CountryID
    Join tblRegion Rgn On Rgn.RegionID = Ctry.RegionID
  Where B.BookDateTime Between '2015-03-03' And '2018-11-12'
    And Rgn.RegionName = 'South America'
  Group By C.CustomerID, C.CustomerFname, C.CustomerLname, COUNT(F.FlightID)
  Having COUNT(F.FlightID) > 5
) As qryA, (
  Select C.CustomerID, COUNT(Distinct B.RouteFlightID) As [Old Boeing Flights]
  From tblCustomer C
    Join tblBooking B On B.CustomerID = C.CustomerID
    Join tblSeat_Plane SP On SP.SeatPlaneClassID = B.SeatPlaneClassID
    Join tblPlane P On P.PlaneID = SP.PlaneID
    Join tblManufacturer M On M.MfgID = P.MfgID
  Where M.MfgName = 'Boeing Airplane'
    And B.BookDateTime < '2019-01-15'
  Group By C.CustomerID, COUNT(Distinct B.RouteFlightID)
  Having COUNT(Distinct B.RouteFlightID) < 10
) As qryB
Where qryA.CustomerID = qryB.CustomerID



-- Write the SQL to determine which employees served in the role of 'captain' on greater than 11 flights departing from airport type of 'military' from the region of North America who also served in the role of 'Chief Navigator' no more than 5 flights arriving to airports in Japan.

Select qryA.EmpName, qryA.[Num NA Military Flights], qryB.[Navigations to Japan]
From (
  Select E.EmployeeID, E.EmployeeFname + ' ' + E.EmployeeLname As EmpName, COUNT(F.FlightID) As [Num NA Military Flights]
  From tblEmployee E
    Join tblFlight_Employee FE On FE.EmployeeID = E.EmployeeID
    Join tblRole R On R.RoleID = FE.RoleID
    Join tblFlight F On F.FlightiD = FE.FlightID
    Join tblAirport A On A.AirportID = F.DepartAirportID
    Join tblAirport_Type [AT] On [AT].AirportTypeID = A.AirportTypeID
    Join tblCity Cty On Cty.CityID = A.CityID
    Join tblCountry Ctry On Ctry.CountryID = Cty.CountryID
    Join tblRegion Rgn On Rgn.RegionID = Ctry.RegionID
  Where R.RoleName = 'captain'
    And [AT].AirportTypeName = 'military'
    And Rgn.RegionName = 'North America'
  Group By E.EmployeeID, E.EmployeeFname, E.EmployeeLname, COUNT(F.FlightID)
  Having COUNT(F.FlightID) > 11
) As qryA, (
  Select E.EmployeeID, COUNT(F.FlightID) As [Navigations to Japan]
  From tblEmployee E
    Join tblFlight_Employee FE On FE.EmployeeID = E.EmployeeID
    Join tblRole R On R.RoleID = FE.RoleID
    Join tblFlight F On F.FlightiD = FE.FlightID
    Join tblAirport A On A.AirportID = F.ArrivalAirportID
    Join tblAirport_Type [AT] On [AT].AirportTypeID = A.AirportTypeID
    Join tblCity Cty On Cty.CityID = A.CityID
    Join tblCountry Ctry On Ctry.CountryID = Cty.CountryID
  Where R.RoleName = 'Chief Navigator'
    And Ctry.CountryName = 'Japan'
  Group By E.EmployeeID, COUNT(F.FlightID)
  Having COUNT(F.FlightID) < 6
) As qryB

-- Write the SQL to create a stored procedure to UPDATE the EMPLOYEE table with new values for City, State and Zip. Use the following parameters:
-- @Fname, @Lname, @Birthdate, @NewCity, @NewState, @NewZip
Go

Create Procedure usp_UpdateEmployeeLocation
  @Fname VarChar(30),
  @Lname VarChar(30),
  @Birthdate DATE,
  @NewCity VarChar(30),
  @NewState CHAR(2),
  @NewZip NUMERIC
As
Begin
Declare @EmpID INT = (
  Select EmployeeID
  From tblEmployee
  Where EmployeeFname = @Fname
    And EmployeeLname = @Lname
    And EmployeeDOB = @BirthDate
)

Begin Transaction
Update tblEmployee
Set EmployeeCity = @NewCity,
  EmployeeState = @NewState,
  EmployeeZip = @NewZip
Where EmployeeID = @EmpID
Commit Transaction
End

Go



-- Write the SQL to create enforce the following business rule:
-- "No employee younger than 28 years old may serve the role of 'Principal Engineer' for routes named 'Around the world over the Arctic' scheduled to depart in the month of December"  

Create Function YoungArcticPncplEngineerInDec()
Returns INT
As
Begin
Declare @Ret INT = 0
If Exists (
  Select *
  From tblEmployee E
    Join tblFlight_Employee FE On FE.EmployeeID = E.EmployeeID
    Join tblRole R On R.RoleID = FE.RoleID
    Join tblFlight F On F.FlightiD = FE.FlightID
    Join tblRoute_Flight RF On RF.FlightID = F.FlightID
    Join tblRoute Rt On Rt.RouteID = RF.RouteID
  Where DateDiff(year, EmployeeDOB, GETDATE()) < 28
    And Rt.RouteName = 'Around the world over the Arctic'
    And R.RoleName = 'Principal Engineer'
    And MONTH(F.ScheduledDepart) = 12
) Set @Ret = 1
Return @Ret
End

Go

Alter Table tbl
Add Constraint NoYoungArcticPncplEngineerInDec
Check (YoungArcticPncplEngineerInDec() = 0)

Go

-- Write the SQL to create enforce the following business rule:
-- "No more than 12,500 pounds of baggage may be booked on planes of type 'Puddle Jumper'" 

Create Function HeavyLoadPuddleJumper()
Returns Int
As
Begin
Declare @Ret INT = 0
If Exists (
  Select *
  From tblBooking B
    Join tblSeat_Plane SP On SP.SeatPlaneClassID = B.SeatPlaneClassID
    Join tblPlane P On P.PlaneID = SP.PlaneID
    Join tblPlane_Type PT On PT.PlaneTypeID = P.PlaneTypeID
    Join tblRoute_Flight RF On RF.RouteFlightID = B.RouteFlightID
    Join tblFlight F On F.FlightID = RF.FlightID
    Join tblBag Bag On Bag.BookingID = B.BookingID
  Where PT.PlaneTypeName = 'Puddle Jumper'
  Group By F.FlightID, P.PlaneID
  Having SUM(Bag.Weight) > 12500
) Set @Ret = 1
Return @Ret
End

Go

Alter Table tblBooking
Add Constraint NoHeavyLoadPuddleJumper
Check (HeavyLoadPuddleJumper() = 0)
