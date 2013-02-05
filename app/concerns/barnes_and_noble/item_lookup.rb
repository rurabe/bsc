module BarnesAndNoble
  class ItemLookup < ApiClass
    # merge with used
    attr_reader :response, :parsed_response

    def initialize(eans)
      @eans = eans
      @response = nil
      @parsed_response = {}
      control
    end

    def parse
      request_items.map { |book| parse_offers(book) }
    end

    private

      def control
        @response = send_request(build_lookup_params)
      end

      def build_lookup_params
        default_params.merge(:ean => parameterized_eans)
      end

      def parameterized_eans
        @eans.delete_if { |product| product.nil? }.join(",")
      end

      def default_params
        { :operation    => 'ProductLookup',
          :product_code => 'Book' }
      end

      def request_items
        @eans.flat_map do |ean|
          { :condition => "new", :ean => ean }
        end
      end

      def response_base(book)
        { :ean               => book[:ean],
          :offers_attributes => [build_offer_response_base] }
      end

      def build_offer_response_base
        { :condition  => "new",
          :vendor     => "Barnes and Noble" }
      end

      def parse_offers(book)
        response = response_base(book)
        response[:offers_attributes].each do |offer_base|
          offer_base.merge!(parse_best_offer(book,offer_base))
        end
        response
      end

     def parse_best_offer(book,offer_base)
        build_offer(best_offer(book,offer_base))
      end

      def best_offer(book,offer_base)
        get_offers(book,offer_base).min { |a,b| parse_price(a) <=> parse_price(b) }
      end

      def get_offers(book,offer_base)
        ean = book[:ean]
        @response.search(".//Product[.//Ean[text()=#{ean}]]")
      end

      def build_offer(offer)
        { :vendor_book_id   => parse_vendor_book_id(offer),
          :price            => parse_price(offer),
          :vendor_offer_id  => parse_vendor_offer_id(offer),
          :availability     => parse_availability(offer),
          :shipping_time    => parse_shipping_time(offer),
          :comments         => parse_comments(offer) }
      end

      def parse_vendor_book_id(product)
        parse_node(product,'.//Ean')
      end

      def parse_price(product)
        price = parse_node(product,".//Prices//BnPrice")
        format_price(price)
      end

      def parse_vendor_offer_id(offer)
      end

      def parse_availability(offer)
        parse_node(offer,".//Availability")
      end

      def parse_shipping_time(offer)
        parse_node(offer,".//DeliveryMessage")
      end

      def parse_comments(offer)
      end
  end
end