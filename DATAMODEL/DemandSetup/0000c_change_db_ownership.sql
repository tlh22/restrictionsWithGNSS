-- Need to set up permissions. Try changing ownership to toms_admin

do
$$
declare
  l_rec record;
  l_sql text;
begin
  for l_rec in select schemaname, tablename
               from pg_tables
               where schemaname in ('compliance', 'compliance_lookups', 'demand', 'demand_lookups',
									'highway_asset_lookups', 'highway_assets', 
									'highways_network',
									'local_authority', 'mhtc_operations', 
									'public', 'toms', 'toms_lookups', 'topography', 'topography_updates') --<< adjust for your schemas
                 and tableowner = 'postgres'
  loop 
    -- change schema
    l_sql := format('ALTER SCHEMA %I OWNER to toms_admin', l_rec.schemaname);
    raise notice 'Running %: ', l_sql;
    execute l_sql;

	-- change tables
    l_sql := format('ALTER TABLE %I.%I OWNER TO toms_admin', l_rec.schemaname, l_rec.tablename);
    raise notice 'Running %: ', l_sql;
    execute l_sql;
  end loop;
end;
$$;

-- Ensure that toms_admin can create db 
ALTER USER toms_admin CREATEDB;