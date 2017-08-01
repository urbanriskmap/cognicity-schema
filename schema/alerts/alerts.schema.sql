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
  the_geom GEOMETRY(Point,4326)
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
