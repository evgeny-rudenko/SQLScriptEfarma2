/*������������ ������������ ����	
��� ������������ ����	
���� ������������ ��������	
�������� �����
 ���
 	����� �������� �����
		��������� ���	
		��������� ���	
		���������
			��� ������	
			�����-���
				�������� ������	
				����� - �������������	���-��	����� ������� � ���*/

				--������� �� �������
declare @dat datetime
set @dat = CAST( GETDATE () AS DATE)


select * from (
select 
��� = isnull( (select top 1 INN from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = STORE.ID_CONTRACTOR ) , ''),
���� = @dat ,
������������������ = store.NAME , 
��������� = STORE.ID_STORE ,
����� = isnull( (select top 1 ADDRESS from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = STORE.ID_CONTRACTOR ) , ''),
������������ =isnull ((select inn from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = LOT.ID_SUPPLIER), '') ,
������������ =isnull ((select KPP from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = LOT.ID_SUPPLIER), '') ,
��������� =isnull ((select NAME from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = LOT.ID_SUPPLIER), '') ,
������������ = GOODS.NAME, --goods.ID_GOODS_GLOBAL,
���������� = ( SELECT 	AMOUNT_OST = SUM(LM2.QUANTITY_ADD - LM2.QUANTITY_SUB)
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
�������� = ( SELECT 	AMOUNT_OST = SUM(LM2.QUANTITY_ADD - LM2.QUANTITY_SUB)
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
where  ���������� >0
ORDER BY ������������
--������� �� �������
/*declare @dat datetime
set @dat = CAST( GETDATE () AS DATE)
select 
������ = @dat ,
 ��� = (select top 1 INN from CONTRACTOR where CONTRACTOR.ID_CONTRACTOR = STORE.ID_CONTRACTOR ) ,
 ��������� = STORE.ID_STORE ,
 ������������������ = store.NAME , 
 ������������ = goods.ID_GOODS_GLOBAL,
 ���������� = ( SELECT 	AMOUNT_OST = SUM(LM2.QUANTITY_ADD - LM2.QUANTITY_SUB)
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