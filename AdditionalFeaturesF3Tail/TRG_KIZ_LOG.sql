-- ================================================
-- Template generated from Template Explorer using:
-- Create Trigger (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- See additional Create Trigger templates for more
-- examples of different Trigger statements.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER TRG_KIZ_LOG
   ON  KIZ_2_DOCUMENT_ITEM
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
