-- 1 - tabela obiekty
CREATE TABLE obiekty (
    id INT PRIMARY KEY,
    geom GEOMETRY NOT NULL,
    name VARCHAR NOT NULL
);

INSERT INTO obiekty VALUES
(1, st_geomFromText('compoundcurve( ' ||
                    '(0 1, 1 1), ' ||
                    'circularstring(1 1, 2 0, 3 1), ' ||
                    'circularstring(3 1, 4 2, 5 1), ' ||
                    '(5 1, 6 1) )'), 'obiekt1'),

(2, st_geomFromText('CURVEPOLYGON(compoundcurve( ' ||
                    '(10 6, 14 6), ' ||
                    'circularstring(14 6, 16 4, 14 2),' ||
                    'circularstring(14 2, 12 0, 10 2), ' ||
                    '(10 2, 10 6)), ' ||
                    'circularstring(11 2, 12 3, 13 2, 12 1, 11 2))'), 'obiekt2'),

(3, st_geomFromText('multicurve( ' ||
                    '(7 15, 10 17), ' ||
                    '(10 17, 12 13), ' ||
                    '(12 13, 7 15) )' ), 'obiekt3'),

(4, st_geomFromText('multicurve(' ||
                    '(20 20, 25 25), ' ||
                    '(25 25, 27 24), ' ||
                    '(27 24, 25 22), ' ||
                    '(25 22, 26 21), ' ||
                    '(26 21, 22 19), ' ||
                    '(22 19, 20.5 19.5))'), 'obiekt4'),

(5, st_geomFromText('multipoint(' ||
                    '30 30 59, ' ||
                    '38 32 234)'), 'obiekt5'),

(6, st_geomFromText('geometrycollection(' ||
                    'point(4 2), ' ||
                    'linestring(1 1, 3 2))'), 'obiekt6');

SELECT * FROM obiekty;

-- p powierzchi bufora o wielkosci 5 - shortestline miedzy 3 a 4
select st_area(st_buffer(st_shortestline(
    (select geom from obiekty where id = 3),
    (select geom from obiekty where id = 4)
), 5));

-- obiekt 4 na poligon
select
       st_geometrytype(geom),
       st_geometrytype(st_curvetoline(geom)),
       st_geometrytype(st_linemerge(st_curvetoline(geom)))
from obiekty where id = 4;

select
       st_makepolygon(st_linemerge(st_curvetoline(geom)))
from obiekty where id = 4; -- blad bo nie zamkniete

-- ST_AddPoint(geometry linestring, geometry point); z docsow:
		--guarantee all linestrings in a table are closed
		--by adding the start point of each linestring to the end of the line string
		--only for those that are not closed

select
       st_makepolygon(st_addpoint(
               st_linemerge(st_curvetoline(geom)),
               st_startpoint(st_linemerge(st_curvetoline(geom)))
            ))
from obiekty where id = 4;

-- 3 polaczyc 3 i 4 geometrie i wstawic jako obiekt7
insert into obiekty values
(7, st_collect(
    (select geom from obiekty where id = 3),
    (select geom from obiekty where id = 4)
), 'obiekt7');

select * from obiekty where id = 7;

-- 4 p pow buforow = 5 obiektow nie lukowych
select st_area(st_buffer(geom, 5))
from obiekty
where not st_hasarc(geom);
