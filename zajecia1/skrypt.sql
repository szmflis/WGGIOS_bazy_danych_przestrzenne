CREATE EXTENSION postgis;
-- enable raster support (for 3+)
CREATE EXTENSION postgis_raster;
-- Enable Topology
CREATE EXTENSION postgis_topology;
-- Enable PostGIS Advanced 3D
-- and other geoprocessing algorithms
-- sfcgal not available with all distributions
CREATE EXTENSION postgis_sfcgal;
-- fuzzy matching needed for Tiger
CREATE EXTENSION fuzzystrmatch;
-- rule based standardizer
CREATE EXTENSION address_standardizer;
-- example rule data set
CREATE EXTENSION address_standardizer_data_us;
-- Enable US Tiger Geocoder
CREATE EXTENSION postgis_tiger_geocoder;

-- 4
-- Na podstawie poniższej mapy utwórz trzy tabele: buildings (id, geometry, name),
-- roads (id, geometry, name), poi (id, geometry, name).

CREATE TABLE buildings(
    building_id INTEGER,
    building_geom GEOMETRY,
    building_name VARCHAR
);

CREATE TABLE roads(
    road_id INTEGER,
    road_geom GEOMETRY,
    road_name VARCHAR
);

CREATE TABLE poi(
    poi_id INTEGER,
    poi_geom GEOMETRY,
    poi_name VARCHAR
);

-- 5
-- Współrzędne obiektów oraz nazwy (np. BuildingA) należy
-- odczytać z mapki umieszczonej
-- poniżej. Układ współrzędnych ustaw jako niezdefiniowany

INSERT INTO buildings (building_id, building_geom, building_name) VALUES
    (1, st_geomfromtext('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))') , 'BuildingC'),
    (2, st_geomfromtext('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))') , 'BuildingB'),
    (3, st_geomfromtext('POLYGON((9 9, 10 9, 9 8, 10 8, 9 9))') , 'BuildingD'),
    (4, st_geomfromtext('POLYGON((8 4, 10.5 4, 10.5 1.5, 8 1.5, 8 4))') , 'BuildingA'),
    (5, st_geomfromtext('POLYGON((1 2, 2 2, 1 1, 2 1, 1 2))') , 'BuildingF');

INSERT INTO poi (poi_id, poi_geom, poi_name) VALUES
    (1, st_geomfromtext('POINT(6 9.5)'), 'K'),
    (2, st_geomfromtext('POINT(6.5 6)'), 'J'),
    (3, st_geomfromtext('POINT(9.5 6)'), 'I'),
    (4, st_geomfromtext('POINT(1 3.5)'), 'G'),
    (5, st_geomfromtext('POINT(5.5 1.5)'), 'H');

INSERT INTO roads (road_id, road_geom, road_name) VALUES
    (1, st_geomfromtext('LINESTRING(7.5 10.5, 7.5 0)'), 'RoadY'),
    (2, st_geomfromtext('LINESTRING(0 4.5, 12 4.5)'), 'RoadX');

-- 6a
-- Wyznacz całkowitą długość dróg w analizowanym mieście.
SELECT SUM(st_length(road_geom)) FROM roads;

-- 6b
-- Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego
-- budynek o nazwie BuildingA.
SELECT st_astext(building_geom), st_area(building_geom), st_perimeter(building_geom)
FROM buildings
WHERE building_name = 'BuildingA';

-- 6c
-- Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego
-- budynek o nazwie BuildingA.
SELECT st_area(building_geom), building_name
FROM buildings
ORDER BY building_name;

-- 6d
-- Wypisz nazwy i obwody 2 budynków o największej powierzchni.
SELECT building_name, st_perimeter(building_geom)
FROM buildings
ORDER BY st_perimeter(building_geom) ASC
LIMIT 2;

-- 6e
-- Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G.
SELECT st_distance(building_geom, poi_geom)
FROM buildings, poi
WHERE building_name = 'BuildingC'
    AND poi_name = 'G';

-- 6f
-- Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w odległości
-- większej niż 0.5 od budynku BuildingB.
SELECT st_area(st_difference(
    (SELECT building_geom FROM buildings WHERE building_name = 'BuildingC'),
    st_buffer(building_geom, 0.5)
    ))
FROM buildings WHERE building_name ='BuildingB';

-- 6g
-- Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi
-- o nazwie RoadX.

SELECT building_name
FROM buildings, roads
WHERE st_y(st_centroid(building_geom)) > st_y(st_centroid(road_geom))
AND road_name = 'RoadX';

-- 8
-- Oblicz pole powierzchni tych części budynku BuildingC i poligonu
-- o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch
-- obiektów.

SELECT st_area(
    st_symdifference(
            st_geomfromtext('polygon((4 7, 6 7, 6 8, 4 8, 4 7))'),
            building_geom
        )
)
from buildings;
