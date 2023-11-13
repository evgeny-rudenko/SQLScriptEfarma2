USE [arm_eplus_work]
GO
/****** Object:  StoredProcedure [dbo].[USP_GM_GET_GOODS_GROUPS]    Script Date: 13.11.2023 17:26:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[USP_GM_GET_GOODS_GROUPS]
	@XML_DATA xml
as
select distinct x.value(N'.[1]', 'bigint') as ID_GOODS
into #G
from @XML_DATA.nodes(N'/XML/ID_GOODS') col(x)

declare @goods_codes table (id_goods bigint) --- все коды которые пришли во воходящих параметрах
insert into @goods_codes
	(id_goods)
	select #G.ID_GOODS from #G

declare @GM_DEFAULT_GROUP varchar (100) -- Группа по умолчанию Золотая сердина 
set @GM_DEFAULT_GROUP = 
		(select top 1 gg.NAME from GOODS_GROUP gg with (nolock) WHERE gg.NAME like 'Золотая Середина%' order by gg.NAME)

declare @result table (ID_GOODS bigint, GROUP_NAME varchar (100)) -- таблица для результирующего набора данных

-- то что нашли в справочнике - товары в группе ЗС
insert into @result 
	(ID_GOODS, GROUP_NAME)
	select #G.ID_GOODS, gg.NAME as GROUP_NAME
	from #G
		inner join GOODS_2_GROUP as g2g on g2g.ID_GOODS = #G.ID_GOODS
		inner join GOODS_GROUP as gg on gg.ID_GOODS_GROUP = g2g.ID_GOODS_GROUP
	where gg.DATE_DELETED is null and g2g.DATE_DELETED is null and gg.NAME like 'Золотая Середина%'

-- выбираем уникальные и делаем так чтобы товар был только в одной группу Золотая середина 
select  ID_GOODS, MAX(GROUP_NAME) as GROUP_NAME  from 
	(
	select ID_GOODS, GROUP_NAME from @result --- то что нашли в справочнике
	union 
	select ID_GOODS, @GM_DEFAULT_GROUP as GROUP_NAME from @goods_codes --- подставляем группу по умолчанию , если не нашли 
	) a 
group by ID_GOODS
