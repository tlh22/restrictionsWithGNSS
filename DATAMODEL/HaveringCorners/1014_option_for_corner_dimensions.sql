/*
Allow dimensioning to be not shown
*/

ALTER TABLE havering_operations."HaveringCorners"
    ADD COLUMN "ShowDimensions" boolean;

UPDATE havering_operations."HaveringCorners"
SET "ShowDimensions" = True;

