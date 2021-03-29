-- deal with match day time periods for restrictions that are "At Any Time"

-- stop triggers
ALTER TABLE toms."Bays" DISABLE TRIGGER all;
ALTER TABLE toms."Lines" DISABLE TRIGGER all;

UPDATE toms."Bays"
SET "MatchDayTimePeriodID" = NULL
WHERE "TimePeriodID" = 1
AND "MatchDayTimePeriodID" IS NOT NULL;

UPDATE toms."Lines"
SET "NoWaitingTimeID" = NULL
WHERE "NoWaitingTimeID" = 1
AND "MatchDayTimePeriodID" IS NOT NULL;

ALTER TABLE toms."Bays" ENABLE TRIGGER all;
ALTER TABLE toms."Lines" ENABLE TRIGGER all;


