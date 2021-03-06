USE [eplus_work]
GO
/****** Object:  StoredProcedure [dbo].[USP_INTERNET_ORDER_SAVE_FromXml_ToRequest]    Script Date: 14.01.2019 20:10:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[USP_INTERNET_ORDER_SAVE_FromXml_ToRequest]
  @XML_DATA XML
AS
---------------------------------------------------------------------------------------------------
SET DATEFORMAT YMD
SET NOCOUNT ON
---------------------------------------------------------------------------------------------------
SELECT 
    [ID_INTERNET_ORDER_GLOBAL] = Tab.Col.value('ID_INTERNET_ORDER_GLOBAL[1]','UNIQUEIDENTIFIER'),
    [NUMBER_DOC] = Tab.Col.value('NUMBER_DOC[1]','VARCHAR(50)'),
    [DATE_CREATE] = Tab.Col.value('DATE_CREATE[1]','DATETIME'),
    [CUSTOMER_NAME] = Tab.Col.value('CUSTOMER_NAME[1]','varchar(255)'),
    [CUSTOMER_EMAIL] = Tab.Col.value('CUSTOMER_EMAIL[1]','varchar(255)'),
    [CUSTOMER_PHONE] = Tab.Col.value('CUSTOMER_PHONE[1]','varchar(255)'),
    [DELIVERY] = Tab.Col.value('DELIVERY[1]','int'),
    [DELIVERY_DATE] = Tab.Col.value('DELIVERY_DATE[1]','datetime'),
    [DELIVERY_ADDRESS] = Tab.Col.value('DELIVERY_ADDRESS[1]','varchar(255)'),
    [METRO] = Tab.Col.value('METRO[1]','varchar(255)'),
    [COMMENTS] = Tab.Col.value('COMMENTS[1]','varchar(255)'),
    [ERROR] = CAST(NULL AS varchar(255)),
    [INTERNET_ORDER_SOURCE] = Tab.Col.value('INTERNET_ORDER_SOURCE[1]','varchar(255)'),
    [COURIER_SERVICE] = Tab.Col.value('COURIER_SERVICE[1]','varchar(255)'),
    [BARCODE] = Tab.Col.value('BARCODE[1]', 'varchar(13)')
    INTO #TAB
    FROM @XML_DATA.nodes('/XML/ORDER') Tab(Col)

SELECT 
    [ID_INTERNET_ORDER_GLOBAL] = Tab.Col.value('../../ID_INTERNET_ORDER_GLOBAL[1]','uniqueidentifier'),
    [APCODE] = Tab.Col.value('APCODE[1]','varchar(50)'),
    [QUANTITY] = Tab.Col.value('QUANTITY[1]','int'),
    [PRICE] = Tab.Col.value('PRICE[1]','money'),
    [SC_PAID] = Tab.Col.value('SC_PAID[1]','money'),
    [INTERNAL_BARCODE] = Tab.Col.value('INTERNAL_BARCODE[1]','varchar(40)')
    INTO #TAB_ITEMS 
    FROM @XML_DATA.nodes('/XML/ORDER/ITEMS/ITEM') Tab(Col)

---------------------------------------------------------------------------------------------------
UPDATE #TAB SET DELIVERY_DATE = NULL FROM #TAB T WHERE DELIVERY_DATE <= '20000101'
UPDATE #TAB SET DELIVERY = CASE WHEN LEN(IsNULL(DELIVERY_ADDRESS,''))>0 THEN 1 ELSE 0 END FROM #TAB T

---------------------------------------------------------------------------------------------------
DECLARE @RETURN int 
DECLARE @ERROR_NUMBER int
DECLARE @ERROR_MESSAGE varchar(2000)
DECLARE @ROWCOUNT_INSERTED int
DECLARE @ROWCOUNT_FROM_XML int
DECLARE @ROWCOUNT_INSERTED_ITEM int
DECLARE @ROWCOUNT_FROM_XML_ITEM int
DECLARE @TransCount int
DECLARE @TransName varchar(50)

SET @ROWCOUNT_FROM_XML = (SELECT COUNT(*) FROM  #TAB) 
SET @ROWCOUNT_FROM_XML_ITEM = (SELECT COUNT(*) FROM  #TAB_ITEMS) 
SET @TransCount = @@TRANCOUNT
SET @TransName = NEWID()

BEGIN TRY
    ---------------------------------------------------------------------------------------------------
    BEGIN TRAN

    ---------------------------------------------------------------------------------------------------
    -- заказ должен содержать заполненое поле: ID_INTERNET_ORDER_GLOBAL
    ---------------------------------------------------------------------------------------------------
    IF EXISTS(SELECT 1 FROM #TAB WHERE ID_INTERNET_ORDER_GLOBAL IS NULL) RAISERROR('В документе есть заказ с незаданным полем: ID_INTERNET_ORDER_GLOBAL.',16,6) 

    ---------------------------------------------------------------------------------------------------
    -- в заказе не должно быть позиций с нулевым и отрицательным значением...
    ---------------------------------------------------------------------------------------------------
    IF EXISTS(SELECT 1 FROM #TAB WHERE ID_INTERNET_ORDER_GLOBAL IS NULL) RAISERROR('В документе есть заказ с незаданным полем: ID_INTERNET_ORDER_GLOBAL.',16,6) 
    IF EXISTS(SELECT 1 FROM #TAB_ITEMS  WHERE isNULL(QUANTITY,0)=0) RAISERROR('В документе есть позиции с нулевым количеством.',16,6) 
    IF EXISTS(SELECT 1 FROM #TAB_ITEMS  WHERE QUANTITY < 0) RAISERROR('В документе есть позиции с отрицательным количеством..',16,6) 

    ---------------------------------------------------------------------------------------------------
    DECLARE @DeleteFromInternetOrderRequest TABLE (ID_INTERNET_ORDER_GLOBAL UNIQUEIDENTIFIER)
    DECLARE @InsertToInternetOrderRequest TABLE (ID_INTERNET_ORDER_GLOBAL UNIQUEIDENTIFIER)

    ---------------------------------------------------------------------------------------------------
    -- Удалить записи, еще не загруженные, но которые хотят обновить.
    ---------------------------------------------------------------------------------------------------
    INSERT INTO @DeleteFromInternetOrderRequest (ID_INTERNET_ORDER_GLOBAL)
        SELECT TOP 1 IOR.ID_INTERNET_ORDER_GLOBAL
            FROM 
                #TAB T
                INNER JOIN INTERNET_ORDER_REQUEST [IOR] ON IOR.ID_INTERNET_ORDER_GLOBAL = T.ID_INTERNET_ORDER_GLOBAL
            WHERE
                IOR.DATE_UPLOAD IS NULL OR IOR.ERROR IS NOT NULL

    DELETE FROM INTERNET_ORDER_REQUEST_ITEM 
        WHERE ID_INTERNET_ORDER_GLOBAL IN (SELECT ID_INTERNET_ORDER_GLOBAL FROM @DeleteFromInternetOrderRequest)

    DELETE FROM INTERNET_ORDER_REQUEST
        WHERE ID_INTERNET_ORDER_GLOBAL IN (SELECT ID_INTERNET_ORDER_GLOBAL FROM @DeleteFromInternetOrderRequest)

    ---------------------------------------------------------------------------------------------------
    -- логика: 
    -- в INTERNET_ORDER_REQUEST добавлять только если такого заказа нет либо заказ с ошибкой.
    -- заказ в таблицу INTERNET_ORDER_REQUEST добавлять нельзя, если поле DATE_UPLOAD не NULL 
    ---------------------------------------------------------------------------------------------------
    update #TAB_ITEMS 
    Set #TAB_ITEMS.INTERNAL_BARCODE = isnull( (select top 1 INTERNAL_BARCODE from  LOT where QUANTITY_REM >0 and LOT.ID_GOODS = #TAB_ITEMS.[APCODE] and LOT.PRICE_SAL = #TAB_ITEMS.[PRICE]), '')
    
    
    INSERT INTO INTERNET_ORDER_REQUEST 
        (
           ID_INTERNET_ORDER_GLOBAL,
           NUMBER_DOC,
           DATE_CREATE,
           CUSTOMER_NAME,
           CUSTOMER_EMAIL,
           CUSTOMER_PHONE,
           DELIVERY,
           DELIVERY_DATE,
           DELIVERY_ADDRESS,
           METRO,
           COMMENTS,
           ERROR,
           INTERNET_ORDER_SOURCE,
           COURIER_SERVICE,
           BARCODE
        )
        OUTPUT inserted.ID_INTERNET_ORDER_GLOBAL INTO @InsertToInternetOrderRequest (ID_INTERNET_ORDER_GLOBAL)
        SELECT 
            T.ID_INTERNET_ORDER_GLOBAL,
            RTrim(LTrim(T.NUMBER_DOC)),
            T.DATE_CREATE,
            RTrim(LTrim(T.CUSTOMER_NAME)),
            RTrim(LTrim(T.CUSTOMER_EMAIL)),
            RTrim(LTrim(T.CUSTOMER_PHONE)),
            T.DELIVERY,
            T.DELIVERY_DATE,
            RTrim(LTrim(T.DELIVERY_ADDRESS)),
            T.METRO,
            RTrim(LTrim(T.COMMENTS)),
            [ERROR]=NULL,
            T.INTERNET_ORDER_SOURCE,
            T.COURIER_SERVICE,
            T.BARCODE
            FROM 
                #TAB T
                LEFT JOIN INTERNET_ORDER_REQUEST [IOR] ON IOR.ID_INTERNET_ORDER_GLOBAL = T.ID_INTERNET_ORDER_GLOBAL
            WHERE
                IOR.ID_INTERNET_ORDER_GLOBAL IS NULL

    -------------------------------------------------------
    SET @ROWCOUNT_INSERTED = @@ROWCOUNT

    -------------------------------------------------------
    -- логирую заявку пользователя на товар (в т.ч. цена с сайта на которую смотре покупатель)
    -------------------------------------------------------
    ;WITH cteGoodsCodeList AS
    (
        SELECT 
            G.CODE,  
            N = ROW_NUMBER() OVER (PARTITION BY G.CODE ORDER BY CASE WHEN G.DATE_EXCLUDED IS NULL THEN 0 ELSE 1 END, G.DATE_EXCLUDED DESC, G.DATE_MODIFIED DESC, G.ID_GOODS),
            G.ID_GOODS
            FROM GOODS G
    ),
    cteActualGoodsCodeList AS
    (
        SELECT 
            t.CODE,  
            t.ID_GOODS
            FROM cteGoodsCodeList t
            WHERE t.N = 1
    )
    INSERT INTO INTERNET_ORDER_REQUEST_ITEM (ID_INTERNET_ORDER_REQUEST_ITEM, ID_INTERNET_ORDER_GLOBAL, ID_GOODS, APCODE, QUANTITY, PRICE, SC_PAID, INTERNAL_BARCODE)
        SELECT
            ID_INTERNET_ORDER_ITEM_GLOBAL=newid(),
            T.ID_INTERNET_ORDER_GLOBAL,
            T.[APCODE],--G.ID_GOODS,
            T.[APCODE],
            SUM(T.QUANTITY),
            T.[PRICE],
            T.[SC_PAID],
            T.[INTERNAL_BARCODE]
            
            FROM 
                #TAB_ITEMS T
                INNER JOIN @InsertToInternetOrderRequest L ON T.ID_INTERNET_ORDER_GLOBAL = L.ID_INTERNET_ORDER_GLOBAL
                LEFT JOIN cteActualGoodsCodeList G ON G.CODE = T.APCODE
            GROUP BY
                T.ID_INTERNET_ORDER_GLOBAL,
                G.ID_GOODS,
                T.[APCODE],
                T.[PRICE],
                T.[SC_PAID],
                T.[INTERNAL_BARCODE]
    -------------------------------------------------------
    SET @ROWCOUNT_INSERTED_ITEM = @@ROWCOUNT
    
    --------------------------------------------------------------------------------------
    COMMIT TRAN
    SET @RETURN = 0
    ---------------------------------------------------------

END TRY
BEGIN CATCH
  ---------------------------------------------------------
  ROLLBACK TRAN
  ---------------------------------------------------------
  SET @RETURN = -1
  SET @ERROR_MESSAGE = ERROR_MESSAGE() 
  SET @ERROR_NUMBER = ERROR_NUMBER() 
  ---------------------------------------------------------
  RAISERROR(@ERROR_MESSAGE,18,0) --NOWAIT
  ---------------------------------------------------------
END CATCH

---------------------------------------------------------------------------------------------------
SELECT 
  [RETURN] = @RETURN,
  [ERROR_NUMBER] = @ERROR_NUMBER,
  [ERROR_MESSAGE] = @ERROR_MESSAGE,
  [ROWCOUNT_INSERTED] = @ROWCOUNT_INSERTED,
  [ROWCOUNT_FROM_XML] = @ROWCOUNT_FROM_XML,
  [ROWCOUNT_INSERTED_ITEM] = @ROWCOUNT_INSERTED_ITEM,
  [ROWCOUNT_FROM_XML_ITEM] = @ROWCOUNT_FROM_XML_ITEM

---------------------------------------------------------------------------------------------------
RETURN @RETURN
---------------------------------------------------------------------------------------------------