USE [arm_eplus_work]
GO

/****** Object:  Table [dbo].[KIZ_LOG]    Script Date: 09/02/2022 05:45:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[KIZ_LOG](
	[ID_KIZ_2_DOCUMENT_ITEM] [bigint] IDENTITY(1,1) NOT NULL,
	[KIZ_STR] [varchar](128) NULL,
	[ID_KIZ_GLOBAL] [uniqueidentifier] NULL,
	[NUMERATOR] [int] NULL,
	[DENOMINATOR] [int] NULL,
	[QUANTITY] [money] NOT NULL,
	[REMAIN] [money] NOT NULL,
	[DATE_MODIFIED] [datetime] NULL,
	[BARCODE] [varchar](128) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO





USE [arm_eplus_work]
GO

/****** Object:  Trigger [dbo].[TRG_KIZ_LOG]    Script Date: 09/02/2022 05:43:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Запись всех отсканированных КИЗ в таблицу с логами на АРМ кассира
-- =============================================
ALTER TRIGGER [dbo].[TRG_KIZ_LOG]
   ON  [dbo].[KIZ_2_DOCUMENT_ITEM]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO KIZ_LOG
           
	 select 
 ISNULL (
  CONVERT
    (
        VARCHAR(MAX), 
        CAST('' AS XML).value('xs:base64Binary(sql:column("BARCODE"))', 'VARBINARY(MAX)')
    ) , BARCODE)AS KIZ_STR
	
           ,[ID_KIZ_GLOBAL]
           ,[NUMERATOR]
           ,[DENOMINATOR]
           ,[QUANTITY]
           ,[REMAIN]
           ,[DATE_MODIFIED]
           ,[BARCODE]


 from inserted

	 

--GO
    -- Insert statements for trigger here

END

GO


