#
# DO NOT MODIFY!!!!
# This file is automatically generated by rex 1.0.0
# from lexical definition file "lib/sql/parser.rex".
#

require 'racc/parser'
module SQL
class Parser < Racc::Parser
  require 'strscan'

  class ScanError < StandardError ; end

  attr_reader :lineno
  attr_reader :filename

  def scan_setup ; end

  def action &block
    yield
  end

  def scan_str( str )
    scan_evaluate  str
    do_parse
  end

  def load_file( filename )
    @filename = filename
    open(filename, "r") do |f|
      scan_evaluate  f.read
    end
  end

  def scan_file( filename )
    load_file  filename
    do_parse
  end

  def next_token
    @rex_tokens.shift
  end

  def scan_evaluate( str )
    scan_setup
    @rex_tokens = []
    @lineno  =  1
    ss = StringScanner.new(str)
    state = nil
    until ss.eos?
      text = ss.peek(1)
      @lineno  +=  1  if text == "\n"
      case state
      when nil
        case
        when (text = ss.scan(/\"[0-9]+-[0-9]+-[0-9]+\"/))
           @rex_tokens.push action { [:date_string, Date.parse(text)] }

        when (text = ss.scan(/\'[0-9]+-[0-9]+-[0-9]+\'/))
           @rex_tokens.push action { [:date_string, Date.parse(text)] }

        when (text = ss.scan(/\"[^"]*\"/))
           @rex_tokens.push action { [:character_string_literal, text[1..-2]] }

        when (text = ss.scan(/\'[^']*\'/))
           @rex_tokens.push action { [:character_string_literal, text[1..-2]] }

        when (text = ss.scan(/[0-9]+/))
           @rex_tokens.push action { [:unsigned_integer, text.to_i] }

        when (text = ss.scan(/\s+/))
          ;

        when (text = ss.scan(/SELECT/))
           @rex_tokens.push action { [:SELECT, text] }

        when (text = ss.scan(/DATE/))
           @rex_tokens.push action { [:DATE, text] }

        when (text = ss.scan(/AS/))
           @rex_tokens.push action { [:AS, text] }

        when (text = ss.scan(/FROM/))
           @rex_tokens.push action { [:FROM, text] }

        when (text = ss.scan(/\(/))
           @rex_tokens.push action { [:left_paren, text] }

        when (text = ss.scan(/\)/))
           @rex_tokens.push action { [:right_paren, text] }

        when (text = ss.scan(/\*/))
           @rex_tokens.push action { [:asterisk, text] }

        when (text = ss.scan(/\//))
           @rex_tokens.push action { [:solidus, text] }

        when (text = ss.scan(/\+/))
           @rex_tokens.push action { [:plus_sign, text] }

        when (text = ss.scan(/\-/))
           @rex_tokens.push action { [:minus_sign, text] }

        when (text = ss.scan(/\./))
           @rex_tokens.push action { [:period, text] }

        when (text = ss.scan(/,/))
           @rex_tokens.push action { [:comma, text] }

        when (text = ss.scan(/\w+/))
           @rex_tokens.push action { [:identifier, text] }

        when (text = ss.scan(/----/))
          ;

        when (text = ss.scan(/require/))
          ;

        else
          text = ss.string[ss.pos .. -1]
          raise  ScanError, "can not match: '" + text + "'"
        end  # if

      else
        raise  ScanError, "undefined state: '" + state.to_s + "'"
      end  # case state
    end  # until ss
  end  # def scan_evaluate

end # class
end # module
