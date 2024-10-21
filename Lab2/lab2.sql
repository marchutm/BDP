-- 2
CREATE DATABASE bdp;

-- 3
CREATE EXTENSION postgis;

-- 4
CREATE TABLE buildings(
	id SERIAL PRIMARY KEY,
	geometry GEOMETRY,
	name VARCHAR(255)
);

CREATE TABLE roads(
	id SERIAL PRIMARY KEY,
	geometry GEOMETRY,
	name VARCHAR(255)
);

CREATE TABLE poi(
	id SERIAL PRIMARY KEY,
	geometry GEOMETRY,
	name VARCHAR(255)
);

-- 5
INSERT INTO roads (name, geometry) VALUES('RoadX', 'LINESTRING(0 4.5, 12 4.5)');
INSERT INTO roads (name, geometry) VALUES('RoadY', 'LINESTRING(7.5 10.5, 7.5 0)');

SELECT * FROM roads;

INSERT INTO poi (name, geometry) VALUES('G', 'POINT(1 3.5)');
INSERT INTO poi (name, geometry) VALUES('H', 'POINT(5.5 1.5)');
INSERT INTO poi (name, geometry) VALUES('I', 'POINT(9.5 6)');
INSERT INTO poi (name, geometry) VALUES('J', 'POINT(6.5 6)');
INSERT INTO poi (name, geometry) VALUES('K', 'POINT(6 9.5)');

SELECT * FROM poi;

INSERT INTO buildings(name, geometry) VALUES('BuildingA', 'POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))');
INSERT INTO buildings(name, geometry) VALUES('BuildingB', 'POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))');
INSERT INTO buildings(name, geometry) VALUES('BuildingC', 'POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))');
INSERT INTO buildings(name, geometry) VALUES('BuildingD', 'POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))');
INSERT INTO buildings(name, geometry) VALUES('BuildingF', 'POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))');

SELECT * FROM buildings;

-- 6

-- a

SELECT SUM((ST_Length(geometry))) FROM roads;

-- b

SELECT ST_ASTEXT(geometry) AS geometry,
       ST_Area(geometry) AS area,
       ST_Perimeter(geometry) AS perimeter
FROM buildings
WHERE name='BuildingA';

-- c

SELECT name,
       ST_Perimeter(geometry) AS perimeter
FROM buildings
ORDER BY name;

-- d

SELECT name,
       ST_Perimeter(geometry) AS perimeter
FROM buildings
ORDER BY perimeter DESC
LIMIT 2;

-- e

SELECT ST_Distance(b.geometry, p.geometry)
FROM buildings AS b
CROSS JOIN poi AS p
WHERE b.name='BuildingC'
  AND p.name='K';

-- f

SELECT ST_AREA(ST_Difference(BuildingC.geometry, ST_Buffer(BuildingB.geometry, 0.5))) AS g_buffer
FROM buildings AS BuildingB,
     buildings AS BuildingC
WHERE BuildingC.name='BuildingC'
  AND BuildingB.name='BuildingB';

-- g

SELECT b.name
FROM buildings AS b
CROSS JOIN roads AS r
WHERE r.name='RoadX'
  AND ST_Y(ST_Centroid(b.geometry)) > ST_Y(ST_Centroid(r.geometry));

-- h
WITH Polygon AS (
    SELECT ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))') AS geom
)
SELECT ST_Area(ST_Difference(buildingC.geometry, Polygon.geom)) + ST_Area(ST_Difference(Polygon.geom, buildingC.geometry)) AS area
FROM buildings AS buildingC,
     POLYGON
WHERE buildingC.name='BuildingC';