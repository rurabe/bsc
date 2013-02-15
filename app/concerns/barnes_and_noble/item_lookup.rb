require 'barnes_and_noble/used_lookup'
module BarnesAndNoble
  class ItemLookup < ApiClass
    # merge with used
    attr_reader :response, :parsed_response

    def initialize(eans)
      @eans = eans
      @response = nil
      control
    end

    def parse
      Automatron::Needle.thread( response_base.map { |book| lambda{parse_offers(book)} } )
    end

    # private

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

      # Response_base #
      def response_base
        @eans.flat_map do |ean|
          { :ean               => ean,
            :offers_attributes => build_offer_response_base }
        end
      end

      def build_offer_response_base
        ["new","used"].map do |condition|
          { :condition  => condition,
            :vendor     => "Barnes and Noble" }
        end
      end

      # Takes a response base object and parses the offers #
      def parse_offers(response)
        response[:offers_attributes].each do |offer_base|
          offer_base.merge!(parse_best_offer(response[:ean],offer_base))
        end
        response
      end

      def parse_best_offer(ean,offer_base)
        condition = offer_base[:condition].downcase
        send("best_#{condition}_offer".to_sym,ean)
      end 

      def best_new_offer(ean)
        offer = get_new_offers(ean).min { |a,b| parse_price(a) <=> parse_price(b) }
        build_new_offer(offer)
      end

      def get_new_offers(ean)
        @response.search(".//Product[.//Ean[text()=#{ean}]]")
      end

      def best_used_offer(ean)
        BarnesAndNoble::UsedLookup.new(ean).parse
      end


      # Parsers #
      def build_new_offer(offer)
        { :vendor_book_id     => parse_vendor_book_id(offer),
          :price              => parse_price(offer),
          :vendor_offer_id    => parse_vendor_offer_id(offer),
          :detailed_condition => parse_offer_detailed_condition(offer),
          :availability       => parse_availability(offer),
          :shipping_time      => parse_shipping_time(offer),
          :comments           => parse_comments(offer) }
      end

      def parse_vendor_book_id(offer)
        parse_node(offer,'./Ean')
      end

      def parse_price(offer)
        price = parse_node(offer,".//Prices//BnPrice")
        format_price(price) if available?(offer)
      end

      def parse_vendor_offer_id(offer)
        parse_vendor_book_id(offer)
      end

      def parse_offer_detailed_condition(offer)
        "New" if available?(offer)
      end

      def parse_availability(offer)
        parse_node(offer,".//Availability")
      end

      def parse_shipping_time(offer)
        parse_node(offer,".//DeliveryMessage")
      end

      def parse_comments(offer)
      end

      def available?(offer)
        if parse_availability(offer) && !(parse_availability(offer) =~ /Not available/i)
          true
        end
      end
  end
end