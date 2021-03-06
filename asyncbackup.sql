USE [master]
GO
/****** Object:  Database [asyncbackup]    Script Date: 02.03.2018 15:33:04 ******/
CREATE DATABASE [asyncbackup]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'asyncbackup', FILENAME = N'E:\BASE\asyncbackup.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'asyncbackup_log', FILENAME = N'E:\BASE\asyncbackup_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [asyncbackup] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [asyncbackup].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [asyncbackup] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [asyncbackup] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [asyncbackup] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [asyncbackup] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [asyncbackup] SET ARITHABORT OFF 
GO
ALTER DATABASE [asyncbackup] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [asyncbackup] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [asyncbackup] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [asyncbackup] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [asyncbackup] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [asyncbackup] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [asyncbackup] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [asyncbackup] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [asyncbackup] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [asyncbackup] SET  DISABLE_BROKER 
GO
ALTER DATABASE [asyncbackup] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [asyncbackup] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [asyncbackup] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [asyncbackup] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [asyncbackup] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [asyncbackup] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [asyncbackup] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [asyncbackup] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [asyncbackup] SET  MULTI_USER 
GO
ALTER DATABASE [asyncbackup] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [asyncbackup] SET DB_CHAINING OFF 
GO
ALTER DATABASE [asyncbackup] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [asyncbackup] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [asyncbackup] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [asyncbackup] SET QUERY_STORE = OFF
GO
USE [asyncbackup]
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [asyncbackup]
GO
/****** Object:  Schema [inf]    Script Date: 02.03.2018 15:33:04 ******/
CREATE SCHEMA [inf]
GO
/****** Object:  Schema [srv]    Script Date: 02.03.2018 15:33:04 ******/
CREATE SCHEMA [srv]
GO
/****** Object:  Table [srv].[BackupSettings]    Script Date: 02.03.2018 15:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [srv].[BackupSettings](
	[DBID] [int] NOT NULL,
	[FullPathBackup] [nvarchar](255) NOT NULL,
	[DiffPathBackup] [nvarchar](255) NULL,
	[LogPathBackup] [nvarchar](255) NULL,
	[InsertUTCDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BackupSettings] PRIMARY KEY CLUSTERED 
(
	[DBID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [srv].[vBackupSettings]    Script Date: 02.03.2018 15:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
/****** Object:  View [inf].[ServerDBFileInfo]    Script Date: 02.03.2018 15:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [inf].[ServerDBFileInfo] as
SELECT  @@Servername AS Server ,
        File_id ,--Идентификатор файла в базе данных. Основное значение file_id всегда равно 1
        Type_desc ,--Описание типа файла
        Name as [FileName] ,--Логическое имя файла в базе данных
        LEFT(Physical_Name, 1) AS Drive ,--Метка тома, где располагается файл БД
        Physical_Name ,--Полное имя файла в операционной системе
        RIGHT(physical_name, 3) AS Ext ,--Расширение файла
        Size as CountPage, --Текущий размер файла в страницах по 8 КБ
		round((cast(Size*8 as float))/1024,3) as SizeMb, --Размер файла в МБ
		round((cast(Size*8 as float))/1024/1024,3) as SizeGb, --Размер файла в ГБ
        case when is_percent_growth=0 then Growth*8 else 0 end as Growth, --Прирост файла в страницах по 8 КБ
		case when is_percent_growth=0 then round((cast(Growth*8 as float))/1024,3) end as GrowthMb, --Прирост файла в МБ
		case when is_percent_growth=0 then round((cast(Growth*8 as float))/1024/1024,3) end as GrowthGb, --Прирост файла в ГБ
		case when is_percent_growth=1 then Growth else 0 end as GrowthPercent, --Прирост файла в целых процентах
		is_percent_growth, --Признак процентного приращения
		database_id,
		DB_Name(database_id) as [DB_Name],
		State,--состояние файла
		state_desc as StateDesc,--описание состояния файла
		is_media_read_only as IsMediaReadOnly,--файл находится на носителе только для чтения (0-и для записи)
		is_read_only as IsReadOnly,--файл помечен как файл только для чтения (0-и записи)
		is_sparse as IsSpace,--разреженный файл
		is_name_reserved as IsNameReserved,--1 - Имя удаленного файла, доступно для использования.
		--Необходимо получить резервную копию журнала, прежде чем удастся повторно использовать имя (аргументы name или physical_name) для нового имени файла
		--0 - Имя файла, недоступно для использовани
		create_lsn as CreateLsn,--Регистрационный номер транзакции в журнале (LSN), на котором создан файл
		drop_lsn as DropLsn,--Номер LSN, с которым файл удален
		read_only_lsn as ReadOnlyLsn,--Номер LSN, на котором файловая группа, содержащая файл, изменила тип с «для чтения и записи» на «только для чтения» (самое последнее изменение)
		read_write_lsn as ReadWriteLsn,--Номер LSN, на котором файловая группа, содержащая файл, изменила тип с «только для чтения» на «для чтения и записи» (самое последнее изменение)
		differential_base_lsn as DifferentialBaseLsn,--Основа для разностных резервных копий. Экстенты данных, измененных после того, как этот номер LSN будет включен в разностную резервную копию
		differential_base_guid as DifferentialBaseGuid,--Уникальный идентификатор базовой резервной копии, на которой будет основываться разностная резервная копия
		differential_base_time as DifferentialBaseTime,--Время, соответствующее differential_base_lsn
		redo_start_lsn as RedoStartLsn,--Номер LSN, с которого должен начаться следующий накат
		--Равно NULL, за исключением случаев, когда значение аргумента state = RESTORING или значение аргумента state = RECOVERY_PENDING
		redo_start_fork_guid as RedoStartForkGuid,--Уникальный идентификатор точки вилки восстановления.
		--Значение аргумента first_fork_guid следующей восстановленной резервной копии журнала должно соответствовать этому значению. Это отражает текущее состояние контейнера
		redo_target_lsn as RedoTargetLsn,--Номер LSN, на котором накат в режиме «в сети» по данному файлу может остановиться
		--Равно NULL, за исключением случаев, когда значение аргумента state = RESTORING или значение аргумента state = RECOVERY_PENDING
		redo_target_fork_guid as RedoTargetForkGuid,--Вилка восстановления, на которой может быть восстановлен контейнер. Используется в паре с redo_target_lsn
		backup_lsn as BackupLsn--Номер LSN самых новых данных или разностная резервная копия файла
FROM    sys.master_files--database_files;

GO
/****** Object:  View [inf].[vServerLastBackupDB]    Script Date: 02.03.2018 15:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [inf].[vServerLastBackupDB] as
with backup_cte as
(
    select
        bs.[database_name],
        backup_type =
            case bs.[type]
                when 'D' then 'database'
                when 'L' then 'log'
                when 'I' then 'differential'
                else 'other'
            end,
        bs.[first_lsn],
		bs.[last_lsn],
		bs.[backup_start_date],
		bs.[backup_finish_date],
		cast(bs.[backup_size] as decimal(18,3))/1024/1024 as BackupSizeMb,
        rownum = 
            row_number() over
            (
                partition by bs.[database_name], type 
                order by bs.[backup_finish_date] desc
            ),
		LogicalDeviceName = bmf.[logical_device_name],
		PhysicalDeviceName = bmf.[physical_device_name],
		bs.[server_name],
		bs.[user_name]
    FROM msdb.dbo.backupset bs
    INNER JOIN msdb.dbo.backupmediafamily bmf 
        ON [bs].[media_set_id] = [bmf].[media_set_id]
)
select
    [server_name] as [ServerName],
	[database_name] as [DBName],
	[user_name] as [USerName],
    [backup_type] as [BackupType],
	[backup_start_date] as [BackupStartDate],
    [backup_finish_date] as [BackupFinishDate],
	[BackupSizeMb], --размер без сжатия
	[LogicalDeviceName],
	[PhysicalDeviceName],
	[first_lsn] as [FirstLSN],
	[last_lsn] as [LastLSN]
from backup_cte
where rownum = 1;
GO
/****** Object:  Table [srv].[RestoreSettings]    Script Date: 02.03.2018 15:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [srv].[RestoreSettings](
	[DBName] [nvarchar](255) NOT NULL,
	[FullPathRestore] [nvarchar](255) NOT NULL,
	[DiffPathRestore] [nvarchar](255) NOT NULL,
	[LogPathRestore] [nvarchar](255) NOT NULL,
	[InsertUTCDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RestoreSettings] PRIMARY KEY CLUSTERED 
(
	[DBName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [srv].[RestoreSettingsDetail]    Script Date: 02.03.2018 15:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [srv].[RestoreSettingsDetail](
	[Row_GUID] [uniqueidentifier] NOT NULL,
	[DBName] [nvarchar](255) NOT NULL,
	[SourcePathRestore] [nvarchar](255) NOT NULL,
	[TargetPathRestore] [nvarchar](255) NOT NULL,
	[Ext] [nvarchar](255) NOT NULL,
	[InsertUTCDate] [datetime] NOT NULL,
 CONSTRAINT [PK_RestoreSettingsDetail] PRIMARY KEY CLUSTERED 
(
	[Row_GUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [srv].[BackupSettings] ADD  CONSTRAINT [DF_BackupSettings_InsertUTCDate]  DEFAULT (getutcdate()) FOR [InsertUTCDate]
GO
ALTER TABLE [srv].[RestoreSettings] ADD  CONSTRAINT [DF_RestoreSettings_InsertUTCDate]  DEFAULT (getutcdate()) FOR [InsertUTCDate]
GO
ALTER TABLE [srv].[RestoreSettingsDetail] ADD  CONSTRAINT [DF_RestoreSettingsDetail_Row_GUID]  DEFAULT (newid()) FOR [Row_GUID]
GO
ALTER TABLE [srv].[RestoreSettingsDetail] ADD  CONSTRAINT [DF_RestoreSettingsDetail_InsertUTCDate]  DEFAULT (getutcdate()) FOR [InsertUTCDate]
GO
/****** Object:  StoredProcedure [inf].[RunAsyncExecute]    Script Date: 02.03.2018 15:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [inf].[RunAsyncExecute]
(
	@sql nvarchar(max),
	@jobname nvarchar(57) = null,   
	@database nvarchar(128)= null,
	@owner nvarchar(128) = null
)
AS BEGIN
/*
	асинхронный вызов пакета через задания Агента
	RunAsyncExecute - asynchronous execution of T-SQL command or stored prodecure  
*/  
    SET NOCOUNT ON;  
  
    declare @id uniqueidentifier;

    --Create unique job name if the name is not specified  
    if (@jobname is null) set @jobname= '';

    set @jobname = @jobname + '_async_' + convert(varchar(64),NEWID());
  
    if (@owner is null) set @owner = 'sa';
  
    --Create a new job, get job ID  
    execute msdb..sp_add_job @jobname, @owner_login_name=@owner, @job_id=@id OUTPUT;
  
    --Specify a job server for the job  
    execute msdb..sp_add_jobserver @job_id=@id;
  
    --Specify a first step of the job - the SQL command  
    --(@on_success_action = 3 ... Go to next step)  
    execute msdb..sp_add_jobstep @job_id=@id, @step_name='Step1', @command = @sql,   
        @database_name = @database, @on_success_action = 3;
  
    --Specify next step of the job - delete the job  
    declare @deletecommand varchar(200);

    set @deletecommand = 'execute msdb..sp_delete_job @job_name='''+@jobname+'''';

    execute msdb..sp_add_jobstep @job_id=@id, @step_name='Step2', @command = @deletecommand;
  
    --Start the job  
    execute msdb..sp_start_job @job_id=@id;
  
END  

GO
/****** Object:  StoredProcedure [srv].[RunDiffBackupDB]    Script Date: 02.03.2018 15:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [srv].[RunDiffBackupDB]
	@ClearLog bit=1 --сокращать ли размер журнала транзакций  
AS
BEGIN
	/*
		Создание разностной резервной копии БД
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
		[DiffPathBackup] [nvarchar](255) NOT NULL
	);

	declare @tbllog table(
		[DBName] [nvarchar](255) NOT NULL,
		[FileNameLog] [nvarchar](255) NOT NULL
	);
	
	--получаем названия БД и полные пути для создания разностных резервных копий
	insert into @tbl (
	           [DBName]
	           ,[DiffPathBackup]
	)
	select		DB_NAME([DBID])
	           ,[DiffPathBackup]
	from [srv].[BackupSettings]
	where [DiffPathBackup] is not null;

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
		@pathBackup=[DiffPathBackup]
		from @tbl;
	
		set @backupName=@DBName+N'_Diff_backup_'+cast(@year as nvarchar(255))+N'_'+cast(@month as nvarchar(255))+N'_'+cast(@day as nvarchar(255))+N'_'
						+cast(@hour as nvarchar(255))+N'_'+cast(@minute as nvarchar(255))+N'_'+cast(@second as nvarchar(255));
		set @pathstr=@pathBackup+@backupName+N'.bak';
		
		--осуществляем проверку на целостность БД
		set @sql=N'DBCC CHECKDB(N'+N''''+@DBName+N''''+N')  WITH NO_INFOMSGS';

		exec(@sql);
		
		--запускаем непосредственно процедуру резервного копирования
		set @sql=N'BACKUP DATABASE ['+@DBName+N'] TO DISK = N'+N''''+@pathstr+N''''+
				 N' WITH DIFFERENTIAL, NOFORMAT, NOINIT, NAME = N'+N''''+@backupName+N''''+
				 N', CHECKSUM, STOP_ON_ERROR, SKIP, REWIND, COMPRESSION, STATS = 10;';
	
		exec(@sql);

		--проверяем созданную резервную копию БД
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
/****** Object:  StoredProcedure [srv].[RunFullBackupDB]    Script Date: 02.03.2018 15:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [srv].[RunFullBackupDB]
	@ClearLog bit=1 --сокращать ли размер журнала транзакций 
AS
BEGIN
	/*
		Создание полной резервной копии БД с предварительной проверкой на целостность самой БД
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

	declare @tbllog table(
		[DBName] [nvarchar](255) NOT NULL,
		[FileNameLog] [nvarchar](255) NOT NULL
	);
	
	declare @tbl table (
		[DBName] [nvarchar](255) NOT NULL,
		[FullPathBackup] [nvarchar](255) NOT NULL
	);
	
	--получаем названия БД и полные пути для создания полных резервных копий
	insert into @tbl (
	           [DBName]
	           ,[FullPathBackup]
	)
	select		DB_NAME([DBID])
	           ,[FullPathBackup]
	from [srv].[BackupSettings];

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
		@pathBackup=[FullPathBackup]
		from @tbl;
	
		set @backupName=@DBName+N'_Full_backup_'+cast(@year as nvarchar(255))+N'_'+cast(@month as nvarchar(255))+N'_'+cast(@day as nvarchar(255))--+N'_'
						--+cast(@hour as nvarchar(255))+N'_'+cast(@minute as nvarchar(255))+N'_'+cast(@second as nvarchar(255));
		set @pathstr=@pathBackup+@backupName+N'.bak';

		--осуществляем проверку на целостность БД
		set @sql=N'DBCC CHECKDB(N'+N''''+@DBName+N''''+N')  WITH NO_INFOMSGS';

		exec(@sql);
		
		--запускаем непосредственно процедуру резервного копирования
		set @sql=N'BACKUP DATABASE ['+@DBName+N'] TO DISK = N'+N''''+@pathstr+N''''+
				 N' WITH NOFORMAT, NOINIT, NAME = N'+N''''+@backupName+N''''+
				 N', CHECKSUM, STOP_ON_ERROR, SKIP, REWIND, COMPRESSION, STATS = 10;';
	
		exec(@sql);

		--проверяем созданную резервную копию БД
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
/****** Object:  StoredProcedure [srv].[RunFullRestoreDB]    Script Date: 02.03.2018 15:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [srv].[RunFullRestoreDB]
AS
BEGIN
	/*
		Восстановление из полной резервной копии БД с последующей проверкой на целостность самой БД
	*/
	SET NOCOUNT ON;

    declare @dt datetime=DateAdd(day,-2,getdate());
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
	declare @SourcePathRestore nvarchar(255);
	declare @TargetPathRestore nvarchar(255);
	declare @Ext nvarchar(255);
	
	declare @tbl table (
		[DBName] [nvarchar](255) NOT NULL,
		[FullPathRestore] [nvarchar](255) NOT NULL
	);

	declare @tbl_files table (
		[DBName] [nvarchar](255) NOT NULL,
		[SourcePathRestore] [nvarchar](255) NOT NULL,
		[TargetPathRestore] [nvarchar](255) NOT NULL,
		[Ext] [nvarchar](255) NOT NULL
	);
	
	--получаем список имен БД и полных путей к полным резервным копиям БД
	insert into @tbl (
	           [DBName]
	           ,[FullPathRestore]
	)
	select		[DBName]
	           ,[FullPathRestore]
	from [srv].[RestoreSettings];

	--получаем детальную информацию по тому, куда переносить файлы БД
	insert into @tbl_files (
	           [DBName]
	           ,[SourcePathRestore]
			   ,[TargetPathRestore]
			   ,[Ext]
	)
	select		[DBName]
	           ,[SourcePathRestore]
			   ,[TargetPathRestore]
			   ,[Ext]
	from [srv].[RestoreSettingsDetail];
	
	--обрабатываем каждую полученную БД
	while(exists(select top(1) 1 from @tbl))
	begin
		set @backupSetId=NULL;

		select top(1)
		@DBName=[DBName],
		@pathBackup=[FullPathRestore]
		from @tbl;
	
		set @backupName=@DBName+N'_Full_backup_'+cast(@year as nvarchar(255))+N'_'+cast(@month as nvarchar(255))+N'_'+cast(@day as nvarchar(255))--+N'_'
						--+cast(@hour as nvarchar(255))+N'_'+cast(@minute as nvarchar(255))+N'_'+cast(@second as nvarchar(255));
		set @pathstr=@pathBackup+@backupName+N'.bak';

		--формируем запрос на восстановление и вызываем его
		set @sql=N'RESTORE DATABASE ['+@DBName+N'_Restore] FROM DISK = N'+N''''+@pathstr+N''''+
				 N' WITH FILE = 1,';

		while(exists(select top(1) 1 from @tbl_files where [DBName]=@DBName))
		begin
			select top(1)
			@SourcePathRestore=[SourcePathRestore],
			@TargetPathRestore=[TargetPathRestore],
			@Ext=[Ext]
			from @tbl_files
			where [DBName]=@DBName;

			set @sql=@sql+N' MOVE N'+N''''+@SourcePathRestore+N''''+N' TO N'+N''''+@TargetPathRestore+N'_Restore.'+@Ext+N''''+N',';

			delete from @tbl_files
			where [DBName]=@DBName
			and [SourcePathRestore]=@SourcePathRestore
			and [Ext]=@Ext;
		end

		set @sql=@sql+N' NOUNLOAD,  REPLACE,  STATS = 5';

		exec(@sql);

		--проверяем на целотность БД
		set @sql=N'DBCC CHECKDB(N'+N''''+@DBName+'_Restore'+N''''+N')  WITH NO_INFOMSGS';
	
		exec(@sql);
		
		delete from @tbl
		where [DBName]=@DBName;
	end
END
GO
/****** Object:  StoredProcedure [srv].[RunLogBackupDB]    Script Date: 02.03.2018 15:33:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
USE [master]
GO
ALTER DATABASE [asyncbackup] SET  READ_WRITE 
GO
