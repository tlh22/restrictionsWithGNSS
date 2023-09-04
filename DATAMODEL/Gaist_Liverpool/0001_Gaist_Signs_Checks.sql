ALTER TABLE IF EXISTS toms_lookups."SignTypes"
    ADD COLUMN "TSRGD_Diagram" character varying(25);

UPDATE toms_lookups."SignTypes"
SET "TSRGD_Diagram" = SUBSTRING("Icon", 'UK_traffic_sign_*(\S{1,10}).svg')
WHERE "Icon" IS NOT NULL;

---- *** Clean up sign times, etc

ALTER TABLE IF EXISTS local_authority."Gaist_Signs"
    ADD COLUMN "Month Day (orig)" character varying(88);
	
UPDATE local_authority."Gaist_Signs"
SET "Month Day (orig)" = "Month Day";

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = LOWER("Month Day");

-- strip out extra details

ALTER TABLE IF EXISTS local_authority."Gaist_Signs"
    ADD COLUMN "MaxStayText" character varying(25);

ALTER TABLE IF EXISTS local_authority."Gaist_Signs"
    ADD COLUMN "NoReturnText" character varying(25);

ALTER TABLE IF EXISTS local_authority."Gaist_Signs"
    ADD COLUMN "AdditionalConditionsText" character varying(250);

ALTER TABLE IF EXISTS local_authority."Gaist_Signs"
    ADD COLUMN "StandardTimeText" character varying(250);
	
ALTER TABLE IF EXISTS local_authority."Gaist_Signs"
    ADD COLUMN "MHTC_TimePeriodCode" integer;
	
-- standard limited waiting
UPDATE local_authority."Gaist_Signs"
SET 
	"Month Day" = SUBSTRING("Month Day", '([^|]+)max stay'), 
	"MaxStayText" = SUBSTRING("Month Day", 'max stay([^|]+)no return'), 
	"NoReturnText" = SUBSTRING("Month Day", 'no return([^|]+)')
WHERE "Month Day" LIKE '%max stay%'
AND LENGTH(SUBSTRING("Month Day", 'max stay([^|]+)no return')) > 0;

-- limited waiting with no "no return" times
UPDATE local_authority."Gaist_Signs"
SET 
	"Month Day" = SUBSTRING("Month Day", '([^|]+)max stay'), 
	"MaxStayText" = SUBSTRING("Month Day", 'max stay([^|]+)')
WHERE "Month Day" LIKE '%max stay%'
AND LENGTH(SUBSTRING("Month Day", 'max stay([^|]+)')) > 0;

UPDATE local_authority."Gaist_Signs"
SET 
	"Month Day" = SUBSTRING("Month Day", '([^|]+)maxstay'), 
	"MaxStayText" = SUBSTRING("Month Day", 'maxstay([^|]+)')
WHERE "Month Day" LIKE '%maxstay%'
AND LENGTH(SUBSTRING("Month Day", 'maxstay([^|]+)')) > 0;

UPDATE local_authority."Gaist_Signs"
SET 
	"Month Day" = SUBSTRING("Month Day", '([^|]+)max saty'), 
	"MaxStayText" = SUBSTRING("Month Day", 'max saty([^|]+)')
WHERE "Month Day" LIKE '%max saty%'
AND LENGTH(SUBSTRING("Month Day", 'max saty([^|]+)')) > 0;

-- Update codes
ALTER TABLE IF EXISTS local_authority."Gaist_Signs"
    ADD COLUMN IF NOT EXISTS "MHTC_MaxStayCode" integer;

ALTER TABLE IF EXISTS local_authority."Gaist_Signs"
    ADD COLUMN IF NOT EXISTS "MHTC_NoReturnCode" integer;

UPDATE local_authority."Gaist_Signs" s
SET "MHTC_MaxStayCode" = l."Code"
FROM toms_lookups."LengthOfTime" l
WHERE TRIM(SUBSTRING("MaxStayText", '([^|]+)m')) = TRIM(SUBSTRING("Description", '([^|]+)min'))
OR TRIM(SUBSTRING("MaxStayText", '([^|]+)h')) = TRIM(SUBSTRING("Description", '([^|]+)hour'));

UPDATE local_authority."Gaist_Signs" s
SET "MHTC_NoReturnCode" = l."Code"
FROM toms_lookups."LengthOfTime" l
WHERE TRIM(SUBSTRING("NoReturnText", '([^|]+)m')) = TRIM(SUBSTRING("Description", '([^|]+)min'))
OR TRIM(SUBSTRING("NoReturnText", '([^|]+)h')) = TRIM(SUBSTRING("Description", '([^|]+)hour'));
	
