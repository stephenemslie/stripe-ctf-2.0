# WaffleCopter

WaffleCopter is a new service delivering locally-sourced organic waffles hot
off of vintage waffle irons straight to your location using quad-rotor
GPS-enabled helicopters. The service is modeled after [TacoCopter][1], an
innovative and highly successful early contender in the airborne food delivery
industry. WaffleCopter is currently being tested in private beta in select
locations.

Your goal is to order one of the decadent Liège waffles, offered only to the
first premium subscribers of the service.

## The API

The WaffleCopter API is quite simple. All users have a secret API token that is
used to sign POST requests to `/v1/orders`. Parameters such as the waffle
product code and target GPS coordinates are encoded as if for a query string and
placed in the request body.

## The Client Code

You can use `client.py` to talk to the API, specifying an appropriate API
endpoint, user id, and secret key. The client requires the `requests` module,
which can be installed from pip with `pip install requests`. This is already
installed in the VM.

# To Run

* Run `ctf-run 7` to start the server on port 9233.
* Go to [http://192.168.57.2:9233](http://192.168.57.2:9233) in your browser.
* Run `ctf-halt 7` to stop the server.

[1]: http://tacocopter.com
