Psql -h <host> - p<port> -U <database> <user> ;
psql -h pg.pg4e.com -p 5432 -U pg4e_1886d2596c pg4e_1886d2596c;
creating tables:
CREATE TABLE album (
  id SERIAL,
  title VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE track (
    id SERIAL,
    title VARCHAR(128),
    len INTEGER, rating INTEGER, count INTEGER,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    UNIQUE(title, album_id),
    PRIMARY KEY(id)
);

DROP TABLE IF EXISTS track_raw;
CREATE TABLE track_raw
 (title TEXT, artist TEXT, album TEXT, album_id INTEGER,
  count INTEGER, rating INTEGER, len INTEGER);

To copy the excel into the table using psql \copy command:
Download the csv file into the system and then upload into pythonanywhere
\copy track_raw(title,artist,album,count,rating,len)from 'library.csv' with delimiter ',' csv;
select * from track_raw limit 5;
insert distinct values into album:
insert into album(title) select distinct (album) from track_raw;
so that we can get the album_id, update the track_raw with album_id
update track_raw set album_id = (select album.id from album where album.title = track_raw.album);
inserting values into track table
insert into track (title,len,rating,count,album_id) select title, len,rating,count,album_id from track_raw;
Done
Next assignment;
Create tables
Step_1:
CREATE TABLE unesco_raw
 (name TEXT, description TEXT, justification TEXT, year INTEGER,
    longitude FLOAT, latitude FLOAT, area_hectares FLOAT,
    category TEXT, category_id INTEGER, state TEXT, state_id INTEGER,
    region TEXT, region_id INTEGER, iso TEXT, iso_id INTEGER);
create lookup tables:

CREATE TABLE category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) UNIQUE
);

CREATE TABLE state (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) UNIQUE
);

CREATE TABLE region (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) UNIQUE
);

CREATE TABLE iso (
    id SERIAL PRIMARY KEY,
    name VARCHAR(128) UNIQUE
);
Step_2:
Upload the csv file into pythonanywhere
To remove the csv header line and copy
\copy unesco_raw(name,description,justification,year,longitude,latitude,area_hectares,category,state,region,iso) FROM 'whc-sites-2018-small.csv' WITH DELIMITER ',' CSV HEADER;
Step_3: Normalize the data
INSERT INTO category (name)
SELECT DISTINCT category FROM unesco_raw
WHERE category IS NOT NULL;

INSERT INTO state (name)
SELECT DISTINCT state FROM unesco_raw
WHERE state IS NOT NULL;

INSERT INTO region (name)
SELECT DISTINCT region FROM unesco_raw
WHERE region IS NOT NULL;

INSERT INTO iso (name)
SELECT DISTINCT iso FROM unesco_raw
WHERE iso IS NOT NULL;

Step 4: Update unesco_raw with Foreign Keys
UPDATE unesco_raw 
SET category_id = (SELECT id FROM category WHERE category.name = unesco_raw.category);

UPDATE unesco_raw 
SET state_id = (SELECT id FROM state WHERE state.name = unesco_raw.state);

UPDATE unesco_raw 
SET region_id = (SELECT id FROM region WHERE region.name = unesco_raw.region);

UPDATE unesco_raw 
SET iso_id = (SELECT id FROM iso WHERE iso.name = unesco_raw.iso);

Step 5: Create the Final unesco Table
CREATE TABLE unesco (
    id SERIAL PRIMARY KEY,
    name TEXT,
    description TEXT,
    justification TEXT,
    year INTEGER,
    longitude FLOAT,
    latitude FLOAT,
    area_hectares FLOAT,
    category_id INTEGER REFERENCES category(id),
    state_id INTEGER REFERENCES state(id),
    region_id INTEGER REFERENCES region(id),
    iso_id INTEGER REFERENCES iso(id)
);

Step 6: Transfer Data to the unesco Table
INSERT INTO unesco (name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id)
SELECT name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id
FROM unesco_raw;

Part – 3 no need to create new tables, just alter table

DROP TABLE album CASCADE;
CREATE TABLE album (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE track CASCADE;
CREATE TABLE track (
    id SERIAL,
    title TEXT, 
    artist TEXT, 
    album TEXT, 
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    count INTEGER, 
    rating INTEGER, 
    len INTEGER,
    PRIMARY KEY(id)
);

DROP TABLE artist CASCADE;
CREATE TABLE artist (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE tracktoartist CASCADE;
CREATE TABLE tracktoartist (
    id SERIAL,
    track VARCHAR(128),
    track_id INTEGER REFERENCES track(id) ON DELETE CASCADE,
    artist VARCHAR(128),
    artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
    PRIMARY KEY(id)
);

\copy track(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;

INSERT INTO album (title) SELECT DISTINCT album FROM track;
UPDATE track SET album_id = (SELECT album.id FROM album WHERE album.title = track.album);
insert into tracktoartist(track,artist) select distinct title,artist from track;
insert into artist(name)select distinct artist from track;
update tracktoartist set track_id = (select track.id from track where track.title = tracktoartist.track);
update tracktoartist set artist_id = (select artist.id from artist where artist.name=tracktoartist.artist);
alter table track drop column album;
alter table track drop column artist;
alter table tracktoartist drop column track;
alter table tracktoartist drop column artist;
