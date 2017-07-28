-- Computes alerts from existing report locations when new report received
CREATE OR REPLACE FUNCTION alerts.compute() RETURNS trigger AS $$
DECLARE
alert RECORD;
BEGIN
  FOR alert IN EXECUTE 'SELECT NEW.pkey, NEW.report_data, NEW.created_at,  d.card_id, d.username, d.network, d.language, ST_DISTANCE(ST_TRANSFORM(NEW.the_geom, 32748), ST_TRANSFORM(b.the_geom, 32748)) FROM cognicity.all_reports b, grasp.reports c, grasp.cards d WHERE ST_DWITHIN(ST_TRANSFORM(NEW.the_geom, 32748), ST_TRANSFORM(b.the_geom, 32748), 1000) AND 22005 <> b.pkey AND b.source = "grasp" AND b.fkey = c.pkey AND d.card_id = c.card_id' LOOP

    PERFORM pg_notify('watchers', alert.report_data)

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER watch_reports_alerts_trigger
  AFTER UPDATE ON cognicity.all_reports
  FOR EACH ROW
  EXECUTE PROCEDURE alerts.compute();
