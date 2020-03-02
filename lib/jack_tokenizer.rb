require 'cgi'

class JackTokenizer
  KEYWORDS = ['class', 'constructor', 'function', 'method', 'field', 'static', 'var', 'int', 'char', 'boolean', 'void', 'true', 'false', 'null', 'this', 'let', 'do', 'if', 'else', 'while', 'return']
  SYMBOLS = ['{', '}', '(', ')', '[', ']', '.', ',', ';', '+', '-', '*', '/', '&', '|', '<', '>', '=', '~']
  WHITESPACE_CHARS = [" ", "\t", "\r", "\n", "\f", "\s"]
  DELIMETERS = SYMBOLS + WHITESPACE_CHARS

  KEYWORD_TYPE = "keyword"
  SYMBOL_TYPE = "symbol"
  IDENTIFIER_TYPE = "identifier"
  INT_CONST_TYPE = "integerConstant"
  STRING_CONST_TYPE = "stringConstant"

  attr_reader :tokens, :source_filepath

  def initialize(source_filepath)
    @source_filepath = source_filepath
    @chars = []
    @tokens = []
    @current_token_type = nil
    @current_token_body = ""
  end

  def run
    open_file_and_save_chars

    tokenize_chars

    write_tokens_to_file
  end

  private

  def open_file_and_save_chars
    File.open(@source_filepath, "r") do |f|
      while c = f.getc
        @chars << c
      end
    end
  end

  def tokenize_chars
    length = @chars.length
    i = 0
    within_string = false

    while i < length do
      # skip single line comment
      if @chars[i] == "/" && @chars[i+1] == "/"
        newline_index = i

        until @chars[newline_index] == "\n" do
          newline_index += 1
        end

        i = newline_index + 1
        store_and_reset_token
        next
      end

      # skip multi line comment
      if @chars[i] == "/" && @chars[i+1] == "*"
        newline_index = i

        until @chars[newline_index] == "*" && @chars[newline_index+1] == "/" do
          newline_index += 1
        end

        i = newline_index + 2
        store_and_reset_token
        next
      end

      if @chars[i] == '"'
        within_string = !within_string
      end

      # handle symbols
      if !within_string && SYMBOLS.include?(@chars[i])
        @current_token_type = SYMBOL_TYPE
        @current_token_body = @chars[i]

        store_and_reset_token
        i += 1
        next
      end

      # handle integer constants
      if %w(0 1 2 3 4 5 6 7 8 9).include?(@chars[i])
        int_index = i
        @current_token_type = INT_CONST_TYPE

        while %w(0 1 2 3 4 5 6 7 8 9).include?(@chars[int_index]) do
          @current_token_body += @chars[int_index]
          int_index += 1
        end

        store_and_reset_token
        i = int_index
        next
      end

      # handle string constants
      if within_string
        string_index = i + 1

        @current_token_type = STRING_CONST_TYPE

        until @chars[string_index] == '"' do
          @current_token_body += @chars[string_index]
          string_index += 1
        end

        store_and_reset_token
        i = string_index
        next
      end

      # handle identifiers and keywords
      if @chars[i].match?(/[a-zA-Z_]/)
        id_index = i

        @current_token_type = IDENTIFIER_TYPE

        until DELIMETERS.include?(@chars[id_index]) do
          @current_token_body += @chars[id_index]
          id_index += 1
        end

        if KEYWORDS.include?(@current_token_body)
          @current_token_type = KEYWORD_TYPE
        end

        store_and_reset_token
        i = id_index
        next
      end

      i += 1
    end
  end

  def store_and_reset_token
    if @current_token_body != "" && @current_token_type != nil
      @tokens << {type: @current_token_type, body: @current_token_body}
    end

    @current_token_type = nil
    @current_token_body = ""
  end

  def write_tokens_to_file
    File.open(xml_token_filepath, "w") do |f|
      f.puts("<tokens>")
      @tokens.each do |token|
        xml_token = format_token_to_xml(token)
        f.puts(xml_token)
      end
      f.puts("</tokens>")
    end
  end

  def xml_token_filepath
    @source_filepath.gsub(".jack", "T.xml")
  end

  def format_token_to_xml(token)
    "<#{token[:type]}> #{CGI.escapeHTML(token[:body])} </#{token[:type]}>"
  end
end
