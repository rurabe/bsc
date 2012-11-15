module BarnesAndNoble
	class UsedBooks
		attr_reader :response, :response_options, :retries
		def initialize(ean)
			@default_params = {:sze => 5,
												:view => 'isbnservice',
												:template => 'textbooksinlay',
												:usedpagetype => 'usedisbn',
												:uiAction => 'isbnservice'}
			@ean = ean
			@retries = nil
			@response = nil
			@response_options = []
			control
		end

		def ui_data
			@response_options.find { |offer| offer[:rating] > 3.5 }.reject {|k| k == :rating }
		end

		# private
			def control # Super sketchy API
				query = 2.times do |i|
					r = send_request(@ean)
					if !r.include?(nil)
						@retries = i
						return
					end
					@retries = i
				end
			end

			def send_request(ean)
				encoded_response = Net::HTTP.get_response(api_build_uri(ean))
				@response = Nokogiri::HTML.parse(CGI::unescape(encoded_response.body))
				api_parse_response
			end

				def api_build_uri(ean)
					url = "http://search.barnesandnoble.com/used/results.aspx?" + api_build_params(ean)
					URI(url)
				end

					def api_build_params(ean)
						request_params = @default_params.merge(:pean => ean)
						request_params.map { |key,value| "#{key.to_s}=#{value.to_s}" }.join("&")
					end

			def api_parse_response
				@response_options = []
				used_offers = select_used_offers(@response)
				used_offers.map do |offer|
						@response_options << {  :rating => parse_rating(offer),
																		:condition => 'used',
																		:ean => parse_offer_ean(offer),
																		:parent_ean => @ean,
																		:price => parse_offer_price(offer),
																		:vendor => 'bn' }
						parse_offer_ean(offer)
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
				form = node.xpath('./div/div/p[@class="product-details"]/a')
				parse_result(form.attr('href').text,/EAN=(\d+)/) if form.present?
			end

			def parse_result(string,regex)
				match = string.match(regex) if string
				match[1] if match
			end

			def numberize(string)
				string.to_s.gsub("$","").to_d if string
			end

	end
end