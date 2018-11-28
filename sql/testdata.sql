USE master
GO

DELETE FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER_IN_WORKSHOP]
DELETE FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOP]
DELETE FROM [SBBWorkshopOmgeving].[dbo].[MODULE]
DELETE FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER]
DELETE FROM [SBBWorkshopOmgeving].[dbo].[BESCHIKBAARHEID]
DELETE FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOPLEIDER]
DELETE FROM [SBBWorkshopOmgeving].[dbo].[CONTACTPERSOON]
DELETE FROM [SBBWorkshopOmgeving].[dbo].[ADVISEUR]
DELETE FROM [SBBWorkshopOmgeving].[dbo].[ORGANISATIE]
DELETE FROM [SBBWorkshopOmgeving].[dbo].[SECTOR]
DROP PROCEDURE IF EXISTS Testdata_Deelnemer_IN_Workshop
GO

/*
SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[SECTOR]

SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[ORGANISATIE]
ORDER BY ORGANISATIENAAM

SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[ADVISEUR]

SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[CONTACTPERSOON]

SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOPLEIDER]

SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[BESCHIKBAARHEID]

SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER]

SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[MODULE]

SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOP]

SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER_IN_WORKSHOP]
ORDER BY VOLGNUMMER

SELECT *
FROM [SBBWorkshopOmgeving].[dbo].[AANVRAAG]
*/

/*==============================================================*/
/* Table: SECTOR                                                */
/*==============================================================*/
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

/*==============================================================*/
/* Table: ORGANISATIE                                           */
/*==============================================================*/
;WITH orgname AS -- organizationname/organisatienaam
(
SELECT TOP 300 [Name] AS organizationname, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorks2014].[Sales].[Store]
),
pcode AS -- postcode
(
SELECT 1 AS id, CAST(FLOOR(RAND(CHECKSUM(NEWID()))*(9000)+1000) AS CHAR(4)) AS pcodenumbers,
				CHAR(CAST((90-65 )*RAND(CHECKSUM(NEWID())) + 65 AS INT)) AS pcodecharacter1,
				CHAR(CAST((90-65 )*RAND(CHECKSUM(NEWID())) + 65 AS INT)) AS pcodecharacter2
UNION ALL
SELECT id + 1, CAST(FLOOR(RAND(CHECKSUM(NEWID()))*(9000)+1000) AS CHAR(4)) AS pcodenumbers,
			   CHAR(CAST((90-65 )*RAND(CHECKSUM(NEWID())) + 65 AS INT)) AS pcodecharacter1,
			   CHAR(CAST((90-65 )*RAND(CHECKSUM(NEWID())) + 65 AS INT)) AS pcodecharacter2
FROM pcode
WHERE id < 300 -- amount of rows/hoeveelheid rijen
),
adrs AS -- address/adres
(
SELECT TOP 300 STUFF(AddressLine1, 1, PATINDEX('%[^0-9_ -.]%', AddressLine1)-1, '') AS [address], ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorks2014].[Person].[Address]
WHERE AddressLine1 LIKE '[0-9]%'
),
housenum AS -- housenumber/huisnummer
(
SELECT 1 AS id, CAST(FLOOR(RAND(CHECKSUM(NEWID()))*(10+89)+1) AS VARCHAR(4)) AS housenumber
UNION ALL
SELECT id + 1, CAST(FLOOR(RAND(CHECKSUM(NEWID()))*(10+89)+1) AS VARCHAR(4)) AS housenumber
FROM housenum
WHERE id < 300 -- amount of rows/hoeveelheid rijen
),
pname AS -- placename/plaatsnaam
(
SELECT TOP 300 City AS placename, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorks2014].[Person].[Address]
)
INSERT INTO	[SBBWorkshopOmgeving].[dbo].[ORGANISATIE] (ORGANISATIENUMMER, ORGANISATIENAAM, ADRES, POSTCODE, PLAATSNAAM)
SELECT TOP 300	ROW_NUMBER() OVER (ORDER BY NEWID()) AS organizationnumber,
				organizationname,
				([address] + ' ' + housenumber) AS [address],
				(pcodenumbers + pcodecharacter1 + pcodecharacter2) AS postcode,
				placename
FROM orgname o, adrs a, housenum h, pcode p, pname pl
WHERE o.id = a.id
AND o.id = h.id
AND o.id = p.id
AND o.id = pl.id
OPTION (MAXRECURSION 0)
go

