lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'soql-parser/version'

Gem::Specification.new do |s|
  s.name          = 'soql-parser'
  s.version       = SOQLParser::VERSION
  s.authors       = ['Dray Lacy', 'Louis Mullie']
  s.email         = ['dray@izea.com', 'louis.mullie@gmail.com']
  s.homepage      = 'https://github.com/louismullie/soql-parser'
  s.summary       = %q{ Ruby library for parsing and generating SOQL statements }
  s.description   = %q{ A Racc-based Ruby parser and generator for SOQL statements }
  s.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  s.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'racc', '1.4.14'

  s.add_development_dependency 'rexical'
  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
end
