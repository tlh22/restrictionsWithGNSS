
-- from https://github.com/tmnnrs/highways-network-pgrouting/blob/master/prepare-graph-vehicular-basic.sql

CREATE EXTENSION pgrouting;
--ALTER EXTENSION pgrouting UPDATE TO "3.3.1"


DROP TABLE IF EXISTS highways_network.node_table2;

CREATE TABLE highways_network.node_table2 AS
  SELECT row_number() OVER (ORDER BY foo.p) AS id,
         foo.p AS node,
         foo.geom
  FROM (
    SELECT DISTINCT a."startNode" AS p, ST_Startpoint(geom) AS geom FROM highways_network."RoadLink_2019" a
    UNION
    SELECT DISTINCT a."endNode" AS p, ST_Endpoint(geom) AS geom FROM highways_network."RoadLink_2019" a
  ) foo
  GROUP BY foo.p, foo.geom;

CREATE UNIQUE INDEX node_table2_id_idx ON highways_network.node_table2 (id);
CREATE INDEX node_table2_node_idx ON highways_network.node_table2 (node);

CREATE INDEX node_table2_geom_idx
  ON highways_network.node_table2
  USING gist
  (geom);

DROP TABLE IF EXISTS highways_network.edge_table2;

CREATE TABLE highways_network.edge_table2 AS
  SELECT row_number() OVER (ORDER BY a."id") AS id,
         a.fid AS fid,
         a."name1" AS name,
         a."name2" AS alt_name,
         a."roadClassificationNumber" AS ref,
         a."roadFunction",
         a."formOfWay",
         'bothDirections' AS directionality,
         a.length,
         --b.id AS source,
         --c.id AS target,
         a.length AS cost_distance,
         a.length AS reverse_cost_distance,
         ST_X(ST_StartPoint(a.geom)) AS x1,
         ST_Y(ST_StartPoint(a.geom)) AS y1,
         ST_X(ST_EndPoint(a.geom)) AS x2,
         ST_Y(ST_EndPoint(a.geom)) AS y2,
         a.geom
  FROM highways_network."RoadLink_2019" a
    JOIN highways_network.node_table2 AS b ON a."startNode" = b.node
    JOIN highways_network.node_table2 AS c ON a."endNode" = c.node;

CREATE UNIQUE INDEX edge_table2_id_idx ON highways_network.edge_table2 (id);
CREATE INDEX edge_table2_source_idx ON highways_network.edge_table2 (source);
CREATE INDEX edge_table2_target_idx ON highways_network.edge_table2 (target);

--CREATE INDEX edge_table2_routehierarchy_idx ON highways_network.edge_table2 ("routeHierarchy");
--CREATE INDEX edge_table2_operationalstate_idx ON highways_network.edge_table2 ("operationalState");

CREATE INDEX edge_table2_geom_idx
  ON highways_network.edge_table2
  USING gist
  (geom);

ALTER TABLE highways_network.edge_table2
    ADD COLUMN "SurveyAreaID" integer;

UPDATE highways_network.edge_table2 s
SET "SurveyAreaID" = a."Code"
FROM mhtc_operations."SurveyAreas" a
WHERE ST_WITHIN (s.geom, a.geom);

-- Now duplicate edges if overlapping in an area

/***
CREATE SEQUENCE highways_network.edge_table2_seq OWNED BY highways_network.edge_table2.id;
SELECT setval('highways_network.edge_table2_seq', coalesce(max(id), 0) + 1, false) FROM highways_network.edge_table2;
ALTER TABLE highways_network.edge_table2 ALTER COLUMN id SET DEFAULT nextval('highways_network.edge_table2_seq');

INSERT INTO highways_network.edge_table2(
	--id,
	fid, name, alt_name, ref, roadclassification, routehierarchy, formofway, operationalstate, directionality, length,
	source, target, cost_distance, reverse_cost_distance, x1, y1, x2, y2, geom, "SurveyAreaID")
SELECT --b.id,
    b.fid, b.name, b.alt_name, b.ref, b.roadclassification, b.routehierarchy, b.formofway, b.operationalstate, b.directionality, b.length,
	b.source, b.target, b.cost_distance, b.reverse_cost_distance, b.x1, b.y1, b.x2, b.y2, b.geom, b."Code"
FROM highways_network.edge_table2 a RIGHT JOIN
    (SELECT id, fid, name, alt_name, ref, roadclassification, routehierarchy, formofway, operationalstate, directionality, length,
	source, target, cost_distance, reverse_cost_distance, x1, y1, x2, y2, s1.geom, a."Code"
    FROM highways_network.edge_table2 s1, mhtc_operations."SurveyAreas" a
    WHERE ST_Intersects (s1.geom, a.geom) ) b
ON a.id=b.id AND a."SurveyAreaID" = b."Code"
WHERE a.id IS NULL
ORDER BY b.id;
***/

