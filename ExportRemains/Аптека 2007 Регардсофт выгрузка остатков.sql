/*
--- документы
select Rel_Name,Prm_ShortName,Prt_UniCode,Obj_Name,Skd_UniCode,Hdr_Date,Prm_UniCode,Str_Qnt,Str_Sum01,Hdr_UniCode,Str_Sum02,Str_Sum03,Hdr_NumDcm,Str_Sum05,Str_Sum06,Str_Sum07,Str_Sum08,Str_Sum09,Str_Sum10,Str_Sum11,Str_Sum12,Str_ExchSum08,Str_ExchSum09,Str_Value4_01,Str_Value4_02,Str_Value4_03,DcmState
from ws_PrtDcm
--where(Prt_UniCode = @P1)
order by Hdr_Date, Hdr_IntDate


select Cmp_UniCode,Prt_IDN,Prt_UniCode,Str_DateSuitable,Cmp_Name,Skd_UniCode,Str_BarCode,Prt_Qnt,PRT_CURRQNT - ISNULL(PRT_RESERVE,0) AS [PRT_CURRQNT],Str_Price03,Str_Value4_04,Prt_Date,Str_Price01,Str_Price02,Str_ExchPrice09,InfoCll,Info_Str_02,Str_DecPlace,Str_Value0_07,Info_Str_01,Cntr_Name,Info_Date1,Str_SeriesNum,InfoID,Str_SertifNum,Ros_Name,Str_ExchPrice03,Str_SertifNeedYN,Str_Value0_11,Str_Value0_12,ObjCode,Pro_BarCode,IntBar,Prm_UniCode
from ws_Prt p with(nolock)
--where (Skd_UniCode = @Skd)AND(@Self = 0 or ObjCode = @Self)AND (@Kls = 0 or exists(select * from KlsCmpLnk k where k.Cmp_UniCode = p.Cmp_UniCode and Kls_UniCode = @Kls))AND((@Ch1 = '' '' or Left(Cmp_Name,1) in (@Ch1,@Ch2,@Ch3,@Ch4,@Ch5))or (@Ch1 = ''0'' and Left(Cmp_Name,1) not in (''А'',''Б'',''В'',''Г'',''Д'',''Е'',''Ё'',''Ж'',''З'',''И'',''Й'',''К'',''Л'',''М'',''Н'',''О'',''П'',''Р'',''С'',''Т'',''У'',''Ф'',''Х'',''Ц'',''Ч'',''Ш'',''Щ'',''Э'',''Ю'',''Я'')))AND((@Qnt = 0)or(Prt_DateClose > @DT)or(Prt_DateClose is Null))AND(Cmp_UniCode = @Cmp or @Cmp = 0)AND(Prt_CurrQnt > @Qnt)AND(Len(@LK) = 0 or Cmp_Name like @LK )
order by Cmp_Name, Prt_Date
--',N'@P1 int,@P2 float,@P3 int,@P4 int,@P5 float,@P6 varchar(50),@P7 varchar(1),@P8 varchar(1),@P9 varchar(1),@P10 varchar(1),@P11 varchar(1),@P12 int',10,0,0,0,42461,'','Щ','Э',' ','
*/

--- по этому препарату мы тестируем что и как выгрузилось
select *

from ws_Prt p with(nolock)
where Cmp_Name like 'Эгилок%25%'
order by Cmp_Name



select 
  HASHBYTES ( 'MD2', 	Cmp_Name +
	Isnull (Pro_Name, '')  +
	Isnull (Cntr_Name,'')) as  GoodsCode, 
Cmp_Name ,							-- 1 наименование
Isnull (Pro_Name, '') as Producer,	-- 2 производитель
Isnull (Cntr_Name,'') as Country ,	-- 3 страна
Prt_CurrQnt,						-- 4 текущий остаток
Str_Price02,						-- 5 цена поставщика без НДС
Str_ExchPrice09,					-- 6 цена Поставщика с НДС
Str_Price01 ,						-- 7 цена производителя без НДС
Str_Price03,						-- 8 цена розничная
Str_Price09,						-- 9 Реестровая цена - нужно проверить

Str_SeriesNum,						-- 10 серия
Str_DateSuitable,					-- 11 Срок годности
Info_Str_01,						-- 12 ГТД
Flg_GVA,							-- 13 признак ЖНВЛС
Str_SertifNum,						-- 14  номер  сертификата 
Isnull(Info_Str_02, '') as barcode ,-- 15  Штрих-Код завода
Str_BarCode -- 13 Штрих-код партии
from ws_Prt p with(nolock)
where Cmp_Name like '%'--'Э%25%60%'
and Prt_CurrQnt >0
order by Cmp_Name