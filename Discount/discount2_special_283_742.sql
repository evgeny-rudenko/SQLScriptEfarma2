USE [Farma]
GO
/****** Object:  StoredProcedure [dbo].[DISCOUNT2_SPECIAL_283_742]    Script Date: 07/16/2017 19:47:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISCOUNT2_SPECIAL_283_742]
    @ID_DISCOUNT2_CARD_GLOBAL UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE @DM  VARCHAR(16)
    DECLARE @SL1 VARCHAR(16)
    DECLARE @SL2 VARCHAR(16)
    DECLARE @SL3 VARCHAR(16)

    SET @DM  = '70196' --Дринкин Мэйт
    SET @SL1 = '22672' --Салонпас пластырь обезболивающий 6,5х4,2см №10
    SET @SL2 = '22674' --Салонпас пластырь обезболивающий большой 13х8,4см №2
    SET @SL3 = '22675' --Салонсип пластырь гелевый обезболивающий 14х10см №3

    SELECT 
        T.CODE,       
        T.QTY    
    INTO #T
    FROM
    (   --Группируем, потому что товар может быть с разных партий       
        SELECT G.CODE, PRICE = MAX(C.PRICE), QTY = SUM(C.QTY)
        FROM #CHEQUEINFO AS C
        INNER JOIN LOT AS L ON L.ID_LOT_GLOBAL = C.ID_LOT_GLOBAL
        INNER JOIN GOODS AS G ON G.ID_GOODS = L.ID_GOODS
        GROUP BY G.CODE
    ) AS T

    --выполняется условие
    IF EXISTS
    (
        SELECT 1
        FROM #T
        WHERE 1 = 1
        AND EXISTS (SELECT * FROM #T WHERE CODE = @DM AND QTY >= 2)
        AND EXISTS (SELECT * FROM #T WHERE CODE IN (@SL1, @SL2, @SL3))
    )
    BEGIN
        UPDATE #CHEQUEINFO
        SET 
            --сумма со скидкой
            SUM_WITH_DISCOUNT = SUM_WITH_DISCOUNT - T.PRICE,
            --размер скидки - цена самого дорогого Салонпаса
            DISCOUNT_VALUE = T.PRICE 
        FROM #CHEQUEINFO AS C
        INNER JOIN
        (   
            --Определяем партию где есть Салонпас с максимальной ценой
            SELECT TOP 1 C.ID_LOT_GLOBAL, C.PRICE
            FROM #CHEQUEINFO AS C
            INNER JOIN LOT AS L ON L.ID_LOT_GLOBAL = C.ID_LOT_GLOBAL
            INNER JOIN GOODS AS G ON G.ID_GOODS = L.ID_GOODS
            WHERE G.CODE IN (@SL1, @SL2, @SL3)
            ORDER BY PRICE DESC
        ) AS T ON T.ID_LOT_GLOBAL = c.ID_LOT_GLOBAL
    END

END