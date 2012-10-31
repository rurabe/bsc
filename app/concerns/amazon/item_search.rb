module Amazon
	class ItemSearch
		attr_reader :response, :parsed_response

		def initialize(search_term)
			@search_term = search_term
			@default_options = {:response_group => 'Offers',
                         :search_index => 'Books', 
                         :sort => 'relevancerank',
                         :'ItemSearch.1.Condition'=> 'New', 
                         :'ItemSearch.2.Condition' => 'Used',
                         :'ItemSearch.1.MerchantId'=> 'Amazon'}
      @response = nil
      @parsed_response = {}
      control
		end
    
    private

  		def control
  			@response = Amazon::Ecs.item_search(@search_term,@default_options)
  			parse_amazon_response(@response)
  		end

  		def parse_amazon_response(response)
        if best_match = response.items.first
          @parsed_response[:asin] = best_match.get('ASIN')
        end
        
        if new_offer = response.items.find { |item| item.get('Offers/Offer/OfferAttributes/Condition') == 'New' }
          @parsed_response[:amazon_new_price]            = parse_amazon_price(new_offer)
          @parsed_response[:amazon_new_offer_listing_id] = parse_amazon_offer_listing_id(new_offer)
        end

        if used_offer = response.items.find { |item| item.get('Offers/Offer/OfferAttributes/Condition') == 'Used' }
          @parsed_response[:amazon_used_price]            = parse_amazon_price(used_offer)
          @parsed_response[:amazon_used_offer_listing_id] = parse_amazon_offer_listing_id(used_offer)
        end
      end

      def parse_amazon_price(response)
        price = response.get('Offers/Offer/OfferListing/Price/Amount')
        price.to_d / 100 if price
      end

      def parse_amazon_offer_listing_id(response)
        offer_listing_id = response.get('Offers/Offer/OfferListing/OfferListingId')
      end


	end
end