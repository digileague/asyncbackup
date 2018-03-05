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

ALTER TABLE [srv].[RestoreSettings] ADD  CONSTRAINT [DF_RestoreSettings_InsertUTCDate]  DEFAULT (getutcdate()) FOR [InsertUTCDate]
GO


