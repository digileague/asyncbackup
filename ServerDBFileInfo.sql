CREATE view [inf].[ServerDBFileInfo] as
SELECT  @@Servername AS Server ,
        File_id ,--������������� ����� � ���� ������. �������� �������� file_id ������ ����� 1
        Type_desc ,--�������� ���� �����
        Name as [FileName] ,--���������� ��� ����� � ���� ������
        LEFT(Physical_Name, 1) AS Drive ,--����� ����, ��� ������������� ���� ��
        Physical_Name ,--������ ��� ����� � ������������ �������
        RIGHT(physical_name, 3) AS Ext ,--���������� �����
        Size as CountPage, --������� ������ ����� � ��������� �� 8 ��
		round((cast(Size*8 as float))/1024,3) as SizeMb, --������ ����� � ��
		round((cast(Size*8 as float))/1024/1024,3) as SizeGb, --������ ����� � ��
        case when is_percent_growth=0 then Growth*8 else 0 end as Growth, --������� ����� � ��������� �� 8 ��
		case when is_percent_growth=0 then round((cast(Growth*8 as float))/1024,3) end as GrowthMb, --������� ����� � ��
		case when is_percent_growth=0 then round((cast(Growth*8 as float))/1024/1024,3) end as GrowthGb, --������� ����� � ��
		case when is_percent_growth=1 then Growth else 0 end as GrowthPercent, --������� ����� � ����� ���������
		is_percent_growth, --������� ����������� ����������
		database_id,
		DB_Name(database_id) as [DB_Name],
		State,--��������� �����
		state_desc as StateDesc,--�������� ��������� �����
		is_media_read_only as IsMediaReadOnly,--���� ��������� �� �������� ������ ��� ������ (0-� ��� ������)
		is_read_only as IsReadOnly,--���� ������� ��� ���� ������ ��� ������ (0-� ������)
		is_sparse as IsSpace,--����������� ����
		is_name_reserved as IsNameReserved,--1 - ��� ���������� �����, �������� ��� �������������.
		--���������� �������� ��������� ����� �������, ������ ��� ������� �������� ������������ ��� (��������� name ��� physical_name) ��� ������ ����� �����
		--0 - ��� �����, ���������� ��� ������������
		create_lsn as CreateLsn,--��������������� ����� ���������� � ������� (LSN), �� ������� ������ ����
		drop_lsn as DropLsn,--����� LSN, � ������� ���� ������
		read_only_lsn as ReadOnlyLsn,--����� LSN, �� ������� �������� ������, ���������� ����, �������� ��� � ���� ������ � ������ �� ������� ��� ������� (����� ��������� ���������)
		read_write_lsn as ReadWriteLsn,--����� LSN, �� ������� �������� ������, ���������� ����, �������� ��� � ������� ��� ������� �� ���� ������ � ������ (����� ��������� ���������)
		differential_base_lsn as DifferentialBaseLsn,--������ ��� ���������� ��������� �����. �������� ������, ���������� ����� ����, ��� ���� ����� LSN ����� ������� � ���������� ��������� �����
		differential_base_guid as DifferentialBaseGuid,--���������� ������������� ������� ��������� �����, �� ������� ����� ������������ ���������� ��������� �����
		differential_base_time as DifferentialBaseTime,--�����, ��������������� differential_base_lsn
		redo_start_lsn as RedoStartLsn,--����� LSN, � �������� ������ �������� ��������� �����
		--����� NULL, �� ����������� �������, ����� �������� ��������� state = RESTORING ��� �������� ��������� state = RECOVERY_PENDING
		redo_start_fork_guid as RedoStartForkGuid,--���������� ������������� ����� ����� ��������������.
		--�������� ��������� first_fork_guid ��������� ��������������� ��������� ����� ������� ������ ��������������� ����� ��������. ��� �������� ������� ��������� ����������
		redo_target_lsn as RedoTargetLsn,--����� LSN, �� ������� ����� � ������ �� ���� �� ������� ����� ����� ������������
		--����� NULL, �� ����������� �������, ����� �������� ��������� state = RESTORING ��� �������� ��������� state = RECOVERY_PENDING
		redo_target_fork_guid as RedoTargetForkGuid,--����� ��������������, �� ������� ����� ���� ������������ ���������. ������������ � ���� � redo_target_lsn
		backup_lsn as BackupLsn--����� LSN ����� ����� ������ ��� ���������� ��������� ����� �����
FROM    sys.master_files--database_files;

GO


