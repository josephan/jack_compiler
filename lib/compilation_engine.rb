require 'cgi'
require_relative "./compilation_methods.rb"

class CompilationEngine
  include CompilationMethods

  attr_reader :tokens

  def initialize(tokenizer)
    @tokens = tokenizer.tokens
    @source_filepath = tokenizer.source_filepath
  end

  def run
    structure = compile_class(@tokens)

    xml = self.class.format_to_xml(structure)

    write_to_file(xml)
  end

  def self.format_to_xml(structure, nest_level = 0)
    if structure.is_a?(Array)
      structure.map { |s| format_to_xml(s, nest_level) }.join("")
    elsif structure[:body] && structure[:body].is_a?(Array)
      ("  " * nest_level) + "<#{structure[:type]}>\n" +
        format_to_xml(structure[:body], nest_level + 1) +
        ("  " * nest_level) + "</#{structure[:type]}>\n"
    elsif structure[:body] && structure[:body].is_a?(String)
      ("  " * nest_level) + "<#{structure[:type]}> #{CGI.escapeHTML(structure[:body])} </#{structure[:type]}>\n"
    end
  end

  private

  def write_to_file(xml)
    File.open(xml_structure_filepath, "w+") do |f|
      f.puts(xml)
    end
  end

  def xml_structure_filepath
    @source_filepath.gsub(".jack", ".xml")
  end
end
