

# Stripe Capture The Flag 2 in Docker

This is a fork of Stripe's 2012 web security capture the flag, with the following additions:

 - Each level as a docker container
 - Docker-Compose orchestration
 - A Go proxy service manage game state

This is a learning project, so design decisions reflect a desire to experiment.

The web has changed a lot since 2012, but a set of exercises like these still address many of the most common attacks on the internet today, and it's pretty fun to think like an attacker.

## A learning project

I put this together as part of an exercise in learning the Go programming language, and ended up learning a lot of other things too. As such, many design decisions were taken with experimentation in mind. The code is available in a github repo that aims to give a brief tour of these things.

## Getting started

The game takes place across a number of web services orchestrated by docker-compose. To run this locally on your machine, add the following to your `/etc/hosts` file so that each host is addressable in a consistent way.

```
127.0.0.1 stripe-ctf level0-stripe-ctf level1-stripe-ctf level2-stripe-ctf level3-stripe-ctf level4-stripe-ctf level5-stripe-ctf level6-stripe-ctf level7-stripe-ctf level8-stripe-ctf
```

Run the game:

```
docker-compose up
```

Visit [http://stripe-ctf:8000/](http://stripe-ctf:8000/) in your browser and start [_hacking_]([https://giphy.com/search/hacking](https://giphy.com/search/hacking)). If you get stuck, OWASP is a great resource. If you're still stuck, or just want to browse, a number of people have written up solutions, including here in the `solutions` directory.


To reset the game:

```
docker-compose kill
docker-compose rm
docker volume prune
```

To run in development (with hot reloading):

```
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up
```
