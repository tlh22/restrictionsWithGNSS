/*** For RAMI use Processing - Export to PostgreSQL ***/

-- set up road names
ALTER TABLE "highways_network"."roadlink"
  ADD COLUMN "RoadFrom" character varying(100);
ALTER TABLE "highways_network"."roadlink"
  ADD COLUMN "RoadTo" character varying(100);

/***
-- for import from gml
ALTER TABLE highways_network.roadlink
    RENAME ogc_fid TO id;
***/

ALTER TABLE "highways_network"."roadlink"
ALTER COLUMN geom TYPE geometry(linestring, 27700) USING ST_Force2D(ST_GeometryN(geom, 1));

-- for RAMI
--ALTER TABLE IF EXISTS highways_network.roadlink
--    ADD COLUMN id serial;
/***
alter table highways_network."roadlink"
    alter geom type geometry(LineString, 27700)
        using st_force2d(geom);
        ***/

ALTER TABLE "highways_network"."roadlink"
   ALTER COLUMN id SET DEFAULT nextval('"highways_network"."roadlink_id_seq"'::regclass);

UPDATE highways_network."roadlink" AS c1
SET "RoadFrom" = c2."name1", "RoadTo" = c3."name1"
FROM highways_network."roadlink" c2, highways_network."roadlink" c3
WHERE ((ST_Intersects (ST_EndPoint(c1.geom), ST_EndPoint(c2.geom)) OR ST_Intersects (ST_EndPoint(c1.geom), ST_StartPoint(c2.geom))) AND c2."name1" <> c1."name1")
AND ((ST_Intersects (ST_StartPoint(c1.geom), ST_EndPoint(c3.geom)) OR ST_Intersects (ST_startPoint(c1.geom), ST_StartPoint(c3.geom)))AND c3."name1" <> c1."name1");


-- for RAMI
/***
UPDATE highways_network."roadlink" AS c1
SET "RoadFrom" = c2."roadName1_Name", "RoadTo" = c3."roadName1_Name"
FROM highways_network."roadlink" c2, highways_network."roadlink" c3
WHERE ((ST_Intersects (ST_EndPoint(c1.geom), ST_EndPoint(c2.geom)) OR ST_Intersects (ST_EndPoint(c1.geom), ST_StartPoint(c2.geom))) AND c2."roadName1_Name" <> c1."roadName1_Name")
AND ((ST_Intersects (ST_StartPoint(c1.geom), ST_EndPoint(c3.geom)) OR ST_Intersects (ST_startPoint(c1.geom), ST_StartPoint(c3.geom)))AND c3."roadName1_Name" <> c1."roadName1_Name");
***/


-- Now create View: local_authority.StreetGazetteerView

-- DROP MATERIALIZED VIEW local_authority."StreetGazetteerView";
CREATE MATERIALIZED VIEW local_authority."StreetGazetteerView"
TABLESPACE pg_default
AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS id,
    roadlink.name1 AS "RoadName",
    NULL::text AS "Locality",
    roadlink.geom
   FROM highways_network.roadlink
WITH DATA;

-- for RAMI
/***
CREATE MATERIALIZED VIEW local_authority."StreetGazetteerView"
TABLESPACE pg_default
AS
 SELECT row_number() OVER (PARTITION BY true::boolean) AS id,
    roadlink."roadName1_Name" AS "RoadName",
    NULL::text AS "Locality",
    roadlink.geom
   FROM highways_network.roadlink
WITH DATA;
***/

ALTER TABLE local_authority."StreetGazetteerView"
    OWNER TO postgres;

GRANT SELECT ON TABLE local_authority."StreetGazetteerView" TO toms_admin;
GRANT ALL ON TABLE local_authority."StreetGazetteerView" TO postgres;
GRANT SELECT ON TABLE local_authority."StreetGazetteerView" TO toms_public;
GRANT SELECT ON TABLE local_authority."StreetGazetteerView" TO toms_operator;

CREATE UNIQUE INDEX "idx_StreetGazetteerView_id"
    ON local_authority."StreetGazetteerView" USING btree
    (id)
    TABLESPACE pg_default;
CREATE INDEX idx_street_name
    ON local_authority."StreetGazetteerView" USING btree
    ("RoadName" COLLATE pg_catalog."default")
    TABLESPACE pg_default;