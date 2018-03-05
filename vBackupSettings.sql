CREATE view [srv].[vBackupSettings]
as
SELECT [DBID]
      ,DB_Name([DBID]) as [DBName]
	  ,[FullPathBackup]
      ,[DiffPathBackup]
      ,[LogPathBackup]
      ,[InsertUTCDate]
  FROM [srv].[BackupSettings];

GO


