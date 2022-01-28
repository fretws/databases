-- 1
Select StudentFname + ' ' + StudentLname AS [Student Name], StudentID
From tblSTUDENT
Where StudentID In (
  Select S.StudentID
  From tblCLASS_LIST CL
    Join tblSTUDENT S On CL.StudentID = S.StudentID
    Join tblCLASS C On CL.ClassID = C.ClassID
    Join tblCOURSE Co On C.CourseID = Co.CourseID
    Join tblDEPARTMENT D On Co.DeptID = D.DeptID
    Join tblCOLLEGE Clg On D.CollegeID = Clg.CollegeID
  Where Clg.CollegeName = 'Information School'
    And C.[YEAR] > 2010
  Group By S.StudentID
  Having SUM(CL.RegistratiOnFee) > 3000
) And StudentID In (
  Select S.StudentID
  From tblCLASS_LIST CL
    Join tblSTUDENT S On CL.StudentID = S.StudentID
    Join tblCLASS C On CL.ClassID = C.ClassID
    Join tblCOURSE Co On C.CourseID = Co.CourseID
    Join tblDEPARTMENT D On Co.DeptID = D.DeptID
    Join tblCOLLEGE Clg On D.CollegeID = Clg.CollegeID
  Where Clg.CollegeName = 'Public Health'
    And C.[YEAR] < 2016
  Group By S.StudentID
  Having SUM(Co.Credits) > 12
)

-- 2
Select Top 3 With Ties D.DeptName, COUNT(DISTINCT S.StudentID) AS [Number of Students]
From tblSTUDENT S
  Join tblCLASS_LIST CL On S.StudentID = CL.StudentID
  Join tblCLASS C On C.ClassID = CL.ClassID
  Join tblCOURSE Co On Co.CourseID = C.CourseID
  Join tblDEPARTMENT D On D.DeptID = Co.DeptID
  Join tblCOLLEGE Clg On Clg.CollegeID = D.CollegeID
Where C.[YEAR] BETWEEN 2004 And 2013
  And CL.Grade < 3.4
  And Clg.CollegeName = 'Arts and Sciences'
Group By D.DeptName
Order By [Number of Students] Desc


-- 3
Select Co.CourseName, I.InstructorFName + ' ' + I.InstructorLName As Instructor, L.LocationName As [Location]
From tblLOCATION L
  Join tblBUILDING B On L.LocationID = B.LocationID
  Join tblCLASSROOM Cr On B.BuildingID = Cr.BuildingID
  Join tblCLASS Cl On Cr.ClassroomID = Cl.ClassroomID
  Join tblINSTRUCTOR_CLASS IC On Cl.ClassID = IC.ClassID
  Join tblINSTRUCTOR I On IC.InstructorID = I.InstructorID
  Join tblCOURSE Co On Cl.CourseID = Co.CourseID
  Join tblDEPARTMENT D On Co.DeptID = D.DeptID
  Join tblQUARTER Q On Cl.QuarterID = Q.QuarterID
Where L.LocationID = 7
  And I.InstructorFName + ' ' + I.InstructorLName = 'Greg Hay'
  And D.DeptID = 19
  And Cl.[YEAR] < 2015
  And Q.QuarterName = 'Winter'

-- 4
Select S.StaffFName + ' ' + S.StaffLName As [Staff Member], SP.BeginDate, Clg.CollegeName
From tblSTAFF S
  Join tblSTAFF_POSITION SP On S.StaffID = SP.StaffID
  Join tblDEPARTMENT D On D.DeptID = SP.DeptID
  Join tblCOLLEGE Clg On Clg.CollegeID = D.CollegeID
  Join (
    Select Clg.CollegeID, Min(SP.BeginDate) As [Begin Date]
    From tblSTAFF S
      Join tblSTAFF_POSITION SP On S.StaffID = SP.StaffID
      Join tblDEPARTMENT D On D.DeptID = SP.DeptID
      Join tblCOLLEGE Clg On Clg.CollegeID = D.CollegeID
    Where SP.EndDate Is Null
    Group By Clg.CollegeID
  ) As MinStartDates On SP.BeginDate = MinStartDates.[Begin Date]
    AND Clg.CollegeID = MinStartDates.CollegeID
Where SP.EndDate Is Null
Order By SP.BeginDate

-- 5
Select Top 5 B.BuildingName, B.YearOpened
From tblBUILDING B Join tblLOCATION L
On B.LocationID = L.LocationID
-- Do not include buildings that are On Satellite Campuses
Where L.LocationDescr NOT LIKE '%Satelitte%'
ORDER By YearOpened

-- 6
Select Top 5 S.StudentPermState, COUNT(C.YEAR) Instances
From tblSTUDENT S Join tblCLASS_LIST CL
On S.StudentID = CL.StudentID
  Join tblCLASS C
On C.ClassID = CL.ClassID
Where C.YEAR = 1930
Group By S.StudentPermState
ORDER By COUNT(C.YEAR) DESC

-- 7
Select Top 1 D.DeptName, COUNT(PT.PositiOnTypeName) Executives
From tblSTAFF_POSITIOn SP Join tblPOSITIOn P
On SP.PositiOnID = P.PositiOnID
  Join tblPOSITIOn_TYPE PT
On P.PositiOnTypeID = PT.PositiOnTypeID
  Join tblDEPARTMENT D
On D.DeptID = SP.DeptID
  Join tblSTAFF S
On S.StaffID = SP.StaffID
Where SP.BeginDate > '1968-06-08'
  And SP.BeginDate < '1989-03-06'
  And PT.PositiOnTypeName = 'Executive'
Group By D.DeptName
ORDER By COUNT(PT.PositiOnTypeName) DESC

-- 8
Select Top 1 I.InstructorFName, I.InstructorLName, IIT.BeginDate, IIT.EndDate
From tblInstructor I Join tblINSTRUCTOR_INSTRUCTOR_TYPE IIT
On I.InstructorID = IIT.InstructorID
  Join tblINSTRUCTOR_TYPE IT
On IT.InstructorTypeID = IIT.InstructorTypeID
Where IT.InstructorTypeName = 'Senior Lecturer'
  And IIT.EndDate IS NULL
ORDER By IIT.BeginDate

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

