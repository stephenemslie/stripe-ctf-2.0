# Level 5

Many attempts have been made at creating a federated identity system for the
web (see [OpenID][1], for example). However, none of them have been successful.
Until today.

The DomainAuthenticator is based off a novel protocol for establishing
identities. To authenticate to a site, you simply provide it username,
password, and pingback URL. The site posts your credentials to the pingback
URL, which returns either "AUTHENTICATED" or "DENIED". If "AUTHENTICATED", the
site considers you signed in as a user for the pingback domain.

We've been using the Stripe CTF DomainAuthenticator instance it to distribute
the password to access Level 6. If you could only somehow authenticate as a
user of a level05 machine...

To avoid nefarious exploits, the machine hosting the DomainAuthenticator has
very locked down network access. It can only make outbound requests to other
local servers. Though, you've heard that someone forgot to internally firewall
off the high ports from the Level 2 server.

NB: During the actual Stripe CTF, we allowed full network access from the
Level 5 server to the Level 2 server. Here both servers are running on the same
machine, but the effects are the same.

# To Run

* Run `ctf-run 5` to start the server on port 4568.
* Run `ctf-run 2` to start the level 2 server on port 7000.
* Go to [http://192.168.57.2:4568](http://192.168.57.2:4568) in your browser.
* Run `ctf-halt 5; ctf-halt 2` to stop the servers.

[1]: http://openid.net/
