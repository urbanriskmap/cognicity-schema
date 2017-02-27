-- Schema for zurich data
CREATE SCHEMA zurich;

-- Create table for zurich reports
CREATE TABLE zurich.reports
(
  pkey bigserial NOT NULL,
  contribution_id bigint NOT NULL UNIQUE,
  database_time timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone,
  disaster_type character varying NOT NULL,
  text character varying,
  lang character varying,
  url character varying,
  image_url character varying,
  title character varying,
  city character varying,
  CONSTRAINT pkey_zurich PRIMARY KEY (pkey)
);

-- Add Geometry column to tweet_reports
SELECT AddGeometryColumn ('zurich','reports','the_geom',4326,'POINT',2);

-- Add GIST spatial index
CREATE INDEX gix_zurich_reports ON zurich.reports USING gist (the_geom);

-- Create table for zurich report users
CREATE TABLE zurich.users
(
  pkey bigserial,
  user_hash character varying UNIQUE,
  reports_count integer	,
  CONSTRAINT pkey_zurich_users PRIMARY KEY (pkey)
);
