# Level 4

The Karma Trader is the world's best way to reward people for good deeds. You
can sign up for an account, and start transferring karma to people who you
think are doing good in the world. In order to ensure you're transferring karma
only to good people, transferring karma to a user will also reveal your
password to him or her.

The very active user `karma_fountain` has infinite karma, making it a ripe
account to obtain (no one will notice a few extra karma trades here and there).
The password for `karma_fountain`'s account will give you access to Level 5.

For the purposes of this test the `karma_fountain` user is active via the web
interface every 30 seconds, using a script, [CasperJS][1], and [PhantomJS][2] to
simulate human activity.

# To Run

* Run `ctf-run 4` to start the server on port 4567, and start the activities of
the `karma_fountain` user.
* Go to [http://192.168.57.2:4567](http://192.168.57.2:4567) in your browser.
* Run `ctf-halt 4` to stop the server and the `karma_fountain` user
activities.

[1]: http://casperjs.org
[2]: http://phantomjs.org