/*==============================================================*/
/* Table: ADVISEUR                                              */
/*==============================================================*/
;WITH orgnum AS -- organizationnumber/organisatienummer
(
SELECT TOP 300 ORGANISATIENUMMER AS organizationnumber, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[ORGANISATIE]
),
fname_sector AS -- firstname + sectorname/voornaam + sectornaam
(
SELECT TOP 300 FirstName AS firstname, SECTORNAAM AS sectorname, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer], [SBBWorkshopOmgeving].[dbo].[SECTOR]
),
lname_email AS -- lastname + email/achternaam + email
(
SELECT TOP 300 LastName AS lastname, CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomemail, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
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
INSERT INTO	[SBBWorkshopOmgeving].[dbo].[ADVISEUR] (ORGANISATIENUMMER, SECTORNAAM, VOORNAAM, ACHTERNAAM, TELEFOONNUMMER, EMAIL)
SELECT	organizationnumber, sectorname, firstname, lastname, phonenumber,
		email =
			CASE
				WHEN randomemail = 0 THEN
				LOWER(left(FirstName,1)+LastName)+'@hotmail.com'
				ELSE 
				LOWER(left(FirstName,1)+LastName)+'@gmail.com'
			END
FROM orgnum o, fname_sector fs, lname_email le, phonenum p
WHERE o.id = fs.id
AND o.id = le.id
AND o.id = p.id
OPTION(MAXRECURSION 0)
go

/*==============================================================*/
/* Table: CONTACTPERSOON                                        */
/*==============================================================*/
;WITH orgnum AS -- organizationnumber/organisatienummer
(
SELECT TOP 300 ORGANISATIENUMMER AS organizationnumber, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[ORGANISATIE]
),
fname AS -- firstname/voornaam
(
SELECT TOP 300 FirstName AS firstname, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer]
),
lname_email AS -- lastname + email/achternaam + email
(
SELECT TOP 300 LastName AS lastname, CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomemail, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
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
SELECT	organizationnumber, firstname, lastname, phonenumber,
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

/*==============================================================*/
/* Table: WORKSHOPLEIDER                                        */
/*==============================================================*/
;WITH fname AS -- firstname/voornaam
(
SELECT TOP 300 FirstName AS firstname, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer]
),
lname AS -- lastname/achternaam
(
SELECT TOP 300 LastName AS lastname, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer]
)
INSERT INTO [SBBWorkshopOmgeving].[dbo].[WORKSHOPLEIDER] (VOORNAAM, ACHTERNAAM, TOEVOEGING)
SELECT firstname, lastname, NULL
FROM fname f, lname l
WHERE f.id = l.id
go

/*==============================================================*/
/* Table: BESCHIKBAARHEID                                       */
/*==============================================================*/
INSERT INTO [SBBWorkshopOmgeving].[dbo].[BESCHIKBAARHEID] (WORKSHOPLEIDER_ID, KWARTAAL, JAAR, AANTAL_UUR)
SELECT	WORKSHOPLEIDER_ID AS workshopleader_id,
		FLOOR(RAND(CHECKSUM(NEWID()))*(10-7+1)+1) AS [quarter], -- quarter/kwartaal
		FLOOR(RAND(CHECKSUM(NEWID()))*(10-5+1)+2020) AS [year], -- year/jaar
		FLOOR(RAND(CHECKSUM(NEWID()))*(10+20)+30) AS [hours] -- amount of hours/aantal uur
FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOPLEIDER]
go

