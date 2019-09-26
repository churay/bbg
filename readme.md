# bbg #

`bbg` (short for **b**etter **b**ubble **g**ame) is a simple game prototype
written in Lua with [LÖVE](https://love2d.org/). This prototype is meant to
imitate the base game rules found in the [Puzzle Bobble/Bust-a-Move series]
(https://en.wikipedia.org/wiki/Puzzle_Bobble).

## Demo ##

!['bbg' demo](https://github.com/churay/bbg/raw/master/doc/demo.gif)

## Install ##

If you're running on an Ubuntu flavor of Linux, you can install all of this
project's dependencies with the following commands:

1. `sudo apt-get install make`: Install build tools.
1. `sudo apt-get install love`: Install Lua code environment.

If you're running on a different flavor of Linux that has a package manager,
simply search-and-replace `apt-get` in the above commands with your distribution's
package management application.

Once these packages are installed, running the application is as simple as
navigating to this project's base directory and running `make`.

## Test ##

To run the internal regression tests for this project, you need to install Lua's
package manager [`luarocks`](https://luarocks.org/) and the Lua testing library
[`busted`](https://olivinelabs.com/busted/) with these commands:

1. `sudo apt-get install luarocks`: Install the Lua package manager.
1. `sudo luarocks install busted`: Install the testing library.

After these packages are installed, run `make specs` to execute the test cases.
