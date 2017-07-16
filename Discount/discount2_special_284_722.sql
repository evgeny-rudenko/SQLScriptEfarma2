USE [Farma]
GO
/****** Object:  StoredProcedure [dbo].[DISCOUNT2_SPECIAL_284_722]    Script Date: 07/16/2017 19:48:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISCOUNT2_SPECIAL_284_722]
    @ID_DISCOUNT2_CARD_GLOBAL UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @ID_LOT_GLOBAL UNIQUEIDENTIFIER   
    DECLARE @ID_GOODS BIGINT
    DECLARE @DISCOUNT MONEY
    DECLARE @CNT INT
    DECLARE @SUMM MONEY
    DECLARE @ITEM_SUM MONEY
    DECLARE @DISCOUNT_SUM MONEY   
    
    SELECT
        T.ID_GOODS,
        T.CODE,    
        T.QTY,
        T.PRICE,
        DISCOUNT = ROUND((T.PRICE * 15.00 / 100.00), 2),
        CNT = CAST(FLOOR(T.QTY / 3) AS INT),
        T.POSITIONS
    INTO #DATA    
    FROM
    (
        SELECT 
            G.ID_GOODS, G.CODE, QTY = SUM(C.QTY), PRICE = MAX(C.PRICE), POSITIONS = COUNT(G.CODE)
        FROM #CHEQUEINFO C
        INNER JOIN LOT L ON L.ID_LOT_GLOBAL = C.ID_LOT_GLOBAL
        INNER JOIN GOODS G ON G.ID_GOODS = L.ID_GOODS
        INNER JOIN SCALING_RATIO SR ON  SR.ID_SCALING_RATIO = L.ID_SCALING_RATIO
        WHERE   1 = 1
                AND SR.NUMERATOR = 1
                AND SR.DENOMINATOR = 1
        GROUP BY G.ID_GOODS, G.CODE
        HAVING SUM(C.QTY) >= 3
    ) AS T

    --В чеке присутсвует по одной партии одного товара
    UPDATE #CHEQUEINFO
    SET 
        SUM_WITH_DISCOUNT = SUM_WITH_DISCOUNT - (D.DISCOUNT * D.CNT),
        DISCOUNT_VALUE = D.DISCOUNT * D.CNT
    FROM #CHEQUEINFO C
    INNER JOIN LOT L ON L.ID_LOT_GLOBAL = C.ID_LOT_GLOBAL
    INNER JOIN #DATA D ON D.ID_GOODS = L.ID_GOODS
    WHERE D.POSITIONS = 1
   
    DECLARE C CURSOR FOR 
        SELECT D.ID_GOODS, D.DISCOUNT, D.CNT 
        FROM #DATA D
        WHERE D.POSITIONS > 1   
    OPEN C
    WHILE 1 = 1
    BEGIN
        FETCH NEXT FROM C INTO @ID_GOODS, @DISCOUNT, @CNT
        IF (@@FETCH_STATUS != 0) BREAK
        
        SET @SUMM = @DISCOUNT * @CNT --сумма скидки в разрезе товара
               
        DECLARE D CURSOR FOR     
        SELECT 
            R.ID_LOT_GLOBAL,  -- ИД партии (уникальен в пределах чека)
            R.SUM_WITH_DISCOUNT -- Пока скидка не предоставлена, это значение без скидки 
        FROM #CHEQUEINFO R
        INNER JOIN LOT L ON L.ID_LOT_GLOBAL = R.ID_LOT_GLOBAL
        WHERE L.ID_GOODS = @ID_GOODS
        ORDER BY R.PRICE DESC
          
        OPEN D
        WHILE 1=1 BEGIN
            FETCH NEXT FROM D INTO @ID_LOT_GLOBAL, @ITEM_SUM
            IF (@@FETCH_STATUS<>0) BREAK
            SET @DISCOUNT_SUM = CASE WHEN @ITEM_SUM>=@SUMM THEN @SUMM -- если сумма по строке больше или равна сумме скидки, то сумма скидки равна всей достуной сумме
                                     ELSE @ITEM_SUM                   -- иначе сумма скидки равна сумме по строке
                                END -- сумма скидки
            UPDATE CI SET
                SUM_WITH_DISCOUNT = @ITEM_SUM - @DISCOUNT_SUM,  -- сумма со скидкой = сумма без скидки - сумма скидки
                DISCOUNT_VALUE = @DISCOUNT_SUM                  -- сумма скидки
            FROM #CHEQUEINFO CI
            WHERE CI.ID_LOT_GLOBAL = @ID_LOT_GLOBAL
                    
            SET @SUMM = @SUMM - @DISCOUNT_SUM                   -- уменьшаем доступную сумму скидки на значение скидки
        END    
        CLOSE D
        DEALLOCATE D
    END
    CLOSE C
    DEALLOCATE C
END