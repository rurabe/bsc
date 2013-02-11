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
			end

			def ids_sliced_by_ten
				["new","used"].flat_map do |condition|
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

			def response_base
				request_items.each do |item|
					item.merge!({ :price => nil, :vendor => "amazon", :asin => nil })
				end
			end

			def build_product_hashes_from_array
				@books.flat_map do |ean|
					[{:condition 	=> "new",
						:ean 			 	=> ean},
					 {:condition 	=> "used",
						:ean 				=> ean}]
				end
			end

			# Parsers and parsing helper methods
			def parse_cart_data
		 		request_items.flat_map do |book|
		 			offer = best_offer(book)
		 			cart_data_parser(offer)
		 		end
	 		end

	 		def parse_ui_data
		 		response_base.flat_map do |book|
		 			offer = best_offer(book)
		 			data = ui_data_parser(offer)
		 			book.merge(data) 
		 		end
	 		end

	 		def cart_data_parser(offer)
	 			offer.get('.//Offer//OfferListingId')
	 		end

	 		def ui_data_parser(offer)
	 			if offer
		 			{
		 				:ean => parse_ean(offer),
		 				:condition => parse_condition(offer),
		 				:price => parse_price(offer),
		 				:asin => parse_asin(offer)
		 			}
		 		else
		 			{}
		 		end
	 		end

	 		def parse_asin(item)
	 			item.get('.//ASIN')
	 		end

	 		def parse_ean(item)
	 			item.get('.//EAN')
	 		end

	 		def parse_condition(item)
	 			condition = item.get('.//Offers//Condition')
	 			condition.downcase if condition
	 		end

	 		def parse_price(item)
	 			format_price(item.get('.//Offers//Price//Amount'))
	 		end

			def format_price(data)
				(data.to_d / 100) if data
			end

			def best_offer(options={})
	 			sorted_orders = find_offers(options).sort { |offer| offer.get('.//Offer//Price//Amount').to_f }
	 			sorted_orders.first if sorted_orders
	 		end

	 		def find_offers(options={})
	 			@responses.flat_map do |response|
	 				response.items.select do |item| 
	 					parse_ean(item)			  == options[:ean] &&
	 				 	parse_condition(item) == options[:condition].to_s.downcase
	 				 end
	 			end
	 		end
	end
end