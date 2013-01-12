module BarnesAndNoble
  class UsedBooks
    def initialize(eans)
      @eans = eans
    end

    def ui_data
      @eans.map do |ean|
        query_used_book(ean)
      end
    end


    def query_used_book(ean)
      BarnesAndNoble::UsedLookup.new(ean).ui_data
    end
  end
end