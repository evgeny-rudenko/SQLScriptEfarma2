

/*
 * 2022.05.09
 * Проверка - все ли позиции из ПМП прошли по акту приемки.
 * Если прошли не все позиции - будет активна кнопка Создать акт приемки.
 * Если по документу акт уже созан- будет принят только товар отсутствующий в старом документе 
 */
with aa as 
(
select 
ID_INTERFIRM_MOVING_GLOBAL,
MNEMOCODE, 
AAC = (select COUNT(*) from 
INTERFIRM_MOVING_ACCEPTANCE_ACT_ITEM imaai 
where imaai.ID_INTERFIRM_MOVING_ACCEPTANCE_ACT_GLOBAL = imaa.ID_INTERFIRM_MOVING_ACCEPTANCE_ACT_GLOBAL)
from INTERFIRM_MOVING_ACCEPTANCE_ACT imaa 
)
select 
s.NAME as store_from ,
s2.NAME  as store_to, 
IM = (select COUNT(*) from INTERFIRM_MOVING_ITEM imi where imi.ID_INTERFIRM_MOVING_GLOBAL = im.ID_INTERFIRM_MOVING_GLOBAL),
AA.AAC,
AA.mnemocode,
* from INTERFIRM_MOVING im , STORE s, STORE s2 , aa
where im.ID_STORE_FROM_MAIN = s.ID_STORE 
and im.ID_STORE_TO_MAIN = s2.ID_STORE 
and im.ID_INTERFIRM_MOVING_GLOBAL = aa.ID_INTERFIRM_MOVING_GLOBAL
and aa.AAC != (select COUNT(*) from INTERFIRM_MOVING_ITEM imi where imi.ID_INTERFIRM_MOVING_GLOBAL = im.ID_INTERFIRM_MOVING_GLOBAL)
and s2.NAME = 'Транзитный склад'
and im.DOCUMENT_STATE ='PROC'
order by s.NAME

