module Amazon
	class ItemLookup
		attr_reader :responses, :parsed_response

		# params should be in one of two formats:
		#   1. [{:ean => "#{EAN}", :condition => "new"},{:ean => "#{EAN}", :condition => "used"}]
		# 			
		# 		This format allows you to specify whether you want the new or used version of a product
		# 
		# 	2. ["#{EAN}","#{EAN}","#{EAN}","#{EAN}","#{EAN}"]
		# 		
		# 		This format allows you to search new and used prices for a list of EANs 

		def initialize(params) 
			@params = params
	    @responses = []
	    @parsed_response = []
	    control
	 	end

	 	def cart_data
	 		@responses.flat_map do |response|
		 		response.items.map do |item|
		 			item.get('Offers/Offer/OfferListing/OfferListingId')
		 		end
	 		end
	 	end

	 def ui_data
 			@parsed_response = request_items
 			@responses.flat_map do |response|
 				response.items.flat_map do |item|
 					set_price_information(item)
 					set_vendor_information(item)
 				end
 			end
 			@parsed_response
	 	end

	 	private

	 		# For controlling the flow

			def control
				build_params.map do |request_params|
					# {:"ItemLookup.1.Condition"=>"New", :"ItemLookup.1.ItemId"=>"1428312234,1604067454,0781760038,1604060441", 
					#  :"ItemLookup.1.MerchantId"=>"Amazon", :"ItemLookup.2.Condition"=>"Used", :"ItemLookup.2.ItemId"=>"160406062X,1604062908"}
					@responses << lookup(request_params)
				end
			end

			# For sending the request to Amazon

			def lookup(request_params)
				send_request(request_params)
			end

			def send_request(request_params)
				Amazon::Ecs.send_request(base_params.merge(request_params))
			end

			def base_params
				{ :operation			=> 'ItemLookup',
					:service 				=> 'AWSECommerceService',
					:response_group => 'Offers,ItemAttributes,Request',
					:id_type 				=> 'EAN',
					:search_index		=> 'Books'}
			end

			# Parsers and parsing helper methods

	 		def set_price_information(item)
	 			offer_matches = @parsed_response.select { |book| book[:ean] == parse_ean(item) && book[:condition] == parse_condition(item) }
	 			offer_matches.each do |matched_book|
	 				matched_book.merge!( price_information(item) )
	 			end
	 		end

	 		def price_information(item)
	 			{ :price => parse_price(item) }
	 		end

	 		def set_vendor_information(item)
	 			item_matches = @parsed_response.select { |book| book[:ean] == parse_ean(item) }
	 			item_matches.each do |matched_book|
	 				matched_book.merge!( vendor_information(item) )
	 			end
	 		end

	 		def vendor_information(item)
	 			{ :asin 	=> parse_asin(item),
	 			  :vendor => "amazon" }
	 		end

	 		def parse_asin(item)
	 			item.get('ASIN')
	 		end

	 		def parse_ean(item)
	 			item.get('ItemAttributes/EAN')
	 		end

	 		def parse_condition(item)
	 			condition = item.get('Offers/Offer/OfferAttributes/Condition')
	 			condition.downcase if condition
	 		end

	 		def parse_price(item)
	 			format_price(item.get('Offers/Offer/OfferListing/Price/Amount'))
	 		end

			def format_price(data)
				(data.to_d / 100) if data
			end

			# For taking items and turning them into Amazon compatible request params

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
				["new","used"].flat_map do |condition|
					books = request_items.select { |book| book[:condition] == condition }
					books.each_slice(10).map { |slice| slice }				
				end
			end

			def request_items
				if @params.first.class != Hash
					build_product_hashes
				else
					@params
				end
			end

			def build_product_hashes
				@params.flat_map do |ean|
					[{:condition 	=> "new",
						:ean 			 	=> ean},
					 {:condition 	=> "used",
						:ean 				=> ean}]
				end
			end
	end
end