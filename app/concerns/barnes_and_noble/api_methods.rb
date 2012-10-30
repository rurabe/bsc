module BarnesAndNoble
	module ApiMethods
		BASE_URL = "http://services.barnesandnoble.com/v03_00/"
		DEFAULT_PARAMS = {:app_id => ENV['BN_API_KEY']}

		def send_request(params)
			response = Net::HTTP.get_response(api_build_uri(params))
			api_parse_response(response)
		end

		private

			def api_build_uri(params)
				operation = params.delete(:operation)
				url = BASE_URL + operation.to_s.camelcase + "?" + api_build_params(params)
				URI(url)
			end

			def api_build_params(params)
				request_params = DEFAULT_PARAMS.merge(params)
				request_params.map { |key,value| "#{key.to_s.camelcase}=#{value}" }.join("&")
			end

			def api_parse_response(response)
				Nokogiri::XML.parse(response.body)
			end
	end
end