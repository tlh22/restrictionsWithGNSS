
DROP TABLE IF EXISTS demand."VRMs_Wednesday_TheRookery";
CREATE TABLE demand."VRMs_Wednesday_TheRookery"
(
  "ID" SERIAL,
  "SurveyID" integer,
  "SectionID" integer,
  "GeometryID" character varying(12),
  "PositionID" integer,
  "VRM" character varying(12),
  "VehicleTypeID" integer,
  "RestrictionTypeID" integer,
  "PermitType" integer,
  "Notes" character varying(255),
  CONSTRAINT "VRMs_Wednesday_TheRookery_pkey" PRIMARY KEY ("ID")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE demand."VRMs_Wednesday_TheRookery"
  OWNER TO postgres;


--


INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 01 , upper("VRM_01"), cast ("VehicleTypeID_01" as int), cast("RestrictionTypeID_01" as int), cast("PermitType_01" as int), "Notes_01" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_01" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 02 , upper("VRM_02"), cast ("VehicleTypeID_02" as int), cast("RestrictionTypeID_02" as int), cast("PermitType_02" as int), "Notes_02" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_02" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 03 , upper("VRM_03"), cast ("VehicleTypeID_03" as int), cast("RestrictionTypeID_03" as int), cast("PermitType_03" as int), "Notes_03" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_03" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 04 , upper("VRM_04"), cast ("VehicleTypeID_04" as int), cast("RestrictionTypeID_04" as int), cast("PermitType_04" as int), "Notes_04" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_04" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 05 , upper("VRM_05"), cast ("VehicleTypeID_05" as int), cast("RestrictionTypeID_05" as int), cast("PermitType_05" as int), "Notes_05" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_05" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 06 , upper("VRM_06"), cast ("VehicleTypeID_06" as int), cast("RestrictionTypeID_06" as int), cast("PermitType_06" as int), "Notes_06" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_06" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 07 , upper("VRM_07"), cast ("VehicleTypeID_07" as int), cast("RestrictionTypeID_07" as int), cast("PermitType_07" as int), "Notes_07" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_07" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 08 , upper("VRM_08"), cast ("VehicleTypeID_08" as int), cast("RestrictionTypeID_08" as int), cast("PermitType_08" as int), "Notes_08" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_08" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 09 , upper("VRM_09"), cast ("VehicleTypeID_09" as int), cast("RestrictionTypeID_09" as int), cast("PermitType_09" as int), "Notes_09" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_09" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 10 , upper("VRM_10"), cast ("VehicleTypeID_10" as int), cast("RestrictionTypeID_10" as int), cast("PermitType_10" as int), "Notes_10" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_10" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 11 , upper("VRM_11"), cast ("VehicleTypeID_11" as int), cast("RestrictionTypeID_11" as int), cast("PermitType_11" as int), "Notes_11" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_11" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 12 , upper("VRM_12"), cast ("VehicleTypeID_12" as int), cast("RestrictionTypeID_12" as int), cast("PermitType_12" as int), "Notes_12" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_12" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 13 , upper("VRM_13"), cast ("VehicleTypeID_13" as int), cast("RestrictionTypeID_13" as int), cast("PermitType_13" as int), "Notes_13" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_13" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 14 , upper("VRM_14"), cast ("VehicleTypeID_14" as int), cast("RestrictionTypeID_14" as int), cast("PermitType_14" as int), "Notes_14" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_14" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 15 , upper("VRM_15"), cast ("VehicleTypeID_15" as int), cast("RestrictionTypeID_15" as int), cast("PermitType_15" as int), "Notes_15" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_15" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 16 , upper("VRM_16"), cast ("VehicleTypeID_16" as int), cast("RestrictionTypeID_16" as int), cast("PermitType_16" as int), "Notes_16" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_16" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 17 , upper("VRM_17"), cast ("VehicleTypeID_17" as int), cast("RestrictionTypeID_17" as int), cast("PermitType_17" as int), "Notes_17" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_17" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 18 , upper("VRM_18"), cast ("VehicleTypeID_18" as int), cast("RestrictionTypeID_18" as int), cast("PermitType_18" as int), "Notes_18" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_18" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 19 , upper("VRM_19"), cast ("VehicleTypeID_19" as int), cast("RestrictionTypeID_19" as int), cast("PermitType_19" as int), "Notes_19" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_19" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 20 , upper("VRM_20"), cast ("VehicleTypeID_20" as int), cast("RestrictionTypeID_20" as int), cast("PermitType_20" as int), "Notes_20" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_20" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 21 , upper("VRM_21"), cast ("VehicleTypeID_21" as int), cast("RestrictionTypeID_21" as int), cast("PermitType_21" as int), "Notes_21" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_21" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 22 , upper("VRM_22"), cast ("VehicleTypeID_22" as int), cast("RestrictionTypeID_22" as int), cast("PermitType_22" as int), "Notes_22" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_22" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 23 , upper("VRM_23"), cast ("VehicleTypeID_23" as int), cast("RestrictionTypeID_23" as int), cast("PermitType_23" as int), "Notes_23" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_23" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 24 , upper("VRM_24"), cast ("VehicleTypeID_24" as int), cast("RestrictionTypeID_24" as int), cast("PermitType_24" as int), "Notes_24" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_24" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 25 , upper("VRM_25"), cast ("VehicleTypeID_25" as int), cast("RestrictionTypeID_25" as int), cast("PermitType_25" as int), "Notes_25" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_25" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 26 , upper("VRM_26"), cast ("VehicleTypeID_26" as int), cast("RestrictionTypeID_26" as int), cast("PermitType_26" as int), "Notes_26" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_26" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 27 , upper("VRM_27"), cast ("VehicleTypeID_27" as int), cast("RestrictionTypeID_27" as int), cast("PermitType_27" as int), "Notes_27" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_27" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 28 , upper("VRM_28"), cast ("VehicleTypeID_28" as int), cast("RestrictionTypeID_28" as int), cast("PermitType_28" as int), "Notes_28" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_28" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 29 , upper("VRM_29"), cast ("VehicleTypeID_29" as int), cast("RestrictionTypeID_29" as int), cast("PermitType_29" as int), "Notes_29" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_29" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 30 , upper("VRM_30"), cast ("VehicleTypeID_30" as int), cast("RestrictionTypeID_30" as int), cast("PermitType_30" as int), "Notes_30" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_30" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 31 , upper("VRM_31"), cast ("VehicleTypeID_31" as int), cast("RestrictionTypeID_31" as int), cast("PermitType_31" as int), "Notes_31" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_31" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 32 , upper("VRM_32"), cast ("VehicleTypeID_32" as int), cast("RestrictionTypeID_32" as int), cast("PermitType_32" as int), "Notes_32" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_32" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 33 , upper("VRM_33"), cast ("VehicleTypeID_33" as int), cast("RestrictionTypeID_33" as int), cast("PermitType_33" as int), "Notes_33" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_33" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 34 , upper("VRM_34"), cast ("VehicleTypeID_34" as int), cast("RestrictionTypeID_34" as int), cast("PermitType_34" as int), "Notes_34" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_34" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 35 , upper("VRM_35"), cast ("VehicleTypeID_35" as int), cast("RestrictionTypeID_35" as int), cast("PermitType_35" as int), "Notes_35" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_35" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 36 , upper("VRM_36"), cast ("VehicleTypeID_36" as int), cast("RestrictionTypeID_36" as int), cast("PermitType_36" as int), "Notes_36" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_36" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 37 , upper("VRM_37"), cast ("VehicleTypeID_37" as int), cast("RestrictionTypeID_37" as int), cast("PermitType_37" as int), "Notes_37" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_37" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 38 , upper("VRM_38"), cast ("VehicleTypeID_38" as int), cast("RestrictionTypeID_38" as int), cast("PermitType_38" as int), "Notes_38" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_38" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 39 , upper("VRM_39"), cast ("VehicleTypeID_39" as int), cast("RestrictionTypeID_39" as int), cast("PermitType_39" as int), "Notes_39" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_39" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 40 , upper("VRM_40"), cast ("VehicleTypeID_40" as int), cast("RestrictionTypeID_40" as int), cast("PermitType_40" as int), "Notes_40" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_40" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 41 , upper("VRM_41"), cast ("VehicleTypeID_41" as int), cast("RestrictionTypeID_41" as int), cast("PermitType_41" as int), "Notes_41" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_41" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 42 , upper("VRM_42"), cast ("VehicleTypeID_42" as int), cast("RestrictionTypeID_42" as int), cast("PermitType_42" as int), "Notes_42" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_42" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 43 , upper("VRM_43"), cast ("VehicleTypeID_43" as int), cast("RestrictionTypeID_43" as int), cast("PermitType_43" as int), "Notes_43" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_43" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 44 , upper("VRM_44"), cast ("VehicleTypeID_44" as int), cast("RestrictionTypeID_44" as int), cast("PermitType_44" as int), "Notes_44" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_44" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 45 , upper("VRM_45"), cast ("VehicleTypeID_45" as int), cast("RestrictionTypeID_45" as int), cast("PermitType_45" as int), "Notes_45" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_45" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 46 , upper("VRM_46"), cast ("VehicleTypeID_46" as int), cast("RestrictionTypeID_46" as int), cast("PermitType_46" as int), "Notes_46" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_46" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 47 , upper("VRM_47"), cast ("VehicleTypeID_47" as int), cast("RestrictionTypeID_47" as int), cast("PermitType_47" as int), "Notes_47" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_47" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 48 , upper("VRM_48"), cast ("VehicleTypeID_48" as int), cast("RestrictionTypeID_48" as int), cast("PermitType_48" as int), "Notes_48" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_48" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 49 , upper("VRM_49"), cast ("VehicleTypeID_49" as int), cast("RestrictionTypeID_49" as int), cast("PermitType_49" as int), "Notes_49" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_49" IS NOT NULL;
INSERT INTO demand."VRMs_Wednesday_TheRookery" ("SurveyID", "SectionID", "GeometryID", "PositionID" , "VRM", "VehicleTypeID", "RestrictionTypeID",  "PermitType", "Notes") 
 SELECT cast ("SurveyID" as int), "SectionID", "GeometryID", 50 , upper("VRM_50"), cast ("VehicleTypeID_50" as int), cast("RestrictionTypeID_50" as int), cast("PermitType_50" as int), "Notes_50" FROM demand."MASTER_Wednesday_The_Rockery_Merged" WHERE "VRM_50" IS NOT NULL;
