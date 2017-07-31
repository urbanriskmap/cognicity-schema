-- Schema for alerting support
CREATE schema alerts;

-- Table for users
CREATE TABLE alerts.users (
  pkey BIGSERIAL PRIMARY KEY,
  username VARCHAR UNIQUE,
  network VARCHAR,
  language VARCHAR,
  subscribed BOOLEAN
);

-- Table for user alerting locations
CREATE TABLE alerts.locations (
  pkey BIGSERIAL PRIMARY KEY,
  userkey BIGINT REFERENCES alerts.users(pkey),
  location GEOMETRY(Point,4326)
);

-- Add a GIST spatial index
CREATE INDEX gix_alert_locations ON alerts.locations USING gist (the_geom);
