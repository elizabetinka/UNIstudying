/*
найти количество чеков, приходящихся на одного покупателя на каждый год.

WITH Sales_CTE (SalesPersonID, SalesORDERID, SalesYear)
AS
(
SELECT SalesPersonID, SalesORDERID, YEAR(ORDERDate) AS SalesYear FROM Sales.SalesORDERHeader
WHERE SalesPersonID IS NOT NULL
)
SELECT SalesPersonID, COUNT(SalesORDERID) AS TotalSales, SalesYear
FROM Sales_CTE
GROUP BY SalesYear, SalesPersonID
ORDER BY SalesPersonID, SalesYear

1 Найти покупателя, который каждый раз имел разный список товаров в чеке (по номенклатуре)

SELECT tmp.c
FROM
    (SELECT soh.CustomerID AS c , soh.SalesORDERID AS o, CHECKSUM_AGG(sod.ProductID) AS ch
    FROM [Sales].[SalesORDERDetail] AS sod JOIN
    [Sales].[SalesORDERHeader] AS soh
    ON sod.SalesORDERID=soh.SalesORDERID
    GROUP BY soh.CustomerID, soh.SalesORDERID) tmp
GROUP BY tmp.c
HAVING count(tmp.ch)=count(DISTINCT tmp.ch)
AND count(tmp.ch)>1


2 Найти пары таких покупателей, что список названий товаров, которые они когда-либо покупали, не пересекается ни в одной позиции.





3 Вывести номера продуктов, таких, что их цена выше средней цены продукта в подкатегории, к которой относится продукт. 
Запрос реализовать двумя способами. В одном из решений допускается использование обобщенного табличного выражения.


Select p.ProductID
from Production.Product as p INNER JOIN 
    (SELECT p.ProductSubcategoryID as SubId, AVG(ListPrice) as avg
    from Production.Product as p
    GROUP BY p.ProductSubcategoryID
    ) as s 
on p.ProductSubcategoryID = s.SubID
WHERE p.ListPrice > s.[avg]

----
WITH SubCatAVG(SubcategoryID, avg)
AS
(
SELECT p.ProductSubcategoryID, AVG(ListPrice) as avg
from Production.Product as p
GROUP BY p.ProductSubcategoryID
)

Select p.ProductID
from Production.Product as p INNER JOIN 
    SubCatAVG as s 
on p.ProductSubcategoryID = s.SubcategoryID
WHERE p.ListPrice > s.[avg]


6 Найти номера покупателей, у которых все купленные ими товары были куплены как минимум дважды, т.е. на два разных чека.

WITH MyTable(cus, prod, c)
AS
(
SELECT soh.CustomerID, sod.ProductID, count(*) as c
from Sales.SalesOrderDetail as sod Inner JOIN
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
GROUP BY soh.CustomerID, sod.ProductID
)

select t.cus
from MyTable as t
GROUP BY t.cus
Having not exists (
    select t2.prod
    from MyTable as t2 
    where t2.cus = t.cus and t2.c<2
)


5 Найти номера покупателей, у которых не было нет ни одной пары чеков с одинаковым количеством наименований товаров.

With MyTable (cus, id, c) as 
(select soh.CustomerID, sod.SalesOrderID, count(*)
from Sales.SalesOrderDetail as sod INNER JOIN
Sales.SalesORDERHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
GROUP BY soh.CustomerID, sod.SalesOrderID)

select distinct t1.cus
from MyTable as t1 
where not exists (
    select *
    from MyTable as t2 
    Where t2.cus = t1.cus and t2.id != t1.id and t2.c = t1.c
)


4 Вывести для каждого покупателя информацию о максимальной и минимальной стоимости одной покупки, чеке, в виде таблицы: 
номер покупателя, максимальная сумма, минимальная сумма.

with MyTable (id, cus, cost) as 
(select sod.SalesOrderID, soh.CustomerID, sum(OrderQty * UnitPrice)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
GROUP BY sod.SalesOrderID, soh.CustomerID)

select t.cus, max(t.cost), min(t.cost)
from MyTable t
GROUP by t.cus


3 Вывести на экран следящую информацию: Название продукта, Общее количество фактов покупки этого продукта, 
Общее количество покупателей этого продукта


with MyTable (prod, c1, c2) as 
(select sod.ProductID, count(distinct sod.SalesOrderID), count(distinct soh.CustomerID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
Group BY sod.ProductID)

select p.Name, t.c1, t.c2
from Production.Product as p LEFT JOIN 
MyTable as t 
on p.ProductID = t.prod


2 Найти для каждого продукта и каждого покупателя соотношение количества фактов покупки данного товара данным покупателем 
к общему количеству фактов покупки товаров данным покупателем


with MyTable1 (cus, c) as 
(select soh.CustomerID, count(distinct sod.SalesOrderID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
GROUP BY soh.CustomerID),

MyTable2 (cus, prod, c) as 
(select soh.CustomerID,sod.ProductID, count(distinct sod.SalesOrderID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
GROUP BY soh.CustomerID, sod.ProductID)

select t2.cus, t2.prod, cast (t2.c as float)/t1.c
from MyTable2 as t2 LEFT JOIN 
MyTable1 as t1
on t1.cus = t2.cus


1 Найти среднее количество покупок на чек для каждого покупателя (2 способа).

with MyTable (cus, id, c) as
(select soh.CustomerID, sod.SalesOrderID, count(distinct sod.ProductID)
from Sales.SalesOrderDetail as sod  INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
Group BY soh.CustomerID, sod.SalesOrderID)

select t.cus, cast (avg(t.c) as float)
from MyTable as t
Group by t.cus




with MyTable (cus, id, c) as
(select soh.CustomerID, sod.SalesOrderID, count(distinct sod.ProductID)
from Sales.SalesOrderDetail as sod  INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
Group BY soh.CustomerID, sod.SalesOrderID)

select t.cus, cast (avg(t.c) as float)
from (select soh.CustomerID as cus, sod.SalesOrderID as id, count(distinct sod.ProductID) as c
from Sales.SalesOrderDetail as sod  INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
Group BY soh.CustomerID, sod.SalesOrderID) t
Group by t.cus


Вывести количество покупок товаров, а также отношение количества покупателей данного товара к количеству покупателей товара в 
данного категории для этого товара

with MyTable1 (prod, с1, c2) as 
(select sod.ProductID, count(distinct sod.SalesOrderID) , count(distinct soh.CustomerID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
Group by sod.ProductID), 
MyTable2 (cat, c) as 
(select ps.ProductcategoryID, count (distinct soh.CustomerID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID= soh.SalesOrderID
INNER JOIN Production.Product as p 
on p.ProductID = sod.ProductID INNER JOIN 
Production.ProductSubCategory as ps 
on ps.ProductSubcategoryID = p.ProductSubcategoryID
Group BY ps.ProductcategoryID),
MyTable3 (prod, cat) as 
(select p.ProductID, ps.ProductcategoryID
from Production.Product as p INNER JOIN 
Production.ProductSubCategory as ps 
on ps.ProductSubcategoryID = p.ProductSubcategoryID)

Select t1.prod, t1.с1, cast(t1.c2 as float)/t2.c
from MyTable1 as t1 LEFT JOIN 
MyTable3 as t3 
on t1.prod = t3.prod LEFT JOIN 
MyTable2 as t2
on t2.cat = t3.cat





6 Найти номера покупателей, у которых все купленные ими товары были куплены как минимум дважды, т.е. на два разных чека.


with MyTable (cus, prod, c) as 
(select soh.CustomerID, sod.ProductID, count(distinct sod.SalesOrderID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
GRoUP BY soh.CustomerID, sod.ProductID)

select t.cus
from MyTable  as t
GROUP BY t.cus 
HAVING not exists(
    select t2.prod
    from MyTable as t2
    WHERE t2.cus = t.cus and t2.c < 2
)


5 Найти номера покупателей, у которых не было нет ни одной пары чеков с одинаковым количеством наименований товаров.

with MyTable (cus, id, c) as 
(select soh.CustomerID, sod.SalesOrderID, count(distinct sod.ProductID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
Group BY soh.CustomerID, sod.SalesOrderID)

select distinct t.cus
from MyTable as t
where  Not exists (
    select t2.id
    from MyTable as t2 
    WHERE t2.cus = t.cus and t2.c = t.c and t2.id != t.id
)



4 Вывести для каждого покупателя информацию о максимальной и минимальной стоимости одной покупки, чеке, в виде таблицы: номер покупателя, 
максимальная сумма, минимальная сумма.


with MyTable (cus, id, cost) as 
(select soh.CustomerID, sod.SalesOrderID, sum(OrderQty * UnitPrice)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID 
Group BY soh.CustomerID, sod.SalesOrderID)

select t.cus, min(t.cost), max(t.cost) 
from MyTable as t
Group BY t.cus


3 Вывести на экран следящую информацию: Название продукта, Общее количество фактов покупки этого продукта, 
Общее количество покупателей этого продукта

with MyTable (prod, nam) as 
(select p.ProductID, p.Name 
from Production.Product as p)

select t.nam, count(distinct sod.SalesOrderID), count(distinct soh.CustomerID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID LEFT JOIN 
MyTable as t 
on t.prod = sod.ProductID
GROUP BY t.nam

2 Найти для каждого продукта и каждого покупателя соотношение количества фактов покупки данного товара данным покупателем 
к общему количеству фактов покупки товаров данным покупателем

with MyTable (cus, c) as 
(select soh.CustomerID, count(sod.SalesOrderID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
Group By soh.CustomerID),
MyTable2 (cus, prod, c) as 
(select soh.CustomerID,sod.ProductID, count(sod.SalesOrderID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
Group By soh.CustomerID, sod.ProductID)

select t1.cus, t1.prod, cast (t1.c as float)/t2.c
from MyTable2 as t1 LEFT JOIN 
MyTable as t2 
on t1.cus = t2.cus


Вывести количество покупок товаров, а также отношение количества покупателей данного товара к количеству покупателей товара в 
данного категории для этого товара

with MyTable1 (prod, c1, c2) as 
(select sod.ProductID, count(distinct sod.SalesOrderID), count(distinct soh.CustomerID) 
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
GROUP BY sod.ProductID), 
MyTable2 (prod, cat ) as 
(select p.ProductID, ps.ProductCategoryID
from Production.Product as p INNER JOIN 
Production.ProductsubCategory as ps 
on p.ProductSubcategoryID = ps.ProductSubcategoryID),
MyTable3 (cat, c) as (
    select ps.ProductCategoryID, count( distinct soh.CustomerID)
    from Sales.SalesOrderDetail as sod INNER JOIN 
    Sales.SalesOrderHeader as soh 
    on sod.SalesOrderID = soh.SalesOrderID INNER JOIN 
    Production.Product as p 
    on sod.ProductID = p.ProductID INNER JOIN 
    Production.ProductsubCategory as ps 
    on p.ProductSubcategoryID = ps.ProductSubcategoryID
    Group BY ps.ProductCategoryID
)
select t1.prod, t1.c1, cast (t1.c2 as float)/t3.c
from MyTable1 as t1 INNER JOIN 
MyTable2 as t2 
on t1.prod = t2.prod INNER JOIN 
MyTable3 as t3 
on t2.cat = t3.cat


1 Найти среднее количество покупок на чек для каждого покупателя (2 способа).

with MyTable (cus, id, c) as 
(select soh.CustomerID, sod.SalesOrderID, count(distinct sod.ProductID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
group by soh.CustomerID, sod.SalesOrderID)

select * 
from MyTable as t
group by 




Вывести номер покупателя, название продукта который он покупал 3 раза, название продукта который он покупал 5 раз


*/


with MyTable1 (cus, prod, c) as 
(select soh.CustomerID, p.Name, count(distinct sod.SalesOrderID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID INNER JOIN 
Production.Product as p 
on p.ProductID = sod.ProductID
GROUP BY soh.CustomerID, p.Name)

Select t.cus, (select TOP 1 t2.prod from MyTable1 as t2 where t2.cus = t.cus and t2.c = 3), (select TOP 1 t3.prod from MyTable1 as t3 where t3.cus = t.cus and t3.c = 5)
from MyTable1 as t 
Group BY t.cus