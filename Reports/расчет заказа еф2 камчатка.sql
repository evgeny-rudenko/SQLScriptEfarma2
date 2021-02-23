
declare @DATE_FROM datetime
declare @DATE_TO datetime
declare @DAY_COUNT int
declare @ORDER_DAYS int
declare @ALL_STORES BIT
declare @store_id INT


set @DAY_COUNT = 30
set @ALL_STORES =1
set @store_id = 10

set @DATE_FROM = getdate ()-30
set @DATE_TO = GETDATE()

set @ORDER_DAYS = 30

SELECT  
--RTRIM(convert(char,(convert(datetime,@DATE_FROM,104)),104)) AS data1,
--RTRIM(convert(char,(convert(datetime,@DATE_TO,104)),104)) AS data2,
@DATE_FROM as data1,
@DATE_TO as data2,
    NAME_OLD = isnull( (select top 1 name_old from v_goods_old where v_goods_old.name = GOODS_NAME ), '') ,
	GOODS_NAME as name,
	--STORE_NAME,
	SUPPLIER_PRICE,
	RETAIL_PRICE,
	SOLD_ITEMS,
	SOLD_ITEMS_AVERAGE = SOLD_ITEMS / @DAY_COUNT,
	REMAIN_ITEMS=round(convert(money,REMAIN_ITEMS),2),
	REMAIN_DAYS = REMAIN_ITEMS / (SOLD_ITEMS / @DAY_COUNT),
	NEED_DAYS = @ORDER_DAYS - REMAIN_ITEMS / (SOLD_ITEMS / @DAY_COUNT),
--zakaz= 0, -- ceiling(convert(money,dbo.d2a_countzakaz(GOODS_NAME,SOLD_ITEMS,REMAIN_ITEMS,@ORDER_DAYS,@ORDER_DAYS_P,@DAY_COUNT),0)), 
zakaz= ceiling(convert(money,(@ORDER_DAYS - REMAIN_ITEMS / (SOLD_ITEMS / @DAY_COUNT)) * SOLD_ITEMS / @DAY_COUNT,0)),
contractor_name,
producer_name,
date_sup,
SUM_RETAIL=(SOLD_ITEMS*RETAIL_PRICE),

on_the_way=(
select sum(ii.quantity) from invoice_item ii,goods g where 
ii.id_goods=g.id_goods
and g.name=GOODS_NAME
and ii.id_invoice_global in 
(
select id_invoice_global from invoice where document_state='SAVE'
) group by g.name
)
 

