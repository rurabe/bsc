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
				:search_index		=> 'Books'
	    }
	    @responses = []
	    @parsed_response = {}
	    control
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
				parse_response(response)
			end

			def send_request(request_params)
				Amazon::Ecs.send_request(base_params.merge(request_params))
			end

			def parse_response(response)
				response.items.each do |item|
					parse = {
						:asin => item.get('ASIN'),
						:ean => item.get('ItemAttributes/EAN'),
						:isbn_10 => item.get('ItemAttributes/ISBN'),
						:amazon_new_price => item.get('Offers/Offer/OfferListing/Price/Amount[../../../OfferAttributes/Condition="New"]'),
						:amazon_new_offer_listing_id => item.get('Offers/Offer/OfferListing/OfferListingId[../../OfferAttributes/Condition="New"]'),
						:amazon_used_price => item.get('Offers/Offer/OfferListing/Price/Amount[../../../OfferAttributes/Condition="Used"]'),
						:amazon_used_offer_listing_id => item.get('Offers/Offer/OfferListing/OfferListingId[../../OfferAttributes/Condition="Used"]')
					}.delete_if { |k,v| v == nil }
					key = parse[base_params[:id_type].parameterize.to_sym]
					@parsed_response[key] ? @parsed_response[key].merge!(parse) : @parsed_response[key] = parse
				end
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
				@lookup_ids.map do |condition,ids|
					ids.each_slice(10).map do |batch|
						{condition => batch}
					end
				end
				.flatten
			end

			def parse_amazon_price(xpath)
        price = response.get(xpath)
        price.to_d / 100 if price
      end
	end
end