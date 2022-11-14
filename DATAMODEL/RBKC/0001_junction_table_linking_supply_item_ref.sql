/***
 * Junction tabel to link geometry_id with item_ref (many to many ...)
 ***/

DROP TABLE IF EXISTS "mhtc_operations"."RBKC_item_ref_links" CASCADE;

CREATE TABLE "mhtc_operations"."RBKC_item_ref_links"
(
  gid SERIAL,
  "GeometryID" character varying(12) COLLATE pg_catalog."default",
  item_ref double precision,
  CONSTRAINT "RBKC_item_ref_links_pkey" PRIMARY KEY (gid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "mhtc_operations"."RBKC_item_ref_links"
  OWNER TO postgres;

-- Index: public."sidx_RC_Sections_geom"

--

INSERT INTO "mhtc_operations"."RBKC_item_ref_links" ("GeometryID", item_ref)
SELECT s."GeometryID", "item_ref"
FROM mhtc_operations."Supply" s, local_authority."Bays_Transfer" t
WHERE ST_INTERSECTS(ST_Line_Substring (s.geom, (ST_LENGTH(s.geom)-0.5)/ST_LENGTH(s.geom), 1.0-(ST_LENGTH(s.geom)-0.5)/ST_LENGTH(s.geom)), ST_Buffer(t.geom, 0.1))
AND s."RestrictionTypeID" < 200;

INSERT INTO "mhtc_operations"."RBKC_item_ref_links" ("GeometryID", item_ref)
SELECT s."GeometryID", "item_ref"
FROM mhtc_operations."Supply" s, local_authority."Lines_Transfer" t
WHERE ST_INTERSECTS(s.geom, ST_Buffer(t.geom, 0.1))
AND s."RestrictionTypeID" > 200;


-- Check

SELECT "GeometryID", "RestrictionTypeID", "RoadName"
FROM mhtc_operations."Supply"
WHERE "RestrictionTypeID" < 200
AND "GeometryID" NOT IN (SELECT "GeometryID" FROM "mhtc_operations"."RBKC_item_ref_links");


SELECT "GeometryID", "RestrictionTypeID", "RoadName"
FROM mhtc_operations."Supply" s, local_authority."Bays_Transfer" t, "mhtc_operations"."RBKC_item_ref_links" l
WHERE s."GeometryID" = l."GeometryID"
AND t."item_ref" = l."item_ref"
AND t."RestrictionTypeID" != s."RestrictionTypeID"




