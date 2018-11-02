ALTER TABLE cognicity.local_areas ADD COLUMN attributes json;
UPDATE cognicity.local_areas SET attributes = ('{"district_id":' || district_id || '}')::json;
ALTER TABLE cognicity.local_areas DROP COLUMN district_id;