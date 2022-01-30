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
  Having SUM(CL.RegistrationFee) > 3000
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

Select Top 3 With Ties CT.ClassroomTypeName, Count(Distinct Co.CourseID) As [Count]
From tblCLASSROOM_TYPE CT
  Join tblClassroom Cr On Cr.ClassroomTypeID = Ct.ClassroomTypeID
  Join tblClass C On C.ClassroomID = Cr.ClassroomID
  Join tblCourse Co On C.CourseID = Co.CourseID
  Join tblDEPARTMENT D On D.DeptID = Co.DeptID
Where D.DeptAbbrev = 'ANTH'
  And Co.CourseNumber Like '3%'
  And C.[YEAR] > 1983
Group By CT.ClassroomTypeName
Order By Count(Distinct Co.CourseID)

-- 6

Go

Alter Procedure fretws_INSERT_NewStaffToExistingPosition
  @StaffFName VARCHAR (60),
  @StaffLName VARCHAR (60),
  @StaffAddress VARCHAR (120),
  @StaffCity VARCHAR (75),
  @StaffState VARCHAR (25),
  @StaffZip VARCHAR (25),
  @StaffBirth DATE,
  @StaffNetID VARCHAR (20),
  @StaffEmail VARCHAR (80),
  @Gender CHAR (1),
  @PositionID INT,
  @DeptID INT,
  @BeginDate DATETIME
As
If (
  Exists (Select PositionID From tblPOSITION)
  And (
    @DeptID Is Null -- Not every Staff_Position needs a DeptID
    Or
    Exists (
      Select DeptID From tblDEPARTMENT
      Where DeptID = @DeptID
      )
  )
)
Begin
Begin Transaction
  Insert Into tblSTAFF (
    StaffFName, StaffLName, StaffAddress, StaffCity, StaffState, StaffZip, StaffBirth, StaffEmail, Gender
  )
  Values
  (
    @StaffFName, @StaffLName, @StaffAddress, @StaffCity, @StaffState, @StaffZip, @StaffBirth, @StaffEmail, @Gender
  )
  
  Insert Into tblSTAFF_POSITION (
    StaffID, PositionID, BeginDate, DeptID
  )
  Values
  (
    SCOPE_IDENTITY(), @PositionID, @BeginDate, @DeptID
  )
Commit Transaction
End

Go

Select Top 15 *
From tblSTAFF S Join tblSTAFF_POSITION SP On S.StaffID = SP.StaffID
Order By SP.BeginDate Desc

Exec fretws_INSERT_NewStaffToExistingPosition
  'Gregory', -- @StaffFName
  'Hayward', -- @StaffLName
  '11332 South Meadowbrook Hill Highway', -- @StaffAddress
  'Seattle', -- @StaffCity
  'WA', -- @StaffState
  98105, -- @StaffZip
  '1970-05-09', -- @StaffBirth
  Null, -- @StaffNetID
  Null, -- @StaffEmail
  'M', -- @Gender
  5, -- @PositionID
  183, -- @DeptID
  '2022-02-04' -- @BeginDate

-- 7

Go

Alter Procedure fretws_INSERT_NewClassOfExistingCourse
  @CourseID INT,
  @QuarterID INT,
  @YEAR CHAR (4),
  @ClassroomID INT,
  @ScheduleID INT,
  @Section VARCHAR (4)
As
Begin Transaction
  Insert Into tblCLASS (
    CourseID, QuarterID, [YEAR], ClassroomID, ScheduleID, Section
  )
  Values
  (
    @CourseID,
    @QuarterID,
    @YEAR,
    @ClassroomID,
    @ScheduleID,
    @Section
  )
Commit Transaction

Go

Select Top 10 * From tblSCHEDULE

Exec fretws_INSERT_NewClassOfExistingCourse
  1, -- @CourseID,
  1, -- @QuarterID,
  2022,-- @YEAR,
  1, -- @ClassroomID,
  4, -- @ScheduleID,
  'A' -- @Section
  
Select Top 20 *
From tblCLASS 
Where CourseID = 1 And [YEAR] = 2022

-- 8

Go

Alter Procedure fretws_INSERT_NewClassList
  @ClassId INT,
  @StudentID INT,
  @RegistrationFee NUMERIC (10,2)
As
Begin Transaction
  Insert Into tblCLASS_LIST (
    ClassID, StudentID, RegistrationDate, RegistrationFee
  )
  Values (
    @ClassID, @StudentID, GetDate(), @RegistrationFee
  )
Commit Transaction

Go

Exec fretws_INSERT_NewClassList
  753187, -- @ClassID
  536987, --@StudentID
  Null -- @RegistrationFee

Select Top 10 *
From tblCLASS_LIST CL Join tblSTUDENT S On CL.StudentID = S.StudentID
Where RegistrationFee Is Null
Order By RegistrationDate Desc