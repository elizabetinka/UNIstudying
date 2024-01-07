-- Цель работы: Выборка данных из нескольких таблиц.

-- Суперключ – атрибут или множество атрибутов, единственным образом идентифицирующие кортеж.
-- Потенциальный ключ – суперключ, который не содержит подмножества, также являющегося суперключом данного отношения. Отношение может иметь несколько потенциальных ключей. Если потенциальный ключ состоит из нескольких атрибутов, он называется составным ключом.
-- Первичный ключ – потенциальный ключ, который выбран для уникальной идентификации кортежей внутри отношения.
-- Внешний ключ – атрибут или множество атрибутов внутри отношения, которое соответствует потенциальному ключу некоторого (может быть, того же самого) отношения. Внешние ключи позволяют описать связь между отношениями.

/*
1 Найти название продуктов и название подкатегорий этих продуктов, у которых отпускная цена больше 100, 
не включая случаи, когда продукт не относится ни к какой подкатегории.

Select p.Name, s.Name
from [Production].Product as p INNER JOIN [Production].ProductSubcategory as s on p.ProductSubcategoryID = s.ProductSubcategoryID
WHERE p.ListPrice > 100


2 Найти название продуктов и название подкатегорий этих продуктов, у которых отпускная цена больше 100, включая случаи, когда 
продукт не относится ни к какой категории.

Select p.Name, s.Name
from [Production].Product as p LEFT JOIN [Production].ProductSubcategory as s on p.ProductSubcategoryID = s.ProductSubcategoryID
WHERE p.ListPrice > 100

3 Найти название продуктов и название категорий из таблицы ProductCategory, с которой связан этот продукт, не включая случаи, 
когда у продукта нет подкатегории.

SELECT p.Name, c.Name
FROM Production.Product as p INNER JOIN 
Production.ProductSubcategory as s 
on (p.ProductSubcategoryID = s.ProductSubcategoryID)
INNER JOIN Production.ProductCategory as c 
on (s.ProductCategoryID = c.ProductCategoryID)

4 Найти название продукта, отпускную цену продукта, а также последнюю отпускную цену этого продукта (LAStReceiptCost), которую 
можно узнать из таблицы ProductVendor.

SELECT p.Name, p.ListPrice, PV.LastReceiptCost
FROM [Production].Product as p LEFT JOIN [Purchasing].ProductVendor as PV
ON (p.ProductID = PV.ProductID)

5 Найти название продукта, отпускную цену продукта, а также последнюю отпускную цену этого продукта (LAStReceiptCost), которую можно узнать 
из таблицы ProductVendor, для таких продуктов, у которых отпускная цена оказалась ниже последней отпускной цены у поставщика, исключив те 
товары, для которых отпускная цена равна нулю.

SELECT p.Name, p.ListPrice, PV.LastReceiptCost
FROM [Production].Product as p INNER JOIN [Purchasing].ProductVendor as PV
ON (p.ProductID = PV.ProductID)
WHERE p.ListPrice<PV.LastReceiptCost AND p.ListPrice != 0 

6 Найти количество товаров, которые поставляют поставщики с самым низким кредитным рейтингом (CreditRatINg принимает целые значение от 
минимального, равного 1, до максимального, равного 5).

SELECT count(Distinct pv.ProductID)
fROM Purchasing.ProductVendor as pv INNER JOIN Purchasing.Vendor as v
ON (pv.BusinessEntityID = v.BusinessEntityID)
WHERE v.CreditRating = 1

7 Найти, сколько товаров приходится на каждый кредитный рейтинг, т.е. сформировать таблицу, первая колонка которой будет содержать номер 
кредитного рейтинга, вторая – количество товаров, поставляемых всеми поставщиками, имеющими соответствующий кредитный рейтинг. 
Необходимо сформировать универсальный запрос, который будет валидным и в случае появления новых значений кредитного рейтинга.

SELECT v.CreditRating, count (DISTINCT pv.ProductID)
FROM Purchasing.ProductVendor as pv INNER JOIN
Purchasing.Vendor as v
ON pv.BusinessEntityID = v.BusinessEntityID
GROUP BY v.CreditRating

8 Найти номера первых трех подкатегорий (ProductSubcategoryID) с наибольшим количеством наименований товаров.

SELECT TOP 3 p.ProductSubcategoryID
From Production.Product as p INNER JOIN
Production.ProductSubcategory as ps
ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY p.ProductSubcategoryID
ORDER BY COunt (Distinct ProductID) DESC

SELECT TOP 3 p.ProductSubcategoryID
From Production.Product as p 
Where p.ProductSubcategoryID IS NOT null
GROUP BY p.ProductSubcategoryID
ORDER BY COunt (Distinct ProductID) DESC

9 Получить названия первых трех подкатегорий с наибольшим количеством наименований товаров.

SELECT TOP 3 ps.Name, ps.ProductSubcategoryID
From Production.Product as p INNER JOIN
Production.ProductSubcategory as ps
ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY ps.ProductSubcategoryID, ps.Name
ORDER BY COunt (Distinct ProductID) DESC

10 Высчитать среднее количество товаров, приходящихся на одну подкатегорию, с точностью минимум до одной десятой.

select 1.0*count(ProductID)/count(DIstinct ProductSubcategoryID)
from Production.Product
WHERE Product.ProductSubcategoryID IS NOT NULL

select cast(count(*) as float)/count(DIstinct ProductSubcategoryID)
from Production.Product
WHERE Product.ProductSubcategoryID IS NOT NULL

select cast(cast(count(*) as float)/count(DIstinct ProductSubcategoryID) as DECIMAL (3,2))
from Production.Product
WHERE Product.ProductSubcategoryID IS NOT NULL

11 Вычислить среднее количество товаров, приходящихся на одну категорию, в целых числах.

select count(ProductID)/count(Distinct ProductCategoryID)
from Production.Product as p INNER JOIN
Production.ProductSubcategory as ps 
On p.ProductSubcategoryID  = ps.ProductSubcategoryID

Этот варик прравильней так как могут появится новые категории которые не используются
SELECT COUNT(ProductID)/COUNT(DISTINCT PC.ProductCategoryID)
FROM [Production].[Product] AS P INNER JOIN
[Production].[ProductSubcategory] AS PSC
ON P.ProductSubcategoryID=PSC.ProductSubcategoryID
RIGHT JOIN [Production].[ProductCategory] AS PC
ON PSC.ProductCategoryID=PC.ProductCategoryID

12 Найти количество цветов товаров, приходящихся на каждую категорию, без учета товаров, для которых цвет не определен.

SELECT  PC.ProductCategoryID,COUNT(DISTINCT Color) as 'colorCount'
FROM [Production].[Product] AS P INNER JOIN
[Production].[ProductSubcategory] AS PSC
ON P.ProductSubcategoryID=PSC.ProductSubcategoryID
Right JOIN [Production].[ProductCategory] AS PC
ON PSC.ProductCategoryID=PC.ProductCategoryID
Group BY PC.ProductCategoryID

13 Найти средний вес продуктов. Просмотреть таблицу продуктов и убедиться, что есть продукты, для которых вес не определен. 
Модифицировать запрос так, чтобы при нахождении среднего веса продуктов те продукты, для которых вес не определен, считались как 
продукты с весом 10.

SELECT AVG(ISNULL([Weight],10))
FROM [Production].[Product]

14 Вывести названия продуктов и период их активных продаж (период между SellStartDate и SellEndDate) в днях, отсортировав по уменьшению 
времени продаж. Если продажи идут до сих пор и SellEndDate не определен, то считать периодом продаж число дней с начала продаж и по текущие 
сутки.

SELECT Name,SellStartDate,SellEndDate, DATEDIFF(day,SellStartDate, ISNULL([SellEndDate], GETDATE()))
FROM Production.Product
WHERE [SellStartDate] IS NOT NULL
ORDER BY DATEDIFF(day,SellStartDate, ISNULL([SellEndDate], GETDATE())) DESC

15 Разбить продукты по количеству символов в названии, и для каждой группы определить количество продуктов.
Select  len(Name),count(ProductID)
from Production.Product
GROUP BY len(Name)

16 Найти для каждого поставщика количество подкатегорий продуктов, к которым относится продукты, поставляемые им, без учета ситуации, 
когда продукт не относится ни к какой подкатегории.

SELECt BusinessEntityID, count(Distinct ProductSubcategoryID)
from Purchasing. ProductVendor as pv INNer JOIN
Production.Product as p
on pv.ProductID = p.ProductID
Where ProductSubcategoryID IS NOT NULL
Group BY BusinessEntityID

17 Проверить, есть ли продукты с одинаковым названием, если есть, то вывести эти названия.

SELECT p1.Name
from Production.Product as p1 INNER JOIN
Production.Product as p2
on p1.Name = p2.Name and p1.ProductID != p2.ProductID

18 Найти первые 10 самых дорогих товаров, с учетом ситуации, когда цена цены у некоторых товаров могут совпадать.

SELECT TOP 10 WITH TIES ProductID
FROM [Production].[Product]
ORDER BY ListPrice DESC

19 Найти первые 10 процентов самых дорогих товаров, с учетом ситуации, когда цены у некоторых товаров могут совпадать.

SELECT TOP 10 PERCENT WITH TIES ProductID
FROM [Production].[Product]
ORDER BY ListPrice DESC

20 Найти первых трех поставщиков, отсортированных по количеству поставляемых товаров, с учетом ситуации, что количество поставляемых 
товаров может совпадать для разных поставщиков.

SELECT TOP 3 WITH TIES BusinessEntityID
FROM Purchasing.ProductVendor
GROUP BY BusinessEntityID
ORDER BY count(ProductID) desc

странное решениее:
SELECT TOP 3 WITH TIES PV.BusINessEntityID
FROM [Production].[Product] AS P INNER JOIN
[PurchASINg].[ProductVendor] AS PV
ON P.ProductID=PV.ProductID
GROUP BY PV.BusINessEntityID
ORDER BY COUNT(P.ProductID) DESC

                                                                    Лабораторная 3

1 Найти и вывести на экран название продуктов и название категорий товаров, к которым относится этот продукт, с учетом того, что 
в выборку попадут только товары с цветом Red и ценой не менее 100.  

SELECT p.Name, pc.Name
FROM Production.Product as p LEFT JOIN
Production.ProductSubcategory as ps 
on (p.ProductSubcategoryID = ps.ProductSubcategoryID)
LEFT JOIN Production.ProductCategory as pc 
on (ps.ProductCategoryID = pc.ProductCategoryID)
WHERE Color = 'Red' and ListPrice >= 100

2 Вывести на экран названия подкатегорий с совпадающими именами.

SELECT p1.Name
FROM Production.ProductSubcategory as p1 INNER JOIN
Production.ProductSubcategory as p2 
on (p1.ProductSubcategoryID != p2.ProductSubcategoryID AND p1.Name = p2.Name)

select Name
from Production.ProductSubcategory
GROUP BY ProductCategoryID, Name
Having count(*) > 1

3 Вывести на экран название категорий и количество товаров в данной категории.

SElect pc.Name, count(distinct ProductID)
from Production.ProductCategory as pc lEFT JOIN
Production.ProductSubcategory as ps 
on (pc.ProductCategoryID = ps.ProductCategoryID) 
LEFT JOIN Production.Product as p 
on (ps.ProductSubcategoryID = p.ProductSubcategoryID)
GROUP BY pc.ProductCategoryID, pc.Name


4 Вывести на экран название подкатегории, а также количество товаров в данной подкатегории с учетом ситуации, что могут существовать 
подкатегории с одинаковыми именами.

SELECT ps.Name, count(distinct p.ProductID)
FROM Production.ProductSubcategory as ps LEFT JOIN 
Production.Product as p
on (ps.ProductSubcategoryID = p.ProductSubcategoryID)
GROUP BY ps.ProductSubcategoryID, ps.Name

5 Вывести на экран название первых трех подкатегорий с небольшим количеством товаров. (типа минимальным)

SELECT TOP 3 ps.Name
from Production.ProductSubcategory as ps LEFT JOIN
Production.Product as p
on(ps.ProductSubcategoryID = p.ProductSubcategoryID)
GROUP BY ps.Name
ORDER BY count(distinct p.ProductID) ASC

6 Вывести на экран название подкатегории и максимальную цену продукта с цветом Red в этой подкатегории.

select ps.Name, max(p.ListPrice)
from Production.ProductSubcategory as ps LEFT JOIN
Production.Product as p 
on (ps.ProductSubcategoryID = p.ProductSubcategoryID)
WHERE p.Color = 'Red'
GROUP BY ps.Name

7 Вывести на экран название поставщика и количество товаров, которые он поставляет.

select v.Name, count(distinct ProductID)
from Purchasing.ProductVendor as pv LEFT JOIN
Purchasing.Vendor as v 
on (pv.BusinessEntityID = v.BusinessEntityID)
GROUP BY pv.BusinessEntityID, v.Name

8 Вывести на экран название товаров, которые поставляются более чем одним поставщиком.

select p.Name
from Purchasing.ProductVendor as pv LEFT JOIN
Production.Product as p 
on (pv.ProductID = p.ProductID)
GROUP BY pv.ProductID,p.Name
HAVING count(BusinessEntityID) > 1

9 Вывести на экран название самого продаваемого товара.

select TOP 1 p.Name
from Sales.SalesOrderDetail as sod LEFT JOIN
Production.Product as p 
on (sod.ProductID = p.ProductID)
GROUP By sod.ProductID, p.Name
ORDER BY count(*) DESC

select TOP 1 p.Name, sum(OrderQty)
from Sales.SalesOrderDetail as sod LEFT JOIN
Production.Product as p 
on (sod.ProductID = p.ProductID)
GROUP By sod.ProductID, p.Name
ORDER BY sum(OrderQty) DESC

 Ну это выпендреж
select TOP 1 p.Name, sum(OrderQty)
from Sales.SalesOrderDetail as sod LEFT JOIN
Production.Product as p 
on (sod.ProductID = p.ProductID)
GROUP By sod.ProductID, p.Name
ORDER BY 1.0*sum(OrderQty)/ DATEDIFF(day,min(p.SellStartDate),ISNull(max(p.SellEndDate), GETDATE())) DESC


10 Вывести на экран название категории, товары из которой продаются наиболее активно.

select TOP 1 pc.Name
from Production.ProductCategory as pc INNER JOIN 
Production.ProductSubcategory as ps 
on (pc.ProductCategoryID = ps.ProductCategoryID)
INNER JOIN Production.Product as p 
on (ps.ProductSubcategoryID = p.ProductSubcategoryID)
LEFT JOIN Sales.SalesOrderDetail as sod 
on (p.ProductID = sod.ProductID)
GROUP BY pc.ProductCategoryID, pc.Name
ORDER BY 1.0*sum(OrderQty)/ DATEDIFF(day,min(p.SellStartDate),ISNull(max(p.SellEndDate), GETDATE())) DESC

11 Вывести на экран названия категорий, количество подкатегорий и количество товаров в них.

select pc.Name, count(distinct p.ProductSubcategoryID),count(p.ProductID)
from Production.Product as p LEFT JOIN 
Production.ProductSubcategory as ps 
on (p.ProductSubcategoryID = ps.ProductSubcategoryID)
LEFT JOIN Production.ProductCategory as pc 
on (ps.ProductCategoryID = pc.ProductCategoryID)
GROUP BY pc.ProductCategoryID, pc.Name

12 Вывести на экран номер кредитного рейтинга и количество товаров, поставляемых компаниями, имеющими этот кредитный рейтинг.

select CreditRating, count (ProductID)
from Purchasing.Vendor as v LEFT JOIN
Purchasing.ProductVendor as pv 
on (v.BusinessEntityID = pv.BusinessEntityID)
GROUP BY CreditRating
*/















