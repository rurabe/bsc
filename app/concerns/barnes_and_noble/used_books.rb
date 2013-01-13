module BarnesAndNoble
  class UsedBooks
    def initialize(eans)
      @eans = eans
    end

    def ui_data
      threads = []
      @eans.map do |ean|
        threads << Thread.new { query_used_book(ean) }
      end
      threads.map { |t| t.join; t.value }
    end


    def query_used_book(ean)
      BarnesAndNoble::UsedLookup.new(ean).ui_data
    end
  end
end