USE [Farma]
GO
/****** Object:  StoredProcedure [dbo].[DISCOUNT2_SPECIAL_BONUS]    Script Date: 07/16/2017 19:49:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISCOUNT2_SPECIAL_BONUS]                   
    @ID_DISCOUNT2_CARD_GLOBAL UNIQUEIDENTIFIER                   
AS                 
    DECLARE @BONUS_APPLIED INT          
    DECLARE @DISCOUNT_VALUE NUMERIC(38,10)
    DECLARE @CHEQUE_SUMM NUMERIC(38,10)
      
    --DECLARE @HDOC INT           
    --DECLARE @XMLSTRING VARCHAR(4000) 
	--SET @XMLSTRING = (SELECT TOP 1 SPECIAL_PARAMS FROM #SPECIAL_PARAMS)          
    --EXEC SP_XML_PREPAREDOCUMENT @HDOC OUT,  @XMLSTRING          
    --SET @BONUS_APPLIED = (SELECT TOP 1 VALUE              
    --  FROM OPENXML(@HDOC, '/XML')          
    --      WITH(VALUE INT 'VALUE'))      
    --   PRINT @BONUS_APPLIED    
                
    DECLARE @XMLSTRING XML 
    SET @XMLSTRING = (SELECT TOP 1 SPECIAL_PARAMS FROM #SPECIAL_PARAMS)          
    SET @BONUS_APPLIED = (SELECT TOP 1 T.ROWS.value('VALUE[1]', 'INT') FROM @XMLSTRING.nodes('/XML') T(ROWS))



    SET @CHEQUE_SUMM = (SELECT SUM(PRICE * QTY) FROM #CHEQUEINFO)      
          
    -- обрабатываем случай когда бонусами оплачивают весь чек с нецелой в рублях суммой       
    SET @DISCOUNT_VALUE = @BONUS_APPLIED      
          
    IF @DISCOUNT_VALUE > @CHEQUE_SUMM       
        SET @DISCOUNT_VALUE = @CHEQUE_SUMM      
            
    UPDATE #CHEQUEINFO SET DISCOUNT_VALUE =  @DISCOUNT_VALUE * PRICE * QTY / @CHEQUE_SUMM       
            
               
    --если по бонусной карте не списывали бонусы, то скидки не будет и она отсечется как нулевая.             
    --Из-за этого она не попадет в БД при синхронизации и по ней не сможет начислиться бонус                    
    IF(ISNULL(@BONUS_APPLIED,0) = 0)                                   
        INSERT INTO #CHEQUEITEM_DISCOUNT 
            ( 
                ID_LOT_GLOBAL, 
                ID_DISCOUNT2_GLOBAL, 
                VALUE 
            )
            SELECT              
                C.ID_LOT_GLOBAL, 
                @ID_DISCOUNT2_CARD_GLOBAL, 
                0               
                FROM #CHEQUEINFO C              
RETURN