-- Count Demand stem

DROP TABLE IF EXISTS "demand"."Count_DemandStem";
CREATE TABLE "demand"."Count_DemandStem" (
    "id" SERIAL,
    "GeometryID" character varying(12) NOT NULL,
    "SectionID" integer,
    "SurveyID" integer,
    --"SurveyTime" timestamp without time zone,
    "Done" boolean,
    ncars character varying COLLATE pg_catalog."default",
    nlgvs character varying COLLATE pg_catalog."default",
    nmcls character varying COLLATE pg_catalog."default",
    nogvs character varying COLLATE pg_catalog."default",
    ntaxis character varying COLLATE pg_catalog."default",
    nminib character varying COLLATE pg_catalog."default",
    nbuses character varying COLLATE pg_catalog."default",
    nbikes character varying COLLATE pg_catalog."default",
    nogvs2 character varying COLLATE pg_catalog."default",
    nspaces character varying COLLATE pg_catalog."default",
    nnotes character varying COLLATE pg_catalog."default",
    sref character varying COLLATE pg_catalog."default",
    sbays character varying COLLATE pg_catalog."default",
    sreason character varying COLLATE pg_catalog."default",
    scars character varying COLLATE pg_catalog."default",
    slgvs character varying COLLATE pg_catalog."default",
    smcls character varying COLLATE pg_catalog."default",
    sogvs character varying COLLATE pg_catalog."default",
    staxis character varying COLLATE pg_catalog."default",
    sbikes character varying COLLATE pg_catalog."default",
    sbuses character varying COLLATE pg_catalog."default",
    sogvs2 character varying COLLATE pg_catalog."default",
    sminib character varying COLLATE pg_catalog."default",
    snotes character varying COLLATE pg_catalog."default",
    dcars character varying COLLATE pg_catalog."default",
    dlgvs character varying COLLATE pg_catalog."default",
    dmcls character varying COLLATE pg_catalog."default",
    dogvs character varying COLLATE pg_catalog."default",
    dtaxis character varying COLLATE pg_catalog."default",
    dbikes character varying COLLATE pg_catalog."default",
    dbuses character varying COLLATE pg_catalog."default",
    dogvs2 character varying COLLATE pg_catalog."default",
    dminib character varying COLLATE pg_catalog."default",
    "Photos_01" character varying COLLATE pg_catalog."default",
    "Photos_02" character varying COLLATE pg_catalog."default",
    "Photos_03" character varying COLLATE pg_catalog."default",

    CONSTRAINT "Count_DemandStem_pkey" PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE demand."Count_DemandStem"
    OWNER to postgres;
