--Некоторые полезные преобразования
set nocount on;
declare @d datetime;
set @d=getdate();
select 'Дата ', cast(convert(char(8),@d,112) as datetime);
 
select 'первый день месяца',
cast(convert(char(6),@d,112)+'01' as datetime);
 
select  'последний день месяца',
dateadd(day,-1, convert(char(6), dateadd(month,1,@d),112)+'01');
 
select 'первый день года',
cast(datename(year,@d) as datetime);
 
select 'последний день года',
cast(datename(year,@d)+'1231' as datetime);

select 'первый день квартала',
dateadd(month,3*(datepart(quarter,@d)-1), datename(year,@d));
 
select 'последний день квартала',
dateadd(day,-1, dateadd(month,3*datepart(quarter,@d), datename(year,@d)));
 
print 'Русская нумерация дней недели'
select (@@datefirst+datepart(weekday,@d)-2)%7+1;

declare @wd tinyint;
set @wd=7;/*воскресенье*/

select 'Первое воскресенье месяца',
dateadd(day,
 7+(@wd-6-@@datefirst-datepart(weekday, dateadd(day,-1, convert(char(6),@d,112)+'01')))%7,
 dateadd(day,-1, convert(char(6),@d,112)+'01'));

select 'Последнее воскресенье месяца',
dateadd(day,
 (@wd-6-@@datefirst-datepart(weekday, dateadd(day,-1, dateadd(month,1, convert(char(6),@d,112)+'01'))))%7,
 dateadd(day,-1, dateadd(month,1, convert(char(6),@d,112)+'01')));

/*
http://www.sql.ru/forum/actualthread.aspx?bid=1&tid=444536&pg=-1#4306492
*/
print 'Количество понедельников в месяце'
set @wd=1 /*Понедельник*/
select
 datediff(week, dateadd(day,-(@wd+1)%7, convert(char(6),@d,112)+'01'),
 dateadd(day,-(@wd+1)%7, dateadd(month,1, convert(char(6),@d,112)+'01')));

print datename(year,@d)+': високосный год?';

/*1*/
if isdate(datename(year,@d)+'0229')=0
print 'НЕ ВИСОКОСНЫЙ'
else
print 'ВИСОКОСНЫЙ';

/*2*/
if month(dateadd(day,59, datename(year,@d)))=2
print 'ВИСОКОСНЫЙ'
else
print 'НЕ ВИСОКОСНЫЙ';
/*или*/
if day(dateadd(day,59, datename(year,@d)))=1
print 'НЕ ВИСОКОСНЫЙ'
else
print 'ВИСОКОСНЫЙ';

/*3*/
if year(@d)%4=0 and (year(@d)%100<>0 or year(@d)%400=0)
print 'ВИСОКОСНЫЙ'
else
print 'НЕ ВИСОКОСНЫЙ';

/*4*/
if datediff(day, datename(year,@d), dateadd(year,1, datename(year,@d)))=366
print 'ВИСОКОСНЫЙ'
else
print 'НЕ ВИСОКОСНЫЙ';

select 'Количество дней в году',
365+isdate(datename(year,@d)+'0229');

/*
http://www.sql.ru/forum/actualthread.aspx?bid=1&tid=414195#3983960
*/
print 'Номер недели по стандарту ISO-8601';
select
 case 0
  when datediff(week, dateadd(year,-1, datename(year,@d)+'1227'), dateadd(day,-1,@d))
  then datediff(week, dateadd(year,-1, datename(year,@d)+'0103'), dateadd(year,-1, datename(year,@d)+'1227'))
  when datediff(week, dateadd(year, 1, datename(year,@d)+'0103'), dateadd(day,-1,@d))
  then 0
  else datediff(week, datename(year,@d)+'0103', dateadd(day,-1,@d))
 end+1 as [Номер недели ISO-8601];
go