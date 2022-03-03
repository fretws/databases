-- Shane Fretwell, Info 330, Lab 2-23
-- Write the SQL to determine which customers have booked at least 15 flights into regional airports in South America  who have also  Spent more than $1500 on baggage fees for flights into SeaTac airport

Select qryA.CustID, qryA.CustName, qryA.BaggageFeesIntoSeaTac, qryB.NumFlightsIntoSA
From (
  Select C.CustID, C.CustomerFname + ' ' + C.CustomerLname As CustName, SUM(Fee.FeeAmount) BaggageFeesIntoSeaTac
  From tblCustomer C
    Join tblBooking B On C.CustID = B.CustID
    Join tblBooking_Fee BF On BF.BookingID = B.BookingID
    Join tblFee Fee On Fee.FeeID = BF.FeeID
    Join tblRoute_Flight_Booking RFB On RFB.BookingID = B.BookingID
    Join tblRoute_Flight RF On RF.FlightBookingID = RFB.FlightBookingID
    Join tblFlight F On F.FlightID = RF.FlightID
    Join tblAirport A On A.AirportID = F.ArrivalAirportID
  Where F.FeeName = 'baggage'
    And A.AirportName = 'SeaTac'
  Group By C.CustID, C.CustomerFname, C.CustomerLname, SUM(Fee.FeeAmount)
  Having SUM(Fee.FeeAmount) > 1500
) As qryA, (
  Select C.CustID, COUNT(Distinct F.FlightID) NumFlightsIntoSA
  From tblCustomer C
    Join tblBooking B On C.CustID = B.CustID
    Join tblRoute_Flight_Booking RFB On RFB.BookingID = B.BookingID
    Join tblRoute_Flight RF On RF.FlightBookingID = RFB.FlightBookingID
    Join tblFlight F On F.FlightID = RF.FlightID
    Join tblAirport A On A.AirportID = F.ArrivalAirportID
    Join tblCity City On City.CityID = A.CityID
    Join tblCountry Ctry On Ctry.CountryID = City.CountryID
    Join tblRegion R On R.RegionID = Ctry.RegionID
  Where R.RegionName = 'South America'
  Group By C.CustID, COUNT(Distinct F.FlightID)
  Having COUNT(Distinct F.FlightID) >= 15
) As qryB
Where qryA.CustID = qryB.CustID
