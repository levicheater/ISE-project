USE SBBWorkshopOmgeving
GO

/*==============================================================*/
/* Table: ORGANISATIE                                           */
/*==============================================================*/
DELETE FROM [SBBWorkshopOmgeving].[dbo].[ORGANISATIE]
INSERT INTO	[SBBWorkshopOmgeving].[dbo].[ORGANISATIE] (ORGANISATIENUMMER, ORGANISATIENAAM)
SELECT ROW_NUMBER() OVER (ORDER BY S.[Name]) AS [ORGANISATIENUMMER], S.[Name] AS [ORGANISATIENAAM]
FROM [AdventureWorks2014].[Sales].[Store] S
go
/*
SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[ORGANISATIE]
ORDER BY ORGANISATIENAAM
*/

/*==============================================================*/
/* Table: ADVISEUR                                              */
/*==============================================================*/
DELETE FROM [SBBWorkshopOmgeving].[dbo].[ADVISEUR]
;WITH orgnum AS -- organizationnumber/organisatienummer
(
SELECT TOP 300 ORGANISATIENUMMER, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[ORGANISATIE]
),
fname AS -- firstname/voornaam
(
SELECT TOP 300 FirstName, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer]
),
lname_email AS -- lastname + email/achternaam + email
(
SELECT TOP 300 LastName, CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomemail, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer]
),
phonenum AS -- phonenumber/telefoonnummer
(
SELECT 1 AS id, '0' + CAST(CAST(FLOOR((RAND(CHECKSUM(NEWID()))+6)*100000000) AS INT) AS VARCHAR(9)) AS phonenumber
UNION ALL
SELECT id + 1, '0' + CAST(CAST(FLOOR((RAND(CHECKSUM(NEWID()))+6)*100000000) AS INT) AS VARCHAR(9)) AS phonenumber
FROM phonenum
WHERE id < 300 -- amount of rows/hoeveelheid rijen
)
INSERT INTO	[SBBWorkshopOmgeving].[dbo].[ADVISEUR] (ORGANISATIENUMMER, VOORNAAM, ACHTERNAAM, TELEFOONNUMMER, EMAIL)
SELECT ORGANISATIENUMMER, FirstName, LastName, phonenumber,
email =
CASE
	WHEN randomemail = 0 THEN
	LOWER(left(FirstName,1)+LastName)+'@hotmail.com'
	ELSE 
	LOWER(left(FirstName,1)+LastName)+'@gmail.com'
END
FROM orgnum o, fname f, lname_email le, phonenum p
WHERE o.id = f.id
AND o.id = le.id
AND o.id = p.id
OPTION(MAXRECURSION 0)
go
/*
SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[ADVISEUR]
*/

/*==============================================================*/
/* Table: CONTACTPERSOON                                        */
/*==============================================================*/
DELETE FROM [SBBWorkshopOmgeving].[dbo].[CONTACTPERSOON]
;WITH orgnum AS -- organizationnumber/organisatienummer
(
SELECT TOP 300 ORGANISATIENUMMER, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[ORGANISATIE]
),
fname AS -- firstname/voornaam
(
SELECT TOP 300 FirstName, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer]
),
lname_email AS -- lastname + email/achternaam + email
(
SELECT TOP 300 LastName, CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomemail, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer]
),
phonenum AS -- phonenumber/telefoonnummer
(
SELECT 1 AS id, '0' + CAST(CAST(FLOOR((RAND(CHECKSUM(NEWID()))+6)*100000000) AS INT) AS VARCHAR(9)) AS phonenumber
UNION ALL
SELECT id + 1, '0' + CAST(CAST(FLOOR((RAND(CHECKSUM(NEWID()))+6)*100000000) AS INT) AS VARCHAR(9)) AS phonenumber
FROM phonenum
WHERE id < 300 -- amount of rows/hoeveelheid rijen
)
INSERT INTO	[SBBWorkshopOmgeving].[dbo].[CONTACTPERSOON] (ORGANISATIENUMMER, VOORNAAM, ACHTERNAAM, TELEFOONNUMMER, EMAIL)
SELECT ORGANISATIENUMMER, FirstName, LastName, phonenumber,
email =
CASE
	WHEN randomemail = 0 THEN
	LOWER(left(FirstName,1)+LastName)+'@hotmail.com'
	ELSE 
	LOWER(left(FirstName,1)+LastName)+'@gmail.com'
