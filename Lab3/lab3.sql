CREATE EXTENSION postgis;

-- 1
-- shp2pgsql.exe "C:\Users\mikos\OneDrive\Pulpit\Semestr 7\BDP\Lab3\Karlsruhe_Germany_Shapefile\T2018_KAR_GERMANY\T2018_KAR_BUILDINGS.shp" public.kar_2018_buildings | psql -h localhost -p 5432 -U postgres -d karlsruhe
SELECT * FROM kar_2018_buildings;

-- shp2pgsql.exe "C:\Users\mikos\OneDrive\Pulpit\Semestr 7\BDP\Lab3\Karlsruhe_Germany_Shapefile\T2019_KAR_GERMANY\T2019_KAR_BUILDINGS.shp" public.kar_2019_buildings | psql -h localhost -p 5432 -U postgres -d karlsruhe
SELECT * FROM kar_2019_buildings;

-- Nowe budynki z 2019 roku
CREATE TEMP TABLE new_buildings_temp AS
SELECT 'Nowy Budynek' AS status,
       kar_2019_buildings.name,
       kar_2019_buildings.polygon_id,
       kar_2019_buildings.geom
FROM kar_2019_buildings
LEFT JOIN kar_2018_buildings 
ON kar_2019_buildings.polygon_id = kar_2018_buildings.polygon_id
WHERE kar_2018_buildings.polygon_id IS NULL;

-- Zmienione budynki (obecne w obu latach, ale różniące się geometrią)
CREATE TEMP TABLE renovated_buildings_temp AS
SELECT 'Zmieniony Budynek' AS status,
       kar_2019_buildings.name,
       kar_2019_buildings.polygon_id,
       kar_2019_buildings.geom
FROM kar_2019_buildings
INNER JOIN kar_2018_buildings ON kar_2019_buildings.polygon_id = kar_2018_buildings.polygon_id
WHERE NOT ST_Equals(kar_2019_buildings.geom, kar_2018_buildings.geom);

SELECT * FROM new_buildings_temp
UNION
SELECT * FROM renovated_buildings_temp;





-- 2

-- shp2pgsql.exe "C:\Users\mikos\OneDrive\Pulpit\Semestr 7\BDP\Lab3\Karlsruhe_Germany_Shapefile\T2018_KAR_GERMANY\T2018_KAR_POI_TABLE.shp" public.kar_2018_poi | psql -h localhost -p 5432 -U postgres -d karlsruhe
SELECT * FROM kar_2018_poi;

-- shp2pgsql.exe "C:\Users\mikos\OneDrive\Pulpit\Semestr 7\BDP\Lab3\Karlsruhe_Germany_Shapefile\T2019_KAR_GERMANY\T2019_KAR_POI_TABLE.shp" public.kar_2019_poi | psql -h localhost -p 5432 -U postgres -d karlsruhe
SELECT * FROM kar_2019_poi;

-- Nowe punkty powstałe w 2019
CREATE TEMP TABLE new_poi AS
SELECT 'Nowy POI' AS status,
	   kar_2019_poi.poi_id,
       kar_2019_poi.poi_name,
       kar_2019_poi.type,
       kar_2019_poi.geom
FROM kar_2019_poi
LEFT JOIN kar_2018_poi ON kar_2019_poi.poi_id = kar_2018_poi.poi_id
WHERE kar_2018_poi.poi_id IS NULL;

SELECT * FROM new_buildings_temp;

-- znalezienie poi które są w odległości 0.005 od nowych i odnowionych budynków
SELECT poi.type AS poi_category,
       COUNT(DISTINCT poi.poi_id) AS poi_count
FROM new_buildings_temp b
INNER JOIN new_poi poi ON ST_DWithin(b.geom, poi.geom, 0.005)
GROUP BY poi.type
UNION ALL
SELECT poi.type AS poi_category,
       COUNT(DISTINCT poi.poi_id) AS poi_count
FROM renovated_buildings_temp b
INNER JOIN new_poi poi ON ST_DWithin(b.geom, poi.geom, 0.005)
GROUP BY poi.type;


