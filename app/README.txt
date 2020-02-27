How is state stored?

  - sqlite
    - session
      - level
  - file on disk

Docker control or http proxy?

Docker control:

  - Port forwarding disabled by default. CTF app unlocks a level and enables port forwarding.

 Kubernetes control:

  - Same sort of thing, but services are defined in kubernetes and the app enables port forwarding when a level is unlocked.

 Port forwarding:

  - This would work by disabling all port forwarding directly to services. Communication with the levels happens through the ctf app.
  - Because we can't set multiple subdomain aliases to the ctf service, we would need to host each level on /levels/0, /levels/1, etc.
  - We would then either have to:
    1. strip `^levels/[\d][/]?` from the path, leaving us with whatever the levels themselves expect.
    2. leave the full path intact

  - if 1., then using XSS with the browser containers would be too tricky. They communicate directly with the container, so they wouldn't need the `levels` prefix. This would make it pointlessly more difficult to complete the game.
  - so if 1 then the browser should also communicate through the proxy, which means that either each level is globally locked/unlocked, or the internal browser needs access to the same levels as the user.
  - this is clearly simpler if we do global lock/unlock.
  - if 2. then the internal services also assume that you'll need that prefix to acces them. That's probably best because then they have internally consistent links.

  I don't know what the right answer to this is, so I'm going to try port forwarding, because it give me the chance to play around with Go in a way that seems appropriate. Not necessarily the best solution, but it should work at least.


What method will we use to lock/unlock levels?
----------------------------------------------

methods could be global or session based

Session based create state issues, so let's go global?
