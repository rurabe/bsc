module Amazon
	class ItemLookup < ApiClass
		attr_reader :responses

		# params should be in one of two formats:
		#   1. [{:ean => "#{EAN}", :condition => "new"},{:ean => "#{EAN}", :condition => "used"}]
		# 			
		# 		This format allows you to specify whether you want the new or used version of a product
		# 
		# 	2. ["#{EAN}","#{EAN}","#{EAN}","#{EAN}","#{EAN}"]
		# 		
		# 		This format allows you to search new and used prices for a list of EANs 

		def initialize(books) 
			@books = books
	    @responses = []
	    @parsed_response = []
	    control
	 	end

	 	def cart_data
	 		parse_cart_data
	 	end

	 	def ui_data
	 		parse_ui_data.to_json
	 	end

	 	private

	 		# For controlling the flow
			def control
				@responses = build_params.map { |request_params| lookup(request_params) }
			end

			# For sending the request to Amazon
			def lookup(request_params)
				send_request(base_params.merge(request_params))
			end

			def base_params
				{ :operation			=> 'ItemLookup',
					:service 				=> 'AWSECommerceService',
					:response_group => 'ItemAttributes,OfferListings',
					:id_type 				=> 'EAN',
					:search_index		=> 'Books'}
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
				params = {:"ItemLookup.#{i+1}.Condition"	=> condition,
									:"ItemLookup.#{i+1}.ItemId" 		=> slice.map {|book| book[:ean]}.join(",")}
				params.merge!(
									:"ItemLookup.#{i+1}.MerchantId" => "Amazon") if condition.to_s =~ /new/i
				params
			end

			def ids_sliced_by_ten
				["new","used","all"].flat_map do |condition|
					books = request_items.select { |book| book[:condition] == condition }
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
					[{:condition 	=> "all",
						:ean 			 	=> ean  }]
				end
			end

			def parse_cart_data
				all_offers = parse_items
				lowest_offers = request_items.map { |item| fetch_lowest_offer(item,all_offers) }
				lowest_offers.map { |offer| offer[:offer_listing_id] }
			end

			def fetch_lowest_offer(item,offers)
				matching_offers = offers.select { |offer| offer_matches?(item,offer) }
				matching_offers.sort { |offer| offer[:price] }.first if matching_offers
			end

			def offer_matches?(item,offer)
				!item.map { |k,v| offer[k] == v }.include?(false)
			end

			def parse_ui_data
				parse_items
			end

			def parse_items
	 			get_items.flat_map { |item| parse_item(item) }
	 		end

	 		def get_items
	 			@responses.flat_map { |r| r.search("//Item") }
	 		end

	 		def parse_item(item) 
	 			[:new,:used].map { |condition| build_offer(item,condition) }
	 		end

	 		def build_offer(item,condition)
	 			base_info = { :ean 			=> parse_item_ean(item),
	 										:condition => condition.to_s }
	 			offer = item.search(".//Offer[.//Condition[text()='#{condition.to_s.camelcase}']]")
	 			offer.present? ? base_info.merge!(parse_offer(offer)) : base_info
	 		end

	 		def parse_offer(offer)
	 			{ :price 						=> parse_price(offer),
	 				:asin 						=> parse_asin(offer),
	 				:offer_listing_id => parse_offer_listing_id(offer),
	 				:availability			=> parse_availability(offer) }
	 		end

	 		def parse_asin(offer)
	 			parse_node(offer,"../../ASIN")
	 		end

	 		def parse_item_ean(offer)
	 			parse_node(offer,".//EAN")
	 		end

	 		def parse_condition(offer)
	 			parse_node("Condition")
	 		end

	 		def parse_price(offer)
	 			price = parse_node(offer,"Price/Amount")
	 			format_price(price)
	 		end

	 		def parse_offer_listing_id(offer)
	 			parse_node(offer,'OfferListing/OfferListingId')
	 		end

	 		def parse_availability(offer)
	 			parse_node(offer,'OfferListing/Availability')
	 		end

			def format_price(data)
				(data.to_d / 100) if data
			end

	 		def parse_node(node,xpath)
        result = node.search(xpath) if node
        result.text.strip if result
      end

      def parse_result(string,regex)
        match = string.match(regex) if string
        match[1].strip if match
      end
	end
end