-- 3
-- shp2pgsql.exe "C:\Users\mikos\OneDrive\Pulpit\Semestr 7\BDP\Lab3\Karlsruhe_Germany_Shapefile\T2019_KAR_GERMANY\T2019_KAR_STREETS.shp" public.kar_2019_streets | psql -h localhost -p 5432 -U postgres -d karlsruhe
SELECT * FROM kar_2019_streets;

-- Sprawdzenie aktualnego ukłądu wspołrzędnych
SELECT ST_SRID(geom) 
FROM kar_2019_streets 
LIMIT 1;

-- Sprawdznie czy układ DHDN.Berlin/Cassini jest dostępny w systemie
SELECT * 
FROM spatial_ref_sys
WHERE srid = 31467;  -- SRID dla DHDN.Berlin/Cassini

-- Ustawienie układu wgs 84, ponieważ wcześniej było 0 dla srid
UPDATE kar_2019_streets
SET geom = ST_SetSRID(geom, 4326)  -- Przypisanie SRID 4326 (WGS 84)
WHERE ST_SRID(geom) = 0; 

-- Transformacja układu 
CREATE TABLE streets_reprojected AS
SELECT 
    gid,
	link_id,
	st_name,
	ref_in_id,
	nref_in_id,
	func_class,
	speed_cat,
	fr_speed_l,
	to_speed_l,
	dir_travel,
    ST_Transform(geom, 31467) AS geom  -- Transformacja geometrii do układu DHDN.Berlin/Cassini (SRID 31467)
FROM kar_2019_streets;

SELECT gid, st_name, ST_SRID(geom)
FROM streets_reprojected
LIMIT 5;




-- 4

-- Utworznie tabeli
CREATE TABLE input_points (
    id SERIAL PRIMARY KEY, 
    name VARCHAR(255), 
    geom GEOMETRY(Point)
);


-- Załadowanie danych
INSERT INTO input_points (name, geom)
VALUES
    ('Point 1', ST_SetSRID(ST_MakePoint(8.36093, 49.03174), 4326)),
    ('Point 2', ST_SetSRID(ST_MakePoint(8.39876, 49.00644), 4326));

SELECT id, name, ST_AsText(geom) FROM input_points;




-- 5

UPDATE input_points
SET geom = ST_Transform(geom, 31467)
WHERE ST_SRID(geom) = 4326;

SELECT id, name, ST_AsText(geom), ST_SRID(geom) FROM input_points;



-- 6
UPDATE kar_2019_street_node
SET geom = ST_SetSRID(geom, 4326)
WHERE ST_SRID(geom) = 0;

UPDATE kar_2019_street_node
SET geom = ST_Transform(geom, 31467)
WHERE ST_SRID(geom) = 4326;


SELECT ST_SRID(geom) FROM kar_2019_street_node;

WITH line_geom AS (
    SELECT ST_Transform(ST_MakeLine(geom ORDER BY id), 31467) AS geom  -- Tworzymy linię i przekształcamy ją do SRID 31467
    FROM input_points
), 

nearby_crossings AS (
    -- Wyszukujemy skrzyżowania w odległości 200 m od linii
    SELECT sn.gid, sn.node_id, sn.geom
    FROM kar_2019_street_node sn
    CROSS JOIN line_geom
    WHERE ST_DWithin(sn.geom, line_geom.geom, 0.002)  -- Sprawdzamy, które wierzchołki są w odległości 200 m
)

SELECT * FROM nearby_crossings;

-- 7


SELECT COUNT(*)
FROM kar_2019_land_use_a AS l
JOIN kar_2019_poi AS p ON ST_DWithin(l.geom, p.geom, 0.002)
WHERE l.type = 'Park (City/County)'
  AND p.type = 'Sporting Goods Store';


-- 8

SELECT * FROM kar_water_lines;
SELECT * FROM kar_railways;

CREATE TABLE T2019_KAR_BRIDGES (
    gid SERIAL PRIMARY KEY,
    geom geometry(Point)
);


INSERT INTO T2019_KAR_BRIDGES (geom)
SELECT ST_Intersection(r.geom, w.geom) AS geom
FROM kar_railways r
JOIN kar_water_lines w
ON ST_Intersects(r.geom, w.geom)  -- Sprawdzamy, które linie się przecinają
WHERE ST_GeometryType(ST_Intersection(r.geom, w.geom)) = 'ST_Point';

SELECT * FROM T2019_KAR_BRIDGES;