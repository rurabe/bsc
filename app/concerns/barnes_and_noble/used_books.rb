module BarnesAndNoble
	class UsedBooks
		attr_reader :response, :parsed_response, :all_parsed_responses
		def initialize(ean)
			@default_params = {:sze => 3,
												:view => 'isbnservice',
												:template => 'textbooksinlay',
												:usedpagetype => 'usedisbn',
												:uiAction => 'isbnservice'}
			@ean = ean
			@response = nil
			@parsed_response = nil
			@all_parsed_responses = nil
			control
		end

		private
			def control # Super sketchy API
				query = 3.times do |i|
					r = send_request(@ean)
					next if r.nil?
					return if r[:bn_used_ean].present?
				end
			end

			def send_request(ean)
				@response = Net::HTTP.get_response(api_build_uri(ean))
				api_parse_response(@response)
				@parsed_response = @all_parsed_responses.first if @all_parsed_responses
			end

			def api_build_uri(ean)
				url = "http://search.barnesandnoble.com/used/results.aspx?" + api_build_params(ean)
				URI(url)
			end

			def api_build_params(ean)
				request_params = @default_params.merge(:pean => ean)
				request_params.map { |key,value| "#{key.to_s}=#{value.to_s}" }.join("&")
			end

			def api_parse_response(response)
				object_response = Nokogiri::HTML.parse(CGI::unescape(response.body))
				used_offers = select_used_offers(object_response)
				@all_parsed_responses = used_offers.map do |offer|
					if parse_rating(offer) > 3
						{
							:bn_used_price => parse_offer_price(offer),
							:bn_used_ean => parse_offer_ean(offer)
						}
					end
				end
			end

			def select_used_offers(response)
				response.xpath('//div[@class="w-box wgt-product-listing-textbooks-item product-root-node"]')
			end

			def parse_offer_price(node)
				numberize(node.xpath('./div/span[@class="price"]').text)
			end

			def parse_rating(node)
				numberize(parse_result(node.xpath('./div/div/p/span[@class="feedback"]').text,/\((.+) out/))
			end

			def parse_offer_ean(node)
				form = node.xpath('./div/div/form/input[@name="EAN"]')
				form.attr('value').text if form.present?
			end

			def parse_result(string,regex)
				match = string.match(regex) if string
				match[1] if match
			end

			def numberize(string)
				string.gsub("$","").to_d
			end

	end
end