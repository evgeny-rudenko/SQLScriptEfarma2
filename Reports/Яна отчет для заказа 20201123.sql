IF OBJECT_ID('tempdb..#Results') IS NOT NULL
    DROP TABLE #Results

IF OBJECT_ID('tempdb..#LS') IS NOT NULL
    DROP TABLE #LS
IF OBJECT_ID('tempdb..#V_GOODS_NAMES') IS NOT NULL
    DROP TABLE #V_GOODS_NAMES

IF OBJECT_ID('tempdb..#V_REMAINS_ALL') IS NOT NULL
    DROP TABLE #V_REMAINS_ALL

IF OBJECT_ID('tempdb..#V_REMAINS_SKLAD') IS NOT NULL
    DROP TABLE #V_REMAINS_SKLAD


IF OBJECT_ID('tempdb..#V_CHEQUE_SUB') IS NOT NULL
    DROP TABLE #V_CHEQUE_SUB

IF OBJECT_ID('tempdb..#V_REMAINS_SKLAD_MARK') IS NOT NULL
    DROP TABLE #V_REMAINS_SKLAD_MARK

IF OBJECT_ID('tempdb..#V_REMAINS_ON_THE_WAY') IS NOT NULL
    DROP TABLE #V_REMAINS_ON_THE_WAY

-- ��� � ���� �� ������ 
IF OBJECT_ID('tempdb..#V_REMAINS_ON_THE_WAY_SKLAD') IS NOT NULL
    DROP TABLE #V_REMAINS_ON_THE_WAY_SKLAD

IF OBJECT_ID('tempdb..#V_REMAINS_ALL_MA') IS NOT NULL
    DROP TABLE #V_REMAINS_ALL_MA


--- � ���� �����
SELECT NM, ON_THE_WAY as ON_THE_WAY_SKLAD 
INTO #V_REMAINS_ON_THE_WAY_SKLAD
FROM V_REMAINS_ON_THE_WAY
WHERE id_store =7
	
	
-- ������� ��  ������������ ������ ����������
select 
NM,
sum (QTY) as QTY,
sum (SUM_OPT) as SUM_OPT,
sum (SUM_ROZN) as SUM_ROZN
into #V_REMAINS_SKLAD_MARK
from V_REMAINS_SKLAD_MARK
group by NM


-- ������� ��  ������������ ������ 
select 
NM,
sum (QTY) as QTY,
sum (SUM_OPT) as SUM_OPT,
sum (SUM_ROZN) as SUM_ROZN
into #V_REMAINS_SKLAD
from V_REMAINS_SKLAD
group by NM



-- ������������� ���� ��� �������� � ���������
select V_GOODS_NAMES.ID_GOODS,V_GOODS_NAMES.NAME,V_GOODS_NAMES.NM
into #V_GOODS_NAMES
from V_GOODS_NAMES


--- ������� �� ����� 
select 
CONTRACTOR.NAME as APTEKA,
#V_GOODS_NAMES.NM,
sum (V_CHEQUE_SUB.PRODANO) as PRODANO,
sum (V_CHEQUE_SUB.SUM_PRODANO_OPT) as SUM_PRODANO_OPT,
sum (V_CHEQUE_SUB.SUM_PRODANO_ROZN) as SUM_PRODANO_ROZN
into #V_CHEQUE_SUB
from V_CHEQUE_SUB, CONTRACTOR, STORE, #V_GOODS_NAMES
where V_CHEQUE_SUB.ID_STORE = STORE.ID_STORE
and CONTRACTOR.ID_CONTRACTOR = STORE.ID_CONTRACTOR
and #V_GOODS_NAMES.ID_GOODS = V_CHEQUE_SUB.ID_GOODS
group by CONTRACTOR.NAME, #V_GOODS_NAMES.NM




--������� ��� ��� ������������ ������������
select #V_GOODS_NAMES.NM,
CONTRACTOR.NAME as APTEKA,
sum (V_REMAINS_ALL.QTY) as QTY,
sum (V_REMAINS_ALL.SUM_OPT) as SUM_OPT,
sum (V_REMAINS_ALL.SUM_ROZN) as SUM_ROZN
into #V_REMAINS_ALL
from V_REMAINS_ALL, #V_GOODS_NAMES, STORE, CONTRACTOR
where V_REMAINS_ALL.ID_GOODS = #V_GOODS_NAMES.ID_GOODS
and STORE.ID_STORE = V_REMAINS_ALL.ID_STORE
and CONTRACTOR.ID_CONTRACTOR = store.ID_CONTRACTOR
and V_REMAINS_ALL.ID_STORE not in (select ID_STORE from store where store.NAME  like '%���%��%') -- ������� ����������� �����������
group by #V_GOODS_NAMES.NM, CONTRACTOR.NAME 
----------------


--������� ��� ��� ������������ ������������
select #V_GOODS_NAMES.NM,
CONTRACTOR.NAME as APTEKA,
sum (V_REMAINS_ALL.QTY) as QTY,
sum (V_REMAINS_ALL.SUM_OPT) as SUM_OPT,
sum (V_REMAINS_ALL.SUM_ROZN) as SUM_ROZN
into #V_REMAINS_ALL_MA
from V_REMAINS_ALL, #V_GOODS_NAMES, STORE, CONTRACTOR
where V_REMAINS_ALL.ID_GOODS = #V_GOODS_NAMES.ID_GOODS
and STORE.ID_STORE = V_REMAINS_ALL.ID_STORE
and CONTRACTOR.ID_CONTRACTOR = store.ID_CONTRACTOR
and V_REMAINS_ALL.ID_STORE  in (select ID_STORE from store where store.NAME  like '%���%��%') -- ������� ����������� �����������
group by #V_GOODS_NAMES.NM, CONTRACTOR.NAME 




