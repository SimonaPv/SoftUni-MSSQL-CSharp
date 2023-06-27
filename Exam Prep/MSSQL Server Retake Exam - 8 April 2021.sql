--CREATE DATABASE [Service]

USE [Service]

CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL UNIQUE,
	[Password] VARCHAR(50) NOT NULL,
	[Name] VARCHAR(50),
	Birthdate DATETIME,
	Age INT CHECK(Age BETWEEN 14 AND 110),
	Email VARCHAR(50) NOT NULL
)

CREATE TABLE Departments(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(25),
	LastName VARCHAR(25),
	Birthdate DATETIME,
	Age INT CHECK(Age BETWEEN 18 AND 110),
	DepartmentId INT FOREIGN KEY REFERENCES Departments
)

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments
)

CREATE TABLE [Status](
	Id INT PRIMARY KEY IDENTITY,
	[Label] VARCHAR(20) NOT NULL
)

CREATE TABLE Reports(
	Id INT PRIMARY KEY IDENTITY,
	CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories,
	StatusId  INT NOT NULL FOREIGN KEY REFERENCES [Status],
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME, 
	[Description] VARCHAR(200) NOT NULL,
	UserId INT NOT NULL FOREIGN KEY REFERENCES Users,
	EmployeeId INT FOREIGN KEY REFERENCES Employees
)

INSERT INTO Employees (FirstName,	LastName,	Birthdate,	DepartmentId)
VALUES (   'Marlo',	 'O''Malley',  '1958-9-21',	 1),
		(    'Niki',	 'Stanaghan',  '1969-11-26', 4),
		(  'Ayrton',    	 'Senna',  '1960-03-21', 9),
		(  'Ronnie',	  'Peterson',  '1944-02-14', 9),
		('Giovanna',         'Amati',  '1959-07-20', 5)

INSERT INTO Reports 
VALUES ( 1, 1,	'2017-04-13',         NULL,	        'Stuck Road on Str.133', 6,	2),
		( 6, 3,	'2015-09-05', '2015-12-06',	        'Charity trail running', 3,	5),
		(14, 2,	'2015-09-07',         NULL,	     'Falling bricks on Str.58', 5,	2),
		( 4, 3,	'2017-07-03', '2017-07-06',	'Cut off streetlight on Str.11', 1,	1)

UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL

DELETE FROM Reports
WHERE StatusId IN (SELECT Id FROM [Status] WHERE [Label] = 'Status 4')

DELETE FROM [Status] 
WHERE [Label] = 'Status 4'

SELECT
	[Description],
	FORMAT(OpenDate, 'dd-MM-yyyy')
FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, [Description]

SELECT
	r.[Description],
	c.[Name] AS CategoryName
FROM Reports AS r
JOIN Categories AS c
	ON r.CategoryId = c.Id
ORDER BY r.[Description], c.[Name]

SELECT TOP 5
	c.[Name] AS CategoryName,
	COUNT(r.Id) AS ReportsNumber
FROM Reports AS r
JOIN Categories AS c
	ON r.CategoryId = c.Id
GROUP BY c.[Name]
ORDER BY ReportsNumber DESC, c.[Name]

SELECT
	u.Username AS Username,
	c.[Name] AS CategoryName
FROM Users AS u
JOIN Reports AS r
	ON u.Id = r.UserId
JOIN Categories AS c
	ON c.Id = r.CategoryId
WHERE DATEPART(dd, r.OpenDate) = DATEPART(dd, u.Birthdate) AND DATEPART(MM, r.OpenDate) = DATEPART(MM, u.Birthdate)
ORDER BY Username, CategoryName

SELECT 
	CONCAT_WS(' ', e.FirstName, e.LastName) AS FullName,
	COUNT(r.UserId) AS UsersCount
FROM Employees AS e
LEFT JOIN Reports AS r 
	ON e.Id = r.EmployeeId
GROUP BY e.FirstName, e.LastName
ORDER BY UsersCount DESC, FullName ASC

SELECT    
    IIF(e.FirstName IS NULL AND e.LastName IS NULL, 'None', e.FirstName + ' ' + e.LastName) AS Employee,
    IIF(d.Name IS NULL, 'None', d.Name) AS Department,
    c.Name AS Category,
    r.Description AS Description,
    FORMAT(r.OpenDate, 'dd.MM.yyyy') AS OpenDate,
    s.Label AS Status,
    u.Name AS [User]
FROM Reports AS r
LEFT JOIN Employees AS e 
	ON r.EmployeeId = e.Id
LEFT JOIN Departments AS d 
	ON e.DepartmentId = d.Id
LEFT JOIN Categories AS c 
	ON r.CategoryId = c.Id
LEFT JOIN Status AS s 
	ON r.StatusId = s.Id
LEFT JOIN Users AS u 
	ON r.UserId = u.Id
ORDER BY e.FirstName DESC, e.LastName DESC, Department, Category, Description, OpenDate, Status, User

GO

CREATE FUNCTION udf_HoursToComplete
				(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
BEGIN
	IF (@StartDate IS NULL OR @EndDate IS NULL) RETURN 0
RETURN DATEDIFF(HOUR, @StartDate, @EndDate)
END

GO

CREATE PROC usp_AssignEmployeeToReport
(@EmployeeId INT, @ReportId INT)
AS
BEGIN
DECLARE @departmentIdEmployee INT = 
(
    SELECT DepartmentId 
    FROM Employees 
    WHERE Id = @EmployeeId
)
DECLARE @departmentIdReport INT = 
(
    SELECT c.DepartmentId 
    FROM Reports AS r 
    JOIN Categories AS c ON r.CategoryId = c.Id
    WHERE r.Id = @ReportId
)
IF @departmentIdEmployee <> @departmentIdReport 
    THROW 50001, 'Employee doesn''t belong to the appropriate department!', 1
ELSE 
    UPDATE Reports 
    SET EmployeeId = @EmployeeId 
    WHERE Id = @ReportId
END