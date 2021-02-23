 
 If  Exists(Select * from tempdb..sysobjects Where id = object_id('tempdb.dbo.#ost'))
     drop table #ost
 If  Exists(Select * from tempdb..sysobjects Where id = object_id('tempdb.dbo.#unload_ost'))
     drop table #unload_ost

declare @date11 datetime
declare @date22 datetime
declare @id_store int

set @date11 = '01.01.2021'
set @date22 = '01.01.2021'
set @id_store =  1 --!store!


/*
 If  Exists(Select * from tempdb..sysobjects Where id = object_id('tempdb.dbo.#ost'))
     drop table #ost
 If  Exists(Select * from tempdb..sysobjects Where id = object_id('tempdb.dbo.#unload_ost'))
     drop table #unload_ost

declare @date11 datetime
declare @date22 datetime
declare @id_store int

set @date11 = '31.01.2019'
set @date22 = '01.02.2019'
set @id_store =  1
*/

EXEC DBO.USP_RANGE_DAYS NULL, @date11 OUT
EXEC DBO.USP_RANGE_NORM NULL, @date11 OUT



SELECT  L.ID_LOT_GLOBAL,SUM(LM.QUANTITY_ADD - LM.QUANTITY_SUB - LM.QUANTITY_RES) AS OST INTO #OST
FROM LOT L INNER JOIN LOT_MOVEMENT LM ON L.ID_LOT_GLOBAL=LM.ID_LOT_GLOBAL
WHERE LM.DATE_OP <= @date11 GROUP BY L.ID_LOT_GLOBAL
SELECT D_TYPE='0',
store_id_global = (select id_store_global from STORE where store.id_store = L.id_store),
store_name = (select NAME from STORE where store.id_store = L.id_store),
N_DOK=ISNULL(L.INVOICE_NUM,''),
D_DOK=REPLACE(ISNULL(CONVERT(VARCHAR,DATEADD(DAY,-1,CAST(@date11 AS DATETIME)),104),''),'.',''),
supplier_id_global = sup.ID_CONTRACTOR_GLOBAL,
Supplier=SUP.NAME,
Supplier_INN = ISNULL(SUP.INN,''),
N_KKM='',N_Chek = '',
FIO_Chek ='',Disk_T = '',Disk_Sum = '',Sum_Zak = '',Sum_Rozn = '',PP_Teg = '',
--Drug_Code = LEFT(CAST(G.ID_GOODS_GLOBAL AS VARCHAR (40)),13),
Drug_Code = G.ID_GOODS_GLOBAL,
Drug_Name = G.NAME, 
--Drug_Producer_Code = LEFT(CAST(P.ID_PRODUCER_GLOBAL AS VARCHAR (40)),13),
Drug_Producer_Code = convert(varchar,(select id_producer from goods where id_goods=l.ID_GOODS)) ,
Drug_Producer_Name = P.NAME,
Drug_Producer_Country = C.NAME, 
Drug_Bar = ISNULL(BC.MAXCODE,''),
Cena_Zak = REPLACE(CAST(ROUND(L.PRICE_SUP* SR.DENOMINATOR /SR.NUMERATOR,2) AS VARCHAR),'.',','),
Cena_Rozn =  REPLACE(CAST(ROUND(L.PRICE_SAL* SR.DENOMINATOR /SR.NUMERATOR,2) AS VARCHAR),'.',','),
Quant = REPLACE(CAST(CAST(O.OST*1.00* SR.NUMERATOR /SR.DENOMINATOR AS DECIMAL(15,6)) AS VARCHAR),'.',','),
Serial = ISNULL(S.SERIES_NUMBER,''),
Godn = REPLACE(ISNULL(CONVERT(VARCHAR,S.BEST_BEFORE,104),''),'.',''),
--Barecode = LEFT(CAST(L.ID_LOT_GLOBAL AS VARCHAR(40)),13)
Barecode = LEFT(CAST(L.INTERNAl_BARCODE AS VARCHAR(40)),13)
INTO #UNLOAD_OST
FROM LOT L INNER JOIN #OST O ON L.ID_LOT_GLOBAL=O.ID_LOT_GLOBAL 
INNER JOIN GOODS G ON G.ID_GOODS=L.ID_GOODS INNER JOIN PRODUCER P ON P.ID_PRODUCER=G.ID_PRODUCER INNER JOIN COUNTRY C ON C.ID_COUNTRY=P.ID_COUNTRY
INNER JOIN CONTRACTOR SUP ON SUP.ID_CONTRACTOR=L.ID_SUPPLIER INNER JOIN SCALING_RATIO SR ON SR.ID_SCALING_RATIO = L.ID_SCALING_RATIO LEFT JOIN SERIES S ON S.ID_SERIES = L.ID_SERIES
LEFT JOIN (SELECT ID_GOODS,MAX(CODE) AS MAXCODE FROM BAR_CODE WHERE DATE_DELETED IS NULL AND LEN(CODE) IN (8,13) GROUP BY ID_GOODS ) BC ON L.ID_GOODS=BC.ID_GOODS
WHERE  1=1 
--AND L.ID_STORE IN (@id_store) 
AND O.OST>0 

select * from #UNLOAD_OST