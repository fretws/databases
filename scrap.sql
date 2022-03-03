select * From tblEVENT_TYPE

Select * From tblPROPERTY_TYPE

Select * From tblNEIGHBORHOOD

SELECT * From tblEVENT

SELECT * From tblUSER

Select * From tblPROPERTY_USER

Select * From tblPROPERTY

Select * From tblAMENITY

Select *
From tblPROPERTY P
  Join tblPROPERTY_USER PU On PU.PropertyID = P.PropertyID
  Join tblEVENT E On E.PropertyUserID = PU.PropertyUserID
  Join tblEVENT_TYPE ET On ET.EventTypeID = E.EventTypeID

Exec dbo.ww_Insert_Neighborhood
  "Ada"

Exec dbo.anthony_insert_Property
  "1090 E Watertower St #150, Meridian, ID 83642",
  "Meridian",
  "ID",
  "83642",
  "1990",
  "Ada",
  "Townhouse"

Exec dbo.ww_Insert_Property_User
  "1090 E Watertower St #150, Meridian, ID 83642",
  "Meridian",
  "MJ@gmail.com",
  "2022-03-02",
  "2023-03-02"

Exec dbo.ww_Insert_Event
  "MJ@gmail.com",
  "1090 E Watertower St #150, Meridian, ID 83642",
  "Meridian",
  "Purchase property",
  150000,
  "2022-03-02"

Exec dbo.anthony_insert_Property_amenity
  2,
  "1090 E Watertower St #150, Meridian, ID 83642",
  "Bathroom",
  "83642"

Exec dbo.anthony_insert_Property_amenity
  1,
  "1090 E Watertower St #150, Meridian, ID 83642",
  "Dishwasher",
  "83642"

Exec dbo.anthony_insert_Property_amenity
  4,
  "1090 E Watertower St #150, Meridian, ID 83642",
  "Bedroom",
  "83642"





Exec dbo.anthony_insert_Property
  "201 Municipal Dr, Nampa, ID 83687",
  "Nampa",
  "ID",
  "83687",
  "2005",
  "Ada",
  "Mobile Home"

Exec dbo.ww_Insert_Property_User
  "201 Municipal Dr, Nampa, ID 83687",
  "Nampa",
  "Poor@gmail.com",
  "2021-03-02",
  "2023-03-02"

Exec dbo.ww_Insert_Event
  "Poor@gmail.com",
  "201 Municipal Dr, Nampa, ID 83687",
  "Nampa",
  "Purchase property",
  15000,
  "2021-03-02"

Exec dbo.anthony_insert_Property_amenity
  1,
  "201 Municipal Dr, Nampa, ID 83687",
  "Lawn",
  "83687"

Exec dbo.anthony_insert_Property_amenity
  1,
  "201 Municipal Dr, Nampa, ID 83687",
  "Bedroom",
  "83687"

Begin Transaction
Delete
From tblPROPERTY_TYPE
Where PropertyTypeID > 7
Commit Transaction