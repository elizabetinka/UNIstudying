-- 1
select distinct p.Name
from Production.Product as p
where p.ProductID in
(select top 1 sod.ProductID
from Sales.SalesOrderDetail as sod
group by sod.ProductID
order by count(*) desc);

--2
select distinct soh1.CustomerID
from Sales.SalesOrderHeader as soh1
where soh1.CustomerID in
(select top 1 soh2.CustomerID
from Sales.SalesOrderHeader as soh2
inner join Sales.SalesOrderDetail as sod1
on soh2.SalesOrderID = sod1.SalesOrderID
group by soh2.CustomerID
order by sum(sod1.UnitPrice) desc);

--3 
select distinct sod1.ProductID
from Sales.SalesOrderDetail as sod1
where sod1.ProductID in
(select sod2.ProductID 
from Sales.SalesOrderDetail as sod2
inner join Sales.SalesOrderHeader as soh2
on sod2.SalesOrderID = soh2.SalesOrderID
group by sod2.ProductID 
having count(distinct soh2.CustomerID) = 1);

--4
select p1.Name
from Production.Product as p1
where p1.ListPrice > 
(select avg(p2.ListPrice)
from Production.Product as p2
inner join Production.ProductSubcategory as ps2
on p2.ProductSubcategoryID = ps2.ProductSubcategoryID
where ps2.ProductSubcategoryID = p1.ProductSubcategoryID);

--5 ?
--select distinct sod1.ProductID
--from Sales.SalesOrderDetail as sod1
--inner join Sales.SalesOrderHeader as soh1
--on sod1.SalesOrderID = soh1.SalesOrderID
--where sod1.ProductID in
--(select sod2.ProductID 
--from Sales.SalesOrderDetail as sod2
--inner join Sales.SalesOrderHeader as soh2
--on sod2.SalesOrderID = soh2.SalesOrderID
--group by sod2.ProductID
--having count(distinct soh1.CustomerID) > 1)
--and soh1.CustomerID in 
--(select soh3.CustomerID
--from Sales.SalesOrderHeader as soh3
--inner join Sales.SalesOrderDetail as sod3
--on soh3.SalesOrderID = sod3.SalesOrderID
--inner join Production.Product as p3
--on sod3.ProductID = p3.ProductID
--where count(distinct p3.Color) = 1 and p3.ProductID not in
--(select sod3.ProductID
--from Sales.SalesOrderHeader as soh3
--inner join Sales.SalesOrderDetail as sod3
--on soh3.SalesOrderID = sod3.SalesOrderID
--inner join Production.Product as p3
--on sod3.ProductID = p3.ProductID
--where count(distinct p3.Color) = 2));

--6
select p1.Name 
from Production.Product as p1
where p1.ProductID in 
(select sod2.ProductID
from Sales.SalesOrderDetail as sod2
inner join Sales.SalesOrderHeader as soh2
on sod2.SalesOrderID = soh2.SalesOrderID
where not exists
(select soh4.SalesOrderID
from Sales.SalesOrderHeader as soh4
inner join Sales.SalesOrderDetail as sod4
on soh4.SalesOrderID = sod4.SalesOrderID
where soh4.CustomerID = soh2.CustomerID
group by soh4.SalesOrderID
having count(distinct sod4.ProductID) = 0)
)

--7
select distinct soh1.CustomerID
from Sales.SalesOrderHeader as soh1
where exists
(select sod2.ProductID
from Sales.SalesOrderDetail as sod2
inner join Sales.SalesOrderHeader as soh2
on sod2.SalesOrderID = soh2.SalesOrderID
where soh2.CustomerID = soh1.CustomerID and not exists 
(select sod3.SalesOrderID 
from Sales.SalesOrderDetail as sod3
inner join Sales.SalesOrderHeader as soh3
on sod3.SalesOrderID = soh3.SalesOrderID
where soh3.CustomerID = soh1.CustomerID and sod3.ProductID = sod2.ProductID
group by sod3.SalesOrderID
having count(sod3.ProductID) = 0));

--8
select distinct sod1.ProductID
from Sales.SalesOrderDetail as sod1
where 
(select count (distinct soh2.CustomerID)
from Sales.SalesOrderHeader as soh2
where exists 
(select sod3.SalesOrderID
from Sales.SalesOrderDetail as sod3
inner join Sales.SalesOrderHeader as soh3
on sod3.SalesOrderID = soh3.SalesOrderID
where soh3.CustomerID = soh2.CustomerID and sod3.ProductID = sod1.ProductID)
) >= 3;

--9
--select p1.Name 
--from Production.Product as p1
--where not exists
--(select sod2.SalesOrderID
--from Sales.SalesOrderDetail as sod2
--group by sod2.SalesOrderID
--having sod2.ProductID = any 
--(select p3.ProductID
--from Production.Product as p3
--where p3.ListPrice = any 
--(select max(p4.ListPrice)
--from Production.Product as p4
--inner join Production.ProductSubcategory as ps4
--on p3.ProductSubcategoryID = ps4.ProductSubcategoryID
--group by ps4.ProductSubcategoryID)
--)
--);

