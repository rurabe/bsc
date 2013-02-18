module Cart
  class Query
    def initialize(cart_data)
      @vendor = cart_data[:vendor]
      @books = cart_data[:books]
    end

    def control
      
    end

    def vendor_query(vendor)
      case vendor
      when "amazon"
        amazon
      when "bn"
        BarnesAndNoble
    end



  end
end