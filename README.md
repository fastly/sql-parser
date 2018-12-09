## soql-parser

A Ruby library for parsing and generating SOQL (Salesforce Object Query Language) statements.

### Features

  * Parse arbitrary SOQL strings into an AST (abstract syntax tree), which can
    then be traversed.

  * Allows your code to understand and manipulate SOQL in a deeper way than
    just using string manipulation.

### Usage

**TODO:** Update these docs

**Parsing a statement into an AST**

```ruby
>> require 'soql-parser'
>> parser = SOQLParser::Parser.new

# Build the AST from a SOQL statement
>> ast = parser.scan_str('SELECT * FROM users WHERE id = 1')

# Find which columns where selected in the FROM clause
>> ast.query_expression.list.to_soql
=> "*"

# Output the table expression as SOQL
>> ast.query_expression.table_expression.to_soql
=> "FROM users WHERE id = 1"

# Drill down into the WHERE clause, to examine every piece
>> ast.query_expression.table_expression.where_clause.to_soql
=> "WHERE id = 1"
>> ast.query_expression.table_expression.where_clause.search_condition.to_soql
=> "id = 1"
>> ast.query_expression.table_expression.where_clause.search_condition.left.to_soql
=> "id"
>> ast.query_expression.table_expression.where_clause.search_condition.right.to_soql
=> "1"
```

**Manually building an AST**

```ruby
>> require 'soql-parser'

# Let's build a tree representing the SOQL statement
# "SELECT * FROM users WHERE id = 1"

# We'll start from the rightmost side, and work our way left as we go.

# First, the integer constant, "1"
>> integer_constant = SOQLParser::Statement::Integer.new(1)
>> integer_constant.to_soql
=> "1"

# Now the column reference, "id"
>> column_reference = SOQLParser::Statement::Column.new('id')
>> column_reference.to_soql
=> "id"

# Now we'll combine the two using an equals operator, to create a search
# condition
>> search_condition = SOQLParser::Statement::Equals.new(column_reference, integer_constant)
>> search_condition.to_soql
=> "id = 1"

# Next we'll feed that search condition to a where clause
>> where_clause = SOQLParser::Statement::WhereClause.new(search_condition)
>> where_clause.to_soql
=> "WHERE id = 1"

# Next up is the FROM clause.  First we'll build a table reference
>> users = SOQLParser::Statement::Table.new('users')
>> users.to_soql
=> "users"

# Now we'll feed that table reference to a from clause
>> from_clause = SOQLParser::Statement::FromClause.new(users)
>> from_clause.to_soql
=> "FROM users"

# Now to combine the FROM and WHERE clauses to form a table expression
>> table_expression = SOQLParser::Statement::TableExpression.new(from_clause, where_clause)
>> table_expression.to_soql
=> "FROM users WHERE id = 1"

# Now we need to represent the asterisk "*"
>> all = SOQLParser::Statement::All.new
>> all.to_soql
=> "*"

# Now we're ready to hand off these objects to a select statement
>> select_statement = SOQLParser::Statement::Select.new(all, table_expression)
>> select_statement.to_soql
=> "SELECT * FROM users WHERE id = 1"
```

### Acknowledgments

This gem was adapted from [sql-parser](https://github.com/fastly/sql-parser).

### License

This software is released under the MIT license.
