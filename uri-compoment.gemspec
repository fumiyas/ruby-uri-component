# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "uri/component/version"

Gem::Specification.new do |s|
  s.name        = "uri-component"
  s.version     = URI::Component::VERSION
  s.authors     = ["SATOH Fumiyasu"]
  s.email       = ["fumiyas@osstech.co.jp"]
  s.homepage    = ""
  s.summary     = %q{URI::Component::* classes}
  s.description = %q{Handle the components of the URI as an object}

  s.rubyforge_project = "uri-component"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

