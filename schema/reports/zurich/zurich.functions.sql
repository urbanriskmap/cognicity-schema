-- Create Trigger Function to update all_reports table
CREATE OR REPLACE FUNCTION zurich.update_all_reports_from_zurich()
  RETURNS trigger AS
$BODY$
	BEGIN
		IF (TG_OP = 'UPDATE') THEN
			INSERT INTO cognicity.all_reports (fkey, created_at, text, source, disaster_type, lang, url, image_url, title, the_geom) SELECT NEW.pkey, NEW.created_at, NEW.text, 'zurich', NEW.disaster_type, NEW.lang, NEW.url, NEW.image_url, NEW.title, NEW.the_geom;
			RETURN NEW;
		ELSIF (TG_OP = 'INSERT') THEN
			INSERT INTO cognicity.all_reports (fkey, created_at, text, source, disaster_type, lang, url, image_url, title, the_geom) SELECT NEW.pkey, NEW.created_at, NEW.text, 'zurich', NEW.disaster_type, NEW.lang, NEW.url, NEW.image_url, NEW.title, NEW.the_geom;
			RETURN NEW;
		END IF;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION zurich.update_all_reports_from_zurich()
  OWNER TO postgres;

CREATE TRIGGER trigger_update_all_reports_from_zurich
  BEFORE INSERT OR UPDATE
  ON zurich.reports
  FOR EACH ROW
  EXECUTE PROCEDURE zurich.update_all_reports_from_zurich();
