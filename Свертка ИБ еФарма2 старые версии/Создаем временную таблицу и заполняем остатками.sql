--select * from lot

/****** Object:  Table [dbo].[_IMPORT_REMAINS]    Script Date: 09/13/2010 14:02:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------------------------
--- первая часть - подготовка временных данных

-- дропаем таблицу
IF OBJECT_ID('_IMPORT_REMAINS') IS  NOT NULL drop  TABLE [dbo].[_IMPORT_REMAINS]

-- если в БД нет таблицы с остатками , то создаем ее
IF OBJECT_ID('_IMPORT_REMAINS') IS  NULL CREATE TABLE [dbo].[_IMPORT_REMAINS](
	[ID_SCALING_RATIO] [numeric](19, 0) NULL,
	[ID_GOODS] [numeric](19, 0) NULL,
	[ID_CONTRACTOR][numeric](19, 0) NULL,
	[ID_STORE][numeric](19, 0) NULL,
	[code_contr] [nvarchar](256) NULL, -- код поставщика
	[outer_code] [nvarchar](256) NULL, -- код препарата
	[quantity] [numeric](19, 2) NULL, --- количество
	[delen] [numeric](19, 2) NULL,    -- на сколько часте разделили
    [series] [nvarchar](256) NULL, ---- список серий
	[bestbefore] [datetime] NULL,  --- употребить до
	[sup_price] [numeric](19, 2) NULL, -- цена завода
	[ret_price] [numeric](19, 2) NULL, -- цена поставщика
	[taxrater] [numeric](19, 2) NULL,  -- НДС
	[taxrates] [numeric](19, 2) NULL,  -- НДС
	[prod_price] [numeric](19, 2) NULL, -- розничная цена
	[sklad] [nvarchar](256) NULL, -- код склада
	[shtrihc] [nvarchar](256) NULL, -- штрих код партии
	[sf_number] [nvarchar](256) NULL, -- номер документа поставщика
	[sf_date] [datetime] NULL -- дата документа поставщика

) ON [PRIMARY]

IF OBJECT_ID('_IMPORT_REMAINS') IS  not NULL delete from [dbo].[_IMPORT_REMAINS]


--- теперь заполняем текущие остатки из таблицы с патиями


insert into _import_remains 
(
	ID_SCALING_RATIO,
	ID_GOODS,
	ID_CONTRACTOR,
	ID_STORE,
	code_contr, -- код поставщика
	outer_code, -- код препарата
	quantity, --- количество
	delen,    -- на сколько часте разделили
	series, ---- список серий
	bestbefore,  --- употребить до
	sup_price, -- цена завода
	ret_price, -- цена поставщика
	taxrater,  -- НДС
	taxrates,  -- НДС
	prod_price, -- розничная цена
	sklad, -- код склада
	shtrihc, -- штрих код партии
	sf_number, -- номер документа поставщика
	sf_date -- дата документа поставщика
)
(
select 
lot.ID_SCALING_RATIO,
lot.ID_GOODS,
--lot.ID_CONTRACTOR,
lot.id_supplier,
lot.ID_STORE,
id_supplier ,
lot.id_goods, 
quantity_rem ,
denominator,
series.series_number,
series.best_before,
price_sup,
price_sal, 
vat_sal ,
vat_sal,
price_prod,
id_store,
internal_barcode,
'' incoming_num,
'' incoming_date
--incoming_num, -- в старой версии этого поля нет
--incoming_date -- в старой версии этого поля нет
 from lot , scaling_ratio , series
where quantity_rem >0
and lot.id_scaling_ratio = scaling_ratio.id_scaling_ratio
and series.id_series =* lot.id_series -- серии есть не у всех партий
)


--------------------------------------------------------
---- вторая часть . 
---- загрузка остатков в виде накладных

-- 2.1
-- чистим базу, обновляем структуру таблиц и харнимые процедуры
-- delete from все ненужные таблицы

-- 2.2 импортируем наши накладные
--select * from _import_remains
-- импорт данных из временной таблицы
-- запускаем руками после очистки всех данных из ефармы
--exec USP_REMAINS_IMPORT_1C

