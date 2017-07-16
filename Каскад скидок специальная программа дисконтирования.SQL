/*

http://samson.protek.ru:8080/issues/10166
" Скидка диференцированная в зависимости от количества упаковок в чеке, не зависит от наименования товара: может быть как одинаковые так и разные наименования. 
Первая упаковка - без скидки 
вторая упаковка - скидка 5% 
третья упаковка - скидка 10% 
четвертая и каждая последующая упаковка - скидка 15% 
Скидка предоставляется по принципу: на самую дорогую упаковку в чеке скидка 5%, на самую дешевую упаковку в чеке скидка 15%, не зависимо от того в каком порядке кассир пробивал товар. 
Если цена на упаковки одинаковая, скидка предоставляется: 
на одну упаковку - 0%, 
на вторую - 5% 
на третью - 10% 
на четвертую - 15% и на все последующие - 15% 
Скидка не предоставляется на: шприцы, бахилы, маски медицинские, перчатки, контейнеры для анализов, пипетки, напальчники. 
Порог рентабельности не учитывается. 
Скидки не суммируются, на акционный товар не распространяются. 
На ЖНВЛП скидка распространяется. 
Скидка имеет временные рамки. 
Должна быть предусмотрена возможность выбора складов. "

Товары, на которые не должна действовать скидка будут перенесены в отдельную группу
*/

if (object_id('discount2_special_cascad') is null) exec ('create procedure discount2_special_cascad as return')
go
alter procedure discount2_special_cascad(
    @id_discount2_global uniqueidentifier
)
as
    -------------------------------------------------------------------------------------------
    -- заполнение параметров (начало)
    -------------------------------------------------------------------------------------------
    create table #store(
        id_store_global uniqueidentifier not null primary key
    )

    -- тут указывается список складов для скидки
    -- нужно заполнить таблицу #store
    -- если список складов не указан, то скидка дейсвует на всех складах

    create table #period(
        time_from int null,
        time_to int null
    )

    -- тут указывается период действия скидки
    -- нужно заполнить таблицу #period
    -- time_from - время начала. Количество секунд прошедших с полуночи
    -- time_to - время окончания. Количество секунд прошедших с полуночи
    -- если период не указан, то скидка действует весь день

    create table #exclude_goods_group(
        id_goods_group_global uniqueidentifier not null primary key
    )

    -- тут указывается группы товаров на которые не распространяется скидка
    -- нужно заполнить таблицу #exclude_goods_group    
    -- если список групп не указан, то скидка распространяется на все товары

    -------------------------------------------------------------------------------------------
    -- заполнение параметров (окончание)
    -------------------------------------------------------------------------------------------

    declare @CHEQUE_DATE datetime
    select top 1 @CHEQUE_DATE = CHEQUE_DATE
    from #chequeinfo c

    DECLARE @SECONDS_PAST_MINIGHT INT
    SELECT @SECONDS_PAST_MINIGHT = DATEPART(hh, @CHEQUE_DATE)*3600+DATEPART(mi, @CHEQUE_DATE)*60+DATEPART(ss, @CHEQUE_DATE)

    if
    (
        exists 
        (
            select null 
            from #period
        )
        and
        (
            not exists
            (
                select null
                from #period
                where 1=1
                and
                (
                    (
                        isnull(time_from,0) <= isnull(time_to,0)
                        and
                        (
                            (time_from is null or time_from <= @SECONDS_PAST_MINIGHT)
                            and
                            (time_to is null or time_to > @SECONDS_PAST_MINIGHT)
                        )
                    )
                    or
                    (
                        isnull(time_from,0) > isnull(time_to,0)
                        and
                        (
                            (time_from is null or time_from <= @SECONDS_PAST_MINIGHT)
                            or
                            (time_to is null or time_to > @SECONDS_PAST_MINIGHT)
                        )
                    )
                )
            )
        )            
    )
    begin
        return
    end

    ;with cte
    as
    (
        select
            c.id_lot_global,
            c.qty
        from #chequeinfo c
        inner join lot l on l.id_lot_global = c.id_lot_global
        inner join store s on s.id_store = l.id_store
        inner join scaling_ratio sr on sr.id_scaling_ratio = l.id_scaling_ratio
        where 1=1
        and sr.numerator=1
        and sr.denominator=1
        and 
        (
            not exists
            (
                select null
                from goods_2_group g2g
                inner join goods_group gg on gg.id_goods_group = g2g.id_goods_group
                where g2g.date_deleted is null
                and g2g.id_goods = l.id_goods
                and 
                (
                    exists
                    (
                        select null
                        from #exclude_goods_group t
                        where t.id_goods_group_global = gg.id_goods_group_global
                    )
                )
            )
        )
        and 
        (
            not exists
            (
                select null
                from #store
            )
            or 
            (
                exists
                (
                    select null
                    from #store t
                    where t.id_store_global = s.id_store_global
                )
            )                
        )
        union all
        select
            c.id_lot_global,
            qty = c.qty-1
        from cte c
        where c.qty-1>0
    )
    update ci set
        discount_value = isnull(ci.discount_value,0)+round(a.discount_value,2),
        sum_with_discount = ci.sum_with_discount - round(a.discount_value,2)
    from #chequeinfo ci
    inner join 
    (
        select
            a.id_lot_global,
            discount_value = sum(a.discount_value)
        from
        (
            select
                a.id_lot_global,
                discount_value =
                    case a.rn
                        when 1 then 0
                        when 2 then a.price * 0.05
                        when 3 then a.price * 0.1
                        else a.price * 0.15
                    end                
            from
            (
                select
                    rn = row_number() over(order by ci.price desc),
                    c.id_lot_global,
                    ci.price
                from cte c
                inner join #chequeinfo ci on ci.id_lot_global = c.id_lot_global
            ) a    
        ) a
        group by a.id_lot_global            
    ) a on a.id_lot_global = ci.id_lot_global
return
go