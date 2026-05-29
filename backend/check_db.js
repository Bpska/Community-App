const db = require('./db');
db.query('SELECT name FROM communities').then(r => {
  console.log(r.rows);
  process.exit(0);
}).catch(e => {
  console.error(e);
  process.exit(1);
});
