/*
SELECT *
FROM INFORMATION_SCHEMA.TABLES


SELECT  p.[Name]
FROM [Production].[Product] AS p

SELECT p.Name
FROM [Production].[Product] AS p
WHERE len(p.Name)=5

SELECT *
FROM [Sales].[SalesORDERDetail] AS sod

SELECT DISTINCT p.Style
FROM [Production].[Product] AS p
WHERE p.Style IS NOT NULL

SELECT  p.Name, p.SellStartDate
FROM [Production].[Product] AS p
WHERE p.SellStartDate BETWEEN '2011-03-01' AND '2012-03-31'

SELECT  max(p.ListPrice) AS [max price]
FROM [Production].[Product] AS p
WHERE p.SellStartDate>='2011-01-03'

SELECT p.Name, p.ListPrice-p.StandardCost
FROM [Production].[Product] AS p
WHERE p.ListPrice!=0 AND p.StandardCost!=0

SELECT p.Name, p.Color, p.ListPrice
FROM [Production].[Product] AS p
WHERE p.Color IS NOT NULL AND p.ListPrice!=0
ORDER BY p.Color ASC, p.ListPrice DESC

SELECT TOP 1 p.Name
FROM [Production].[Product] AS p
ORDER BY p.ListPrice

SELECT [Name] 
FROM [Production].[Product]
WHERE [SellStartDate] BETWEEN '2005-01-01' AND '2005-12-31'

SELECT p.Name
FROM [Production].[Product] AS p
WHERE datepart(YEAR,p.SellStartDate)=2005

                                                                    Лабораторная 1

1 Найти и вывести на экран названия продуктов, их цвет и размер.
SELECT [Name],[Color],[SIZE] 
FROM [Production].[Product]

2. Найти и вывести на экран названия, цвет и размер таких продуктов, у которых цена более 100.
SELECT [Name],[Color],[SIZE] 
FROM [Production].[Product]
WHERE [ListPrice]>100

3. Найти и вывести на экран название, цвет и размер таких продуктов, у которых цена менее 100 и цвет Black.
SELECT [Name],[Color],[SIZE] 
FROM [Production].[Product]
WHERE [ListPrice]<100 AND [Color]='Black'

4. Найти и вывести на экран название, цвет и размер таких продуктов, у которых цена менее 100 и цвет Black, упорядочив вывод по возрастанию стоимости продуктов.
SELECT [Name],[Color],[SIZE]
FROM [Production].[Product]
WHERE [ListPrice]<100 AND [Color]='Black'
ORDER BY [ListPrice] ASC

5. Найти и вывести на экран название и размер первых трех самых дорогих товаров с цветом Black.
SELECT TOP 3 [Name],[SIZE]
FROM [Production].[Product]
WHERE [Color]='Black'
ORDER BY [ListPrice] DESC

6. Найти и вывести на экран название и цвет таких продуктов, для которых определен и цвет, и размер.
SELECT [Name],[Color]
FROM [Production].[Product]
WHERE [Color] IS NOT NULL AND [Size] IS NOT NULL

7. Найти и вывести на экран не повторяющиеся цвета продуктов, у которых цена находится в диапазоне от 10 до 50 включительно. 
P.S я подумала о том, что сюда можно проверку на null Просто решила что не нужно
SELECT DISTINCT [Color]
FROM [Production].[Product]
WHERE [ListPrice] BETWEEN 10 AND 50

8. Найти и вывести на экран все цвета таких продуктов, у которых в имени первая буква ‘L’ и третья ‘N’.
SELECT [Color]
FROM [Production].[Product]
WHERE [Name] LIKE 'L_N%'

9. Найти и вывести на экран названия таких продуктов, которых начинаются либо на букву ‘D’, либо на букву ‘M’, и при этом длина имени – более трех символов.
SELECT [Name]
FROM [Production].[Product]
WHERE ([Name] LIKE 'D%' OR [Name]='M%') AND (len([Name])>3)

10. Вывести на экран названия продуктов, у которых дата начала продаж – не позднее 2012 года.
SELECT [Name]
FROM [Production].[Product]
WHERE [SellStartDate]<='2012-12-31'

P.S WHERE datepart(year,[SellStartDate])<=2012

SELECT *
FROM INFORMATION_SCHEMA.TABLES

11. Найти и вывести на экран названия всех подкатегорий товаров.
SELECT Name
FROM [Production].[ProductSubcategory]

P.S Там ограничение на столбец, он не может быть null

12. Найти и вывести на экран названия всех категорий товаров.
SELECT Name
FROM [Production].[ProductCategory]

P.S Там ограничение на столбец, он не может быть null

13. Найти и вывести на экран имена всех клиентов из таблицы Person, у которых обращение (Title) указано как «Mr.».
SELECT [FirstName],[MiddleName],[LastName]
FROM [Person].[Person]
WHERE [Title]='Mr.'

14. Найти и вывести на экран имена всех клиентов из таблицы Person, для которых не определено обращение (Title).
SELECT [FirstName],[MiddleName],[LastName]
FROM [Person].[Person]
WHERE [Title] IS NULL

*/

SELECT [Name] FROM Production.ProductSubcategory
WHERE [Name] LIKE '[^M]%' AND [ProductCategoryID] IN (1,3,5)




