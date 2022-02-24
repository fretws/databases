-- You can only have one event associated with a given property that has the event type 'Rent' or 'Purchase' at any given time. This means that there can only be one user who rents/owns the property at any given time.

Create Function fn_IsOccupiedByOnlyOne()
Returns INT
As
Begin
Declare @Ret INT = 0
If Exists (
  Select *
  From tblEVENT_TYPE ET
    Join tblEVENT E On E.EventTypeID = ET.EventTypeID
    Join tblPROPERTY_USER PU On PU.PropertyUserID = E.PropertyUserID
    Join tblProperty P On P.PropertyID = PU.PropertyUserID
  Where E.EventName = 'Purchase property'
     Or E.EventName = 'Rent property'
  Group By P.PropertyID
  Having COUNT(Distinct E.EventID) > 1
) Set @Ret = 1
Return @Ret
End

Go

Alter Table tblPROPERTY
Add Constraint IsOccupiedByOnlyOne
Check (dbo.fn_IsOccupiedByOnlyOne() = 0)

Go

-- Listers cannot list a property as both for sale and for rent.

Create Function fn_IsListedOnlyOnce()
Returns INT
As
Begin
Declare @Ret INT = 0
If Exists (
  Select *
  From tblEVENT_TYPE ET
    Join tblEVENT E On E.EventTypeID = ET.EventTypeID
    Join tblPROPERTY_USER PU On PU.PropertyUserID = E.PropertyUserID
    Join tblProperty P On P.PropertyID = PU.PropertyUserID
  Where E.EventName = 'List for rent'
     Or E.EventName = 'List for purchase'
  Group By P.PropertyID
  Having COUNT(Distinct E.EventID) > 1
) Set @Ret = 1
Return @Ret
End

Go

Alter Table tblProperty
Add Constraint IsListedOnlyOnce
Check (dbo.fn_IsListedOnlyOnce() = 0)
