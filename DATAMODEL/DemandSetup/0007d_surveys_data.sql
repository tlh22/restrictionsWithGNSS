-- surveys

--INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (1, 'Monday', '0030', '0300');
--INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (2, 'Tuesday', '0030', '0300');


INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (1, 'Wednesday', '0500', '0700');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (2, 'Wednesday', '0700', '0800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (3, 'Wednesday', '0900', '1000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (4, 'Wednesday', '1100', '1200');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (5, 'Wednesday', '1300', '1400');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (6, 'Wednesday', '1500', '1600');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (7, 'Wednesday', '1700', '1800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (8, 'Wednesday', '1900', '2000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (9, 'Wednesday', '2100', '2200');

INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (10, 'Saturday', '0500', '0600');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (11, 'Saturday', '0700', '0800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (12, 'Saturday', '0900', '1000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (13, 'Saturday', '1100', '1200');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (14, 'Saturday', '1300', '1400');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (15, 'Saturday', '1500', '1600');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (16, 'Saturday', '1700', '1800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (17, 'Saturday', '1900', '2000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (18, 'Saturday', '2100', '2200');

INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (19, 'Sunday', '0500', '0600');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (20, 'Sunday', '0700', '0800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (21, 'Sunday', '0900', '1000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (22, 'Sunday', '1100', '1200');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (23, 'Sunday', '1300', '1400');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (24, 'Sunday', '1500', '1600');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (25, 'Sunday', '1700', '1800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (26, 'Sunday', '1900', '2000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (27, 'Sunday', '2100', '2200');

UPDATE demand."Surveys"
SET "BeatTitle" = LPAD("SurveyID"::text, 2, '0') || '_' || "SurveyDay" || '_' || "BeatStartTime" || '_' || "BeatEndTime";


INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (31, 'Wednesday', '0500', '0600');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (32, 'Wednesday', '0700', '0800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (33, 'Wednesday', '0900', '1000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (34, 'Wednesday', '1100', '1200');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (35, 'Wednesday', '1400', '1500');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (36, 'Wednesday', '1600', '1700');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (37, 'Wednesday', '1800', '1900');

INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (38, 'Saturday', '0500', '0600');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (39, 'Saturday', '0700', '0800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (40, 'Saturday', '0900', '1000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (41, 'Saturday', '1100', '1200');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (42, 'Saturday', '1400', '1500');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (43, 'Saturday', '1600', '1700');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (44, 'Saturday', '1800', '1900');

INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (45, 'Sunday', '0500', '0600');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (46, 'Sunday', '0700', '0800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (47, 'Sunday', '0900', '1000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (48, 'Sunday', '1100', '1200');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (49, 'Sunday', '1400', '1500');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (50, 'Sunday', '1600', '1700');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (51, 'Sunday', '1800', '1900');

UPDATE demand."Surveys"
SET "BeatTitle" = LPAD("SurveyID"::text, 2, '0') || '_' || "SurveyDay" || '_' || "BeatStartTime" || '_' || "BeatEndTime";


-- hourly beats
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (101, 'Wednesday', '0700', '0800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (102, 'Wednesday', '0800', '0900');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (103, 'Wednesday', '0900', '1000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (104, 'Wednesday', '1000', '1100');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (105, 'Wednesday', '1100', '1200');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (106, 'Wednesday', '1200', '1300');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (107, 'Wednesday', '1300', '1400');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (108, 'Wednesday', '1400', '1500');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (109, 'Wednesday', '1500', '1600');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (110, 'Wednesday', '1600', '1700');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (111, 'Wednesday', '1700', '1800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (112, 'Wednesday', '1800', '1900');

INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (201, 'Thursday', '0700', '0800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (202, 'Thursday', '0800', '0900');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (203, 'Thursday', '0900', '1000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (204, 'Thursday', '1000', '1100');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (205, 'Thursday', '1100', '1200');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (206, 'Thursday', '1200', '1300');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (207, 'Thursday', '1300', '1400');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (208, 'Thursday', '1400', '1500');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (209, 'Thursday', '1500', '1600');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (210, 'Thursday', '1600', '1700');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (211, 'Thursday', '1700', '1800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (212, 'Thursday', '1800', '1900');

INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (301, 'Saturday', '0700', '0800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (302, 'Saturday', '0800', '0900');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (303, 'Saturday', '0900', '1000');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (304, 'Saturday', '1000', '1100');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (305, 'Saturday', '1100', '1200');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (306, 'Saturday', '1200', '1300');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (307, 'Saturday', '1300', '1400');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (308, 'Saturday', '1400', '1500');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (309, 'Saturday', '1500', '1600');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (310, 'Saturday', '1600', '1700');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (311, 'Saturday', '1700', '1800');
INSERT INTO demand."Surveys"("SurveyID", "SurveyDay", "BeatStartTime", "BeatEndTime") VALUES (312, 'Saturday', '1800', '1900');

UPDATE demand."Surveys"
SET "BeatTitle" = LPAD("SurveyID"::text, 3, '0') || '_' || "SurveyDay" || '_' || "BeatStartTime" || '_' || "BeatEndTime";






-- Deal with SiteArea

UPDATE demand."Surveys"
SET "SiteArea" = SUBSTRING("SurveyDay" FROM '\(([^\(]+)\)')