-- extra
UPDATE local_authority."Gaist_Signs"
SET 
	"Month Day" = SUBSTRING("Month Day", '([^|]+)no return'), 
	"NoReturnText" = SUBSTRING("Month Day", 'no return([^|]+)')
WHERE "Month Day" LIKE '%no return%'
AND LENGTH(SUBSTRING("Month Day", 'no return([^|]+)')) > 0;

-- entrance markings
UPDATE local_authority."Gaist_Signs"
SET 
	"Month Day" = SUBSTRING("Month Day", '([^|]+)on  entrance markings'), 
	"AdditionalConditionsText" = 'on entrance markings'
WHERE "Month Day" LIKE '%on  entrance markings%'
;

UPDATE local_authority."Gaist_Signs"
SET 
	"Month Day" = SUBSTRING("Month Day", '([^|]+)on school entrance markings'), 
	"AdditionalConditionsText" = 'on school entrance markings'
WHERE "Month Day" LIKE '%on school entrance markings%'
;
-- Remove any extra spaces
UPDATE local_authority."Gaist_Signs"
SET "Month Day" = TRIM("Month Day");

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = regexp_replace("Month Day", '- ', '-')
WHERE "Month Day" LIKE ('%- %');

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = regexp_replace("Month Day", ' -', '-')
WHERE "Month Day" LIKE ('% -%');

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = regexp_replace("Month Day", ' - ', '-')
WHERE "Month Day" LIKE ('% - %');

-- Get into a standard form '00:00'
UPDATE local_authority."Gaist_Signs"
SET "Month Day" = regexp_replace("Month Day", ' ([0-9]){1}:', ' 0\1:');

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = regexp_replace("Month Day", '-([0-9]){1}:', '-0\1:');

-- specifics

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = 'mon-sat 07:30-09:30 16:00-18:30'
WHERe "Month Day" IN ( 'mon-sat 07:30 09:30-16:00 18:30'
					  );

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = 'mon-sat 08:00-09:30 16:30-18:00'
WHERe "Month Day" IN ( 'mon-sat 08:00-09:30-16:30-18:00'
					  );
	
UPDATE local_authority."Gaist_Signs"
SET "Month Day" = '1 aug-30 jun 10:00-00:00'
WHERe "Month Day" IN ( '1aug-30jun 10:00-00:00'
					  );
					  
UPDATE local_authority."Gaist_Signs"
SET "Month Day" = '1 sep-31 may mon-fri 09:00-16:30'
WHERe "Month Day" IN ( '1 sept-31 may mon-fri 09:00-16:301 sept-31 may mon-fri 09:00-16:30', '1 sep-31 may mon-fri 09:00-16:30'
					  );

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = '1 sep-31 may mon-fri 04:30-00:00'
WHERe "Month Day" IN ( '1 sept-31 may mon-fri 04:30-00:00'
					  );	

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = 'mon-sun 08:00-18:00'
WHERe "Month Day" IN ( 'mon-son 08:00-18:00'
					  );	
					  
-- convert to 12 hour clock

do $$
DECLARE
	time_record RECORD;
	dates TEXT;
	days TEXT;
	times TEXT;
	
	time_string RECORD;
	var1 TEXT;
	var2 TEXT;
	converted_times TEXT;

	hour1 TEXT;
	minute1 TEXT;
	hour2 TEXT;
	minute2 TEXT;
	time1 TEXT;
	time2 TEXT;
	
