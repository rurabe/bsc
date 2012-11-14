module Amazon
	class CartQuery
		attr_reader :link

		def initialize(params)
			@books = params
			@request_defaults = {
				:operation		=> 'CartCreate',
				:service 			=> 'AWSECommerceService' 	 
			}
			@response = nil
			@link = nil
			control
		end
		
		private

			def control
				@response = send_request
				parse_cart_response(@response)
			end

			def send_request
				# Amazon::Ecs.send_request(:operation => 'CartCreate',:'Item.1.OfferListingId' => 'cdr23rg...', :'Item.1.Quantity' => 1,:service => "AWSECommerceService")
				Amazon::Ecs.send_request(build_request)
			end

			def build_request
				@request_defaults.merge(build_item_params)
			end

			def build_item_params
				cart_data.each_with_index.inject({}) do |hash,(id,i)|
					hash.merge!( :"Item.#{i+1}.OfferListingId" => id, :"Item.#{i+1}.Quantity" => 1 )
				end
			end

			def cart_data
				Amazon::ItemLookup.new(@books).cart_data
			end

			def parse_cart_response(response)
				@link = parse_node(response.doc,'./CartCreateResponse/Cart/PurchaseURL')
			end

			def parse_node(node,xpath)
				result = node.xpath(xpath).first
				result.content if result
			end

	end
end