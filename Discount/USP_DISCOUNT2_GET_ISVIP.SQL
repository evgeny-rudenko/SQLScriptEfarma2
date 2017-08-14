/****** Object:  StoredProcedure [dbo].[USP_DISCOUNT2_GET_ISVIP]    Script Date: 08/12/2017 13:06:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_DISCOUNT2_GET_ISVIP]
    @VALUE_IN VARCHAR(4000)
AS
  -- Проверяем - отсканирована ли хоть одна дисконтная карта
  -- Использовать в поверках системы дисконтирования акции
  IF 
    (
         EXISTS 
        (
            SELECT NULL 
            FROM #CCI_CARDS C
            INNER JOIN DISCOUNT2_CARD DC ON DC.ID_DISCOUNT2_CARD_GLOBAL = C.ID_DISCOUNT2_CARD_GLOBAL
            INNER JOIN DISCOUNT2_MEMBER DM ON DM.ID_DISCOUNT2_MEMBER_GLOBAL = DC.ID_DISCOUNT2_MEMBER_GLOBAL
           -- тут вставить проверку на конкретный тип карты
        )
    ) begin
			SELECT top 1
		    VALUE = CONVERT(VARCHAR(4000), CONVERT(BIT, 1))
			FROM LOT
  
	end 
   

RETURN
