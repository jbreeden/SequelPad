SequelPad
=========

Like LINQPad, but for Ruby and Sequel.

![SequlPad Screenshot](/images/SequelPad.PNG?raw=true)

Overview
--------

SequelPad is essentially just a GUI wrapped around a Ruby interpreter, standard library, and the [Sequel](http://sequel.jeremyevans.net/) gem. You can connect to a database, run a script, and SequelPad will display the results in a table for you.

When you connect to a database in SequelPad, the global `$db` will be defined with the corresponding Sequel::Database object.

On top of the standard Sequel api, SequelPad adds some conveniences to make scripting easier. For exaple, to get a Dataset for a table named "city" in the schema "public", instead of `$db[:public__city]`, you can just use `public.city`, or even just `city` if public is the default schema on your database. In the context of a SequelPad script, `method_missing` is utilized to try to figure out what you mean. So, if you type a name that is a match for a schema, we'll assume that's what you want. If you call a method on that schema object that's a match for a table or view within the schema, you'll get a dataset for that table or view. All of these matches are case insensitive, which can really speed up writing one-off queries.

[Sequel](http://sequel.jeremyevans.net/) offers conventient mechanisms for database queries, updates, and reflection. However, having the full power of the Ruby language and standard library means you can do much more than just query the database. For example, if your database contained a collection of hostnames, you could `require 'resolv'` and run DNS lookups on each hostname from within SequelPad. That's just one idea, but there's [plenty more](http://ruby-doc.org/stdlib-2.0.0/) you could do with it.

Building
--------

This project has only just begun, and there is no binary release yet available. However, you can use the supplied Rakefile to build from scratch. You will also need pre-built copies of Ruby 2.0 (does not currently work with 2.1), wxWidgets 3.0, and [rubydo](https://github.com/jbreeden/rubydo). After updating the Rakefile to have the correct paths for its dependencies on your local machine, just run `rake debug:build`.

If you're building on Windows, I recommend [RubyInstaller](https://github.com/oneclick/rubyinstaller) and TDM-64 >= 4.7.1. Their github page has detailed infromation, but all you need to do is download the repo and run `rake ruby20 DKVER=tdm-64-4.7.1`.

LICENSE
-------

(The MIT License)

Copyright (c) 2014 Jared Breeden

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
