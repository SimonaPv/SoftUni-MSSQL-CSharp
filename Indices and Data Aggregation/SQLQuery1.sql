USE Gringotts

SELECT 
	a.AgeGroup,
	COUNT(*) AS	WizardCount
FROM
(
	SELECT 
		CASE
			WHEN Age BETWEEN 0 AND 10 THEN '[0-10]'
			WHEN Age BETWEEN 11 AND 20 THEN '[11-20]'
			WHEN Age BETWEEN 21 AND 30 THEN '[21-30]'
			WHEN Age BETWEEN 31 AND 40 THEN '[31-40]'
			WHEN Age BETWEEN 41 AND 50 THEN '[41-50]'
			WHEN Age BETWEEN 51 AND 60 THEN '[51-60]'
			ELSE '[61+]'
			END AS AgeGroup
	FROM WizzardDeposits
) AS a
GROUP BY a.AgeGroup


SELECT 
	LEFT(FirstName, 1) AS FirstLetter
FROM WizzardDeposits
GROUP BY LEFT(FirstName, 1), DepositGroup
	HAVING DepositGroup = 'Troll Chest' --AND COUNT(LEFT(FirstName, 1)) = 1
ORDER BY FirstLetter


SELECT
	DepositGroup,
	IsDepositExpired,
	AVG(DepositInterest) AS AverageInterest
FROM WizzardDeposits
WHERE DepositStartDate > '1985-01-01'
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired 


USE SoftUni


SELECT
	DepartmentID,
	MIN(Salary)
FROM Employees
WHERE HireDate > '2000-01-01'
GROUP BY DepartmentID
HAVING DepartmentID IN (2, 5, 7)
ORDER BY DepartmentID


SELECT * INTO NewTable
FROM Employees
WHERE Salary > 30000

DELETE FROM NewTable
WHERE ManagerID = 42

UPDATE NewTable
SET Salary += 5000
WHERE DepartmentID = 1

SELECT 
	DepartmentID,
	AVG(Salary) AS AverageSalary
FROM NewTable
GROUP BY DepartmentID


SELECT
	DepartmentID,
	MAX(Salary)
FROM Employees
GROUP BY DepartmentID
HAVING MAX(Salary) NOT BETWEEN 30000 AND 70000


SELECT
	COUNT(Salary)
FROM Employees
WHERE ManagerID IS NULL