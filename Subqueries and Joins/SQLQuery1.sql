USE SoftUni

SELECT TOP 5 
	e.EmployeeID, 
	e.JobTitle,
	e.AddressID,
	a.AddressText
FROM Employees AS e 
JOIN Addresses AS a 
	ON e.AddressID = a.AddressID
ORDER BY AddressID 

SELECT TOP 50
	e.FirstName,
	e.LastName,
	t.[Name] AS Town,
	a.AddressText
FROM Employees AS e
JOIN Addresses AS a
	ON e.AddressID = a.AddressID
JOIN Towns AS t
	ON a.TownID = t.TownID
ORDER BY e.FirstName, e.LastName

SELECT 
	e.EmployeeID,
	e.FirstName,
	e.LastName,
	d.[Name] AS DepartmentName 
FROM Employees AS e
JOIN Departments AS d 
	ON e.DepartmentID = d.DepartmentID
WHERE d.[Name] = 'Sales'
ORDER BY e.EmployeeID

SELECT TOP 5
	e.EmployeeID,
	e.FirstName,
	e.Salary,
	d.[Name] AS DepartmentName 
FROM Employees AS e
JOIN Departments AS d 
	ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID

SELECT TOP 3
	e.EmployeeID, 
	e.FirstName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep
	ON e.EmployeeID = ep.EmployeeID
WHERE ep.ProjectID IS NULL
ORDER BY e.EmployeeID

SELECT 
	e.FirstName,
	e.LastName,
	e.HireDate,
	d.[Name] AS DeptName
FROM Employees AS e
JOIN Departments AS d
	ON e.DepartmentID = d.DepartmentID
WHERE e.HireDate > '1999-1-1' AND d.Name IN ('Sales', 'Finance')
ORDER BY e.HireDate

SELECT TOP 5
	e.EmployeeID, 
	e.FirstName,
	p.[Name] AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep
	ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p
	ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '2002-8-13' AND p.EndDate IS NULL
ORDER BY e.EmployeeID

SELECT TOP 5
	e.EmployeeID, 
	e.FirstName,
	CASE 
		WHEN p.StartDate >= '2005-1-1' THEN NULL
		ELSE p.[Name] 
	END AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep
	ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p
	ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24

SELECT 
	e.EmployeeID,
	e.FirstName,
	e.ManagerID,
	m.FirstName AS ManagerName
FROM Employees AS e
JOIN Employees AS m
	ON e.ManagerID = m.EmployeeID
WHERE m.EmployeeID IN (3, 7)
ORDER BY e.EmployeeID

SELECT TOP 50
	e.EmployeeID,
	e.FirstName + ' ' + e.LastName AS EmployeeName,
	m.FirstName + ' ' + m.LastName AS ManagerName,
	d.[Name] AS DepartmentName
FROM Employees AS e
JOIN Employees AS m
	ON e.ManagerID = m.EmployeeID
JOIN Departments AS d 
	ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID

SELECT MIN(m.Average) AS MinAverageSalary
FROM 
(
	SELECT 
		e.DepartmentID,
		AVG(e.Salary) AS Average
	FROM Employees AS e
	GROUP BY e.DepartmentID
) AS m

USE Geography

SELECT
	mc.CountryCode,
	m.MountainRange,
	p.PeakName,
	p.Elevation
FROM Mountains AS m
JOIN MountainsCountries AS mc
	ON mc.MountainId = m.Id
JOIN Peaks AS p
	ON p.MountainId = m.Id
WHERE mc.CountryCode = 'BG' AND p.Elevation > 2835
ORDER BY p.Elevation DESC

SELECT 
	mc.CountryCode,
	COUNT(m.MountainRange)
FROM MountainsCountries mc
JOIN Mountains AS m
	ON mc.MountainId = m.Id
WHERE mc.CountryCode IN ('BG', 'RU', 'US')
GROUP BY mc.CountryCode

SELECT TOP 5
	c.CountryName,
	r.RiverName
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr
	ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r
	ON cr.RiverId = r.Id
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName


SELECT 
	COUNT(C.CountryCode) AS [Count]
FROM Countries AS c
LEFT JOIN MountainsCountries AS mc
	ON c.CountryCode = mc.CountryCode
WHERE mc.MountainId IS NULL

SELECT TOP 5
	c.CountryName,
	MAX(p.Elevation) AS HighestPeakElevation,
	MAX(r.[Length]) AS LongestRiverLength
FROM Countries AS c
JOIN MountainsCountries AS mc
	ON c.CountryCode = mc.CountryCode
JOIN Peaks AS p
	ON p.MountainId = mc.MountainId
JOIN CountriesRivers AS cr
	ON cr.CountryCode = c.CountryCode
JOIN Rivers AS r
	ON cr.RiverId = r.Id
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC,
	LongestRiverLength DESC,
	c.CountryName