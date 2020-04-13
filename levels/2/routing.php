<?php

$forbid = [
  '/^\/password.txt/'
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
