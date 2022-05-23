Blocks
==============

You can read more about the development of this project [here](http://metaphysicaldeveloper.wordpress.com/2011/12/20/implementing-minecraft-in-webgl/)

Compiling
----

It requires Coffeescript 1.1.3+ (version 1.6.2+ for [source maps](http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/)), and node.js 0.6+

To compile, run:

    cake c

The command above will also watch for any changes. If you just wanna compile the files, run:

    cake compile

If you wanna see the game locally, you need python, and you run 

    cake server

which simply runs

    python -m SimpleHTTPServer

enabling you to open the game on [http://localhost:8000/docs/](http://localhost:8000/docs/)


