--CREATE DATABASE Airport

USE Airport

CREATE TABLE Passengers(
	Id INT PRIMARY KEY IDENTITY,
	FullName VARCHAR(100) NOT NULL UNIQUE,
	Email VARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE Pilots(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL UNIQUE,
	LastName VARCHAR(30) NOT NULL UNIQUE,
	Age TINYINT NOT NULL CHECK (Age >= 21 AND Age <= 62),
    Rating FLOAT CHECK(Rating >= 0.0 AND Rating <= 10.0)--DECIMAL(3, 1)
)

CREATE TABLE AircraftTypes(
	Id INT PRIMARY KEY IDENTITY,
	TypeName VARCHAR(30) NOT NULL UNIQUE
)

CREATE TABLE Aircraft(
	Id INT PRIMARY KEY IDENTITY,
	Manufacturer VARCHAR(25) NOT NULL,
	Model VARCHAR(30) NOT NULL,
	[Year] INT NOT NULL,
	FlightHours INT,
	Condition CHAR(1) NOT NULL,
	TypeId INT NOT NULL,
	FOREIGN KEY (TypeId) REFERENCES AircraftTypes
)

CREATE TABLE PilotsAircraft(
	AircraftId INT NOT NULL FOREIGN KEY REFERENCES Aircraft,
	PilotId INT NOT NULL FOREIGN KEY REFERENCES Pilots,
	PRIMARY KEY(AircraftId, PilotId)
)

CREATE TABLE Airports(
	Id INT PRIMARY KEY IDENTITY,
	AirportName VARCHAR(70) NOT NULL UNIQUE,
	Country VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE FlightDestinations(
	Id INT PRIMARY KEY IDENTITY,
	AirportId INT NOT NULL
		FOREIGN KEY REFERENCES Airports,
	[Start] DATETIME NOT NULL,
	AircraftId INT NOT NULL
		FOREIGN KEY REFERENCES Aircraft,
	PassengerId INT NOT NULL
		FOREIGN KEY REFERENCES Passengers,
	TicketPrice DECIMAL(18, 2) DEFAULT 15 NOT NULL
)

--DONT EXECUTE
--INSERT
INSERT INTO Passengers
	SELECT 
		FirstName + ' ' + LastName,
		FirstName + LastName + '@gmail.com'
	FROM Pilots
	WHERE Id >= 5 AND Id <= 15

--UPDATE
UPDATE Aircraft
SET Condition = 'A'
WHERE Condition IN ('C', 'B') 
	AND (FlightHours IS NULL OR FlightHours <= 100)
	AND [Year] >= 2013

--DELETE
DELETE FROM FlightDestinations
WHERE PassengerId IN
	(SELECT Id FROM Passengers WHERE LEN(FullName) <= 10)

DELETE FROM Passengers 
WHERE LEN(FullName) <= 10

--Querying 
SELECT
	Manufacturer,
	Model,
	FlightHours,
	Condition
FROM Aircraft
ORDER BY FlightHours DESC

SELECT
	p.FirstName,
	p.LastName,
	a.Manufacturer,
	a.Model,
	a.FlightHours
FROM Pilots AS p
JOIN PilotsAircraft AS pa
	ON p.Id = pa.PilotId
JOIN Aircraft AS a
	ON a.Id = pa.AircraftId
WHERE a.FlightHours < 304 
	AND a.FlightHours IS NOT NULL
ORDER BY a.FlightHours DESC, p.FirstName

SELECT TOP 20
	fd.Id AS DestinationId,
	fd.[Start],
	p.FullName,
	a.AirportName,
	fd.TicketPrice
FROM FlightDestinations AS fd
JOIN Passengers AS p
	ON fd.PassengerId = p.Id
JOIN Airports AS a
	ON fd.AirportId = a.Id
WHERE DATEPART(dd, [Start]) % 2 = 0
ORDER BY fd.TicketPrice DESC, a.AirportName

SELECT
	fd.AircraftId,
	a.Manufacturer, 
	a.FlightHours,
	COUNT(fd.AircraftId) AS FlightDestinationsCount,
	ROUND(AVG(fd.TicketPrice), 2) AS AvgPrice
FROM Aircraft AS a
JOIN FlightDestinations AS fd
	ON fd.AircraftId = a.Id
GROUP BY fd.AircraftId, a.Manufacturer, a.FlightHours
HAVING COUNT(fd.AircraftId) >= 2
ORDER BY FlightDestinationsCount DESC, fd.AircraftId

SELECT
	p.FullName,
	COUNT(fd.AircraftId) AS CountOfAircraft,
	SUM(fd.TicketPrice) AS TotalPayed
FROM Passengers AS p
JOIN FlightDestinations AS fd
	ON fd.PassengerId = p.Id
WHERE p.FullName LIKE '[A-Z]a%'
GROUP BY p.FullName
HAVING COUNT(fd.AircraftId) > 1  
ORDER BY p.FullName

SELECT 
	ap.AirportName,
	fd.[Start] AS DayTime,
	fd.TicketPrice,
	p.FullName,
	ac.Manufacturer,
	ac.Model
FROM FlightDestinations AS fd
JOIN Airports AS ap
	ON ap.Id = fd.AirportId
JOIN Passengers AS p
	ON p.Id = fd.PassengerId
JOIN Aircraft AS ac
	ON ac.Id = fd.AircraftId
WHERE DATEPART(HH, fd.[Start]) BETWEEN 6 AND 20
	AND fd.TicketPrice > 2500
ORDER BY ac.Model

GO

--Programmability 
CREATE FUNCTION udf_FlightDestinationsByEmail
				(@email VARCHAR(50)) 
RETURNS INT
AS
BEGIN
	DECLARE @passId INT = (SELECT Id FROM Passengers WHERE Email = @email)
	RETURN (SELECT COUNT(*) FROM FlightDestinations WHERE PassengerId = @passId)
END

GO

CREATE PROC usp_SearchByAirportName
			@airportName VARCHAR(70)
AS
BEGIN
	SELECT 
		a.AirportName,
		p.FullName,
			CASE 
				WHEN fd.TicketPrice <= 400 THEN 'Low'
				WHEN fd.TicketPrice BETWEEN 401 AND 1500 THEN 'Medium' 
				WHEN fd.TicketPrice >= 1501 THEN 'High' 
					END AS LevelOfTickerPrice,
		ac.Manufacturer,
		ac.Condition,
		[at].TypeName
	FROM Airports AS a
	JOIN FlightDestinations AS fd
		ON fd.AirportId = a.Id
	JOIN Passengers AS p
		ON fd.PassengerId = p.Id
	JOIN Aircraft AS ac
		ON fd.AircraftId = ac.Id
	JOIN AircraftTypes AS [at]
		ON [at].Id = ac.TypeId
	WHERE a.AirportName = @airportName
	ORDER BY ac.Manufacturer, p.FullName
END