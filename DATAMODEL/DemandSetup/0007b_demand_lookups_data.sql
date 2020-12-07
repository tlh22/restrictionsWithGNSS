-- bayline type demand details


-- vehicle types

INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description") VALUES (1, 'Car');
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description") VALUES (2, 'LGV');
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description") VALUES (3, 'MCL');
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description") VALUES (4, 'OGV');
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description") VALUES (5, 'Bus');
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description") VALUES (6, 'PCL');
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description") VALUES (7, 'Taxi');
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description") VALUES (8, 'Other');
INSERT INTO "demand_lookups"."VehicleTypes" ("Code", "Description") VALUES (9, NULL);

-- permit types

INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (1, 'Resident (Zone F)');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (2, 'Business (Zone F or All zone)');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (3, 'Car club');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (4, 'Visitor/trader ');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (5, 'Visitor P&D ticket');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (6, 'Disabled (Blue badge)');
INSERT INTO "demand_lookups"."PermitTypes" ("Code", "Description") VALUES (7, NULL);