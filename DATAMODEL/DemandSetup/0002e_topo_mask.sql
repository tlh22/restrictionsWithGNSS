/***
 * Mask for covering top areas that are "untidy"
 
   Use a 200m buffer clipped with a 25m buffer from site area to create a shpae with a hole in the middle
 ***/
 
 -- DROP TABLE IF EXISTS topography."TopographicAreasMask";
 
 CREATE TABLE topography."TopographicAreasMask"
 AS 
 SELECT row_number() OVER (PARTITION BY true::boolean) AS sid,
 		ST_Difference(ST_Buffer(v.geom, 400.0), ST_Buffer(v.geom, 25.0))
 FROM local_authority."SiteArea" v;
 
 ALTER TABLE topography."TopographicAreasMask"
    OWNER TO postgres;
    
 CREATE UNIQUE INDEX idx_TopographicAreasMask ON topography."TopographicAreasMask"
(
    "sid"
);
 