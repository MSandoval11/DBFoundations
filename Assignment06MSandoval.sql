--*************************************************************************--
-- Title: Assignment06
-- Author: MSandoval
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,MSandoval,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MSandoval')
	 Begin 
	  Alter Database [Assignment06DB_MSandoval] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MSandoval;
	 End
	Create Database Assignment06DB_MSandoval;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MSandoval;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
GO 
CREATE VIEW vCategories 
WITH SCHEMABINDING
AS 
  SELECT CategoryID, CategoryName
FROM dbo.Categories
GO

CREATE VIEW vProducts 
WITH SCHEMABINDING
AS
  SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM dbo.Products
GO

CREATE VIEW vEmployees 
WITH SCHEMABINDING
AS
  SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM dbo.Employees
GO

CREATE VIEW vInventories 
WITH SCHEMABINDING
AS
  SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
FROM dbo.Inventories
GO


SELECT * FROM vCategories
GO
SELECT * FROM vProducts
GO
SELECT * FROM vEmployees
GO
SELECT * FROM vInventories
GO


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON Categories TO PUBLIC
GRANT SELECT ON vCategories TO PUBLIC
GO

DENY SELECT ON Products TO PUBLIC
GRANT SELECT ON vProducts TO PUBLIC
GO

DENY SELECT ON Employees TO PUBLIC
GRANT SELECT ON vEmployees TO PUBLIC
GO

DENY SELECT ON Inventories TO PUBLIC
GRANT SELECT ON vInventories TO PUBLIC
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

/*	
	--Look at all data 
		Select * From vCategories;
		Select * From vProducts;
	--Look at just the data we want
		Select CategoryName From vCategories;
		Select ProductName, UnitPrice  From vProducts
	--Combine the results
		Select CategoryName, ProductName, UnitPrice
		From vCategories
		Join vProducts On Categories.CategoryID = Products.CategoryID
		Order By CategoryName, ProductName
	--Add Alises
		Select CategoryName, ProductName, UnitPrice
		From vCategories as C
		Join vProducts as P On C.CategoryID = P.CategoryID
		Order By CategoryName, ProductName
*/
CREATE VIEW vProductsByCategories 
AS 
  SELECT TOP 100000 
	CategoryName, ProductName, UnitPrice
		FROM vCategories AS C
		Join vProducts AS P 
		  ON C.CategoryID = P.CategoryID
		ORDER BY CategoryName, ProductName
GO

SELECT * FROM vProductsByCategories 
GO



-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33

/*
	--Look at all data 
		Select * From vProducts;
		Select * From vInventories;
	--Look at just the data we want
		Select ProductName From vProducts;
		Select InventoryDate, Count  From vInventories
	--Combine the results
		Select ProductName, InventoryDate, Count
		From vProducts
		Join vInventories On Products.ProductID = Inventories.ProductID
		Order By InventoryDate, ProductName, Count
	--Add Alises 
		Select Distinct InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
		From vInventories as I
		Join vEmployees as E On I.EmployeeID = E.EmployeeID
		Order By InventoryDate
*/

--Write final View Code
CREATE VIEW vInventoriesByProductsByDates
AS
	SELECT TOP 1000000
	  ProductName, InventoryDate, Count
		FROM vProducts AS P
		Join vInventories AS I ON P.ProductID = I.ProductID
		ORDER BY ProductName, InventoryDate, Count
GO

SELECT * FROM vInventoriesByProductsByDates
GO



-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

/*
	--Look at all data 
		Select * From vInventories;
		Select * From vEmployees;
	--Look at just the data we want
		Select Distinct InventoryDate From vInventories
		Select EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName  From vEmployees
	--Combine the results
		Select Distinct InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
		From vInventories
		Join vEmployees On Inventories.EmployeeID = Employees.EmployeeID
		Order By InventoryDate
*/
	--Write final Code and Create View 
CREATE VIEW vInventoriesByEmployeesByDates
	AS	
		SELECT DISTINCT
		InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
		FROM vInventories AS I
		Join vEmployees AS E On I.EmployeeID = E.EmployeeID	
