if object_id('[dbo].[PROD_UPDATE]') is not null
    drop table [dbo].[PROD_UPDATE]
go

CREATE TABLE [dbo].[PROD_UPDATE](
	[ROW_VER] [timestamp] NOT NULL,
	[FILEDATA] [varbinary](max) NULL,
	[VERSION] [varchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
go

insert into [dbo].[PROD_UPDATE] (
    [VERSION]
)
values (
    '1.0.0'
)
go