/*==============================================================*/
/* Table: DEELNEMER                                             */
/*==============================================================*/
;WITH orgnum AS -- organizationnumber/organisatienummer
(
SELECT TOP 250 ORGANISATIENUMMER AS organizationnumber, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[ORGANISATIE]
),
fname_hon_sector_educ AS -- firstname + honorific + sectorname + education/voornaam + aanhef + sectornaam + opleidingsniveau
(
SELECT TOP 250	FirstName AS firstname,
				CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomhonorific,
				SECTORNAAM AS sectorname,
				CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomeducation,
				ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorksDW2014].[dbo].[DimCustomer], [SBBWorkshopOmgeving].[dbo].[SECTOR]
),
lname_email_enroll_guid AS -- lastname + email + is open enrollment + preferred guidance level/achternaam + email + is open inschrijving + gewenst begeleidingsniveau
(
SELECT TOP 250	LastName AS lastname,
				CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomemail,
				CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) enrollment,
				CAST(RAND(CHECKSUM(NEWID()))*2 AS INT) randomguidance,
				ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
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
SELECT TOP 250 City AS placename, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorks2014].[Person].[Address]
),
funcname AS -- functionname/functienaam
(
SELECT TOP 250 JobTitle AS functionname, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorks2014].[HumanResources].[Employee]
)
INSERT INTO [SBBWorkshopOmgeving].[dbo].[DEELNEMER] (SECTORNAAM, ORGANISATIENUMMER, AANHEF, VOORNAAM, ACHTERNAAM, GEBOORTEDATUM, EMAIL, TELEFOONNUMMER, OPLEIDINGSNIVEAU, ORGANISATIE_VESTIGINGSPLAATS, IS_OPEN_INSCHRIJVING, GEWENST_BEGELEIDINGSNIVEAU, FUNCTIENAAM)
SELECT	sectorname,
		organizationnumber,
		honorific =
			CASE
				WHEN randomhonorific = 0 THEN 'meneer'
				ELSE 'mevrouw'
			END,
		firstname,
		lastname,
		birthdate,
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
		placename,
		enrollment,
		guidance =
			CASE
				WHEN randomguidance = 0 THEN 'mbo'
				ELSE 'hbo'
			END,
		functionname
FROM orgnum o, fname_hon_sector_educ fhse, lname_email_enroll_guid leeg, bdate b, phonenum p, oblocation ol, funcname f
WHERE o.id = fhse.id
AND o.id = leeg.id
AND o.id = b.id
AND o.id = p.id
AND o.id = ol.id
AND o.id = f.id
OPTION(MAXRECURSION 0)
go

/*==============================================================*/
/* Table: MODULE                                                */
/*==============================================================*/
INSERT INTO [SBBWorkshopOmgeving].[dbo].[MODULE] (MODULENUMMER, MODULENAAM)
VALUES	(1, 'Matching en Voorbereiding'),
		(2, 'Begeleiding tijdens BPV'),
		(3, 'Beoordeling')
go

