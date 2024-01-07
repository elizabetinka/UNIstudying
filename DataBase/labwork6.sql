/*
Практическая работа 6
Цель работы: Использование оконных функций и предложения OVER.

SELECT SalesORDERID, ProductID, ORDERQty
,SUM(ORDERQty) OVER(PARTITION BY SalesORDERID) AS Total
,CAST(1. * ORDERQty / SUM(ORDERQty) OVER(PARTITION BY SalesORDERID) *100 AS DECIMAL(5,2))AS "Percent BY ProductID"
FROM Sales.SalesORDERDetail
WHERE SalesORDERID IN(43659,43664)


SELECT Name, ListPrice,
FIRST_VALUE(Name) OVER (ORDER BY ListPrice ASC) AS LeAStExpensive
FROM Production.Product
WHERE ProductSubcategoryID = 37


SELECT BusINessEntityID, TerritoryID, SalesYTD, ModifiedDate
,CONVERT(varchar(20),SalesYTD,1) AS  SalesYTD
,DATEPART(yy,ModifiedDate) AS SalesYear,
SUM(SalesYTD) OVER (PARTITION BY TerritoryID) as sum_SalesYTD,
CONVERT(
    varchar(20),SUM(SalesYTD) OVER 
        (PARTITION BY TerritoryID
        ORDER BY DATEPART(yy,ModifiedDate)
        ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING ),
    1) AS CumulativeTotal
FROM Sales.SalesPerson
WHERE TerritoryID IS NULL OR TerritoryID < 5


SELECT BusINessEntityID, YEAR(QuotaDate) AS SalesYear, SalesQuota AS CurrentQuota,
LAG(SalesQuota, 1,0) OVER (ORDER BY YEAR(QuotaDate)) AS PreviousQuota
FROM Sales.SalesPersonQuotaHistory
WHERE BusINessEntityID = 275 AND YEAR(QuotaDate) IN ('2011','2012')


SELECT BusINessEntityID, YEAR(QuotaDate) AS SalesYear, SalesQuota AS CurrentQuota,
LEAD(SalesQuota, 1,0) OVER (ORDER BY YEAR(QuotaDate)) AS NextQuota
FROM Sales.SalesPersonQuotaHistory
WHERE BusINessEntityID = 275 AND YEAR(QuotaDate) IN ('2011','2012')



SELECT p.FirstName, p.LastName, 
ROW_NUMBER() OVER (ORDER BY a.PostalCode) AS "Row Number"
,NTILE(4) OVER (PARTITION BY  ORDER BY a.PostalCode) AS Quartile
,s.SalesYTD
,a.PostalCode
FROM Sales.SalesPerson AS s
INNER JOIN Person.Person AS p
ON s.BusINessEntityID = p.BusINessEntityID
INNER JOIN Person.Address AS a
ON a.AddressID = p.BusINessEntityID
WHERE TerritoryID IS NOT NULL AND SalesYTD <> 0


1 Найти долю затрат каждого покупателя на каждый купленный им продукт среди общих его затрат в данной сети магазинов. 
Можно использовать обобщенное табличное выражение.

select CustomerID, ProductID, sum(OrderQty * UnitPrice), sum(sum(OrderQty * UnitPrice)) OVER(partitiON BY CustomerID), sum(OrderQty * UnitPrice)/ sum(sum(OrderQty * UnitPrice)) OVER(partitiON BY CustomerID)
FROM [Sales].[SalesORDERDetail] AS SOD INner JOIN
Sales.SalesOrderHeader as soh 
on soh.SalesOrderID = SOD.SalesOrderID
GROUP BY CustomerID, ProductID



2 Для одного выбранного покупателя вывести, для каждой покупки (чека), разницу в деньгах между этой и следующей покупкой.

select soh.CustomerID, sod.SalesOrderDetailID, sum(OrderQty*UnitPrice), LEAD (sum(OrderQty*UnitPrice), 1, 0) over (ORDER BY sod.SalesOrderDetailID asc), sum(OrderQty*UnitPrice)- LEAD (sum(OrderQty*UnitPrice), 1, 0) over (ORDER BY sod.SalesOrderDetailID asc)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
WHERE soh.CustomerID = 11000
Group BY soh.CustomerID, sod.SalesOrderDetailID


with MyTable (cus, id, s) as 
    (select soh.CustomerID, sod.SalesOrderDetailID, sum(OrderQty*UnitPrice)
    from Sales.SalesOrderDetail as sod INNER JOIN 
    Sales.SalesOrderHeader as soh 
    on sod.SalesOrderID = soh.SalesOrderID
    WHERE soh.CustomerID = 11000
    Group BY soh.CustomerID, sod.SalesOrderDetailID)


select MyTable.cus, MyTable.id, MyTable.s, LEAD (MyTable.s, 1, 0) over (ORDER BY MyTable.id asc), MyTable.s- LEAD (MyTable.s, 1, 0) over (ORDER BY MyTable.id asc)
from MyTable


3 Вывести следующую информацию: номер покупателя, номер чека этого покупателя, отсортированные по покупателям, номерам чека 
(по возрастанию). Третья колонка должна содержать в каждой своей строке сумму текущего чека покупателя со всеми предыдущими чеками этого покупателя.

with MyTable (cus, id, s) as 
(select soh.CustomerID, sod.SalesOrderID, sum(OrderQty * UnitPrice)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
GROUP BY sod.SalesOrderID, soh.CustomerID)

select MyTable.cus, MyTable.id, MyTable.s,sum(MyTable.s) over (ORDER BY MyTable.cus, MyTable.id asc ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
from MyTable

1 Найти долю продаж каждого продукта (цена продукта * количество продукта), на каждый чек, в денежном выражении.

select sod.SalesOrderID, sod.ProductID, sum(sod.UnitPrice * OrderQty), sum(sum(sod.UnitPrice * OrderQty)) over (PARTITION  by sod.SalesOrderID) 
from Sales.SalesOrderDetail as sod 
GROUp by sod.SalesOrderID, sod.ProductID

2 Вывести на экран список продуктов, их стоимость, а также разницу между стоимостью этого продукта и стоимостью самого дешевого 
продукта в той же подкатегории, к которой относится продукт.

select p.ProductId,p.ListPrice, (select min(p2.ListPrice) from  Production.Product as p2 WHERE p2.ProductSubcategoryID = p.ProductSubcategoryID)
from Production.Product as p
WHERE p.ProductSubcategoryID IS NOT NULL


3 Вывести три колонки: номер покупателя, номер чека покупателя (отсортированный по возрастанию даты чека) и искусственно 
введенный порядковый номер текущего чека, начиная с 1, для каждого покупателя.

with MyTable (cus, id, da) as 
(select soh.CustomerID, sod.SalesOrderID ,  soh.OrderDate
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID
Group BY soh.CustomerID, sod.SalesOrderID, soh.OrderDate)

select *, ROW_NUMBER() over (PARTITION BY cus ORDER BY da asc)
from MyTable
ORDER BY cus,da asc



2 Вывести на экран список продуктов, их стоимость, а также разницу между стоимостью этого продукта и стоимостью самого дешевого 
продукта в той же подкатегории, к которой относится продукт.

select p.ProductId,p.ListPrice, min(ListPrice) over (PARTITION BY p.ProductsubcategoryID)
from Production.Product as p
WHERE p.ProductSubcategoryID IS NOT NULL
order BY p.ProductID

4 Вывести номера продуктов, таких что их цена выше средней цены продукта в подкатегории, к которой относится продукт. 
Запрос реализовать двумя способами. В одном из решений допускается использование обобщенного табличного выражения.

with MyTable (prod, price, avPrice) as 
(select p.ProductID,p.ListPrice, avg(p.ListPrice) over(Partition BY p.ProductSubcategoryID)
from Production.Product as p
)
select prod
from MyTable
WHERE price>avPrice


select tabl.ProductID
from (select p.ProductID,p.ListPrice, avg(p.ListPrice) over(Partition BY p.ProductSubcategoryID) as av
    from Production.Product as p
) as tabl
where tabl.ListPrice> tabl.av


5 Вывести на экран номер продукта, название продукта, а также информацию о среднем количестве этого продукта, приходящихся на три 
последних по дате чека, в которых был этот продукт.

select p.ProductID, p.Name,sod.ModifiedDate, sod.OrderQty, avg(OrderQty) over (Partition by sod.ProductID Order BY sod.ModifiedDate desc ROWS BETWEEN Unbounded preceding and 2 FOLLOWING)
from Production.Product as p INNER JOIN 
Sales.SalesOrderDetail as sod 
on p.ProductID = sod.ProductID



Найти для каждого чека его номер, количество категорий и подкатегорий

select sod.SalesOrderID, count (p.ProductSubcategoryID) over (PARTITION BY sod.SalesOrderID), count (ps.ProductCategoryID) over (PARTITION BY sod.SalesOrderID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Production.Product as p 
on sod.ProductID = p.ProductID LEFT JOIn 
Production.ProductSubcategory as ps 
on p.ProductSubcategoryID = ps.ProductSubcategoryID



Название товара, название категории, к которой относится и общее кол-во товаров в категории

select p.Name, pc.Name, count(ProductID) over (PARTITION BY pc.ProductCategoryID)
from Production.Product as p LEFT JOIN 
Production.ProductSubcategory as ps 
on p.ProductSubcategoryID = ps.ProductSubcategoryID LEFT JOIN 
Production.ProductCategory as pc 
on ps.ProductCategoryID = pc.ProductCategoryID



Найти для каждого товара соотношения количества покупателей, купивших товар, к общему количеству покупателей, совершавших когда-либо покупки


select sod.ProductID, count(soh.CustomerID) over (PARTITION BY sod.ProductID), count(distinct soh.CustomerID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID


Вывести на экран, для каждого продукта, количество его продаж, и соотношение числа покупателей этого продукта, к числу покупателей, купивших товары из категории, к которой относится данный товар
select sod.ProductID, count(soh.CustomerID) over (PARTITION BY sod.ProductID), count(distinct soh.CustomerID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID


Найти для каждого чека его номер, количество категорий и подкатегорий

select sod.SalesOrderID, count (p.ProductSubcategoryID) over (PARTITION BY sod.SalesOrderID), count (ps.ProductCategoryID) over (PARTITION BY sod.SalesOrderID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Production.Product as p 
on sod.ProductID = p.ProductID LEFT JOIn 
Production.ProductSubcategory as ps 
on p.ProductSubcategoryID = ps.ProductSubcategoryID


select distinct d.SalesOrderID,
dense_rank() over (partition by d.SalesOrderID order by ps.ProductCategoryID) +
dense_rank() over (partition by d.SalesOrderID order by ps.ProductCategoryID desc) - 1 as 'cats',

dense_rank() over (partition by d.SalesOrderID order by ps.ProductSubcategoryID) +
dense_rank() over (partition by d.SalesOrderID order by ps.ProductSubcategoryID desc) - 1 as 'subcats'

from Sales.SalesOrderDetail as d join 
Production.Product as p 
on p.ProductID=d.ProductID join Production.ProductSubcategory as ps 
on ps.ProductSubcategoryID=p.ProductSubcategoryID


Вывести на экран, для каждого продукта, количество его продаж, и соотношение числа покупателей этого продукта, к числу покупателей, купивших товары из категории, к которой относится данный товар
select sod.ProductID, count(soh.CustomerID) over (PARTITION BY sod.ProductID), count(distinct soh.CustomerID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID


select distinct sod.ProductID, 
DENSE_RANK() over (PARTITION BY sod.ProductID order by sod.SalesOrderID asc) + 
DENSE_RANK() over (PARTITION BY sod.ProductID order by sod.SalesOrderID desc) - 1 , 

DENSE_RANK() over (PARTITION BY sod.ProductID order by soh.CustomerID asc) + 
DENSE_RANK() over (PARTITION BY sod.ProductID order by soh.CustomerID desc) - 1 
, count(distinct soh.CustomerID)
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID

Найти для каждого товара соотношения количества покупателей, купивших товар, к общему количеству покупателей, совершавших когда-либо покупки

select distinct sod.ProductID, 
    DENSE_RANK() over (Partition BY sod.ProductID ORDER BY soh.CustomerID desc) + DENSE_RANK() over (Partition BY sod.ProductID ORDER BY soh.CustomerID asc) -1,
    DENSE_RANK() over (ORDER BY soh.CustomerID desc) + DENSE_RANK() over (ORDER BY soh.CustomerID asc) -1
from Sales.SalesOrderDetail as sod INNER JOIN 
Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID










для каждого товара отношение количества покупателей к
*/



select distinct sod.ProductID, 
    CAST (DENSE_RANK() over ( PARTITION BY sod.ProductID ORDER BY soh.CustomerID desc) + DENSE_RANK() over ( PARTITION BY sod.ProductID ORDER BY soh.CustomerID asc) -1 AS FLOAT),
    (DENSE_RANK() over (Order BY soh.CustomerID desc) + DENSE_RANK() over (Order BY soh.CustomerID asc) -1)

from Sales.SalesOrderDetail as sod 
INNER JOIN Sales.SalesOrderHeader as soh 
on sod.SalesOrderID = soh.SalesOrderID






