begin
   for time_record in SELECT id, "Month Day" 
					  FROM local_authority."Gaist_Signs"
					  WHERE LENGTH ("Month Day") > 0
   LOOP
   
	   times = time_record."Month Day";
	   converted_times = '';

		WHILE COALESCE(LENGTH(times),0) > 0 LOOP

			dates = SUBSTRING(times, '([^|]*?)\ymon|tue|wed|thu|fri|sat|sun\y');
			IF COALESCE(LENGTH(dates),0) > 0 THEN
				converted_times = CONCAT(converted_times, ' ', TRIM(INITCAP(dates)));
				times = TRIM(SUBSTRING(times, LENGTH(dates)));
			END IF;
			
			days = SUBSTRING(times, '\w{3}-\w{3}');	
			IF COALESCE(LENGTH(days),0) > 0 THEN
				converted_times = CONCAT(converted_times, ' ', TRIM(INITCAP(days)));
				times = TRIM(SUBSTRING(times, '\w{3}-\w{3}([^|]+)'));
			END IF;
		
			var1 = SUBSTRING(times, '\d{2}:\d{2}-\d{2}:\d{2}');
			
			-- assume format 00:00-00:00
			
			hour1 = SUBSTRING(var1, 1, 2);
			minute1 = SUBSTRING(var1, 4, 2);
			time1 = convert_to_12_hour_time_string(hour1, minute1);
			
			hour2 = SUBSTRING(var1, 7, 2);
			minute2 = SUBSTRING(var1, 10, 2);
			time2 = convert_to_12_hour_time_string(hour2, minute2);

			converted_times = CONCAT(converted_times, ' ', time1, '-', time2);
			times = TRIM(SUBSTRING(times, '\d{2}:\d{2}-\d{2}:\d{2}([^|]+)'));
			
			--raise notice 'time period: %. % % --%-- |%| %', var1, hour1, hour2, converted_times, times, COALESCE(LENGTH(times),0) ;
		
		END LOOP;
	
		UPDATE local_authority."Gaist_Signs"
		SET "StandardTimeText" = converted_times
		WHERE id = time_record."id";
		
	    --raise notice 'record: %. % %', time_record."Month Day", INITCAP(days), converted_times ;
	   
   END LOOP;
end; $$

create or replace function convert_to_12_hour_time_string(hour TEXT, minute TEXT)
   returns text
       LANGUAGE 'plpgsql'
  as
$$
declare 

	i_hour INTEGER;
	i_minute INTEGER;
	time_text TEXT;
	
begin

	i_hour = TO_NUMBER(hour, '99');
	i_minute = TO_NUMBER(minute, '99');
	
	IF i_hour = 0 THEN
		IF i_minute = 0 THEN
			time_text = 'midnight';
		ELSE
			time_text = TRIM(CONCAT(TO_CHAR(i_hour, '99'), '.', minute, 'am'));
		END IF;
	ELSIF i_hour < 12 THEN
		time_text = TRIM(CONCAT(TO_CHAR(i_hour, '99'), '.', minute, 'am'));
	ELSIF i_hour = 12 THEN
		IF i_minute = 0 THEN
			time_text = 'Noon';
		ELSE
			time_text = TRIM(CONCAT(TO_CHAR(i_hour, '99'), '.', minute, 'pm'));
		END IF;
	ELSE
		i_hour = i_hour - 12;
		time_text = TRIM(CONCAT(TO_CHAR(i_hour, '99'), '.', minute, 'pm'));
	END IF;

	RETURN time_text;

end;
$$

-- Match to TimePeriods
UPDATE local_authority."Gaist_Signs" s
SET "MHTC_TimePeriodCode" = t."Code"
FROM toms_lookups."TimePeriods" t
WHERE TRIM(s."StandardTimeText") = TRIM(t."Description");

-- Loading at any time
UPDATE local_authority."Gaist_Signs" s
SET "MHTC_TimePeriodCode" = 1
WHERE s."Dft Diagra" IN ('638');

-- Output
SELECT DISTINCT s."Dft Diagra", t."Description", count(s."Dft Diagra")
	FROM local_authority."Gaist_Signs" s LEFT JOIN toms_lookups."SignTypes" t ON s."Dft Diagra" = t."TSRGD_Diagram"
	group BY "Dft Diagra", t."Description"
	ORDER BY "Dft Diagra";

-- *******

-- Initial efforts

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = 'Mon-Sat 07:00-19:00'
WHERE "Month Day" LIKE '% Mon-Sat 07:00-19:00';

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = '1 Aug-30 Jun Mon-Sun 10:00-00:00'
WHERe "Month Day" IN ( '1 Aug- 30 Jun Mon-Sun 10:00-00', '1 Aug- 30 Jun Mon-Sun 10:00-00:00', '1 Aug-30 Jun  10:00-00:00',
					   '1 Aug-30 Jun 10:00-00:00', '1 Aug-30 Jun Mon-Sun 10:00-00:0', '1 Aug-30 Jun Mon-Sun 10:00-00:00',
					   '1 Aug-30 Jun Mon-Sun 10:00 -00:00', '1 Aug-30 Jun Mon-Sun 10:00 00:00', '1 Aug-30Jun Mon-Sun 10:00-00:00',
					   '1 Aug-30 Jun Mon-Sun 10:00-00:00', '1 Aug-30 Jun  Mon-Sun 10:00-00:00'
					  );

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = '1 Aug-31 May Mon-Fri 17:00-22:00 Sat-Sun 10:00-18:00'
WHERe "Month Day" IN ( '1 Aug-31 May Mon-Fri 17:00-22:00  Sat -Sun 10:00-18:00', '1 Aug-31 May Mon-Fri 17:00-22:00 Sat-Sun 10:00-18:00',
					   '1 Aug-31 May Mon-Fri 17:00-22:00 Sat -Sun 10:00-18:00', '1Aug-31May Mon-Fri 17:00-22:00  Sat & Sun 10:00-18:00',
					   'Mon-Fri 17:00 22:00 Sat Sun 10:00-18:00 1 Aug-31 May'
					  );
					  
