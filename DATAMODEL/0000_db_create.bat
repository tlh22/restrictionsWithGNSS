SET currentDB=SYS2011_Watford2
SET PGPASSWORD=OS!2postgres
SET DataModelPath="C:\Users\marie_000\AppData\Roaming\QGIS\QGIS3\profiles\default\python\plugins\TOMs\DATAMODEL"
SET TestDataPath="C:\Users\marie_000\AppData\Roaming\QGIS\QGIS3\profiles\default\python\plugins\TOMs\test\data"
echo on
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0001_initial_data_structure.sql %currentDB%
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0002a_roles_and_users.sql %currentDB%
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0002b_permissions.sql %currentDB%
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0002c_additional_permissions.sql %currentDB%

"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %TestDataPath%\0002a_test_data_lookups.sql %currentDB%

"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0002d_tidy_itn_roadcentreline.sql %currentDB%

"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %TestDataPath%\0002d_add_additional_condition_types.sql %currentDB%
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %TestDataPath%\0003b_test_data_add_sign_wkt.sql %currentDB%

"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0006a_restructure_compliance_lookups.sql %currentDB%
REM "C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0006b_Gazetteer_from_RAMI.sql %currentDB%
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0006c_additional_toms_details.sql %currentDB%

"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %TestDataPath%\0006a_test_data_add_icon_details_to_sign_types.sql %currentDB%
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %TestDataPath%\0006b_test_data_compliance_lookups.sql %currentDB%
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %TestDataPath%\0006c_update_toms_details.sql %currentDB%

"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0007_moving_traffic_data_structure.sql %currentDB%
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0007b_moving_traffic_permissions.sql %currentDB%
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0008_add_match_day_control_times.sql %currentDB%
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0009_add_pay_parking_areas.sql %currentDB%

REM "C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0010_highway_asset_lookups_structure.sql %currentDB%
REM "C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0011_highway_assets_structure.sql %currentDB%
REM "C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0012_highway_assets_permissions.sql %currentDB%

"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0015_add_toms_create_date.sql %currentDB%
"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0016_add_moving_traffic_create_date.sql %currentDB%

REM "C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0017_add_highway_assets_create_date.sql %currentDB%

"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0018_add_toms_capacity.sql %currentDB%

"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %TestDataPath%\0018_add_toms_capacity_details.sql %currentDB%

"C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0019_add_toms_additional_condition_to_restriction_polygons.sql %currentDB%

REM "C:\Program Files\PostgreSQL\12\bin\psql" -U postgres -p 5433 -f %DataModelPath%\0022_remove_extra_restriction_polygon_types.sql %currentDB%
