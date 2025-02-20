/***
 * Junction tabel to link geometry_id with item_ref (many to many ...)
 ***/

This takes a long time to run

DROP TABLE IF EXISTS "mhtc_operations"."RBKC_item_ref_links_2024" CASCADE;

CREATE TABLE "mhtc_operations"."RBKC_item_ref_links_2024"
(
  gid SERIAL,
  "GeometryID" character varying(12) COLLATE pg_catalog."default",
  item_ref double precision,
  CONSTRAINT "RBKC_item_ref_links_2024_pkey" PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "mhtc_operations"."RBKC_item_ref_links_2024"
  OWNER TO postgres;

-- Index: public."sidx_RC_Sections_geom"

--

INSERT INTO "mhtc_operations"."RBKC_item_ref_links_2024" ("GeometryID", item_ref)
SELECT s."GeometryID", "item_ref"
FROM mhtc_operations."Supply" s, local_authority."PM_Lines_Transfer_Current_101" t
WHERE ST_INTERSECTS(ST_LineSubstring (s.geom, 0.1, 0.9), ST_Buffer(t.geom, 0.1))
AND s."RestrictionTypeID" < 200
AND s."GeometryID" NOT IN (SELECT DISTINCT "GeometryID" FROM "mhtc_operations"."RBKC_item_ref_links_2024");

INSERT INTO "mhtc_operations"."RBKC_item_ref_links_2024" ("GeometryID", item_ref)
SELECT s."GeometryID", "item_ref"
FROM mhtc_operations."Supply" s, local_authority."PM_Lines_Transfer_Current_101" t
WHERE ST_INTERSECTS(ST_LineSubstring (s.geom, 0.1, 0.9), ST_Buffer(t.geom, 0.1))
AND s."RestrictionTypeID" > 200
AND s."GeometryID" NOT IN (SELECT DISTINCT "GeometryID" FROM "mhtc_operations"."RBKC_item_ref_links_2024");


-- Check

SELECT "GeometryID", "RestrictionTypeID", "RoadName"
FROM mhtc_operations."Supply"
WHERE "RestrictionTypeID" < 200
AND "GeometryID" NOT IN (SELECT "GeometryID" FROM "mhtc_operations"."RBKC_item_ref_links_2024");


SELECT "GeometryID", "RestrictionTypeID", "RoadName"
FROM mhtc_operations."Supply" s, local_authority."Bays_Transfer" t, "mhtc_operations"."RBKC_item_ref_links_2024" l
WHERE s."GeometryID" = l."GeometryID"
AND t."item_ref" = l."item_ref"
AND t."RestrictionTypeID" != s."RestrictionTypeID"