--id_contractor
FROM 
(

select goods_name,
SUPPLIER_PRICE=max(SUPPLIER_PRICE),
RETAIL_PRICE=max(RETAIL_PRICE),
SOLD_ITEMS=sum(SOLD_ITEMS),
REMAIN_ITEMS=(select sum(quantity_rem) from lot where id_goods in (select id_goods from goods where name=goods_name)),
contractor_name=MAX(contractor_name),
producer_name=MAX(producer_name),
date_sup=(select max(convert(datetime,doc_date,104)) from lot where id_goods in (select id_goods from goods where name=goods_name))

 from
(
SELECT
	--L.ID_GOODS,
	L.ID_STORE,
p.name as producer_name,    
id_contractor=con.id_contractor,
contractor_name= CASE WHEN 1 = 1 AND LEN(MAX(ES.ES_NAME)) > 0 THEN MAX(ES.ES_NAME) ELSE MAX(con.name) END,
GOODS_NAME = CASE WHEN 1 = 1 AND LEN(MAX(ES.ES_NAME)) > 0 THEN MAX(ES.ES_NAME) ELSE MAX(G.NAME) END,
	STORE_NAME = MAX(S.NAME),
    SUPPLIER_PRICE = (SELECT MAX(L1.PRICE_SUP) FROM LOT L1
						INNER JOIN ALL_DOCUMENT AD ON AD.ID_DOCUMENT_GLOBAL = L1.ID_DOCUMENT
					WHERE L1.ID_GOODS = L.ID_GOODS
						AND L1.ID_STORE = L.ID_STORE
						AND AD.DOC_DATE = (SELECT MAX(AD1.DOC_DATE) FROM ALL_DOCUMENT AD1 
												INNER JOIN LOT L2 ON AD1.ID_DOCUMENT_GLOBAL = L2.ID_DOCUMENT											
											WHERE L2.ID_GOODS = L.ID_GOODS
											AND L2.ID_STORE = L.ID_STORE
											AND (AD1.ID_TABLE = 30 OR AD1.ID_TABLE = 2))),
    RETAIL_PRICE = (SELECT MAX(L1.PRICE_SAL) FROM LOT L1
						INNER JOIN ALL_DOCUMENT AD ON AD.ID_DOCUMENT_GLOBAL = L1.ID_DOCUMENT
					WHERE L1.ID_GOODS = L.ID_GOODS
						AND L1.ID_STORE = L.ID_STORE
						AND AD.DOC_DATE = (SELECT MAX(AD1.DOC_DATE) FROM ALL_DOCUMENT AD1 
												INNER JOIN LOT L2 ON AD1.ID_DOCUMENT_GLOBAL = L2.ID_DOCUMENT											
											WHERE L2.ID_GOODS = L.ID_GOODS
											AND L2.ID_STORE = L.ID_STORE
											AND (AD1.ID_TABLE = 30 OR AD1.ID_TABLE = 2))),
    SOLD_ITEMS = CAST(SUM((CASE WHEN LM.ID_TABLE = 12 THEN -1 * LM.QUANTITY_ADD ELSE LM.QUANTITY_SUB END) * SR.NUMERATOR / SR.DENOMINATOR) AS FLOAT),
    REMAIN_ITEMS = (SELECT SUM(QUANTITY_REM * SR.NUMERATOR / SR.DENOMINATOR) FROM LOT L1
						INNER JOIN SCALING_RATIO SR ON SR.ID_SCALING_RATIO = L1.ID_SCALING_RATIO
					WHERE L1.ID_GOODS = L.ID_GOODS AND L1.ID_STORE = L.ID_STORE)




FROM LOT_MOVEMENT LM
    LEFT JOIN LOT L ON L.ID_LOT_GLOBAL = LM.ID_LOT_GLOBAL
	LEFT JOIN SCALING_RATIO SR ON SR.ID_SCALING_RATIO = L.ID_SCALING_RATIO
    INNER JOIN GOODS G ON G.ID_GOODS = L.ID_GOODS
INNER JOIN contractor con ON con.id_contractor = L.id_supplier
INNER JOIN producer p ON p.ID_Producer = g.ID_producer    
INNER JOIN STORE S ON S.ID_STORE = L.ID_STORE



LEFT JOIN (
        SELECT ES_NAME = ES.NAME, ID_GOODS_GLOBAL = E2G.ID_GOODS_GLOBAL
        FROM ES_EF2 ES INNER JOIN ES_ES_2_GOODS E2G ON E2G.C_ES = ES.GUID_ES
        INNER JOIN (SELECT ID_ES_ES_2_GOODS = MAX(ID_ES_ES_2_GOODS) FROM ES_ES_2_GOODS
        GROUP BY ID_GOODS_GLOBAL) TAB ON TAB.ID_ES_ES_2_GOODS = E2G.ID_ES_ES_2_GOODS) ES ON ES.ID_GOODS_GLOBAL = G.ID_GOODS_GLOBAL
WHERE convert(datetime,LM.DATE_OP,104) BETWEEN @DATE_FROM AND @DATE_TO
	AND (@ALL_STORES = 1 OR L.ID_STORE IN (@store_id))
    AND LM.ID_TABLE IN (12, 21, 19)
	and L.ID_STORE not in (6,24) -- исключаем шамсу
--and l.vat_sup in (@NDS10,@NDS18,@NDS0)

GROUP BY l.id_lot_global,L.ID_GOODS,
 L.ID_STORE,p.name,con.id_contractor,con.name
) xx
WHERE xx.SOLD_ITEMS > 0 --AND @ORDER_DAYS - xx.REMAIN_ITEMS / (xx.SOLD_ITEMS / @DAY_COUNT) > 0 
--and REMAIN_ITEMS / (SOLD_ITEMS / @DAY_COUNT)<= @ORDER_DAYS_P
GROUP BY xx.goods_name
) b
WHERE SOLD_ITEMS > 0 

--AND @ORDER_DAYS - REMAIN_ITEMS / (SOLD_ITEMS / @DAY_COUNT) > 0 
--and REMAIN_ITEMS / (SOLD_ITEMS / @DAY_COUNT) <= @ORDER_DAYS_P
ORDER BY --
--SOLD_ITEMS*RETAIL_PRICE DESC,
GOODS_NAME
