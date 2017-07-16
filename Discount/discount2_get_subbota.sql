USE [Farma]
GO
/****** Object:  StoredProcedure [dbo].[USP_DISCOUNT2_GET_SUBBOTA]    Script Date: 07/16/2017 20:22:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[USP_DISCOUNT2_GET_SUBBOTA]
    @VALUE_IN VARCHAR(4000)
AS
-- Функция для проверки - вторая и четверая суббота месяца или что то аналогичное
-- используется в условиях модуля Акции / скидки
-- Функция проверяет - текущая дата это второй или четвертый деь недели текущего месяца 
set nocount on;
declare @d datetime;
set @d=getdate();


declare @wd tinyint;
set @wd=1;/*7 - воскресенье*/  --- нужно поменять на субботу 

if (14 + dateadd(day, 7+(@wd-6-@@datefirst-datepart(weekday, dateadd(day,-1, convert(char(6),@d,112)+'01')))%7, dateadd(day,-1, convert(char(6),@d,112)+'01'))) = (cast(convert(char(8),@d,112) as datetime)) 
begin 
    SELECT top 1
        VALUE = CONVERT(VARCHAR(4000), CONVERT(BIT, 1))
    FROM LOT
  end 

if (7 + dateadd(day, 7+(@wd-6-@@datefirst-datepart(weekday, dateadd(day,-1, convert(char(6),@d,112)+'01')))%7, dateadd(day,-1, convert(char(6),@d,112)+'01'))) = (cast(convert(char(8),@d,112) as datetime)) 
begin 
    SELECT top 1
        VALUE = CONVERT(VARCHAR(4000), CONVERT(BIT, 1))
    FROM LOT
  
end 
    
RETURN
