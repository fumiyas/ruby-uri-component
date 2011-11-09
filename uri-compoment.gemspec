# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "uri/component/version"

Gem::Specification.new do |s|
  s.name        = "uri-component"
  s.version     = URI::Component::VERSION
  s.authors     = ["SATOH Fumiyasu"]
  s.email       = ["fumiyas@osstech.co.jp"]
  s.homepage    = "https://github.com/fumiyas/ruby-uri-component"
  s.summary     = %q{URI::Component::* classes}
  s.description = %q{Handle URI components as an object}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

