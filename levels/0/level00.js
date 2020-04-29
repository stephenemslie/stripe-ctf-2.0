var path = require("path");

var express = require("express"), // Web framework
  mu = require("mu2"), // Mustache.js templating
  sqlite3 = require("sqlite3"), // SQLite (database) driver
  bodyParser = require("body-parser"); // Body parsing middleware

// Look for templates in the current directory
mu.root = __dirname;

// Set up the DB
var db = new sqlite3.Database(path.join(__dirname, "level00.db"));
db.run(
  "CREATE TABLE IF NOT EXISTS secrets (" +
    "key varchar(255)," +
    "secret varchar(255)" +
    ")"
);

// Create the server
var app = express();
app.use(bodyParser.urlencoded({ extended: false }));

function renderPage(res, variables) {
  var stream = mu.compileAndRender(
    path.join(__dirname, "level00.html"),
    variables
  );
  res.header("Content-Type", "text/html");
  stream.pipe(res);
}

app.get("/*", function(req, res) {
  var namespace = req.param("namespace");

  if (namespace) {
    var query = 'SELECT * FROM secrets WHERE key LIKE ? || ".%"';
    db.all(query, namespace, function(err, secrets) {
      if (err) throw err;

      renderPage(res, { namespace: namespace, secrets: secrets });
    });
  } else {
    renderPage(res, {});
  }
});

app.post("/*", function(req, res) {
  var namespace = req.body["namespace"];
  var secret_name = req.body["secret_name"];
  var secret_value = req.body["secret_value"];

  var query = 'INSERT INTO secrets (key, secret) VALUES (? || "." || ?, ?)';
  db.run(query, namespace, secret_name, secret_value, function(err) {
    if (err) throw err;

    res.header("Content-Type", "text/html");
    res.redirect(req.path + "?namespace=" + namespace);
  });
});

if (process.argv.length > 2) {
  var socket = process.argv[2];
  console.log("Starting server on UNIX socket " + socket);
  app.listen(socket);
} else {
  var port = parseInt(process.env.PORT || "3000");
  console.log(`Starting server on port ${port}`);
  app.listen(port);
}
