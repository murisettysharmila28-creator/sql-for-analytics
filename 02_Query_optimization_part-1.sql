/*
Demonstrates:
- Nested aggregation
- Correlated subqueries
- Business performance analysis
*/

-- Create Database
Create Database Lab_9
Go
Use Lab_9

CREATE TABLE Departments (
DepartmentID INT PRIMARY KEY,
DepartmentName VARCHAR(50) NOT NULL UNIQUE
);

Insert into Departments (DepartmentID,DepartmentName)
Values 
(01,'HealthCare'),
(02,'Baby'),
(03,'Food');

Insert into Departments (DepartmentID,DepartmentName)
Values 
(04,'Electronics'),
(05,'Clothing'),
(06,'Cosmetics');

CREATE TABLE Employees (
EmpID INT PRIMARY KEY,
EmpName VARCHAR(50) NOT NULL,
DepartmentID INT,
Salary DECIMAL(10,2) CHECK (Salary >= 30000),
HireDate DATE DEFAULT GETDATE(),
FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

Insert into Employees (EmpID,EmpName,DepartmentID,Salary,HireDate)
Values
(1,'Elsa',3,50000,'2024-02-10'),
(2,'Gunner',1,62000.00,'2023-11-01'),
(3,'Ariel',2,48000.00,'2024-01-15'),
(4,'David',3,55000.00,'2022-07-23'),
(5,'Daisy',1,72000.00,'2021-12-10'),
(6,'Freddy',2,46000.00,'2023-03-28'),
(7,'Ash',3,51000.00,'2024-04-12'),
(8,'Tuffy',1,80000.00,'2020-09-17'),
(9,'Emma',2,47000.00,'2022-05-03'),
(10,'Paisly',3,52000.00,'2023-02-20'),
(11,'Moe',1,60000.00,'2023-06-14'),
(12,'Peach',2,45000.00,'2021-10-08'),
(13,'Saddie',3,56000.00,'2022-03-19'),
(14,'Mosely',1,77000.00,'2023-08-09'),
(15,'Penny',2,49000.00,'2024-01-25');

CREATE TABLE Sales (
SaleID INT PRIMARY KEY,
EmpID INT NOT NULL,
SaleAmount DECIMAL(10,2) CHECK (SaleAmount > 0),
SaleDate DATE DEFAULT GETDATE(),
FOREIGN KEY (EmpID) REFERENCES Employees(EmpID)
);

Insert into Sales (SaleID,EmpID,SaleAmount,SaleDate)
Values
(1,1,1500.00,'2024-03-10'),
(2,3,1200.00,'2024-02-20'),
(3,4,1800.00,'2023-11-15'),
(4,5,3200.00,'2023-09-10'),
(5,7,1750.00,'2024-01-08'),
(6,8,4000.00,'2022-12-20'),
(7,9,1350.00,'2023-06-25'),
(8,10,2100.00,'2024-04-18'),
(9,13,1900.00,'2023-09-30'),
(10,15,1400.00,'2024-03-16'),
(11,1,2200.00,'2024-05-02'),
(12,3,1550.00,'2024-03-25'),
(13,4,2650.00,'2023-12-05'),
(14,7,1950.00,'2024-02-15'),
(15,9,1750.00,'2023-08-10'),
(16,10, 2450.00,'2024-05-10'),
(17,13,3000.00,'2023-10-02'),
(18,15,2100.00,'2024-04-12'),
(19,5,2800.00,'2023-10-25'),
(20,6,1250.00,'2023-07-19');

-- Displaying Tables
Select * from Departments;
Select * from Employees;
Select * from Sales;

--Section B – Subqueries

--1. List of departments where total sales exceed the average sales of all departments.

 --- a.Calculate each dep Total Sales (To Food,Tot health...)
Select DepartmentName,SUM(SaleAmount) as TotalSales
from Departments
join Employees on Employees.DepartmentID = Departments.DepartmentID
join Sales on Sales.EmpID = Employees.EmpID
Group by DepartmentName 
Having SUM(SaleAmount)> --- Filter dept tot>avg
   ( 
     Select Avg(DepartmentTotal) ---b. avg of total sales across depts (Tot Food + Tot Heath...) nesting a to compare with single value
	 from
        (SELECT Sum(S.SaleAmount) as DepartmentTotal
        FROM Departments as D  
        join Employees as E ON D.DepartmentID = E.DepartmentID 
        join Sales as S ON E.EmpID = S.EmpID 
        group by D.DepartmentName 
	    )As DeptSales
    ); 

--2. Display employees who have made more than 2 sales (correlated subquery)

Select E.EmpName
from Employees as E  -- Goes through each Employee
where 2< -- Keeps employee where count is greater than 2
       (Select count(S.SaleID)
	   from Sales as S
	   where S.EmpID = E.EmpID); -- Counts sales made by each employee

-- Geting count of sales made by each employee

Select E.EmpName, count(S.SaleID) as CountofSales
from Employees as E
join Sales as S on E.EmpID = S.EmpID
Group by E.EmpName

--3. Find the employee with the highest total sales amount.

Select E.EmpName, sum(S.SaleAmount) as TotalSales -- Outer query group total sales by each emp
from Employees as E
Join Sales as S on S.EmpID = E.EmpID
group by E.EmpName
Having sum(S.SaleAmount) >= All -- Keeps employees whose tot is greater than equal to every other employee tot
       (Select sum(s1.SaleAmount) -- Calculates all employees total sales
	    from Employees as E1
        Join Sales as S1 on S1.EmpID = E1.EmpID
		group by E1.EmpName);

-- Without Subquery

Select Top 1 E.EmpName, sum(S.SaleAmount) as TotalSales -- Outer query group total sales by each emp
from Employees as E
Join Sales as S on S.EmpID = E.EmpID
group by E.EmpName
order by sum(S.SaleAmount) desc;

--4. List of employees who have never made a sale

Select E.EmpName    -- Goes through all employees
from Employees as E
where not exists  -- Filters employee who have no matching rows
               ( Select S.EmpID  -- will check sales by each employee
                 from Sales as S 
				 where S.EmpID = E.EmpID
				);

--Section C – CTEs

-- 1. Create a CTE to display each employee along with their total sales amount

;with EmployeeSales as 
(
  Select E.EmpName, sum(S.SaleAmount) as TotalSales
  from Employees as E
  join Sales as S on S.EmpID = E.EmpID
  Group by E.EmpName
)

Select * from EmployeeSales;

-- 2.Use CTE to find average salary per department; show only departments above $60,000

;with AvgSalaryDep as
(
  Select D.DepartmentName, Avg(E.Salary) as AverageSalary
  from Employees as E
  join Departments as D on D.DepartmentID = E.DepartmentID
  group by D.DepartmentName
)

Select * from AvgSalaryDep  where AverageSalary >60000;

-- 3. Create a recursive CTE to simulate employee–manager hierarchy

Create table Hierarchy ( 
EmpID INT  Primary key,
ManagerID INT,
Foreign key (ManagerID) references Employees(EmpID));

Insert into Hierarchy (EmpID,ManagerID)
VALUES (1, Null), --- CEO
(2, 3), 
(3, 4), 
(4, 5),
(5, 5),
(6, 4),
(7, 2),
(8,2),
(9,3),
(10,13),
(11,1),
(12,1),
(13,2),
(14,4),
(15,4);

UPDATE Hierarchy
SET ManagerID = 2
WHERE EmpID = 10;

UPDATE Hierarchy
SET ManagerID = 2
WHERE EmpID = 5;

UPDATE Hierarchy 
SET ManagerID = 1 
WHERE EmpID = 5;


Select* from Hierarchy;

;with HierarchyCTE as (
 Select EmpID,ManagerID, 1 as Level
 from Hierarchy
 where ManagerID is Null

 Union All

 Select H.EmpID,H.ManagerID, HC.Level +1
 from Hierarchy H
 join HierarchyCTE HC ON H.ManagerID = HC.EmpID
 )
 SELECT * FROM HierarchyCTE;

-- 4. Combine a CTE with aggregation to display top 3 performing employees

;with TopEmpCTE as (
 Select E.EmpName, Sum(SaleAmount) as TotalSales
 from Employees E
 join Sales S on S.EmpID = E.EmpID
 group by E.EmpName
 )
 Select Top 3 EmpName, TotalSales 
 from TopEmpCTE
 Order by TotalSales Desc;

 -- Section D – Functions

-- 1. Create a scalar function that calculates 15% commission on a given sale amount.

Create Function CalculateCommision --Function name
(@SaleAmount int) --input Parameter
Returns Decimal(10,2) -- Type of return value
As
Begin
 Declare @Commission Decimal(10,2); -- Local variable
 Set @Commission = @SaleAmount*0.15; -- Calculate commision
 Return @Commission;
 End;

 Select EmpID,SaleAmount,dbo.CalculateCommision(SaleAmount)as Commision
 from Sales;

 --  2. Create a table-valued function that returns all sales for a given employee.

 Create function GetSales
 (@EmpName varchar(50))
 Returns Table
 As
 Return(
        Select E.EmpName,E.EmpID,S.SaleID,S.SaleAmount
		from Employees E
		join Sales S on S.EmpID = E.EmpID
		where E.EmpName = @EmpName);

Select * from dbo.GetSales('Tuffy');

-- 3. Develop a function that returns performance categories (Excellent, Good, Needs Improvement).

Create Function PerformanceCategories
(@TotalSales Decimal(10,2))
Returns Varchar(20)
As
Begin
 Declare @Category Varchar(30);
 if @TotalSales >= 10000
    set @Category = 'Excellent';
 else if @TotalSales >= 5000
    set @Category = 'Good';
 else
    set @Category = 'Needs Improvement';
 Return @Category;
 End;

 Select dbo.PerformanceCategories(4000) as Performance;
 Select dbo.PerformanceCategories(10000) as Performance;
 Select dbo.PerformanceCategories(6000) as Performance;

 -- 4. Use the function in a SELECT query to display employee name, total sales, and performance category.

 Select E.EmpName, Sum(S.SaleAmount) as TotalSales, dbo.PerformanceCategories(sum(S.SaleAmount)) as PerformanceCategory
 from Employees E
 join Sales S on E.EmpID = S.EmpID
 Group by E.EmpName
 Order by TotalSales Desc;

-- Section E – Stored Procedures

-- 1. Create a procedure to display all employees.

Create Procedure GetAllEmployees
As
Begin
 Select * from Employees;
End;

Exec GetAllEmployees;

-- 2. Create a procedure that accepts DepartmentID and returns employees in that department.

Create Procedure GetEmpbyDep
@DepartmentID int
As
Begin
Select EmpID,EmpName,DepartmentID
from Employees
where DepartmentID = @DepartmentID;
End;

Exec GetEmpbyDep @DepartmentID = 2;

-- 3. Write a procedure to increase salary by 10% for employees with above-average total sales.
Create Procedure IncreaseSalaryAboveAvg
As
Begin
Declare @AverageSales decimal(10,2); -- variable that temporarily holds values
Select @AverageSales = Avg(TotalSales) -- Cal avg of each employees tot sales
from(
     Select sum(SaleAmount) as TotalSales
	 from Sales
	 group by EmpID
	 ) as a;

     update E -- Updating salaries of employees above avg
	 set E.Salary = E.Salary*1.10
	 from Employees E
	 join (
	       Select EmpID, Sum(SaleAmount) as TotalSales
		   from Sales
		   group by EmpID
		   Having sum(SaleAmount) > @AverageSales
		   ) as HighPerformer
		on E.EmpID = HighPerformer.EmpID;
End;

Exec IncreaseSalaryAboveAvg;
Exec GetAllEmployees;

---4. Create a procedure to return department-wise total sales.

CREATE PROCEDURE dbo.DepartmentSalesSummary
AS
BEGIN
    SELECT D.DepartmentName, SUM(s.SaleAmount) AS TotalSales
    FROM Departments D
    JOIN Employees E ON E.DepartmentID = D.DepartmentID
    JOIN Sales S ON S.EmpID = E.EmpID
    GROUP BY d.DepartmentName
    ORDER BY TotalSales DESC;
END;

EXEC dbo.DepartmentSalesSummary;	   

    
       





 
