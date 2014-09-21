SequelPad
=========

Like LINQPad, but for Ruby and Sequel.

Overview
--------

SequelPad is essentially just a GUI wrapped around a Ruby interpreter, standard library, and the Sequel gem. You can connect to a database, run a script, and SequelPad will display the results in a table for you. [Sequel](http://sequel.jeremyevans.net/) offers conventient mechanisms for database queries, updates, and reflection. However, having the full power of the Ruby language and standard library means you can do much more than just query the database. For example, if your database contained a collection of hostnames, you could `require 'resolv'` and run DNS lookups on each hostname from within SequlPad. That's just one idea, but there's [plenty more](http://ruby-doc.org/stdlib-2.0.0/) you could do with it. It's also a nice alternative to IRB for doing some quick exploratory programming.

Building
--------

This project has only just begun, and there is no binary release yet available. However, you can use the supplied Rakefile to build from scratch. You will also need pre-built copies of Ruby 2.0 (does not currently work with 2.1), wxWidgets 3.0, and [rubydo](https://github.com/jbreeden/rubydo). After updating the Rakefile to have the correct paths for its dependencies on your local machine, just run `rake debug:build`.

If you're building on Windows, I recommend [RubyInstaller](https://github.com/oneclick/rubyinstaller) and TDM-64 >= 4.7.1. Their github page has detailed infromation, but all you need to do is download the repo and run `rake ruby20 DKVER=tdm-64-4.7.1`.
