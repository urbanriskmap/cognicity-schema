CREATE SCHEMA outreach;

-- Outreach content table
-- Holds the adCreative
CREATE TABLE outreach.fb_metadata
(
  id bigserial NOT NULL,
  fb_id bigint NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  properties JSONB NOT NULL,
  CONSTRAINT outreach_fb_metadata_pkey PRIMARY KEY (id)
);

-- Outreach data table
-- Has facebook insight information
CREATE TABLE outreach.fb_data
(
  id bigserial NOT NULL,
  f_key bigint NOT NULL,
  fb_id bigint NOT NULL,
  created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  properties JSONB NOT NULL,
  CONSTRAINT outreach_fb_data_pkey PRIMARY KEY (id),
  CONSTRAINT outreach_fb_data_fkey FOREIGN KEY (f_key)
    REFERENCES outreach.fb_metadata (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- Add a geometry column
SELECT AddGeometryColumn('outreach', 'fb_data', 'the_geom', 4326, 'POLYGON', 2);
ALTER TABLE outreach.data ALTER COLUMN the_geom SET NOT NULL;

-- Add a GIST spatial index
CREATE INDEX gix_outreach_fb_data ON outreach.fb_data USING gist(the_geom);
