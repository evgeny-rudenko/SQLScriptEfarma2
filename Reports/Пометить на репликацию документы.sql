use eplus_work

-- провер€ем - если это центр , то не мен€ем настройки репликации
if (dbo.FN_IS_CONTRACTOR_CO()=0)
begin
        update SYS_OPTION
        set VALUE = 'PROC_AUTO', DISPLAY_VALUE = 'AUTO'
        where name = '—пособ репликации'
end

--select * from ACT_DISASSEMBLING -- 'ACT_DISASSEMBLING' *
--select * from ACT_DEDUCTION		-- 'ACT_DEDUCTION' *
--select * FROM ACT_REVALUATION2	-- 'ACT_REVALUATION2'

--јкты переоценки
DECLARE ACT_REVALUATION2 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
select
            m.ID_ACT_REVALUATION2_GLOBAL
from ACT_REVALUATION2 m
where document_state  = 'PROC'
and m.DATE_MODIFIED between getdate() -30 and GETDATE()
-- не переотправл€ть документы пришедшие из офиса. на них нет пометки репликации. но она и не нужна  
and ID_STORE not in (select id_store from store where STORE.ID_CONTRACTOR =1)
and (
                SELECT TOP 1 STATUS
                    FROM REPLICATION_LOG_ADD RLA
                    WHERE RLA.ID_ROW_GLOBAL = m.ID_ACT_REVALUATION2_GLOBAL
            ) is null
declare @ACT_REVALUATION2 UNIQUEIDENTIFIER
open ACT_REVALUATION2
WHILE 1 = 1 BEGIN
    FETCH NEXT FROM ACT_REVALUATION2 INTO @ACT_REVALUATION2
    IF @@FETCH_STATUS <> 0 BREAK

EXEC REPL_DOCUMENT_SET_PREPARED @ACT_REVALUATION2, 'ACT_REVALUATION2'
END

close ACT_REVALUATION2
deallocate ACT_REVALUATION2



-- јкты списани€
DECLARE ACT_DEDUCTION CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
select
            m.ID_ACT_DEDUCTION_GLOBAL
from ACT_DEDUCTION m
where document_state  = 'PROC'
and m.DATE_MODIFIED between getdate() -30 and GETDATE()
-- не переотправл€ть документы пришедшие из офиса. на них нет пометки репликации. но она и не нужна  
and ID_STORE not in (select id_store from store where STORE.ID_CONTRACTOR =1)
and (
                SELECT TOP 1 STATUS
                    FROM REPLICATION_LOG_ADD RLA
                    WHERE RLA.ID_ROW_GLOBAL = m.ID_ACT_DEDUCTION_GLOBAL
            ) is null
declare @ACT_DEDUCTION UNIQUEIDENTIFIER
open ACT_DEDUCTION
WHILE 1 = 1 BEGIN
    FETCH NEXT FROM ACT_DEDUCTION INTO @ACT_DEDUCTION
    IF @@FETCH_STATUS <> 0 BREAK

EXEC REPL_DOCUMENT_SET_PREPARED @ACT_DEDUCTION, 'ACT_DEDUCTION'
END

close ACT_DEDUCTION
deallocate ACT_DEDUCTION




-- јкты разукомплектации
DECLARE ACT_DISASSEMBLING CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
select
            m.ID_ACT_DISASSEMBLING_GLOBAL
from ACT_DISASSEMBLING m
where document_state  = 'PROC'
and m.DATE_MODIFIED between getdate() -30 and GETDATE()
-- не переотправл€ть документы пришедшие из офиса. на них нет пометки репликации. но она и не нужна  
and ID_STORE not in (select id_store from store where STORE.ID_CONTRACTOR =1)
and (
                SELECT TOP 1 STATUS
                    FROM REPLICATION_LOG_ADD RLA
                    WHERE RLA.ID_ROW_GLOBAL = m.ID_ACT_DISASSEMBLING_GLOBAL
            ) is null
declare @ACT_DISASSEMBLING UNIQUEIDENTIFIER
open ACT_DISASSEMBLING
WHILE 1 = 1 BEGIN
    FETCH NEXT FROM ACT_DISASSEMBLING INTO @ACT_DISASSEMBLING
    IF @@FETCH_STATUS <> 0 BREAK

