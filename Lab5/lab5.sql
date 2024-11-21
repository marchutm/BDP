CREATE EXTENSION POSTGIS;

-- 1
CREATE TABLE obiekty (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50),
	geometry GEOMETRY
);

-- a
INSERT INTO obiekty(name, geometry)
VALUES
('obiekt1', (ST_Collect(ARRAY [ST_GeomFromText('LINESTRING(0 1, 1 1)'),
	ST_GeomFromText('CIRCULARSTRING(1 1, 2 0, 3 1)'),
	ST_GeomFromText('CIRCULARSTRING(3 1, 4 2, 5 1)'),
	ST_GeomFromText('LINESTRING(5 1, 6 1)')])));

-- b
INSERT INTO obiekty(name, geometry)
VALUES
('obiekt2', ST_Collect(ARRAY [ST_GeomFromText('LINESTRING(10 6, 10 2)'),
	ST_GeomFromText('CIRCULARSTRING(10 2, 12 0, 14 2)'),
	ST_GeomFromText('CIRCULARSTRING(14 2, 16 4, 14 6)'),
	ST_GeomFromText('LINESTRING(14 6, 10 6)'),
	ST_GeomFromText('CIRCULARSTRING(11 2, 13 2, 11 2)')]));

-- c
INSERT INTO obiekty(name, geometry)
VALUES
('obiekt3', ST_GeomFromText('POLYGON((7 15, 10 17, 12 13, 7 15))'));

-- d
INSERT INTO obiekty(name, geometry)
VALUES
('obiekt4', ST_GeomFromText('LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)'));

-- e
INSERT INTO obiekty(name, geometry)
VALUES
('obiekt5', ST_Collect('POINT(30 30 59)','POINT(38 32 234)'));

-- f
INSERT INTO obiekty(name, geometry)
VALUES
('obiekt6', ST_Collect(ST_GeomFromText('LINESTRING(1 1, 3 2)'),ST_GeomFromText('POINT(4 2)')));

-- 2
SELECT ST_Area(ST_Buffer(ST_ShortestLine(o1.geometry, o2.geometry), 5)) AS pole_powierzchni
FROM obiekty o1
CROSS JOIN obiekty o2
WHERE o1.name = 'obiekt3'
  AND o2.name = 'obiekt4';

-- 3
-- Obiekt 4 nie spełnia definicji poligonu, ponieważ poligon to każda zamknięta linia łamana.
-- W tym przypadku obiekt nie jest zamknięty, co oznacza, że jest linią łamaną, ale nie kwalifikuje się jako poligon.
-- Aby przekształcić obiekt 4 w poligon, należałoby zamknąć linię łamaną, tak by pierwszy i ostatni punkt były tożsame.

UPDATE obiekty
SET geometry = ST_AddPoint(geometry, ST_StartPoint(geometry))
WHERE name = 'obiekt4';

UPDATE obiekty
SET geometry = ST_MakePolygon(geometry)
WHERE name = 'obiekt4';

-- 4
WITH obiekt3 AS
  (SELECT *
   FROM obiekty
   WHERE name = 'obiekt3'),
     obiekt4 AS
  (SELECT *
   FROM obiekty
   WHERE name = 'obiekt4')
INSERT INTO obiekty (id, name, geometry)
SELECT 7,
       'obiekt7',
       ST_Collect(obiekt3.geometry, obiekt4.geometry)
FROM obiekt3
CROSS JOIN obiekt4;

-- 5
SELECT name AS nazwa_obiektu,
       ST_Area(ST_Buffer(geometry, 5)) AS pole_powierzchni
FROM obiekty
WHERE NOT ST_HasArc(geometry);