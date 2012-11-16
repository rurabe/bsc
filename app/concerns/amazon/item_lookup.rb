module Amazon
	class ItemLookup
		attr_reader :responses, :parsed_response

		def initialize(params) #{:new => ["1..","2.."], :used => ["3..","4.."] :options=>{:id_type => "EAN"}}
			@custom_options = params.delete(:options)
			@params = params
			@request_defaults = {
				:operation			=> 'ItemLookup',
				:service 				=> 'AWSECommerceService',
				:response_group => 'Offers,ItemAttributes,Request',
				:id_type 				=> 'EAN',
				:search_index		=> 'Books'}
	    @ui_parsers = {
				:asin 					=> 'ASIN',
				:ean 						=> 'ItemAttributes/EAN',
				:condition 			=> 'Offers/Offer/OfferAttributes/Condition',
				:price 					=> 'Offers/Offer/OfferListing/Price/Amount'}
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
	 		@responses.each_with_index.flat_map do |response,responses_index|
		 		response.items.each_with_index.map do |item,item_index|
		 			parse_ui_data(item,item_index,responses_index)
		 		end
	 		end
	 	end

	 	# private

	 		def parse_ui_data(item,item_index,responses_index)
	 			{
	 				:asin 			=> parse_asin(item),
	 				:ean 				=> parse_ean(item),
	 				:condition  => parse_condition(item,item_index,responses_index),
	 				:price 			=> parse_price(item),
	 				:vendor			=> "amazon"
	 			}
	 		end

	 		def parse_asin(item)
	 			item.get('ASIN')
	 		end

	 		def parse_ean(item)
	 			item.get('ItemAttributes/EAN')
	 		end

	 		def parse_condition(item,item_index,responses_index)
	 			condition = item.get('Offers/Offer/OfferAttributes/Condition') || condition_index[responses_index][item_index]
	 			condition.downcase if condition
	 		end

	 		def parse_price(item)
	 			format_price(item.get('Offers/Offer/OfferListing/Price/Amount'))
	 		end

	 		def custom_options
	 			@custom_options ||= {}
	 		end

			def control
				build_params.map do |request_params|
					# {:"ItemLookup.1.Condition"=>"New", :"ItemLookup.1.ItemId"=>"1428312234,1604067454,0781760038,1604060441", 
					#  :"ItemLookup.1.MerchantId"=>"Amazon", :"ItemLookup.2.Condition"=>"Used", :"ItemLookup.2.ItemId"=>"160406062X,1604062908"}
					@responses << lookup(request_params)
				end

			end

			def condition_index
				batch_ids.each_slice(2).map do |slice|
					slice.flat_map do |hash|
						hash.flat_map do |k,v|
							v.length.times.map { k.to_s }
						end
					end
				end
			end

			def lookup(request_params)
				send_request(request_params)
			end

			def send_request(request_params)
				Amazon::Ecs.send_request(base_params.merge(request_params))
			end

			def format_price(data)
				(data.to_d / 100) if data
			end

			def base_params
				@request_defaults.merge(custom_options)
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