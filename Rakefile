require_relative 'lib/soql-parser/version'
require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

GENERATED_PARSER = 'lib/soql-parser/parser.racc.rb'
GENERATED_LEXER = 'lib/soql-parser/parser.rex.rb'

file GENERATED_LEXER => 'lib/soql-parser/parser.rex' do |t|
  sh "bundle exec rex -o #{t.name} #{t.prerequisites.first}"
end

file GENERATED_PARSER => 'lib/soql-parser/parser.racc' do |t|
  sh "bundle exec racc -o #{t.name} #{t.prerequisites.first}"
end

task :parser => [GENERATED_LEXER, GENERATED_PARSER]

# Make sure the parser's up-to-date when we test.
Rake::Task['test'].prerequisites << :parser
task :default => :test
