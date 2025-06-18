DROP TABLE IF EXISTS "mhtc_operations"."project_parameters";

CREATE TABLE "mhtc_operations"."project_parameters" (
    "Field" character varying NOT NULL,
    "Value" character varying NOT NULL
);

ALTER TABLE ONLY "mhtc_operations"."project_parameters"
    ADD CONSTRAINT "project_parameters_pkey" PRIMARY KEY ("Field");

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE "mhtc_operations"."project_parameters" TO toms_admin;
GRANT SELECT ON TABLE "mhtc_operations"."project_parameters" TO toms_operator, toms_public;

INSERT INTO mhtc_operations.project_parameters("Field", "Value") VALUES ('VehicleLength', '5.0');
INSERT INTO mhtc_operations.project_parameters("Field", "Value") VALUES ('VehicleWidth', '2.5');
INSERT INTO mhtc_operations.project_parameters("Field", "Value") VALUES ('MotorcycleWidth', '1.0');

INSERT INTO mhtc_operations.project_parameters("Field", "Value") VALUES ('CycleWidth', '0.5');

-- set up corner protection parameter

INSERT INTO mhtc_operations.project_parameters("Field", "Value") VALUES ('CornerProtectionDistance', 5.0);

INSERT INTO mhtc_operations.project_parameters("Field", "Value") VALUES ('BusLength', '14.0');

-- add considersation of RBKC capacity formula

INSERT INTO mhtc_operations.project_parameters("Field", "Value") VALUES ('RBKC_capacity_formula', '0.0');

--DROP FUNCTION IF EXISTS mhtc_operations."getParameter";

CREATE OR REPLACE FUNCTION mhtc_operations."getParameter"(param text) RETURNS text AS
'SELECT "Value"
FROM mhtc_operations."project_parameters"
WHERE "Field" = $1'
LANGUAGE SQL;

