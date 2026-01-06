USE AnalyticIQW10;
GO
-- Q1. From the Employee table, show: EmpName, Age. Create a new column AgeCategory:
-- where: Age < 30 → 'Young', Age between 30 and 40 → 'Mid', Age > 40 → 'Senior'

Select EmpName,Age,
Case 
   when Age < 30 then 'Young'
   when Age >= 30 and Age <=40 then 'Mid'
   else 'Senior'
End as AgeCategory
from Employee;

-- Q2. Group Employees based on their Salary: Low salary <60K, Mid Salary between 60k-10k, High Salary > 100k. Show Salary Category and TotalEmployees

Select
Case
    when Salary.Amount < 60000 then 'Low Salary'
	when Salary.Amount >= 60000 and Salary.Amount <= 100000 then 'Mid Salary'
	else 'High Salary'
End as SalaryCategory,
count(Employee.EmpID) as TotalEmployees
from Salary
join Employee on Employee.SalaryID = Salary.SalaryID
group by 
      Case
    when Salary.Amount < 60000 then 'Low Salary'
	when Salary.Amount >= 60000 and Salary.Amount <= 100000 then 'Mid Salary'
	else 'High Salary'
End;