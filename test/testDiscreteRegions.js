const test = require('unit.js');

export default (db, instances) => {
  describe('Instance regions should be discrete geographies: ',
  (done) => {
    it('Checks overlapping region boundaries',
    (done) => {
      // if there are overlapping instance regions
      // then we might not pick the correct instance_region_code
      // which means we won't show it on the map!
      // therefore instance_regions cannot overlap!

      // Do a pairwise intersection comparison
      let query = `SELECT is_intersecting.name,
      COUNT(is_intersecting.bool) as intersections
      FROM (
        SELECT a.name, ST_Intersects(a.the_geom, b.the_geom) as bool
        FROM cognicity.instance_regions a, cognicity.instance_regions b
        WHERE a.code != b.code
      ) is_intersecting
      WHERE is_intersecting.bool = true
      GROUP BY is_intersecting.name`;

      db.any(query, null)
        .then((data) => {
          if (data.length) {
            for (const region of data) {
              console.log('Region ' + region.name + ' intersects with '
              + region.intersections + ' other region(s)');
            }
          }

          test.value(data.length).is(0);
          done();
        })
        .catch((error) => test.fail(error));
    });
  });
};
