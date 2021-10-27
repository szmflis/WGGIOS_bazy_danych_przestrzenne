-- 4 - budynki 1000m od rzek
SELECT popp.geom
INTO tableB
FROM popp
JOIN rivers ON st_within(popp.geom, st_buffer(rivers.geom, 1000))
WHERE popp.f_codedesc = 'Building';

-- 5
select airports.name, airports.geom, airports.elev
into airportsNew
from airports;
-- 5 a lotnisko najdalej na zachod i wschod

select airportsNew.name, st_x(airportsNew.geom) as x
from airportsNew
order by x DESC LIMIT 1;

select airportsNew.name, st_x(airportsNew.geom) as x
from airportsNew
order by x ASC LIMIT 1;

-- 5 b lotnisko miedzy tymi wyzej rowno

INSERT INTO airportsNew VALUES (
    'airport',
    1337,
    (
        SELECT st_centroid(
            st_makeline(
                (select geom from airportsNew where name = 'ATKA'),
                (select geom from airportsNew where name = 'ANNETTE ISLAND')
            )
        )
    )
);

-- 6. Wyznacz pole powierzchni obszaru, który oddalony jest mniej niż 1000 jednostek od najkrótszej linii
-- łączącej jezioro o nazwie ‘Iliamna Lake’ i lotnisko o nazwie „AMBLER”
SELECT st_area(st_buffer(st_shortestline(airportsNew.geom, lakes.geom),1000))
FROM airportsNew, lakes
WHERE lakes.names='Iliamna Lake' and airportsNew.name='AMBLER';

-- 7. sumaryczne pole poligonow prezentujacych typy drzew w tundrze/bagnach
SELECT sum(st_area(trees.geom)) as powierzchnia, trees.vegdesc as nazwa
FROM trees, swamp, tundra
WHERE st_contains(trees.geom, swamp.geom) or st_contains(trees.geom, tundra.geom)
group by nazwa;