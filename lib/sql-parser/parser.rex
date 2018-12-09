class SQLParser::Parser

option
  ignorecase

inner
  KEYWORDS = %w(
    SELECT
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
    EXISTS # TODO: remove
    DESC
    SCOPE
    FIRST
    LAST
    WITH
    EXCLUDES
    INCLUDES
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

  YEARS   {DIGIT}{4}
  MONTHS  {DIGIT}{2}
  DAYS    {DIGIT}{2}
  DATE    {YEARS}-{MONTHS}-{DAYS}

  HOURS     {DIGIT}{2}
  MINUTES   {DIGIT}{2}
  SECONDS   {DIGIT}{2}
  OFFSET    ([-+]{DIGIT}{2}:{DIGIT}{2}|Z)
  DATETIME  {DATE}T{HOURS}:{MINUTES}:{SECONDS}{OFFSET}

  IDENT   [a-zA-Z_][a-zA-Z0-9_]*

rule
# [:state]  pattern       [actions]

# literals
            {DATETIME}    {                  [:datetime_literal, text] }
            {DATE}        {                  [:date_literal, text] }

            \'            { @state = :STRS;  [:quote, text] }
  :STRS     \'            { @state = nil;    [:quote, text] }
  :STRS     .*?(?=\')     {                  [:character_string_literal, text.gsub("''", "'")] }

            \"            { @state = :STRD;  [:quote, text] }
  :STRD     \"            { @state = nil;    [:quote, text] }
  :STRD     .*?(?=\")     {                  [:character_string_literal, text.gsub('""', '"')] }

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
