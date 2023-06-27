--CREATE DATABASE Boardgames 

USE Boardgames 

CREATE TABLE Categories(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
)

CREATE TABLE Addresses(
	Id INT PRIMARY KEY IDENTITY,
	StreetName NVARCHAR(100) NOT NULL,
	StreetNumber INT NOT NULL,
	Town VARCHAR(30) NOT NULL,
	Country VARCHAR(50) NOT NULL,
	ZIP INT NOT NULL
)

CREATE TABLE Publishers(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL UNIQUE,
	AddressId INT NOT NULL FOREIGN KEY REFERENCES Addresses,
	Website NVARCHAR(40),
	Phone NVARCHAR(20)
)

CREATE TABLE PlayersRanges(
	Id INT PRIMARY KEY IDENTITY,
	PlayersMin INT NOT NULL,
	PlayersMax INT NOT NULL
)

CREATE TABLE Boardgames(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	YearPublished INT NOT NULL,
	Rating DECIMAL(18, 2) NOT NULL,
	CategoryId INT NOT NULL FOREIGN KEY REFERENCES Categories,
	PublisherId INT NOT NULL FOREIGN KEY REFERENCES Publishers,
	PlayersRangeId INT NOT NULL FOREIGN KEY REFERENCES PlayersRanges
)

CREATE TABLE Creators(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Email NVARCHAR(30) NOT NULL
)

CREATE TABLE CreatorsBoardgames(
	CreatorId INT NOT NULL FOREIGN KEY REFERENCES Creators,
	BoardgameId INT NOT NULL FOREIGN KEY REFERENCES Boardgames,
	PRIMARY KEY(CreatorId, BoardgameId)
)

INSERT INTO Boardgames
VALUES('Deep Blue',	2019	,5.67,	1	,15,	7),
		('Paris',	2016	,9.78,	7,	1	,5),
		('Catan: Starfarers',	2021,	9.87,	7,	13,	6),
		('Bleeding Kansas',	2020	,3.25	,3	,7	,4),
		('One Small Step',	2019	,5.75	,5	,9	,2)

INSERT INTO Publishers
VALUES ('Agman Games',	5,	'www.agmangames.com',	'+16546135542'),
		('Amethyst Games',	7,	'www.amethystgames.com',	'+15558889992'),
		('BattleBooks',	13,	'www.battlebooks.com',	'+12345678907')


UPDATE PlayersRanges 
SET PlayersMax = PlayersMax + 1
WHERE PlayersMin = 2 AND PlayersMax = 2

UPDATE Boardgames
SET [Name] = CONCAT([Name], 'V2')
WHERE YearPublished >= 2020

DELETE FROM CreatorsBoardgames   
WHERE BoardgameId IN (SELECT Id 
					  FROM Boardgames 
					  WHERE PublisherId IN 
					  (SELECT Id 
					   FROM Publishers                                                
					   WHERE AddressId IN (SELECT Id FROM Addresses WHERE TOWN LIKE 'L%')))

DELETE FROM Boardgames 
WHERE PublisherId IN (SELECT Id 
					  FROM Publishers 
				      WHERE AddressId IN (SELECT Id FROM Addresses WHERE Town LIKE 'L%'))

DELETE FROM Publishers 
WHERE AddressId IN (SELECT Id
					FROM Addresses                       
					WHERE Town LIKE 'L%')

DELETE FROM Addresses   
WHERE Town LIKE 'L%'

SELECT
	[Name],
	Rating
FROM Boardgames 
ORDER BY YearPublished, [Name] DESC

SELECT
	b.Id,
	b.Name,
	b.YearPublished,
	c.Name AS CategoryName
FROM Boardgames AS b
JOIN Categories AS c
	ON c.Id = b.CategoryId
WHERE c.Name IN ('Strategy Games', 'Wargames')
ORDER BY b.YearPublished DESC

SELECT
	c.Id,
	CONCAT_WS(' ', c.FirstName, c.LastName) AS CreatorName,
	c.Email
FROM Creators AS c
LEFT JOIN CreatorsBoardgames AS cb
	ON c.Id = cb.CreatorId
LEFT JOIN Boardgames AS b
	ON b.Id = cb.BoardgameId
WHERE b.Id IS NULL
ORDER BY CreatorName


SELECT TOP 5 
	b.Name,
	b.Rating,
	c.Name AS CategoryName
FROM Boardgames AS b
JOIN PlayersRanges AS pr
	ON b.PlayersRangeId = pr.Id
JOIN Categories AS c
	ON b.CategoryId = c.Id
WHERE (b.Rating > 7.00 AND b.Name LIKE '%a%') OR (b.Rating > 7.50 AND pr.PlayersMin = 2 AND pr.PlayersMax = 5)
ORDER BY b.Name, b.Rating DESC

SELECT 
	CONCAT_WS(' ', c.FirstName, c.LastName) AS FullName,
	c.Email,
	MAX(b.Rating)
FROM Creators AS c
JOIN CreatorsBoardgames AS cb
	ON c.Id = cb.CreatorId
JOIN Boardgames AS b
	ON b.Id = cb.BoardgameId
WHERE c.Email LIKE '%.com'
GROUP BY c.FirstName, c.LastName, c.Email
ORDER BY FullName


SELECT
	c.LastName,
	CEILING(AVG(b.Rating)),
	p.Name
FROM Creators AS c
JOIN CreatorsBoardgames AS cb
	ON cb.CreatorId = c.Id
JOIN Boardgames AS b
	ON cb.BoardgameId = b.Id
JOIN Publishers AS p
	ON p.Id = b.PublisherId
WHERE p.Name = 'Stonemaier Games' 
GROUP BY c.LastName, p.Name
ORDER BY AVG(b.Rating) DESC

GO

CREATE FUNCTION udf_CreatorWithBoardgames
				(@name VARCHAR(50)) 
RETURNS INT
AS
BEGIN
	DECLARE @id INT = (SELECT Id FROM Creators WHERE FirstName = @name)
	RETURN (SELECT COUNT(BoardgameId) FROM CreatorsBoardgames WHERE CreatorId = @id)
END

GO

CREATE PROC usp_SearchByCategory 
			@category VARCHAR(50)
AS
BEGIN
	SELECT 
		b.Name,
		b.YearPublished,
		b.Rating,
		c.Name AS 'CategoryName',
		p.Name AS 'PublisherName',
		CONCAT(pr.PlayersMin, ' people'),
		CONCAT(pr.PlayersMax, ' people')
	FROM Boardgames AS b
	JOIN Categories AS c
		ON b.CategoryId = c.Id
	JOIN Publishers AS p
		ON p.Id = b.PublisherId
	JOIN PlayersRanges AS pr
		ON pr.Id = b.PlayersRangeId
	WHERE c.Name = @category
	ORDER BY p.Name, YearPublished DESC
END

EXEC usp_SearchByCategory 'Wargames'