-- 1
Create Function fnCountTasksWithDamagedToolByEmployee(@PK INT)
Returns INT
As
Begin
Declare @Ret INT = (
  Select Count(Distinct Tk.TaskID)
  From tblTask Tk
    Join tblJOB_TASK_TOOL_EQUIP JTTE On JTTE.TaskID = Tk.TaskID
    Join tblTOOL_CONDITION TC On JTTE.ToolConditionID = TC.ToolConditionID
    Join tblEMPLOYEE_SKILL_LEVEL ESL On ESL.EmpSkillID = JTTE.EmpSkillID
    Join tblEMPLOYEE_POSITION EP On EP.EmpPositionID = ESL.EmpPositionID
    Join tblEMPLOYEE E On E.EmpID = EP.EmpID
    Join tblCONDITION C On C.ConditionID = TC.ConditionID
  Where EP.EmpID = @PK
    And C.ConditionName = 'damaged'
    And DateDiff('year', JTTE.EndDateTime, GetDate()) < 4.5
  )
Return @Ret
End
Go
Alter Table tblEMPLOYEE
Add RecentTasksWithDamagedTool
As (dbo.fnCountTasksWithDamagedToolByEmployee(EmpID))
Go 

-- 2
Create Procedure uspNewToolCondition
  @ToolName VarChar(30), @ToolTypeName VarChar(30), @ConditionName VarChar(30), @BeginDate DATE
As
Begin
Declare @T_ID INT, @TT_ID INT, @C_ID INT

Set @C_ID = (Select ConditionID From tblCondition Where ConditionName = @ConditionName)
Set @TT_ID = (Select ToolTypeID From tblTOOL_TYPE Where ToolTypeName = @ToolTypeName)

Begin Transaction
Insert Into tblTOOL(ToolName) -- Since you said four parameters, I am assuming ToolDescr can be null for this problem
Values(@ToolName)

Insert Into tblTOOL_CONDITION(ToolID, ConditionID, BeginDate)
Values(SCOPE_IDENTITY(), @C_ID, GetDate())
Commit Transaction

-- 3
Select C.CustomerName, Orders.[Count]
From tblCUSTOMER C
  Inner Join (
    Select C.CustomerName, Count(O.OrderID) [Count]
    From tblCUSTOMER C
      Join tblJOB J On J.CustID = C.CustID
      Join tblORDER O On O.JobID = J.JobID
      Join tblLINE_ITEM LI On LI.OrderID = O.OrderID
      Join tblPRODUCT P On LI.ProductID = P.ProductID
      Join tblPRODUCT_TYPE PT On PT.ProductTypeID = P.ProductTypeID
    Where PT.ProductTypeName = 'lighting'
      And DateDiff('year', O.OrderDate, GetDate()) < 5
    Group By C.CustomerID
    Having Count(O.OrderID) > 11
  ) As Orders On Orders.CustID = C.CustID
Where C.CustID In (
  Select C.CustID
  From tblCUSTOMER C
    Join tblJOB J On J.CustID = C.CustID
    Join tblJOB_TASK_TOOL_EQUIP JTTE On JTTE.JobID = J.JobID
    Join tblEMPLOYEE_SKILL_LEVEL ESL On ESL.EmpSkillID = JTTE.EmpSkillID
    Join tblEMPLOYEE_POSITION EP On EP.EmpPositionID = EP.EmpPositionID
    Join tblEMPLOYEE E On E.EmpID = EP.EmpID
    Join tblTASK T On T.TaskID = JTTE.TaskID
  Where E.EmpFname + ' ' + E.EmpLname = 'Mikki Bailey'
    And T.TaskName = 'sliding-glass door replaced'
)

-- 4
Go
Create Function fnIsNuclearYoungAdultEmployee()
Returns INT
As
Begin
Declare @Ret INT = 0
If Exists (
  Select *
  From tblJOB_TASK_TOOL_EQUIP JTTE
    Join tblEMPLOYEE_SKILL_LEVEL ESL On ESL.EmpSkillID = JTTE.EmpSkillID
    Join tblEMPLOYEE_POSITION EP On EP.EmpPositionID = EP.EmpPositionID
    Join tblEMPLOYEE E On E.EmpID = EP.EmpID
    Join tblTOOL_CONDITION TC On JTTE.ToolConditionID = TC.ToolConditionID
    Join tblTOOL T On T.ToolID = TC.ToolID
    Join tblTOOL_TYPE TT On TT.ToolTypeID = T.ToolTypeID
  Where DateDiff('year', E.EmpBirthDate, GetDate()) Between 18 And 21
    And TT.ToolTypeName = 'Nuclear'
) Set @Ret = 1
Return @Ret
End
Go

Alter Table tblJOB_TASK_TOOL_EQUIP
Add Constraint NoNuclearYoungAdultEmployees
Check (fnIsNuclearYoungAdultEmployee() = 0)

-- 5
Go
Create Function fnHighRiseEmployeeIsntSeniorHeavyMachinery()
Returns INT
As
Begin
Declare @Ret INT = 0
If Exists (
  Select *
  From tblJOB_TASK_TOOL_EQUIP JTTE
    Join tblEMPLOYEE_SKILL_LEVEL ESL On ESL.EmpSkillID = JTTE.EmpSkillID
    Join tblSKILL S On S.SkillID = ESL.SkillID
    Join tblSKILL_TYPE ST On ST.SkillTypeID = S.SkillTypeID
    Join tblTOOL_CONDITION TC On JTTE.ToolConditionID = TC.ToolConditionID
    Join tblTOOL T On T.ToolID = TC.ToolID
    Join tblTOOL_TYPE TT On TT.ToolTypeID = T.ToolTypeID
    Join tblJOB J On J.JobID = JTTE.JobID
    Join tblJOB_Type JT On JT.JobTypeID = J.JobTypeID
    Join tblLEVEL SL On SL.LevelID = ESL.LevelID
  Where JT.JobTypeName = 'high-rise commercial'
    And TT.ToolTypeName = 'hydraulic lift'
    And JTTE.BeginDateTime > '2020-11-13'
    And (SL.LevelName != 'senior' Or ST.SkillTypeName != 'Heavy Machinery')
) Set @Ret = 1
Return @Ret
End
Go

Alter Table tblJOB_TASK_TOOL_EQUIP
Add Constraint fnHighRiseEmployeeOnlySeniorHeavyMachinery
Check (fnHighRiseEmployeeIsntSeniorHeavyMachinery() = 0)


