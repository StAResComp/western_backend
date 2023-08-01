-- schema for catch data from Western Isles mobile app

-- devices have a unique ID string
DROP TABLE IF EXISTS devices CASCADE;
CREATE TABLE devices (
  device_id SERIAL PRIMARY KEY,
  device_string CHAR(16)
);

\i 'data.sql'

-- catch metadata
DROP TABLE IF EXISTS catch_md CASCADE;
CREATE TABLE catch_md (
  catch_id SERIAL PRIMARY KEY,
  device_id INTEGER REFERENCES devices (device_id) ON UPDATE CASCADE,
  string_num TEXT,
  lat NUMERIC(15, 12),
  lon NUMERIC(15, 12),
  time_stamp TIMESTAMP WITHOUT TIME ZONE,
  upload_time_stamp TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()
);

-- catch types
DROP TABLE IF EXISTS catch_types CASCADE;
CREATE TABLE catch_types (
  catch_type_id INTEGER PRIMARY KEY,
  catch_type VARCHAR(16)
);

INSERT INTO catch_types (catch_type_id, catch_type)
     VALUES (1, 'neph_small'),
            (2, 'neph_med'),
	    (3, 'neph_large'),
	    (4, 'neph_returned'),
	    (5, 'lobs_retained'),
	    (6, 'lobs_returned'),
	    (7, 'brown_retained'),
	    (8, 'brown_returned'),
	    (9, 'velvet_retained'),
	    (10,'velvet_returned'),
	    (11,'wrasse_retained'),
	    (12,'wrasse_returned');

-- catch details
DROP TABLE IF EXISTS catch_details CASCADE;
CREATE TABLE catch_details (
  catch_id INTEGER REFERENCES catch_md (catch_id) ON UPDATE CASCADE,
  catch_type_id INTEGER REFERENCES catch_types (catch_type_id) ON UPDATE CASCADE,
  quantity NUMERIC(7, 3),
  PRIMARY KEY (catch_id, catch_type_id)
);