END
FROM orgnum o, fname f, lname_email le, phonenum p
WHERE o.id = f.id
AND o.id = le.id
AND o.id = p.id
OPTION(MAXRECURSION 0)
go
/*
SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[CONTACTPERSOON]
*/

/*==============================================================*/
/* Table: WORKSHOPLEIDER                                        */
/*==============================================================*/
DELETE FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOPLEIDER]
;WITH fname AS -- firstname/voornaam
(
SELECT TOP 300 FirstName, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer]
),
lname AS -- lastname/achternaam
(
SELECT TOP 300 LastName, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer]
)
INSERT INTO [SBBWorkshopOmgeving].[dbo].[WORKSHOPLEIDER] (VOORNAAM, ACHTERNAAM, TOEVOEGING)
SELECT FirstName, LastName, NULL
FROM fname f, lname l
WHERE f.id = l.id
go
/*
SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOPLEIDER]
*/

/*==============================================================*/
/* Table: BESCHIKBAARHEID                                       */
/*==============================================================*/
DELETE FROM [SBBWorkshopOmgeving].[dbo].[BESCHIKBAARHEID]
INSERT INTO [SBBWorkshopOmgeving].[dbo].[BESCHIKBAARHEID] (WORKSHOPLEIDER_ID, KWARTAAL, JAAR, AANTAL_UUR)
SELECT WORKSHOPLEIDER_ID,
FLOOR(RAND(CHECKSUM(NEWID()))*(10-7+1)+1) AS [quarter], -- quarter/kwartaal
FLOOR(RAND(CHECKSUM(NEWID()))*(10-5+1)+2020) AS [year], -- year/jaar
FLOOR(RAND(CHECKSUM(NEWID()))*(10+20)+30) AS [hours] -- amount of hours/aantal uur
FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOPLEIDER]
go
/*
SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[BESCHIKBAARHEID]
*/

/*==============================================================*/
/* Table: SECTOR                                                */
/*==============================================================*/
DELETE FROM [SBBWorkshopOmgeving].[dbo].[SECTOR]
INSERT INTO [SBBWorkshopOmgeving].[dbo].[SECTOR] (SECTORNAAM)
VALUES	('ICTCI'),
		('MTLM'),
		('SV'),
		('TGO'),
		('VGG'),
		('ZDV'),
		('ZWS'),
		('Handel')
go
/*
SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[SECTOR]
*/

