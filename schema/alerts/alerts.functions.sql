-- Function: alerts.compute()
-- Determine whether alert locations are within radius of new report
CREATE OR REPLACE FUNCTION alerts.compute()
  RETURNS trigger AS
$BODY$
DECLARE
alert RECORD; -- store alert location
BEGIN
  -- Get any alert locations which are within range of the new report and issue a notification
  FOR alert IN SELECT locations.pkey as location_key, locations.userkey, NEW.pkey as report_key, ST_DISTANCE(NEW.the_geom::geography, locations.the_geom::geography) as alerting_distance, locations.alert_log FROM alerts.locations WHERE ST_DWITHIN(NEW.the_geom::geography, locations.the_geom, 5000)
  LOOP -- Loop locations and issue alert
    PERFORM pg_notify('alerts', LEFT(row_to_json(alert)::text, 7999)); -- crop payload to max of 8000 bytes (UTF8 1 char = 1 byte)
 END LOOP;
 RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION alerts.compute()
  OWNER TO postgres;

-- Trigger an alert
CREATE TRIGGER watch_reports_alerts_trigger
  AFTER UPDATE ON cognicity.all_reports
  FOR EACH ROW
  EXECUTE PROCEDURE alerts.compute();
