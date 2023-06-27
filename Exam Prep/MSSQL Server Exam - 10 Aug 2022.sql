--CREATE DATABASE NationalTouristSitesOfBulgaria

USE NationalTouristSitesOfBulgaria

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Locations(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Municipality VARCHAR(50),
	Province VARCHAR(50) 
)

CREATE TABLE Sites(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	LocationId INT NOT NULL,
	CategoryId INT NOT NULL,
	Establishment VARCHAR(15),
	FOREIGN KEY (LocationId) REFERENCES Locations,
	FOREIGN KEY (CategoryId) REFERENCES Categories
)

CREATE TABLE Tourists(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	Age INT NOT NULL CHECK(Age BETWEEN 0 AND 120),
	PhoneNumber VARCHAR(20) NOT NULL,
	Nationality VARCHAR(30) NOT NULL,
	Reward VARCHAR(20)
)

CREATE TABLE SitesTourists(
	TouristId INT NOT NULL FOREIGN KEY REFERENCES Tourists,
	SiteId INT NOT NULL FOREIGN KEY REFERENCES Sites,
	PRIMARY KEY(TouristId, SiteId)
)

CREATE TABLE BonusPrizes(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
)

CREATE TABLE TouristsBonusPrizes(
	TouristId INT NOT NULL FOREIGN KEY REFERENCES Tourists,
	BonusPrizeId INT NOT NULL FOREIGN KEY REFERENCES BonusPrizes,
	PRIMARY KEY(TouristId, BonusPrizeId)
)

--DON'T EXECUTE
	--Insert
INSERT INTO Tourists
VALUES ('Borislava Kazakova', 52, '+359896354244', 'Bulgaria', NULL),
		('Peter Bosh', 48, '+447911844141', 'UK', NULL),
		('Martin Smith', 29, '+353863818592', 'Ireland', 'Bronze badge'),
		('Svilen Dobrev', 49, '+359986584786', 'Bulgaria', 'Silver badge'),
		('Kremena Popova',	38,	'+359893298604', 'Bulgaria', NULL)

INSERT INTO Sites
VALUES ('Ustra fortress', 90, 7, 'X'),
		('Karlanovo Pyramids', 65,	7, NULL),
		('The Tomb of Tsar Sevt', 63, 8, 'V BC'),
		('Sinite Kamani Natural Park', 17, 1, NULL),
		('St. Petka of Bulgaria – Rupite',	92,	6,	'1994')


	--Update
UPDATE Sites
SET Establishment = '(not defined)'
WHERE Establishment IS NULL

	--Delete
DELETE FROM TouristsBonusPrizes
WHERE BonusPrizeId = 5

DELETE FROM BonusPrizes
WHERE Id = 5

--Querying 

SELECT
	[Name],
	Age,
	PhoneNumber,
	Nationality
FROM Tourists 
ORDER BY Nationality, Age DESC, [Name]

SELECT 
	s.[Name],
	l.[Name],
	s.Establishment,
	c.[Name]
FROM Sites AS s
JOIN Locations AS l
	ON s.LocationId = l.Id
JOIN Categories AS c
	ON s.CategoryId = c.Id
ORDER BY c.[Name] DESC, l.[Name], s.[Name]

SELECT
	l.Province,
	l.Municipality,
	l.[Name] AS [Location],
	COUNT(s.Id) AS CountOfSites
FROM Sites AS s
JOIN Locations AS l
	ON s.LocationId = l.Id
WHERE Province = 'Sofia'
GROUP BY l.Province,
	l.Municipality,
	l.[Name]
ORDER BY CountOfSites DESC, [Location]


SELECT
	s.[Name] AS [Site],
	l.[Name] AS [Location],
	l.Municipality,
	l.Province,
	s.Establishment
FROM Sites AS s
JOIN Locations AS l
	ON s.LocationId = l.Id
WHERE s.[Name] NOT LIKE '[BMD]%' AND s.Establishment LIKE '% BC'
ORDER BY [Site]

SELECT
	t.[Name],
	t.Age,
	t.PhoneNumber,
	t.Nationality,
	IIF (bp.[Name] IS NULL, '(no bonus prize)', bp.[Name]) AS Reward
	FROM Tourists AS t
LEFT JOIN TouristsBonusPrizes AS tbp
	ON t.Id = tbp.TouristId
LEFT JOIN BonusPrizes AS bp
	ON tbp.BonusPrizeId = bp.Id
ORDER BY t.[Name]

SELECT
	DISTINCT SUBSTRING(t.[Name], CHARINDEX(' ', t.[Name]) + 1, LEN(t.[Name]) - CHARINDEX(' ', t.[Name])) AS LastName,
	t.Nationality,
	t.Age,
	t.PhoneNumber
FROM Tourists AS t
JOIN SitesTourists AS st
	ON st.TouristId = t.Id
JOIN Sites AS s
	ON st.SiteId = s.Id
JOIN Categories AS c
	ON s.CategoryId = c.Id
WHERE c.[Name] = 'History and archaeology'
ORDER BY LastName

GO

--Programmability 

CREATE FUNCTION udf_GetTouristsCountOnATouristSite 
				(@Site VARCHAR(50)) 
RETURNS INT
AS
BEGIN
	DECLARE @id INT = (SELECT Id FROM Sites WHERE @Site = [Name])
	RETURN (SELECT COUNT(*) FROM SitesTourists WHERE SiteId = @id)
END

GO

SELECT dbo.udf_GetTouristsCountOnATouristSite ('Gorge of Erma River')
SELECT dbo.udf_GetTouristsCountOnATouristSite ('Samuil’s Fortress')
SELECT dbo.udf_GetTouristsCountOnATouristSite ('Regional History Museum – Vratsa')

GO



CREATE PROC usp_AnnualRewardLottery 
			@TouristName VARCHAR(50)
AS
BEGIN
	DECLARE @touristId INT = (SELECT Id FROM Tourists WHERE [Name] = @TouristName)
	DECLARE @count INT = (SELECT COUNT(*) FROM SitesTourists WHERE TouristId = @touristId)

	UPDATE Tourists
	SET Reward = CASE
				WHEN @count >= 100 THEN 'Gold badge'
				WHEN @count >= 50 THEN 'Silver badge'
				WHEN @count >= 25 THEN 'Bronze badge' END
	WHERE Id = @touristId

	SELECT [Name], Reward FROM Tourists WHERE Id = @touristId
END

GO

EXEC usp_AnnualRewardLottery 'Stoyan Mitev'
EXEC usp_AnnualRewardLottery 'Teodor Petrov'
EXEC usp_AnnualRewardLottery 'Zac Walsh'
EXEC usp_AnnualRewardLottery 'Brus Brown'