-- 1
SELECT studentFname, studentLname FROM tblSTUDENT
WHERE StudentBirth > '1996-11-05'

-- 2
SELECT B.BuildingName FROM tblBUILDING B JOIN tblLOCATION L
ON B.LocationID = L.LocationID
WHERE LocationName = 'West Campus'

-- 3
SELECT COUNT(B.BuildingID)
FROM tblBUILDING B JOIN tblBUILDING_TYPE BT
ON B.BuildingTypeID = BT.BuildingTypeID
WHERE BuildingTypeName = 'Library'


SELECT * FROM tblQUARTER

-- 4
SELECT DISTINCT TOP 10 S.StudentFname, S.StudentLname, S.StudentBirth
  -- , Q.QuarterName, C.YEAR, Clg.CollegeName
FROM tblCLASS_LIST CL JOIN tblSTUDENT S
ON CL.StudentID = S.StudentID
  JOIN tblCLASS C
ON CL.ClassID = C.ClassID
  JOIN tblQUARTER Q
ON C.QuarterID = Q.QuarterID
  JOIN tblCOURSE Co
ON C.CourseID = Co.CourseID
  JOIN tblDEPARTMENT D
ON Co.DeptID = D.DeptID
  JOIN tblCOLLEGE Clg
ON D.CollegeID = Clg.CollegeID
WHERE Q.QuarterName = 'Winter'
  AND C.YEAR = 2009
  AND Clg.CollegeName = 'Information School'
ORDER BY S.StudentBirth DESC

SELECT * FROM tblLOCATION
-- 5
SELECT BuildingName,
FROM tblBUILDING
