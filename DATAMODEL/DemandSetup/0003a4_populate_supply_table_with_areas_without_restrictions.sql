
-- Also need to include areas where there is no restriction (and call it unmarked)

DROP TABLE IF EXISTS mhtc_operations."Supply_WithoutRestrictions" CASCADE;

CREATE TABLE mhtc_operations."Supply_WithoutRestrictions"
(
    "GeometryID" SERIAL NOT NULL,
    geom geometry(LineString,27700) NOT NULL,

    CONSTRAINT "Supply_WithoutRestrictions_pkey" PRIMARY KEY ("GeometryID")
)

TABLESPACE pg_default;

-- set up crossover nodes table

DROP TABLE IF EXISTS  mhtc_operations."SupplyNodes" CASCADE;

CREATE TABLE mhtc_operations."SupplyNodes"
(
  id SERIAL,
  geom geometry(Point,27700),
  CONSTRAINT "SupplyNodes_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."SupplyNodes"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."SupplyNodes" TO postgres;

CREATE INDEX "sidx_SupplyNodes_geom"
  ON mhtc_operations."SupplyNodes"
  USING gist
  (geom);

INSERT INTO mhtc_operations."SupplyNodes" (geom)
SELECT ST_StartPoint(geom) As geom
FROM mhtc_operations."Supply";

INSERT INTO mhtc_operations."SupplyNodes" (geom)
SELECT ST_EndPoint(geom) As geom
FROM mhtc_operations."Supply";

-- Make "blade" geometry

DROP TABLE IF EXISTS  mhtc_operations."SupplyNodes_Single" CASCADE;

CREATE TABLE mhtc_operations."SupplyNodes_Single"
(
  id SERIAL,
  geom geometry(MultiPoint,27700),
  CONSTRAINT "SupplyNodes_Single_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."SupplyNodes_Single"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."SupplyNodes_Single" TO postgres;

CREATE INDEX "sidx_SupplyNodes_Single_geom"
  ON mhtc_operations."SupplyNodes_Single"
  USING gist
  (geom);

INSERT INTO mhtc_operations."SupplyNodes_Single" (geom)
SELECT ST_Multi(ST_Collect(geom)) As geom
FROM mhtc_operations."SupplyNodes";

--
INSERT INTO mhtc_operations."Supply_WithoutRestrictions"(geom)
SELECT
    --225 AS "RestrictionTypeID", 'Kerbline without restriction' AS "Notes", 
    --"SectionID", "StartStreet", "EndStreet", "SideOfStreet",
    (ST_Dump(ST_Split(s1.geom, ST_Buffer(c.geom, 0.00001)))).geom
FROM "topography"."road_casement" s1, (SELECT ST_Union(ST_Snap(cnr.geom, s1.geom, 0.00000001)) AS geom
									  FROM "topography"."road_casement" s1,
                                          (SELECT geom
                                          FROM "mhtc_operations"."SupplyNodes_Single"
                                          ) cnr
									  ) c
WHERE ST_DWithin(s1.geom, c.geom, 0.25);

DELETE FROM mhtc_operations."Supply_WithoutRestrictions"
WHERE ST_Length(geom) < 0.0001;

-- Add to Supply

INSERT INTO mhtc_operations."Supply"(geom, "RestrictionLength", "RestrictionTypeID", "GeomShapeID", "Notes")
SELECT c.geom, ST_Length(c.geom), 225, 10, 'Kerbline without restriction'
FROM mhtc_operations."Supply_WithoutRestrictions" c
LEFT JOIN mhtc_operations."Supply" s ON ST_Intersects(c.geom, s.geom)
WHERE s."GeometryID" IS NULL
AND c.geom IN (SELECT c.geom
			   FROM  mhtc_operations."Supply_WithoutRestrictions" c, local_authority."SiteArea" a
			   WHERE ST_Within(c.geom, a.geom));

