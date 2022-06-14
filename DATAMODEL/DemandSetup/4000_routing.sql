
-- from https://github.com/tmnnrs/highways-network-pgrouting/blob/master/prepare-graph-vehicular-basic.sql

CREATE EXTENSION pgrouting;
--ALTER EXTENSION pgrouting UPDATE TO "3.3.1"


DROP TABLE IF EXISTS highways_network.node_table;

CREATE TABLE highways_network.node_table AS
  SELECT row_number() OVER (ORDER BY foo.p) AS id,
         foo.p AS node,
         foo.geom
  FROM (
    SELECT DISTINCT CONCAT(a."startNode", a."startGradeSeparation") AS p, ST_Startpoint(geom) AS geom FROM highways_network.roadlink a
    UNION
    SELECT DISTINCT CONCAT(a."endNode", a."endGradeSeparation") AS p, ST_Endpoint(geom) AS geom FROM highways_network.roadlink a
  ) foo
  GROUP BY foo.p, foo.geom;

CREATE UNIQUE INDEX node_table_id_idx ON highways_network.node_table (id);
CREATE INDEX node_table_node_idx ON highways_network.node_table (node);

CREATE INDEX node_table_geom_idx
  ON highways_network.node_table
  USING gist
  (geom);

DROP TABLE IF EXISTS highways_network.edge_table;

CREATE TABLE highways_network.edge_table AS
  SELECT row_number() OVER (ORDER BY a."TOID") AS id,
         a.id AS fid,
         a."roadName1_Name" AS name,
         a."roadName2_Name" AS alt_name,
         a."roadClassificationNumber" AS ref,
         a."roadClassification",
         a."routeHierarchy",
         a."formOfWay",
         a."operationalState",
         a.directionality,
         a.length,
         b.id AS source,
         c.id AS target,
         CASE
           WHEN directionality = 'in opposite direction' THEN -1
           ELSE a.length
         END AS cost_distance,
         CASE
           WHEN directionality = 'in direction' THEN -1
           ELSE a.length
         END AS reverse_cost_distance,
         ST_X(ST_StartPoint(a.geom)) AS x1,
         ST_Y(ST_StartPoint(a.geom)) AS y1,
         ST_X(ST_EndPoint(a.geom)) AS x2,
         ST_Y(ST_EndPoint(a.geom)) AS y2,
         a.geom
  FROM highways_network.roadlink a
    JOIN highways_network.node_table AS b ON CONCAT(a."startNode", a."startGradeSeparation") = b.node
    JOIN highways_network.node_table AS c ON CONCAT(a."endNode", a."endGradeSeparation") = c.node;

CREATE UNIQUE INDEX edge_table_id_idx ON highways_network.edge_table (id);
CREATE INDEX edge_table_source_idx ON highways_network.edge_table (source);
CREATE INDEX edge_table_target_idx ON highways_network.edge_table (target);

CREATE INDEX edge_table_routehierarchy_idx ON highways_network.edge_table ("routeHierarchy");
CREATE INDEX edge_table_operationalstate_idx ON highways_network.edge_table ("operationalState");

CREATE INDEX edge_table_geom_idx
  ON highways_network.edge_table
  USING gist
  (geom);

ALTER TABLE highways_network.edge_table
    ADD COLUMN "SurveyArea" integer;

UPDATE highways_network.edge_table s
SET "SurveyArea" = a.id
FROM mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom);

---

SELECT  pgr_createTopology('highways_network.edge_table',0.00001, 'geom','id','source','target');

---

DROP TABLE IF EXISTS mhtc_operations."Routes";

CREATE TABLE mhtc_operations."Routes"
(
    id SERIAL,
    SurveyArea character varying(32) COLLATE pg_catalog."default",
    seq INTEGER,
    node INTEGER,
    edge INTEGER,
    geom geometry(LineString,27700),
    CONSTRAINT "Routes_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE mhtc_operations."Routes"
    OWNER to postgres;


DO
$do$
DECLARE
    this_survey_area RECORD;
    nr_rows_inserted INTEGER;
	str_select VARCHAR;
BEGIN

    -- ** Bays
    FOR this_survey_area IN
        SELECT name
        FROM mhtc_operations."SurveyAreas"
        ORDER BY name::int
    LOOP

        RAISE NOTICE 'Considering survey area % ... ', this_survey_area.name;

        str_select = format('SELECT id, source, target, 1 as cost, 1 as reverse_cost FROM highways_network.edge_table e WHERE "SurveyArea" = %s', this_survey_area.name);
        --RAISE NOTICE '  select str % ... ', str_select;

        INSERT INTO mhtc_operations."Routes"(
            surveyarea, seq, node, edge, geom)
        SELECT this_survey_area.name, c.seq, c.node, c.edge, e.geom
        FROM pgr_chinesepostman (
            str_select) c,
             highways_network.edge_table e
        WHERE c.edge = e.id;

        GET DIAGNOSTICS nr_rows_inserted = ROW_COUNT;
        RAISE NOTICE '** Nr edges in route: % ... ', nr_rows_inserted;

        UPDATE mhtc_operations."Routes" AS r
        SET "InSameDirectionAsRoad" = true
        FROM highways_network.edge_table e
        WHERE e.id = r.edge
        AND e.source = r.node
        AND "SurveyArea"::int = this_survey_area.name::int;

        UPDATE mhtc_operations."Routes" AS r
        SET "InSameDirectionAsRoad" = false
        FROM highways_network.edge_table e
        WHERE e.id = r.edge
        AND e.target = r.node
        AND "SurveyArea"::int = this_survey_area.name::int;

    END LOOP;

END;
$do$;

--DELETE FROM mhtc_operations."Routes";
INSERT INTO mhtc_operations."Routes"(
	surveyarea, seq, node, edge, geom)
SELECT 4, c.seq, c.node, c.edge, e.geom
FROM pgr_chinesepostman (
	'SELECT id, source, target, 1 as cost, 1 as reverse_cost
	 FROM highways_network.edge_table e
	 WHERE "SurveyArea" = 14 ') c,
	 highways_network.edge_table e
WHERE c.edge = e.id;

ALTER TABLE mhtc_operations."Routes"
    ADD COLUMN "InSameDirectionAsRoad" Boolean;

UPDATE mhtc_operations."Routes" AS r
SET "InSameDirectionAsRoad" = true
FROM highways_network.edge_table e
WHERE e.id = r.edge
AND e.source = r.node
AND "SurveyArea" = 14;

UPDATE mhtc_operations."Routes" AS r
SET "InSameDirectionAsRoad" = false
FROM highways_network.edge_table e
WHERE e.id = r.edge
AND e.target = r.node
AND "SurveyArea" = 14;




