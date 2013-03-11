module Amazon
	class CartQuery < ApiClass

		def initialize(params)
			@books = params['books']
			@associate_tag = "bsc-#{params['school']}-20"
			@response = nil
			control
		end
		
		def link
			parse_cart_response(@response)
		end

		private

			def control
				@response = send_request(build_request)
			end

			def build_request
				base_params.merge(build_associate_tag_param)
			end

			def build_associate_tag_param
				build_item_params.merge(:associate_tag => @associate_tag)
			end

			def build_item_params
				cart_data.each_with_index.inject({}) do |hash,(id,i)|
					hash.merge!( :"Item.#{i+1}.OfferListingId" => id, :"Item.#{i+1}.Quantity" => 1 )
				end
			end

			def base_params
				{ :operation		=> 'CartCreate',
					:service 			=> 'AWSECommerceService' }
			end

			def cart_data
				# TODO raise a sold out error if nils are included
				get_offer_ids.reject(&:nil?) #right now it just silently kicks them out
			end

			def get_offer_ids
				updated_query_data.flat_map do |book|
				  book[:offers_attributes].flat_map do |offer|
				    offer[:vendor_offer_id]
				  end
				end
			end

			def updated_query_data
				Amazon::ItemLookup.new(sanitized_query_data).parse
			end

			def sanitized_query_data
				@books.map { |book| book.reject { |k,v| extra_attrs.include?(k) } }
			end

			def extra_attrs
				['vendor', 'vendor_offer_id', 'vendor_book_id', 'price']
			end

			def parse_cart_response(response)
				parse_node(response,'.//Cart/PurchaseURL')
			end
	end
end