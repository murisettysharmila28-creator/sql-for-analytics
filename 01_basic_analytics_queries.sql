-- SQL Analytics Practice
-- Covers filtering, joins, aggregation, subqueries, and date-based analysis
-- Database: Lab3_Analytics


USE Lab3_AnalytIQ;
Go

-- 1.List all customers ordered by Country and then by City in ascending order.
Select *
From Customers
Order by Country, City; -- by default sorts in ASCENDING order and will sort the first Column (County) specified first in the statement

-- 2.Display all products ordered by Price (descending). If two products have the same price, order them alphabetically by ProductName.
Select *
From Products
Order by Price DESC , ProductName; -- when two products have the same price sorts Products alphabetically by their name

-- 3.	Find all customers from Canada or USA whose FirstName starts with 'A' or 'B'.
Select *
From Customers
Where Country in ('Canada','USA')
and (FirstName like 'A%' or Firstname like 'B%');

-- Retrieve all orders placed in March 2024 and paid using Credit Card or PayPal.

Select *
from Orders
Where (Year(OrderDate) = '2024') -- YEAR extract year
and (Month(OrderDate) = 3) -- MONTH extracts month
and (PaymentMethod = 'Credit Card' or PaymentMethod = 'PayPal');

--5.	Find the total number of orders placed by each customer. Show CustomerID, FullName, and OrderCount.
Select Customers.CustomerID, Concat(Customers.FirstName,' ',Customers.LastName) as FullName, Count(Orders.OrderID) as OrderCount
from Customers
Join Orders on Customers.CustomerID = Orders.CustomerID
Where Orders.OrderDate is Not Null
Group by Customers.CustomerID, Customers.FirstName, Customers.LastName
HAVING COUNT(Orders.OrderID) > 0
Order by CustomerID, OrderCount Desc;

-- 6.	Calculate the average, minimum, and maximum product price for each product category.
Select Avg(Price) as Average, Min(Price) as Minimum, Max(Price) as Maximum, Category
from Products
Where Price is not null
Group by Category
Order by Average Desc,Minimum Desc, Maximum Desc, Category Asc;

-- 7.	Find the top 3 customers with the highest total spending (sum of Total in OrderDe-tails).
Select Top(3) Customers.CustomerID, Sum(OrderDetails.Total) as OrderTotal
From OrderDetails
join Orders on Orders.OrderID = OrderDetails.OrderID
join Customers on Customers.CustomerID = Orders.CustomerID
Group by Customers.CustomerID
Order by OrderTotal desc;

--8.	Find the customers who have placed at least one order containing a product priced above $1000 (use subquery).

Select distinct CustomerID, FirstName, LastName
from Customers
where CustomerID IN (
    select CustomerID
    from Orders
    where OrderID IN (
        select OrderID
        from OrderDetails
        where ProductID IN (
            select ProductID
            from Products
            where Price > 1000
        )
    )
);
-- 9.	Find products that were never ordered (subquery with NOT IN)

Select ProductName
from Products
where  ProductID not in 
       (Select ProductID 
        from OrderDetails
        Where ProductID is not null
       );
        
 -- 10.	Find all customers whose total spending is above the average spending of all cus-tomers (subquery with aggregation).


Select CustomerID, FirstName, LastName
from Customers
where CustomerID IN (
    select CustomerID
    from Orders 
    join OrderDetails  on Orders.OrderID = OrderDetails.OrderID
    group by CustomerID
    having sum(OrderDetails.Total) > (
        select avg(CustomerSpending)
        from (
            select Orders.CustomerID, sum(OrderDetails.Total) as CustomerSpending
            from Orders 
            join OrderDetails on Orders.OrderID = OrderDetails.OrderID
            group by Orders.CustomerID
        ) as SpendingPerCustomer
    )
);

-- 11.	List each order with customer name, product name, quantity, and total.

Select Concat(Customers.Firstname, ' ', Customers.LastName) as FullName, ProductName, Quantity, OrderDetails.Total
from Customers
join Orders on Orders.CustomerID = Customers.CustomerID
join OrderDetails on OrderDetails.OrderID = Orders.OrderID
join Products on Products.ProductID = OrderDetails.ProductID
Order by OrderDetails.Total Desc;

-- 12.	Show all customers along with the number of products they ordered (using JOIN + GROUP BY).
Select FirstName, LastName, sum(Quantity) as NumofProds
from Customers
join Orders on Orders.CustomerID = Customers.CustomerID
join OrderDetails on OrderDetails.OrderID = Orders.OrderID
join Products on Products.ProductID = OrderDetails.ProductID
group by Firstname,LastName
Order by NumofProds desc;

-- 13.	Find the highest-priced product purchased by each customer.
Select FirstName, LastName, ProductName ,Price
from Customers
join Orders on Orders.CustomerID = Customers.CustomerID -- this join will tell which products each customer bought
join OrderDetails on OrderDetails.OrderID = Orders.OrderID
join Products on Products.ProductID = OrderDetails.ProductID
where Price = (
    select max(Products2.Price)
    from Orders as Orders2
    join OrderDetails as OrderDetails2 on OrderDetails2.OrderID = Orders2.OrderID -- performing repeat join in sub query to find what the maximum product price is per customer
    join Products as Products2 on Products2.ProductID = OrderDetails2.ProductID
    where Orders2.CustomerID = Customers.CustomerID
)
 Order by  Price desc;

-- 14.	List all customers and their orders. If a customer has not placed an order, still show their name with NULL in OrderID.
 
Select Concat(Customers.Firstname, ' ', Customers.LastName) as FullName, ProductName, Quantity, OrderDetails.Total
from Customers
left join Orders on Orders.CustomerID = Customers.CustomerID
left join OrderDetails on OrderDetails.OrderID = Orders.OrderID
left join Products on Products.ProductID = OrderDetails.ProductID
Order by OrderDetails.Total Desc;

-- 15.	List all products and the orders they belong to. If a product was never ordered, still show the product name with NULL for OrderID.

Select ProductName, Orders.OrderID
from Products
left join OrderDetails on OrderDetails.ProductID = Products.ProductID
left join Orders on Orders.OrderID = OrderDetails.OrderID
Order by ProductName;

-- 16.	Find customers who are from Canada OR USA (use UNION).
Select FirstName,LastName, Country
from Customers
where Country = 'Canada'
union
Select FirstName,LastName, Country
from Customers
where Country = 'USA'

-- 17.	Find customers who are from Toronto and have also placed at least one order in March 2024 (use INTERSECT).

Select FirstName,LastName, City
from Customers
where City = 'Toronto'
intersect
Select FirstName,LastName, City
from Customers
join Orders on Orders.CustomerID = Customers.CustomerID
where year(OrderDate) = 2024 and month(OrderDate)=3

-- 18.	Find customers from London who have never placed an order (use EXCEPT).

Select FirstName,LastName, City
from Customers
where City = 'London'
except
Select FirstName,LastName, City
from Customers
join Orders on Orders.CustomerID = Customers.CustomerID

-- 19.Find customers who ordered products in electronic category

Select FirstName, LastName, Category, OrderDetails.OrderID
from Customers
join Orders on Orders.CustomerID = Customers.CustomerID
join OrderDetails on OrderDetails.OrderID = Orders.OrderID
join Products on Products.ProductID = OrderDetails.ProductID
where Category = 'Electronics'
