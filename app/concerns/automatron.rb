module Automatron
  class Needle
    def self.thread(procs)
      threads = []
      procs.each do |p|
        threads << Thread.new { p.call }
      end
      threads.flat_map { |t| t.join; t.value }
    end
  end

  class ParserClass
    private

      def format_price(data)
        (data.to_d / 100) if data
      end

      def parse_node(node,xpath)
        result = node.search(xpath) if node
        result.text.strip.gsub(/\s+/, " ") if result
      end

      def parse_result(string,regex)
        match = string.match(regex) if string
        match[1] if match
      end

      def numberize(string)
        string.to_s.gsub("$","").to_d if string
      end
  end
end