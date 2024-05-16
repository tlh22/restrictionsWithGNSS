--

REVOKE ALL ON ALL TABLES IN SCHEMA highways_network FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA highways_network TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA highways_network TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA highways_network TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA local_authority FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA local_authority TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA local_authority TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA local_authority TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA toms_lookups FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA toms_lookups TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA toms_lookups TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA toms_lookups TO toms_public, toms_operator, toms_admin;

REVOKE ALL ON ALL TABLES IN SCHEMA topography FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA topography TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA topography TO toms_public, toms_operator, toms_admin;
GRANT USAGE ON SCHEMA topography TO toms_public, toms_operator, toms_admin;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE "mhtc_operations"."RC_Sections_merged" TO toms_admin, toms_operator;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE mhtc_operations."Corners" TO toms_operator, toms_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE mhtc_operations."SectionBreakPoints" TO toms_operator, toms_admin;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE topography.road_casement TO toms_operator, toms_admin;

GRANT ALL ON SCHEMA mhtc_operations TO postgres;
GRANT USAGE ON SCHEMA mhtc_operations TO toms_admin;
GRANT USAGE ON SCHEMA mhtc_operations TO toms_operator;
GRANT USAGE ON SCHEMA mhtc_operations TO toms_public;

REVOKE ALL ON ALL TABLES IN SCHEMA mhtc_operations FROM toms_public, toms_operator, toms_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;
GRANT SELECT,USAGE ON ALL SEQUENCES IN SCHEMA mhtc_operations TO toms_public, toms_operator, toms_admin;

GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE mhtc_operations."MHTC_Kerblines" TO toms_operator, toms_admin;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE mhtc_operations."gnss_pts" TO toms_operator, toms_admin;