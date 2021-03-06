/* =================================================================
   Author: Bart
   Create date: 26-11-2018
   Description: this script is used to create the constraints
   for the 'SBBWorkshopOmgeving' database
   --------------------------------
   Modified by: Mark
   Modifications made by Mark: made CK_ind_workshop_values
   ================================================================ */


USE [SBBWorkshopOmgeving]
GO

--=========================================================================
-- WORKSHOP constraints
--=========================================================================

--=========================================================================
-- IR1 / C1 / BR1
-- Check if workshopstate = 'bevestigd' when WORKSHOPLEIDER_ID is not null
--=========================================================================
CREATE OR ALTER TRIGGER TR_workshop_state_bevestigd
ON WORKSHOP
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @RECORDSAFFECTED INT = @@ROWCOUNT
	IF @RECORDSAFFECTED = 0
		RETURN

	SET NOCOUNT ON

	BEGIN TRY
		IF UPDATE(WORKSHOPLEIDER_ID)
			BEGIN
				UPDATE WORKSHOP
				SET STATUS = 'bevestigd'
				FROM WORKSHOP W INNER JOIN inserted i
				ON W.WORKSHOP_ID = i.WORKSHOP_ID 
				LEFT JOIN deleted d 
				ON W.WORKSHOP_ID = d.WORKSHOP_ID 
				WHERE i.WORKSHOPLEIDER_ID IS NOT NULL
				AND d.WORKSHOPLEIDER_ID IS NULL
				AND i.STATUS IS NULL 
			END
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

--=====================================================================================================================
-- IR2 / C2 / BR2
-- A workshop that received VERWERKT_BREIN, DEELNEMER_GEGEGEVENS_ONTVANGEN, OVK_BEVESTIGING, PRESENTIELIJST_VERSTUURD,
-- PRESENTIELIJST_ONTVANGEN, BEWIJS_DEELNAME_MAIL_SBB_WSL has to have status 'afgehandeld'
--=====================================================================================================================
ALTER TABLE WORKSHOP
DROP CONSTRAINT IF EXISTS CK_workshop_concluded
GO

ALTER TABLE WORKSHOP
ADD CONSTRAINT CK_workshop_concluded CHECK((VERWERKT_BREIN IS NULL AND DEELNEMER_GEGEVENS_ONTVANGEN IS NULL AND OVK_BEVESTIGING IS NULL AND
PRESENTIELIJST_VERSTUURD IS NULL AND BEWIJS_DEELNAME_MAIL_SBB_WSL IS NULL AND PRESENTIELIJST_ONTVANGEN IS NULL) OR STATUS = 'afgehandeld')
GO

/*
CREATE OR ALTER TRIGGER TR_workshop_concluded
ON WORKSHOP
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @RECORDSAFFECTED INT = @@ROWCOUNT
	IF @RECORDSAFFECTED = 0
		RETURN

	SET NOCOUNT ON

	BEGIN TRY
		IF (UPDATE(VERWERKT_BREIN) OR UPDATE(DEELNEMER_GEGEVENS_ONTVANGEN) OR UPDATE(OVK_BEVESTIGING)
			OR UPDATE(PRESENTIELIJST_VERSTUURD) OR UPDATE(BEWIJS_DEELNAME_MAIL_SBB_WSL) OR UPDATE(PRESENTIELIJST_ONTVANGEN))
			BEGIN
				UPDATE WORKSHOP
				SET STATUS = 'bevestigd'
				FROM WORKSHOP W INNER JOIN inserted i
				ON W.WORKSHOP_ID = i.WORKSHOP_ID 
				LEFT JOIN deleted d 
				ON W.WORKSHOP_ID = d.WORKSHOP_ID 
				WHERE (W.VERWERKT_BREIN IS NOT NULL OR i.VERWERKT_BREIN IS NOT NULL)
				AND (W.DEELNEMER_GEGEVENS_ONTVANGEN IS NOT NULL OR i.DEELNEMER_GEGEVENS_ONTVANGEN iS NOT NULL)
				AND (W.OVK_BEVESTIGING IS NOT NULL OR i.OVK_BEVESTIGING iS NOT NULL)
				AND	(W.PRESENTIELIJST_VERSTUURD IS NOT NULL OR i.PRESENTIELIJST_VERSTUURD iS NOT NULL)
				AND (W.BEWIJS_DEELNAME_MAIL_SBB_WSL IS NOT NULL OR i.BEWIJS_DEELNAME_MAIL_SBB_WSL iS NOT NULL)
				AND (W.PRESENTIELIJST_ONTVANGEN IS NOT NULL OR i.PRESENTIELIJST_ONTVANGEN iS NOT NULL)
				AND i.STATUS IS NULL
			END
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO
*/
--===============================================
-- IR3 / C3 / BR3
-- Check if adviseur is not null when type = INC
--===============================================
ALTER TABLE WORKSHOP
DROP CONSTRAINT IF EXISTS CK_workshop_advisor
GO

