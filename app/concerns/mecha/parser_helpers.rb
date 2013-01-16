module Mecha
  module ParserHelpers
  
    def parse_node(node,xpath)
      result = node.search(xpath).first
      result.text.strip if result
    end

    def parse_result(string,regex)
      match = string.match(regex) if string
      match[1].strip if match
    end

    def numberize_price(string)
      if string =~ /\$/
        number = string.gsub("$","")
        BigDecimal.new(number) if number.to_f > 0
      else
        nil
      end
    end

  end
end