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
  subscribed BOOLEAN,
  alert_log JSONB,
  the_geom GEOMETRY(Point,4326),
  UNIQUE (userkey, the_geom)
);

-- Add a GIST spatial index
CREATE INDEX gix_alert_locations ON alerts.locations USING gist (the_geom);