--10 ?
select soh1.CustomerID
from Sales.SalesOrderHeader as soh1
where (select count(distinct sod3.SalesOrderID)
		from Sales.SalesOrderDetail as sod3
		where sod3.SalesOrderID in
			(select soh2.SalesOrderID
			from Sales.SalesOrderHeader as soh2
			inner join Sales.SalesOrderDetail as sod2
			on soh2.SalesOrderID = soh2.SalesOrderID
			where soh2.CustomerID = soh1.CustomerID
			group by soh2.SalesOrderID
			having (select count(distinct sod4.ProductID)
					from Sales.SalesOrderDetail as sod4
					inner join Sales.SalesOrderHeader as soh4
					on sod4.SalesOrderID = soh4.SalesOrderID
					where soh4.CustomerID = soh1.CustomerID and soh4.SalesOrderID = soh2.SalesOrderID
						and (select count(distinct soh5.SalesOrderID)
						from Sales.SalesOrderDetail as sod5
						inner join Sales.SalesOrderHeader as soh5
						on sod4.SalesOrderID = soh4.SalesOrderID
						where sod5.ProductID = sod4.ProductID and soh5.CustomerID != soh4.CustomerID) > 3
					) > 3
			)
		) > 2;

--11



--1
select distinct p1.Name
from Production.Product as p1
where p1.ProductID in 
(select top 1 with ties sod2.ProductID
from Sales.SalesOrderDetail as sod2
group by sod2.ProductID
order by sum(sod2.OrderQty) desc);

--2
select distinct soh1.CustomerID
from Sales.SalesOrderHeader as soh1
where soh1.SalesorderID = 
	(select top 1 sod2.SalesOrderID
	from Sales.SalesOrderDetail as sod2
	group by sod2.SalesOrderID
	order by sum(sod2.UnitPrice) desc);

--3
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

--4
select p1.Name
from Production.Product as p1
where p1.ListPrice > 
	(select avg(p2.ListPrice) 
	from Production.Product as p2
	right join Production.ProductSubcategory as ps2
	on p2.ProductSubcategoryID = ps2.ProductSubcategoryID
	where ps2.ProductSubcategoryID = p1.ProductSubcategoryID);

--5

--6
select p1.Name
from Production.Product as p1
where p1.ProductID in 
	(select distinct sod2.ProductID
	from Sales.SalesOrderDetail as sod2
	inner join Sales.SalesOrderHeader as soh2
	on sod2.SalesOrderID = soh2.SalesOrderID
	where sod2.ProductID = p1.ProductID and 
		(select count(distinct sod3.SalesOrderID)
		from Sales.SalesOrderDetail as sod3
		inner join Sales.SalesOrderHeader as soh3
		on sod3.SalesOrderID = soh3.SalesOrderID
		where soh3.CustomerID = soh2.CustomerID and sod3.ProductID = p1.ProductID)
		= 
		(select count(distinct soh4.SalesOrderID)
		from Sales.SalesOrderHeader as soh4
		where soh4.CustomerID = soh2.CustomerID)
	);

--7
select distinct soh1.CustomerID
from Sales.SalesOrderHeader as soh1
inner join Sales.SalesOrderDetail as sod1
on soh1.SalesOrderID = sod1.SalesOrderID
where not exists 
	(select sod2.SalesOrderID
	from Sales.SalesOrderDetail as sod2
	inner join Sales.SalesOrderHeader as soh2
	on sod2.SalesOrderID = soh2.SalesOrderID
	where soh2.CustomerID = soh1.CustomerID
	group by sod2.SalesOrderID
	having (select count(*)
			from Sales.SalesOrderDetail as sod3
			where sod3.ProductID = sod1.ProductID and sod3.SalesOrderID = sod2.SalesOrderID) = 0
	);

--8
--select distinct p1.Name
--from Production.Product as p1
--where 
--	(select count(distinct soh2.CustomerID)
--	from Sales.SalesOrderHeader as soh2
--	where exists 
--		(select distinct sod3.SalesOrderID
--		from Sales.SalesOrderDetail as sod3
--		where sod3.ProductID = p1.ProductID and sod3.SalesOrderID = soh2.SalesOrderID))
--	<= 3;

select distinct p1.Name
from Production.Product as p1
where p1.ProductID in
	(select sod2.ProductID
	from Sales.SalesOrderDetail as sod2
	inner join Sales.SalesOrderHeader as soh2
	on sod2.SalesOrderID = soh2.SalesOrderID
	group by sod2.ProductID
	having count(distinct soh2.CustomerID) <= 3);

--9 
--select p1.Name 
--from Production.Product as p1
--where exists
--	(select sod2.SalesOrderID
--	from Sales.SalesOrderDetail as sod2
--	group by sod2.SalesOrderID
--	having count(
--		(select p2.ProductID
--		from Production.Product as p2
--		where p2.ListPrice = Any
--			(select max(p3.ListPrice)
--			from Production.Product as p3
--			group by p3.ProductSubcategoryID))
--		) 
--		> 0 and count(p1.ProductID) > 0)

--10

--11?
select sod1.SalesOrderID
from Sales.SalesOrderDetail as sod1
where not exists 
	(select sod2.SalesOrderID
	from Sales.SalesOrderDetail as sod2
	where sod2.SalesOrderID = sod1.SalesOrderID and sod2.ProductID != 2)

--12
select sod1.ProductID
from Sales.SalesOrderDetail as sod1
where 
	(select count(distinct soh2.CustomerID)
	from Sales.SalesOrderDetail as sod2
	inner join Sales.SalesOrderHeader as soh2
	on sod2.SalesOrderID = soh2.SalesOrderID
	where sod2.productID = sod1.ProductID) > 3
	and
	(select count(distinct sod2.SalesOrderID)
	from Sales.SalesOrderDetail as sod2
	inner join Sales.SalesOrderHeader as soh2
	on sod2.SalesOrderID = soh2.SalesOrderID
	where sod2.productID = sod1.ProductID) > 3;

--13