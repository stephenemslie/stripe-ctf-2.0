<?php

$forbid = [
  '/^\/ctf-halt.sh/',
  '/^\/ctf-install.sh/',
  '/^\/ctf-run.sh/',
  '/^\/level02-password.txt/',
  '/^\/secret-combination.txt/'
];

if (
  file_exists($_SERVER['SCRIPT_FILENAME']) &&
  # Make sure we're not letting people read secrets directly.
  !current(array_filter($forbid, function($element) { return preg_match($element, $_SERVER['PHP_SELF']); }))
) {
  // Serve the requested resource as-is.
  return false;
} else {
  include_once 'index.php';
}