--- ��������� ����������� 
SELECT  CONTRACTOR.NAME as APTEKA ,
V_GOODS_NAMES.NM,
MAX(LOT_MOVEMENT.DATE_OP) AS POSLEDNEE_POSTUPLENIE
INTO #LS
FROM            dbo.LOT_MOVEMENT INNER JOIN
                         dbo.LOT ON dbo.LOT_MOVEMENT.ID_LOT_GLOBAL = dbo.LOT.ID_LOT_GLOBAL INNER JOIN
                         
                         dbo.STORE ON dbo.STORE.ID_STORE = dbo.LOT.ID_STORE INNER JOIN
						 dbo.CONTRACTOR ON dbo.STORE.ID_CONTRACTOR = CONTRACTOR.ID_CONTRACTOR inner join 
						 V_GOODS_NAMES ON LOT.ID_GOODS = V_GOODS_NAMES.ID_GOODS

WHERE        (dbo.LOT_MOVEMENT.CODE_OP IN ('MOVE', 'INVOICE')) AND (dbo.LOT_MOVEMENT.OP = 'ADD')
GROUP BY  CONTRACTOR.NAME, V_GOODS_NAMES.NM




SELECT        
#V_REMAINS_ALL.APTEKA,
#V_REMAINS_ALL.NM, 
#V_REMAINS_ALL.QTY, 
#V_REMAINS_ALL.SUM_OPT, 
#V_REMAINS_ALL.SUM_ROZN, 
#V_REMAINS_ALL_MA.QTY AS MA_QTY,
#V_REMAINS_ALL_MA.SUM_OPT AS MA_SUM_OPT_MA,
#V_REMAINS_ALL_MA.SUM_ROZN AS MA_SUM_ROZN,
#V_CHEQUE_SUB.PRODANO, 
#V_CHEQUE_SUB.SUM_PRODANO_OPT, 
#V_CHEQUE_SUB.SUM_PRODANO_ROZN, 
#V_REMAINS_SKLAD.QTY AS OSTATOK_SKLAD, 
#V_REMAINS_SKLAD.SUM_OPT AS SUM_OPT_SKLAD, 
#V_REMAINS_SKLAD.SUM_ROZN AS SUM_ROZN_SKLAD,
#V_REMAINS_SKLAD_MARK.QTY as QTY_MARK,
DBO.V_REMAINS_ON_THE_WAY.ON_THE_WAY, 
#V_REMAINS_ON_THE_WAY_SKLAD.ON_THE_WAY_SKLAD,
#LS.POSLEDNEE_POSTUPLENIE
INTO #Results

FROM            #V_REMAINS_ALL  LEFT OUTER JOIN
#V_REMAINS_SKLAD ON #V_REMAINS_ALL.NM = #V_REMAINS_SKLAD.NM LEFT OUTER JOIN
#V_CHEQUE_SUB ON #V_REMAINS_ALL.NM = #V_CHEQUE_SUB.NM
AND #V_REMAINS_ALL.APTEKA = #V_CHEQUE_SUB.APTEKA LEFT OUTER JOIN 
#V_REMAINS_SKLAD_MARK ON #V_REMAINS_ALL.NM = #V_REMAINS_SKLAD_MARK.NM LEFT OUTER JOIN 
V_REMAINS_ON_THE_WAY ON #V_REMAINS_ALL.NM = V_REMAINS_ON_THE_WAY.NM
AND #V_REMAINS_ALL.APTEKA = V_REMAINS_ON_THE_WAY.APTEKA LEFT OUTER JOIN
#LS ON #V_REMAINS_ALL.NM = #LS.NM and #V_REMAINS_ALL.APTEKA = #LS.APTEKA LEFT OUTER JOIN
#V_REMAINS_ALL_MA ON #V_REMAINS_ALL.APTEKA = #V_REMAINS_ALL_MA.APTEKA AND #V_REMAINS_ALL.NM = #V_REMAINS_ALL_MA.NM LEFT OUTER JOIN
#V_REMAINS_ON_THE_WAY_SKLAD ON #V_REMAINS_ALL.NM = #V_REMAINS_ON_THE_WAY_SKLAD.NM


SELECT * FROM #Results
WHERE APTEKA  like '%'
and nm like  '%%'

--- � �������� ������ ��� ������������ ������������ 
/*
select  
NM , 
APTEKA ,
sum (QTY) as QTY, 
sum (SUM_OPT) as SUM_OPT , 
sum (SUM_ROZN) as SUM_ROZN, 
isnull ( sum (PRODANO),0) as PRODANO, 
isnull (sum (SUM_PRODANO_OPT),0) as SUM_PRODANO_OPT ,
isnull (sum (SUM_PRODANO_ROZN),0) as SUM_PRODANO_ROZN , 
isnull (sum (OSTATOK_SKLAD),0) as  OSTATOK_SKLAD, 
isnull (sum (SUM_OPT_SKLAD),0) as SUM_OPT_SKLAD , 
isnull (sum (SUM_ROZN_SKLAD),0) as SUM_ROZN_SKLAD ,
isnull (sum (QTY_MARK),0) as QTY_MARK ,
isnull (sum (ON_THE_WAY),0) as ON_THE_WAY ,
max (POSLEDNEE_POSTUPLENIE) as POSLEDNEE_POSTUPLENIE
from #Results
WHERE APTEKA  like '%'
and nm like  '%%'
group by APTEKA, NM
order by APTEKA, NM
*/
