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
			response = response_base
			response.merge!(best_offer) if best_offer
			response
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

			def response_base
				{
					:vendor => "bn",
					:condition => "used",
					:price => nil,
					:parent_ean => @ean,
					:ean => nil
				}
			end

			def best_offer
				best_offer = @response_options.find { |offer| offer[:rating] > 3.5 }
				best_offer.reject {|k| k == :rating } if best_offer
			end

			def select_used_offers(response)
				response.xpath('//div[@class="w-box wgt-product-listing-textbooks-item product-root-node"]')
			end

			def parse_offer_price(node)
				numberize(parse_node(node,'./div/span[@class="price"]'))
			end

			def parse_rating(node)
				rating = numberize(parse_result(parse_node(node,'./div/div/p/span[@class="feedback"]'),/\((.+) out/))
				rating ? rating : 0
			end

			def parse_offer_ean(node)
				form = node.xpath('./div/div/p[@class="product-details"]/a')
				parse_result(form.attr('href').text,/EAN=(\d+)/) if form.present?
			end

		  def parse_node(node,xpath)
	      result = node.search(xpath).first
	      result.text.strip if result
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