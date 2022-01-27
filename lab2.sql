-- 1
SELECT StudentFname + ' ' + StudentLname AS [Student Name], StudentID
FROM tblSTUDENT
WHERE StudentID IN (
  SELECT S.StudentID
  FROM tblCLASS_LIST CL
    JOIN tblSTUDENT S ON CL.StudentID = S.StudentID
    JOIN tblCLASS C ON CL.ClassID = C.ClassID
    JOIN tblCOURSE Co ON C.CourseID = Co.CourseID
    JOIN tblDEPARTMENT D ON Co.DeptID = D.DeptID
    JOIN tblCOLLEGE Clg ON D.CollegeID = Clg.CollegeID
  WHERE Clg.CollegeName = 'Information School'
    AND C.[YEAR] > 2010
  GROUP BY S.StudentID
  HAVING SUM(CL.RegistrationFee) > 3000
) AND StudentID IN (
  SELECT S.StudentID
  FROM tblCLASS_LIST CL
    JOIN tblSTUDENT S ON CL.StudentID = S.StudentID
    JOIN tblCLASS C ON CL.ClassID = C.ClassID
    JOIN tblCOURSE Co ON C.CourseID = Co.CourseID
    JOIN tblDEPARTMENT D ON Co.DeptID = D.DeptID
    JOIN tblCOLLEGE Clg ON D.CollegeID = Clg.CollegeID
  WHERE Clg.CollegeName = 'Public Health'
    AND C.[YEAR] < 2016
  GROUP BY S.StudentID
  HAVING SUM(Co.Credits) > 12
)

-- 2
SELECT TOP 3 WITH TIES D.DeptName, COUNT(DISTINCT S.StudentID) AS [Number of Students]
FROM tblSTUDENT S
  JOIN tblCLASS_LIST CL ON S.StudentID = CL.StudentID
  JOIN tblCLASS C ON C.ClassID = CL.ClassID
  JOIN tblCOURSE Co ON Co.CourseID = C.CourseID
  JOIN tblDEPARTMENT D ON D.DeptID = Co.DeptID
  JOIN tblCOLLEGE Clg ON Clg.CollegeID = D.CollegeID
WHERE C.[YEAR] BETWEEN 2004 AND 2013
  AND CL.Grade < 3.4
  AND Clg.CollegeName = 'Arts and Sciences'
GROUP BY D.DeptName
ORDER BY [Number of Students] DESC


-- 3
SELECT COUNT(B.BuildingID)
FROM tblBUILDING B JOIN tblBUILDING_TYPE BT
ON B.BuildingTypeID = BT.BuildingTypeID
WHERE BuildingTypeName = 'Library'

-- 4
SELECT DISTINCT TOP 10 S.StudentFname, S.StudentLname, S.StudentBirth
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

-- 5
SELECT TOP 5 B.BuildingName, B.YearOpened
FROM tblBUILDING B JOIN tblLOCATION L
ON B.LocationID = L.LocationID
-- Do not include buildings that are on Satellite Campuses
WHERE L.LocationDescr NOT LIKE '%Satelitte%'
ORDER BY YearOpened

-- 6
SELECT TOP 5 S.StudentPermState, COUNT(C.YEAR) Instances
FROM tblSTUDENT S JOIN tblCLASS_LIST CL
ON S.StudentID = CL.StudentID
  JOIN tblCLASS C
ON C.ClassID = CL.ClassID
WHERE C.YEAR = 1930
GROUP BY S.StudentPermState
ORDER BY COUNT(C.YEAR) DESC

-- 7
SELECT TOP 1 D.DeptName, COUNT(PT.PositionTypeName) Executives
FROM tblSTAFF_POSITION SP JOIN tblPOSITION P
ON SP.PositionID = P.PositionID
  JOIN tblPOSITION_TYPE PT
ON P.PositionTypeID = PT.PositionTypeID
  JOIN tblDEPARTMENT D
ON D.DeptID = SP.DeptID
  JOIN tblSTAFF S
ON S.StaffID = SP.StaffID
WHERE SP.BeginDate > '1968-06-08'
  AND SP.BeginDate < '1989-03-06'
  AND PT.PositionTypeName = 'Executive'
GROUP BY D.DeptName
ORDER BY COUNT(PT.PositionTypeName) DESC

-- 8
SELECT TOP 1 I.InstructorFName, I.InstructorLName, IIT.BeginDate, IIT.EndDate
FROM tblInstructor I JOIN tblINSTRUCTOR_INSTRUCTOR_TYPE IIT
ON I.InstructorID = IIT.InstructorID
  JOIN tblINSTRUCTOR_TYPE IT
ON IT.InstructorTypeID = IIT.InstructorTypeID
WHERE IT.InstructorTypeName = 'Senior Lecturer'
  AND IIT.EndDate IS NULL
ORDER BY IIT.BeginDate

-- 9
Select Cg.CollegeName, COUNT(Distinct C.CourseID) Courses
From tblCLASS C Join tblQUARTER Q
On C.QuarterID = Q.QuarterID
  Join tblCOURSE Co
On Co.CourseID = C.CourseID
  Join tblDEPARTMENT D
On D.DeptID = Co.DeptID
  Join tblCOLLEGE Cg
On Cg.CollegeID = D.CollegeID
Where Q.QuarterName = 'Spring'
  And C.YEAR = 2014
Group By Cg.CollegeName
Order By Courses Desc

-- 10
Select Distinct Co.CourseName, ClT.ClassroomTypeName
From tblCLASSROOM_TYPE ClT Join tblCLASSROOM Cl
On Cl.ClassroomTypeID = ClT.ClassroomTypeID
  Join tblCLASS C
On C.ClassroomID = Cl.ClassroomID
  Join tblCOURSE Co
On Co.CourseID = C.CourseID
  Join tblQUARTER Q
On Q.QuarterID = C.QuarterID
Where ClT.ClassroomTypeName = 'Large Lecture Hall'
  Or ClT.ClassroomTypeName = 'Auditorium'
  And Q.QuarterName = 'Summer'
  And C.Year =2016

