CREATE DATABASE Zoo

--1
CREATE TABLE Owners(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
PhoneNumber VARCHAR(15) NOT NULL,
[Address] VARCHAR(50))

CREATE TABLE AnimalTypes(
Id INT PRIMARY KEY IDENTITY,
AnimalType VARCHAR(30) NOT NULL)

CREATE TABLE Cages(
Id INT PRIMARY KEY IDENTITY,
AnimalTypeId INT NOT NULL,
FOREIGN KEY (AnimalTypeId) REFERENCES AnimalTypes)

CREATE TABLE Animals(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL,
BirthDate DATE NOT NULL,
OwnerId INT,
AnimalTypeId INT NOT NULL,
FOREIGN KEY (OwnerId) REFERENCES Owners,
FOREIGN KEY (AnimalTypeId) REFERENCES AnimalTypes)

CREATE TABLE AnimalsCages(
CageId INT NOT NULL FOREIGN KEY REFERENCES Cages,
AnimalId INT NOT NULL FOREIGN KEY REFERENCES Animals,
PRIMARY KEY (CageId, AnimalId))

CREATE TABLE VolunteersDepartments(
Id INT PRIMARY KEY IDENTITY,
DepartmentName VARCHAR(30) NOT NULL)

CREATE TABLE Volunteers(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
PhoneNumber VARCHAR(15) NOT NULL,
[Address] VARCHAR(50),
 AnimalId INT,
 DepartmentId INT NOT NULL,
 FOREIGN KEY (AnimalId) REFERENCES Animals,
 FOREIGN KEY (DepartmentId) REFERENCES VolunteersDepartments)

 --5
 SELECT 
	[Name],
	PhoneNumber,
	[Address],
	AnimalId,
	DepartmentId
FROM Volunteers
ORDER BY [Name], AnimalId, DepartmentId

--6
SELECT
	a.[Name],
	[at].AnimalType,
	FORMAT([a].BirthDate, 'dd.MM.yyyy')
FROM Animals AS a
JOIN AnimalTypes AS [at]
	ON a.AnimalTypeId = at.Id
ORDER BY a.[Name]

--7
SELECT TOP 5
	o.[Name],
	COUNT(a.Id) AS CountOfAnimals
FROM Animals AS a
JOIN Owners AS o
	ON a.OwnerId = o.Id
GROUP BY o.[Name]
ORDER BY CountOfAnimals DESC, o.[Name]

--8
DECLARE @mammalId INT = (SELECT Id FROM AnimalTypes WHERE AnimalType = 'Mammals')

SELECT
	CONCAT(o.[Name], '-', a.[Name]),
	o.PhoneNumber,
	ac.CageId
FROM Owners AS o
JOIN Animals AS a
	ON o.Id = a.OwnerId
JOIN AnimalsCages AS ac
	ON ac.AnimalId = a.Id
WHERE AnimalTypeId = @mammalId
ORDER BY o.[Name], a.[Name] DESC

--9
DECLARE @depId INT = (SELECT Id FROM VolunteersDepartments WHERE DepartmentName = 'Education program assistant') 

SELECT
	[Name],
	PhoneNumber,
	SUBSTRING([Address], CHARINDEX(',', [Address]) + 2, LEN([Address]) - CHARINDEX(',', Address))
FROM Volunteers
WHERE DepartmentId = @depId AND [Address] LIKE '%Sofia%'
ORDER BY [Name] 

--10
SELECT
	a.[Name],
	DATEPART(yyyy, a.BirthDate) AS BirthYear,
	[at].AnimalType
FROM Animals AS a
JOIN AnimalTypes AS [at]
	ON [at].Id = a.AnimalTypeId
WHERE 
	a.OwnerId IS NULL AND
	a.BirthDate > '2018-01-01' AND
	[at].AnimalType <> 'Birds'
ORDER BY a.[Name]

GO

--11
CREATE FUNCTION udf_GetVolunteersCountFromADepartment 
				(@volunteersDepartment VARCHAR(30))
RETURNs INT
AS
BEGIN
	DECLARE @id INT = (SELECT Id FROM VolunteersDepartments WHERE DepartmentName = @volunteersDepartment)
		DECLARE @count INT = (SELECT COUNT(Id) FROM Volunteers WHERE DepartmentId = @id)
	RETURN @count
END

GO

--12
CREATE PROC usp_AnimalsWithOwnersOrNot
			@animalName VARCHAR(50)
AS
BEGIN
	SELECT 
		a.[Name],
		CASE 
			WHEN a.OwnerId IS NULL THEN 'For adoption'
				ELSE o.[Name] END AS OwnersName --IIF(o.Name IS NULL, 'For adoption', o.Name) AS OwnersName
	FROM Animals AS a
	LEFT JOIN Owners AS o
		ON a.OwnerId = o.Id
	WHERE a.[Name] = @animalName
END