UPDATE local_authority."Gaist_Signs"
SET "Month Day" = '1 Sep-31 May Mon-Fri 09:00-16:30'
WHERe "Month Day" IN ( '1 Sep-31 May Mon-Fri 09:00-16:30', '1 Sept-31 May Mon-Fri 09:00-16:30',
					   '1 Sept-31May Mon-Fri  09:00-16:30'
					  );

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = '1 Aug-31 May Mon-Fri 05:00-22:00 Sat-Sun 10:00-18:00'
WHERe "Month Day" IN ( '1 Aug-31 May Mon-Fri 5:00-22:00 Sat-Sun 10:00-18:00', '1 Aug-31 May Mon-Fri 05:00-22:00 Sat-Sun 10:00-18:00'
					  );
					  
UPDATE local_authority."Gaist_Signs"
SET "Month Day" = '1 Aug-30 Jun Mon-Sun 10:00-00:00'
WHERe "Month Day" IN ( '1Aug- 30Jun Mon-Sun 10:00-00:00', '1Aug- 30Jun Mon-Sun 10:00 00:00', ''
					   '1Aug-30jun Mon-Sun 10:00-00:00', '1Aug-30Jun Mon-Sun 10:00-00:00'
					  );					  
					  
UPDATE local_authority."Gaist_Signs"
SET "Month Day" = 'Mon-Fri 08:00-17:00'
WHERe "Month Day" IN ( 'Mon-Fri 08:00-17:00', 'Mon-Fri  08:00-17:00', 'Mon- Fri 08:00-17:00', 'Mon-Fri  08:00 -17:00'
					  );
					  
UPDATE local_authority."Gaist_Signs"
SET "Month Day" = 'Mon-Fri 07:00-19:00'
WHERe "Month Day" IN ( 'Mon-Fri 07:00-19:00', 'Mon-Fri 07:00 19:00'
					  );
					  
UPDATE local_authority."Gaist_Signs"
SET "Month Day" = 'Mon-Fri 07:30-09:30 16:00-18:30'
WHERe "Month Day" IN ( 'Mon-fri 07:30-09:30 16:00-18:30', 'Mon-Fri 07:30-09:30 16:00-18:30', 'Mon-Fri 07:30-09:30 16:00 -18:30',
					   'Mon-Fri 07:30-9:30 16:00-18:30', 'Mon-Fri 7:30-9.30 16:00-18:30'
					  );
					  
UPDATE local_authority."Gaist_Signs"
SET "Month Day" = 'Mon-Fri 07:30-09:30'
WHERe "Month Day" IN ( 'Mon-Fri 07:30-09:30', 'Mon-Fri 07:30-9:30'
					  );

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = 'Mon-Fri 08:00-09:00 15:00-16:30'
WHERe "Month Day" IN ( 'Mon-Fri 08:00-09:00-15:00-16:30', 'Mon-Fri 08:00-09:00 15:00-16:30'
					  );

UPDATE local_authority."Gaist_Signs"
SET "Month Day" = 'Mon-Fri 08:00-17:00'
WHERe "Month Day" IN ( 'Mon-Fri 08:00-17:00', 'mon-fri 08:00-17:00', 'Mon-Fri 08:00 17:00', 'Mon-Fri 08:00AM-17:00PM'
					  );
					  
UPDATE local_authority."Gaist_Signs"
SET "Month Day" = 'Mon-Sat 07:00-19:00'
WHERe "Month Day" IN ( 'Mon-Sat 07:00-19:00', 'Mon-sat 07:00-19:00', 'Mon-Sat 07:00 19:00'
					  );					  