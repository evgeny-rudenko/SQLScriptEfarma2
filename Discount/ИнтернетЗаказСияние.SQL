SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Evgeny Rudenko
-- Create date: 09-01-2019
-- Description:	считаем цену прайс листа для интернет заказа по партиям
-- =============================================
CREATE FUNCTION [dbo].[GetInternetPrice]
(
	-- Add the parameters for the function here
	@lot uniqueidentifier 
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @price_sal money set @price_sal  = (select top 1 PRICE_SAL from LOT where ID_LOT_GLOBAL = @lot)
	DECLARE @price_sup money set @price_sup = (select top 1 PRICE_SUP from LOT where ID_LOT_GLOBAL = @lot )
	DECLARE @result int set @result= @price_sal
	DECLARE @percent float
	DECLARE @important int set @important = (select top 1 important from goods where GOODS.ID_GOODS = (select top 1 id_goods from lot where ID_LOT_GLOBAL = @lot))
	 
	 -- если препарат ЖВ -  возвращаем розничную цену без изменений
	 if @important =1 
		begin 
			return @price_sal
		end
	 -- не заполнена цена поставщика
	 if @price_sup =0
		begin
			return @price_sal
		end
	-- не продаем ниже закупочной
	if @price_sup >= @price_sal
		begin
			return @price_sal
		end

	-- процент наценки фактический
	set @percent = (@price_sal/@price_sup -1) *100 
	
	if @percent < 15 
		begin
			return @result
		end
	
	if @percent >=15 and @percent <20
		begin
			return @result*0.97
		end
	if @percent >=20 and @percent<40
		begin 
			return @result*0.95
		end
		
	if @percent >=40
		begin 
			return @result*0.85
		end
	
	RETURN @result

END



-- =============================================
-- Author:		Evgeny Rudenko
-- Create date: 09-01-2019
-- Description:	Заполнение цен со скидкой в АРМ Кассира 
--              
-- =============================================
CREATE PROCEDURE [dbo].[DISCOUNT2_SPECIAL_INTERNET]
@PARAMS VARCHAR(4000)
AS
    -- Для предоставления скидки нужно обоновить поля таблицы #CHEQUEINFO
    -- SUM_WITH_DISCOUNT -- сумма со скидкой
    -- DISCOUNT_VALUE -- размер скидки
    -----------------------------------
    -- Другие поля (их обновлять НЕЛЬЗЯ)
    -- CHEQUE_DATE - дата чека
    -- ID_DISCOUNT2_CARD_GLOBAL - ИД дисконтной карты
    -- ID_LOT_GLOBAL - ИД партии
    -- QTY - количество
    -- PRICE - цена розничная с НДС
    -- PRICE_SUP - цена постащика с НДС
    -- CHEQUE_SUM - сумма ВСЕГО чека
    -- SUM_WITH_DISCOUNT - сумма со скидкой по строке
    -- DISCOUNT_VALUE - значение скидки в деньгах
begin
if object_id('tempdb..#CHEQUEINFO') is null
return;

-- Нужно выкинуть ЖВ препараты - не всегда правильно пересчитывает АРМ Кассира. Внутри есть округления
update #CHEQUEINFO
set		DISCOUNT_VALUE		= QTY * PRICE - dbo.getinternetprice (ID_LOT_GLOBAL)*QTY 
		where ID_LOT_GLOBAL in (select ID_LOT_GLOBAL from LOT where LOT.ID_GOODS  in (select goods.ID_GOODS from GOODS where IMPORTANT =0))	


update #CHEQUEINFO
set 	SUM_WITH_DISCOUNT	= QTY * PRICE - DISCOUNT_VALUE
		where ID_LOT_GLOBAL in (select ID_LOT_GLOBAL from LOT where LOT.ID_GOODS  in (select goods.ID_GOODS from GOODS where IMPORTANT =0))	

return
end
