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
end