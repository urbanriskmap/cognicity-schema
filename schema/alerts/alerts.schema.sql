-- Schema for alerting support
CREATE schema alerts;

-- Table for users
CREATE TABLE alerts.users (
  pkey BIGSERIAL PRIMARY KEY,
  username VARCHAR,
  network VARCHAR,
  language VARCHAR,
  subscribed BOOLEAN,
  UNIQUE (username, network)
);

-- Table for user alerting locations
CREATE TABLE alerts.locations (
  pkey BIGSERIAL PRIMARY KEY,
  userkey BIGINT REFERENCES alerts.users(pkey),
  the_geom GEOMETRY(Point,4326),
  UNIQUE (userkey, the_geom)
);

-- Add a GIST spatial index
CREATE INDEX gix_alert_locations ON alerts.locations USING gist (the_geom);

-- Table to log alerts issued to users by location
CREATE TABLE alerts.log (
  pkey BIGSERIAL PRIMARY KEY,
  location_key BIGSERIAL REFERENCES alerts.locations(pkey),
  log_time TIMESTAMP WITH TIME ZONE DEFAULT now(),
  log_metadata JSON
);

-- SAMPLE DATA FOR Testing
INSERT INTO alerts.users(username, network, language, subscribed) VALUES
('tomas', 'twitter', 'en', TRUE);

INSERT INTO alerts.users(username, network, language, subscribed) VALUES
('adi', 'twitter', 'en', TRUE);

INSERT INTO alerts.locations (userkey, the_geom) VALUES
(1, ST_GeomFromText('POINT(1 1)',4326));

INSERT INTO alerts.locations (userkey, the_geom) VALUES
(1, ST_GeomFromText('POINT(1 2)',4326));

INSERT INTO alerts.locations (userkey, the_geom) VALUES
(2, ST_GeomFromText('POINT(1 3)',4326));

INSERT INTO alerts.log (location_key, log_metadata) VALUES
(1, '{"value":"key"}');
