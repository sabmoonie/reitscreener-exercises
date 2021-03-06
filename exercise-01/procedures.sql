DROP FUNCTION calculateSharePriceNAV;

CREATE OR REPLACE FUNCTION calculateSharePriceNAV()
  RETURNS trigger AS
$BODY$
DECLARE
	auditedNAVPerUnit FLOAT;
BEGIN
	IF NEW.close = 0 THEN
		RETURN;
	END IF;

    SELECT "auditedNAVPerUnit" INTO auditedNAVPerUnit FROM "AnnualReport" 
	WHERE "reitId" = NEW."reitId" ORDER BY "announcementDate" DESC LIMIT 1;

	INSERT INTO "SharePriceNAV"("reitId",date,"pricePerNAVPerUnit")
	VALUES(NEW."reitId", CURRENT_DATE, NEW.close / auditedNAVPerUnit);

	RETURN NEW;
END;
$BODY$
LANGUAGE PLPGSQL;

DROP FUNCTION calculateSharePriceYield;

CREATE OR REPLACE FUNCTION calculateSharePriceYield()
  RETURNS trigger AS
$BODY$
DECLARE
	declaredDPU FLOAT;
BEGIN
	IF NEW.close = 0 THEN
		RETURN;
	END IF;

    SELECT "declaredDPU" INTO declaredDPU FROM "AnnualReport" 
	WHERE "reitId" = NEW."reitId" ORDER BY "announcementDate" DESC LIMIT 1;

	INSERT INTO "SharePriceYield"("reitId",date,yield)
	VALUES(NEW."reitId", CURRENT_DATE, declaredDPU / NEW.close);

	RETURN NEW;
END;
$BODY$
LANGUAGE PLPGSQL;
