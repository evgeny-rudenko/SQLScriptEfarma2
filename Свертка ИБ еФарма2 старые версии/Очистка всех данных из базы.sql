--- проверки под разные версии ефармы
--- 
delete from MOVEMENT_ITEM
delete from MOVEMENT
delete from ACT_RETURN_TO_BUYER_ITEM
delete from ACT_RETURN_TO_BUYER
delete from DISCOUNT2_MAKE_ITEM
IF OBJECT_ID('DEFECT_JOURNAL_DETAIL') IS  not NULL  delete from DEFECT_JOURNAL_DETAIL
delete from CASH_ORDER
delete from PAYMENT_ORDER_ITEM
delete from PAYMENT_ORDER
delete from CHEQUE_PAYMENT
IF OBJECT_ID('ARM_SYNC_DISCOUNT2_MEMBER_DATA') IS  not NULL delete from ARM_SYNC_DISCOUNT2_MEMBER_DATA
delete from CHEQUE_ITEM
IF OBJECT_ID('ARM_SYNC_DATA') IS  not NULL delete from ARM_SYNC_DATA
IF OBJECT_ID('ARM_SYNC_BARCODE_DATA') IS  not NULL delete from ARM_SYNC_BARCODE_DATA
IF OBJECT_ID('CASH_SESSION_CHEQUE_SUM') IS  not NULL delete from CASH_SESSION_CHEQUE_SUM
delete from CHEQUE
delete from ACT_DISASSEMBLING_ITEM
delete from ACT_DISASSEMBLING
delete from ACT_DEDUCTION_ITEM
delete from ACT_DEDUCTION
delete from CASH_SESSION
delete from INVOICE_ITEM
delete from INVOICE
delete from INVOICE_OUT_ITEM
delete from INVOICE_OUT
delete from ACT_RETURN_TO_CONTRACTOR_ITEM
delete from ACT_RETURN_TO_CONTRACTOR
delete from STOCK_RECORD
delete from LOT_MOVEMENT
delete from LOT
delete from doc_movement
delete from movement
IF OBJECT_ID('ACT_REVALUATION2_ITEM') IS  not NULL delete from ACT_REVALUATION2_ITEM
IF OBJECT_ID('ACT_REVALUATION2') IS  not NULL delete from ACT_REVALUATION2
IF OBJECT_ID('act_revaluation_item') IS  not NULL delete from act_revaluation_item
IF OBJECT_ID('act_revaluation2_item') IS  not NULL delete from act_revaluation2_item
IF OBJECT_ID('act_revaluation') IS  not NULL delete from act_revaluation
delete from DISCOUNT2_PROGRAM
delete from REQUEST_ITEM
delete from REQUEST
delete from all_document
delete from document_ved
delete from action_log
delete from lot_period_rem
delete from lot_period_rem_day
delete from certificate
delete from series
delete from CALCULATION_CARD_ITEM
delete from production_item
delete from production
delete from CASH_SESSION_CHEQUE_SUM
delete from CASH_SESSION
delete from DISCOUNT2_ACCUMULATION_SCHEMA
delete from DISCOUNT2_MAKE_ITEM
delete from DISCOUNT2_card
delete from DISCOUNT2_card_number
delete from DISCOUNT2_card_type
delete from BILL
delete from BILL_ITEM
delete  from STOCK_RECORD
delete  from DOCUMENT_VED
IF OBJECT_ID('DEFECT_JOURNAL') IS  not NULL delete  from DEFECT_JOURNAL
delete  from DEFECTURA_ITEM
delete  from DEFECTURA
delete  from INVOICE_IMPORT
update mnemocodes  set counter=0
where obj_name<>'GOODS'
update notes set is_alert=0 where id_note=1
DELETE FROM [META_USER2ROLE]
WHERE ID_USER in
(
select id_user from meta_user where name not in ('1','Администратор')
)

DELETE FROM [META_USER]
WHERE ID_USER in
(
select id_user from meta_user where name not in ('1','Администратор')
)

--select * from sysobjects
--where name like '%master%'

--select * from STOCK_RECORD
