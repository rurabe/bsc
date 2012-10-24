class AmazonItemLookup
	attr_reader :offer_listing_ids

	def initialize(order_asins) #{:new => ["1..","2.."], :used => ["3..","4.."]}
		@order_asins = order_asins
		@request_defaults = {
			:operation								 	=> 'ItemLookup',
			:service 									 	=> 'AWSECommerceService',
			:response_group 					 	=> 'Offers',
			:id_type 									 	=> 'ASIN'
    }
    @offer_listing_ids = []
    control
 	end

 	private

		def control
			build_params.map do |request_params|
				# {:"ItemLookup.1.Condition"=>"New", :"ItemLookup.1.ItemId"=>"1428312234,1604067454,0781760038,1604060441", 
				#  :"ItemLookup.1.MerchantId"=>"Amazon", :"ItemLookup.2.Condition"=>"Used", :"ItemLookup.2.ItemId"=>"160406062X,1604062908"}
				@offer_listing_ids += lookup(request_params)
			end
		end

		def lookup(request_params)
			response = send_request(request_params)
			parse_response(response)
		end

		def send_request(request_params)
			request = @request_defaults.merge(request_params)
			Amazon::Ecs.send_request(request)
		end

		def parse_response(response)
			response.items.map {|x| x.get('Offers/Offer/OfferListing/OfferListingId')}
		end

		def build_params
			batch_asins.each_slice(2).map do |batch|
				hash = {}
				batch.each_with_index.map do |set,i|
					set.each do |condition,asins|
						hash.merge!(
							:"ItemLookup.#{i+1}.Condition"	=> condition.to_s.camelcase,
							:"ItemLookup.#{i+1}.ItemId" 		=> asins.join(","))
						hash.merge!(
							:"ItemLookup.#{i+1}.MerchantId" => "Amazon") if condition.to_s =~ /new/i
					end
				end
				hash
			end
		end

		def batch_asins
			@order_asins.map do |condition,asins|
				asins.each_slice(10).map do |batch|
					{condition => batch}
				end
			end
			.flatten
		end
end