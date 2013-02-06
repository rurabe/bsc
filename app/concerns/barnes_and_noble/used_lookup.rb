module BarnesAndNoble
  class UsedLookup < Automatron::ParserClass
    attr_reader :response, :retries
    def initialize(ean)
      @ean = ean
      @retries = nil
      @response = nil
      control
    end

    def parse
      build_offer(best_offer)
    end

    private
      def control # Super sketchy API
        2.times do |i|
          r = send_request(@ean)
          if !r.include?(nil)
            @retries = i
            return
          end
          @retries = i
        end
      end

      # Sends reuqest to API and gets response
      def send_request(ean)
        encoded_response = Net::HTTP.get_response(build_uri(ean))
        @response = Nokogiri::HTML.parse(CGI::unescape(encoded_response.body))
      end

      def build_uri(ean)
        url = "http://search.barnesandnoble.com/used/results.aspx?" + build_params(ean)
        URI(url)
      end

      def build_params(ean)
        request_params = default_params.merge(:pean => ean)
        request_params.map { |key,value| "#{key.to_s}=#{value.to_s}" }.join("&")
      end

      def default_params
        { :sze          => 5,
          :view         => 'isbnservice',
          :template     => 'textbooksinlay',
          :usedpagetype => 'usedisbn',
          :uiAction     => 'isbnservice'}
      end

      # Select offers #
      def best_offer
        offers = all_reputable_offers
        offers.min { |offer| parse_offer_price(offer) }
      end

      def all_reputable_offers
        offers = select_used_offers
        offers.reject { |offer| parse_offer_seller_rating(offer) < 3.5} if offers
      end

      def select_used_offers
        @response.xpath('//div[@class="w-box wgt-product-listing-textbooks-item product-root-node"]')
      end

      # Parsers #
      def build_offer(offer)
        if offer
          { :vendor_book_id     => parse_vendor_book_id(offer),
            :price              => parse_offer_price(offer),
            :vendor_offer_id    => parse_vendor_offer_id(offer),
            :detailed_condition => parse_offer_detailed_condition(offer),
            :availability       => parse_offer_availability(offer),
            :shipping_time      => parse_offer_shipping_time(offer),
            :comments           => parse_offer_comments(offer) }
        else
          {}
        end
      end

      def parse_vendor_book_id(offer)
        parse_vendor_offer_id(offer)
      end

      def parse_offer_price(offer)
        numberize(parse_node(offer,'./div/span[@class="price"]'))
      end

      def parse_vendor_offer_id(offer)
        form = offer.search('./div/div/p[@class="product-details"]/a')
        parse_result(form.attr('href').text,/EAN=(\d+)/) if form.present?
      end

      def parse_offer_detailed_condition(offer)
        parse_node(offer,'.//text()[preceding-sibling::*[@class="condition-label"]][1]')
      end

      def parse_offer_availability(offer)
      end

      def parse_offer_shipping_time(offer)
        parse_node(offer,'.//text()[parent::*[@class="product-availability"]][last()]')
      end

      def parse_offer_comments(offer)
        parse_node(offer,'.//text()[preceding-sibling::*[@class="comment-label"]][1]')
      end

      def parse_offer_seller_rating(offer)
        rating = parse_result(parse_node(offer,'./div/div/p/span[@class="feedback"]'),/\((.+) out/)
        rating ? rating.to_d : 0
      end


  end
end