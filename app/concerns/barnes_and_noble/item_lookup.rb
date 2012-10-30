module BarnesAndNoble
	class ItemLookup
		include ApiMethods

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
				@parsed_response = parse_lookup_response(response)
			end

			def build_lookup_params
				parameterized_eans = @eans.join(",")
				@default_params.merge(:ean => parameterized_eans)
			end

			def parse_lookup_response(response)
				products = response.xpath('./ProductLookupResponse/ProductLookupResult/Product')
				products.map do |product|
					{
						:ean          => product.xpath('./Ean').text,
						:bn_new_price => product.xpath('./Prices/BnPrice').text.to_d,
						:bn_string		=> product.xpath('./Url').text
					}
				end
			end
	end
end