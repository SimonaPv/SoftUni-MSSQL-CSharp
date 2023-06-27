-- Create Database
CREATE DATABASE Minions;

-- Create Table
CREATE TABLE Minions(
Id INT PRIMARY KEY,
[Name] NVARCHAR(50) NOT NULL,
Age INT NOT NULL
);

-- Create Table
CREATE TABLE Towns(
Id INT PRIMARY KEY,
[Name] NVARCHAR(70) NOT NULL,
);

-- Alter Minions Table
ALTER TABLE Minions
ADD TownId INT NOT NULL
FOREIGN KEY (TownId) REFERENCES Towns (Id)

-- Insert Records in Both Tables
ALTER TABLE Minions
ALTER COLUMN Age INT

INSERT INTO Towns
VALUES (1, 'Sofia'),
		(2, 'Plovdiv'),
		(3, 'Varna')

INSERT INTO Minions
VALUES (1, 'Kevin', 22, 1),
		(2, 'Bob', 15, 3),
		(3, 'Steward', NULL, 2)

-- Truncate Table Minionñ
Truncate Table Minions

-- Drop All Tables
DROP TABLE Minions
DROP TABLE Towns

-- Create Table People
CREATE TABLE People
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(200) NOT NULL,
	[Picture] IMAGE,
	[Height] DECIMAL(3, 2),
	[Weight] DECIMAL(4, 2),
	[Gender] CHAR(1) NOT NULL,
	[Birthdate] DATE NOT NULL,
	[Biography] NVARCHAR(MAX),
)

INSERT INTO People VALUES
	('John', NULL, 1.80, 72.00, 'm', '2001-12-01', 'John bio'),
	('Jane', NULL, 1.71, 58.00, 'f', '2002-11-15', 'Jane bio'),
	('Jim', NULL, 1.68, 95.00, 'm', '1998-02-02', 'Jim bio'),
	('Jenna', NULL, 1.64, 49.00, 'f', '2004-06-09', 'Jenna bio'),
	('Jack', NULL, 1.83, 80.00, 'm', '1985-09-24', 'Jack bio')

-- Create Table Users
CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	[Password] VARCHAR(26) NOT NULL,
	ProfilePicture IMAGE,
	LastLoginTime DATETIME,
	IsDeleted BIT
)

INSERT INTO Users VALUES
	('Username 1', 'Password 1', NULL, NULL, 0),
	('Username 2', 'Password 2', NULL, NULL, 0),
	('Username 3', 'Password 3', NULL, NULL, 0),
	('Username 4', 'Password 4', NULL, NULL, 1),
	('Username 5', 'Password 5', NULL, NULL, 1)

-- Change Primary Key
ALTER TABLE Users
DROP CONSTRAINT PK_Users 

ALTER TABLE Users
ADD CONSTRAINT PK_Users 
PRIMARY KEY (Id, Username)

-- Add Check Constraint
ALTER TABLE Users
ADD CONSTRAINT check_password 
CHECK (LEN(Password) >= 5)

-- Set Default Value of a Field
ALTER TABLE Users
ADD CONSTRAINT lastLoginTime
DEFAULT GETDATE() FOR LastLoginTime

-- Set Unique Field
ALTER TABLE Users
DROP PK__Users__3214EC0782CA3FE3

ALTER TABLE Users
ADD CONSTRAINT PK__Users PRIMARY KEY (Id) ;

ALTER TABLE Users
ADD CONSTRAINT CHK_Usernames CHECK (LEN(Username) >= 3)

-- Movies Database
CREATE DATABASE Movies

CREATE TABLE Directors
(
	Id INT PRIMARY KEY IDENTITY,
	DirectorName VARCHAR(50) NOT NULL,
	Notes NVARCHAR(1000)
)

CREATE TABLE Genres
(
	Id INT PRIMARY KEY IDENTITY,
	GenreName VARCHAR(50) NOT NULL,
	Notes NVARCHAR(1000)
)

CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY,
	CategoryName VARCHAR(50) NOT NULL,
	Notes NVARCHAR(1000)
)

CREATE TABLE Movies
(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(50) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id) NOT NULL,
	CopyrightYear INT NOT NULL,
	Length TIME NOT NULL,
	GenreId INT FOREIGN KEY REFERENCES Genres(Id) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	Rating DECIMAL(2, 1) NOT NULL,
	Notes NVARCHAR(1000)
)

INSERT INTO Directors 
VALUES ('Stanley Kubrick', NULL),
		('Alfred Hitchcock', NULL),
		('Quentin Tarantino', NULL),
		('Steven Spielberg', NULL),
		('Martin Scorsese', NULL)

INSERT INTO Genres 
VALUES ('Action', NULL),
		('Comedy', NULL),
		('Drama', NULL),
		('Fantasy', NULL),
		('Horror', NULL)

INSERT INTO Categories 
VALUES ('Short', NULL),
		('Long', NULL),
		('Biography', NULL),
		('Documentary', NULL),
		('TV', NULL)

INSERT INTO Movies 
VALUES ('The Shawshank Redemption', 1, 1994, '02:22:00', 2, 3, 9.4, NULL),
		('The Godfather', 2, 1972, '02:55:00', 3, 4, 9.2, NULL),
		('Schindler`s List', 3, 1993, '03:15:00', 4, 5, 9.0, NULL),
		('Pulp Fiction', 4, 1994, '02:34:00', 5, 1, 8.9, NULL),
		('Fight Club', 5, 1999, '02:19:00', 1, 2, 8.8, NULL)