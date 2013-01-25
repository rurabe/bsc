module BarnesAndNoble
	class ItemLookup
		include ApiMethods

		attr_reader :response, :parsed_response

		def initialize(eans)
			@eans = eans
			@default_params = {
				:operation => 'ProductLookup',
				:product_code => 'Book' }
			@response = nil
			@parsed_response = {}
			control
		end

		def ui_data
			parse_ui_data.to_json
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

			def request_items
				@eans.flat_map do |ean|
					{ :condition => "new", :ean => ean }
				end
			end

			def response_base
				request_items.each do |item|
					item.merge!({ :price => nil, :vendor => "bn" })
				end
			end

			def find_product_data(ean)
				@response.search(".//Product[.//Ean[text()=#{ean}]]").first
			end

			def parse_ui_data
				response_base.map do |book|
					product_data = find_product_data(book[:ean])
					book.merge(ui_data_parsers(product_data))
				end
			end

			def ui_data_parsers(product)
				if product
					{	:ean     => parse_ean(product),
						:price   => parse_price(product) }
				else
					{}
				end
			end

			def parse_ean(product)
				parse_node(product,'.//Ean')
			end

			def parse_price(product)
				price = parse_node(product,".//Prices//BnPrice")
				price.to_d if price && available?(product)
			end

			def available?(product)
				parse_node(product,'.//Availability') != "Not Available"
			end

			def parse_node(node,xpath)
        result = node.search(xpath).first
        result.text.strip if result
      end
	end
end