-- deal with problems in G and Q

/*
    for G, current MatchDayTimePeriodID is "Mon-Fri 2.00pm-8.30pm Sat Noon-4.30pm Sun Noon-4.30pm" (391)
    Need to change to "Mon-Fri 10.00am-8.30pm Sat-Sun Noon-4.30pm" (591)
*/

ALTER TABLE toms."Bays" DISABLE TRIGGER all;
ALTER TABLE toms."Lines" DISABLE TRIGGER all;

UPDATE toms."ControlledParkingZones"
SET "MatchDayTimePeriodID" = 591
WHERE "CPZ" = 'G';

UPDATE toms."MatchDayEventDayZones"
SET "TimePeriodID" = 591
WHERE "EDZ" = 'MG';

UPDATE toms."Bays"
SET "MatchDayTimePeriodID" = 591
WHERE "CPZ" = 'G'
AND "MatchDayTimePeriodID" = 391;

UPDATE toms."Lines"
SET "MatchDayTimePeriodID" = 591
WHERE "CPZ" = 'G'
AND "MatchDayTimePeriodID" = 391;

ALTER TABLE toms."Bays" ENABLE TRIGGER all;
ALTER TABLE toms."Lines" ENABLE TRIGGER all;


/*
    for Q, matchday time period is "Mon-Fri 8.30am-8.30pm Sat-Sun Noon-4.30pm" (450)
    Currently, many Bays and Lines are "Mon-Fri 8.30am-6.30pm Sat-Sun Noon-4.30pm" (444)
*/

ALTER TABLE toms."Bays" DISABLE TRIGGER all;
ALTER TABLE toms."Lines" DISABLE TRIGGER all;

UPDATE toms."Bays"
SET "MatchDayTimePeriodID" = 450
WHERE "CPZ" = 'Q'
AND "MatchDayTimePeriodID" = 444;

UPDATE toms."Lines"
SET "MatchDayTimePeriodID" = 450
WHERE "CPZ" = 'Q'
AND "MatchDayTimePeriodID" = 444;

ALTER TABLE toms."Bays" ENABLE TRIGGER all;
ALTER TABLE toms."Lines" ENABLE TRIGGER all;