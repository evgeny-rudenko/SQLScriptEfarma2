/*
Список КИЗов по накладным. 
Все данные по поставкам в одной плоской таблице 

delete from KIZ_2_DOCUMENT_ITEM
where ID_KIZ_GLOBAL in (
select ID_KIZ_GLOBAL from kiz 
where kiz.GTIN_SGTIN in (
select gtin_sgtin from v_invoice_kiz
where mnemocode = '300/ПН-00000079')
and kiz.ID_KIZ_GLOBAL not in (
select id_kiz_global  from v_invoice_kiz
where mnemocode = '300/ПН-00000079')
)

delete from kiz
where kiz.GTIN_SGTIN in (
select gtin_sgtin from v_invoice_kiz
where mnemocode = '300/ПН-00000079')
and kiz.ID_KIZ_GLOBAL not in (
select id_kiz_global  from v_invoice_kiz
where mnemocode = '300/ПН-00000079')
*/

CREATE VIEW [dbo].[V_INVOICE_KIZ]
AS
SELECT        dbo.INVOICE.ID_INVOICE_GLOBAL, dbo.INVOICE.DOCUMENT_DATE, dbo.INVOICE.MNEMOCODE, dbo.INVOICE.INCOMING_DATE, dbo.INVOICE.INCOMING_NUMBER, 
                         CASE WHEN K.[STATE] = 'SAVE' THEN '0' WHEN K.[STATE] = 'HOLD' THEN '2' WHEN K.[STATE] = 'PART' THEN '3' WHEN K.[STATE] = 'PROC' THEN '3' WHEN K.[STATE] = 'STOP' THEN '1' WHEN K.[STATE] = 'EXIT' THEN '1' ELSE
                          '0' END AS IS_ERROR, CASE WHEN KI.IS_READY = 1 THEN '3' WHEN KM.ID_KIZ_MOVE IS NULL THEN '0' WHEN ISNULL(KM.ERROR, '') != '' THEN '1' ELSE '2' END AS KIZ_MOVE_STATE, 
                         CASE WHEN KI.IS_READY = 0 THEN K.ID_ERROR ELSE NULL END AS ERROR_INNER, CASE WHEN KI.IS_READY = 0 THEN DBO.FN_KIZ_ERROR_INNER_NOTE(K.ID_ERROR) ELSE NULL END AS ERROR_INNER_NAME, 
                         CASE WHEN KI.IS_READY = 0 AND ISNULL(KM.ERROR, '') != '' THEN KM.ID_ERROR ELSE NULL END AS ERROR_OUTER, 
                         CASE WHEN KI.IS_READY = 0 THEN CASE WHEN KM.ERROR LIKE '%Документ поставлен в очередь на отправку в МДЛП%' THEN 'Документ поставлен в очередь на отправку в МДЛП' ELSE KM.ERROR END ELSE NULL 
                         END AS ERROR_OUTER_NAME, K.STATE, CASE WHEN KM.ID_KIZ_MOVE IS NULL THEN 'В обработке' WHEN ISNULL(KM.[STATE], '') 
                         = 'OK' THEN 'Успешно' ELSE CASE WHEN KM.ERROR LIKE '%Документ поставлен в очередь на отправку в МДЛП%' THEN 'Документ поставлен в очередь на отправку в МДЛП' ELSE KM.ERROR END END AS KIZ_STATE,
                          K.ID_KIZ, K.ID_KIZ_GLOBAL, II.ID_INVOICE_ITEM_GLOBAL, K.BARCODE AS KIZ, CASE LEFT(K.BARCODE, 3) WHEN 'MDE' THEN CAST(CAST(N'' AS XML ).value('xs:base64Binary(sql:column("K.BARCODE"))', 'VARBINARY(MAX)') 
                         AS VARCHAR(MAX)) ELSE K.BARCODE END AS BARCODE, K.GTIN_SGTIN, K.GTIN, K.SGTIN, K.TNVED4, K.BATCH, K.BEST_BEFORE, K.DATE_TO, K.ID_ERROR, KM.DOCUMENT_OUT_ID, II.ID_INVOICE_ITEM, II.ID_INVOICE, 
                         II.ID_INVOICE_GLOBAL AS Expr1, II.ID_GOODS, G.NAME AS GOODS_NAME, G.MNEMOCODE AS GOODS_MNEMOCODE, G.IMPORTANT, II.register_price, G.MAX_PRICE_SAL, II.QUANTITY, II.ORDER_NUMBER, 
                         II.ID_SCALING_RATIO, ISNULL(SC.alias, CAST(SC.NUMERATOR AS VARCHAR) + '/' + CAST(SC.DENOMINATOR AS VARCHAR) + ' ' + U.NAME) AS SCALING_RATIO_NAME, P.ID_PRODUCER, P.NAME AS PRODUCER_NAME, 
                         C.NAME AS COUNTRY_NAME, II.PRODUCER_PRICE, II.SUPPLIER_VAT_PER_UNIT, II.SUPPLIER_ADPRICE, II.SUPPLIER_PRICE, II.SUPPLIER_VAT, II.SUPPLIER_PRICE_VAT, II.SUPPLIER_SUM, II.SUPPLIER_VAT_SUM, 
                         II.SUPPLIER_SUM_VAT, II.RETAIL_ADPRICE, II.RETAIL_PRICE, II.RETAIL_VAT, II.RETAIL_VAT_SUM, II.RETAIL_SUM, II.RETAIL_SUM_VAT, II.RETAIL_PRICE_VAT, II.GTD_NUMBER, II.BAR_CODE, II.BREAKAGE_QTY, 
                         II.WASTE_QTY, II.SHORTFALL_QTY, II.OTHER_QTY, II.ID_GOS_CONTRACT_GOODS, II.BOX, G.CODE AS GOODS_CODE, G.IS_WEIGHT, II.COST, II.ID_AUCTION_ORDER, KI.IS_READY, ISNULL(K.DATE_ENTER_CIRCULATION, 
                         II.DATE_ENTER_CIRCULATION) AS DATE_ENTER_CIRCULATION
