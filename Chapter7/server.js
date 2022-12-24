let connect = require('connect');
let serveStatic = require('serve-static');

connect()
  .use(serveStatic(__dirname + '/'))
  .listen(7500, function () {
    console.log('localhost:7500');
  });
