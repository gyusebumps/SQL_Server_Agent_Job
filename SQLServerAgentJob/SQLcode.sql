--*************************************************************************--
-- Title: Assignment05
-- Author: RRoot
-- Desc: This file creates a sproc that backups the northwind db and restores a copy of it for reporting 
-- Change Log: When,Who,What
-- 2018-02-07,RRoot,Created File
--**************************************************************************--
USE [TempDB];
go
SET NoCount ON;
go
	If Exists(Select * from Sys.objects where Name = 'pMaintRefreshNorthwindReport')
   Drop Procedure pMaintRefreshNorthwindReport;
go
Create Procedure pMaintRefreshNorthwindReport
/* Author: RRoot
** Desc: Backups the northwind db and restores a copy of it for reporting 
** Change Log: When,Who,What
** 2018-02-07,RRoot,Created Sproc.
*/
as
Begin
  Declare @RC int = 0;
  Begin Try
   -- Step 1: Make a copy of the current database
   BACKUP DATABASE [Northwind] 
   TO DISK = N'C:\_BISolutions\Northwind.bak' 
   WITH INIT;
   -- Step 2: Restore the copy as a different database for reporting
   RESTORE DATABASE [Northwind-ReadOnly] 
   FROM DISK = N'C:\_BISolutions\Northwind.bak' 
   WITH FILE = 1
      , MOVE N'Northwind' TO N'C:\_BISolutions\northwnd-Reports.mdf'
      , MOVE N'Northwind_log' TO N'C:\_BISolutions\northwnd-Reports.ldf'
      , REPLACE;
   -- Step 3: Set the reporting database to read-only
   ALTER DATABASE [Northwind-ReadOnly] SET READ_ONLY WITH NO_WAIT;
   Set @RC = +1
  End Try
  Begin Catch
   Print Error_Message()
   Set @RC = -1
  End Catch
  Return @RC;
End
/* Testing Code:
 Declare @Status int;
 Exec @Status = pMaintRefreshNorthwindReport;
 Print @Status;
 Select * from SysDatabases Where Name like 'Northwind%';
 Select name, create_date, is_read_only from Sys.Databases Where Name like 'Northwind%';
*/