/*==============================================================*/
/* Table: DEELNEMER                                             */
/*==============================================================*/
DELETE FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER]
;WITH orgnum AS -- organizationnumber/organisatienummer
(
SELECT TOP 250 ORGANISATIENUMMER, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[ORGANISATIE]
),
fname_hon_sector_educ AS -- firstname + honorific + sectorname + education/voornaam + aanhef + sectornaam + opleidingsniveau
(
SELECT TOP 250 FirstName, CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomhonorific, SECTORNAAM, CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomeducation, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer], [SBBWorkshopOmgeving].[dbo].[SECTOR]
),
lname_email_enroll_guid AS -- lastname + email + is open enrollment + preferred guidance level/achternaam + email + is open inschrijving + gewenst begeleidingsniveau
(
SELECT TOP 250 LastName, CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomemail, CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomenrollment, CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomguidance, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer]
),
bdate AS -- birthdate/geboortedatum
(
SELECT 1 AS id, CAST(DATEADD(DAY, RAND(CHECKSUM(NEWID())) * DATEDIFF(DAY, '1950-01-01', '1998-01-01'), '1950-01-01') AS DATE) AS birthdate
UNION ALL
SELECT id + 1, CAST(DATEADD(DAY, RAND(CHECKSUM(NEWID())) * DATEDIFF(DAY, '1950-01-01', '1998-01-01'), '1950-01-01') AS DATE) AS birthdate
FROM bdate
WHERE id < 250 -- amount of rows/hoeveelheid rijen
),
phonenum AS -- phonenumber/telefoonnummer
(
SELECT 1 AS id, '0' + CAST(CAST(FLOOR((RAND(CHECKSUM(NEWID()))+6)*100000000) AS INT) AS VARCHAR(9)) AS phonenumber
UNION ALL
SELECT id + 1, '0' + CAST(CAST(FLOOR((RAND(CHECKSUM(NEWID()))+6)*100000000) AS INT) AS VARCHAR(9)) AS phonenumber
FROM phonenum
WHERE id < 250 -- amount of rows/hoeveelheid rijen
),
oblocation AS -- organization business location/organisatie vestigingsplaats
(
SELECT TOP 250 City, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorks2014].[Person].[Address]
),
funcname AS -- functionname/functienaam
(
SELECT TOP 250 JobTitle, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorks2014].[HumanResources].[Employee]
)
INSERT INTO [SBBWorkshopOmgeving].[dbo].[DEELNEMER] (SECTORNAAM, ORGANISATIENUMMER, AANHEF, VOORNAAM, ACHTERNAAM, GEBOORTEDATUM, EMAIL, TELEFOONNUMMER, OPLEIDINGSNIVEAU, ORGANISATIE_VESTIGINGSPLAATS, IS_OPEN_INSCHRIJVING, GEWENST_BEGELEIDINGSNIVEAU, FUNCTIENAAM)
SELECT SECTORNAAM, ORGANISATIENUMMER,
honorific =
CASE
	WHEN randomhonorific = 0 THEN 'meneer'
	ELSE 'mevrouw'
END,
FirstName, LastName, birthdate, -- birthdate nog
email =
CASE
	WHEN randomemail = 0 THEN
	LOWER(left(FirstName,1)+LastName)+'@hotmail.com'
	ELSE 
	LOWER(left(FirstName,1)+LastName)+'@gmail.com'
END,
phonenumber,
education =
CASE
	WHEN randomeducation = 0 THEN 'mbo'
	ELSE 'hbo'
END,
City,
randomenrollment,
guidance =
CASE
	WHEN randomguidance = 0 THEN 'mbo'
	ELSE 'hbo'
END,
JobTitle
FROM orgnum o, fname_hon_sector_educ fhse, lname_email_enroll_guid leeg, bdate b, phonenum p, oblocation ol, funcname f
WHERE o.id = fhse.id
AND o.id = leeg.id
AND o.id = b.id
AND o.id = p.id
AND o.id = ol.id
AND o.id = f.id
OPTION(MAXRECURSION 0)
go
/*
SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER]
*/

/*==============================================================*/
/* Table: MODULE                                                */
/*==============================================================*/
DELETE FROM [SBBWorkshopOmgeving].[dbo].[MODULE]
INSERT INTO [SBBWorkshopOmgeving].[dbo].[MODULE] (MODULENUMMER, MODULENAAM)
VALUES	(1, 'Matching en Voorbereiding'),
		(2, 'Begeleiding tijdens BPV'),
		(3, 'Beoordeling')
go
/*
SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[MODULE]
*/

/*==============================================================*/
/* Table: WORKSHOP                                              */
/*==============================================================*/
DELETE FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOP]
go
/*
SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOP]
*/

/*==============================================================*/
/* Table: DEELNEMER_IN_WORKSHOP                                 */
/*==============================================================*/
DELETE FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER_IN_WORKSHOP]
go
/*
SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER_IN_WORKSHOP]
*/