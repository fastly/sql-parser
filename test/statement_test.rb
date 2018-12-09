require 'test_helper'

class TestStatement < Minitest::Test
  def test_order_by
    assert_soql 'ORDER BY name', SOQLParser::Statement::OrderBy.new(col('name'))
  end

  def test_subquery
    assert_soql '(SELECT 1)', SOQLParser::Statement::Subquery.new(select(int(1)))
  end

  def test_select
    assert_soql 'SELECT 1', select(int(1))
    assert_soql 'SELECT Id FROM User', query(select(col('Id')), from(tbl('User')))
  end

  def test_select_list
    assert_soql 'id', slist(col('id'))
    assert_soql 'id, name', slist([col('id'), col('name')])
  end

  def test_distinct
    assert_soql 'DISTINCT(username)', distinct(col('username'))
  end

  def test_query
    assert_soql 'SELECT Id FROM User WHERE Id = 1 GROUP BY name', query(select(col('Id')), from(tbl('User')), where(equals(col('Id'), int(1))), group_by(col('name')))
  end

  def test_limit
    assert_soql 'SELECT Id FROM User LIMIT 2', query(select(col('Id')), from(tbl('User')), limit(int(2)))
  end

  def test_from_clause
    assert_soql 'FROM users', from(tbl('users'))
  end

  def test_order_clause
    assert_soql 'ORDER BY name DESC', SOQLParser::Statement::OrderClause.new(SOQLParser::Statement::OrderColumn.new(col('name'), SOQLParser::Statement::Descending.new))
    assert_soql 'ORDER BY id ASC, name DESC', SOQLParser::Statement::OrderClause.new([SOQLParser::Statement::OrderColumn.new(col('id'), SOQLParser::Statement::Ascending.new), SOQLParser::Statement::OrderColumn.new(col('name'), SOQLParser::Statement::Descending.new)])
  end

  def test_having_clause
    assert_soql 'HAVING id = 1', SOQLParser::Statement::HavingClause.new(equals(col('id'), int(1)))
  end

  def test_group_by_clause
    assert_soql 'GROUP BY name', group_by(col('name'))
    assert_soql 'GROUP BY name, status', group_by([col('name'), col('status')])
  end

  def test_where_clause
    assert_soql 'WHERE 1 = 1', where(equals(int(1), int(1)))
  end

  def test_or
    assert_soql '(FALSE OR FALSE)', SOQLParser::Statement::Or.new(SOQLParser::Statement::False.new, SOQLParser::Statement::False.new)
  end

  def test_and
    assert_soql '(TRUE AND TRUE)', SOQLParser::Statement::And.new(SOQLParser::Statement::True.new, SOQLParser::Statement::True.new)
  end

  def test_is_not_null
    assert_soql '1 IS NOT NULL', SOQLParser::Statement::Not.new(SOQLParser::Statement::Is.new(int(1), SOQLParser::Statement::Null.new))
  end

  def test_is_null
    assert_soql '1 IS NULL', SOQLParser::Statement::Is.new(int(1), SOQLParser::Statement::Null.new)
  end

  def test_not_like
    assert_soql "'hello' NOT LIKE 'h%'", SOQLParser::Statement::Not.new(SOQLParser::Statement::Like.new(str('hello'), str('h%')))
  end

  def test_like
    assert_soql "'hello' LIKE 'h%'", SOQLParser::Statement::Like.new(str('hello'), str('h%'))
  end

  def test_not_in
    assert_soql '1 NOT IN (1, 2, 3)', SOQLParser::Statement::Not.new(SOQLParser::Statement::In.new(int(1), SOQLParser::Statement::InValueList.new([int(1), int(2), int(3)])))
  end

  def test_in
    assert_soql '1 IN (1, 2, 3)', SOQLParser::Statement::In.new(int(1), SOQLParser::Statement::InValueList.new([int(1), int(2), int(3)]))
  end

  def test_not_between
    assert_soql '2 NOT BETWEEN 1 AND 3', SOQLParser::Statement::Not.new(SOQLParser::Statement::Between.new(int(2), int(1), int(3)))
  end

  def test_between
    assert_soql '2 BETWEEN 1 AND 3', SOQLParser::Statement::Between.new(int(2), int(1), int(3))
  end

  def test_gte
    assert_soql '1 >= 1', SOQLParser::Statement::GreaterOrEquals.new(int(1), int(1))
  end

  def test_lte
    assert_soql '1 <= 1', SOQLParser::Statement::LessOrEquals.new(int(1), int(1))
  end

  def test_gt
    assert_soql '1 > 1', SOQLParser::Statement::Greater.new(int(1), int(1))
  end

  def test_lt
    assert_soql '1 < 1', SOQLParser::Statement::Less.new(int(1), int(1))
  end

  def test_not_equals
    assert_soql '1 <> 1', SOQLParser::Statement::Not.new(equals(int(1), int(1)))
  end

  def test_equals
    assert_soql '1 = 1', equals(int(1), int(1))
  end

  def test_sum
    assert_soql 'SUM(messages_count)', SOQLParser::Statement::Sum.new(col('messages_count'))
  end

  def test_minimum
    assert_soql 'MIN(age)', SOQLParser::Statement::Minimum.new(col('age'))
  end

  def test_maximum
    assert_soql 'MAX(age)', SOQLParser::Statement::Maximum.new(col('age'))
  end

  def test_average
    assert_soql 'AVG(age)', SOQLParser::Statement::Average.new(col('age'))
  end

  def test_count
    assert_soql 'COUNT(Id)', SOQLParser::Statement::Count.new(col('Id'))
  end

  def test_table
    assert_soql 'users', tbl('users')
  end

  def test_qualified_column
    assert_soql 'users.id', qcol(tbl('users'), col('id'))
  end

  def test_column
    assert_soql 'id', col('id')
  end

  def test_as
    assert_soql '1 a', SOQLParser::Statement::As.new(int(1), col('a'))
  end

  def test_multiply
    assert_soql '(2 * 2)', SOQLParser::Statement::Multiply.new(int(2), int(2))
  end

  def test_divide
    assert_soql '(2 / 2)', SOQLParser::Statement::Divide.new(int(2), int(2))
  end

  def test_add
    assert_soql '(2 + 2)', SOQLParser::Statement::Add.new(int(2), int(2))
  end

  def test_subtract
    assert_soql '(2 - 2)', SOQLParser::Statement::Subtract.new(int(2), int(2))
  end

  def test_unary_plus
    assert_soql '+1', SOQLParser::Statement::UnaryPlus.new(int(1))
  end

  def test_unary_minus
    assert_soql '-1', SOQLParser::Statement::UnaryMinus.new(int(1))
  end

  def test_true
    assert_soql 'TRUE', SOQLParser::Statement::True.new
  end

  def test_false
    assert_soql 'FALSE', SOQLParser::Statement::False.new
  end

  def test_null
    assert_soql 'NULL', SOQLParser::Statement::Null.new
  end

  def test_datetime
    assert_soql "2008-07-01T12:34:56Z", SOQLParser::Statement::DateTime.new("2008-07-01T12:34:56Z")
    assert_soql "2008-07-01T12:34:56+07:00", SOQLParser::Statement::DateTime.new("2008-07-01T12:34:56+07:00")
    assert_soql "2008-07-01T12:34:56-07:00", SOQLParser::Statement::DateTime.new("2008-07-01T12:34:56-07:00")
  end

  def test_date
    assert_soql "2008-07-01", SOQLParser::Statement::Date.new("2008-07-01")
  end

  def test_string
    assert_soql "'foo'", str('foo')

    # # FIXME
    # assert_soql "'O\\\'rly'", str("O'rly")
  end

  def test_approximate_float
    assert_soql '1E1', SOQLParser::Statement::ApproximateFloat.new(int(1), int(1))
  end

  def test_float
    assert_soql '1.1', SOQLParser::Statement::Float.new(1.1)
  end

  def test_integer
    assert_soql '1', int(1)
  end

  private

  def assert_soql(expected, ast)
    assert_equal expected, ast.to_soql
  end

  def query(select_clause, from_clause, using_scope_clause = nil, where_clause = nil, group_by_clause = nil, having_clause = nil)
    SOQLParser::Statement::Query.new(select_clause, from_clause, using_scope_clause, where_clause, group_by_clause, having_clause)
  end

  def qcol(table, column)
    SOQLParser::Statement::QualifiedColumn.new(table, column)
  end

  def equals(left, right)
    SOQLParser::Statement::Equals.new(left, right)
  end

  def str(value)
    SOQLParser::Statement::String.new(value)
  end

  def int(value)
    SOQLParser::Statement::Integer.new(value)
  end

  def col(name)
    SOQLParser::Statement::Column.new(name)
  end

  def tbl(name)
    SOQLParser::Statement::Table.new(name)
  end

  def distinct(col)
    SOQLParser::Statement::Distinct.new(col)
  end

  def slist(ary)
    SOQLParser::Statement::SelectList.new(ary)
  end

  def select(list)
    SOQLParser::Statement::Select.new(list)
  end

  def from(tables)
    SOQLParser::Statement::FromClause.new(tables)
  end

  def where(search_condition)
    SOQLParser::Statement::WhereClause.new(search_condition)
  end

  def group_by(columns)
    SOQLParser::Statement::GroupByClause.new(columns)
  end

  def limit(limit)
    SOQLParser::Statement::LimitClause.new(limit)
  end
end
