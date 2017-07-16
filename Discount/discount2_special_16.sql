USE [Farma]
GO
/****** Object:  StoredProcedure [dbo].[DISCOUNT2_SPECIAL_16]    Script Date: 07/16/2017 19:38:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISCOUNT2_SPECIAL_16](
    @ID_DISCOUNT2_CARD_GLOBAL UNIQUEIDENTIFIER
)
AS
    DECLARE @SUMM MONEY -- доступная сумма скидки
    DECLARE @ROWCOUNT INT
    DECLARE @CHEQUES TABLE( -- табличная переменная
        ID_CHEQUE_GLOBAL UNIQUEIDENTIFIER,
        DATE_CHEQUE DATETIME,
        SUMM MONEY,
        HAS_DISCOUNT BIT
    )


    INSERT INTO @CHEQUES
    -- все строки чеков при продаже по дисконтной карте с таким типом 
    -- должны записываться как предоставленные скидки
    -- даже если скидка не была предоставлена (в этом случае должно быть записано значение 0)
    SELECT 
        C.ID_CHEQUE_GLOBAL, -- ИД чека
        C.DATE_CHEQUE,      -- дата чека
        C.SUMM,             -- сумма чека
        HAS_DISCOUNT = CASE WHEN SUM_DISCOUNT > 0 THEN 1 ELSE 0 END
    FROM DISCOUNT2_MAKE_ITEM DMI -- предостваленные скидки
    INNER JOIN CHEQUE_ITEM CI ON CI.ID_CHEQUE_ITEM_GLOBAL = DMI.ID_CHEQUE_ITEM_GLOBAL -- строки чеков
    INNER JOIN CHEQUE C ON C.ID_CHEQUE_GLOBAL = CI.ID_CHEQUE_GLOBAL -- чеки
    WHERE DMI.ID_DISCOUNT2_CARD_GLOBAL = @ID_DISCOUNT2_CARD_GLOBAL -- по дисконтной карте
    AND C.CHEQUE_TYPE = 'SALE' -- только продажи
    GROUP BY 
        C.ID_CHEQUE_GLOBAL, 
        C.DATE_CHEQUE,
        C.SUMM,
        CASE WHEN SUM_DISCOUNT > 0 THEN 1 ELSE 0 END

    SELECT @ROWCOUNT = COUNT(*) FROM @CHEQUES WHERE HAS_DISCOUNT=0
    
    IF (@ROWCOUNT=0 OR (@ROWCOUNT+1) % 16 <> 0) RETURN -- количество, выбранных чеков, должно быть кратно 16 и больше 0

    SELECT 
        @SUMM = SUM(A.SUMM) / 10.0000 -- 10 процентов от суммы последних 15 покупок
    FROM (SELECT TOP 15 -- 15 чеков
              SUMM      -- суммы
          FROM @CHEQUES
          WHERE HAS_DISCOUNT = 0
          ORDER BY DATE_CHEQUE DESC -- последние по дате
         ) A

    DECLARE C CURSOR FOR 
    SELECT
        ID_LOT_GLOBAL,  -- ИД партии (уникальен в пределах чека)
        SUM_WITH_DISCOUNT -- Пока скидка не предоставлена, это значение без скидки
    FROM #CHEQUEINFO
    
    DECLARE @ID_LOT_GLOBAL UNIQUEIDENTIFIER
    DECLARE @ITEM_SUM MONEY
    DECLARE @DISCOUNT_SUM MONEY

    SET @SUMM = ISNULL(@SUMM, 0) -- паранойя
    OPEN C
    WHILE 1=1 BEGIN
        FETCH NEXT FROM C INTO @ID_LOT_GLOBAL, @ITEM_SUM
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
    CLOSE C
    DEALLOCATE C
RETURN