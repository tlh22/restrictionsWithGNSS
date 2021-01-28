-- tidy junction ids

ALTER TABLE havering_operations."CornersWithinJunctions" DROP CONSTRAINT "CornersWithinJunctions_JunctionID_fkey";

UPDATE havering_operations."HaveringJunctions" AS j
SET "GeometryID" = concat('JU_', "to_char"(SUBSTRING(j."GeometryID", '\d+')::integer, 'FM000000'::"text"));

UPDATE havering_operations."CornersWithinJunctions" AS j
SET "JunctionID" = concat('JU_', "to_char"(SUBSTRING(j."JunctionID", '\d+')::integer, 'FM000000'::"text"));

ALTER TABLE havering_operations."CornersWithinJunctions"
    ADD CONSTRAINT "CornersWithinJunctions_JunctionID_fkey" FOREIGN KEY ("JunctionID")
    REFERENCES havering_operations."HaveringJunctions" ("GeometryID") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;