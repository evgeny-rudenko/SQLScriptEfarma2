SELECT        TOP (100) PERCENT
 dbo.LOT.ID_GOODS, 					--код товара 
 dbo.GOODS.NAME, 					-- наименование
 dbo.PRODUCER.NAME AS prod_name, 			-- производитель 
 dbo.COUNTRY.NAME AS cnt_name, 				-- страна
 dbo.LOT.QUANTITY_REM, 					-- остаток в текущей единице
 dbo.LOT.PRICE_SAL, 					-- розничная цена с НДС
 dbo.LOT.INTERNAL_BARCODE, 				-- внутренний ШК партии
 dbo.STORE.NAME AS Sklad, 				--- наименование склада
 dbo.GOODS.IMPORTANT,  					--- ЖВ препарат или не очень
 dbo.SERIES.BEST_BEFORE, 				-- срок годности
 dbo.SERIES.SERIES_NUMBER , 				-- серия 
 dbo.LOT.PRICE_PROD,					---- цена производителя без НДС
 --dbo.LOT.PVAT_PROD,
 --dbo.LOT.VAT_PROD, 
 dbo.LOT.PRICE_SUP, 					-- цена поставщика  
 dbo.LOT.PVAT_SUP, 					-- НДС поставщика Рубли
 dbo.LOT.VAT_SUP, 					---ставка НДС поставщика 
 dbo.LOT.VAT_SAL, 					--- ставка НДС розничная
 dbo.LOT.PVAT_SAL, 					-- ндс розничная (Рубли)
 dbo.LOT.REGISTER_PRICE, 				-- зарегистрированная цена если есть (без ндс)
 dbo.LOT.VAT_SUP, 
 dbo.SCALING_RATIO.DENOMINATOR, 			-- Единица делитель
 dbo.SCALING_RATIO.NUMERATOR, 				-- Единица делимое
 dbo.REG_CERT.NAME AS Cert 				--- серитфикат







FROM            dbo.LOT INNER JOIN
                         dbo.GOODS ON dbo.LOT.ID_GOODS = dbo.GOODS.ID_GOODS INNER JOIN
                         dbo.PRODUCER ON dbo.GOODS.ID_PRODUCER = dbo.PRODUCER.ID_PRODUCER INNER JOIN
                         dbo.STORE ON dbo.LOT.ID_STORE = dbo.STORE.ID_STORE INNER JOIN
                         dbo.SCALING_RATIO ON dbo.LOT.ID_SCALING_RATIO = dbo.SCALING_RATIO.ID_SCALING_RATIO AND 
                         dbo.GOODS.ID_GOODS = dbo.SCALING_RATIO.ID_GOODS LEFT OUTER JOIN
                         dbo.SERIES ON dbo.LOT.ID_SERIES = dbo.SERIES.ID_SERIES AND dbo.GOODS.ID_GOODS = dbo.SERIES.ID_GOODS LEFT OUTER JOIN
                         dbo.REG_CERT ON dbo.LOT.ID_REG_CERT_GLOBAL = dbo.REG_CERT.ID_REG_CERT_GLOBAL LEFT OUTER JOIN
                         dbo.COUNTRY ON dbo.PRODUCER.ID_COUNTRY = dbo.COUNTRY.ID_COUNTRY
WHERE        (dbo.LOT.QUANTITY_REM > 0) 
and  dbo.STORE.NAME = 'Основной'   ---- подставить нужное наименование 
/*AND (dbo.LOT.ID_SCALING_RATIO IN
                             (SELECT        ID_SCALING_RATIO
                               FROM            dbo.SCALING_RATIO AS SCALING_RATIO_1
                               WHERE        (NUMERATOR = 1) AND (DENOMINATOR = 1)))*/ -- если нужно будет выгрузить только целые, то убрать комментирование
ORDER BY dbo.GOODS.NAME

/*
select ID_STORE, NAME from STORE    ---- список складов

*/


/*
select count( *) from lot
where (dbo.LOT.QUANTITY_REM > 0) */ -- проверка по количеству партий -все выгрузилось или нет
