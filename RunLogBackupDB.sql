create PROCEDURE [srv].[RunLogBackupDB]
	@ClearLog bit=1 --сокращать ли размер журнала транзакций 
AS
BEGIN
	/*
		Создание резервной копии журнала транзакции БД
	*/
	SET NOCOUNT ON;

    declare @dt datetime=getdate();
	declare @year int=YEAR(@dt);
	declare @month int=MONTH(@dt);
	declare @day int=DAY(@dt);
	declare @hour int=DatePart(hour, @dt);
	declare @minute int=DatePart(minute, @dt);
	declare @second int=DatePart(second, @dt);
	declare @pathBackup nvarchar(255);
	declare @pathstr nvarchar(255);
	declare @DBName nvarchar(255);
	declare @backupName nvarchar(255);
	declare @sql nvarchar(max);
	declare @backupSetId as int;
	declare @FileNameLog nvarchar(255);
	
	declare @tbl table (
		[DBName] [nvarchar](255) NOT NULL,
		[LogPathBackup] [nvarchar](255) NOT NULL
	);

	declare @tbllog table(
		[DBName] [nvarchar](255) NOT NULL,
		[FileNameLog] [nvarchar](255) NOT NULL
	);
	
	--получаем названия БД и полные пути для создания резервных копий журналов транзакций, у которых модель восстановления не простая (полная или с неполным протоколированием)
	--и за исключением системных БД
	insert into @tbl (
	           [DBName]
	           ,[LogPathBackup]
	)
	select		DB_NAME(b.[DBID])
	           ,b.[LogPathBackup]
	from [srv].[BackupSettings] as b
	inner join sys.databases as d on b.[DBID]=d.[database_id]
	where d.recovery_model<3
	and DB_NAME([DBID]) not in (
		N'master',
		N'tempdb',
		N'model',
		N'msdb',
		N'ReportServer',
		N'ReportServerTempDB'
	)
	and [LogPathBackup] is not null;

	--получаем названия БД и полные названия файлов соответствующих журналов транзакций (т к у одной базы данных их может быть несколько)
	insert into @tbllog([DBName], [FileNameLog])
	select t.[DBName], tt.[FileName] as [FileNameLog]
	from @tbl as t
	inner join [inf].[ServerDBFileInfo] as tt on t.[DBName]=DB_NAME(tt.[database_id])
	where tt.[Type_desc]='LOG';
	
	--далее последовательно обрабатываем каждую полученную ранее БД
	while(exists(select top(1) 1 from @tbl))
	begin
		set @backupSetId=NULL;

		select top(1)
		@DBName=[DBName],
		@pathBackup=[LogPathBackup]
		from @tbl;
	
		set @backupName=@DBName+N'_Log_backup_'+cast(@year as nvarchar(255))+N'_'+cast(@month as nvarchar(255))+N'_'+cast(@day as nvarchar(255))+N'_'
						+cast(@hour as nvarchar(255))+N'_'+cast(@minute as nvarchar(255))+N'_'+cast(@second as nvarchar(255));
		set @pathstr=@pathBackup+@backupName+N'.trn';
		
		--запускаем непосредственно процедуру резервного копирования
		set @sql=N'BACKUP LOG ['+@DBName+N'] TO DISK = N'+N''''+@pathstr+N''''+
				 N' WITH NOFORMAT, NOINIT, NAME = N'+N''''+@backupName+N''''+
				 N', CHECKSUM, STOP_ON_ERROR, SKIP, REWIND, COMPRESSION, STATS = 10;';
	
		exec(@sql);

		--проверяем созданную резервную копию журнала транзакций
		select @backupSetId = position
		from msdb..backupset where database_name=@DBName
		and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=@DBName);

		set @sql=N'Ошибка верификации. Сведения о резервном копировании для базы данных "'+@DBName+'" не найдены.';

		if @backupSetId is null begin raiserror(@sql, 16, 1) end
		else
		begin
			set @sql=N'RESTORE VERIFYONLY FROM DISK = N'+''''+@pathstr+N''''+N' WITH FILE = '+cast(@backupSetId as nvarchar(255));

			exec(@sql);
		end

		--ужимаем журналы транзакций БД
		if(@ClearLog=1)
		begin
			while(exists(select top(1) 1 from @tbllog where [DBName]=@DBName))
			begin
				select top(1)
				@FileNameLog=FileNameLog
				from @tbllog
				where DBName=@DBName;
			
				set @sql=N'USE ['+@DBName+N'];'+N' DBCC SHRINKFILE (N'+N''''+@FileNameLog+N''''+N' , 0, TRUNCATEONLY)';

				exec(@sql);

				delete from @tbllog
				where FileNameLog=@FileNameLog
				and DBName=@DBName;
			end
		end
		
		delete from @tbl
		where [DBName]=@DBName;
	end
END

GO


