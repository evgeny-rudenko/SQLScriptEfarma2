
/****** Object:  UserDefinedFunction [dbo].[FormatDateTime]    Script Date: 06.11.16 10:07:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[FormatDateTime](@Format varchar(1000), @Time datetime)
RETURNS varchar(1000) AS
/*©Drkb v.3(2007): <a href="http://www.drkb.ru" title="www.drkb.ru">www.drkb.ru</a>, 
 ®Vit (Vitaly Nevzorov) - nevzorov@yahoo.com*/

BEGIN
 Declare @temp varchar(20)
/*Special substitutions to avoid formating prepared strings*/
 Declare @dddd varchar(35) Set @dddd='QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ'
 Declare @ddd varchar(35) Set @ddd= 'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW'
 Declare @mmmm varchar(35) Set @mmmm='EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE'
 Declare @mmm varchar(35) Set @mmm= 'RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR'
 Declare @am varchar(35) Set @am= 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'
 Declare @pm varchar(35) Set @pm= 'PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP'
--Declare xxx varchar(35) set xxx=''
 if PATINDEX('%dddd%' , @Format)>0 Set @Format=Replace(@Format,'dddd', @dddd)
 if PATINDEX('%ddd%' , @Format)>0 Set @Format= Replace(@Format,'ddd', @ddd)
 if PATINDEX('%mmmm%' , @Format)>0 Set @Format=Replace(@Format,'mmmm',@mmmm)
 if PATINDEX('%mmm%' , @Format)>0 Set @Format=Replace(@Format,'mmm', @mmm)
 if PATINDEX('%doy%' , @Format)>0 
 begin
  Declare @Doy int
  Set @Doy=Case Month(@Time)
  When 1 Then 0 
  When 2 Then 31 -- Jan
  Else 
  Case 
  When Year(@Time)%4=0 and Year(@Time)%400<>0 Then 31+29
  Else 31+28
  End -- Feb 
  End
  Set @Doy=Case Month(@Time)
  When 4 Then @Doy+31 -- Mar
  When 5 Then @Doy+31+30 -- Apr
  When 6 Then @Doy+31+30+31-- May
  When 7 Then @Doy+31+30+31+30-- Jun
  When 8 Then @Doy+31+30+31+30+31-- Jul
  When 9 Then @Doy+31+30+31+30+31+31-- Aug
  When 10 Then @Doy+31+30+31+30+31+31+30-- Sep
  When 11 Then @Doy+31+30+31+30+31+31+30+31-- Oct
  When 12 Then @Doy+31+30+31+30+31+31+30+31+30-- Nov
  Else @Doy
  End 
  Set @Doy=@Doy+Day(@Time) 
  Set @Format= Case 
  When @Doy<10 Then Replace(@Format,'doy', '00'+cast(@Doy as varchar(1)))
  When @Doy>=100 Then Replace(@Format,'doy', cast(@Doy as varchar(3)))
  Else Replace(@Format,'doy', '0'+cast(@Doy as varchar(2)))
  End 
 end 

 if PATINDEX('%dd%' , @Format)>0 
 begin
  if DATENAME(d, @time)<10
  Set @Format= Replace(@Format,'dd', '0'+DATENAME(d, @time))
  else
  Set @Format= Replace(@Format,'dd', DATENAME(d, @time))
 end 
 if PATINDEX('%d%' , @Format)>0 Set @Format= Replace(@Format,'d', DATENAME(d, @time))
 if PATINDEX('%yyyy%' , @Format)>0 Set @Format= Replace(@Format,'yyyy', Year(@Time))
 if PATINDEX('%yy%' , @Format)>0 Set @Format= Replace(@Format,'yy', Right(Cast(Year(@Time) as varchar(4)),2))
 if PATINDEX('%hh%' , @Format)>0 
 begin
  if PATINDEX('%am/pm%' , @Format)>0
  begin
  Set @Format=
  Case DATENAME(hh, @time)
  When 0 Then Replace(@Format,'hh', '12')
  When 1 Then Replace(@Format,'hh', '01')
  When 2 Then Replace(@Format,'hh', '02')
  When 3 Then Replace(@Format,'hh', '03')
  When 4 Then Replace(@Format,'hh', '04')
  When 5 Then Replace(@Format,'hh', '05')
  When 6 Then Replace(@Format,'hh', '06')
  When 7 Then Replace(@Format,'hh', '07')
  When 8 Then Replace(@Format,'hh', '08')
  When 9 Then Replace(@Format,'hh', '09')
  When 10 Then Replace(@Format,'hh', '10')
  When 11 Then Replace(@Format,'hh', '11')
  When 12 Then Replace(@Format,'hh', '12')
  When 13 Then Replace(@Format,'hh', '01')
  When 14 Then Replace(@Format,'hh', '02')
  When 15 Then Replace(@Format,'hh', '03')
  When 16 Then Replace(@Format,'hh', '04')
  When 17 Then Replace(@Format,'hh', '05')
  When 18 Then Replace(@Format,'hh', '06')
  When 19 Then Replace(@Format,'hh', '07')
  When 20 Then Replace(@Format,'hh', '08')
  When 21 Then Replace(@Format,'hh', '09')
  When 22 Then Replace(@Format,'hh', '10')
  When 23 Then Replace(@Format,'hh', '11')
  When 24 Then Replace(@Format,'hh', '12')
  End 
  Set @Format=
  Case 
  When DATENAME(hh, @time)<12 Then Replace(@Format,'am/pm', @am)
  Else Replace(@Format,'am/pm', @pm)
  End 
  end
  else
  begin
  if DATENAME(hh, @time)<10
  Set @Format= Replace(@Format,'hh', '0'+cast(DATENAME(hh, @time) as varchar(2)))
  else
  Set @Format= Replace(@Format,'hh', DATENAME(hh, @time))
  end
 end 
 if PATINDEX('%h%' , @Format)>0 
 begin
  if PATINDEX('%am/pm%' , @Format)>0
  begin
  Set @Format=
  Case DATENAME(hh, @time)
  When 0 Then Replace(@Format,'hh', '12')
  When 1 Then Replace(@Format,'hh', '1')
  When 2 Then Replace(@Format,'hh', '2')
  When 3 Then Replace(@Format,'hh', '3')
  When 4 Then Replace(@Format,'hh', '4')
  When 5 Then Replace(@Format,'hh', '5')
  When 6 Then Replace(@Format,'hh', '6')
  When 7 Then Replace(@Format,'hh', '7')
  When 8 Then Replace(@Format,'hh', '8')
  When 9 Then Replace(@Format,'hh', '9')
  When 10 Then Replace(@Format,'hh', '10')
  When 11 Then Replace(@Format,'hh', '11')
  When 12 Then Replace(@Format,'hh', '12')
  When 13 Then Replace(@Format,'hh', '1')
  When 14 Then Replace(@Format,'hh', '2')
  When 15 Then Replace(@Format,'hh', '3')
  When 16 Then Replace(@Format,'hh', '4')
  When 17 Then Replace(@Format,'hh', '5')
  When 18 Then Replace(@Format,'hh', '6')
  When 19 Then Replace(@Format,'hh', '7')
  When 20 Then Replace(@Format,'hh', '8')
  When 21 Then Replace(@Format,'hh', '9')
  When 22 Then Replace(@Format,'hh', '10')
  When 23 Then Replace(@Format,'hh', '11')
  When 24 Then Replace(@Format,'hh', '12')
  End 
  Set @Format=
  Case 
  When DATENAME(hh, @time)<12 Then Replace(@Format,'am/pm', @am)
  Else Replace(@Format,'am/pm', @pm)
  End 
  end
  else
  begin
  Set @Format= Replace(@Format,'h', DATENAME(hh, @time))
  end
 end
 if PATINDEX('%mm%' , @Format)>0 
 begin
  if Month(@Time)<10
  Set @Format= Replace(@Format,'mm', '0'+cast(Month(@Time) as varchar(2)))
  else
  Set @Format= Replace(@Format,'mm', Month(@Time))
 end 
 if PATINDEX('%m%' , @Format)>0 Set @Format= Replace(@Format,'m', Month(@Time))
 if PATINDEX('%nn%' , @Format)>0 
 begin
  if DATENAME(mi, @time)<10
  Set @Format= Replace(@Format,'nn', '0'+cast(DATENAME(mi, @time) as varchar(2)))
  else
  Set @Format= Replace(@Format,'nn', DATENAME(mi, @time))
 end 
 if PATINDEX('%n%' , @Format)>0 Set @Format= Replace(@Format,'n', DATENAME(mi, @time))
 if PATINDEX('%ss%' , @Format)>0 
 begin
  if DATENAME(ss, @time)<10
  Set @Format= Replace(@Format,'ss', '0'+cast(DATENAME(ss, @time) as varchar(2)))
  else
  Set @Format= Replace(@Format,'ss', DATENAME(ss, @time))
 end 
 if PATINDEX('%s%' , @Format)>0 Set @Format= Replace(@Format,'s', DATENAME(ss, @time))
 if PATINDEX('%'+@dddd+'%' , @Format)>0 
 begin
  Set @Format=
  Case DAtepart(weekday, @time) 
  When 1 Then Replace(@Format,@dddd, 'Sunday')
  When 2 Then Replace(@Format,@dddd, 'Monday')
  When 3 Then Replace(@Format,@dddd, 'Tuesday')
  When 4 Then Replace(@Format,@dddd, 'Wednesday')
  When 5 Then Replace(@Format,@dddd, 'Thursday')
  When 6 Then Replace(@Format,@dddd, 'Friday')
  When 7 Then Replace(@Format,@dddd, 'Saturday')
  End 
 end 
 if PATINDEX('%'+@ddd+'%' , @Format)>0 
 begin
  Set @Format=
  Case DAtepart(weekday, @time) 
  When 1 Then Replace(@Format,@ddd, 'Sun')
  When 2 Then Replace(@Format,@ddd, 'Mon')
  When 3 Then Replace(@Format,@ddd, 'Tue')
  When 4 Then Replace(@Format,@ddd, 'Wed')
  When 5 Then Replace(@Format,@ddd, 'Thu')
  When 6 Then Replace(@Format,@ddd, 'Fri')
  When 7 Then Replace(@Format,@ddd, 'Sat')
  End 
 end 
 if PATINDEX('%'+@mmmm+'%' , @Format)>0 
 begin
  Set @Format=
  Case DAtepart(month, @time) 
  When 1 Then Replace(@Format,@mmmm, 'January')
  When 2 Then Replace(@Format,@mmmm, 'February')
  When 3 Then Replace(@Format,@mmmm, 'March')
  When 4 Then Replace(@Format,@mmmm, 'April')
  When 5 Then Replace(@Format,@mmmm, 'May')
  When 6 Then Replace(@Format,@mmmm, 'June')
  When 7 Then Replace(@Format,@mmmm, 'July')
  When 8 Then Replace(@Format,@mmmm, 'August')
  When 9 Then Replace(@Format,@mmmm, 'September')
  When 10 Then Replace(@Format,@mmmm, 'October')
  When 11 Then Replace(@Format,@mmmm, 'November')
  When 12 Then Replace(@Format,@mmmm, 'December')
  End 
 end 
 if PATINDEX('%'+@mmm+'%' , @Format)>0 
 begin
  Set @Format=
  Case DAtepart(month, @time) 
  When 1 Then Replace(@Format,@mmm, 'Jan')
  When 2 Then Replace(@Format,@mmm, 'Feb')
  When 3 Then Replace(@Format,@mmm, 'Mar')
  When 4 Then Replace(@Format,@mmm, 'Apr')
  When 5 Then Replace(@Format,@mmm, 'May')
  When 6 Then Replace(@Format,@mmm, 'Jun')
  When 7 Then Replace(@Format,@mmm, 'Jul')
  When 8 Then Replace(@Format,@mmm, 'Aug')
  When 9 Then Replace(@Format,@mmm, 'Sep')
  When 10 Then Replace(@Format,@mmm, 'Oct')
  When 11 Then Replace(@Format,@mmm, 'Nov')
  When 12 Then Replace(@Format,@mmm, 'Dec')
  End 
 end 
-- if PATINDEX('%'+@am+'%' , @Format)>0 Set @Format=Replace(@Format, @am,'AM')
 --if PATINDEX('%'+@pm+'%' , @Format)>0 Set @Format=Replace(@Format, @pm,'PM')
--set xxx= @Format
Return @Format
end

GO

