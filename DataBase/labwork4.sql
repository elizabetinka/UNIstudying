/*
 список самых дорогих товаров в каждой из подкатегорий.

SELECT [Name]
FROM [Production].[Product] AS P1
WHERE [ListPrice]=
(SELECT MAX([ListPrice])
FROM [Production].[Product] AS P2
WHERE P1.ProductSubcategoryID=P2.ProductSubcategoryID)

название продукта и название подкатегории, к которой он относится.
SELECT [Name],
(SELECT [Name]
FROM [Production].[ProductSubcategory] AS PS
WHERE P1.ProductSubcategoryID=PS.ProductSubcategoryID)
FROM [Production].[Product] AS P1

1 Найти название подкатегории с наибольшим количеством продуктов, без учета продуктов,
 для которых подкатегория не определена (еще одна возможная реализация).

 select ps.Name
from Production.ProductSubCategory as ps
WHERE Ps.ProductSubcategoryID in
    (select TOP 1 WITH TIES p.ProductSubcategoryID
    from Production.Product as p
    WHERE p.ProductSubcategoryID IS NOT NULL
    GROUP BY p.ProductSubcategoryID
    ORDER BY COUNT(*) desc

)

2 Вывести на экран такого покупателя, который каждый раз покупал только одну номенклатуру 
товаров, не обязательно в одинаковых количествах, т.е. у него всегда был один и тот же 
«список покупок».

Вообщем количество сколько раз встречается один покупатель сравнивается с количеством раз, сколько раз этот покупатель кпил конкретный продукт
SELECT [CustomerID], count(*)
FROM [Sales].[SalesORDERHeader] AS SOH1
GROUP BY [CustomerID]
HAVING count(*)>1 AND count(*)=all
(SELECT count(*)
FROM [Sales].[SalesORDERHeader] AS SOH INner JOIN
[Sales].[SalesORDERDetail] AS SOD
ON soh.SalesORDERID=sod.SalesORDERID
WHERE soh.CustomerID=soh1.CustomerID
GROUP BY soh.[CustomerID], sod.ProductID
)


3 Вывести на экран следующую информацию: название товара (первая колонка), 
количество покупателей, покупавших этот товар (вторая колонка), количество 
покупателей, совершавших покупки, но не покупавших товар из первой колонки 
(третья колонка).

select p.Name, 
    (select count (distinct(soh.CustomerID)) from Sales.SalesOrderDetail as sod INNER JOIN
    Sales.SalesOrderHeader as soh
    on sod.SalesOrderID = soh.SalesOrderID
    WHERE sod.ProductID = p.ProductID
    ), 
    (select count(distinct(soh.CustomerID))
    from Sales.SalesOrderHeader as soh
    WHERE soh.CustomerID NOT IN
    (select soh.CustomerID
    from Sales.SalesOrderDetail as sod INNER JOIN
    Sales.SalesOrderHeader as soh
    on sod.SalesOrderID = soh.SalesOrderID
    WHERE sod.ProductID = p.ProductID
    ))
 
from Production.Product as p

4 Найти такие товары, которые были куплены более чем одним покупателем, при этом все 
покупатели этих товаров покупали товары только из одной подкатегории.

SELECT name
FROM [Production].[Product]
WHERE ProductID IN(
SELECT sod.ProductID
FROM [Sales].[SalesORDERDetail] AS sod JOIN
[Sales].[SalesORDERHeader] AS soh
ON sod.SalesORDERID=soh.SalesORDERID
WHERE soh.CustomerID IN(
SELECT soh.CustomerID
FROM [Sales].[SalesORDERDetail] AS sod JOIN
[Sales].[SalesORDERHeader] AS soh
ON sod.SalesORDERID=soh.SalesORDERID JOIN
[Production].[Product] AS p ON
sod.ProductID=p.ProductID
GROUP BY soh.CustomerID
HAVING count(DISTINCT p.ProductSubcategoryID)=1)
GROUP BY sod.ProductID
HAVING count(DISTINCT soh.CustomerID)>1)


Самый дорогой товар который покупал пользователь
select soh.CustomerID ,
(select max(ListPrice)
from Sales.SalesOrderDetail as sod INNer join
Production.Product as p
on sod.ProductID = p.ProductID INNER JOIN 
Sales.SalesOrderHeader as soh2 
on sod.SalesOrderID = soh2.SalesOrderID
WHERE soh2.CustomerID = soh.CustomerID
)
from Sales.SalesOrderHeader as soh

вывести такие категории, в которых самый дорогой товар красного цвета стоит больше самого дорого черного цвета

select ProductCategoryID, (select max(ListPrice) from Production.Product as p2 where Color = 'Red' and p2.ProductSubcategoryID = ps.ProductSubcategoryID), (select max(ListPrice) from Production.Product as p3 where Color = 'Black' and p3.ProductSubcategoryID = ps.ProductSubcategoryID)
from Production.ProductSubCategory as ps
where  
    (select max(ListPrice) from Production.Product as p2 where Color = 'Red' and p2.ProductSubcategoryID = ps.ProductSubcategoryID) >
    (select max(ListPrice) from Production.Product as p3 where Color = 'Black' and p3.ProductSubcategoryID = ps.ProductSubcategoryID)




5 Найти покупателя, который каждый раз имел разный список товаров в чеке 
(по номенклатуре).

SELECT DISTINCT CustomerID
FROM [Sales].[SalesORDERHeader]
WHERE CustomerID NOT IN (
    SELECT soh.Customerid
    FROM [Sales].[SalesORDERDetail] AS sod JOIN
    [Sales].[SalesORDERHeader] AS soh
    ON sod.SalesORDERID=soh.SalesORDERID
    WHERE exists
        (SELECT ProductID
        FROM [Sales].[SalesORDERDetail] AS sod1 JOIN
        [Sales].[SalesORDERHeader] AS soh1
        ON sod.SalesORDERID=soh.SalesORDERID
        WHERE soh1.CustomerID=soh.CustomerID AND
        sod1.ProductID=sod.ProductID AND sod.SalesORDERID!=sod1.SalesORDERID
))



6 Найти такого покупателя, что все купленные им товары были куплены только им и никогда не покупались другими покупателями.

select soh0.CustomerID
FROM [Sales].[SalesORDERDetail] AS sod0 JOIN
    [Sales].[SalesORDERHeader] AS soh0
    ON sod0.SalesORDERID=soh0.SalesORDERID
where not exists (
    select sod.ProductID
    FROM [Sales].[SalesORDERDetail] AS sod JOIN
    [Sales].[SalesORDERHeader] AS soh
    ON sod.SalesORDERID=soh.SalesORDERID
    where sod.ProductID = sod0.ProductID and soh.CustomerID != soh0.CustomerID
)

SELECT DISTINCT soh.CustomerID
FROM [Sales].[SalesORDERHeader] AS soh
WHERE soh.CustomerID NOT IN(
    SELECT DISTINCT soh.CustomerID
    FROM [Sales].[SalesORDERDetail] AS sod JOIN
    [Sales].[SalesORDERHeader] AS soh
    ON sod.SalesORDERID=soh.SalesORDERID
    WHERE ProductID NOT IN(
        SELECT sod.ProductID
        FROM [Sales].[SalesORDERDetail] AS sod JOIN
        [Sales].[SalesORDERHeader] AS soh
        ON sod.SalesORDERID=soh.SalesORDERID
        GROUP BY sod.ProductID
        HAVING count(DISTINCT soh.CustomerID)=1))



1 Найти название самого продаваемого продукта.

select p.[Name] 
from Production.Product as p 
where p.ProductID = (
    select TOP 1 sod.ProductID
    from Sales.SalesOrderDetail as sod 
    GROUP BY sod.ProductID
    ORDER BY sum(OrderQty) desc
)

2 Найти покупателя, совершившего покупку на самую большую сумм, считая сумму покупки исходя из цены товара без скидки (UnitPrice).

select TOP 1 soh.CustomerID
from Sales.SalesOrderHeader as soh INNER JOIN 
Sales.SalesOrderDetail as sod 
on soh.SalesOrderID = sod.SalesOrderID
GROUP BY soh.CustomerID, sod.SalesOrderID
HAVING SUM(UnitPrice) = (
    select TOP 1 sum(UnitPrice)
    from Sales.SalesOrderDetail as sod2 
    GROUP By sod2.SalesOrderID
    ORDER BY sum(UnitPrice) desc
)


3 Найти такие продукты, которые покупал только один покупатель.


select sod.ProductID
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
where not exists (
    select soh2.CustomerID
    from Sales.SalesOrderDetail as sod2 INNER JOIN 
    Sales.SalesOrderHeader as soh2
    on sod2.SalesOrderID = soh2.SalesOrderID
    where soh2.CustomerID != soh.CustomerID and sod2.ProductID = sod.ProductID
)

select p.Name
from Production.Product as p
where p.ProductID in 
	(select sod1.ProductID
	from Sales.SalesOrderDetail as sod1
	inner join Sales.SalesOrderHeader as soh1
	on sod1.SalesOrderID = soh1.SalesOrderID
	where sod1.ProductID = p.ProductID
	group by sod1.ProductID
	having count(distinct soh1.CustomerID) = 1);


4 Вывести список продуктов, цена которых выше средней цены товаров в подкатегории, к которой относится товар.

select p.Name
from Production.Product as p
where p.ListPrice > (
    select (avg (p2.ListPrice))
    from Production.Product as p2
    WHERE p2.ProductSubcategoryID = p.ProductSubcategoryID
)

5 Найти такие товары, которые были куплены более чем одним покупателем, при этом все покупатели этих товаров покупали товары 
только одного цвета и товары не входят в список покупок покупателей, купивших товары только двух цветов.

Select sod.ProductID
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID 
where soh.CustomerID in (
    select soh2.CustomerID
    from Sales.SalesOrderDetail as sod2 INNER JOIN 
    Sales.SalesOrderHeader as soh2 
    on sod2.SalesOrderID = soh2.SalesOrderID  INNER JOIN 
    Production.Product as p2
    on sod2.ProductID = p2.ProductID 
    where not exists (
        select soh3.CustomerID
        from Sales.SalesOrderDetail as sod3 INNER JOIN 
        Sales.SalesOrderHeader as soh3 
        on sod3.SalesOrderID = soh3.SalesOrderID  INNER JOIN 
        Production.Product as p3
        on sod3.ProductID = p3.ProductID
        where p2.ProductID = p3.ProductID
        Group By soh3.CustomerID
        HAVING COUNT(distinct p3.Color) = 2
    )
    Group By soh2.CustomerID
    HAVING COUNT(distinct p2.Color) = 1
)
GROUP BY sod.ProductID 
HAVING count(distinct soh.CustomerID) > 1


6 Найти такие товары, которые были куплены такими покупателями, у которых они присутствовали в каждой их покупке.

Select distinct sod.ProductID
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID 
where soh.CustomerID in (
    select soh2.CustomerID
    from Sales.SalesOrderDetail as sod2 INNER JOIN 
    Sales.SalesOrderHeader as soh2 
    on sod2.SalesOrderID = soh2.SalesOrderID 
    GROUP BY soh2.CustomerID, soh2.SalesOrderID
    HAVING count (soh2.CustomerID) = 
        (select count(*)
        from Sales.SalesOrderDetail as sod3 INNER JOIN 
        Sales.SalesOrderHeader as soh3 
        on sod3.SalesOrderID = soh2.SalesOrderID
        where soh3.CustomerID = soh2.CustomerID and sod3.ProductID = sod.ProductID
        )
)

7 Найти покупателей, у которых есть товар, присутствующий в каждой покупке/чеке.

select distinct soh.CustomerID
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
Group BY soh.CustomerID, sod.SalesOrderID, sod.ProductID
HAVING count(*)  = 
    (select count(distinct sod2.SalesOrderID)
    from Sales.SalesOrderDetail as sod2 INNER JOIN 
    Sales.SalesOrderHeader as soh2 
    on sod2.SalesOrderID = soh2.SalesOrderID
    WHERE soh2.CustomerID = soh.CustomerID)


8 Найти такой товар или товары, которые были куплены не более чем тремя различными покупателями.

select sod.ProductID
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
GROUP BY sod.ProductID
HAVING 
(select count(distinct soh2.CustomerID )
from Sales.SalesOrderDetail as sod2 INNER JOIN 
Sales.SalesOrderHeader as soh2 
on sod2.SalesOrderID = soh2.SalesOrderID
WHERE sod2.ProductID = sod.ProductID
) 
<=3


9 Найти все товары, такие что их покупали всегда с товаром, цена которого максимальна в своей категории.

select sod.ProductID
from Sales.SalesOrderDetail as sod 
where not exists (
    select sod0.SalesOrderID
    from Sales.SalesOrderDetail as sod0 
    WHERE sod0.ProductID = sod.ProductID and sod0.SalesOrderID not in
    (
    select sod.SalesOrderID //тут выводятся чеки котрые содержат максимальный по стоимости в сабкатгории товар
    from Sales.SalesOrderDetail as sod2
    WHERE sod2.ProductID in (
        select p.ProductID
        from Production.Product as p
        where not exists (
            select p2.ProductID
            from Production.Product as p2
            where p2.ProductSubcategoryID = p.ProductSubcategoryID and  p2.ListPrice > p.ListPrice
        )
    )
)
)

12 Найти товары, которые были куплены минимум три раза различными покупателями.

select sod.ProductID
from Sales.SalesOrderDetail as sod INNER JOIN
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
GROUP BY sod.ProductID
HAVING (
    (select count(distinct soh2.CustomerID)
    from Sales.SalesOrderDetail as sod2 INNER JOIN
    Sales.SalesOrderHeader as soh2 
    on sod2.SalesOrderID = soh2.SalesOrderID 
    where sod2.ProductID = sod.ProductID)
 ) >= 3



 Самый дорогой товар, который покупал пользователь
select soh0.CustomerID, 
    (select max(p.ListPrice)
    from Sales.SalesOrderDetail as sod INNER JOIN 
    Sales.SalesOrderHeader as soh 
    on sod.SalesOrderID = soh.SalesOrderID INNER JOIN 
    Production.Product as p 
    on sod.ProductID = p.ProductID 
    WHERE soh.CustomerID = soh0.CustomerID
    )
from Sales.SalesOrderHeader as soh0 

 вывести такие категории, в которых самый дорогой товар красного цвета стоит больше самого дорого черного цвета

 select ps.ProductCategoryID
from Production.ProductsubCategory as ps
where (select MAX(ListPrice) from Production.Product where Color = 'Red' and ProductSubcategoryID = ps.ProductSubcategoryID) > 
    (select MAX(ListPrice) from Production.Product where Color = 'Black' and ProductSubcategoryID = ps.ProductSubcategoryID)



    название самого дорогого товара с цветом Red.
    select Name
from Production.product 
where color = 'Red' and ListPrice = (
    select max(p.ListPrice)
    from Production.Product as p
)

список товаров, цвет которых может быть любой, кроме Red, а цена равна цене любого товара с цветом Red
select Name
from Production.Product
where ListPrice in (
    select p.ListPrice
    from Production.Product as p
    where Color = 'Red'
)

список товаров, цена которых больше цены любого из товаров с цветом Red.

select p2.ProductID
from Production.Product  as p2
WHERE not exists (
    select p.ProductID
    from Production.Product as p
    where p.Color = 'Red' and p.ListPrice >= p2.ListPrice
)

select Name
from Production.Product 
WHERE ListPrice > all (
    select p.ListPrice
    from Production.Product as p
    where p.Color = 'Red'
)

получить название товаров, чей цвет совпадает с цветом одного из товаров, чья цена больше 3000.
select p.Name
from Production.Product as p
where p.Color in (
    select p2.Color
    from Production.Product as p2
    WHERE p2.ListPrice > 3000
)

название категории, где содержится самый дорогой товар.

select pc.Name
from Production.ProductCategory as pc INNER JOIN 
Production.ProductSubcategory as ps
on pc.ProductCategoryID = ps.ProductSubcategoryID 
WHERE ps.ProductSubcategoryID in (
    select p.ProductSubcategoryID
    from Production.Product as p
    where p.ListPrice = (select Max(ListPrice) from Production.Product)
)

1 Найти название самого продаваемого продукта.
select p.Name
from Production.Product as p
where p.ProductID = (
    select TOP 1 ProductID
    from Sales.SalesOrderDetail 
    Group BY ProductID
    Order BY SUM(OrderQty) desc
)

2 Найти покупателя, совершившего покупку на самую большую сумм, считая сумму покупки исходя из цены товара без скидки (UnitPrice).
select soh.CustomerID
from Sales.SalesOrderHeader as soh INNER JOIN 
Sales.SalesOrderDetail as sod 
on soh.SalesOrderID = sod.SalesOrderID 
GROUP BY soh.CustomerID, sod.SalesOrderID
Having sum(UnitPrice) = (
    select TOP 1 SUM(UnitPrice)
    from Sales.SalesOrderDetail as sod2 
    GROUP BY sod2.SalesOrderID
    ORDER BY SUM(UnitPrice) desc
)

3 Найти такие продукты, которые покупал только один покупатель.
select distinct sod.ProductID
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
where not exists (
    select sod2.ProductID
    from Sales.SalesOrderDetail as sod2 INNER JOIN 
    Sales.SalesOrderHeader as soh2 
    on sod2.SalesOrderID = soh2.SalesOrderID
    where sod2.ProductID = sod.ProductID and soh2.CustomerID != soh2.CustomerID
)

4 Вывести список продуктов, цена которых выше средней цены товаров в подкатегории, к которой относится товар.


6 Найти такие товары, которые были куплены такими покупателями, у которых они присутствовали в каждой их покупке.






Найти все товары которые красного цвета и прордавались не менее 2 раз
*/


select p.Name
from Production.Product as p 
where p.Color = 'Red' and p.ProductID in (
    select sod.ProductID
    from Sales.SalesOrderDetail as sod 
    GROUP BY sod.ProductID
    HAVING count(distinct sod.SalesOrderID) >= 2
)
















