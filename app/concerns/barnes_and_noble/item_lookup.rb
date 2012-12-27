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

		def ui_data
			@parsed_response = request_items
			products = response.xpath('./ProductLookupResponse/ProductLookupResult/Product')
			products.map do |product| 
				set_price_information(product)
			end
			@parsed_response.to_json
		end

		private

			def control
				@response = send_request(build_lookup_params)
			end

			def build_lookup_params
				@default_params.merge(:ean => parameterized_eans)
			end

			def parameterized_eans
				@eans.delete_if { |product| product.nil? }.join(",")
			end

			def set_price_information(product)
				product_matches = @parsed_response.select { |book| book[:ean] == product.xpath('./Ean').text }
				product_matches.each do |match|
					match.merge!( :price  => product.xpath('./Prices/BnPrice').text,
											  :vendor => "bn" )
				end
			end

			def request_items
				@eans.flat_map do |ean|
					{:condition 	=> "new",
					 :ean 			 	=> ean}
				end
			end

			def ui_data_parsers(product)
					{
						:ean      		=> product.xpath('./Ean').text,
						:price 				=> product.xpath('./Prices/BnPrice').text.to_d,
						:condition 		=> "new",
						:vendor				=> "bn"
					}
			end
	end
end