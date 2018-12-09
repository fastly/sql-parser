class SQLParser::Parser

option
  ignorecase

inner
  KEYWORDS = %w(
    SELECT
    DATE
    ASC
    AS
    FROM
    WHERE
    BETWEEN
    AND
    NOT
    IN
    ORDER
    OR
    LIKE
    IS
    NULL
    NULLS
    COUNT
    AVG
    MAX
    MIN
    SUM
    GROUP
    BY
    HAVING
    LIMIT
    USING
    EXISTS
    DESC
    SCOPE
    FIRST
    LAST
    WITH
  )

  def tokenize_ident(text)
    if KEYWORDS.include?(text.upcase)
      [:"#{text.upcase}", text]
    else
      [:identifier, text]
    end
  end


macro
  DIGIT   [0-9]
  UINT    {DIGIT}+
  BLANK   \s+

  YEARS   {UINT}
  MONTHS  {UINT}
  DAYS    {UINT}
  DATE    {YEARS}-{MONTHS}-{DAYS}

  IDENT   [a-zA-Z_][a-zA-Z0-9_]*

rule
# [:state]  pattern       [actions]

# literals
            \"{DATE}\"    { [:date_string, Date.parse(text)] }
            \'{DATE}\'    { [:date_string, Date.parse(text)] }

            \'            { @state = :STRS;  [:quote, text] }
  :STRS     \'            { @state = nil;    [:quote, text] }
  :STRS     .*(?=\')      {                  [:character_string_literal, text.gsub("''", "'")] }

            \"            { @state = :STRD;  [:quote, text] }
  :STRD     \"            { @state = nil;    [:quote, text] }
  :STRD     .*(?=\")      {                  [:character_string_literal, text.gsub('""', '"')] }

            {UINT}        { [:unsigned_integer, text.to_i] }

# skip
            {BLANK}       # no action

# tokens
            <>            { [:not_equals_operator, text] }
            !=            { [:not_equals_operator, text] }
            =             { [:equals_operator, text] }
            <=            { [:less_than_or_equals_operator, text] }
            <             { [:less_than_operator, text] }
            >=            { [:greater_than_or_equals_operator, text] }
            >             { [:greater_than_operator, text] }

            \(            { [:left_paren, text] }
            \)            { [:right_paren, text] }
            \*            { [:asterisk, text] }
            \/            { [:solidus, text] }
            \+            { [:plus_sign, text] }
            \-            { [:minus_sign, text] }
            \.            { [:period, text] }
            ,             { [:comma, text] }

# identifier
            `{IDENT}`     { [:identifier, text[1..-2]] }
            {IDENT}       { tokenize_ident(text) }

---- header ----
require 'date'