FROM            dbo.KIZ AS K WITH (NOLOCK) INNER JOIN
                         dbo.KIZ_2_DOCUMENT_ITEM AS KDI WITH (NOLOCK) ON KDI.ID_KIZ_GLOBAL = K.ID_KIZ_GLOBAL INNER JOIN
                         dbo.INVOICE_ITEM AS II WITH (NOLOCK) ON II.ID_INVOICE_ITEM_GLOBAL = KDI.ID_DOCUMENT_ITEM_ADD INNER JOIN
                         dbo.LOT AS L WITH (NOLOCK) ON L.ID_LOT =
                             (SELECT        TOP (1) ID_LOT
                               FROM            dbo.LOT AS _L WITH (NOLOCK)
                               WHERE        (ID_DOCUMENT = II.ID_INVOICE_GLOBAL) AND (ID_DOCUMENT_ITEM = II.ID_INVOICE_ITEM_GLOBAL)
                               ORDER BY ID_LOT) INNER JOIN
                         dbo.MV_GOODS AS G WITH (NOLOCK) ON G.ID_GOODS = II.ID_GOODS INNER JOIN
                         dbo.PRODUCER AS P WITH (NOLOCK) ON G.ID_PRODUCER = P.ID_PRODUCER INNER JOIN
                         dbo.SCALING_RATIO AS SC WITH (NOLOCK) ON II.ID_SCALING_RATIO = SC.ID_SCALING_RATIO INNER JOIN
                         dbo.UNIT AS U WITH (NOLOCK) ON U.ID_UNIT = SC.ID_UNIT INNER JOIN
                         dbo.COUNTRY AS C WITH (NOLOCK) ON C.ID_COUNTRY = P.ID_COUNTRY INNER JOIN
                         dbo.INVOICE WITH (NOLOCK) ON II.ID_INVOICE_GLOBAL = dbo.INVOICE.ID_INVOICE_GLOBAL LEFT OUTER JOIN
                         dbo.KIZ_ITEM AS KI WITH (NOLOCK) ON KI.ID_KIZ_ITEM =
                             (SELECT        TOP (1) ID_KIZ_ITEM
                               FROM            dbo.KIZ_ITEM AS _KI WITH (NOLOCK)
                               WHERE        (ID_DOCUMENT = II.ID_INVOICE_GLOBAL) AND (ID_DOCUMENT_ITEM = II.ID_INVOICE_ITEM_GLOBAL) AND (ID_KIZ_GLOBAL = K.ID_KIZ_GLOBAL) AND (ID_LOT_GLOBAL = L.ID_LOT_GLOBAL)
                               ORDER BY ID_KIZ_ITEM DESC) LEFT OUTER JOIN
                         dbo.KIZ_MOVE AS KM WITH (NOLOCK) ON KM.ID_KIZ_ITEM_GLOBAL = KI.ID_KIZ_ITEM_GLOBAL AND KM.ID_KIZ_MOVE =
                             (SELECT        TOP (1) ID_KIZ_MOVE
                               FROM            dbo.KIZ_MOVE AS _KM WITH (NOLOCK)
                               WHERE        (ID_KIZ_ITEM_GLOBAL = KI.ID_KIZ_ITEM_GLOBAL)
                               ORDER BY ID_KIZ_MOVE DESC)
GO
