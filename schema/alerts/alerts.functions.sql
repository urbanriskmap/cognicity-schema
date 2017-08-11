-- Function: alerts.compute()
-- Determine whether alert locations are within radius of new report
CREATE OR REPLACE FUNCTION alerts.compute()
  RETURNS trigger AS
$BODY$
DECLARE
alert RECORD; -- store alert location
send_flag BOOLEAN; -- send alert flag
BEGIN
  -- Get all data in query, and then test for conditions
  FOR alert IN SELECT locations.pkey as location_key, locations.userkey, NEW.pkey as report_key, users.username as username, users.network as network, ST_DISTANCE(NEW.the_geom::geography, locations.the_geom::geography) AS alerting_distance, locations.alert_log FROM alerts.locations, alerts.users WHERE ST_DWITHIN(NEW.the_geom::geography, locations.the_geom, 5000) AND locations.subscribed = TRUE AND (locations.last_bubble IS NULL OR locations.last_bubble >= now() + interval '5 minutes') AND locations.userkey = users.pkey
  LOOP -- Loop locations and issue alert

    send_flag := True; -- Default to send alert

    -- Check that the incoming report is not from the alerting user
    IF NEW.source = 'grasp' AND (SELECT username = alert.username AND network = alert.network FROM grasp.cards as cards, grasp.reports as reports WHERE cards.card_id  = reports.card_id AND reports.pkey = NEW.fkey)  THEN
        send_flag := False; -- Disable self reporting - DO NOT SEND ALERT
    END IF;

    IF send_flag = True THEN
      --INSERT INTO last_bubble
      PERFORM pg_notify('alerts', LEFT(row_to_json(alert)::text, 7999)); -- crop payload to max of 8000 bytes (UTF8 1 char = 1 byte)
    END IF;

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
