class SOQLParser::Parser

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

  DATE_LITERALS_WITHOUT_ARGUMENT = %w(
    YESTERDAY
    TODAY
    TOMORROW
    LAST_WEEK
    THIS_WEEK
    NEXT_WEEK
    LAST_MONTH
    THIS_MONTH
    NEXT_MONTH
    LAST_90_DAYS
    NEXT_90_DAYS
    THIS_QUARTER
    LAST_QUARTER
    NEXT_QUARTER
    THIS_YEAR
    LAST_YEAR
    NEXT_YEAR
    THIS_FISCAL_QUARTER
    LAST_FISCAL_QUARTER
    NEXT_FISCAL_QUARTER
    THIS_FISCAL_YEAR
    LAST_FISCAL_YEAR
    NEXT_FISCAL_YEAR
  )

  DATE_LITERALS_WITH_ARGUMENT = %w(
    LAST_N_DAYS
    NEXT_N_DAYS
    NEXT_N_WEEKS
    LAST_N_WEEKS
    NEXT_N_MONTHS
    LAST_N_MONTHS
    NEXT_N_QUARTERS
    LAST_N_QUARTERS
    NEXT_N_YEARS
    LAST_N_YEARS
    NEXT_N_FISCAL_QUARTERS
    LAST_N_FISCAL_QUARTERS
    NEXT_N_FISCAL_YEARS
    LAST_N_FISCAL_YEARS
  )

  def tokenize_ident(text)
    if KEYWORDS.include?(text.upcase)
      [:"#{text.upcase}", text]
    elsif DATE_LITERALS_WITHOUT_ARGUMENT.include?(text.upcase)
      [:date_literal, text]
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
            {DATETIME}    {                  [:datetime, text] }
            {DATE}        {                  [:date, text] }

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

# Date literals with argument
            {IDENT}:\d+   { [:date_literal_with_arg, text] }

# identifier
            {IDENT}       { tokenize_ident(text) }


---- header ----
require 'date'
