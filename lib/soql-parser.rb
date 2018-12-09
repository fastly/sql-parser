module SOQLParser

  require 'strscan'
  require 'date'

  require 'racc/parser'

  require_relative 'soql-parser/version'
  require_relative 'soql-parser/statement'
  require_relative 'soql-parser/soql_visitor'
  require_relative 'soql-parser/parser.racc.rb'

end