ALTER TABLE WORKSHOP
ADD CONSTRAINT CK_workshop_advisor CHECK(ADVISEUR_ID IS NOT NULL OR TYPE != 'INC')
GO

--========================================================================
-- BR5 / C5 / IR5
-- Check if the workshopdate is later than the date the workshop is added
--========================================================================
ALTER TABLE WORKSHOP
DROP CONSTRAINT IF EXISTS CK_workshop_date
GO

ALTER TABLE WORKSHOP
ADD CONSTRAINT CK_workshop_date CHECK(DATUM > GETDATE())
GO

--========================================================================================
-- IR7 / C7 / BR7
-- If workshop_type isn't IND, then SECTOR has to be NOT NULL
--========================================================================================
ALTER TABLE WORKSHOP
DROP CONSTRAINT IF EXISTS CK_workshop_type_and_sector
GO

ALTER TABLE WORKSHOP
ADD CONSTRAINT CK_workshop_type_and_sector CHECK(SECTORNAAM IS NOT NULL OR TYPE = 'IND')
GO

--========================================================================================
-- IR13 / C13 / BR13
-- Check if the e-mail contains a '@' and a '.'
--========================================================================================
ALTER TABLE WORKSHOP
DROP CONSTRAINT IF EXISTS CK_deelnemer_email
GO

ALTER TABLE WORKSHOP
ADD CONSTRAINT CK_contactperson_email CHECK (CONTACTPERSOON_EMAIL LIKE '%@%.%')
GO

--========================================================================================
-- IR9 / C9 / BR9
-- Check if the workshopstatus is 'uitgezet', 'bevestigd', 'geannuleerd' or 'afgehandeld'
--========================================================================================
ALTER TABLE WORKSHOP
DROP CONSTRAINT IF EXISTS CK_workshop_state
GO

ALTER TABLE WORKSHOP
ADD CONSTRAINT CK_workshop_state CHECK (STATUS IN ('uitgezet', 'bevestigd', 'geannuleerd', 'afgehandeld'))
GO

--========================================================================================
-- IR15 / C15 / BR15
-- The ending time of a workshop has to be after the starting time
--========================================================================================
ALTER TABLE WORKSHOP
DROP CONSTRAINT IF EXISTS CK_workshop_endtime
GO

ALTER TABLE WORKSHOP
ADD CONSTRAINT CK_workshop_endtime CHECK (STARTTIJD < EINDTIJD)
GO

--========================================================================================
-- IR18 / C18 / BR18
-- If TYPE is 'IND' then CONTACTPERSOON_NAAM, CONTACTPERSOON_EMAIL 
-- and CONTACTPERSOON_TELEFOONNUMMER have to be NOT NULL
--========================================================================================
ALTER TABLE WORKSHOP
DROP CONSTRAINT IF EXISTS CK_ind_workshop_values
GO

ALTER TABLE WORKSHOP
ADD CONSTRAINT CK_ind_workshop_values CHECK ([TYPE] = 'IND' OR (CONTACTPERSOON_NAAM IS NULL
OR CONTACTPERSOON_EMAIL IS NULL OR CONTACTPERSOON_TELEFOONNUMMER IS NULL))
GO

