Multi part solution:

We need to upload solution.php to the level2 server. It's been crafted such that there will be a string in it that will match /`[^\w]AUTHENTICATED[^\w]*$/` even as part of a bigger string. That's easy enough as long as the response has a line ending after AUTHENTICATED. We just repeat ourselves to make sure that php doesn't strip line endings.

Then we need `host` to match `/^localhost$/` but for the pingback server to actually be level2. We do that by submitting

```
http://localhost:4568/?pingback=http%3A//level2%3A8000/uploads/solution.php
```

That submits to localhost, but uses the GET parameters to set `pingback`. `params` in ruby is a merging of params from GET and POST, so we end up with:

```
pingback: htp://level2:8000/uploads/solution.php
usernme: level05
password: foo
```

So in summary: the pingback server gets a form submission that causes it to ping itself. During the second request the merging of GET and POST params causes it to actually pingback level2 server, which we have seeded with a response that causes the ultimate response to match the authentication regular expression.

Then we're authenticated as `level05`, and we have a host of `localhost`, so we get the password to level06.


