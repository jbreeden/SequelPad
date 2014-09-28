# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bigdecimal"
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kenta Murata", "Shigeo Kobayashi"]
  s.date = "2012-02-19"
  s.description = "This library provides arbitrary-precision decimal floating-point number class."
  s.email = "mrkn@mrkn.jp"
  s.extensions = ["extconf.rb"]
  s.files = ["rubyinstaller-master/sandbox/ruby_2_0/ext/bigdecimal/extconf.rb", "rubyinstaller-master/sandbox/ruby_2_0/ext/bigdecimal/lib/bigdecimal/jacobian.rb", "rubyinstaller-master/sandbox/ruby_2_0/ext/bigdecimal/lib/bigdecimal/ludcmp.rb", "rubyinstaller-master/sandbox/ruby_2_0/ext/bigdecimal/lib/bigdecimal/math.rb", "rubyinstaller-master/sandbox/ruby_2_0/ext/bigdecimal/lib/bigdecimal/newton.rb", "rubyinstaller-master/sandbox/ruby_2_0/ext/bigdecimal/lib/bigdecimal/util.rb", "rubyinstaller-master/sandbox/ruby_2_0/ext/bigdecimal/sample/linear.rb", "rubyinstaller-master/sandbox/ruby_2_0/ext/bigdecimal/sample/nlsolve.rb", "rubyinstaller-master/sandbox/ruby_2_0/ext/bigdecimal/sample/pi.rb", "extconf.rb"]
  s.homepage = "http://www.ruby-lang.org"
  s.require_paths = ["."]
  s.rubygems_version = "2.0.14"
  s.summary = "Arbitrary-precision decimal floating-point number library."
end