GO

SELECT * FROM vInventoriesByEmployeesByDates

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37

/*
	--Look at all data 
		Select * From vCategories;
		Select * From vProducts;
		Select * From vInventories;
	--Look at just the data we want
		Select CategoryName From vCategories
		Select ProductName From vProducts
		Select InventoryDate, Count From vInventories
	--Combine the results
		Select CategoryName, ProductName, InventoryDate, Count
		From vCategories 
		Join vProducts On Categories.CategoryID = Products.CategoryID
		Join vInventories On Products.ProductID = Inventories.ProductID
		Order By CategoryName, ProductName, InventoryDate, Count
*/
	--Adding Alises to final View code
GO
CREATE VIEW vInventoriesByProductsByCategories
	AS
		SELECT TOP 1000000
		CategoryName, ProductName, InventoryDate, Count
		FROM vCategories AS C
		Join vProducts AS P ON C.CategoryID = P.CategoryID
		Join vInventories AS I ON P.ProductID = I.ProductID
		ORDER BY CategoryName, ProductName, InventoryDate, Count
GO

SELECT * FROM vInventoriesByProductsByCategories


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan

/*
	--Look at all data 
		Select * From vCategories;
		Select * From vProducts;
		Select * From vInventories;
		Select * From vEmployees
	--Look at just the data we want
		Select CategoryName From vCategories
		Select ProductName From vProducts
		Select InventoryDate, Count From vInventories
		Select EmployeeFirstName + ' ' + EmployeeLastName as vEmployeeName
	--Combine the results
		Select CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
		From vCategories 
		Join vProducts On Categories.CategoryID = Products.CategoryID
		Join vInventories On Products.ProductID = Inventories.ProductID
		Join vEmployees On Inventories.EmployeeID = Employees.EmployeeID
		Order By InventoryDate, CategoryName, ProductName, EmployeeName
	--Add Alises to code
		Select CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
		From Categories as C
		Join Products as P On C.CategoryID = P.CategoryID
		Join Inventories as I On P.ProductID = I.ProductID
		Join Employees as E On I.EmployeeID = E.EmployeeID
		Order By InventoryDate, CategoryName, ProductName, EmployeeName
*/
	--Create final view code
GO
CREATE VIEW vInventoriesByProductsByEmployees
	AS
		SELECT TOP 1000000
		CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
		FROM vCategories AS C
		Join vProducts AS P ON C.CategoryID = P.CategoryID
		Join vInventories AS I ON P.ProductID = I.ProductID
		Join vEmployees AS E ON I.EmployeeID = E.EmployeeID
		ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName
GO

SELECT * FROM vInventoriesByProductsByEmployees





-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth

/*
	--Look at all data 
		Select * From vCategories;
		Select * From vProducts;
		Select * From vInventories;
		Select * From vEmployees
	--Look at just the data we want
		Select CategoryName From vCategories
		Select ProductName From vProducts
		Select InventoryDate, Count From vInventories
		Select EmployeeFirstName + ' ' + EmployeeLastName as vEmployeeName
	--Perform subquery to determine ProductID based on ProductNames
		Select ProductID 
		From Products
		Where ProductName = 'Chai' OR ProductName = 'Chang'
	--Combine the results
		Select CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
		From Categories 
		Join Products On Categories.CategoryID = Products.CategoryID
		Join Inventories On Products.ProductID = Inventories.ProductID
		Join Employees On Inventories.EmployeeID = Employees.EmployeeID
			Where Products.ProductName = 'Chai' OR Products.ProductName = 'Chang'
		Order By InventoryDate, CategoryName, ProductName, EmployeeName
	--Add Alises to final code
		Select CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
		From vCategories as C
		Join vProducts as P On C.CategoryID = P.CategoryID
		Join vInventories as I On P.ProductID = I.ProductID
		Join vEmployees as E On I.EmployeeID = E.EmployeeID
			Where P.ProductName = 'Chai' OR P.ProductName = 'Chang'
		Order By InventoryDate, CategoryName, ProductName, EmployeeName
*/
	--Write final View Code


