SELECT PersonID FROM Sales.Customer
UNION
SELECT BusinessEntityID FROM HumanResources.Employee

SELECT FirstName,LastName,PersonType
FROM Person.Person
WHERE BusinessEntityID IN(
SELECT PersonID FROM Sales.Customer
UNION
SELECT BusinessEntityID FROM HumanResources.Employee
)

SELECT FirstName,LastName
FROM Person.Person p
INNER JOIN Sales.Customer sc
ON p.BusinessEntityID=sc.PersonID
INNER JOIN HumanResources.Employee em
ON em.BusinessEntityID=p.BusinessEntityID

SELECT FirstName,LastName
FROM Person.Person
WHERE BusinessEntityID IN (
SELECT BusinessEntityID FROM HumanResources.Employee)
OR
BusinessEntityID IN (
SELECT PersonID
FROM Sales.Customer)

SELECT BusinessEntityID FROM HumanResources.Employee
WHERE BusinessEntityID IN (
	SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
	WHERE DepartmentID IN (
		SELECT DepartmentID FROM HumanResources.Department
		WHERE Name='Research and Development'
	)
)
UNION
SELECT BusinessEntityID FROM HumanResources.Employee
WHERE BusinessEntityID IN (
	SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
	WHERE ShiftID IN (
		SELECT ShiftID FROM HumanResources.Shift
		WHERE ShiftID='1' OR ShiftID='2'
	)
)

SELECT FirstName,LastName FROM Person.Person
WHERE BusinessEntityID IN(
SELECT BusinessEntityID FROM HumanResources.Employee
WHERE BusinessEntityID IN (
	SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
	WHERE DepartmentID IN (
		SELECT DepartmentID FROM HumanResources.Department
		WHERE Name='Research and Development'
	)
)
UNION
SELECT BusinessEntityID FROM HumanResources.Employee
WHERE BusinessEntityID IN (
	SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
	WHERE ShiftID IN (
		SELECT ShiftID FROM HumanResources.Shift
		WHERE ShiftID='1' OR ShiftID='2'
	)
)
)

SELECT FirstName,LastName FROM Person.Person
WHERE BusinessEntityID IN(
SELECT BusinessEntityID FROM HumanResources.Employee
WHERE BusinessEntityID IN (
	SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
	WHERE DepartmentID IN (
		SELECT DepartmentID FROM HumanResources.Department
		WHERE Name='Research and Development'
	)
)
)
OR
BusinessEntityID IN(
SELECT BusinessEntityID FROM HumanResources.Employee
WHERE BusinessEntityID IN (
	SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
	WHERE ShiftID IN (
		SELECT ShiftID FROM HumanResources.Shift
		WHERE ShiftID='1' OR ShiftID='2'
	)
)
)

SELECT FirstName,LastName FROM Person.Person
WHERE BusinessEntityID IN(
	SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
	WHERE DepartmentID IN (
		SELECT DepartmentID FROM HumanResources.Department
		WHERE Name='Research and Development'
	)
)
OR
BusinessEntityID IN(
	SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
	WHERE ShiftID IN (
		SELECT ShiftID FROM HumanResources.Shift
		WHERE ShiftID='1' OR ShiftID='2'
	)
)

SELECT FirstName,LastName FROM Person.Person
WHERE BusinessEntityID IN(
	SELECT BusinessEntityID FROM HumanResources.EmployeePayHistory
	WHERE Rate>2
	INTERSECT
	SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
	WHERE ShiftID IN (
		SELECT ShiftID FROM HumanResources.Shift
		WHERE '08:00:00' BETWEEN StartTime AND EndTime
	UNION
		SELECT ShiftID FROM HumanResources.Shift
		WHERE '22:00:00' BETWEEN StartTime AND EndTime
	)
)

SELECT FirstName,LastName FROM Person.Person
WHERE BusinessEntityID IN(
	SELECT PersonID FROM Sales.Customer
	WHERE TerritoryID IN (
		SELECT TerritoryID FROM Sales.SalesTerritory
		WHERE Name='Canada'
	)
INTERSECT
	SELECT PersonID FROM Sales.Customer
	WHERE CustomerID IN (
		SELECT CustomerID,SUM(SubTotal) AS 'Ukupno' FROM Sales.SalesOrderHeader
		GROUP BY CustomerID
		HAVING SUM(SubTotal)>500
	)
)

SELECT FirstName,LastName FROM Person.Person
WHERE BusinessEntityID IN (
SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
WHERE ShiftID IN(
SELECT ShiftID FROM HumanResources.Shift
WHERE '08:00:00' BETWEEN StartTime AND EndTime
UNION 
SELECT ShiftID FROM HumanResources.Shift
WHERE '22:00:00' BETWEEN StartTime AND EndTime
)
EXCEPT
SELECT BusinessEntityID FROM HumanResources.EmployeePayHistory
WHERE Rate<2
)

SELECT FirstName,LastName FROM Person.Person
WHERE BusinessEntityID IN (
	SELECT PersonID FROM Sales.Customer
	WHERE TerritoryID IN (
		SELECT TerritoryID FROM Sales.SalesTerritory
		WHERE Name='Canada'
	)
	INTERSECT (
		SELECT PersonID FROM Sales.Customer
		WHERE CustomerID IN (
			SELECT CustomerID FROM Sales.SalesOrderHeader
			WHERE SubTotal>200
		)
		UNION
		SELECT PersonID FROM Sales.Customer
		WHERE CustomerID IN (
			SELECT CustomerID FROM Sales.SalesOrderHeader
			WHERE SalesOrderID IN (
				SELECT SalesOrderID FROM Sales.SalesOrderDetail
				WHERE ProductID IN (
					SELECT ProductID FROM Sales.SpecialOfferProduct
				)
			)
		)
)	
)

SELECT CustomerID,Sales.SalesOrderDetail.ProductID,COUNT(*) FROM Sales.SalesOrderHeader
INNER JOIN Sales.SalesOrderDetail
ON Sales.SalesOrderHeader.SalesOrderID=Sales.SalesOrderDetail.SalesOrderID
INNER JOIN Sales.SpecialOfferProduct
ON Sales.SalesOrderDetail.SpecialOfferID=Sales.SpecialOfferProduct.SpecialOfferID
GROUP BY CustomerID,Sales.SalesOrderDetail.ProductID

WITH SalesProduct AS
(
	SELECT sod.SpecialOfferID FROM Sales.SalesOrderHeader soh
	INNER JOIN Sales.SalesOrderDetail sod
	ON soh.SalesOrderID=sod.SalesOrderID
)
SELECT * FROM SalesProduct sp

WITH PersonVistaCreditCard AS (
	
	SELECT BusinessEntityID FROM Sales.PersonCreditCard
	WHERE CreditCardID IN (
	SELECT CreditCardID FROM Sales.CreditCard
	WHERE CardType='ColonialVoice' AND ExpMonth=7
	)
)
SELECT * FROM Person.Person
WHERE BusinessEntityID IN (
	SELECT PersonID FROM Sales.Customer
) AND BusinessEntityID IN (SELECT BusinessEntityID FROM PersonVistaCreditCard)
AND BusinessEntityID = (
SELECT PersonID FROM Sales.Customer
WHERE CustomerID =
(SELECT CustomerID FROM Sales.SalesOrderHeader 
WHERE SubTotal = (SELECT MAX(SubTotal) FROM Sales.SalesOrderHeader))
)
