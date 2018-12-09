require 'test_helper'

class TestParser < Minitest::Test

  def test_case_insensitivity
    assert_soql 'SELECT Id FROM User WHERE Id = 1', 'select Id from User where Id = 1'
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
    assert_soql 'SELECT Id FROM User WHERE Id <> 1', 'SELECT Id FROM User WHERE NOT Id = 1'
    assert_soql 'SELECT Id FROM User WHERE Id NOT IN (1, 2, 3)', 'SELECT Id FROM User WHERE NOT Id IN (1, 2, 3)'
    assert_soql 'SELECT Id FROM User WHERE Id NOT BETWEEN 1 AND 3', 'SELECT Id FROM User WHERE NOT Id BETWEEN 1 AND 3'
    assert_soql "SELECT Id FROM User WHERE Name NOT LIKE 'A%'", "SELECT Id FROM User WHERE NOT Name LIKE 'A%'"

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
    assert_understands "SELECT Name FROM Account WHERE Name LIKE 'A%'"
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
    assert_soql 'SELECT Id FROM User WHERE Id <> 1', 'SELECT Id FROM User WHERE Id != 1'
    assert_understands 'SELECT Id FROM User WHERE Id <> 1'
  end

  def test_equals
    assert_understands 'SELECT Id FROM User WHERE Id = 1'
  end

  def test_where_clause
    assert_understands 'SELECT Id FROM User WHERE 1 = 1'
    assert_soql "SELECT Id FROM User WHERE Name = 'Foo'", "SELECT Id FROM User WHERE Name='Foo'"
    assert_soql "SELECT Id FROM Contact WHERE (Name LIKE 'A%' AND MailingState = 'California')", "SELECT Id FROM Contact WHERE Name LIKE 'A%' AND MailingState='California'"
    assert_understands "SELECT Amount FROM Opportunity WHERE CALENDAR_YEAR(CreatedDate) = 2011"
    assert_understands "SELECT Name FROM Account WHERE CreatedDate > 2011-04-26T10:00:00-08:00"
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

  def test_from_multiple
    assert_understands "SELECT COUNT() FROM Contact c, c.Account a WHERE a.name = 'MyriadPubs'"
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

  def test_dates
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate = YESTERDAY'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate > TODAY'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate = TOMORROW'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate > LAST_WEEK'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate < THIS_WEEK'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate = NEXT_WEEK'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate > LAST_MONTH'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate < THIS_MONTH'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate = NEXT_MONTH'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate = LAST_90_DAYS'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate > NEXT_90_DAYS'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate = LAST_N_DAYS:365'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate > NEXT_N_DAYS:15'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate > NEXT_N_WEEKS:4'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate = LAST_N_WEEKS:52'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate > NEXT_N_MONTHS:2'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate = LAST_N_MONTHS:12'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate = THIS_QUARTER'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate > LAST_QUARTER'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate < NEXT_QUARTER'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate < NEXT_N_QUARTERS:2'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate > LAST_N_QUARTERS:2'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate = THIS_YEAR'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate > LAST_YEAR'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate < NEXT_YEAR'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate < NEXT_N_YEARS:5'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate > LAST_N_YEARS:5'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate = THIS_FISCAL_QUARTER'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate > LAST_FISCAL_QUARTER'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate < NEXT_FISCAL_QUARTER'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate < NEXT_N_FISCAL_QUARTERS:6'
    assert_understands 'SELECT Id FROM Account WHERE CreatedDate > LAST_N_FISCAL_QUARTERS:6'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate = THIS_FISCAL_YEAR'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate > LAST_FISCAL_YEAR'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate < NEXT_FISCAL_YEAR'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate < NEXT_N_FISCAL_YEARS:3'
    assert_understands 'SELECT Id FROM Opportunity WHERE CloseDate > LAST_N_FISCAL_YEARS:3'
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
    assert_soql 'SELECT Name, toLabel(StageName) FROM Opportunity WHERE (IsClosed = false AND CloseDate = THIS_MONTH) ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST', 'SELECT Name, toLabel(StageName) FROM Opportunity WHERE IsClosed = false AND CloseDate = THIS_MONTH ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST'

  end

  private

  def assert_soql(expected, given)
    assert_equal expected, SOQLParser::Parser.parse(given).to_soql
  end

  def assert_understands(soql)
    assert_soql(soql, soql)
  end
end