GO
CREATE VIEW vInventoriesForChaiAndChangByEmployees
	AS
		SELECT TOP 1000000
		CategoryName, ProductName, InventoryDate, Count, EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName
		FROM vCategories AS C
		Join vProducts AS P ON C.CategoryID = P.CategoryID
		Join vInventories AS I ON P.ProductID = I.ProductID
		Join vEmployees AS E ON I.EmployeeID = E.EmployeeID
			WHERE P.ProductName = 'Chai' OR P.ProductName = 'Chang'
		ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName
GO

SELECT * FROM vInventoriesForChaiAndChangByEmployees




-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King

/*

	--Look at all data 
		Select * From vEmployees
	--Look at just the data we want
		Select EmployeeFirstName + ' ' + EmployeeLastName as EmployeeName From vEmployees
	--Join Data
		Select m.EmployeeFirstName + ' ' + m.EmployeeLastName as Manager, e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee
		From vEmployees as e
		Join vEmployees as m
		on e.ManagerID = m.EmployeeID
	--order data by Manager's Name and employee's name
		Select m.EmployeeFirstName + ' ' + m.EmployeeLastName as Manager, e.EmployeeFirstName + ' ' + e.EmployeeLastName as Employee
		From vEmployees as e
		Join vEmployees as m
		on e.ManagerID = m.EmployeeID
			order by m.EmployeeFirstName, e.EmployeeFirstName
*/
	--Write final View Code
GO
CREATE VIEW vEmployeesByManager
	AS
		SELECT TOP 1000000
		m.EmployeeFirstName + ' ' + m.EmployeeLastName AS Manager, e.EmployeeFirstName + ' ' + e.EmployeeLastName AS Employee
		FROM vEmployees AS e
		Join vEmployees AS m
		ON e.ManagerID = m.EmployeeID
			ORDER BY m.EmployeeFirstName, e.EmployeeFirstName
GO
SELECT * FROM vEmployeesByManager



-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	          2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	          2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	          2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	          2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica   	4.50	    24	          2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	          2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	          2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	          14.00	    34	          2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	          14.00	    111	          2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	          14.00	    188	          2017-03-01	  131	  9	          Anne Dodsworth

/*
	--Look at all data 
		Select * From vCategories;
		Select * From vProducts;
		Select * From vInventories;
		Select * From vEmployees
	--Look at just the data we want
		Select CategoryID, CategoryName From vCategories
		Select ProductID, ProductName, ProductName, UnitPrice From vProducts
		Select InventoryID, InventoryDate, Count From vInventories
		Select EmployeeID, EmployeeFirstName + ' ' + EmployeeLastName as Employee from Employees
	
	--Combine the results
		Select CategoryID, CategoryName, ProductID, ProductName, UnitPrice, InventoryID, InventoryDate, Count, EmployeeID, EmployeeFirstName + ' ' + EmployeeLastName as Employee
		From Categories 
		Join Products On Categories.CategoryID = Products.CategoryID
		Join Inventories On Products.ProductID = Inventories.ProductID
		Join Employees On Inventories.EmployeeID = Employees.EmployeeID
		order by CategoryName, ProductID, ProductName, InventoryID, Employee
				
	--Add Alises
			Select C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.Count, E.EmployeeID, E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
		From Categories AS C
		Join vProducts AS P On C.CategoryID = P.CategoryID
		Join vInventories AS I On P.ProductID = I.ProductID
		Join vEmployees AS E On I.EmployeeID = E.EmployeeID
		order by CategoryName, ProductID, ProductName, InventoryID, Employee
*/
		--Write final code and Create View

go
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
	AS
		SELECT TOP 1000000
		C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, 
		I.Count, E.EmployeeID, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
		From vCategories AS C
		Join vProducts AS P On C.CategoryID = P.CategoryID
		Join vInventories AS I On P.ProductID = I.ProductID
		Join vEmployees AS E On I.EmployeeID = E.EmployeeID
			ORDER BY CategoryID, ProductID, InventoryID, Employee
GO
SELECT * FROM vInventoriesByProductsByCategoriesByEmployees


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/