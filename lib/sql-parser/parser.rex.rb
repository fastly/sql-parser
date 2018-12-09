#--
# DO NOT MODIFY!!!!
# This file is automatically generated by rex 1.0.5
# from lexical definition file "lib/sql-parser/parser.rex".
#++

require 'racc/parser'
class SQLParser::Parser < Racc::Parser
  require 'strscan'

  class ScanError < StandardError ; end

  attr_reader   :lineno
  attr_reader   :filename
  attr_accessor :state

  def scan_setup(str)
    @ss = StringScanner.new(str)
    @lineno =  1
    @state  = nil
  end

  def action
    yield
  end

  def scan_str(str)
    scan_setup(str)
    do_parse
  end
  alias :scan :scan_str

  def load_file( filename )
    @filename = filename
    open(filename, "r") do |f|
      scan_setup(f.read)
    end
  end

  def scan_file( filename )
    load_file(filename)
    do_parse
  end


  def next_token
    return if @ss.eos?
    
    # skips empty actions
    until token = _next_token or @ss.eos?; end
    token
  end

  def _next_token
    text = @ss.peek(1)
    @lineno  +=  1  if text == "\n"
    token = case @state
    when nil
      case
      when (text = @ss.scan(/\"[0-9]+-[0-9]+-[0-9]+\"/i))
         action { [:date_string, Date.parse(text)] }

      when (text = @ss.scan(/\'[0-9]+-[0-9]+-[0-9]+\'/i))
         action { [:date_string, Date.parse(text)] }

      when (text = @ss.scan(/\'/i))
         action { @state = :STRS;  [:quote, text] }

      when (text = @ss.scan(/\"/i))
         action { @state = :STRD;  [:quote, text] }

      when (text = @ss.scan(/[0-9]+/i))
         action { [:unsigned_integer, text.to_i] }

      when (text = @ss.scan(/\s+/i))
        ;

      when (text = @ss.scan(/<>/i))
         action { [:not_equals_operator, text] }

      when (text = @ss.scan(/!=/i))
         action { [:not_equals_operator, text] }

      when (text = @ss.scan(/=/i))
         action { [:equals_operator, text] }

      when (text = @ss.scan(/<=/i))
         action { [:less_than_or_equals_operator, text] }

      when (text = @ss.scan(/</i))
         action { [:less_than_operator, text] }

      when (text = @ss.scan(/>=/i))
         action { [:greater_than_or_equals_operator, text] }

      when (text = @ss.scan(/>/i))
         action { [:greater_than_operator, text] }

      when (text = @ss.scan(/\(/i))
         action { [:left_paren, text] }

      when (text = @ss.scan(/\)/i))
         action { [:right_paren, text] }

      when (text = @ss.scan(/\*/i))
         action { [:asterisk, text] }

      when (text = @ss.scan(/\//i))
         action { [:solidus, text] }

      when (text = @ss.scan(/\+/i))
         action { [:plus_sign, text] }

      when (text = @ss.scan(/\-/i))
         action { [:minus_sign, text] }

      when (text = @ss.scan(/\./i))
         action { [:period, text] }

      when (text = @ss.scan(/,/i))
         action { [:comma, text] }

      when (text = @ss.scan(/`[a-zA-Z_][a-zA-Z0-9_]*`/i))
         action { [:identifier, text[1..-2]] }

      when (text = @ss.scan(/[a-zA-Z_][a-zA-Z0-9_]*/i))
         action { tokenize_ident(text) }

      when (text = @ss.scan(/----/i))
        ;

      when (text = @ss.scan(/require/i))
        ;

      else
        text = @ss.string[@ss.pos .. -1]
        raise  ScanError, "can not match: '" + text + "'"
      end  # if

    when :STRS
      case
      when (text = @ss.scan(/\'/i))
         action { @state = nil;    [:quote, text] }

      when (text = @ss.scan(/.*(?=\')/i))
         action {                  [:character_string_literal, text.gsub("''", "'")] }

      else
        text = @ss.string[@ss.pos .. -1]
        raise  ScanError, "can not match: '" + text + "'"
      end  # if

    when :STRD
      case
      when (text = @ss.scan(/\"/i))
         action { @state = nil;    [:quote, text] }

      when (text = @ss.scan(/.*(?=\")/i))
         action {                  [:character_string_literal, text.gsub('""', '"')] }

      else
        text = @ss.string[@ss.pos .. -1]
        raise  ScanError, "can not match: '" + text + "'"
      end  # if

    else
      raise  ScanError, "undefined state: '" + state.to_s + "'"
    end  # case state
    token
  end  # def _next_token

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
    INNER
    INTO
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
    CROSS
    JOIN
    ON
    LEFT
    OUTER
    RIGHT
    FULL
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
end # class
