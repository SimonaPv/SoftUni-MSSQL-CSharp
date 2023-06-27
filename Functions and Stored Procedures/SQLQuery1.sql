CREATE PROC usp_GetEmployeesSalaryAbove35000 
AS
BEGIN
	SELECT 
		FirstName, 
		LastName 
	FROM Employees
	WHERE Salary > 35000
END

EXEC dbo.usp_GetEmployeesSalaryAbove35000 

GO

CREATE PROC usp_GetEmployeesSalaryAboveNumber 
			@number DECIMAL(18, 4)
AS
BEGIN
	SELECT 
		FirstName, 
		LastName 
	FROM Employees
	WHERE Salary >= @number
END

EXEC dbo.usp_GetEmployeesSalaryAboveNumber 48100

GO

CREATE PROC usp_GetTownsStartingWith 
			@string VARCHAR(20)
AS
BEGIN
	SELECT 
		[Name] AS Town
	FROM Towns
	WHERE [Name] LIKE @string + '%'
END

EXEC dbo.usp_GetTownsStartingWith 'b'

GO

CREATE PROC usp_GetEmployeesFromTown 
			@townName VARCHAR(50)
AS
BEGIN
	SELECT 
		e.FirstName,
		e.LastName
	FROM Employees AS e
	JOIN Addresses AS a
		ON e.AddressID = a.AddressID
	JOIN Towns AS t
		ON a.TownID = t.TownID
	WHERE t.Name = @townName
END

EXEC dbo.usp_GetEmployeesFromTown 'Sofia'

GO

CREATE FUNCTION ufn_GetSalaryLevel
				(@salary DECIMAL(18, 4))
RETURNS VARCHAR(10)
AS
BEGIN
	RETURN CASE 
		   WHEN @salary < 30000 THEN 'Low'
		   WHEN @salary <= 50000 THEN 'Average'
		   ELSE 'High'
		   END
END

GO

CREATE PROC usp_EmployeesBySalaryLevel 
			@level VARCHAR(10)
AS
BEGIN
	SELECT
		FirstName,
		LastName
	FROM Employees AS e
	WHERE @level = dbo.ufn_GetSalaryLevel(e.Salary)
END

EXEC dbo.usp_EmployeesBySalaryLevel 'High'

GO

CREATE FUNCTION ufn_IsWordComprised
				(@setOfLetters VARCHAR(40),
				 @word VARCHAR(40))
RETURNS BIT
AS
BEGIN
	DECLARE @currIndex INT = 1
	WHILE(@currIndex <= LEN(@word))
		BEGIN
			DECLARE @currChar CHAR = SUBSTRING(@word, @currIndex, 1)
			IF(CHARINDEX(@currChar, @setOfLetters) = 0)
				BEGIN
					RETURN 0;
				END
			SET @currIndex += 1;
		END
	RETURN 1
END

GO

SELECT dbo.ufn_IsWordComprised('oistmiahf', 'Sofia')

GO

USE BANK

GO

CREATE PROC usp_GetHoldersFullName 
AS
BEGIN
	SELECT
		CONCAT_WS(' ', FirstName, LastName)
	FROM AccountHolders
END

EXEC dbo.usp_GetHoldersFullName

GO

CREATE PROC usp_GetHoldersWithBalanceHigherThan 
			@money DECIMAL(18, 4)
AS
BEGIN
	SELECT
		ah.FirstName,
		ah.LastName
	FROM AccountHolders AS ah
	JOIN Accounts AS a
		ON ah.Id = a.AccountHolderId
	GROUP BY ah.FirstName, ah.LastName
	HAVING SUM(a.Balance) > @money
	ORDER BY FirstName, LastName
END

GO

CREATE FUNCTION ufn_CalculateFutureValue 
				(@sum DECIMAL(18, 4),
				 @yearRate FLOAT,
				 @years INT)
RETURNS DECIMAL(18, 4)
AS
BEGIN
	RETURN @sum * POWER(1 + @yearRate, @years)
END

GO

CREATE PROC usp_CalculateFutureValueForAccount 
			@accountId INT,
			@yearRate FLOAT
AS
BEGIN
	SELECT
		a.Id AS [Account Id],
		ah.FirstName AS [First Name],
		ah.LastName AS [Last Name],
		a.Balance AS [Current Balance],
		dbo.ufn_CalculateFutureValue(a.Balance, @yearRate, 5) AS [Balance in 5 years]
	FROM AccountHolders AS ah
	JOIN Accounts AS a
		ON a.AccountHolderId = ah.Id
	WHERE a.Id = @accountId
END