/**
Add extra fields to table and form
**/

ALTER TABLE havering_operations."HaveringJunctions"
    ADD COLUMN "JunctionTypeID" integer;

ALTER TABLE ONLY havering_operations."HaveringJunctions"
    ADD CONSTRAINT "JunctionType_JunctionTypes_fkey" FOREIGN KEY ("JunctionTypeID") REFERENCES "havering_operations"."JunctionTypes"("Code");

--
ALTER TABLE havering_operations."HaveringJunctions"
    ADD COLUMN "ExistingCornerProtectionRoadMarkingsConditionTypeID" integer;

ALTER TABLE ONLY havering_operations."HaveringJunctions"
    ADD CONSTRAINT "ExistingCornerProtectionRoadMarkings_ComplianceRoadMarkingsFaded_fkey" FOREIGN KEY ("ExistingCornerProtectionRoadMarkingsConditionTypeID") REFERENCES "compliance_lookups"."RestrictionRoadMarkingsFadedTypes"("Code");

--
ALTER TABLE havering_operations."HaveringJunctions"
    ADD COLUMN "ExistingOtherRestrictionRoadMarkingsConditionTypeID" integer;

ALTER TABLE ONLY havering_operations."HaveringJunctions"
    ADD CONSTRAINT "ExistingOtherRestrictionRoadMarkings_ComplianceRoadMarkingsFaded_fkey" FOREIGN KEY ("ExistingOtherRestrictionRoadMarkingsConditionTypeID") REFERENCES "compliance_lookups"."RestrictionRoadMarkingsFadedTypes"("Code");
