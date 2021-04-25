
-- Set permissions

REVOKE ALL ON ALL TABLES IN SCHEMA havering_operations FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA havering_operations TO toms_public;
GRANT SELECT, UPDATE, INSERT, DELETE ON ALL TABLES IN SCHEMA havering_operations TO toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA havering_operations TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA havering_operations TO toms_public, toms_operator, toms_admin;