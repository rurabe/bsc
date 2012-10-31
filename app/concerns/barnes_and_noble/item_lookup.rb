module BarnesAndNoble
	class ItemLookup
		include ApiMethods

		attr_reader :response, :parsed_response

		def initialize(eans)
			@eans = eans
			@default_params = {
				:operation => 'ProductLookup',
				:product_code => 'Book'
			}
			@response = nil
			@parsed_response = nil
			control
		end

		private

			def control
				@response = send_request(build_lookup_params)
				@parsed_response = parse_lookup_response(@response)
			end

			def build_lookup_params
				@default_params.merge(:ean => parameterized_eans)
			end

			def parameterized_eans
				if @eans.class == String
					@eans
				elsif @eans.class == Array
					@eans.join(",")
				end
			end

			def parse_lookup_response(response)
				products = response.xpath('./ProductLookupResponse/ProductLookupResult/Product')
				if products.count == 1
					parse_product(products)
				else
					products.map do |product|
						parse_product(product)
					end
				end
			end

			def parse_product(product)
					{
						:isbn_13      => product.xpath('./Ean').text,
						:bn_new_price => product.xpath('./Prices/BnPrice').text.to_d,
						:bn_link			=> product.xpath('./Url').text
					}
			end
	end
end