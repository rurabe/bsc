class AmazonCartQuery

	def initialize(cart)
		@cart = cart
		@request_defaults = {
			:operation		=> 'CartCreate',
			:service 			=> 'AWSECommerceService' 	 
		}
	end

	def create_cart
		response = send_request
		link = parse_node(response.doc,'./CartCreateResponse/Cart/PurchaseURL')
		{ :link => link }
	end
	
	private

		def send_request
			# Amazon::Ecs.send_request(:operation => 'CartCreate',:'Item.1.OfferListingId' => 'cdr23rg...', :'Item.1.Quantity' => 1,:service => "AWSECommerceService")
			Amazon::Ecs.send_request(build_request)
		end

		def build_request
			@request_defaults.merge(build_item_params)
		end

		def build_item_params
			hash = {}
			get_item_offer_listing_ids.each_with_index do |id,i|
				hash.merge!( :"Item.#{i+1}.OfferListingId" => id, :"Item.#{i+1}.Quantity" => 1 )
			end
			hash
		end

		def get_item_offer_listing_ids
			@cart.cart_items.map(&:offer_listing_id)
		end

		def parse_node(node,xpath)
			result = node.xpath(xpath).first
			result.content if result
		end

end