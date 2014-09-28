# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "test-unit"
  s.version = "2.0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shota Fukumori"]
  s.date = "2014-09-07"
  s.description = "This library implements test/unit compatible API on minitest. The test/unit means that test/unit which was bundled with Ruby 1.8."
  s.email = "sorah@tubusu.net"
  s.executables = ["testrb"]
  s.files = ["rubyinstaller-master/sandbox/ruby_2_0/lib/test/unit.rb", "rubyinstaller-master/sandbox/ruby_2_0/lib/test/unit/assertions.rb", "rubyinstaller-master/sandbox/ruby_2_0/lib/test/unit/parallel.rb", "rubyinstaller-master/sandbox/ruby_2_0/lib/test/unit/testcase.rb", "bin/testrb"]
  s.homepage = "http://www.ruby-lang.org"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.14"
  s.summary = "test/unit compatible API testing framework"
end