--=========================================================================
-- IR16 / C16 / BR16
-- Give a workshopleader his/her available hours back if he/she is no longer
-- leading the workshop.
--=========================================================================
CREATE OR ALTER TRIGGER TR_workshop_remove_hours
ON WORKSHOP
AFTER INSERT, UPDATE
AS
BEGIN
	DECLARE @RECORDSAFFECTED INT = @@ROWCOUNT
	IF @RECORDSAFFECTED = 0
		RETURN

	SET NOCOUNT ON

	BEGIN TRY
		IF UPDATE(WORKSHOPLEIDER_ID)
			BEGIN
				DECLARE @workshopleader_ID INT = (SELECT WORKSHOPLEIDER_ID FROM inserted)
				DECLARE @start_workshop TIME(7) = (SELECT STARTTIJD FROM inserted)
				DECLARE @end_workshop TIME(7) = (SELECT EINDTIJD FROM inserted)
				DECLARE @year SMALLINT = (SELECT CAST(YEAR(DATUM) AS SMALLINT) FROM inserted)
				DECLARE @quarter CHAR(1) = (SELECT CAST(DATEPART(QUARTER, DATUM) AS CHAR(1)) FROM inserted)

				UPDATE	BESCHIKBAARHEID
				SET		AANTAL_UUR = (AANTAL_UUR - (CAST(DATEDIFF(minute, @start_workshop , @end_workshop) AS NUMERIC(5,2)) / 60.00))
				WHERE	WORKSHOPLEIDER_ID = @workshopleader_ID
				AND		JAAR = @year
				AND		KWARTAAL = @quarter
			END
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

--=========================================================================
-- IR19 / C19 / BR19
-- Give a workshopleader his/her available hours back if he/she is no longer
-- leading the workshop.
--=========================================================================
CREATE OR ALTER TRIGGER TR_workshop_return_hours
ON WORKSHOP
AFTER UPDATE, DELETE
AS
BEGIN
	DECLARE @RECORDSAFFECTED INT = @@ROWCOUNT
	IF @RECORDSAFFECTED = 0
		RETURN

	SET NOCOUNT ON

	BEGIN TRY
		IF UPDATE(WORKSHOPLEIDER_ID)
			BEGIN
				DECLARE @workshopleader_ID INT = (SELECT WORKSHOPLEIDER_ID FROM deleted)
				DECLARE @start_workshop TIME(7) = (SELECT STARTTIJD FROM deleted)
				DECLARE @end_workshop TIME(7) = (SELECT EINDTIJD FROM deleted)
				DECLARE @year SMALLINT = (SELECT CAST(YEAR(DATUM) AS SMALLINT) FROM deleted)
				DECLARE @quarter CHAR(1) = (SELECT CAST(DATEPART(QUARTER, DATUM) AS CHAR(1)) FROM deleted)

				UPDATE	BESCHIKBAARHEID
				SET		AANTAL_UUR = (AANTAL_UUR + (CAST(DATEDIFF(minute, @start_workshop , @end_workshop) AS NUMERIC(5,2)) / 60.00))
				WHERE	WORKSHOPLEIDER_ID = @workshopleader_ID
				AND		JAAR = @year
				AND		KWARTAAL = @quarter
			END
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

--=========================================================================
-- MODULE_VAN_GROEP constraints
--=========================================================================

--=========================================================================
-- IR20 / C20 / BR20
-- Give a workshopleader his/her available hours back if he/she is no longer
-- leading the workshop that is still a workshoprequest.
--=========================================================================
CREATE OR ALTER TRIGGER TR_module_van_groep_return_hours
ON MODULE_VAN_GROEP
AFTER UPDATE, DELETE
AS
BEGIN
	DECLARE @RECORDSAFFECTED INT = @@ROWCOUNT
	IF @RECORDSAFFECTED = 0
		RETURN

	SET NOCOUNT ON

	BEGIN TRY
		IF UPDATE(WORKSHOPLEIDER)
			BEGIN
				DECLARE @workshopleader_ID INT = (SELECT WORKSHOPLEIDER FROM deleted)
				DECLARE @start_workshop TIME(7) = (SELECT STARTTIJD FROM deleted)
				DECLARE @end_workshop TIME(7) = (SELECT EINDTIJD FROM deleted)
				DECLARE @year SMALLINT = (SELECT CAST(YEAR(DATUM) AS SMALLINT) FROM deleted)
				DECLARE @quarter CHAR(1) = (SELECT CAST(DATEPART(QUARTER, DATUM) AS CHAR(1)) FROM deleted)

				UPDATE	BESCHIKBAARHEID
				SET		AANTAL_UUR = (AANTAL_UUR + (CAST(DATEDIFF(minute, @start_workshop , @end_workshop) AS NUMERIC(5,2)) / 60.00))
				WHERE	WORKSHOPLEIDER_ID = @workshopleader_ID
				AND		JAAR = @year
				AND		KWARTAAL = @quarter
			END
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