EXEC REPL_DOCUMENT_SET_PREPARED @ACT_DISASSEMBLING, 'ACT_DISASSEMBLING'
END

close ACT_DISASSEMBLING
deallocate ACT_DISASSEMBLING




-- помечаем все перемещени€ ћ≈∆ƒ” ѕќƒ–ј«ƒ≈Ћ≈Ќ»яћ»
DECLARE INTERFIRM_MOVEMENTS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
select
            m.ID_INTERFIRM_MOVING_GLOBAL
from INTERFIRM_MOVING m
where document_state  = 'PROC'
and m.DATE_MODIFIED between getdate() -30 and GETDATE()
-- не переотправл€ть документы пришедшие из офиса. на них нет пометки репликации. но она и не нужна  
and ID_STORE_TO_MAIN not in (select id_store from store where STORE.ID_CONTRACTOR =1)
and (
                SELECT TOP 1 STATUS
                    FROM REPLICATION_LOG_ADD RLA
                    WHERE RLA.ID_ROW_GLOBAL = m.ID_INTERFIRM_MOVING_GLOBAL
            ) is null
declare @INTERFIRM_MOVEMENT UNIQUEIDENTIFIER
open INTERFIRM_MOVEMENTS
WHILE 1 = 1 BEGIN
    FETCH NEXT FROM INTERFIRM_MOVEMENTS INTO @INTERFIRM_MOVEMENT
    IF @@FETCH_STATUS <> 0 BREAK

EXEC REPL_DOCUMENT_SET_PREPARED @INTERFIRM_MOVEMENT, 'INTERFIRM_MOVING'
END

close INTERFIRM_MOVEMENTS
deallocate INTERFIRM_MOVEMENTS





-- помечаем все перемещени€
DECLARE MOVEMENTS CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
select
            m.ID_MOVEMENT_GLOBAL
from MOVEMENT m
where document_state  = 'PROC'
and m.DATE_MODIFIED between getdate() -30 and GETDATE()
-- не переотправл€ть документы пришедшие из офиса. на них нет пометки репликации. но она и не нужна  
and ID_STORE_TO not in (select id_store from store where STORE.ID_CONTRACTOR =1)
and (
                SELECT TOP 1 STATUS
                    FROM REPLICATION_LOG_ADD RLA
                    WHERE RLA.ID_ROW_GLOBAL = m.ID_MOVEMENT_GLOBAL
            ) is null
declare @MOVEMENT UNIQUEIDENTIFIER
open MOVEMENTS
WHILE 1 = 1 BEGIN
    FETCH NEXT FROM MOVEMENTS INTO @MOVEMENT
    IF @@FETCH_STATUS <> 0 BREAK

EXEC REPL_DOCUMENT_SET_PREPARED @MOVEMENT, 'MOVEMENT'
END


close MOVEMENTS
deallocate MOVEMENTS



-- помечаем на репликацию все приходные за мес€ц у которых нет отметки о репликации

DECLARE INVOICES CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
select
           i.ID_INVOICE_GLOBAL

from invoice i
where document_state  = 'PROC' and
 DOCUMENT_DATE between getdate() -30 and GETDATE()
and i.ID_STORE in (select id_store from store where STORE.ID_CONTRACTOR = DBO.FN_CONST_CONTRACTOR_SELF())
/*and (
                SELECT TOP 1 STATUS
                    FROM REPLICATION_LOG_ADD RLA
                    WHERE RLA.ID_ROW_GLOBAL = I.ID_INVOICE_GLOBAL
            ) is null
            */ -- раскомментировать чтобы попадали только нереплицированные документы
declare @INVOICE UNIQUEIDENTIFIER
open INVOICES
WHILE 1 = 1 BEGIN
    FETCH NEXT FROM INVOICES INTO @INVOICE
    IF @@FETCH_STATUS <> 0 BREAK

EXEC REPL_DOCUMENT_SET_PREPARED @INVOICE, 'INVOICE'
END


close INVOICES
deallocate INVOICES