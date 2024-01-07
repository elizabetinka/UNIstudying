-- Цель работы: Изучение выражения GROUP BY – группировка данных
/*
SELECT COUNT(*) AS 'Amount' FROM [Production].[Product]
WHERE [Color] IS NOT NULL

SELECT MAX([ListPrice]) FROM [Production].[Product]
WHERE [Color]='Red'

SELECT [Color] , COUNT(*) AS 'Amount'
FROM [Production].[Product]
WHERE [Color] IS NOT NULL
GROUP BY [Color]

SELECT [ListPrice],[StandardCost],[ListPrice]+[StandardCost] , COUNT(*) AS 'Amount'
FROM [Production].[Product]
GROUP BY [ListPrice],[StandardCost]

SELECT [ListPrice]+[StandardCost] , COUNT(*) AS 'Amount'
FROM [Production].[Product]
GROUP BY [ListPrice]+[StandardCost]

SELECT [ListPrice]+[StandardCost]+10 , COUNT(*) AS 'Amount'
FROM [Production].[Product]
GROUP BY [ListPrice]+[StandardCost]

SELECT [Color], [Style], COUNT(*) AS 'Amount'
FROM [Production].[Product]
WHERE [Color] IS NOT NULL AND [Style] IS NOT NULL
GROUP BY [Color], [Style]

SELECT [Color], [Style], COUNT(*) AS 'Amount'
FROM [Production].[Product]
WHERE [Color] IS NOT NULL AND [Style] IS NOT NULL
GROUP BY [Color], [Style]
HAVING COUNT(*)>10 AND MAX([ListPrice])>3000

!!!!Так плохоооооо, лучше в WHERE условие прописать!!!!
SELECT [Color], COUNT(*) AS 'Amount'
FROM [Production].[Product]
GROUP BY [Color], [Style]
HAVING [Color] IS NOT NULL


SELECT [Color], [Style], [Class], COUNT(*)
FROM [Production].[Product]
GROUP BY ROLLUP ([Color], [Style], [Class])

SELECT [Color], [Style], [Class], COUNT(*)
FROM [Production].[Product]
GROUP BY Cube ([Color],[Style],[Class])




SELECT [Color],[Size],COUNT(*)
FROM [Production].[Product]
GROUP BY GROUPING SETS (([Color]),([Size]))

Примеры запросов с решениями
1. Найти номера первых трех подкатегорий (ProductSubcategoryID) с наибольшим количеством наименований товаров.

SELECT TOP 3 [ProductSubcategoryID], count(*)
FROM [Production].[Product]
WHERE [ProductSubcategoryID] IS NOT NULL
GROUP BY [ProductSubcategoryID]
ORDER BY COUNT(*) DESC

2. Разбить продукты по количеству символов в названии, для каждой группы определить количество продуктов.
SELECT len([Name]) AS 'ДЛина', count(*) AS 'Количество' 
FROM [Production].[Product]
GROUP BY len([Name])

3. Проверить, есть ли продукты с одинаковым названием, если есть, то вывести эти названия.

SELECT  [Name]
FROM [Production].[Product]
GROUP BY [ProductID], [Name]  ?? хз зачем тут продуктИД
HAVING count(*)>1

                                                                    Лабораторная 2

1. Найти и вывести на экран количество товаров каждого цвета, исключив из поиска товары, цена которых меньше 30. 
  
Select [Color], Count(*) 
FROM Production.Product
WHERE [ListPrice] >= 30 AND [Color] IS NOT NULL
GROUP BY [Color]       


2. Найти и вывести на экран список, состоящий из цветов товаров, таких, что минимальная цена товара данного цвета более 100.

SELECT [Color]
FROM [Production].[Product]
WHERE [Color] IS NOT NULL
GROUP BY [Color]
HAVING min([ListPrice])>100


3. Найти и вывести на экран номера подкатегорий товаров и количество товаров в каждой категории.
SELECT [ProductSubcategoryID], COUNT(*)
FROM [Production].[Product]
WHERE [ProductSubcategoryID] IS NOT NULL
GROUP BY [ProductSubcategoryID]


4. Найти и вывести на экран номера товаров и количество фактов продаж данного товара (используется таблица SalesORDERDetail).
SUM (OrderQty)

select [ProductID], count(*)
from [Sales].[SalesOrderDetail]
GROUP By [ProductID]

5. Найти и вывести на экран номера товаров, которые были куплены более пяти раз.
SELECT [ProductID]
FROM [Sales].[SalesORDERDetail]
GROUP By [ProductID]
HAVING count(*) > 5


6. Найти и вывести на экран номера покупателей, CustomerID, у которых существует более одного чека, SalesORDERID, с одинаковой датой
SELECT [CustomerID]
FROM [Sales].[SalesOrderHeader]
GROUP BY [CustomerID],[OrderDate]
HAVING count(*)>1

7. Найти и вывести на экран все номера чеков, на которые приходится более трех продуктов.

Select [SalesOrderID]
FROM Sales.SalesOrderDetail
GROUP BY [SalesOrderID]
HAVING count([ProductID]) > 3

8. Найти и вывести на экран все номера продуктов, которые были куплены более трех раз.
select ProductID
from [Sales].[SalesOrderDetail]
GROUP by ProductID
HAVING count(*) > 3

9. Найти и вывести на экран все номера продуктов, которые были куплены или три или пять раз.
select ProductID
from [Sales].[SalesOrderDetail]
GROUP by ProductID
HAVING count(*) = 3 OR count(*) = 5


10. Найти и вывести на экран все номера подкатегорий, в которым относится более десяти товаров.
SELECT [ProductSubcategoryID]
from Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY [ProductSubcategoryID]
HAVING count(*) > 10

11. Найти и вывести на экран номера товаров, которые всегда покупались в одном экземпляре за одну покупку.

Select [ProductID]
FROM Sales.SalesOrderDetail
GROUP BY [ProductID]
HAVING min(OrderQty) = 1 AND max(OrderQty) = 1

* HAVING SUM(OrderQty) = COUNT(OrderQty)

12 Найти и вывести на экран номер чека, SalesORDERID, на который приходится с наибольшим разнообразием товаров купленных на этот чек.

SELECT TOP 1 SalesOrderID
from [Sales].[SalesOrderDetail]
GROUP BY SalesOrderID
ORDER BY COUNT(Distinct ProductID) DESC

13 Найти и вывести на экран номер чека, SalesORDERID с наибольшей суммой покупки, исходя из того, что цена товара – это UnitPrice, а количество конкретного товара в чеке – это ORDERQty.

Select TOP 1 [SalesOrderID]
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
ORDER BY SUM(UnitPrice * OrderQty) Desc


14 Определить количество товаров в каждой подкатегории, исключая товары, для которых подкатегория не определена, и товары, у которых не определен цвет.

Select [ProductSubcategoryID],count(ProductID)
FROM Production.Product
WHERE [ProductSubcategoryID] IS NOT NULL AND [Color] IS NOT NULL
GROUP BY [ProductSubcategoryID]

15 Получить список цветов товаров в порядке убывания количества товаров данного цвета

Select [Color]
FROM Production.Product
WHERE [Color] IS NOT NULL
GROUP BY [Color]
ORDER BY COUNT(ProductID) DESC

16 Вывести на экран ProductID тех товаров, что всегда покупались в количестве более 1 единицы на один чек, при этом таких покупок было более двух.

SELECT ProductID
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING min(OrderQty) > 1 AND COUNT(DISTINCT SalesOrderID) > 2

GROUP BY ROLLUP,
GROUP BY CUBE
GROUP BY GROUPING SETS ( ) 

*/
SELECT [Size]
FROm Production.Product
WHERE Size IS NOT NULL
GROUP BY [Size]
HAVING count (DISTINCT ProductID) > 10

























