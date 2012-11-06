module Amazon
	class ItemLookup
		attr_reader :responses, :parsed_response

		def initialize(params) #{:new => ["1..","2.."], :used => ["3..","4.."] :options={:id_type => "EAN"}}
			@custom_options = params.delete(:options)
			@lookup_ids = params
			@request_defaults = {
				:operation			=> 'ItemLookup',
				:service 				=> 'AWSECommerceService',
				:response_group => 'Offers,ItemAttributes',
				:id_type 				=> 'EAN',
				:search_index		=> 'Books'}
	    @parsers = {
				:asin => 'ASIN',
				:ean => 'ItemAttributes/EAN',
				:isbn_10 => 'ItemAttributes/ISBN',
				:amazon_new_price => 'Offers/Offer/OfferListing/Price/Amount[../../../OfferAttributes/Condition="New"]',
				:amazon_new_offer_listing_id => 'Offers/Offer/OfferListing/OfferListingId[../../OfferAttributes/Condition="New"]',
				:amazon_used_price => 'Offers/Offer/OfferListing/Price/Amount[../../../OfferAttributes/Condition="Used"]',
				:amazon_used_offer_listing_id => 'Offers/Offer/OfferListing/OfferListingId[../../OfferAttributes/Condition="Used"]'}
	    @responses = []
	    @parsed_response = {}
	    control
	 	end

	 	def offer_listing_ids
	 		@parsed_response.map do |id,info|
	 			info.select {|key,value| key =~ /offer_listing_id/ }.values
	 		end.flatten
	 	end

	 	# private

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
				parse_response(response)
			end

			def send_request(request_params)
				Amazon::Ecs.send_request(base_params.merge(request_params))
			end

			def parse_response(response)
				response.items.each do |item|
					data = @parsers.inject({}) { |hash,(k,v)| item.get(v) ? hash.merge(k => item.get(v)) : hash }
					format_prices!(data)
					key = data[base_params[:id_type].parameterize.to_sym]
					@parsed_response[key] ? @parsed_response[key].merge!(data) : @parsed_response[key] = data
				end
			end

			def format_prices!(data)
				data.select { |k,v| k =~ /price/i ? data[k] = v.to_d / 100 : nil } 
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
				@lookup_ids.flat_map do |condition,ids|
					ids.each_slice(10).map do |batch|
						{condition => batch}
					end
				end
			end
	end
end