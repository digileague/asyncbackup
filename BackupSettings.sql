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

ALTER TABLE [srv].[BackupSettings] ADD  CONSTRAINT [DF_BackupSettings_InsertUTCDate]  DEFAULT (getutcdate()) FOR [InsertUTCDate]
GO


