Gem::Specification.new do |s|
  s.name = "openurl"
  s.version = "1.0.0"

  s.authors = ["Jonathan Rochkind", "Ross Singer"]
  s.email = ["rochkind@jhu.edu", "rossfsinger@gmail.com"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = Dir.glob("{lib,test}/**/*")

  s.homepage = "https://github.com/openurl/openurl"
  s.require_paths = ["lib"]
  s.summary = "a Ruby library to create, parse and use NISO Z39.88 OpenURLs"

  s.add_development_dependency "bundler", "~> 1.6"
  s.add_development_dependency "rake"

  # currently needs 'marc' becuase of it's inclusion
  # of the marc referent format, sorry.Should make
  # this optional.
  s.add_dependency "marc"
  # backfill of String#scrub -- for encoding safety in reading/parsing kev -- in ruby pre 2.1
  s.add_dependency "scrub_rb", "~> 1.0"
end
