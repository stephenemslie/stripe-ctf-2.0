/**
 * @fileOverview Create the sqlite database holding the password.
 */

// Core.
var path = require("path");

// NPM.
var async = require("async");
var sqlite3 = require("sqlite3");
var uuid = require("uuid");

if (process.argv.length < 3) {
  throw new Error("Usage: node ctf-install.js <password>");
}

var password = process.argv[2];
var db;

async.series(
  {
    createDatabase: function(callback) {
      // Set up the DB.
      db = new sqlite3.Database(path.join(__dirname, "level00.db"), callback);
    },
    createTable: function(callback) {
      db.run(
        "CREATE TABLE IF NOT EXISTS secrets (" +
          "key varchar(255)," +
          "secret varchar(255)" +
          ")",
        [],
        callback
      );
    },
    insert: function(callback) {
      db.run(
        "INSERT INTO secrets (key, secret) values (?, ?)",
        [uuid.v4() + ".level-1-password", password],
        callback
      );
    }
  },
  function(error) {
    if (error) {
      throw error;
    }
  }
);
