require 'test_helper'

class TestParser < Minitest::Test

  def test_case_insensitivity
    assert_sql 'SELECT Id FROM User WHERE Id = 1', 'select Id from User where Id = 1'
  end

  def test_subquery_in_where_clause
    assert_understands 'SELECT Id FROM t1 WHERE Id > (SELECT SUM(a) FROM t2)'
  end

  def test_limits
    assert_understands 'SELECT Id FROM t1 LIMIT 1'
  end

  def test_order_by_constant
    assert_understands 'SELECT Id FROM User ORDER BY 1'
    assert_understands 'SELECT Id FROM User ORDER BY 1 ASC'
    assert_understands 'SELECT Id FROM User ORDER BY 1 DESC'
  end

  def test_qualified_table
    assert_understands 'SELECT Id FROM Foo.Bar'
  end

  def test_order
    assert_understands 'SELECT Id FROM User ORDER BY Name'
    assert_understands 'SELECT Id FROM User ORDER BY Name ASC'
    assert_understands 'SELECT Id FROM User ORDER BY Name DESC'
  end

  # TODO Remove joins
  def test_full_outer_join
    assert_understands 'SELECT Id FROM t1 FULL OUTER JOIN t2 ON t1.a = t2.a'
    assert_understands 'SELECT Id FROM t1 FULL OUTER JOIN t2 ON t1.a = t2.a FULL OUTER JOIN t3 ON t2.a = t3.a'
    assert_understands 'SELECT Id FROM t1 FULL OUTER JOIN t2 USING (a)'
    assert_understands 'SELECT Id FROM t1 FULL OUTER JOIN t2 USING (a) FULL OUTER JOIN t3 USING (b)'
  end

  def test_full_join
    assert_understands 'SELECT Id FROM t1 FULL JOIN t2 ON t1.a = t2.a'
    assert_understands 'SELECT Id FROM t1 FULL JOIN t2 ON t1.a = t2.a FULL JOIN t3 ON t2.a = t3.a'
    assert_understands 'SELECT Id FROM t1 FULL JOIN t2 USING (a)'
    assert_understands 'SELECT Id FROM t1 FULL JOIN t2 USING (a) FULL JOIN t3 USING (b)'
  end

  def test_right_outer_join
    assert_understands 'SELECT Id FROM t1 RIGHT OUTER JOIN t2 ON t1.a = t2.a'
    assert_understands 'SELECT Id FROM t1 RIGHT OUTER JOIN t2 ON t1.a = t2.a RIGHT OUTER JOIN t3 ON t2.a = t3.a'
    assert_understands 'SELECT Id FROM t1 RIGHT OUTER JOIN t2 USING (a)'
    assert_understands 'SELECT Id FROM t1 RIGHT OUTER JOIN t2 USING (a) RIGHT OUTER JOIN t3 USING (b)'
  end

  def test_right_join
    assert_understands 'SELECT Id FROM t1 RIGHT JOIN t2 ON t1.a = t2.a'
    assert_understands 'SELECT Id FROM t1 RIGHT JOIN t2 ON t1.a = t2.a RIGHT JOIN t3 ON t2.a = t3.a'
    assert_understands 'SELECT Id FROM t1 RIGHT JOIN t2 USING (a)'
    assert_understands 'SELECT Id FROM t1 RIGHT JOIN t2 USING (a) RIGHT JOIN t3 USING (b)'
  end

  def test_left_outer_join
    assert_understands 'SELECT Id FROM t1 LEFT OUTER JOIN t2 ON t1.a = t2.a'
    assert_understands 'SELECT Id FROM t1 LEFT OUTER JOIN t2 ON t1.a = t2.a LEFT OUTER JOIN t3 ON t2.a = t3.a'
    assert_understands 'SELECT Id FROM t1 LEFT OUTER JOIN t2 USING (a)'
    assert_understands 'SELECT Id FROM t1 LEFT OUTER JOIN t2 USING (a) LEFT OUTER JOIN t3 USING (b)'
  end

  def test_left_join
    assert_understands 'SELECT Id FROM t1 LEFT JOIN t2 ON t1.a = t2.a'
    assert_understands 'SELECT Id FROM t1 LEFT JOIN t2 ON t1.a = t2.a LEFT JOIN t3 ON t2.a = t3.a'
    assert_understands 'SELECT Id FROM t1 LEFT JOIN t2 USING (a)'
    assert_understands 'SELECT Id FROM t1 LEFT JOIN t2 USING (a) LEFT JOIN t3 USING (b)'
  end

  def test_inner_join
    assert_understands 'SELECT Id FROM t1 INNER JOIN t2 ON t1.a = t2.a'
    assert_understands 'SELECT Id FROM t1 INNER JOIN t2 ON t1.a = t2.a INNER JOIN t3 ON t2.a = t3.a'
    assert_understands 'SELECT Id FROM t1 INNER JOIN t2 USING (a)'
    assert_understands 'SELECT Id FROM t1 INNER JOIN t2 USING (a) INNER JOIN t3 USING (b)'
  end

  def test_cross_join
    assert_understands 'SELECT Id FROM t1 CROSS JOIN t2'
    assert_understands 'SELECT Id FROM t1 CROSS JOIN t2 CROSS JOIN t3'
  end

  # The expression
  #   SELECT Id FROM t1, t2
  # is just syntactic sugar for
  #   SELECT Id FROM t1 CROSS JOIN t2
  def test_cross_join_syntactic_sugar
    assert_sql 'SELECT Id FROM t1 CROSS JOIN t2', 'SELECT Id FROM t1, t2'
    assert_sql 'SELECT Id FROM t1 CROSS JOIN t2 CROSS JOIN t3', 'SELECT Id FROM t1, t2, t3'
  end

  def test_having
    assert_understands 'SELECT Id FROM Users HAVING Id = 1'
  end

  def test_group_by
    assert_understands 'SELECT Id FROM User GROUP BY Name'
    assert_understands 'SELECT Id FROM User GROUP BY User.Name'
    assert_understands 'SELECT Id FROM User GROUP BY Name, Id'
    assert_understands 'SELECT Id FROM User GROUP BY User.Name, User.Id'
  end

  def test_or
    assert_understands 'SELECT Id FROM User WHERE (Id = 1 OR Age = 18)'
  end

  def test_and
    assert_understands 'SELECT Id FROM User WHERE (Id = 1 AND Age = 18)'
  end

  def test_not
    assert_sql 'SELECT Id FROM User WHERE Id <> 1', 'SELECT Id FROM User WHERE NOT Id = 1'
    assert_sql 'SELECT Id FROM User WHERE Id NOT IN (1, 2, 3)', 'SELECT Id FROM User WHERE NOT Id IN (1, 2, 3)'
    assert_sql 'SELECT Id FROM User WHERE Id NOT BETWEEN 1 AND 3', 'SELECT Id FROM User WHERE NOT Id BETWEEN 1 AND 3'
    assert_sql "SELECT Id FROM User WHERE Name NOT LIKE 'A%'", "SELECT Id FROM User WHERE NOT Name LIKE 'A%'"

    # Shouldn't negate subqueries
    assert_understands 'SELECT Id FROM User WHERE NOT EXISTS (SELECT Id FROM User WHERE Id = 1)'
  end

  def test_not_exists
    assert_understands 'SELECT Id FROM User WHERE NOT EXISTS (SELECT Id FROM User)'
  end

  def test_exists
    assert_understands 'SELECT Id FROM User WHERE EXISTS (SELECT Id FROM User)'
  end

  def test_is_not_null
    assert_understands 'SELECT Id FROM User WHERE deleted_at IS NOT NULL'
  end

  def test_is_null
    assert_understands 'SELECT Id FROM User WHERE deleted_at IS NULL'
  end

  def test_not_like
    assert_understands "SELECT Id FROM User WHERE name NOT LIKE 'Joe%'"
  end

  def test_like
    assert_understands "SELECT Id FROM User WHERE name LIKE 'Joe%'"
  end

  def test_not_in
    assert_understands 'SELECT Id FROM User WHERE Id NOT IN (1, 2, 3)'
    assert_understands 'SELECT Id FROM User WHERE Id NOT IN (SELECT Id FROM User WHERE age = 18)'
  end

  def test_in
    assert_understands 'SELECT Id FROM User WHERE Id IN (1, 2, 3)'
    assert_understands 'SELECT Id FROM User WHERE Id IN (SELECT Id FROM User WHERE age = 18)'
  end

  def test_not_between
    assert_understands 'SELECT Id FROM User WHERE Id NOT BETWEEN 1 AND 3'
  end

  def test_between
    assert_understands 'SELECT Id FROM User WHERE Id BETWEEN 1 AND 3'
  end

  def test_gte
    assert_understands 'SELECT Id FROM User WHERE Id >= 1'
  end

  def test_lte
    assert_understands 'SELECT Id FROM User WHERE Id <= 1'
  end

  def test_gt
    assert_understands 'SELECT Id FROM User WHERE Id > 1'
  end

  def test_lt
    assert_understands 'SELECT Id FROM User WHERE Id < 1'
  end

  def test_not_equals
    assert_sql 'SELECT Id FROM User WHERE Id <> 1', 'SELECT Id FROM User WHERE Id != 1'
    assert_understands 'SELECT Id FROM User WHERE Id <> 1'
  end

  def test_equals
    assert_understands 'SELECT Id FROM User WHERE Id = 1'
  end

  def test_where_clause
    assert_understands 'SELECT Id FROM User WHERE 1 = 1'
  end

  def test_sum
    assert_understands 'SELECT SUM(messages_count) FROM User'
  end

  def test_min
    assert_understands 'SELECT MIN(age) FROM User'
  end

  def test_max
    assert_understands 'SELECT MAX(age) FROM User'
  end

  def test_avg
    assert_understands 'SELECT AVG(age) FROM User'
  end

  def test_count
    assert_understands 'SELECT COUNT() FROM User'
    assert_understands 'SELECT COUNT(Id) FROM User'
  end

  def test_from_clause
    assert_understands 'SELECT 1 FROM User'
    assert_understands 'SELECT Id FROM User'
    assert_understands 'SELECT User.Id FROM User'
    assert_understands 'SELECT Id FROM User'
  end

  def test_select_list
    assert_understands 'SELECT Id FROM Opportunity'
    assert_understands 'SELECT Id, Name, Amount FROM Opportunity'
  end

  def test_as
    assert_understands 'SELECT u.Id FROM User u'
    assert_understands 'SELECT Id OppId FROM Opportunity'
    assert_understands 'SELECT Id, Name OppName FROM Opportunity'
  end

  # SOQL

  def test_select_alias
    assert_understands 'SELECT SUM(Amount) Total FROM Opportunity'
  end

  def test_toLabel
    assert_understands 'SELECT toLabel(StageName) FROM Opportunity'
    assert_understands 'SELECT toLabel(Recordtype.Name) FROM Case'
  end

  def test_using_scope
    assert_understands 'SELECT Id FROM Opportunity USING SCOPE mine'
    assert_understands 'SELECT Id FROM Opportunity USING SCOPE Delegated'
    assert_understands 'SELECT Id FROM Opportunity USING SCOPE Everything'
    assert_understands 'SELECT Id FROM Opportunity USING SCOPE My_Territory'
    assert_understands 'SELECT Id FROM Opportunity USING SCOPE My_Team_Territory'
  end

  def test_order_by_nulls
    assert_understands 'SELECT Id FROM Opportunity ORDER BY StageName DESC NULLS LAST'
    assert_understands 'SELECT Id FROM Opportunity ORDER BY StageName DESC NULLS LAST, Id ASC NULLS FIRST'
  end

  # TODO
  # def test_with_filters
  #   assert_understands "SELECT Id FROM UserProfileFeed WITH UserId='005D0000001AamR' ORDER BY CreatedDate DESC, Id DESC LIMIT 20"
  # end
  #
  # def test_with_data_category_filters
  #   assert_understands "SELECT Title FROM KnowledgeArticleVersion WHERE PublishStatus='online' WITH DATA CATEGORY Geography__c ABOVE usa__c"
  #   assert_understands "SELECT Title FROM Question WHERE LastReplyDate > 2005-10-08T01:02:03Z WITH DATA CATEGORY Geography__c AT (usa__c, uk__c)"
  #   assert_understands "SELECT UrlName FROM KnowledgeArticleVersion WHERE PublishStatus='draft' WITH DATA CATEGORY Geography__c AT usa__c AND Product__c ABOVE_OR_BELOW mobile_phones__c"
  # end

  def test_soql_queries
    assert_understands 'SELECT Name, Account.Name, toLabel(StageName), CloseDate, Amount, Fiscal, Id, RecordTypeId, CreatedDate, LastModifiedDate, SystemModstamp FROM Opportunity USING SCOPE mine WHERE Amount > 10000 ORDER BY StageName DESC NULLS LAST, Id ASC NULLS FIRST'

	# Parentheses are added to where clause
    assert_sql 'SELECT Name, toLabel(StageName) FROM Opportunity WHERE (IsClosed = false AND CloseDate = THIS_MONTH) ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST', 'SELECT Name, toLabel(StageName) FROM Opportunity WHERE IsClosed = false AND CloseDate = THIS_MONTH ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST'

  end

  private

  def assert_sql(expected, given)
    assert_equal expected, SQLParser::Parser.parse(given).to_sql
  end

  def assert_understands(sql)
    assert_sql(sql, sql)
  end
end
