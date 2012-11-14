module Amazon
	class ItemLookup
		attr_reader :responses, :parsed_response

		def initialize(params) #{:new => ["1..","2.."], :used => ["3..","4.."] :options={:id_type => "EAN"}}
			@custom_options = params.delete(:options)
			@params = params
			@request_defaults = {
				:operation			=> 'ItemLookup',
				:service 				=> 'AWSECommerceService',
				:response_group => 'Offers,ItemAttributes',
				:id_type 				=> 'EAN',
				:search_index		=> 'Books'}
	    @ui_parsers = {
				:asin => 'ASIN',
				:ean => 'ItemAttributes/EAN',
				:condition => 'Offers/Offer/OfferAttributes/Condition',
				:price => 'Offers/Offer/OfferListing/Price/Amount'}
			@cart_parsers = {
				:offer_listing_id => 'Offers/Offer/OfferListing/OfferListingId'}
	    @responses = []
	    control
	 	end

	 	def cart_data
	 		@responses.flat_map do |response|
		 		response.items.map do |item|
		 			item.get(@cart_parsers[:offer_listing_id])
		 		end
	 		end
	 	end

	 def ui_data
	 		@responses.flat_map do |response|
		 		response.items.map do |item|
		 			@ui_parsers.inject({}) do |hash,(k,v)|
		 				parsed_result = item.get(v)
		 				parsed_result = format_price(parsed_result) if k =~ /price/i && parsed_result
		 				parsed_result = parsed_result.downcase if k =~ /condition/i && parsed_result
		 				hash.merge(k => parsed_result)
		 			end.merge(:vendor => "amazon")
		 		end
	 		end
	 	end

	 	private

			def control
				build_params.map do |request_params|
					# {:"ItemLookup.1.Condition"=>"New", :"ItemLookup.1.ItemId"=>"1428312234,1604067454,0781760038,1604060441", 
					#  :"ItemLookup.1.MerchantId"=>"Amazon", :"ItemLookup.2.Condition"=>"Used", :"ItemLookup.2.ItemId"=>"160406062X,1604062908"}
					lookup(request_params)
				end
			end

			def lookup(request_params)
				response = send_request(request_params)
				@responses << response
			end

			def send_request(request_params)
				Amazon::Ecs.send_request(base_params.merge(request_params))
			end

			def format_price(data)
				(data.to_d / 100) if data
			end

			def base_params
				@custom_options ? @request_defaults.merge(@custom_options) : @request_defaults
			end

			def build_params
				batch_ids.each_slice(2).map do |batch|
					hash = {}
					batch.each_with_index.map do |set,i|
						set.each do |condition,ids|
							hash.merge!(
								:"ItemLookup.#{i+1}.Condition"	=> condition.to_s.camelcase,
								:"ItemLookup.#{i+1}.ItemId" 		=> ids.join(","))
							hash.merge!(
								:"ItemLookup.#{i+1}.MerchantId" => "Amazon") if condition.to_s =~ /new/i
						end
					end
					hash
				end
			end

			def batch_ids
				prepare_params.flat_map do |condition,ids|
					ids.each_slice(10).map do |batch|
						{condition => batch}
					end
				end
			end

			def prepare_params
				if @params.class == Array
					{	:new => @params,
						:used => @params}
				else
					@params
				end
			end
	end
end