--=========================================================================
-- DEELNEMER constraints
--=========================================================================

--========================================================================================
-- IR4 / C4 / BR4
-- AANHEF has to be 'Mvr.' or 'Dhr.'
--========================================================================================
ALTER TABLE DEELNEMER
DROP CONSTRAINT IF EXISTS CK_salutation
GO

ALTER TABLE DEELNEMER
ADD CONSTRAINT CK_salutation CHECK (AANHEF = 'Mvr.' OR AANHEF = 'Dhr.')
GO

--========================================================================================
-- IR6 / C6 / BR6
-- If IS_OPEN_INSCHRIJVING is 1 then GEWENST_BEGELEIDINGSNIVEAU, FUNCTIENAAM 
-- and SECTORNAAM have to be NOT NULL
--========================================================================================
ALTER TABLE DEELNEMER
DROP CONSTRAINT IF EXISTS CK_open_inschrijving_values
GO

ALTER TABLE DEELNEMER
ADD CONSTRAINT CK_open_inschrijving_values CHECK (IS_OPEN_INSCHRIJVING != 1 OR (GEWENST_BEGELEIDINGSNIVEAU IS NOT NULL
AND FUNCTIENAAM IS NOT NULL))
GO

--========================================================================================
-- IR13 / C13 / BR13
-- Check if the e-mail contains a '@' and a '.'
--========================================================================================
ALTER TABLE DEELNEMER
DROP CONSTRAINT IF EXISTS CK_deelnemer_email
GO

ALTER TABLE DEELNEMER
ADD CONSTRAINT CK_deelnemer_email CHECK (EMAIL LIKE '%@%.%')
GO

--========================================================================================
-- IR14 / C14 / BR14
-- The date of birth can't be higher than the current date
--========================================================================================
ALTER TABLE DEELNEMER
DROP CONSTRAINT IF EXISTS CK_deelnemer_birthdate
GO

ALTER TABLE DEELNEMER
ADD CONSTRAINT CK_deelnemer_birthdate CHECK (GEBOORTEDATUM < GETDATE())
GO

--=========================================================================
-- BESCHIKBAARHEID constraints
--=========================================================================

--========================================================================================
-- IR8 / C8 / BR8
-- KWARTAAL has to be 1, 2, 3 or 4
--========================================================================================
ALTER TABLE BESCHIKBAARHEID
DROP CONSTRAINT IF EXISTS CK_kwartaal
GO

ALTER TABLE BESCHIKBAARHEID
ADD CONSTRAINT CK_kwartaal CHECK (KWARTAAL IN (1, 2, 3, 4))
GO

--========================================================================================
-- IR10 / C10 / BR10
-- JAAR has to be between 1900 and 2200
--========================================================================================
ALTER TABLE BESCHIKBAARHEID
DROP CONSTRAINT IF EXISTS CK_jaar
GO

ALTER TABLE BESCHIKBAARHEID
ADD CONSTRAINT CK_jaar CHECK (JAAR BETWEEN 1900 AND 2200)
GO

-- Deze code wordt gebruikt om de eerste 2 triggers te testen, aangezien deze vaak kapot gaan hou ik
-- de test code nog even hier.
/*
SELECT *
INTO #tempWorkshop
FROM workshop
where 1=0

INSERT INTO #tempWorkshop (WORKSHOPLEIDER_ID) VALUES(1)

SELECT *
FROM #tempWorkshop

SELECT *
FROM #tempWorkshop1

SELECT *
FROM WORKSHOP W INNER JOIN #tempWorkshop i
ON W.WORKSHOP_ID = i.WORKSHOP_ID 
LEFT JOIN #tempWorkshop1 d 
ON W.WORKSHOP_ID = d.WORKSHOP_ID 
WHERE i.WORKSHOPLEIDER_ID IS NOT NULL
AND d.WORKSHOPLEIDER_ID IS NULL
AND i.STATUS IS NULL 

SELECT *
FROM WORKSHOP W LEFT JOIN #tempWorkshop i
ON W.WORKSHOP_ID = i.WORKSHOP_ID 
WHERE i.WORKSHOPLEIDER_ID IS NOT NULL
AND i.STATUS IS NULL 
*/