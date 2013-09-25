require File.expand_path("../lib/grib/version", __FILE__)

Gem::Specification.new do |s|
  s.version     = Grib::VERSION

  s.name        = "grib"
  s.summary     = "Git RevIewBoard script"
  s.description = "Wraps reviewboard's post-review command line tool to remember previous invocations, and do some basic sanity checks prior to posting a review"

  s.authors     = ["Dan Carmon"]
  s.email       = "dan.carmon@trusteer.com"
  s.homepage    = "http://dancar.github.com/grib"
  s.license     = "MIT"

  s.files       =  []
  s.files       += Dir["lib/**/*.rb", "tests/**/*.rb"]
  s.files       += Dir["[A-Z]*"]

  s.bindir      = "bin"
  s.executables = Dir["bin/*"].map { |e| File.basename(e) }
end
