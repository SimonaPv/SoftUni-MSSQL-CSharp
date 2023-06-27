--CREATE DATABASE Bitbucket

USE Bitbucket

CREATE TABLE Users(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(30) NOT NULL,
	Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors(
	RepositoryId INT NOT NULL FOREIGN KEY REFERENCES Repositories,
	ContributorId INT NOT NULL FOREIGN KEY REFERENCES Users,
	PRIMARY KEY(RepositoryId, ContributorId)
)

CREATE TABLE Issues(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(255) NOT NULL,
	IssueStatus VARCHAR(6) NOT NULL,
	RepositoryId INT NOT NULL FOREIGN KEY REFERENCES Repositories,
	AssigneeId INT NOT NULL FOREIGN KEY REFERENCES Users
)

CREATE TABLE Commits(
	Id INT PRIMARY KEY IDENTITY,
	[Message] VARCHAR(255) NOT NULL,
	IssueId INT FOREIGN KEY REFERENCES Issues,
	RepositoryId INT NOT NULL FOREIGN KEY REFERENCES Repositories,
	ContributorId INT NOT NULL FOREIGN KEY REFERENCES Users
)

CREATE TABLE Files(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	Size DECIMAL(18, 2) NOT NULL,
	ParentId INT FOREIGN KEY REFERENCES Files,
	CommitId INT NOT NULL FOREIGN KEY REFERENCES Commits
)

INSERT INTO Files
VALUES ('Trade.idk',	2598.0,	1,	1),
		('menu.net',	9238.31,	2,	2),
		('Administrate.soshy', 	1246.93,	3,	3),
		('Controller.php',	7353.15,	4,	4),
		('Find.java',	9957.86,	5,	5),
		('Controller.json',	14034.87,	3,	6),
		('Operate.xix',	7662.92,	7	,7)

INSERT INTO Issues
VALUES ('Critical Problem with HomeController.cs file',	'open',	1,	4),
		('Typo fix in Judge.html',	'open',	4,	3),
		('Implement documentation for UsersService.cs',	'closed',	8,	2),
		('Unreachable code in Index.cs',	'open',	9,	8)

UPDATE Issues
SET IssueStatus = 'Closed'
WHERE AssigneeId = 6

SELECT Id FROM Repositories WHERE Name = 'Softuni-Teamwork'

DELETE FROM RepositoriesContributors
WHERE RepositoryId = 3

DELETE FROM Issues
WHERE RepositoryId = 3

SELECT
	Id, 
	[Message], 
	RepositoryId, 
	ContributorId
FROM Commits
ORDER BY Id, [Message], RepositoryId, ContributorId

SELECT 
	Id,
	[Name],
	[Size]
FROM Files
WHERE [Size] > 1000 AND [Name] LIKE '%html%'
ORDER BY [Size] DESC, Id, [Name]

SELECT
	i.Id,
	CONCAT_WS(' : ', u.Username, i.Title) AS IssueAssignee
FROM Issues AS i
JOIN Users AS u
	ON i.AssigneeId = u.Id
ORDER BY i.Id DESC, IssueAssignee 

SELECT
	f1.Id,
	f1.[Name],
	CONCAT(f1.Size, 'KB')
FROM Files AS f1
LEFT JOIN Files AS f2
	ON f1.Id = f2.ParentId
WHERE f2.ParentId IS NULL
ORDER BY f1.Id, f1.[Name], f1.Size DESC

SELECT TOP 5
	r.Id,
	r.[Name],
	COUNT(c.Id) AS Commits
FROM Commits AS c
JOIN Repositories AS r
	ON c.RepositoryId = r.Id
JOIN RepositoriesContributors AS rc 
	ON rc.RepositoryId = r.Id
GROUP BY r.Id, r.[Name]
ORDER BY Commits DESC, r.Id, r.[Name]

SELECT
	u.Username,
	AVG(f.Size) AS Size
FROM Users AS u
JOIN Commits AS c
	ON u.Id = c.ContributorId
JOIN Files AS f
	ON
	f.CommitId = c.Id
GROUP BY u.Username
ORDER BY Size DESC, u.Username

GO

CREATE FUNCTION udf_AllUserCommits
				(@username VARCHAR(40))
RETURNS INT
AS
BEGIN
	DECLARE @id INT = (SELECT Id FROM Users WHERE Username = @username)
	RETURN (SELECT COUNT(*) FROM Commits WHERE ContributorId = @id)
END

GO

CREATE PROC usp_SearchForFiles 
			@fileExtension VARCHAR(30)
AS
BEGIN
	SELECT
		Id,	
		[Name],	
		CONCAT(Size, 'KB')
	FROM Files
	WHERE [Name] LIKE '%' + @fileExtension
	ORDER BY Id, [Name], Size DESC
END

EXEC usp_SearchForFiles 'txt'