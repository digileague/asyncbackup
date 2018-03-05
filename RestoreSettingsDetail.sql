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

ALTER TABLE [srv].[RestoreSettingsDetail] ADD  CONSTRAINT [DF_RestoreSettingsDetail_Row_GUID]  DEFAULT (newid()) FOR [Row_GUID]
GO

ALTER TABLE [srv].[RestoreSettingsDetail] ADD  CONSTRAINT [DF_RestoreSettingsDetail_InsertUTCDate]  DEFAULT (getutcdate()) FOR [InsertUTCDate]
GO