/*==============================================================*/
/* Table: WORKSHOP                                              */
/*==============================================================*/
;WITH wl_id_sname AS -- workshopleader_id + sectorname/workshopleider_id + sectornaam
(
SELECT TOP 250 WORKSHOPLEIDER_ID AS workshopleader_id, SECTORNAAM AS sectorname, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOPLEIDER], [SBBWorkshopOmgeving].[dbo].[SECTOR]
),
cp_id AS -- contactperson_id/contactpersoon_id
(
SELECT TOP 250 CONTACTPERSOON_ID AS contactperson_id, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[CONTACTPERSOON]
),
orgnum AS -- organizationnumber/organisatienummer
(
SELECT TOP 250 ORGANISATIENUMMER AS organizationnumber, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[ORGANISATIE]
),
modnum AS -- modulenumber/modulenummer
(
SELECT 1 AS id, FLOOR(RAND(CHECKSUM(NEWID()))*(10-8+1)+1) AS modulenumber
UNION ALL
SELECT id + 1, FLOOR(RAND(CHECKSUM(NEWID()))*(10-8+1)+1) AS modulenumber
FROM modnum
WHERE id < 250 -- amount of rows/hoeveelheid rijen
),
ad_id AS -- advisor_id/adviseur_id
(
SELECT TOP 250 ADVISEUR_ID AS advisor_id, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[ADVISEUR]
),
wdate AS -- date/datum
(
SELECT 1 AS id, CAST(DATEADD(DAY, RAND(CHECKSUM(NEWID())) * DATEDIFF(DAY, '2020-01-01', '2025-01-01'), '2025-01-01') AS DATE) AS [date]
UNION ALL
SELECT id + 1, CAST(DATEADD(DAY, RAND(CHECKSUM(NEWID())) * DATEDIFF(DAY, '2020-01-01', '2025-01-01'), '2020-01-01') AS DATE) AS [date]
FROM wdate
WHERE id < 250 -- amount of rows/hoeveelheid rijen
),
stime_etime AS -- starttime + endtime/starttijd + eindtijd
(
SELECT 1 AS id, CAST(DATEADD(MINUTE, RAND(CHECKSUM(NEWID())) * DATEDIFF(MINUTE, '09:00:00', '13:00:00'), '09:00:00') AS TIME) AS starttime,
				CAST(DATEADD(MINUTE, RAND(CHECKSUM(NEWID())) * DATEDIFF(MINUTE, '13:00:00', '17:00:00'), '13:00:00') AS TIME) AS endtime
UNION ALL
SELECT id + 1, CAST(DATEADD(MINUTE, RAND(CHECKSUM(NEWID())) * DATEDIFF(MINUTE, '09:00:00', '13:00:00'), '09:00:00') AS TIME) AS starttime,
			   CAST(DATEADD(MINUTE, RAND(CHECKSUM(NEWID())) * DATEDIFF(MINUTE, '13:00:00', '17:00:00'), '13:00:00') AS TIME) AS endtime
FROM stime_etime
WHERE id < 250 -- amount of rows/hoeveelheid rijen
),
adrs AS -- address/adres
(
SELECT TOP 250 STUFF(AddressLine1, 1, PATINDEX('%[^0-9_ -.]%', AddressLine1)-1, '') AS [address], ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorks2014].[Person].[Address]
WHERE AddressLine1 LIKE '[0-9]%'
),
housenum AS -- housenumber/huisnummer
(
SELECT 1 AS id, CAST(FLOOR(RAND(CHECKSUM(NEWID()))*(10+89)+1) AS VARCHAR(2)) AS housenumber
UNION ALL
SELECT id + 1, CAST(FLOOR(RAND(CHECKSUM(NEWID()))*(10+89)+1) AS VARCHAR(2)) AS housenumber
FROM housenum
WHERE id < 250 -- amount of rows/hoeveelheid rijen
),
pcode AS -- postcode
(
SELECT 1 AS id, CAST(FLOOR(RAND(CHECKSUM(NEWID()))*(9000)+1000) AS CHAR(4)) AS pcodenumbers,
				CHAR(CAST((90-65 )*RAND(CHECKSUM(NEWID())) + 65 AS INT)) AS pcodecharacter1,
				CHAR(CAST((90-65 )*RAND(CHECKSUM(NEWID())) + 65 AS INT)) AS pcodecharacter2
UNION ALL
SELECT id + 1, CAST(FLOOR(RAND(CHECKSUM(NEWID()))*(9000)+1000) AS CHAR(4)) AS pcodenumbers,
			   CHAR(CAST((90-65 )*RAND(CHECKSUM(NEWID())) + 65 AS INT)) AS pcodecharacter1,
			   CHAR(CAST((90-65 )*RAND(CHECKSUM(NEWID())) + 65 AS INT)) AS pcodecharacter2
FROM pcode
WHERE id < 250 -- amount of rows/hoeveelheid rijen
),
pname AS -- placename/plaatsnaam
(
SELECT TOP 250 City AS placename, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [AdventureWorks2014].[Person].[Address]
),
wtype AS
(
SELECT 1 id, CAST(RAND(CHECKSUM(NEWID()))*4+1 AS INT) randomtype
UNION ALL
SELECT id + 1, CAST(RAND(CHECKSUM(NEWID()))*4+1 AS INT) randomtype
FROM wtype
WHERE id < 250 -- amount of rows/hoeveelheid rijen
)
INSERT INTO [SBBWorkshopOmgeving].[dbo].[WORKSHOP] (WORKSHOPLEIDER_ID, CONTACTPERSOON_ID, ORGANISATIENUMMER, MODULENUMMER, ADVISEUR_ID, SECTORNAAM, DATUM, STARTTIJD, EINDTIJD, ADRES, POSTCODE, PLAATSNAAM, [STATUS], OPMERKING, TYPE, VERWERKT_BREIN, DEELNEMER_GEGEVENS_ONTVANGEN, OVK_BEVESTIGING, PRESENTIELIJST_VERSTUURD, PRESENTIELIJST_ONTVANGEN, BEWIJS_DEELNAME_MAIL_SBB_WSL)
SELECT	workshopleader_id,
		contactperson_id,
		organizationnumber,
		modulenumber,
		advisor_id,
		sectorname,
		[date],
		starttime,
		endtime,
		([address] + ' ' + housenumber) AS [address],
		(pcodenumbers + pcodecharacter1 + pcodecharacter2) AS postcode,
		placename,
		'bevestigd' AS [status],
		NULL AS OPMERKING,
		[type] =
			CASE
				WHEN randomtype = 1 THEN 'IND'
				WHEN randomtype = 2 THEN 'INC'
				WHEN randomtype = 3 THEN 'COM'
				ELSE 'LA'
			END,
		NULL AS VERWERKT_BREIN,
		NULL AS DEELNEMER_GEGEVENS_ONTVANGEN,
		NULL AS OVK_BEVESTIGING,
		NULL AS PRESENTIELIJST_VERSTUURD,
		NULL AS PRESENTIELIJST_ONTVANGEN,
		NULL AS BEWIJS_DEELNAME_MAIL_SBB_WSL
