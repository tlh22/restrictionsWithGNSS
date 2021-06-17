/**
Look at restrictions that should have "At Any Time"
- Car Club Bay (108)
- Disabled Bays (110, 111, 145)
- Bus Stops/stands (107, 122, 161 162)
- Diplomat (112)
- Cycle Hire Bay (116)
- MCL bays (117, 118)
- On carriageway cycle bay (119)
- Police Bay (120)
- Rubbish Bin bays (144)
- Keep Clear Other (146)
- Cycle Hangar (147)
- EV Chargin Point (148)
- Planter (149)
- Parklet (150)
- ??
**/


SELECT "GeometryID", "RestrictionTypeID"
FROM toms."Bays"
WHERE "RestrictionTypeID" IN (108, 110, 111, 145, 107, 122, 161, 162, 112, 116, 117, 118, 119, 120, 144, 146, 147, 148, 149, 150)
AND "TimePeriodID" != 1
AND "MaxStayID" IS NULL
ORDER BY "RestrictionTypeID"

/**
Lines
- DYL/DRL (202, 218)
- Zig-Zag (relevant) (204, 205, 206, 207)
- Crossings (209, 210, 211, 212, 213, 214, 215)
**/

SELECT "GeometryID", "RestrictionTypeID"
FROM toms."Lines"
WHERE "RestrictionTypeID" IN (202, 204, 205, 206, 207, 209, 210, 210, 211, 212, 213, 214, 215)
AND "NoWaitingTimeID" != 1
ORDER BY "RestrictionTypeID"