---

SELECT  pgr_createTopology('highways_network.edge_table2',0.00001, 'geom','id','source','target');

---

DROP TABLE IF EXISTS mhtc_operations."Routes";

CREATE TABLE mhtc_operations."Routes"
(
    id SERIAL,
    "SurveyAreaID" INTEGER,
    seq INTEGER,
    node INTEGER,
    edge INTEGER,
    geom geometry(LineString,27700),
    CONSTRAINT "Routes_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE mhtc_operations."Routes"
    OWNER to postgres;

ALTER TABLE mhtc_operations."Routes"
    ADD COLUMN "InSameDirectionAsRoad" Boolean;


DO
$do$
DECLARE
    this_survey_area RECORD;
    nr_rows_inserted INTEGER;
	str_select VARCHAR;
BEGIN

    -- ** Bays
    FOR this_survey_area IN
        SELECT "SurveyAreaName", "Code"
        FROM mhtc_operations."SurveyAreas"
        ORDER BY "SurveyAreaName"
    LOOP

        RAISE NOTICE 'Considering survey area % ... ', this_survey_area."SurveyAreaName";

        str_select = format('SELECT id, source, target, 1 as cost, 1 as reverse_cost FROM highways_network.edge_table2 e WHERE "SurveyAreaID" = %s', this_survey_area."Code");
        --RAISE NOTICE '  select str % ... ', str_select;

        INSERT INTO mhtc_operations."Routes"(
            "SurveyAreaID", seq, node, edge, geom)
        SELECT this_survey_area."Code", c.seq, c.node, c.edge, e.geom
        FROM pgr_chinesepostman (
            str_select) c,
             highways_network.edge_table2 e
        WHERE c.edge = e.id;

        GET DIAGNOSTICS nr_rows_inserted = ROW_COUNT;
        RAISE NOTICE '** Nr edges in route: % ... ', nr_rows_inserted;

        UPDATE mhtc_operations."Routes" AS r
        SET "InSameDirectionAsRoad" = true
        FROM highways_network.edge_table2 e
        WHERE e.id = r.edge
        AND e.source = r.node
        AND r."SurveyAreaID" = this_survey_area."Code";

        UPDATE mhtc_operations."Routes" AS r
        SET "InSameDirectionAsRoad" = false
        FROM highways_network.edge_table2 e
        WHERE e.id = r.edge
        AND e.target = r.node
        AND r."SurveyAreaID" = this_survey_area."Code";

    END LOOP;

END;
$do$;

--DELETE FROM mhtc_operations."Routes";
INSERT INTO mhtc_operations."Routes"(
	"SurveyAreaID", seq, node, edge, geom)
SELECT 4, c.seq, c.node, c.edge, e.geom
FROM pgr_chinesepostman (
	'SELECT id, source, target, 1 as cost, 1 as reverse_cost
	 FROM highways_network.edge_table2 e
	 WHERE "SurveyAreaID" = 14 ') c,
	 highways_network.edge_table2 e
WHERE c.edge = e.id;

UPDATE mhtc_operations."Routes" AS r
SET "InSameDirectionAsRoad" = true
FROM highways_network.edge_table2 e
WHERE e.id = r.edge
AND e.source = r.node
AND e."SurveyAreaID" = 14;

UPDATE mhtc_operations."Routes" AS r
SET "InSameDirectionAsRoad" = false
FROM highways_network.edge_table2 e
WHERE e.id = r.edge
AND e.target = r.node
AND e."SurveyAreaID" = 14;




---

UPDATE highways_network.edge_table2
SET cost_distance = ST_LENGTH(geom), reverse_cost_distance = ST_LENGTH(geom)
WHERE cost_distance IS NULL



---


SELECT
pgr_createTopology('highways_network."RoadLink_2019"', 2.0,
                       the_geom:='geom',
                       clean:=TRUE)

SELECT pgr_analyzegraph('highways_network.edge_table2', 2, the_geom:='geom', id:='id');

SELECT pgr_nodeNetwork('highways_network.edge_table2', 2, the_geom:='geom',id:='id');



SELECT  pgr_createTopology('highways_network.edge_table2', 5.0, the_geom:='geom', id:='id', source:='source', target:='target', clean:=TRUE);

SELECT  pgr_analyzeGraph('highways_network.edge_table2', 5.0, the_geom:='geom', id:='id', source:='source', target:='target', rows_where:='"SurveyAreaID" = 13');