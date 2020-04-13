# Level 6

After Karma Trader from Level 4 was hit with massive karma inflation
(purportedly due to someone flooding the market with massive quantities of
karma), the site had to close its doors. All hope was not lost, however, since
the technology was acquired by a real up-and-comer, Streamer. Streamer is the
self-proclaimed most steamlined way of sharing updates with your friends.

The Streamer engineers, realizing that security holes had led to the demise of
Karma Trader, have greatly beefed up the security of their application. Which
is really too bad, because you've learned that the holder of the password to
access Level 7, `level07-password-holder`, is the first Streamer user.

In addition, `level07-password-holder` is taking a lot of precautions: his or
her computer has no network access besides the Streamer server itself, and his
or her password is a complicated mess, including quotes and apostrophes and the
like.

Fortunately for you, the Streamer engineers have decided to open-source their
application so that other people can run their own Streamer instances.

# To Run

* Run `ctf-run 6` to start the server on port 4569, and start the activities of
the `level07-password-holder` user.
* Go to [http://192.168.57.2:4569](http://192.168.57.2:4569) in your browser.
* Run `ctf-halt 6` to stop the server and the `level07-password-holder` user
activities.

## `level07-password-holder`

We used [CapserJS][1] on top of [PhantomJS][2] to power the
`level07-password-holder` user. It is active every 30 seconds or so.

[1]: http://casperjs.org
[2]: http://phantomjs.org
