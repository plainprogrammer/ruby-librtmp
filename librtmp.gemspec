# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "librtmp/version"

Gem::Specification.new do |s|
  s.name        = "librtmp"
  s.version     = Librtmp::VERSION
  s.authors     = ["James Thompson"]
  s.email       = ["james@plainprograms.com"]
  s.homepage    = "http://github.com/plainprograms/ruby-librtmp"
  s.summary     = %q{Wraps the librtmp library from rtmpdump with Ruby}
  s.description = %q{Provides a wrapper for the librtmp library in Ruby to allow use of the RTMP streaming protocols}

  s.rubyforge_project = "librtmp"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "ffi"
end
