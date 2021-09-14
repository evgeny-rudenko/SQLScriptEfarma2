--USE [arm_eplus_work] -- База Данных АРМ кассира
-- нужно выбрать то что необходимо 
--GO

/****** Object:  Table [dbo].[KIZ_2_DOCUMENT_ITEM]    Script Date: 02.09.2021 15:45:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- таблица куда будем складывать логи кизов в чеках
CREATE TABLE [dbo].[KIZ_LOG](
	[ID_KIZ_2_DOCUMENT_ITEM] [bigint] IDENTITY(1,1) NOT NULL,
	[KIZ_STR] [varchar](128) NULL,
	[ID_KIZ_GLOBAL] [uniqueidentifier] NULL,
	[NUMERATOR] [int] NULL,
	[DENOMINATOR] [int] NULL,
	[QUANTITY] [money] NOT NULL,
	[REMAIN] [money] NOT NULL,
	[DATE_MODIFIED] [datetime] NULL,
	[BARCODE] [varchar](128) NULL)


