USE [Farma]
GO
/****** Object:  StoredProcedure [dbo].[DISCOUNT2_SPECIAL_STICKER]    Script Date: 07/16/2017 19:51:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISCOUNT2_SPECIAL_STICKER]                   
    @ID_DISCOUNT2_CARD_GLOBAL UNIQUEIDENTIFIER                     
    AS      
BEGIN                      
      DECLARE @STICKERS_NUM INT       
      DECLARE @PARAMS VARCHAR(4000)  
      DECLARE @PARAM_TABLE TABLE (value VARCHAR(100))  
        
     SET @PARAMS =(SELECT TOP 1 SPECIAL_PARAMS FROM #SPECIAL_PARAMS)   
     
     INSERT INTO @PARAM_TABLE
     SELECT * FROM FN_PARSE_SEPARATED_STRING(@PARAMS,';')
     
   -- параметр - коды номенклатуры по АП или названия группы товаров
     SET  @STICKERS_NUM = ROUND((SELECT TOP 1 CHEQUE_SUM FROM #CHEQUEINFO ) / 200,0,1 )
   
  --суммарное количество целых пачек акционного товара  
  --ищем по коду товара и по названию группы
	 SELECT @STICKERS_NUM = @STICKERS_NUM  +
			 ISNULL(ROUND(CI.QTY * SC.NUMERATOR / SC.DENOMINATOR ,0,1),0)  
			 
			 FROM LOT L
			 JOIN #CHEQUEINFO CI ON CI.ID_LOT_GLOBAL = L.ID_LOT_GLOBAL  
			 JOIN SCALING_RATIO SC ON L.ID_SCALING_RATIO = SC.ID_SCALING_RATIO  
			 JOIN
			 -- найдем партии для акционных товаров чека
				 (SELECT  CI.ID_LOT_GLOBAL 
						FROM  GOODS G 
						 JOIN LOT L ON L.ID_GOODS = G.ID_GOODS  
						 JOIN #CHEQUEINFO CI ON CI.ID_LOT_GLOBAL = L.ID_LOT_GLOBAL  
						 JOIN GOODS_2_GROUP G2G ON G.ID_GOODS = G2G.ID_GOODS
						 JOIN GOODS_GROUP GG ON GG.ID_GOODS_GROUP = G2G.ID_GOODS_GROUP
						 JOIN @PARAM_TABLE PR ON     PR.VALUE = GG.NAME 
												  OR PR.VALUE = CAST(G.CODE AS VARCHAR)
						GROUP BY CI.ID_LOT_GLOBAL
				 ) 
				 T ON T.ID_LOT_GLOBAL = CI.ID_LOT_GLOBAL
			                          
    
	 IF(@STICKERS_NUM >0)  
	 UPDATE #CHEQUEINFO  
	   SET INFO_CASHIER = 'Выдать '+ CAST(@STICKERS_NUM AS VARCHAR)+' наклеек по акции '  
	RETURN	 
END