module BarnesAndNoble
  class UsedBooks
    def initialize(eans)
      @eans = eans
    end

    def ui_data
      threads = @eans.map { |ean| lambda{ query_used_book(ean) } }
      Automatron::Needle.thread(threads)
    end

    def slow_ui_data
      @eans.map { |ean| query_used_book(ean) }
    end

    def query_used_book(ean)
      BarnesAndNoble::UsedLookup.new(ean).ui_data
    end
  end
end