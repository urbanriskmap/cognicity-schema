-- Function: alerts.compute()

-- DROP FUNCTION alerts.compute();

CREATE OR REPLACE FUNCTION alerts.compute()
  RETURNS trigger AS
$BODY$
DECLARE
alert RECORD;
BEGIN
  --SELECT into report_id, report_area c.PKEY, c.tags->>'instance_region_code' FROM cognicity.all_reports c, grasp.reports g WHERE c.fkey = g.pkey AND c.source = 'grasp' AND g.card_id = NEW.card_id;

  --PERFORM pg_notify('watchers', '{"' || TG_TABLE_NAME || '":{"pkey":"' || NEW.pkey || '", "username": "'|| NEW.username ||'", "network": "' || NEW.network || '", "language": "'|| NEW.language ||'", "report_id": "' || report_id ||'", "report_impl_area": "' || report_area || '"}}' );
  --RETURN new;

  FOR alert IN SELECT d.card_id, d.username, d.network, d.language, ST_DISTANCE(ST_TRANSFORM(NEW.the_geom, 32748), ST_TRANSFORM(b.the_geom, 32748)) FROM cognicity.all_reports b, grasp.reports c, grasp.cards d WHERE ST_DWITHIN(ST_TRANSFORM(NEW.the_geom, 32748), ST_TRANSFORM(b.the_geom, 32748), 1000) AND 22005 <> b.pkey AND b.source = 'grasp' AND b.fkey = c.pkey AND d.card_id = c.card_id LOOP

  -- this should be swapped out for query on alerts.locations  WHERE alerts.users.subscribed === TRUE

    PERFORM pg_notify('alerts', alert::text);

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

-- Subscribe a GRASP user to alerts service
CREATE OR REPLACE FUNCTION alerts.register()
  RETURNS trigger AS
    $BODY$
      DECLARE
      --something
      userkey BIGINT;
      BEGIN

      INSERT INTO alerts.users (username, network, subscribed) SELECT c.username, c.network, c.language FROM grasp.cards c WHERE c.card_id = NEW.card_id ON CONFLICT c.username DO NOTHING RETURNING pkey INTO userkey;

      INSERT INTO alerts.locations (userkey, location) VALUES (userkey, NEW.the_geom);

      RETURN NEW;
    END;
    $BODY$
      LANGUAGE plpgsql VOLATILE
      COST 100;
    ALTER FUNCTION alerts.register()
      OWNER TO postgres;

CREATE TRIGGER register_grasp_users_alerts_trigger
  BEFORE INSERT ON grasp.reports
  FOR EACH ROW
  EXECUTE PROCEDURE alerts.register();
