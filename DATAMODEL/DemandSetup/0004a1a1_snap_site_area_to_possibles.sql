/***

Snap SiteArea to:
 - restriction start/end points
 - Corners
 - Section Break points
 
***/

-- set up points table

DROP TABLE IF EXISTS mhtc_operations."SiteArea_PossibleVertices" CASCADE;

CREATE TABLE mhtc_operations."SiteArea_PossibleVertices"
(
  id SERIAL,
  geom geometry(Point,27700),
  CONSTRAINT "SiteArea_PossibleVertices_pkey" PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE mhtc_operations."SiteArea_PossibleVertices"
  OWNER TO postgres;
GRANT ALL ON TABLE mhtc_operations."SiteArea_PossibleVertices" TO postgres;

-- Index: public."sidx_SiteArea_PossibleVertices_geom"

-- DROP INDEX public."sidx_SiteArea_PossibleVertices_geom";

CREATE INDEX "sidx_SiteArea_PossibleVertices_geom"
  ON mhtc_operations."SiteArea_PossibleVertices"
  USING gist
  (geom);
  
  
INSERT INTO mhtc_operations."SiteArea_PossibleVertices" (geom)
SELECT DISTINCT (geom)
FROM (
	SELECT ST_StartPoint(s.geom) AS geom
	FROM mhtc_operations."Supply" s, local_authority."SiteArea" b
	WHERE ST_DWithin(ST_StartPoint(s.geom), ST_Boundary(b.geom), 0.25)
	UNION
	SELECT ST_EndPoint(s.geom) AS geom
	FROM mhtc_operations."Supply" s, local_authority."SiteArea" b
	WHERE ST_DWithin(ST_EndPoint(s.geom), ST_Boundary(b.geom), 0.25)
	UNION
	SELECT s.geom AS geom
	FROM mhtc_operations."Corners_Single" s, local_authority."SiteArea" b
	WHERE ST_DWithin(s.geom, ST_Boundary(b.geom), 0.25)
) j
; 

-- Copy current table

-- DROP TABLE IF EXISTS local_authority."SiteArea_orig";

CREATE TABLE IF NOT EXISTS local_authority."SiteArea_orig"
(
    id character varying COLLATE pg_catalog."default" NOT NULL,
    geom geometry(MultiPolygon,27700),
    fid bigint,
    "endNode" character varying(39) COLLATE pg_catalog."default",
    "startNode" character varying(39) COLLATE pg_catalog."default",
    "roadNumberTOID" character varying(21) COLLATE pg_catalog."default",
    "roadNameTOID" character varying(21) COLLATE pg_catalog."default",
    fictitious integer,
    "roadClassification" character varying(22) COLLATE pg_catalog."default",
    "roadFunction" character varying(30) COLLATE pg_catalog."default",
    "formOfWay" character varying(50) COLLATE pg_catalog."default",
    length integer,
    length_uom character varying(10) COLLATE pg_catalog."default",
    loop integer,
    "primaryRoute" integer,
    "trunkRoad" integer,
    "roadClassificationNumber" character varying(10) COLLATE pg_catalog."default",
    name1 character varying(150) COLLATE pg_catalog."default",
    name1_lang character varying(150) COLLATE pg_catalog."default",
    name2 character varying(150) COLLATE pg_catalog."default",
    name2_lang character varying(150) COLLATE pg_catalog."default",
    "roadStructure" character varying(14) COLLATE pg_catalog."default",
    CONSTRAINT "SiteArea_orig_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS local_authority."SiteArea_orig"
    OWNER to postgres;
-- Index: sidx_SiteArea_geom

INSERT INTO local_authority."SiteArea_orig"(
	id, geom, fid, "endNode", "startNode", "roadNumberTOID", "roadNameTOID", fictitious, "roadClassification", "roadFunction", "formOfWay", length, length_uom, loop, "primaryRoute", "trunkRoad", "roadClassificationNumber", name1, name1_lang, name2, name2_lang, "roadStructure")
SELECT id, geom, fid, "endNode", "startNode", "roadNumberTOID", "roadNameTOID", fictitious, "roadClassification", "roadFunction", "formOfWay", length, length_uom, loop, "primaryRoute", "trunkRoad", "roadClassificationNumber", name1, name1_lang, name2, name2_lang, "roadStructure"
	FROM local_authority."SiteArea";


/***

Next steps:
 a. Use "Snap Geometries to Layer" in toolbox. Input layer is "SiteArea" and reference layer is "SiteArea_PossibleVertices". Tolerance is 0.25
 b. Use GDAL "Export to PostgresQL (available connections)" but allow it to save as Multipoly
 c. Change from MultiPoly to Poly 

***/

/***
--- Delete from table

-- DELETE FROM local_authority."SiteArea";

--



--- Loop through all vertices in polygon


do $$
DECLARE
	site_area_geom RECORD;
	site_area_pt geometry;
	curr_geom_pt geometry;
	bdy geometry;
	p1 integer;
	p2 integer;
	
begin

	-- get boundary of polygon
	
	FOR site_area_geom IN
		SELECT path[1], geom
		FROM (
			SELECT (ST_Dump(ST_Boundary(geom))).*
			FROM local_authority."SiteArea"
			) a

    FOR site_area_geom IN
			SELECT a.p1, a.p2, a.geom AS site_area_pt, j.geom AS curr_geom_pt
			FROM (SELECT path[1] AS p1, path[2] AS p2, geom
				  FROM (SELECT (ST_DumpPoints(ST_Boundary(geom))).* FROM local_authority."SiteArea") q
				 ) a,
				(SELECT DISTINCT ((ST_Dump(geom)).geom) As geom
				 FROM (SELECT ST_StartPoint(geom) As geom FROM mhtc_operations."Supply"
					     UNION
					   SELECT ST_EndPoint(geom) As geom FROM mhtc_operations."Supply"
					     UNION
					   SELECT geom FROM mhtc_operations."Corners"
						 UNION
					   SELECT geom FROM mhtc_operations."SectionBreakPoints" ) k
				) j

			WHERE ST_DWithin(a.geom, j.geom, 0.25)
			AND NOT ST_EQUALS(a.geom, j.geom)
			
	LOOP

		-- Replace the point with the 
		UPDATE bdy
		   SET geom = ST_SetPoint(geom, ST_NPoints(site_area_geom, 0) ) - 1)

    END LOOP;

end; $$;	


***/