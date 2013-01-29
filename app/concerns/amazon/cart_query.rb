module Amazon
	class CartQuery < ApiClass
		attr_reader :link

		def initialize(params)
			@books = params[:books]
			@associate_tag = params[:tag]
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
				@response = send_request(build_request)
				@link = parse_cart_response(@response)
			end

			def build_request
				@request_defaults.merge(build_associate_tag_param)
			end

			def build_associate_tag_param
				build_item_params.merge(:associate_tag => @associate_tag)
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
				parse_node(response.doc,'./CartCreateResponse/Cart/PurchaseURL')
			end

			def parse_node(node,xpath)
				result = node.xpath(xpath).first
				result.content if result
			end

	end
end