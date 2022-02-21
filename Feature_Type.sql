Create Procedure usp_insertFeatureType
  @name VarChar(30),
  @descr VarChar(500)
As
Begin
Begin Transaction
Insert Into tblFEATURE_TYPE(FeatureTypeName, FeatureTypeDescr)
Values (@name, @descr)
Commit Transaction
End

Exec usp_insertFeatureType
  "House Metric",
  "A measure of a physical aspect of the property, such as quare footage or acreage"

Exec usp_insertFeatureType
  "Proximity",
  "Denotes a building or attraction that is close to the property"

Exec usp_insertFeatureType
  "Specialized Room",
  "A room that has a specific purpose, such as a bathroom, gym, or garage"

Exec usp_insertFeatureType
  "Security",
  "A home security enhancement"

Exec usp_insertFeatureType
  "Private Outdoors",
  "A space outdoors such as a front yard or patio, not shared with other properties"

Exec usp_insertFeatureType
  "Shared Space",
  "A space shared between community members"

Exec usp_insertFeatureType
  "Crime",
  "A crime that has occurred on or near the property"

Select * From tblFEATURE_TYPE