/*Наименование юридического лица	
ИНН юридического лица	
Дата формирования остатков	
Торговая точка
 код
 	Адрес торговой точки
		Поставщик ИНН	
		Поставщик КПП	
		Поставщик
			Код товара	
			Штрих-код
				Название товара	
				Фирма - производитель	Кол-во	Сумма закупки с НДС*/

				--Остатки по складам
declare @dat datetime
set @dat = CAST( GETDATE () AS DATE)


select * from (
select 
ИНН = isnull( (select top 1 INN from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = STORE.ID_CONTRACTOR ) , ''),
Дата = @dat ,
НаименованиеСклада = store.NAME , 
КодСклада = STORE.ID_STORE ,
Адрес = isnull( (select top 1 ADDRESS from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = STORE.ID_CONTRACTOR ) , ''),
ПоставщикИНН =isnull ((select inn from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = LOT.ID_SUPPLIER), '') ,
ПоставщикКПП =isnull ((select KPP from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = LOT.ID_SUPPLIER), '') ,
Поставщик =isnull ((select NAME from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = LOT.ID_SUPPLIER), '') ,
Номенклатура = GOODS.NAME, --goods.ID_GOODS_GLOBAL,
Количество = ( SELECT 	AMOUNT_OST = SUM(LM2.QUANTITY_ADD - LM2.QUANTITY_SUB)
FROM LOT_movement LM2
INNER JOIN LOT L2 ON L2.ID_LOT_GLOBAL = LM2.ID_LOT_GLOBAL
WHERE
LM2.ID_LOT_GLOBAL=LOT.id_lot_global  and 
(lm2.QUANTITY_ADD!=0 or lm2.QUANTITY_SUB!=0)   
and
LM2.DATE_OP <=@dat
GROUP BY lm2.ID_LOT_GLOBAL
--having sum(LM2.QUANTITY_ADD - LM2.QUANTITY_SUB) >0
) ,
СуммаОпт = ( SELECT 	AMOUNT_OST = SUM(LM2.QUANTITY_ADD - LM2.QUANTITY_SUB)
FROM LOT_movement LM2
INNER JOIN LOT L2 ON L2.ID_LOT_GLOBAL = LM2.ID_LOT_GLOBAL
WHERE
LM2.ID_LOT_GLOBAL=LOT.id_lot_global  and 
(lm2.QUANTITY_ADD!=0 or lm2.QUANTITY_SUB!=0)   
and
LM2.DATE_OP <=@dat
GROUP BY lm2.ID_LOT_GLOBAL
--having sum(LM2.QUANTITY_ADD - LM2.QUANTITY_SUB) >0
)*LOT.PRICE_SUP

 from LOT , STORE , GOODS
where ID_LOT_GLOBAL in 
(
select ID_LOT_GLOBAL from LOT_MOVEMENT where DATE_OP <= @dat

)
and lot.ID_STORE = store.ID_STORE
and GOODS.ID_GOODS = lot.ID_GOODS

) as aaaa
where  Количество >0
ORDER BY Номенклатура
--Остатки по складам
/*declare @dat datetime
set @dat = CAST( GETDATE () AS DATE)
select 
Период = @dat ,
 ИНН = (select top 1 INN from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = STORE.ID_CONTRACTOR ) ,
 КодСклада = STORE.ID_STORE ,
 НаименованиеСклада = store.NAME , 
 Номенклатура = goods.ID_GOODS_GLOBAL,
 Количество = ( SELECT 	AMOUNT_OST = SUM(LM2.QUANTITY_ADD - LM2.QUANTITY_SUB)
FROM LOT_movement LM2
INNER JOIN LOT L2 ON L2.ID_LOT_GLOBAL = LM2.ID_LOT_GLOBAL
WHERE
LM2.ID_LOT_GLOBAL=LOT.id_lot_global  and 
(lm2.QUANTITY_ADD!=0 or lm2.QUANTITY_SUB!=0)   
and
LM2.DATE_OP <=@dat
GROUP BY lm2.ID_LOT_GLOBAL
)

 from LOT , STORE , GOODS
where ID_LOT_GLOBAL in 
(
select ID_LOT_GLOBAL from LOT_MOVEMENT where DATE_OP <= @dat

)
and lot.ID_STORE = store.ID_STORE
and GOODS.ID_GOODS = lot.ID_GOODS
--ORDER BY store.ID_STORE
*/