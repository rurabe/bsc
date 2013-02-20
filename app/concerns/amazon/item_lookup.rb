module Amazon
  class ItemLookup < ApiClass
    attr_reader :responses

    # params should be in one of two formats:
    #   1. [{:ean => "#{EAN}", :condition => "new"},{:ean => "#{EAN}", :condition => "used"}]
    #       
    #     This format allows you to specify whether you want the new or used version of a product
    # 
    #   2. ["#{EAN}","#{EAN}","#{EAN}","#{EAN}","#{EAN}"]
    #     
    #     This format allows you to search new and used prices for a list of EANs 

    def initialize(books) 
      @books = books
      @responses = []
      control
    end

    def parse
      request_items.map { |book| parse_offers(book) }
    end

    # private

      # For controlling the flow #
      def control
        @responses = build_params.map { |request_params| lookup(request_params) }
      end

      # For sending the request to Amazon #
      def lookup(request_params)
        send_request(base_params.merge(request_params))
      end

      def base_params
        { :operation      => 'ItemLookup',
          :response_group => 'ItemAttributes,OfferListings',
          :id_type        => 'EAN',
          :search_index   => 'Books'}
      end

      # For building Amazon compatible request parameters
      def build_params
        ids_sliced_by_ten.each_slice(2).map do |batch|
          build_params_from_batch(batch)
        end
      end

      def build_params_from_batch(batch)
        batch.each_with_index.inject({}) do |hash,(slice,i)|
          hash.merge(build_params_from_slice(slice,i))
        end
      end

      def build_params_from_slice(slice,i)
        condition = slice.first[:condition].to_s.camelcase
        params = {:"ItemLookup.#{i+1}.Condition"  => condition,
                  :"ItemLookup.#{i+1}.ItemId"     => slice.map {|book| book[:ean]}.join(",")}
        params.merge!(
                  :"ItemLookup.#{i+1}.MerchantId" => "Amazon") if condition.to_s =~ /new/i
        params
      end

      def ids_sliced_by_ten
        ["new","used","all"].flat_map do |condition|
          books = request_items.uniq.select { |book| book[:condition] == condition }
          books.each_slice(10).map { |slice| slice }        
        end
      end

      def request_items
        if @books.first.class == String
          build_product_hashes_from_array
        else
          @books
        end
      end

      def build_product_hashes_from_array
        @books.flat_map do |ean|
          [{:condition  => "all",
            :ean        => ean  }]
        end
      end

      # Parse helpers #
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
        ean       = book[:ean]
        condition = offer_base[:condition].titlecase
        @responses.flat_map do |r|
          r.search("//Item[.//EAN='#{ean}']//Offer[.//Condition='#{condition}']")
        end
      end

      def response_base(book)
        { :ean                => book[:ean],
          :offers_attributes  => offer_response_base(book) }
      end

      def offer_response_base(book)
        conditions = book[:condition] =~ /all/i ? ["new","used"] : [book[:condition]]
        conditions.map { |condition| build_offer_response_base(book.merge(:condition => condition)) }
      end

      def build_offer_response_base(book)
        { :vendor           => 'Amazon',
          :condition        => book[:condition] }
      end

      def build_offer(offer)
        { :vendor_book_id     => parse_vendor_book_id(offer),
          :price              => parse_price(offer),
          :vendor_offer_id    => parse_vendor_offer_id(offer),
          :detailed_condition => parse_detailed_condition(offer),
          :availability       => parse_availability(offer),
          :shipping_time      => parse_shipping_time(offer),
          :comments           => parse_comments(offer) }
      end

      def parse_vendor_book_id(offer)
        parse_node(offer,"../../ASIN")
      end

      def parse_condition(offer)
        parse_node(offer,".//Condition")
      end

      def parse_price(offer)
        price = parse_node(offer,".//Price//Amount")
        format_price(price)
      end

      def parse_vendor_offer_id(offer)
        parse_node(offer,".//OfferListing//OfferListingId")
      end

      def parse_detailed_condition(offer)
      end

      def parse_availability(offer)
        parse_node(offer,".//AvailabilityType")
      end

      def parse_shipping_time(offer)
        parse_node(offer,".//OfferListing//Availability")
      end

      def parse_comments(offer)
      end

      def available?(offer)
        !!parse_price(offer)
      end



  end
end