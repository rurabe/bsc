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
			@parsed_response = {}
			control
		end

		private

			def control
				@response = send_request(build_lookup_params)
				parse_lookup_response(@response)
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
					data = parse_product(products)
					key = data[:ean]
					@parsed_response[key] ? @parsed_response[key].merge!(data) : @parsed_response[key] = data
				else
					products.map do |product|
						data = parse_product(product)
						key = data[:ean]
						@parsed_response[key] ? @parsed_response[key].merge!(data) : @parsed_response[key] = data
					end
				end
			end

			def parse_product(product)
					{
						:ean      		=> product.xpath('./Ean').text,
						:bn_new_price => product.xpath('./Prices/BnPrice').text.to_d,
					}
			end
	end
end