FROM wl_id_sname ws, cp_id cid, orgnum o, modnum m, ad_id aid, wdate w, stime_etime se, adrs a, housenum h, pcode p, pname pl, wtype wo
WHERE ws.id = cid.id
AND ws.id = o.id
AND ws.id = m.id
AND ws.id = aid.id
AND ws.id = w.id
AND ws.id = se.id
AND ws.id = a.id
AND ws.id = h.id
AND ws.id = p.id
AND ws.id = pl.id
AND ws.id = wo.id
OPTION (MAXRECURSION 0)
go

;WITH randomworkshops AS
(
SELECT TOP 75 WORKSHOP_ID, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOP]
)
UPDATE [SBBWorkshopOmgeving].[dbo].[WORKSHOP]
SET WORKSHOPLEIDER_ID = NULL
FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOP] w INNER JOIN randomworkshops r ON w.WORKSHOP_ID = r.WORKSHOP_ID
go

UPDATE [SBBWorkshopOmgeving].[dbo].[WORKSHOP]
SET [STATUS] = 'uitgezet'
WHERE WORKSHOPLEIDER_ID IS NULL
go

/*==============================================================*/
/* Table: DEELNEMER_IN_WORKSHOP                                 */
/*==============================================================*/
CREATE PROCEDURE Testdata_Deelnemer_IN_Workshop
AS
BEGIN
	DECLARE @counter INT = 1
	WHILE @counter <= 100
		BEGIN
			INSERT INTO [SBBWorkshopOmgeving].[dbo].[DEELNEMER_IN_WORKSHOP] (WORKSHOP_ID, DEELNEMER_ID, VOLGNUMMER, IS_GOEDGEKEURD)
			SELECT TOP 16	workshop_id,
							DEELNEMER_ID AS deelnemer_id,
							@counter AS follownumber,
							0
			FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER],
			(SELECT TOP 1 WORKSHOP_ID AS workshop_id FROM [SBBWorkshopOmgeving].[dbo].[WORKSHOP] ORDER BY NEWID()) workshop
			ORDER BY NEWID()
			SET @counter += 1
		END
END
go

EXEC Testdata_Deelnemer_IN_Workshop
go

DROP PROCEDURE IF EXISTS Testdata_Deelnemer_IN_Workshop
go

;WITH appr AS
(
SELECT VOLGNUMMER
FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER_IN_WORKSHOP]
WHERE VOLGNUMMER IN	(
					SELECT TOP 50 VOLGNUMMER
					FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER_IN_WORKSHOP]
					GROUP BY VOLGNUMMER
					ORDER BY NEWID()
					)
)
UPDATE [SBBWorkshopOmgeving].[dbo].[DEELNEMER_IN_WORKSHOP]
SET IS_GOEDGEKEURD = 1
FROM [SBBWorkshopOmgeving].[dbo].[DEELNEMER_IN_WORKSHOP] dw INNER JOIN appr a ON dw.VOLGNUMMER = a.VOLGNUMMER
go

/*==============================================================*/
/* Table: AANVRAAG				                                */
/*==============================================================*/
;WITH ad_id_cp_id AS -- advisor_id + contactperson_id/adviseur_id + contactpersoon_id
(
SELECT TOP 20 ADVISEUR_ID AS advisor_id, CONTACTPERSOON_ID AS contactperson_id, ROW_NUMBER() OVER (ORDER BY NEWID()) AS id
FROM [SBBWorkshopOmgeving].[dbo].[ADVISEUR] a INNER JOIN [SBBWorkshopOmgeving].[dbo].[CONTACTPERSOON] c
ON a.ORGANISATIENUMMER = c.ORGANISATIENUMMER
),
grps AS -- amount of groups/aantal groepen
(
SELECT 1 AS id, FLOOR(RAND(CHECKSUM(NEWID()))*(10-8+1)+1) AS groups
UNION ALL
SELECT id + 1, FLOOR(RAND(CHECKSUM(NEWID()))*(10-8+1)+1) AS groups
FROM grps
WHERE id < 20 -- amount of rows/hoeveelheid rijen
)
INSERT INTO [SBBWorkshopOmgeving].[dbo].[AANVRAAG] (CONTACTPERSOON_ID, ADVISEUR_ID, AANTAL_GROEPEN)
SELECT contactperson_id, advisor_id, groups
FROM ad_id_cp_id ac, grps g
WHERE ac.id = g.id
go